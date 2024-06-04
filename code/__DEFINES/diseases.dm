#define DISEASE_LIMIT 1
#define VIRUS_SYMPTOM_LIMIT 6

//Visibility Flags
#define HIDDEN_SCANNER (1<<0)
#define HIDDEN_PANDEMIC (1<<1)

//Bitfield for Visibility Flags
DEFINE_BITFIELD(visibility_flags, list(
	"HIDDEN_FROM_ANALYZER" = HIDDEN_SCANNER,
	"HIDDEN_FROM_PANDEMIC" = HIDDEN_PANDEMIC,
))

//Disease Flags
#define CURABLE (1<<0)
#define CAN_CARRY (1<<1)
#define CAN_RESIST (1<<2)
#define CHRONIC (1<<3)

//Spread Flags
#define DISEASE_SPREAD_SPECIAL (1<<0)
#define DISEASE_SPREAD_NON_CONTAGIOUS (1<<1)
#define DISEASE_SPREAD_BLOOD (1<<2)
#define DISEASE_SPREAD_CONTACT_FLUIDS (1<<3)
#define DISEASE_SPREAD_CONTACT_SKIN (1<<4)
#define DISEASE_SPREAD_AIRBORNE (1<<5)

//Bitfield for Spread Flags
DEFINE_BITFIELD(spread_flags, list(
	"SPREAD_SPECIAL" = DISEASE_SPREAD_SPECIAL,
	"SPREAD_NON_CONTAGIOUS" = DISEASE_SPREAD_NON_CONTAGIOUS,
	"SPREAD_BLOOD" = DISEASE_SPREAD_BLOOD,
	"SPREAD_FLUIDS" = DISEASE_SPREAD_CONTACT_FLUIDS,
	"SPREAD_SKIN_CONTACT" = DISEASE_SPREAD_CONTACT_SKIN,
	"SPREAD_AIRBORNE" = DISEASE_SPREAD_AIRBORNE,
))

//Severity Defines
/// Diseases that buff, heal, or at least do nothing at all
#define DISEASE_SEVERITY_POSITIVE "Positive"
/// Diseases that may have annoying effects, but nothing disruptive (sneezing)
#define DISEASE_SEVERITY_NONTHREAT "Harmless"
/// Diseases that can annoy in concrete ways (dizziness)
#define DISEASE_SEVERITY_MINOR "Minor"
/// Diseases that can do minor harm, or severe annoyance (vomit)
#define DISEASE_SEVERITY_MEDIUM "Medium"
/// Diseases that can do significant harm, or severe disruption (brainrot)
#define DISEASE_SEVERITY_HARMFUL "Harmful"
/// Diseases that can kill or maim if left untreated (flesh eating, blindness)
#define DISEASE_SEVERITY_DANGEROUS "Dangerous"
/// Diseases that can quickly kill an unprepared victim (fungal tb, gbs)
#define DISEASE_SEVERITY_BIOHAZARD "BIOHAZARD"
/// Diseases that are uncurable (hms)
#define DISEASE_SEVERITY_UNCURABLE "Uncurable"

//Severity Guaranteed Cycles or how long before a disease can potentially self-cure
/// Positive diseases should not self-cure by themselves, but if they do, they cure fast
#define DISEASE_CYCLES_POSITIVE 15
/// Roughly 6 minutes for a harmless virus
#define DISEASE_CYCLES_NONTHREAT 180
/// Roughly 5 minutes for a disruptive nuisance virus
#define DISEASE_CYCLES_MINOR 150
/// Roughly 4 minutes for a medium virus
#define DISEASE_CYCLES_MEDIUM 120
/// Roughly 3 minutes for a dangerous virus
#define DISEASE_CYCLES_DANGEROUS 90
/// Roughly 2 minutes for a harmful virus
#define DISEASE_CYCLES_HARMFUL 60
/// Roughly 1 minute for a biohazard kill-death-evil-bad virus
#define DISEASE_CYCLES_BIOHAZARD 30

//Natural Immunity/Recovery Balance Levers
/// Recovery Constant - starting point, 'base' recovery when you get initially infected.
//// Minimum stage_prob is 1 for most advanced diseases. Don't raise it above that if you don't want those diseases to start naturally curing themselves.
#define DISEASE_RECOVERY_CONSTANT 0
/// Recovery Scaling - the divisor of the number of adjusted cycles at max_stages divided by Severity Guaranteed Cycles.
//// Raise to make over-time scaling more aggressive as you get further away from Severity Guaranteed Cycles.
//// Basically, once you hit Severity Guaranteed Cycles or equivalent, this will be your flat recovery chance, increasing by 1% for every Severity Guaranteed Cycles/this value cycles. So, if SGC = 30 and this = 3, every 10 cycles should give you another 1% per-cycle chance to recover.
#define DISEASE_RECOVERY_SCALING 2
/// Peaked Recovery Multiplier - Once we hit max_stages, multiplicative bonus to recovery scaling.
//// Adjust to make it faster or slower to cure once the virus has reached its peak.
#define DISEASE_PEAKED_RECOVERY_MULTIPLIER 1.2
/// Slowdown Recovery Bonus - set this to the maximum extra chance per tick you want people to get to recover from spaceacillin or other slowdown/virus resistance effects
#define DISEASE_SLOWDOWN_RECOVERY_BONUS 3
/// Slowdown Recovery Bonus Duration - set this to the maximum # of cycles you want things that cause slowdown/virus resistance to be able to add a bonus up to DISEASE_SLOWDOWN_RECOVERY_BONUS.
//// Scales down linearly over time.
#define DISEASE_SLOWDOWN_RECOVERY_BONUS_DURATION 200
/// Negative Malnutrition Recovery Penalty
//// Flat penalty to recovery chance if malnourished or starving
#define DISEASE_MALNUTRITION_RECOVERY_PENALTY 3
/// Satiety Recovery Multiplier - added chance to recover based on positive satiety
//// Multiplier of satiety/max_satiety if satiety is positive or zero. Increase to make satiety more valuable, decrease for less.
#define DISEASE_SATIETY_RECOVERY_MULTIPLIER 3
/// Good Sleeping Recovery Bonus - additive benefits for various types of good sleep (blanket, bed, darkness, pillows.)
//// Raise to make each factor add this much chance to recover.
#define DISEASE_GOOD_SLEEPING_RECOVERY_BONUS 0.6
/// Sleeping Recovery Multiplier - multiplies ALL recovery chance effects by this amount.
//// Set to 1 for no effect on recovery chances from sleeping.
#define DISEASE_SLEEPING_RECOVERY_MULTIPLIER 6
/// Final Cure Chance Multiplier - multiplies the disease's cure chance to get the probability of moving from stage 1 to a final cure.
//// Must be greater than zero for diseases to self cure.
#define DISEASE_FINAL_CURE_CHANCE_MULTIPLIER 6
/// Symptom Offset Duration - number of cycles over which sleeping/having spaceacillin or a slowdown effect can prevent symptoms appearing
//// Set to maximum # of cycles you want to be able to offset symptoms. Scales down linearly over time.
#define DISEASE_SYMPTOM_OFFSET_DURATION 200

/// Symptom Frequency Modifier
//// Raise to make symptoms fire less frequently, lower to make them fire more frequently. Keep at 0 or above.
#define DISEASE_SYMPTOM_FREQUENCY_MODIFIER 1

/// Minimum Chemical Cure Chance
//// Minimum per-cycle chance we want of being able to cure an advanced disease with the chemicals present.
#define DISEASE_MINIMUM_CHEMICAL_CURE_CHANCE 5
