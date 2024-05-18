%% COLOR-ENHANCED PointNET++ ALGORITHM

%% Data Management
dataFolder      = fullfile('{Your Data Path Here}');
trainDataFolder = fullfile(dataFolder,'TRAIN');
testDataFolder  = fullfile(dataFolder,'TEST');
%% Read .las File & Preview
lasReader = lasFileReader(fullfile(trainDataFolder,'{One of The Train Data Name for Previewving}'));
[pc,attr] = readPointCloud(lasReader,'Attributes','Classification');
labels    = attr.Classification;

pc = select(pc,labels~=0);
labels = labels(labels~=0);
    classNames = ["Building"
                  "Roof"
                  "Ground"];
figure;
ax = pcshow(pc.Location,labels);
helperLabelColorbar(ax,classNames);
title("Point Cloud with Overlaid Ground Truth Labels");

%% Preprocessing
blocksize   = [51 51 Inf];
fs          = matlab.io.datastore.FileSet(trainDataFolder);
bpc         = blockedPointCloud(fs,blocksize);
numClasses  = numel(classNames);
[weights,maxLabel,maxWeight] = helperCalculateClassWeights(fs,numClasses);

% Preview Point Cloud
ptcld = preview(ldsTrain);
figure;
pcshow(ptcld.Location);
title("Sample Point Cloud");

ldsTrain  = blockedPointCloudDatastore(bpc);
labelIDs  = 1 : numClasses;
numPoints = 8192;

ldsTransformed = transform(ldsTrain, ...
                           @(x,info) helperTransformToTrainData(x, ...
                                                                numPoints, ...
                                                                info, ...
                                                                labelIDs, ...
                                                                classNames), ...
                                                                'IncludeInfo',true);
read(ldsTransformed)


%% PointNet++ Model Creation
lgraph = pointnetplusLayers(numPoints, ...
                            6, ...
                            numClasses, ...
                            NormalizationLayer ="instance", ...
                            NumClusters        = 2048, ...
                            ClusterRadius      = 0.1, ...
                            ClusterSize        = 64, ...
                            PointNetLayerSize  = 64);

larray = pixelClassificationLayer('Name', ...
                                  'SegmentationLayer', ...
                                  'ClassWeights'     , weights, ...
                                  'Classes'          , classNames);
lgraph = replaceLayer(lgraph,'FocalLoss',larray);

%% Training Options
learningRate               = 0.001;
l2Regularization           = 0.0001;
numEpochs                  = 1000;
miniBatchSize              = 128;   % You can decrease according to your hardware specs.
learnRateDropFactor        = 0.01;
learnRateDropPeriod        = 10;
gradientDecayFactor        = 0.9;
squaredGradientDecayFactor = 0.999;

options = trainingOptions('adam', ...
                          'InitialLearnRate'    ,learningRate, ...
                          'L2Regularization'    ,l2Regularization, ...
                          'MaxEpochs'           ,numEpochs, ...
                          'MiniBatchSize'       ,miniBatchSize, ...
                          'LearnRateSchedule'   ,'piecewise', ...
                          'LearnRateDropFactor' ,learnRateDropFactor, ...
                          'LearnRateDropPeriod' ,learnRateDropPeriod, ...
                          'GradientDecayFactor' ,gradientDecayFactor, ...
                          'SquaredGradientDecayFactor',squaredGradientDecayFactor, ...
                          'Plots'                     , 'training-progress', ...
                          'ExecutionEnvironment'      , 'gpu', ...
                           Shuffle                      = 'every-epoch', ...
                           BatchNormalizationStatistics = 'population', ...
                           OutputNetwork                = 'last-iteration');

%% Train or Load PointNet++ Model
doTraining = true; % Change as false, if you have trained model.

if doTraining
    [net,info] = trainNetwork(ldsTransformed,lgraph,options);
else
    load('{Your Trained Model Path Here}','net');
end

%% Semantic Segmentation Section

tbpc                = blockedPointCloud(fullfile(testDataFolder,'{One of the Test Data Name Here}'),blocksize);
tbpcds              = blockedPointCloudDatastore(tbpc);
numNearestNeighbors = 40;
radius              = 0.05;

while hasdata(tbpcds)

    [ptCloudDense,infoDense] = read(tbpcds);
    labelsDense   = infoDense.PointAttributes.Classification;
    ptCloudDense  = select(ptCloudDense{1},labelsDense~=0);
    labelsDense   = labelsDense(labelsDense~=0);
    ptCloudSparse = helperDownsamplePoints(ptCloudDense, ...
                                           labelsDense, ...
                                           numPoints);

    limits                       = [ptCloudDense.XLimits;ptCloudDense.YLimits;ptCloudDense.ZLimits];
    ptCloudSparseLocation        = ptCloudSparse.Location;
    ptCloudSparseLocation(1:2,:) = limits(:,1:2)';
    ptCloudSparse = pointCloud(ptCloudSparseLocation, ...
                               'Color'    , ptCloudSparse.Color, ...
                               'Intensity', ptCloudSparse.Intensity, ...
                               'Normal'   , ptCloudSparse.Normal);

    ptCloudSparseNormalized    = helperNormalizePointCloud(ptCloudSparse);
    ptCloudDenseNormalized     = helperNormalizePointCloud(ptCloudDense);
    ptCloudSparseForPrediction = helperTransformToTestData(ptCloudSparseNormalized);

    labelsSparsePred = semanticseg(ptCloudSparseForPrediction{1,1}, ...
        net,'OutputType','uint8');

    interpolatedLabels = helperInterpolate(ptCloudDenseNormalized, ...
                                           ptCloudSparseNormalized, ...
                                           labelsSparsePred, ...
                                           numNearestNeighbors, ...
                                           radius, ...
                                           maxLabel, ...
                                           numClasses);

    labelsDensePred   = vertcat(labelsDensePred,interpolatedLabels);
    labelsDenseTarget = vertcat(labelsDenseTarget,labelsDense);

end

%% Evaluation of the Model
confusionMatrix = segmentationConfusionMatrix(double(labelsDensePred), ...
                                              double(labelsDenseTarget), ...
                                              'Classes',1:numClasses);

metrics = evaluateSemanticSegmentation({confusionMatrix}, ...
                                        classNames, ...
                                        'Verbose',false);

metrics.DataSetMetrics
metrics.ClassMetrics

% Confusion Matrix
figure,
confusionchart(confusionMatrix, classNames);




















