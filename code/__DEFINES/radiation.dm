/*
These defines are the balancing points of various parts of the radiation system.
Changes here can have widespread effects: make sure you test well.
Ask ninjanomnom if they're around
*/

#define RAD_BACKGROUND_RADIATION 9 					// How much radiation is harmless to a mob, this is also when radiation waves stop spreading
													// WARNING: Lowering this value significantly increases SSradiation load
#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000

// apply_effect(amount * RAD_MOB_COEFFICIENT, IRRADIATE, blocked)
#define RAD_MOB_COEFFICIENT 0.25					// Radiation applied is multiplied by this

#define RAD_LOSS_PER_TICK 1
#define RAD_TOX_COEFFICIENT 0.05					// Toxin damage per tick coefficient

#define RAD_MOB_SAFE 300							// How much stored radiation in a mob with no ill effects
#define RAD_MOB_KNOCKDOWN 1500						// How much stored radiation to start stunning
// If (mutate*2<knockdown) then monkeys will sometimes turn into gorillas before being knocked down
// otherwise they only turn into gorillas *after* being knocked down
#define RAD_MOB_MUTATE 800							// How much stored radiation to check for mutation
#define RAD_MOB_HAIRLOSS 500						// How much stored radiation to check for hair loss

#define RAD_KNOCKDOWN_TIME 200						// How much knockdown to apply

#define RAD_NO_INSULATION 1.0						// For things that shouldn't become irradiated for whatever reason
#define RAD_VERY_LIGHT_INSULATION 0.9				// What girders have
#define RAD_LIGHT_INSULATION 0.8
#define RAD_MEDIUM_INSULATION  0.7					// What common walls have
#define RAD_HEAVY_INSULATION 0.6					// What reinforced walls have
#define RAD_EXTREME_INSULATION 0.5					// What rad collectors have
#define RAD_FULL_INSULATION 0						// Unused

// WARNING: The deines below could have disastrous consequences if tweaked incorrectly. See: The great SM purge of Oct.6.2017
// contamination_chance = 		(strength-RAD_MINIMUM_CONTAMINATION) * RAD_CONTAMINATION_CHANCE_COEFFICIENT * min(1/(steps*RAD_DISTANCE_COEFFICIENT), 1))
// contamination_strength = 	(strength-RAD_MINIMUM_CONTAMINATION) * RAD_CONTAMINATION_STR_COEFFICIENT * min(1/(steps*RAD_DISTANCE_COEFFICIENT), 1)
#define RAD_MINIMUM_CONTAMINATION 300				// How strong does a radiation wave have to be to contaminate objects
#define RAD_CONTAMINATION_CHANCE_COEFFICIENT 0.0075	// Higher means higher strength scaling contamination chance
#define RAD_CONTAMINATION_STR_COEFFICIENT 0.5		// Higher means higher strength scaling contamination strength
#define RAD_DISTANCE_COEFFICIENT 1					// Lower means further rad spread

#define RAD_HALF_LIFE 150							// The half-life of contaminated objects