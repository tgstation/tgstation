// living_flags
/// Simple mob trait, indicating it may follow continuous move actions controlled by code instead of by user input.
#define MOVES_ON_ITS_OWN (1<<0)
/// Always does *deathgasp when they die
/// If unset mobs will only deathgasp if supplied a death sound or custom death message
#define ALWAYS_DEATHGASP (1<<1)
/**
 * For carbons, this stops bodypart overlays being added to bodyparts from calling mob.update_body_parts().
 * This is useful for situations like initialization or species changes, where
 * update_body_parts() is going to be called ONE time once everything is done.
 */
#define STOP_OVERLAY_UPDATE_BODY_PARTS (1<<2)
/// Nutrition changed last life tick, so we should bulk update this tick
#define QUEUE_NUTRITION_UPDATE (1<<3)
/// Blood volume or status has changed since the last [proc/update_blood_effects] call.
/// Nowhere near guaranteed to happen only once per life tick, or at all.
#define BLOOD_UPDATE_QUEUED (1<<4)
/// This mob can have blood, cached value of [proc/can_have_blood]
#define LIVING_CAN_HAVE_BLOOD (1<<5)

/// Getter for a mob/living's lying angle, otherwise protected
#define GET_LYING_ANGLE(mob) (UNLINT(mob.lying_angle))
/// Checks if the mob can have blood
#define CAN_HAVE_BLOOD(mob) (mob.living_flags & LIVING_CAN_HAVE_BLOOD)
/// Queues a blood update for the next life tick for the mob
#define QUEUE_BLOOD_UPDATE(mob) mob.living_flags |= BLOOD_UPDATE_QUEUED

// Used in living mob offset list for determining pixel offsets
#define PIXEL_W_OFFSET "w"
#define PIXEL_X_OFFSET "x"
#define PIXEL_Y_OFFSET "y"
#define PIXEL_Z_OFFSET "z"

//Physiology macros and keys

///Default value for physiology coefficients. It should be an identity for multiplication, so basically 1
#define DEFAULT_PHYSIOLOGY_VAL 1

///get the physiology coefficient for a specific key
#define GET_PHYSIOLOGY(living, key) (LAZYACCESS(living.physiology, key) || DEFAULT_PHYSIOLOGY_VAL)

#define _INIT_PHYSIOLOGY_VAL(living, key) \
	LAZYINITLIST(living.physiology); \
	if(isnull(living.physiology[key])) { \
		living.physiology[key] = DEFAULT_PHYSIOLOGY_VAL; \
	}

#define _CLEAR_PHYSIOLOGY_VAL(living, key) \
	if(round(living.physiology[key], 0.001) == DEFAULT_PHYSIOLOGY_VAL) { \
		LAZYREMOVE(living.physiology, key); \
	}

#define MODIFY_PHYSIOLOGY(living, key, mult) \
	_INIT_PHYSIOLOGY_VAL(living, key); \
	living.physiology[key] *= mult;\
	_CLEAR_PHYSIOLOGY_VAL(living, key);

/// Multiplier to brute damage received on adjust_brute_loss (and bodypart/receive_damage()). IE: A brute mod of 0.9 = 10% less brute damage.
#define PHYS_COEFF_BRUTE "brute"
/// Multiplier to burn damage received on adjust_brute_loss (and bodypart/receive_damage())
#define PHYS_COEFF_BURN "burn"
/// Multiplier to toxin damage received on adjust_brute_loss
#define PHYS_COEFF_TOX "tox"
/// Multiplier to oxygen damage received on adjust_brute_loss
#define PHYS_COEFF_OXY "oxy"
/// Multiplier to stamina damage received
#define PHYS_COEFF_STAMINA "stamina"
/// Multiplier to damage taken from high / low pressure exposure, stacking with the brute modifier
#define PHYS_COEFF_PRESSURE "pressure"
/// Multiplier to damage taken from high temperature exposure, stacking with the burn modifier
#define PHYS_COEFF_HEAT "heat"
/// Multiplier to damage taken from low temperature exposure, stacking with the burn modifier
#define PHYS_COEFF_COLD "cold"
/// Multiplier to the damage electrical shocks can cause
#define PHYS_COEFF_ELEC_CONDUCTIVITY "elec_conductivity"
/// Multiplier applied to all incapacitating stuns (knockdown, stun, paralyze, immobilize)
#define PHYS_COEFF_STUN "stun"
/// Multiplied aplpied to just knockdowns, stacks with above multiplicatively
#define PHYS_COEFF_KNOCKDOWN "knockdown"
/// Modifier to amount of blood lost when bleeding (both on life ticks and from flat bleed calls)
#define PHYS_COEFF_BLEED "bleed"
/// Modifier to amount blood regenerated per life tick
#define PHYS_COEFF_BLOOD_REGEN "blood_regen"
/// Modifier of the hunger rate taken per tick
#define PHYS_COEFF_HUNGER_MOD "hunger"
/// Multiplier for flat damage in general (tox, burn, oxy, brute)
#define PHYS_COEFF_DAMAGE "damage"
