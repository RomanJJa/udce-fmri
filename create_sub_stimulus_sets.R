

path = "C:/Users/Roman/Documents/MATLAB/projects/udce-fmri/tasks-tuebingen"
bidsPath <- file.path(path, "data")
setwd(paste0(path,"/originalStimuli"))


subjectNum <- c(0:40)
tasks <- c("nct1","nct2","phono","lexi","morpho","syntax")
langs  <- c("de", "fr")
minISI <- 1000
maxISI <- 3000
# trialsPerBlock <- 32 # after every "trialsPerBlock" trials, there is a pause
# 64 null events



### Functions

# Repeat an array and mix throughout that parameter
repMixedArray <- function(n, arr, tolerance=1) {
	arr <- rep(arr, each=tolerance)
	res <- sample(arr, replace=FALSE)
	while (length(res) < n) {
		res <- c(res, sample(arr, replace=FALSE))
	}
	return(res[1:n])
}

insertRows <- function(data, rows, at=nrow(data)) {
	# row = nullEvent; at = indices
	
	if (is.null(rows) | nrow(rows)==0 | is.null(at) | all(at<2)) {
		return(data)
	} else if (nrow(rows) == 1) {
		#at <- sort(at)
		for (i in 1:length(at)) {
			if (at[i] < 2) {
				data <- rbind(rows, data)
			} else if (at[i] < nrow(data)) {
				data <- rbind(data[1:(at[i]-1), ], rows,
							  data[at[i]:nrow(data), ])
			} else {
				data <- rbind(data, rows)
			}
			# at[i:length(at)] <- at[i:length(at)] + 1
			at[at > at[i]] <- at[at > at[i]] + 1
		}
	} else if (nrow(rows) > 1 & nrow(rows) == length(at)) {		
		for (i in 1:length(at)) {
			if (at[i] < 2) {
				data <- rbind(rows[i, ], data)
			} else if (at[i] < nrow(data)) {
				data <- rbind(data[1:(at[i]-1), ], rows[i, ],
							  data[at[i]:nrow(data), ])
			} else {
				data <- rbind(data, rows[i, ])
			}
		}
		# !!!!!!!! After appending, row numbers have shifted up by 1
		at[at > at[i]] <- at[at > at[i]] + 1
	} else {
		stop("If nrow(rows) > 1, then nrow(rows) must equal length(at).")
	}
	return(data)
}

# This function has errors!!
equalRandomize <- function(data, by=c()) {
	# data = rawstim$phono$test; by = c("condition", "stim1_correct");
	data <- data[sample(1:nrow(data), replace=FALSE), ]
	condition <- character(nrow(data))
	for (i in 1:length(by)) {
		condition <- paste0(condition, "+", data[[by[i]]])
	}
	uniq <- unique(condition)
	urne <- data
	newdata <- NULL
	while (nrow(urne) > length(uniq)) {
		selectedRows <- c()
		for (i in 1:length(uniq)) {
			if (sum(condition == uniq[i]) > 0) {
				selectedRows <- c(selectedRows, which(condition == uniq[i])[1])
			} else {
				warning("Unequal sizes of categories");
			}
		}
		newdata <- rbind(newdata, urne[selectedRows, ])
		condition <- condition[-selectedRows]
		urne <- urne[-selectedRows, ]
	}
	# table(rle(data$stim1_correct)$lengths)
	
	newdata <- rbind(newdata, urne)
	return(newdata)
}

# pseudorandomize a data.frame by rows: 
# res <- pseudorandomize(newstim$nct2$test, by=c("within_dec","stim1_correct"), maxRepeat=3)
pseudorandomize <- function(data, by=c(), maxRepeat=3) {
	# pseudorandomize(newstim, by=c("within_dec", "stim1_correct"), maxRepeat=3)
	# pseudorandomize(newstim$nct2$test, by=c("within_dec", "stim1_correct"), maxRepeat=3)
	# data = rawstim$nct2$test; by=c("within_dec", "stim1_correct"); maxRepeat=3
	
	# check if all columns have the same value
	isRowRep <- function(data, columns) {
		areSame <- FALSE
		for (column in columns) {
			# rle(data$stim1_correct)$lengths
			if (length(unique(data[, column]))<2) {
				areSame <- TRUE; break
			}
		}
		return(areSame);
	}
	
	data <- data[sample(1:nrow(data)), ]
	data2 <- data;
	if (is.null(by)) return(data);
	
	# go through the rows and check if there are repetitions
	# If there are unwanted repetitions, we will store the 
	# "currently unwanted" stimulus in the cache.
	# We will try to inject them back into "data" later.
	
	cache <- data.frame()
	tries <- 0; maxTries <- 1000
	while ((nrow(cache) > 0 | tries == 0) & tries < maxTries) {
		tries = tries + 1
		cache <- data.frame()
		i = maxRepeat+1
		while (i <= nrow(data)) {
			# Seep through the rows to find if there are overly repetitive rows.
			# If so, collect them in the cache and delete them from data.
			between <- data[(i-maxRepeat):i, ]
			if (isRowRep(between, by)) {
				cache <- rbind(cache, data[i, ])
				data <- data[-i, ]
			} else {
				i = i + 1;
			}
		}
		# now sprinkle leftovers
		data <- insertRows(data, rows=cache, 
						   at=sample(1:nrow(data), nrow(cache), replace=FALSE))
		cat("Run", tries, ". nrow(cache): ", nrow(cache), ", nrow(data): ", nrow(data),".\n")
	}
	
	## Error testing and implementation:
	#if (nrow(cache) > nrow(data)) {
	#	stop("Data cannot be mixed: Too many rows of a single kind.\nMaybe try adjusting maxRepeat?")
	#}
	
	## Checks:
	dim(cache)
	dim(data)
	table(rle(data$stim1_correct)$lengths)
	#lengths <- rle(data$stim1_correct)$lengths
	#lengths1 <- lengths[1:(length(lengths)-1)]; lengths2 <- lengths[2:(length(lengths))]
	#summary(lm(lengths2 ~ lengths1))
	
	if (nrow(cache) > 0) {
		data <- rbind(data, cache);
		warning("Was not able to seemlessly sprinkle in all leftover items.")
	}
	
	return(data)
}


generateISIs <- function(data, category, min=0.5, max=3, isiName="isi") {
	# generateISIs(data=newstim, category=newstim$condition, min=0.5, max=3)
	# data=newstim; category=newstim$condition; min=0.5; max=3; isiName="isi"
	uniqs <- unique(category)
	data[[isiName]] <- NA
	for (uniq in uniqs) {
		affectedRows <- nrow(data[category == uniq, ])
		# affectedRows <- 10; min=0.5; max=3;
		percentiles <- seq(0, 1, length=affectedRows+2)
		percentiles <- percentiles[percentiles > 0 & percentiles < 1]
		
		# In the exponential distribution, there the mean is 1/rate
		# Thus, we set the rate to 1:
		isi <- qexp(percentiles, 1) #  * length(percentiles)
		isi <- min + isi * (max-min) / max(isi)
		#isi <- min + (isi * rate / mean(isi))
		
		# plot(isi, type="b"); median(isi); mean(isi)
		data[[isiName]][category == uniq] <- sample(isi, replace=FALSE)
	}
	return(data)
}


# Sprinkle null events into the stimulus set
insertNullEvents <- function(data, content="##", every=5, jitter=1, pauseEvery=32, minDistFromPause=3) {
	# data=rawstim$nct2$test;
	# data=block; content="##"; every=5; pauseEvery=55; minDistFromPause=3; jitter=1
	
	data$is_null <- 0
	
	# Create the null event row:
	nullEvent <- data[1, ]
	nullEvent[1, ] <- NA
	nullEvent$condition <- "null_event"
	nullEvent$stim1 <- content
	nullEvent$stim2 <- content
	nullEvent$stim1_correct <- NA
	nullEvent$is_null <- 1
	
	# Create jitter across all insertion points (to make null events less anticipatory)
	insertAt <- seq(0, nrow(data), by=every)
	#insertReal <- insertAt + 0:(length(insertAt)-1)
	insertAt <- insertAt[insertAt>0 & insertAt<nrow(data)-jitter-1] # & 
	#                     insertReal %% pauseEvery > minDistFromPause &
	#					 abs(pauseEvery - (insertReal %% pauseEvery)) > minDistFromPause]
	shifts   <- repMixedArray((-jitter):jitter, n=length(insertAt))
	indices  <- insertAt + shifts
	# table(diff(indices))
	
	#query <- indices %% pauseEvery <= minDistFromPause
	#indices[query] <- indices[query] + abs(minDistFromPause - (indices[query] %% pauseEvery))
	
	#query <- abs((indices %% pauseEvery) - pauseEvery) < minDistFromPause
	#indices[query] <- indices[query] - abs(minDistFromPause + ((indices[query] %% pauseEvery) - pauseEvery))
	# min(indices %% 32)
	# max(indices %% 32)
	# table(indices[2:length(indices)] - indices[1:(length(indices)-1)])
	
	# Insert null events into randomized stimulus set:
	data <- insertRows(data, nullEvent, indices);
	return(data)
}

# To avoid column-wise comparisons, shift the position of numbers (or words?)
shiftStimuli <- function(data, shift=" ") {
	factors <- c("no-tilt", "stim1-tilt-right", "stim1-tilt-left",
	             "stim2-tilt-right", "stim2-tilt-left")
	data$stim_shift <- repMixedArray(factors, n=nrow(data))
	for (i in 1:nrow(data)) {
		if (data$stim_shift[i] == "stim1-tilt-right") {
			data$stim1[i] <- paste0(shift, data$stim1[i])
		} else if (data$stim_shift[i] == "stim1-tilt-left") {
			data$stim1[i] <- paste0(data$stim1[i], shift)
		} else if (data$stim_shift[i] == "stim2-tilt-right") {
			data$stim2[i] <- paste0(shift, data$stim2[i])
		} else if (data$stim_shift[i] == "stim2-tilt-left") {
			data$stim2[i] <- paste0(data$stim2[i], shift)
		}
	}
	return(data)
}


### Load stimulus sets and 
library(readr)
options("encoding" = "UTF-8")
stimlist <- rawstim <- list()

for (lang in langs) {
	for (task in tasks) {
		rawstim[[task]][["test"]] <- as.data.frame(read_csv(sprintf("%s_test_%s.csv", task, lang),
											                locale = locale(encoding = "UTF-8")))
		rawstim[[task]][["practice"]] <- as.data.frame(read_csv(sprintf("%s_practice_%s.csv", task, lang),
												                locale = locale(encoding = "UTF-8")))
		
		## Add missing necessary columns to stimulus sets	
		## Required columns
		# stim1
		# stim2
		# stim1_correct
		# condition
		# is_null: is null event
		# expected_button?
		# isi --> we do that later for each participant
		if (task == "nct2") {
			
			rawstim$nct2$practice$stim1         <- as.character(rawstim$nct2$practice$num1)
			rawstim$nct2$practice$stim2         <- as.character(rawstim$nct2$practice$num2)
			rawstim$nct2$practice$stim1_correct <- rawstim$nct2$practice$num1_greater
			rawstim$nct2$practice$is_null       <- 0
			rawstim$nct2$practice$isi           <- 500
			
			rawstim$nct2$test$stim1         <- as.character(rawstim$nct2$test$num1)
			rawstim$nct2$test$stim2         <- as.character(rawstim$nct2$test$num2)
			rawstim$nct2$test$stim1_correct <- rawstim$nct2$test$num1_greater
			rawstim$nct2$test$is_null       <- 0
			rawstim$nct2$test$isi           <- 500
			
		} else if (task == "nct1") {
			
			rawstim$nct1$practice$stim1         <- as.character(rawstim$nct1$practice$number1)
			rawstim$nct1$practice$stim2         <- as.character(rawstim$nct1$practice$number2)
			#rawstim$nct1$practice$condition    <- paste0("dist_",rawstim$nct1$practice$distance)
			rawstim$nct1$practice$condition     <- paste0("dist-", ((rawstim$nct1$practice$distance+1) %/% 2)*2-1, 
														  "-", ((rawstim$nct1$practice$distance+1) %/% 2)*2)
			rawstim$nct1$practice$stim1_correct <- rawstim$nct1$practice$num1_greater
			rawstim$nct1$practice$is_null       <- 0
			rawstim$nct1$practice$isi               <- 500
			
			rawstim$nct1$test$stim1         <- as.character(rawstim$nct1$test$number1)
			rawstim$nct1$test$stim2         <- as.character(rawstim$nct1$test$number2)
			rawstim$nct1$test$condition     <- paste0("dist-", ((rawstim$nct1$test$distance+1) %/% 2)*2-1, 
													  "-", ((rawstim$nct1$test$distance+1) %/% 2)*2)
			rawstim$nct1$test$stim1_correct <- rawstim$nct1$test$num1_greater
			rawstim$nct1$test$is_null       <- 0
			rawstim$nct1$test$isi           <- 500
			
		} else if (task == "phono") {
			
			rawstim$phono$practice$stim1         <- as.character(rawstim$phono$practice$word_1)
			rawstim$phono$practice$stim2         <- as.character(rawstim$phono$practice$word_2)
			rawstim$phono$practice$condition     <- gsub("_","-",rawstim$phono$practice$orthography_phonology)
			rawstim$phono$practice$stim1_correct <- rawstim$phono$practice$does_rhyme
			rawstim$phono$practice$is_null       <- 0
			rawstim$phono$practice$isi           <- 500

			rawstim$phono$test$stim1         <- as.character(rawstim$phono$test$word_1)
			rawstim$phono$test$stim2         <- as.character(rawstim$phono$test$word_2)
			rawstim$phono$test$condition     <- gsub("_","-",rawstim$phono$test$orthography_phonology)
			rawstim$phono$test$stim1_correct <- rawstim$phono$test$does_rhyme
			rawstim$phono$test$is_null       <- 0
			rawstim$phono$test$isi           <- 500

		} else if (task == "lexi") {
			
			rawstim$lexi$practice$stim1         <- as.character(rawstim$lexi$practice$word_pt_1)
			rawstim$lexi$practice$stim2         <- as.character(rawstim$lexi$practice$word_pt_2)
			rawstim$lexi$practice$condition     <- "word-true"
			rawstim$lexi$practice$condition[rawstim$lexi$practice$Error_position_syllable==1] <- "prefix-false"
			rawstim$lexi$practice$condition[rawstim$lexi$practice$Error_position_syllable==2] <- "suffix-false"
			rawstim$lexi$practice$stim1_correct <- rawstim$lexi$practice$correct
			rawstim$lexi$practice$is_null       <- 0
			rawstim$lexi$practice$isi           <- 500
			
			rawstim$lexi$test$stim1         <- as.character(rawstim$lexi$test$word_pt_1)
			rawstim$lexi$test$stim2         <- as.character(rawstim$lexi$test$word_pt_2)
			#rawstim$lexi$test$condition     <- rawstim$lexi$test$Error_position_syllable
			rawstim$lexi$test$condition     <- "real-word"
			rawstim$lexi$test$condition[rawstim$lexi$test$Error_position_syllable==1] <- "prefix-false"
			rawstim$lexi$test$condition[rawstim$lexi$test$Error_position_syllable==2] <- "suffix-false"
			
			rawstim$lexi$test$stim1_correct <- rawstim$lexi$test$correct
			rawstim$lexi$test$is_null       <- 0
			rawstim$lexi$test$isi           <- 500
			
		} else if (task == "morpho") {
			
			rawstim$morpho$practice$stim1         <- as.character(rawstim$morpho$practice$word_pt_1)
			rawstim$morpho$practice$stim2         <- as.character(rawstim$morpho$practice$word_pt_2)
			rawstim$morpho$practice$condition     <- ifelse(rawstim$morpho$practice$prefix==1, "prefix", "suffix")
			rawstim$morpho$practice$stim1_correct <- rawstim$morpho$practice$correct
			rawstim$morpho$practice$is_null       <- 0
			rawstim$morpho$practice$isi           <- 500
			
			rawstim$morpho$test$stim1         <- as.character(rawstim$morpho$test$word_pt_1)
			rawstim$morpho$test$stim2         <- as.character(rawstim$morpho$test$word_pt_2)
			rawstim$morpho$test$condition     <- ifelse(rawstim$morpho$test$prefix==1, "prefix", "suffix")
			rawstim$morpho$test$stim1_correct <- rawstim$morpho$test$correct
			rawstim$morpho$test$is_null       <- 0
			rawstim$morpho$test$isi           <- 500
			
		} else if (task == "syntax") {
			
			rawstim$syntax$practice$stim1         <- as.character(rawstim$syntax$practice$word_1)
			rawstim$syntax$practice$stim2         <- as.character(rawstim$syntax$practice$word_2)
			rawstim$syntax$practice$condition     <- paste0(ifelse(rawstim$syntax$practice$inflection_type_word_2==1,"verb","noun"), "-", 
															ifelse(rawstim$syntax$practice$correct==1,"true","false"))
			rawstim$syntax$practice$stim1_correct <- rawstim$syntax$practice$correct
			rawstim$syntax$practice$is_null       <- 0
			rawstim$syntax$practice$isi           <- 500
			
			rawstim$syntax$test$stim1         <- as.character(rawstim$syntax$test$word_1)
			rawstim$syntax$test$stim2         <- as.character(rawstim$syntax$test$word_2)
			#rawstim$syntax$test$condition    <- rawstim$syntax$test$word_1
			rawstim$syntax$test$condition     <- paste0(ifelse(rawstim$syntax$test$inflection_type_word_2==1,"verb","noun"), "-", 
														ifelse(rawstim$syntax$test$correct==1,"true","false"))
			rawstim$syntax$test$stim1_correct <- rawstim$syntax$test$correct
			rawstim$syntax$test$is_null       <- 0
			rawstim$syntax$test$isi           <- 500
			
		} else {
			cat("Task ", task, "is not found in the \"tasks\" array.\n")
		}
	}
	stimlist[[lang]] <- rawstim
}
# rawstim$phono$practice
names(stimlist)
names(stimlist$de)
names(stimlist$fr)


### Generate individual BIDS directories and stimulus sets
# createStimFiles <- function(bidsPath, subjectNum)
createStimFiles <- function(bids, subjects, stimulusSets, minisi=500, maxisi=3000) {
	# bids = bidsPath; subjects = subjectNum; stimulusSets = stimlist; minisi=500; maxisi=3000
	if (class(subjects) != "numeric" & class(subjects) != "integer") {
		stop("Argument \"subjects\" must be numeric or integer.")
	}
		
	# Check if any data have already been recorded for that participant:
	for (subj in subjects) {
		subject <- sprintf("sub-%03d", subj)
		if (subject != "sub-000" & 
		    (length(dir(file.path(bids, subject, "beh"))) > 0 |
		     length(dir(file.path(bids, subject, "func"))) > 0 |
			 length(dir(file.path(bids, subject, "anat"))))) {
			stop("Subject ",subject, paste0(" already appears to haved data.",
				 "Cancelling data preparation because it cannot be assumed",
				 "that this is a new subject. Check out:", 
				 file.path(bids, subject), collapse="\n"))
		}
	}
	# bids = bidsPath; 
	# bids: path to bids data
	
	# See if bids path exists:
	suppressWarnings(dir.create(bids))
	
	for (subj in subjects) {
		# subj = subjects[1]
		subject <- sprintf("sub-%03d", subj)
		cat("subject", subject, "\n")
		subjectPath  <- file.path(bids, subject)
		stimPath     <- file.path(subjectPath, "stimuli")
		#stimFileName <- paste0(subject, "_task-%s-%s%s_stimuli.csv")
		# sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>][_recording-<label>]_stim.tsv.gz
		
		# Create paths:
		suppressWarnings(dir.create(subjectPath))
		suppressWarnings(dir.create(stimPath)) # path to stimuli (anything before the experiment)
		suppressWarnings(dir.create(file.path(subjectPath, "beh")))  # path to behavioral data
		suppressWarnings(dir.create(file.path(subjectPath, "anat"))) # path to anatomical records
		suppressWarnings(dir.create(file.path(subjectPath, "dicom"))) # path to dicom files
		suppressWarnings(dir.create(file.path(subjectPath, "fmap"))) # path to field maps
		suppressWarnings(dir.create(file.path(subjectPath, "func"))) # path to functional records
		
		for (lang in c("de","fr")) {
			for (phase in c("practice", "test")) {
				for (task in names(stimulusSets[[lang]])) {
					# phase = "test"; task = "nct2"
					cat(sprintf("task: %s-%s in language %s for subject %s:\n", task, phase, lang, subject))
					newstim <- stimulusSets[[lang]][[task]][[phase]]
					# newstim <- stimulusSets[["nct2"]][["practice"]]
					if (phase == "test" & task == "nct2") {
						firstRun <- TRUE
						newstim2 <- newstim
						
						# pseudo-randomize stimulus set:
						while (firstRun | max(as.numeric(names(table(rle(newstim2$stim1_correct)$lengths)))) > 3 ) {
							newstim2 <- newstim
							firstRun <- FALSE
							newstim2 <- pseudorandomize(newstim2[sample(1:nrow(newstim2), replace=FALSE), ], 
														by=c("condition","stim1_correct"), maxRepeat=3)
						}
						newstim <- newstim2
						
						# bounds to cut the :
						bounds <- c(0, floor(nrow(newstim)/2), nrow(newstim))
						
						for (set in 1:2) {
							# Extract block of tasks:
							block <- newstim[(bounds[set]+1):bounds[set+1], ]
							
							# Insert null events:
							block <- insertNullEvents(data=block, content="##", every=5, jitter=1, pauseEvery=55)
							# generate different ISIs:
							block <- generateISIs(block, block$condition, min=minisi, max=maxisi)
							# shift numbers to the left or right
							block <- shiftStimuli(data=block, shift="  ")
							
							# paste0(subject, "_task-%s-%s%s_stimuli.csv")
							#sprintf(stimFileName, sprintf("%s_", task, set), phase))
							file <- file.path(stimPath, sprintf("%s_task-%s_run-%d_lang-%s_stimuli.csv", subject, task, set, lang))
							
							readr::write_excel_csv(block, file)
						}
					} else if (phase == "practice" & task == "nct2") {
						# Insert null events:
						newstim <- insertNullEvents(data=newstim, content="##", every=3)
						# shift numbers to the left or right
						newstim <- shiftStimuli(data=newstim, shift="  ")
					} else if (phase == "test") {
						newstim <- pseudorandomize(newstim, by=c("condition", "stim1_correct"), maxRepeat=3)
					} else { # if a practice set:
						newstim <- newstim[sample(1:nrow(newstim), replace=FALSE), ]
					}
					
					if (phase == "test") {
						cat(sprintf("task: %s-%s, occurences of same response sides:\n", task, phase))
						print(table(rle(newstim$stim1_correct)$lengths))
					}
					
					# Now write the files:
					if (!(phase == "test" & task == "nct2") & phase == "test") { # any localizer task
						file <- file.path(stimPath, sprintf("%s_task-%s_lang-%s_stimuli.csv", subject, task, lang))
						readr::write_excel_csv(newstim, file)
					} else if (!(phase == "test" & task == "nct2") & phase == "practice") {
						file <- file.path(stimPath, sprintf("%s_task-%s-practice_lang-%s_stimuli.csv", subject, task, lang))
						readr::write_excel_csv(newstim, file)
					}
					# write.csv(newstim, file, row.names=FALSE, quote=TRUE)
					cat("wrote file:", file, "\n")
					cat("\n\n\n")
				}
			}
		}
	}
}


#createStimFiles(bids=bidsPath, subjects=subjectNum, stimulusSets=stimlist, minisi=minISI, maxisi=maxISI)
createStimFiles(bids=bidsPath, subjects=subjectNum, stimulusSets=stimlist, minisi=minISI, maxisi=maxISI)
