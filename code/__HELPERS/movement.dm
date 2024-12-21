/// Converts w_class into newtons from throwing it, in (0.6 ~ 2.2) range
#define WEIGHT_TO_NEWTONS(w_class, arguments...) 0.2 NEWTONS + w_class * 0.4 NEWTONS
