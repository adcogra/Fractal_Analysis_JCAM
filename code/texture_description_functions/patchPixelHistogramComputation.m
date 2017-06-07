function [h_LBP, h_VAR, h_LBP_VAR] = patchPixelHistogramComputation(I, ILBP, IVAR, totalMask, mand)
% @author Adrian COLOMER <adcogra@i3b.upv.es>
% @date 2017-02-01

%% Grid in rows and columns
gridC = 1 : mand.stepC : size(I,2);
gridR = 1 : mand.stepR : size(I,1);

%Important! I make the grille using the original image size because the size 
%of the ILBP image is modified a couple of pixels in each axis. 

%% Avoiding warnings of parfor loop
bb1 = mand.bb1;
bb2 = mand.bb2;

ind = 1;

for c = 1 : length(gridC)
    for r = 1 : length(gridR)
        
        %Taking into account the bounds
        if (gridR(r) - floor(bb1/2) >= 1 && gridC(c) - floor(bb2/2) >= 1 &&...
                gridR(r) + floor(bb1/2) <= size(ILBP,1) &&...
                gridC(c) + floor(bb2/2) <= size(ILBP,2))
            winR = gridR(r) - floor(bb1/2) : gridR(r) + floor(bb1/2);
            winC = gridC(c) - floor(bb2/2) : gridC(c) + floor(bb2/2);
        else
            %Zero vector when I am out of bounds (inicialization)
            h_LBP(ind,:) = zeros(1,10);
            h_VAR(ind,:) = zeros(1,256);
            h_LBP_VAR(ind,:) = zeros(1,10); %%% OJOOOOOOOOOOOOOO QUE LO CAMBIO A 18 PERO ES 10 PARA LBP(8,1)
            ind = ind + 1;
            continue;
        end
        
        %Image and Mask Patch
        imPatchLBP = ILBP(winR,winC);
        imPatchVAR = IVAR(winR,winC);
        imPatchTM = totalMask(winR,winC);
        
        %% LBP histogram
        h1 = hist(imPatchLBP(imPatchTM(:)>0), 0:9); %10 bins due to the rotation-invariant uniform LBPs
        %Normalization
        if(sum(h1)>0)
            h_LBP(ind,:) = h1/sum(h1);
        else
            h_LBP(ind,:) = h1;
        end
        
        %% VAR histogram
        h2 = hist(imPatchVAR(imPatchTM(:)>0), 0:255); %256 bins
        %Normalization
        if(sum(h2)>0)
            h_VAR(ind,:) = h2/sum(h2);
        else
            h_VAR(ind,:) = h2;
        end
        
        %% LBP/VAR histogram
        h3 = zeros(1,10); %10 bins due to the rotation-invariant uniform LBPs %%% OJOOOOOOOOOOOOOO QUE LO CAMBIO A 18 PERO ES 10 PARA LBP(8,1)
        for s = 1 : length(imPatchLBP(:))
            if(imPatchTM(s)>0)
                h3(imPatchLBP(s)+1) = h3(imPatchLBP(s)+1) + imPatchVAR(s);
            end
        end
        %Normalization
        if(sum(h3)>0)
            h_LBP_VAR(ind,:) = h3/sum(h3);
        else
            h_LBP_VAR(ind,:) = h3;
        end
        
        %Incrementing the index
        ind = ind + 1;
    end
end