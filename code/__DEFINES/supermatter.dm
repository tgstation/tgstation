#define PLASMA_HEAT_PENALTY 15     // Higher == Bigger heat and waste penalty from having the crystal surrounded by this gas. Negative numbers reduce penalty.
#define OXYGEN_HEAT_PENALTY 1
#define PLUOXIUM_HEAT_PENALTY 3
#define TRITIUM_HEAT_PENALTY 10
#define CO2_HEAT_PENALTY 0.1
#define NITROGEN_HEAT_PENALTY -1.5
#define BZ_HEAT_PENALTY 5
#define H2O_HEAT_PENALTY 12 //This'll get made slowly over time, I want my spice rock spicy god damnit
#define FREON_HEAT_PENALTY -10 //very good heat absorbtion and less plasma and o2 generation
#define HYDROGEN_HEAT_PENALTY 10 // similar heat penalty as tritium (dangerous)
#define HEALIUM_HEAT_PENALTY 4
#define PROTO_NITRATE_HEAT_PENALTY -3
#define ZAUKER_HEAT_PENALTY 8

//All of these get divided by 10-bzcomp * 5 before having 1 added and being multiplied with power to determine rads
//Keep the negative values here above -10 and we won't get negative rads
#define OXYGEN_TRANSMIT_MODIFIER 1.5   //Higher == Bigger bonus to power generation.
#define PLASMA_TRANSMIT_MODIFIER 4
#define BZ_TRANSMIT_MODIFIER -2
#define TRITIUM_TRANSMIT_MODIFIER 30 //We divide by 10, so this works out to 3
#define PLUOXIUM_TRANSMIT_MODIFIER -5 //Should halve the power output
#define H2O_TRANSMIT_MODIFIER 2
#define HYDROGEN_TRANSMIT_MODIFIER 25 //increase the radiation emission, but less than the trit (2.5)
#define HEALIUM_TRANSMIT_MODIFIER 2.4
#define PROTO_NITRATE_TRANSMIT_MODIFIER 15
#define ZAUKER_TRANSMIT_MODIFIER 20

#define BZ_RADIOACTIVITY_MODIFIER 5 //Improves the effect of transmit modifiers

#define N2O_HEAT_RESISTANCE 6          //Higher == Gas makes the crystal more resistant against heat damage.
#define HYDROGEN_HEAT_RESISTANCE 2 // just a bit of heat resistance to spice it up
#define PROTO_NITRATE_HEAT_RESISTANCE 5

/// The minimum portion of the miasma in the air that will be consumed. Higher values mean more miasma will be consumed be default.
#define MIASMA_CONSUMPTION_RATIO_MIN 0
/// The maximum portion of the miasma in the air that will be consumed. Lower values mean the miasma consumption rate caps earlier.
#define MIASMA_CONSUMPTION_RATIO_MAX 1
/// The minimum pressure for a pure miasma atmosphere to begin being consumed. Higher values mean it takes more miasma pressure to make miasma start being consumed. Should be >= 0
#define MIASMA_CONSUMPTION_PP (ONE_ATMOSPHERE*0.01)
/// How the amount of miasma consumed per tick scales with partial pressure. Higher values decrease the rate miasma consumption scales with partial pressure. Should be >0
#define MIASMA_PRESSURE_SCALING (ONE_ATMOSPHERE*0.5)
/// How much the amount of miasma consumed per tick scales with gasmix power ratio. Higher values means gasmix has a greater effect on the miasma consumed.
#define MIASMA_GASMIX_SCALING (0.3)
/// The amount of matter power generated for every mole of miasma consumed. Higher values mean miasma generates more power.
#define MIASMA_POWER_GAIN 10

#define POWERLOSS_INHIBITION_GAS_THRESHOLD 0.20         //Higher == Higher percentage of inhibitor gas needed before the charge inertia chain reaction effect starts.
#define POWERLOSS_INHIBITION_MOLE_THRESHOLD 20        //Higher == More moles of the gas are needed before the charge inertia chain reaction effect starts.        //Scales powerloss inhibition down until this amount of moles is reached
#define POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD 500  //bonus powerloss inhibition boost if this amount of moles is reached

#define MOLE_PENALTY_THRESHOLD 1800           //Above this value we can get lord singulo and independent mol damage, below it we can heal damage
#define MOLE_HEAT_PENALTY 350                 //Heat damage scales around this. Too hot setups with this amount of moles do regular damage, anything above and below is scaled
//Along with damage_penalty_point, makes flux anomalies.
/// The cutoff for the minimum amount of power required to trigger the crystal invasion delamination event.
#define EVENT_POWER_PENALTY_THRESHOLD 4500
#define POWER_PENALTY_THRESHOLD 5000          //The cutoff on power properly doing damage, pulling shit around, and delamming into a tesla. Low chance of pyro anomalies, +2 bolts of electricity
#define SEVERE_POWER_PENALTY_THRESHOLD 7000   //+1 bolt of electricity, allows for gravitational anomalies, and higher chances of pyro anomalies
#define CRITICAL_POWER_PENALTY_THRESHOLD 9000 //+1 bolt of electricity.
#define HEAT_PENALTY_THRESHOLD 40             //Higher == Crystal safe operational temperature is higher.
#define DAMAGE_HARDCAP 0.002
#define DAMAGE_INCREASE_MULTIPLIER 0.25


#define THERMAL_RELEASE_MODIFIER 5         //Higher == less heat released during reaction, not to be confused with the above values
#define PLASMA_RELEASE_MODIFIER 750        //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325        //Higher == less oxygen released at high temperature/power

#define REACTION_POWER_MODIFIER 0.55       //Higher == more overall power

#define MATTER_POWER_CONVERSION 10         //Crystal converts 1/this value of stored matter into energy.

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 60

#define HALLUCINATION_RANGE(P) (min(7, round(P ** 0.25)))


#define GRAVITATIONAL_ANOMALY "gravitational_anomaly"
#define FLUX_ANOMALY "flux_anomaly"
#define PYRO_ANOMALY "pyro_anomaly"

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 5
#define SUPERMATTER_EMERGENCY_PERCENT 25
#define SUPERMATTER_DANGER_PERCENT 50
#define SUPERMATTER_WARNING_PERCENT 100
#define CRITICAL_TEMPERATURE 10000

#define SUPERMATTER_COUNTDOWN_TIME 30 SECONDS

///to prevent accent sounds from layering
#define SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN 2 SECONDS

#define DEFAULT_ZAP_ICON_STATE "sm_arc"
#define SLIGHTLY_CHARGED_ZAP_ICON_STATE "sm_arc_supercharged"
#define OVER_9000_ZAP_ICON_STATE "sm_arc_dbz_referance" //Witty I know

#define MAX_SPACE_EXPOSURE_DAMAGE 2
