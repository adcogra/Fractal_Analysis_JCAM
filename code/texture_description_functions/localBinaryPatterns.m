
function [LBP, VAR, totalMask_aux] = localBinaryPatterns (im, vesselMask, diskMask, extMask, R, P, n_filter)
% @author Adrian COLOMER <adcogra@i3b.upv.es>
% @date 2017-02-01

%% Visualization parameters
verbose = 0;

%% Mask binarization
if (~islogical(vesselMask))
    vesselMask = (vesselMask>128);
end
if (~islogical(diskMask))
    diskMask = (diskMask>128);
end
if (~islogical(extMask))
    extMask = (extMask>128);
end

%% Selecting image component
% if (size(im,3)>1)
%     im = im(:,:,2);
% end
%figure, imshow(mat2gray(im)), title('Trozo original');

%% Dilating vesselMask and diskMask
vesselMask = imdilate(vesselMask,strel('disk',R+1));
diskMask = imdilate(diskMask,strel('disk',R+1));
extMask = imerode(extMask, strel('disk',11));
% figure,imshow(extMask)

%% Resizing masks (Para igualar el tamaño de la imagen LBP que se modifica al computarlo)
vesselMask_aux = vesselMask(R+1:end-R,R+1:end-R);
diskMask_aux = diskMask(R+1:end-R,R+1:end-R);
extMask_aux = extMask(R+1:end-R,R+1:end-R);

%% Jointing masks
totalMask_aux = and(extMask_aux,and(not(vesselMask_aux),not(diskMask_aux)));

%% Median filtering
im = medfilt2(im, [n_filter n_filter]);

%% Algorithm LBP-VAR
%MAPPING = getmapping(P,'ri'); % rotation-invariant LBP
MAPPING=getmapping(P,'riu2'); % uniform rotation-invariant LBP.
LBP = lbp(im,R,P,MAPPING,'i');
%figure, imshow(mat2gray(LBPIM));
VAR = cont(im,R,P);
%figure, imshow(mat2gray(C))

LBP = double(LBP);
VAR = double(VAR);

% LBP = double(LBP).*totalMask_aux;
% VAR = double(VAR).*totalMask_aux;

%% Figures & Data
if(verbose)
    figure, imshow(mat2gray(LBP.*totalMask_aux))
    figure, imshow(mat2gray(VAR.*totalMask_aux))
end

% imwrite(mat2gray(LBP.*totalMask_aux),name_LBP_image)
% imwrite(mat2gray(VAR.*totalMask_aux),name_contrast_image)

end




