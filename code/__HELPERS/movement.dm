/// Converts w_class into newtons from throwing it, in (0.6 ~ 2.2) range
#define WEIGHT_TO_NEWTONS(w_class, arguments...) 0.2 NEWTONS + w_class * 0.4 NEWTONS

/// Converts movement delay into drift force required to achieve that speed
#define MOVE_DELAY_TO_DRIFT(move_delay) ((DEFAULT_INERTIA_SPEED / move_delay - 1) / INERTIA_SPEED_COEF + 1)
