library(gamlss2)
library(targets)
tar_load(gam_df_1950)
tar_load(gam_1950)
tar_load(gamlss_test)
newdata <- tar_read(newdata_stack_1950_gam_1950)
# find_family(gam_df_1950$DOY)
# SEP1 has lowest IC, EGB2 and WEI2 have highest IC
# GG is one of the lower ones, but there are many lower than it.

# plot(gamlss_test, which = "hist-resid")
# plot(gamlss_test, which = "qq-resid")
# plot(gamlss_test, which = "scatter-resid")
plot(gamlss_test, which = "resid") #all 4

#plus the fitted vs response plot from gratia (1:1 line good)
bind_cols(insight::get_data(gamlss_test), p_gamlss2) |>
  ggplot(aes(x = mu, y = DOY)) +
  geom_point() +
  labs(x = "fitted mean", y = "response")


#wow, cool.  seems to have helped!

#sigma (variance) vs. latitude
options(scipen = 999)
plot(gamlss_test, which = "effects", term = 3, scale = 0, xlab = "latitude (m)")
options(scipen = 0)

summary(gamlss_test)

#how long did they take to fit?
tar_meta(c("gamlss_test", "gam_1950"), fields = seconds)
#1296s for gamlss2 and 909s for gam_1950—negligible difference

#benchmark predict methods
library(bench)

b <-
  mark(
    predict(gamlss_test, newdata = newdata), #12GB, 25.5s
    predict(gam_1950, newdata = newdata), #181MB, 384ms
    check = FALSE #I know they are different
  )
b

coef(gamlss_test)
