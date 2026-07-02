# udce-fmri
fMRI experiment for running comparison tasks for words or numbers in German and French. The experiments are programmed in MATLAB's Psychtoolbox (version 3.0.22 downloaded in May 2025; paid version). The fMRI analysis uses SPM 25.

### 

### runTaskMRI_de.m
This is the file for German participants because instructions will be needed in German language.

### runTaskMRI_fr.m
This is the file for French-speaking participants in Germany because instructions will be needed in the French language.

### create_nifti.m
We can create NIfTIs automatically from DICOM files via MRIcroGL. Compatible with Windows, Mac, and Linux, 
we can access the MRIcroGL from MATLAB by simply adjusting the paths to those of our working machine 
(path to BIDS folder, path to MRIcroGL, indicating whether we want ".nii.gz" or ".nii", and then we are good to go. 
The script scans participants for whether the `/func` or `/anat` directories are already filled. 
If one of them is not filled, it starts the  DICOM-to-NIfTI conversion.


