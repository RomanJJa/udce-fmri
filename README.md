# udce-fmri
fMRI experiment for running comparison tasks for words or numbers in German and French. The experiments are programmed in MATLAB's Psychtoolbox (version 3.0.22 downloaded in May 2025; paid version). The fMRI analysis uses SPM 25.

### create_sub_stimulus_sets.R
By accessing the original stimulus sets from the originalStimuli directory, we can create stimulus sets for each participant:
shuffle, pseudo-randomize, insert null events, manipulate inter-stimulus intervals.
Stimulus sets will not be overwritten. If you would like to create new stimulus sets for a participant, please first delete their directory. 
This way, we make sure that we do not overwrite stimuli from already collected data. Sure, we can always infer stimulus sets from the `/beh` directory,
but we should always aim to keep all data for documentation.

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

**Important**: You need to define `protocol2bids.json` to run this process.
No files should be renamed "by hand" as this is a common source for errors.
You only need to define `protocol2bids.json` once for the entire MRI protocol (i.e., study).

### protocol2bids.json
This file will be used by `create_nifti.m` to properly store newly created NIfTI files.
It maps the complex protocol names given by the MRI machine to your own names.
To transform DICOM files to NIfTI files in a BIDS fashion (or your own format ;) ), you use this JSON file to translate the protocol names  into your own names.
The JSON object uses the `ProtocolName` field of MRIcroGL's JSON output as a key. The value is another object containing `name`, `folder`, and `type`.
The key `name` is part of the file name. Subject and series number will be added by `create_nifti.m` to the file name for tracability 
and `type` will be appended to the end of the file name (before the format).

The key `folder` contains the name of the folder within the sub-XXX directory.
Within this directory, the `.json` and `.nii` (or `.nii.gz`) will be saved that `protocol2bids.json` outputs.
Typical BIDS folders include `beh`, `func`, `anat`, and `fmap`, but any folder name is possible.
If an empty string is provided, the file will be saved in the subject's main directory.

