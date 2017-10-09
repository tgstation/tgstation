/*
These defines are the balancing points of various parts of the radiation system. Changes here can have widespread effects: make sure you test well.
*/

#define RAD_BACKGROUND_RADIATION 9 					// How much radiation is harmless to a mob, this is also when radiation waves stop spreading
#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000

#define RAD_MOB_SAFE 100							// How much stored radiation in a mob with no ill effects
#define RAD_MOB_KNOCKDOWN 1000						// How much stored radiation to start stunning
#define RAD_MOB_MUTATE 800							// How much stored radiation to check for mutation
#define RAD_MOB_HAIRLOSS 500						// How much stored radiation to check for hair loss

#define RAD_KNOCKDOWN_TIME 200						// How much knockdown to apply

#define RAD_LOSS_PER_TICK 10

#define RAD_NO_INSULATION 1.0						// For things that shouldn't become irradiated for whatever reason
#define RAD_VERY_LIGHT_INSULATION 0.9				// What girders have
#define RAD_LIGHT_INSULATION 0.7
#define RAD_MEDIUM_INSULATION  0.5					// What common walls have
#define RAD_HEAVY_INSULATION 0.25				
#define RAD_EXTREME_INSULATION 0.05					// What reinforced walls have
#define RAD_FULL_INSULATION 0						// Unused

// contamination_chance = (strength-RAD_MINIMUM_CONTAMINATION) * RAD_CONTAMINATION_CHANCE_COEFFICIENT
// contamination_strength = (strength-RAD_MINIMUM_CONTAMINATION) * max(1/(steps*RAD_DISTANCE_COEFFICIENT), 1)
#define RAD_MINIMUM_CONTAMINATION 300				// How strong does a radiation wave have to be to contaminate objects
#define RAD_CONTAMINATION_CHANCE_COEFFICIENT 0.005
#define RAD_DISTANCE_COEFFICIENT 0.50				// Lower means further rad spread

#define RAD_HALF_LIFE 150							// The half-life of contaminated objects