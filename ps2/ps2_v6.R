################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Course : Statistical Modelling and Inference
# Title  : Problem Set #2
# Author : (c) Miquel Torrens
# Date   : 2015.10.12
################################################################################
# source('/Users/miquel/Desktop/bgse/courses/term1/smi/ps/ps2/ps2_v6.R')
################################################################################

scatterhist <- function(x, y, x1, y1, xlab="", ylab="", ...){
  zones=matrix(c(2,0,1,3), ncol=2, byrow=TRUE)
  layout(zones, widths=c(4/5,1/5), heights=c(1/5,4/5))
  xhist = hist(x, plot=FALSE)
  yhist = hist(y, plot=FALSE)
  top = max(c(xhist$counts, yhist$counts))
  par(mar=c(3,3,1,1))
  plot(x,y, col = 'gray', pch = 16, ...)
  points(x1, y1, col = 'red', pch = 16, cex = 2)
  par(mar=c(0,3,1,1))
  barplot(xhist$counts, axes=FALSE, ylim=c(0, top), space=0, col = 'dodgerblue')
  par(mar=c(3,0,1,1))
  barplot(yhist$counts, axes=FALSE, xlim=c(0, top), space=0, horiz=TRUE, col = 'dodgerblue')
  par(oma=c(3,3,0,0))
  mtext(xlab, side=1, line=1, outer=TRUE, adj=0, 
    at=.8 * (mean(x) - min(x))/(max(x)-min(x)))
  mtext(ylab, side=2, line=1, outer=TRUE, adj=0, 
    at=(.8 * (mean(y) - min(y))/(max(y) - min(y))))
}

# Paths
PATH <- '/Users/miquel/Desktop/bgse/courses/term1/smi/'
OUTPUTDIR <- paste(PATH, 'ps/ps2/', sep = '')
DATADIR <- paste(PATH, 'datasets/', sep = '')

# Packages
needed.packages <- c()
if (length(needed.packages) > 0) {
  for (pkg in needed.packages) {
    if (! pkg %in% installed.packages()[, 1]) {
      aux <- try(install.packages(pkg))
      if (class(aux) != 'try-error') {
        cat('Installed package:', pkg, '\n')
      } else {
        stop('unable to install package ', pkg)
      }
    } else {
      aux <- try(library(pkg, character.only = TRUE))
      if (class(aux) != 'try-error') {
        cat('Library:', pkg, '\n')
      } else {
        stop('unable to load package ', pkg)
      }
    }
  }
}; rm(needed.packages)

# Load data
file <- paste(DATADIR, 'curve_data.txt', sep = '')
cd <- read.table(file = file); cat('Loaded file:', file, '\n')

################################################################################
# Exercise 2
png(paste(OUTPUTDIR, 'ps2_plot1.png', sep = ''), height = 600, width = 600)
plot(cd[, 1], cd[, 2],
		 main = 'Layout of the training data',
		 ylab = 'Response variable',
		 xlab = 'Input variable',
		 ylim = c(0.9 * min(cd[, 2]), 1.1 * max(cd[, 2])), 
		 xlim = c(-0.1, 1.1), 
		 pch = 16)#, cex = 0.8)
abline(v = 0, lty = 'dashed')
abline(v = 1, lty = 'dashed')
dev.off()

################################################################################
# Function "phix"
phix <- function(x, M, basis) {
################################################################################
  # Check correctness of input x
  if (x < 0 || x > 1) {
    stop('out-of-range values in the input vector "x".')
  }
  
  # Perform the calculations  
  if (basis == 'poly') {
    out <- rep(NA, length = M + 1)
    sapply(c(0, 1:M), function(i) {
      out[i + 1] <<- x^i
    })
  } else if (basis == 'Gauss') {
    #mus <- seq(0, 1, M ** (-1))
    mus <- seq(0, 1, length.out = M)
    out <- rep(NA, length = M)
    sapply(1:M, function(i) {
      #out <<- c(out, exp((-(x - mus[i]) ** 2) / 0.1))
      out[i] <<- exp((-(x - mus[i]) ** 2) / 0.1)
    })
    out <- c(1, out)
  } else {
    stop('specify a valid option for the parameter "basis".')
  }
  
  # Return the values
  return(out)
}

################################################################################
# Function "post.params"
post.params <- function(tdata, M, basis, phix, delta, q) {
################################################################################
  # Input data
  t <- tdata[, 't']  # Response variable
  x <- tdata[, 'x']  # Input variable
  
  # Initialize Phi matrix
  phi <- matrix(nrow = length(x), ncol = M + 1)
  sapply(1:length(x), function(i) {
    phi[i, ] <<- phix(x = x[i], M = M, basis = basis)
  })

  # Function parameter
  lambda <- delta / q
  
  Q <- delta * diag(ncol(phi)) + q * t(phi) %*% phi
  w.bayes <- q * solve(Q) %*% t(phi) %*% t
    
  # Results
  return(list(w.bayes = w.bayes, Q = Q))
}

# Execute the function with the specified parameters
params <- post.params(cd, M = 9, basis = 'poly', phix,
                      delta = 2L, q = 0.1 ** (-2))
                      
# Calculating the Phi matrix
phi <- matrix(nrow = length(cd[, 'x']), ncol = 10)
sapply(1:length(cd[, 'x']), function(i) {
  phi[i, ] <<- phix(x = cd[, 'x'][i], M = 9, basis = 'poly')
})

# Form of the function
fits <- phi %*% params[['w.bayes']]

# Plot the original data
png(paste(OUTPUTDIR, 'ps2_plot2.png', sep = ''), height = 600, width = 600)
plot(cd[, 't'], col = 'red',
     ylim = c(-1.1, 1.1),
     main = 'Bayesian curve fitting',
     xlab = 'Input variable',
     ylab = 'Response variable',
     xaxt = 'n')

# Plot the approximating function
lines(loess.smooth(1:10, as.vector(t(fits)),
                   family = 'gaussian', degree = 3), col = 'blue')

# Print x-axis
axis(side = 1, at = 1:10, labels = seq(0.1, 1, 0.1))
dev.off()

################################################################################
# Exercise 3

################################################################################
bayesian.precision <- function(x) {
################################################################################
  # Parameters
  M <- 9
  delta <- 1L
  q <- 0.1 ** (-2)
  
  # Initialize Phi matrix
  phi <- matrix(nrow = length(x), ncol = M + 1)
  sapply(1:length(x), function(i) {
    phi[i, ] <<- phix(x = x[i], M = 9, basis = 'Gauss')
  })
  
  # Execute the function with the specified parameters
  params <- post.params(cd, M = 9, basis = 'Gauss', phix,
                        delta = 1L, q = 0.1 ** (-2))
  
  # Resulting parameters
  Q <- params[[2]]
  w.bayes <- params[[1]]
  
  # Predicted values
  means <- phi %*% w.bayes
  vars <- phi %*% solve(Q) %*% t(phi) + q ** (-1)
  
  # Return
  return(list(means = means, vars = diag(vars)))
}

################################################################################
# Plot 3
new.x <- seq(0, 1, 1/10000)
res <- bayesian.precision(new.x)
png(paste(OUTPUTDIR, 'ps2_plot3.png', sep = ''), height = 600, width = 600)
plot(new.x, res[['means']], pch = '.', col = 'blue',
#plot(smooth.spline(new.x, res[['means']]), pch = '.', col = 'blue',
     ylim = c(min(res[['means']]) - 0.2, max(res[['means']]) + 0.2),
     main = 'Predicted mean with standard predictive posterior deviation',
     ylab = 't', xlab = 'x')
#points(new.x, res[['means']] + sqrt(res[['vars']]), pch = '.', col = 'red')
lines(smooth.spline(new.x, res[['means']] + sqrt(res[['vars']])), pch = '.', col = 'red')
#points(new.x, res[['means']] - sqrt(res[['vars']]), pch = '.', col = 'red')
lines(smooth.spline(new.x, res[['means']] - sqrt(res[['vars']])), pch = '.', col = 'red')
points(cd[, 'x'], cd[, 't'], pch = 16)
dev.off()

################################################################################
# Plot 4
params <- post.params(cd, M = 9, basis = 'Gauss', phix,
                      delta = 1L, q = 0.1 ** (-2))

# Simulate
set.seed(666)
sim <- MASS::mvrnorm(100, mu = params[[1]], Sigma = solve(params[[2]]))

# Replicate Phi
M <- 9
new.x <- seq(min(cd[, 'x']), max(cd[, 'x']), 1 / 1000)
phi2 <- matrix(nrow = length(new.x), ncol = M + 1)
sapply(1:length(new.x), function(i) {
  phi2[i, ] <<- phix(x = new.x[i], M = 9, basis = 'Gauss')
})

# Plot
png(paste(OUTPUTDIR, 'ps2_plot4.png', sep = ''), height = 600, width = 600)
#par(mfrow = c(1, 2))
plot(cd[, 'x'], cd[, 't'], pch = 16, col = 'blue',
     ylim = c(min(cd[, 't']) - 0.2, max(cd[, 't']) + 0.4),
     main = 'Simulation of Bayesian functions given inputs',
     ylab = 't', xlab = 'x')
maxs <- c()
mins <- c()
for (i in 1:nrow(sim)) {
  new.res <- phi2 %*% sim[i, ]
  maxs <- c(maxs, max(new.res))
  mins <- c(mins, min(new.res))
  lines(new.x, new.res, col = 'gray')
}
points(cd[, 'x'], cd[, 't'], pch = 16, col = 'blue')
dev.off()

# Part 2: right side of the plot
png(paste(OUTPUTDIR, 'ps2_plot5.png', sep = ''), height = 600, width = 600)
maxmin <- cbind(mins, maxs)
#plot(maxmin[, 1], maxmin[, 2], col = 'gray', pch = 16,
#     main = 'Maxima and minima of the response variables for the simulations',
#     ylab = 'Maximum value', xlab = 'Minimum value')
#points(min(cd[, 't']), max(cd[, 't']), col = 'red', pch = 16)
scatterhist(x = maxmin[, 1],
            y = maxmin[, 2],
            xlab = 'Minimum value',
            ylab = 'Maximum value',
            x1 = min(cd[, 't']),
            y1 = max(cd[, 't']))#,
#main = 'Maxima and minima of the response variables for the simulations',
#ylab = 'Maximum value', xlab = 'Minimum value')
dev.off()










