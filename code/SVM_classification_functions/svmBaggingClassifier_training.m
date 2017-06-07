function [model, dataModel] = svmBaggingClassifier_training(features, gridRim, gridCim, totalMask, GT, optSVM, mand)
% @author Adrian COLOMER <adcogra@i3b.upv.es>
% @date 2017-02-01

%% Building data structure for SVM
data = []; labels =[]; pyrLevel = []; totMask = [];

for z = 1 : length(features)
    
    %% Adding the data from image z
    if size(features{z},1) > 1
        data = [data; features{z}];
    else
        data = [data; features{z}'];
    end
    
    %% Label vector containing the GT
    labels = [labels GT{z}];
    
    %% Total mask
    totMask = [totMask totalMask{z}];
    
    %% Spatial Pyramid
    for n = 1 : length(gridRim{z})
        pyrLevel = [pyrLevel zeros(1,length(gridRim{z}{n})*length(gridCim{z}{n})) + n];
    end
    
end

%% Selecting data
if(mand.onlyFull)
    goodPatches = find(totMask==1); % Removing data patches containing disk or external pixels
    data = data(goodPatches,:);
    labels = labels(goodPatches);
    pyrLevel = pyrLevel(goodPatches);
else
    goodPatches = find(totMask >= 0); %Removing OOB (outOfBounds) patches
    data = data(goodPatches,:);
    labels = labels(goodPatches);
    pyrLevel = pyrLevel(goodPatches);
end

%% If I only want to classify the patches related to the basis of the pyramid
if(mand.onlyPyramidBasis)
    patchesBasis = find(pyrLevel == 1);
    data = data(patchesBasis,:);
    labels = labels(patchesBasis);
end

%% Obtaining N
posPath = find(labels == 1);
posHealthy = find(labels == 2);
N = round(length(posHealthy)/length(posPath));

%% Number of healthy samples for each classifier
numHS = length(1:N:length(posHealthy));

%% Random permutation of the healthy samples
if (exist(['randperm_set',num2str(mand.numFoldTest),'.mat'],'file'))
    load(['randperm_set',num2str(mand.numFoldTest),'.mat']);
else
    p1 = randperm(length(posHealthy));
    save(['randperm_set',num2str(mand.numFoldTest),'.mat'], 'p1');
end

ind = 1;
while(~isempty(p1))
    
    %% Selecting samples for a new classifier in each iteration
    if(length(p1) >= numHS)
        dataModel{ind} = data([posHealthy(p1(1:numHS)) posPath],:);
        labelsClassn = labels([posHealthy(p1(1:numHS)) posPath]);
        %Updating p1
        p1(1:numHS) = [];
    else
        dataModel{ind} = data([posHealthy(p1) posPath],:);
        labelsClassn = labels([posHealthy(p1) posPath]);
        %Updating p1
        p1 = [];
    end

    %% Training the SVM model
    model{ind} = svmtrain(labelsClassn', dataModel{ind}, eval(optSVM.train));
    
    ind = ind + 1;
end
