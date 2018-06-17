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
#define FUSION_SUPER_TIER					50 		//anything above this is super tier
#define FUSION_HIGH_TIER					20 		//anything above this and below 50 is high tier
#define FUSION_MID_TIER						5 		//anything above this and below 20 is mid tier - below this is low tier, but that doesnt need a define
#define FUSION_ENERGY_DIVISOR_SUPER			25
#define FUSION_ENERGY_DIVISOR_HIGH			20
#define FUSION_ENERGY_DIVISOR_MID			10
#define FUSION_ENERGY_DIVISOR_LOW			2
#define FUSION_GAS_CREATION_FACTOR_SUPER	0.20	//stimulum and pluoxium - 40% in total
#define FUSION_GAS_CREATION_FACTOR_HIGH		0.60 	//trit - one gas, so its higher than the other two - 60% in total
#define FUSION_GAS_CREATION_FACTOR_MID		0.45 	//BZ and N2O - 90% in total
#define FUSION_GAS_CREATION_FACTOR_LOW		0.48 	//O2 and CO2 - 96% in total
#define FUSION_MID_TIER_RAD_PROB_FACTOR		2		//probability of radpulse is power ratio * this for whatever tier
#define FUSION_LOW_TIER_RAD_PROB_FACTOR		5
#define FUSION_EFFICIENCY_BASE				60		//used in the fusion efficiency calculations
#define FUSION_EFFICIENCY_DIVISOR			0.6		//ditto
#define FUSION_RADIATION_FACTOR				15000	//horizontal asymptote
#define FUSION_RADIATION_CONSTANT			30		//equation is form of (ax) / (x + b), where a = radiation factor and b = radiation constant (https://www.desmos.com/calculator/4i1f296phl)
#define FUSION_VOLUME_SUPER					100		//volume of the sound the fusion noises make
#define FUSION_VOLUME_HIGH					50
#define FUSION_VOLUME_MID					25
#define FUSION_VOLUME_LOW					10