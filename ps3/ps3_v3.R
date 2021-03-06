################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Course : Statistical Modelling and Inference
# Title  : Problem Set #3
# Author : (c) Miquel Torrens
# Date   : 2015.10.23
################################################################################
# source('/Users/miquel/Desktop/bgse/courses/term1/smi/ps/ps3/ps3_v3.R')
################################################################################

# Libraries
library(mnormt)
library(mvtnorm)

# Load previous problem set
source('/Users/miquel/Desktop/bgse/courses/term1/smi/ps/ps2/ps2_v6.R')
#stop('End point.')

# Load functions
source('/Users/miquel/Desktop/bgse/courses/term1/smi/ps/ps3/functions_ps3.R')

# Observed values
t <- cd[, 't']
x <- cd[, 'x']

# Define Phi matrix
phi <- matrix(nrow = length(x), ncol = M + 1)
invisible(sapply(1:length(x), function(i) {
  phi[i, ] <<- phix(x = x[i], M = 9, basis = 'Gauss')
}))

#res <- plot.model(delta = 9, 'ps3_plot1.png')
#res <- plot.model(delta = 2, 'ps3F_plot1.png')
res <- plot.model(delta = 1, 'ps3F_plot1.png')

par1. <- as.vector(res[['par1']])
par2. <- as.vector(sqrt(res[['par2']]))
par3. <- res[['par3']]
w.bayes <- res[['w.bayes']]
D. <- res[['D.']]
a. <- res[['a.']]
b. <- res[['b.']]

# Replicate Phi
M <- 9
new.x <- seq(min(cd[, 'x']), max(cd[, 'x']), 1 / 10000)
phi4 <- matrix(nrow = length(new.x), ncol = M + 1)
sapply(1:length(new.x), function(i) {
  phi4[i, ] <<- phix(x = new.x[i], M = 9, basis = 'Gauss')
})

# Simulate
nsim <- 1000
set.seed(666)
sim <- MASS::mvrnorm(nsim, mu = w.bayes, Sigma = solve(D.))
#sim <- mvtnorm::rmvt(n = nsim, delta = as.vector(w.bayes), sigma = solve(a. / (a. - 2) * solve(D.)), df = 2 * a.)
sim <- mvtnorm::rmvt(n = nsim, delta = as.vector(w.bayes), solve(as.numeric(a. / b.) * D.), df = 2 * a.)

# Plot
png('/Users/miquel/Desktop/bgse/courses/term1/smi/ps/ps3/ps3F_plot2.png')
main <- 'Posterior draws of the L.P. (n = 1000, delta = 1, approx. g = 104)'
plot(cd[, 'x'], cd[, 't'], pch = 16, col = 'blue',
     ylim = c(min(cd[, 't']) - 0.5, max(cd[, 't']) + 0.5),
     main = main,
     ylab = 't', xlab = 'x')
for (i in 1:nrow(sim)) {
  new.res <- phi4 %*% sim[i, ]
  lines(new.x, new.res, col = 'gray')
}
points(cd[, 'x'], cd[, 't'], pch = 16, col = 'blue')
dev.off()

# Repeat with a smaller simulation
nsim <- 100
set.seed(666)
sim <- MASS::mvrnorm(nsim, mu = w.bayes, Sigma = solve(D.))
#sim <- mvtnorm::rmvt(n = nsim, delta = as.vector(w.bayes), solve(a. / (a. - 2) * solve(D.)), df = 2 * a.)
sim <- mvtnorm::rmvt(n = nsim, delta = as.vector(w.bayes), solve(as.numeric(a. / b.) * D.), df = 2 * a.)

# Plot
png('/Users/miquel/Desktop/bgse/courses/term1/smi/ps/ps3/ps3F_plot2_0.png')
main <- 'Posterior draws of the L.P. (n = 100, delta = 1, approx. g = 104)'
plot(cd[, 'x'], cd[, 't'], pch = 16, col = 'blue',
     ylim = c(min(cd[, 't']) - 0.5, max(cd[, 't']) + 0.5),
     main = main,
     ylab = 't', xlab = 'x')
for (i in 1:nrow(sim)) {
  new.res <- phi4 %*% sim[i, ]
  lines(new.x, new.res, col = 'gray')
}
points(cd[, 'x'], cd[, 't'], pch = 16, col = 'blue')
dev.off()

# Plot many values of delta
plot.model(delta = 0.0001, 'ps3F_plot3_1.png')
plot.model(delta = 0.001, 'ps3F_plot3_2.png')
plot.model(delta = 0.01, 'ps3F_plot3_3.png')
plot.model(delta = 0.1, 'ps3F_plot3_4.png')
plot.model(delta = 0.5, 'ps3F_plot3.png')
plot.model(delta = 1, 'ps3F_plot4.png')
plot.model(delta = 2, 'ps3F_plot5.png')
plot.model(delta = 3, 'ps3F_plot6.png')
plot.model(delta = 5, 'ps3F_plot7.png')
plot.model(delta = 10, 'ps3F_plot8.png')
plot.model(delta = 20, 'ps3F_plot9.png')
plot.model(delta = 50, 'ps3F_plot10.png')
plot.model(delta = 100, 'ps3F_plot11.png')
plot.model(delta = 1000, 'ps3F_plot12.png')
plot.model(delta = 1000000, 'ps3F_plot13.png')

# END OF SCRIPT
