
path <- "C:/Users/Roman/Documents/MATLAB/projects/udce-fmri/tasks"
setwd(path)

tasks  <- c("nct2.1", "nct2.2", "nct1", "phono", "syntax", "lexi", "morpho")
ptasks <- tasks[3:length(tasks)]
n      <- 50
perm   <- matrix(ncol=length(tasks),nrow=n)
perm[, 1] <- tasks[1]
perm[, 2] <- tasks[2]

x <- expand.grid(ptasks, ptasks, ptasks, ptasks, ptasks)
x <- x[5 == apply(X=x, MARGIN=1, FUN=function(x){length(unique(x))}), ]
x <- x[2 > apply(X=x, MARGIN=1, FUN=function(x){abs(which(x=="lexi")-which(x=="morpho"))}), ]
rownames(x) <- NULL
# Yess!

colnames(x) <- paste0("task_", 3:(ncol(x)+2))
rownames(x) <- sprintf("sub-%03d", 1:nrow(x))
write.csv(x, "permutation_table.csv")

