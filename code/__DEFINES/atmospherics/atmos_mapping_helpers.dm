///Used to define the temperature of a tile, arg is the temperature it should be at. Should always be put at the end of the atmos list.
///This is solely to be used after compile-time.
#define TURF_TEMPERATURE(temperature) "TEMP=[temperature]"

//OPEN TURF ATMOS
/// the default air mix that open turfs spawn
#define OPENTURF_DEFAULT_ATMOS GAS_O2 + "=22;" + GAS_N2 + "=82;TEMP=293.15"
/// the default low-pressure air mix used mostly for mining areas.
#define OPENTURF_LOW_PRESSURE GAS_O2 + "=14;" + GAS_N2 + "=30;TEMP=293.15"
/// breathable air that causes disease
#define OPENTURF_DIRTY_ATMOS GAS_MIASMA + "=15;" + GAS_O2 + "=88;TEMP=293.15"
/// -193,15°C telecommunications. also used for xenobiology slime killrooms
#define TCOMMS_ATMOS GAS_N2 + "=100;TEMP=80"
/// space
#define AIRLESS_ATMOS "TEMP=2.7"
/// -93.15°C snow and ice turfs
#define FROZEN_ATMOS GAS_O2 + "=22;" + GAS_N2 + "=82;TEMP=180"
/// -14°C snow and ice turfs, a more breatheable coldroom atmos.
#define COLD_ATMOS GAS_O2 + "=22;" + GAS_N2 + "=82;TEMP=259.15"
/// -14°C kitchen coldroom, just might loss your tail; higher amount of mol to reach about 101.3 kpA
#define KITCHEN_COLDROOM_ATMOS GAS_O2 + "=26;" + GAS_N2 + "=97;TEMP=259.15"
/// used in the holodeck burn test program
#define BURNMIX_ATMOS GAS_O2 + "=2500;" + GAS_PLASMA + "=5000;TEMP=370"
///-153.15°C plasma air, used for burning people.
#define BURNING_COLD GAS_N2 + "=82;" + GAS_PLASMA + "=24;TEMP=120"
///Space temperature hyper nob
#define SPACE_TEMP_NOBLIUM GAS_HYPER_NOBLIUM + "=7500;TEMP=2.7"
///Xenobio slime containment turf
#define XENOBIO_BZ GAS_BZ + "=100;TEMP=293.15"

//ATMOSPHERICS DEPARTMENT GAS TANK TURFS
#define ATMOS_TANK_N2O GAS_N2O + "=6000;TEMP=293.15"
#define ATMOS_TANK_CO2 GAS_CO2 + "=50000;TEMP=293.15"
#define ATMOS_TANK_PLASMA GAS_PLASMA + "=70000;TEMP=293.15"
#define ATMOS_TANK_O2 GAS_O2 + "=100000;TEMP=293.15"
#define ATMOS_TANK_N2 GAS_N2 + "=100000;TEMP=293.15"
#define ATMOS_TANK_BZ GAS_BZ + "=100000;TEMP=293.15"
#define ATMOS_TANK_FREON GAS_FREON + "=100000;TEMP=293.15"
#define ATMOS_TANK_HALON GAS_HALON + "=100000;TEMP=293.15"
#define ATMOS_TANK_HEALIUM GAS_HEALIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_H2 GAS_HYDROGEN + "=100000;TEMP=293.15"
#define ATMOS_TANK_HYPERNOBLIUM GAS_HYPER_NOBLIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_MIASMA GAS_MIASMA + "=100000;TEMP=293.15"
#define ATMOS_TANK_NITRIUM GAS_NITRIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_PLUOXIUM GAS_PLUOXIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_PROTO_NITRATE GAS_PROTO_NITRATE + "=100000;TEMP=293.15"
#define ATMOS_TANK_TRITIUM GAS_TRITIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_H2O GAS_WATER_VAPOR + "=100000;TEMP=293.15"
#define ATMOS_TANK_ZAUKER GAS_ZAUKER + "=100000;TEMP=293.15"
#define ATMOS_TANK_HELIUM GAS_HELIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_ANTINOBLIUM GAS_ANTINOBLIUM + "=100000;TEMP=293.15"
#define ATMOS_TANK_AIRMIX GAS_O2 + "=2644;" + GAS_N2 + "=10580;TEMP=293.15"

//LAVALAND
/// what pressure you have to be under to increase the effect of equipment meant for lavaland
#define LAVALAND_EQUIPMENT_EFFECT_PRESSURE 50

//ATMOS MIX IDS
#define LAVALAND_DEFAULT_ATMOS "LAVALAND_ATMOS"
#define ICEMOON_DEFAULT_ATMOS "ICEMOON_ATMOS"

//AIRLOCK CONTROLLER TAGS

//RnD ordnance burn chamber
#define INCINERATOR_ORDMIX_IGNITER "ordmix_igniter"
#define INCINERATOR_ORDMIX_VENT "ordmix_vent"
#define INCINERATOR_ORDMIX_DP_VENTPUMP "ordmix_airlock_pump"
#define INCINERATOR_ORDMIX_AIRLOCK_SENSOR "ordmix_airlock_sensor"
#define INCINERATOR_ORDMIX_AIRLOCK_CONTROLLER "ordmix_airlock_controller"
#define INCINERATOR_ORDMIX_AIRLOCK_INTERIOR "ordmix_airlock_interior"
#define INCINERATOR_ORDMIX_AIRLOCK_EXTERIOR "ordmix_airlock_exterior"

//Atmospherics/maintenance incinerator
#define INCINERATOR_ATMOS_IGNITER "atmos_incinerator_igniter"
#define INCINERATOR_ATMOS_MAINVENT "atmos_incinerator_mainvent"
#define INCINERATOR_ATMOS_AUXVENT "atmos_incinerator_auxvent"
#define INCINERATOR_ATMOS_DP_VENTPUMP "atmos_incinerator_airlock_pump"
#define INCINERATOR_ATMOS_AIRLOCK_SENSOR "atmos_incinerator_airlock_sensor"
#define INCINERATOR_ATMOS_AIRLOCK_CONTROLLER "atmos_incinerator_airlock_controller"
#define INCINERATOR_ATMOS_AIRLOCK_INTERIOR "atmos_incinerator_airlock_interior"
#define INCINERATOR_ATMOS_AIRLOCK_EXTERIOR "atmos_incinerator_airlock_exterior"
#define TEST_ROOM_ATMOS_MAINVENT_1 "atmos_test_room_mainvent_1"
#define TEST_ROOM_ATMOS_MAINVENT_2 "atmos_test_room_mainvent_2"

//Syndicate lavaland base incinerator (lavaland_surface_syndicate_base1.dmm)
#define INCINERATOR_SYNDICATELAVA_IGNITER "syndicatelava_igniter"
#define INCINERATOR_SYNDICATELAVA_MAINVENT "syndicatelava_mainvent"
#define INCINERATOR_SYNDICATELAVA_AUXVENT "syndicatelava_auxvent"
#define INCINERATOR_SYNDICATELAVA_DP_VENTPUMP "syndicatelava_airlock_pump"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR "syndicatelava_airlock_sensor"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER "syndicatelava_airlock_controller"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_INTERIOR "syndicatelava_airlock_interior"
#define INCINERATOR_SYNDICATELAVA_AIRLOCK_EXTERIOR "syndicatelava_airlock_exterior"
