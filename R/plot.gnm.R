#  Modification of plot.lm from the stats package for R.
#
#  Copyright (C) 1995-2005 The R Core Team
#  Copyright (C) 2005, 2006, 2008 Heather Turner
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 or 3 of the License
#  (at your option).
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/

plot.gnm <- function (x, which = c(1:3, 5),
                      caption = c("Residuals vs Fitted", "Normal Q-Q",
                      "Scale-Location", "Cook's distance",
                      "Residuals vs Leverage"),
                      panel = if (add.smooth) panel.smooth else points,
                      sub.caption = NULL, main = "", ask = prod(par("mfcol")) <
                      length(which) && dev.interactive(), ...,
                      id.n = 3, labels.id = names(residuals(x)), cex.id = 0.75,
                      qqline = TRUE, cook.levels = c(0.5, 1.0),
                      add.smooth = getOption("add.smooth"),
                      label.pos = c(4, 2), cex.caption = 1)
{
    if (!is.numeric(which) || any(which < 1) || any(which > 5))
        stop("'which' must be in 1:5")
    show <- rep(FALSE, 5)
    show[which] <- TRUE
    r <- residuals(x)
    yh <- predict(x) # != fitted() for glm
    w <- weights(x)
    if (!is.null(w)) { # drop obs with zero wt: PR#6640
        wind <- w != 0
        r <- r[wind]
        yh <- yh[wind]
        w <- w[wind]
        labels.id <- labels.id[wind]
    }
    n <- length(r)
    if (any(show[2:5])) {
        s <- sqrt(deviance(x)/df.residual(x))
        hii <- c(hatvalues(x))
        if (any(show[4:5])) {
            cook <- c(cooks.distance(x))
        }
    }
    if (any(show[2:3])) {
        ylab23 <- "Std. deviance resid."
        r.w <- if (is.null(w)) r else sqrt(w) * r
    }
    if (show[5]) {
        ylab5 <- "Std. Pearson resid."
        r.w <- residuals(x, "pearson")
        if(!is.null(w)) r.w <- r.w[wind] # drop 0-weight cases
        r.hat <- range(hii, na.rm = TRUE) # though should never have NA
        isConst.hat <- all(r.hat == 0) || diff(r.hat) < 1e-10 * mean(hii)
    }

    dropInf <- function(x) {
	if(any(isInf <- is.infinite(x))) {
	    warning("Not plotting observations with leverage one:\n  ",
		    paste(which(isInf), collapse=", "))
	    x[isInf] <- NaN
	}
	x
    }
    if (any(show[c(2:3,5)]))
	rs <- dropInf( r.w/(s * sqrt(1 - hii)) )

    if (any(show[c(1, 3)]))
        l.fit <- "Predicted values"
    if (is.null(id.n))
        id.n <- 0
    else {
        id.n <- as.integer(id.n)
        if (id.n < 0 || id.n > n)
            stop(gettextf("'id.n' must be in {1,..,%d}", n), domain = NA)
    }
    if (id.n > 0) { ## label the largest residuals
        if (is.null(labels.id))
            labels.id <- paste(1:n)
        iid <- 1:id.n
        show.r <- sort.list(abs(r), decreasing = TRUE)[iid]
        if (any(show[2:3]))
            show.rs <- sort.list(abs(rs), decreasing = TRUE)[iid]
        text.id <- function(x, y, ind, adj.x = TRUE) {
            labpos <-
                if (adj.x) label.pos[1 + as.numeric(x > mean(range(x)))] else 3
            text(x, y, labels.id[ind], cex = cex.id, xpd = TRUE,
                pos = labpos, offset = 0.25)
        }
    }
    getCaption <- function(k) # allow caption = "" , plotmath etc
        as.graphicsAnnot(unlist(caption[k]))
    if (is.null(sub.caption)) { ## construct a default:
        cal <- x$call
        if (!is.na(m.f <- match("formula", names(cal)))) {
            cal <- cal[c(1, m.f)]
            names(cal)[2] <- "" # drop	" formula = "
        }
        cc <- deparse(cal, 80) # (80, 75) are ``parameters''
        nc <- nchar(cc[1], "c")
        abbr <- length(cc) > 1 || nc > 75
        sub.caption <-
            if (abbr) paste(substr(cc[1], 1, min(75, nc)), "...") else cc[1]
    }
    one.fig <- prod(par("mfcol")) == 1
    if (ask) {
        oask <- devAskNewPage(TRUE)
        on.exit(devAskNewPage(oask))
    }
    ##---------- Do the individual plots : ----------
    if (show[1]) {
        ylim <- range(r, na.rm = TRUE)
        if (id.n > 0)
            ylim <- extendrange(r = ylim, f = 0.08)
        plot(yh, r, xlab = l.fit, ylab = "Residuals", main = main,
            ylim = ylim, type = "n", ...)
        panel(yh, r, ...)
        if (one.fig)
            title(sub = sub.caption, ...)
        mtext(getCaption(1), 3, 0.25, cex = cex.caption)
        if (id.n > 0) {
            y.id <- r[show.r]
            y.id[y.id < 0] <- y.id[y.id < 0] - strheight(" ")/3
            text.id(yh[show.r], y.id, show.r)
        }
        abline(h = 0, lty = 3, col = "gray")
    }
    if (show[2]) { ## Normal
        ylim <- range(rs, na.rm = TRUE)
        ylim[2] <- ylim[2] + diff(ylim) * 0.075
        qq <- qqnorm(rs, main = main, ylab = ylab23, ylim = ylim, ...)
        if (qqline) qqline(rs, lty = 3, col = "gray50")
        if (one.fig)
            title(sub = sub.caption, ...)
        mtext(getCaption(2), 3, 0.25, cex = cex.caption)
        if (id.n > 0)
            text.id(qq$x[show.rs], qq$y[show.rs], show.rs)
    }
    if (show[3]) {
        sqrtabsr <- sqrt(abs(rs))
        ylim <- c(0, max(sqrtabsr, na.rm = TRUE))
        yl <- as.expression(substitute(sqrt(abs(YL)), 
                                       list(YL = as.name(ylab23))))
        yhn0 <- if (is.null(w)) yh else yh[w != 0]
        plot(yhn0, sqrtabsr, xlab = l.fit, ylab = yl, main = main,
            ylim = ylim, type = "n", ...)
        panel(yhn0, sqrtabsr, ...)
        if (one.fig)
            title(sub = sub.caption, ...)
        mtext(getCaption(3), 3, 0.25, cex = cex.caption)
        if (id.n > 0)
            text.id(yhn0[show.rs], sqrtabsr[show.rs], show.rs)
    }
    if (show[4]) {
        if (id.n > 0) {
            show.r <- order(-cook)[iid]# index of largest 'id.n' ones
            ymx <- cook[show.r[1]] * 1.075
        }
        else ymx <- max(cook, na.rm = TRUE)
        plot(cook, type = "h", ylim = c(0, ymx), main = main,
            xlab = "Obs. number", ylab = "Cook's distance", ...)
        if (one.fig)
            title(sub = sub.caption, ...)
        mtext(getCaption(4), 3, 0.25, cex = cex.caption)
        if (id.n > 0)
            text.id(show.r, cook[show.r], show.r, adj.x = FALSE)
    }
    if (show[5]) {
	ylim <- range(rs, na.rm = TRUE)
        if (id.n > 0) {
            ylim <- extendrange(r = ylim, f = 0.08)
            show.r <- order(-cook)[iid]
        }
        do.plot <- TRUE
        if (isConst.hat) {## leverages are all the same
            caption[5] <- "Constant Leverage:\n Residuals vs Factor Levels"
            ## plot against factor-level combinations instead
            aterms <- attributes(terms(x))
            ## classes w/o response
            dcl <- aterms$dataClasses[-aterms$response]
            facvars <- names(dcl)[dcl %in% c("factor", "ordered")]
            mf <- model.frame(x)[facvars]# better than x$model
            if(ncol(mf) > 0) {
                ## now re-order the factor levels *along* factor-effects
                ## using a "robust" method {not requiring dummy.coef}:
                effM <- mf
                for(j in seq_len(ncol(mf)))
                    effM[, j] <- vapply(split(yh, mf[, j]), mean, 1)[mf[, j]]
                ord <- do.call(order, effM)
                dm <- data.matrix(mf)[ord, , drop = FALSE]
                ## #{levels} for each of the factors:
                nf <- length(nlev <- unlist(unname(lapply(x$xlevels, length))))
                ff <- if(nf == 1) 1 else rev(cumprod(c(1, nlev[nf:2])))
                facval <- ((dm-1) %*% ff)
                ## now reorder to the same order as the residuals
                facval[ord] <- facval
                xx <- facval # for use in do.plot section.

                plot(facval, rs, xlim = c(-1/2, sum((nlev-1) * ff) + 1/2),
                     ylim = ylim, xaxt = "n",
                     main = main, xlab = "Factor Level Combinations",
                     ylab = ylab5, type = "n", ...)
                axis(1, at = ff[1]*(1:nlev[1] - 1/2) - 1/2,
                     labels= x$xlevels[[1]][order(vapply(split(yh,mf[,1]), 
                                                         mean, 1))])
                mtext(paste(facvars[1],":"), side = 1, line = 0.25, adj=-.05)
                abline(v = ff[1]*(0:nlev[1]) - 1/2, col="gray", lty="F4")
                panel(facval, rs, ...)
                abline(h = 0, lty = 3, col = "gray")
            }
	    else { # no factors
		message("hat values (leverages) are all = ",
                        format(mean(r.hat)),
			"\n and there are no factor predictors; no plot no. 5")
                frame()
                do.plot <- FALSE
            }
        }
        else { ## Residual vs Leverage
            xx <- hii
            ## omit hatvalues of 1.
            xx[xx >= 1] <- NA
            plot(xx, rs, xlim = c(0, max(xx, na.rm = TRUE)), ylim = ylim,
                 main = main, xlab = "Leverage", ylab = ylab5, type = "n",
                 ...)
            panel(xx, rs, ...)
            abline(h = 0, v = 0, lty = 3, col = "gray")
            if (one.fig)
                title(sub = sub.caption, ...)
            if (length(cook.levels)) {
                p <- length(coef(x))
                usr <- par("usr")
                hh <- seq.int(min(r.hat[1], r.hat[2]/100), usr[2],
                              length.out = 101)
                for (crit in cook.levels) {
                  cl.h <- sqrt(crit * p * (1 - hh)/hh)
                  lines(hh, cl.h, lty = 2, col = 2)
                  lines(hh, -cl.h, lty = 2, col = 2)
                }
                legend("bottomleft", legend = "Cook's distance",
                  lty = 2, col = 2, bty = "n")
                xmax <- min(0.99, usr[2])
                ymult <- sqrt(p * (1 - xmax)/xmax)
                aty <- c(-sqrt(rev(cook.levels)) * ymult,
                         sqrt(cook.levels) * ymult)
                axis(4, at = aty,
                     labels = paste(c(rev(cook.levels), cook.levels)),
                     mgp = c(.25, .25, 0), las = 2, tck = 0,
                     cex.axis = cex.id, col.axis = 2)
            }
        } # if(const h_ii) .. else ..
        if (do.plot) {
            mtext(getCaption(5), 3, 0.25, cex = cex.caption)
            if (id.n > 0) {
                y.id <- rs[show.r]
                y.id[y.id < 0] <- y.id[y.id < 0] - strheight(" ")/3
                text.id(xx[show.r], y.id, show.r)
            }
        }
    }
    if (!one.fig && par("oma")[3] >= 1)
        mtext(sub.caption, outer = TRUE, cex = 1.25)
    invisible()
}
