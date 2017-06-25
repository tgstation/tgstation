#define FIRE_DAMAGE_MODIFIER	0.0215	//Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER		2.025	//More means less damage from hot air scalding lungs, less = more damage. (default 2.025)

#define MOLES_CELLSTANDARD		(ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC
#define M_CELL_WITH_RATIO		(MOLES_CELLSTANDARD * 0.005)
#define O2STANDARD				0.21
#define N2STANDARD				0.79
#define MOLES_O2STANDARD		(MOLES_CELLSTANDARD*O2STANDARD)	// O2 standard value (21%)
#define MOLES_N2STANDARD		(MOLES_CELLSTANDARD*N2STANDARD)	// N2 standard value (79%)

//indices of values in gas lists. used by listmos.
#define MOLES			1
#define ARCHIVE			2
#define GAS_META		3
#define META_GAS_SPECIFIC_HEAT	1
#define META_GAS_NAME			2
#define META_GAS_MOLES_VISIBLE	3
#define META_GAS_OVERLAY		4
#define META_GAS_DANGER			5

//stuff you should probably leave well alone!
//ATMOS
#define CELL_VOLUME							2500	//liters in a cell
#define BREATH_VOLUME						0.5		//liters in a normal breath
#define BREATH_PERCENTAGE					(BREATH_VOLUME/CELL_VOLUME)					//Amount of air to take a from a tile
#define HUMAN_NEEDED_OXYGEN					(MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16)	//Amount of air needed before pass out/suffocation commences
#define NORMPIPERATE						30		//pipe-insulation rate divisor
#define HEATPIPERATE						8		//heat-exch pipe insulation
#define FLOWFRAC							0.99	//fraction of gas transfered per process
#define TANK_LEAK_PRESSURE					(30.*ONE_ATMOSPHERE)	//Tank starts leaking
#define TANK_RUPTURE_PRESSURE				(35.*ONE_ATMOSPHERE)	//Tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE				(40.*ONE_ATMOSPHERE)	//Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    			(6.*ONE_ATMOSPHERE)	//+1 for each SCALE kPa aboe threshold
#define MINIMUM_AIR_RATIO_TO_SUSPEND		0.1		//Ratio of air that must move to/from a tile to reset group processing
#define MINIMUM_AIR_RATIO_TO_MOVE			0.001	//Minimum ratio of air that must move to/from a tile
#define MINIMUM_AIR_TO_SUSPEND				(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)	//Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE			(MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_MOVE) //Either this must be active
#define EXCITED_GROUP_BREAKDOWN_CYCLES		4
#define EXCITED_GROUP_DISMANTLE_CYCLES		16
#define MINIMUM_TEMPERATURE_TO_MOVE			(T20C+100)			//or this (or both, obviously)
#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND		0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND		4		//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER		0.5		//Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		T20C+10
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	T20C+200
#define FLOOR_HEAT_TRANSFER_COEFFICIENT		0.4
#define WALL_HEAT_TRANSFER_COEFFICIENT		0.0
#define DOOR_HEAT_TRANSFER_COEFFICIENT		0.0
#define SPACE_HEAT_TRANSFER_COEFFICIENT		0.2		//a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT		0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT	0.1		//a hack for now
	//Must be between 0 and 1. Values closer to 1 equalize temperature faster
	//Should not exceed 0.4 else strange heat flow occur
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	150+T0C
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	100+T0C
#define FIRE_SPREAD_RADIOSITY_SCALE			0.85
#define FIRE_CARBON_ENERGY_RELEASED			500000	//Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED			3000000	//Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE					40000	//For small fires
#define CARBON_LIFEFORM_FIRE_RESISTANCE 	200+T0C	//Resistance to fire damage
#define CARBON_LIFEFORM_FIRE_DAMAGE			4		//Fire damage
	//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_BURN_RATE_DELTA				9
#define PLASMA_MINIMUM_BURN_TEMPERATURE		100+T0C
#define PLASMA_UPPER_TEMPERATURE			1370+T0C
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10
#define MIN_PLASMA_DAMAGE					1
#define MAX_PLASMA_DAMAGE					10
#define MOLES_PLASMA_VISIBLE				0.5		//Moles in a standard cell after which plasma is visible
	//Plasma fusion properties
#define PLASMA_BINDING_ENERGY				3000000
#define MAX_CARBON_EFFICENCY				9
#define PLASMA_FUSED_COEFFICENT				0.08
#define CARBON_CATALYST_COEFFICENT			0.01
#define FUSION_PURITY_THRESHOLD				0.9
// Pressure limits.
#define HAZARD_HIGH_PRESSURE				550		//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE				325		//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE				50		//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE					20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT		1.5		//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define BODYTEMP_AUTORECOVERY_DIVISOR		12		//This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM		10		//Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX				30		//The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX				30		//The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT			360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT			260.15 // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELM_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MAX_TEMP_PROTECT			1500	//Thermal insulation works both ways /Malkevin
#define SPACE_SUIT_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_TEMP_PROTECT			1500

#define FIRE_SUIT_MIN_TEMP_PROTECT			60		//Cold protection for firesuits
#define FIRE_SUIT_MAX_TEMP_PROTECT			30000	//what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_HELM_MIN_TEMP_PROTECT			60		//Cold protection for fire helmets
#define FIRE_HELM_MAX_TEMP_PROTECT			30000	//for fire helmet quality items (red and white hardhats)

#define FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT	35000	//what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT	35000	//for fire helmet quality items (red and white hardhats)

#define HELMET_MIN_TEMP_PROTECT				160		//For normal helmets
#define HELMET_MAX_TEMP_PROTECT				600		//For normal helmets
#define ARMOR_MIN_TEMP_PROTECT				160		//For armor
#define ARMOR_MAX_TEMP_PROTECT				600		//For armor

#define GLOVES_MIN_TEMP_PROTECT				2.0		//For some gloves (black and)
#define GLOVES_MAX_TEMP_PROTECT				1500	//For some gloves
#define SHOES_MIN_TEMP_PROTECT				2.0		//For gloves
#define SHOES_MAX_TEMP_PROTECT				1500	//For gloves


#define PRESSURE_DAMAGE_COEFFICIENT			4		//The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE			4		//This used to be 20... I got this much random rage for some retarded decision by polymorph?! Polymorph now lies in a pool of blood with a katana jammed in his spleen. ~Errorage --PS: The katana did less than 20 damage to him :(
#define LOW_PRESSURE_DAMAGE					2		//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define COLD_SLOWDOWN_FACTOR				20		//Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this

// Atmos pipe limits
#define MAX_OUTPUT_PRESSURE					4500 // (kPa) What pressure pumps and powered equipment max out at.
#define MAX_TRANSFER_RATE					200 // (L/s) Maximum speed powered equipment can work at.

//Atmos machinery pipenet stuff

// used for device_type vars; used by DEVICE_TYPE_LOOP
#define UNARY		1
#define BINARY 		2
#define TRINARY		3
#define QUATERNARY	4

// this is the standard for loop used by all sorts of atmos machinery procs
#define DEVICE_TYPE_LOOP	var/I in 1 to device_type

// defines for the various machinery lists
// NODE_I, AIR_I, PARENT_I are used within DEVICE_TYPE_LOOP

//  nodes list - all atmos machinery
#define NODE1	nodes[1]
#define	NODE2	nodes[2]
#define NODE3	nodes[3]
#define NODE4	nodes[4]
#define NODE_I	nodes[I]

//  airs list - components only
#define AIR1	airs[1]
#define AIR2	airs[2]
#define AIR3	airs[3]
#define AIR_I	airs[I]

//  parents list - components only
#define PARENT1		parents[1]
#define PARENT2		parents[2]
#define PARENT3		parents[3]
#define PARENT_I	parents[I]

//Tanks
#define TANK_MAX_RELEASE_PRESSURE (ONE_ATMOSPHERE*3)
#define TANK_MIN_RELEASE_PRESSURE 0
#define TANK_DEFAULT_RELEASE_PRESSURE 16


#define ATMOS_PASS_YES 1
#define ATMOS_PASS_NO 0
#define ATMOS_PASS_PROC -1 //ask CanAtmosPass()
#define ATMOS_PASS_DENSITY -2 //just check density
#define CANATMOSPASS(A, O) ( A.CanAtmosPass == ATMOS_PASS_PROC ? A.CanAtmosPass(O) : ( A.CanAtmosPass == ATMOS_PASS_DENSITY ? !A.density : A.CanAtmosPass ) )

#define LAVALAND_DEFAULT_ATMOS "o2=14;n2=23;TEMP=300"
