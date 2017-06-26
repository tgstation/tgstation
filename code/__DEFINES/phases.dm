//Megafauna phase transition methods
#define ONE_PHASE 1 //The mob only has one phase and doesn't transition at all
#define PHASE_TRANSITION_HEALTH 2 //The mob transitions between phases at certain health thresholds
#define PHASE_TRANSITION_HEALTH_NOREGRESS 3 //Like PHASE_TRANSITION_HEALTH, but it won't regress to earlier phases if it heals enough
#define PHASE_TRANSITION_SET_POINT 4 //The mob transitions between phases at set points determined by its code
