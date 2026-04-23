
# preprocessed:
f <- "C:/Users/Roman/Documents/MATLAB/projects/udce-fmri/tasks/data/sub-004/func/s2_w_r_v_4000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_4000.nii"

# not preprocessed:
f <- "C:/Users/Roman/Documents/MATLAB/projects/udce-fmri/tasks/data/sub-004/func/4000_BOLD_NCT_2d_st3.4_gap.6_20251216152646_4000.nii"

library("RNifti")

image <- readNifti(f)

pixdim(image)
pixunits(image)
