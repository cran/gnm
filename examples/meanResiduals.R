data(yaish)
## Fit a conditional independence model, leaving out
## the uninformative subtable for dest == 7:
CImodel <- gnm(Freq ~ educ*orig + educ*dest, family = poisson,
               data = yaish, subset = (dest != 7))

## compute mean residuals over origin and destination
meanResiduals(CImodel, model.frame(CImodel)[c("orig", "dest")])

## non-aggregated residuals
res1 <- meanResiduals(CImodel,
                      model.frame(CImodel)[c("educ", "orig", "dest")])

res2 <- residuals(CImodel, type = "pearson")

all.equal(res1[,,], res2[,,])
