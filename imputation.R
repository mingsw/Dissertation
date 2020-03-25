class_new <- c('real','integer','real','integer','real','integer','integer','integer',
           'integer','integer','integer','integer','integer','integer')
data <- read.csv(file = "dissertation.new.csv", fill = TRUE, colClasses = class_new, header = TRUE)

# convert binary variables into factor
for(j in 11:14){
  data[,j] <- factor(data[,j], exclude = NA)
}

# impute missing data
library(mice)
imputed_data <- mice(data, m=1, method = c(rep("norm", 10), rep("logreg", 4)), maxit = 5, seed = 500)
imp_da <- complete(imputed_data)
write.csv(imp_da, "imputed.csv", row.names = FALSE)
