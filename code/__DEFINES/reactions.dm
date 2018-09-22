//Defines used in atmos gas reactions. Used to be located in ..\modules\atmospherics\gasmixtures\reactions.dm, but were moved here because fusion added so fucking many.

//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_BURN_RATE_DELTA				9
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define FIRE_CARBON_ENERGY_RELEASED			100000	//Amount of heat released per mole of burnt carbon into the tile
#define FIRE_HYDROGEN_ENERGY_RELEASED		280000  //Amount of heat released per mole of burnt hydrogen and/or tritium(hydrogen isotope)
#define FIRE_PLASMA_ENERGY_RELEASED			3000000	//Amount of heat released per mole of burnt plasma into the tile
//General assmos defines.
#define WATER_VAPOR_FREEZE					200
#define NITRYL_FORMATION_ENERGY				100000
#define TRITIUM_BURN_OXY_FACTOR				100
#define TRITIUM_BURN_TRIT_FACTOR			10
#define TRITIUM_BURN_RADIOACTIVITY_FACTOR	50000 	//The neutrons gotta go somewhere. Completely arbitrary number.
#define TRITIUM_MINIMUM_RADIATION_ENERGY	0.1  	//minimum 0.01 moles trit or 10 moles oxygen to start producing rads
#define SUPER_SATURATION_THRESHOLD			96
#define STIMULUM_HEAT_SCALE					100000
#define STIMULUM_FIRST_RISE					0.65
#define STIMULUM_FIRST_DROP					0.065
#define STIMULUM_SECOND_RISE				0.0009
#define STIMULUM_ABSOLUTE_DROP				0.00000335
#define REACTION_OPPRESSION_THRESHOLD		5
#define NOBLIUM_FORMATION_ENERGY			2e9 	//1 Mole of Noblium takes the planck energy to condense.
//Plasma fusion properties
#define FUSION_ENERGY_THRESHOLD				3e9 	//Amount of energy it takes to start a fusion reaction
#define FUSION_TEMPERATURE_THRESHOLD		1000 	//Temperature required to start a fusion reaction
#define FUSION_MOLE_THRESHOLD				250 	//Mole count required (tritium/plasma) to start a fusion reaction
#define FUSION_RELEASE_ENERGY_SUPER			3e9 	//Amount of energy released in the fusion process, super tier
#define FUSION_RELEASE_ENERGY_HIGH			1e9 	//Amount of energy released in the fusion process, high tier
#define FUSION_RELEASE_ENERGY_MID			5e8 	//Amount of energy released in the fusion process, mid tier
#define FUSION_RELEASE_ENERGY_LOW			1e8 	//Amount of energy released in the fusion process, low tier
#define FUSION_MEDIATION_FACTOR				80 		//Arbitrary
#define FUSION_SUPER_TIER_THRESHOLD			50 		//anything above this is super tier
#define FUSION_HIGH_TIER_THRESHOLD			20 		//anything above this and below 50 is high tier
#define FUSION_MID_TIER_THRESHOLD			5 		//anything above this and below 20 is mid tier - below this is low tier, but that doesnt need a define
#define FUSION_ENERGY_DIVISOR_SUPER			25		//power_ratio is divided by this during energy calculations
#define FUSION_ENERGY_DIVISOR_HIGH			20
#define FUSION_ENERGY_DIVISOR_MID			10
#define FUSION_ENERGY_DIVISOR_LOW			2
#define FUSION_GAS_CREATION_FACTOR_TRITIUM	0.40 	//trit - one gas rather than two, so think about that when calculating stuff - 40% in total
#define FUSION_GAS_CREATION_FACTOR_STIM		0.05	//stim percentage creation from high tier - 5%, 60% in total with pluox
#define FUSION_GAS_CREATION_FACTOR_PLUOX    0.55	//pluox percentage creation from high tier - 55%, 60% in total with stim
#define FUSION_GAS_CREATION_FACTOR_NITRYL	0.20 	//nitryl and N2O - 80% in total
#define FUSION_GAS_CREATION_FACTOR_N2O		0.60 	//nitryl and N2O - 80% in total
#define FUSION_GAS_CREATION_FACTOR_BZ		0.05 	//BZ - 5% - 90% in total with CO2
#define FUSION_GAS_CREATION_FACTOR_CO2		0.85 	//CO2 - 85% - 90% in total with BZ
#define FUSION_MID_TIER_RAD_PROB_FACTOR		2		//probability of radpulse is power ratio * this for whatever tier
#define FUSION_LOW_TIER_RAD_PROB_FACTOR		5
#define FUSION_EFFICIENCY_BASE				60		//used in the fusion efficiency calculations
#define FUSION_EFFICIENCY_DIVISOR			0.6		//ditto
#define FUSION_RADIATION_FACTOR				15000	//horizontal asymptote
#define FUSION_RADIATION_CONSTANT			30		//equation is form of (ax) / (x + b), where a = radiation factor and b = radiation constant and x = power ratio (https://www.desmos.com/calculator/4i1f296phl)
#define FUSION_ZAP_POWER_ASYMPTOTE			50000	//maximum value - not enough to instacrit but it'll still hurt like shit
#define FUSION_ZAP_POWER_CONSTANT			75		//equation is of from [ax / (x + b)] + c, where a = zap power asymptote, b = zap power constant, c = zap power base and x = power ratio
#define FUSION_ZAP_POWER_BASE				1000	//(https://www.desmos.com/calculator/vvbmhf4unm)
#define FUSION_ZAP_RANGE_SUPER				9		//range of the tesla zaps that occur from fusion
#define FUSION_ZAP_RANGE_HIGH				7
#define FUSION_ZAP_RANGE_MID				5
#define FUSION_ZAP_RANGE_LOW				3
#define FUSION_PARTICLE_FACTOR_SUPER		4		//# of particles fired out is equal to rand(3,6) * this for whatever tier
#define FUSION_PARTICLE_FACTOR_HIGH			3
#define FUSION_PARTICLE_FACTOR_MID			2
#define FUSION_PARTICLE_FACTOR_LOW			1
