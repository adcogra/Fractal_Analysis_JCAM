function output = svmBaggingClassifier_test(dirOutput, features, gridCim, gridRim, coordRow, coordCol, totalMask, GT, trainOut, optSVM, mand)
% @author Adrian COLOMER <adcogra@i3b.upv.es>
% @date 2017-02-01

%% Building data structure for SVM
data = []; labels =[]; numIm = []; coordR = []; coordC = []; pyrLevel = []; totMask = [];
verbose = 1;

for z = 1 : length(features)
    
    if size(features{z},1) > 1
        data = [data; features{z}];
    else
        data = [data; features{z}'];
    end
    
    %% Label vector containing the GT
    labels = [labels GT{z}];
    
    %% Label to save the number image information
    if size(features{z},1) > 1
        numIm = [numIm zeros(1,size(features{z},1))+z];
    else
        numIm = [numIm zeros(1,size(features{z},2))+z];
    end
    
    %% Total mask
    totMask = [totMask totalMask{z}];
    
    %% Grids
    coordR = [coordR coordRow{z}];
    coordC = [coordC coordCol{z}];
    
    for n = 1 : length(gridRim{z})
        %coord = [coord combvec(gridRim{z}{n},gridCim{z}{n})];
        pyrLevel = [pyrLevel zeros(1,length(gridRim{z}{n})*length(gridCim{z}{n})) + n];
    end
    
end

%% Selecting data
if(mand.onlyFull)
    goodPatches = find(totMask==1); % Removing data patches containing disk or external pixels
    data = data(goodPatches,:);
    labels = labels(goodPatches);
    numIm = numIm(goodPatches);
    coordR = coordR(goodPatches);
    coordC = coordC(goodPatches);
    pyrLevel = pyrLevel(goodPatches);
else
    goodPatches = find(totMask >= 0); %Removing OOB (OutOfBounds) patches
    data = data(goodPatches,:);
    labels = labels(goodPatches);
    numIm = numIm(goodPatches);
    coordR = coordR(goodPatches);
    coordC = coordC(goodPatches);
    pyrLevel = pyrLevel(goodPatches);
end

%% If I only want to classify the patches related to the basis of the pyramid
if(mand.onlyPyramidBasis)
    patchesBasis = find(pyrLevel==1);
    data = data(patchesBasis,:);
    labels = labels(patchesBasis);
    numIm = numIm(patchesBasis);
    coordR = coordR(patchesBasis);
    coordC = coordC(patchesBasis);
    pyrLevel = pyrLevel(patchesBasis);
end

for k = 1 : length(trainOut.model)
    
    %% Testing SVM model
    tic,
    [predict_label_L{k}, accuracy_L{k}, dec_values_L{k}] = svmpredict(labels', data, trainOut.model{k}, eval(optSVM.test));
    toc
    
end

output = classifierPerformanceEvaluation(dirOutput, dec_values_L, accuracy_L, labels, coordR, coordC, numIm, pyrLevel, optSVM, mand);
