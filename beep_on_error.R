# Test file

```{r }
options(error = function() beepr::beep())
```


```{r}
# Here is the error, as object does not exist in workspace
summary(rectab)
```


```{r, echo=FALSE}
# Other stuff in script
summary(cars)
plot(cars)
```
