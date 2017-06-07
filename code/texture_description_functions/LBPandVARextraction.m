function [h_LBP, h_VAR, h_LBP_VAR] = LBPandVARextraction(I, mask, mand, opt)
% @author Adrian COLOMER <adcogra@i3b.upv.es>
% @date 2017-02-01

%% Computing the LBP & VAR images
[ILBP, IVAR, totalMask] = localBinaryPatterns (I, mask.vesselMask, mask.diskMask, mask.extMask, opt.R, opt.P, opt.n_filter);

%% Computing the histograms
switch mand.type
    case 'grWin'
        %Extracting patches from the image and mask
        blkLBP = im2col(ILBP,[mand.bb1, mand.bb2],'distinct');
        blkVAR = im2col(IVAR,[mand.bb1, mand.bb2],'distinct');
        blkTotalMask = im2col(totalMask,[mand.bb1, mand.bb2],'distinct');
        %Computing h_LBP & h_VAR & h_LBP_VAR for the grille
        %tic,
        [h_LBP, h_VAR, h_LBP_VAR] = patchHistogramComputation(blkLBP, blkVAR, blkTotalMask);
        %toc
        
    case 'slWin'
        %Computing h_LBP & h_VAR & h_LBP_VAR for the sliding window
        %tic,
        [h_LBP, h_VAR, h_LBP_VAR] = patchPixelHistogramComputation(I, ILBP, IVAR, totalMask, mand);
        %toc
end

%Plot h_LBP_VAR for one patch
% f1 = figure;
% bar(h_LBP_VAR(136,:))
% title('Histogram LBPV')
% xlabel('Label asigned in the LBP image')
% ylabel('Cumulative value of VAR')

