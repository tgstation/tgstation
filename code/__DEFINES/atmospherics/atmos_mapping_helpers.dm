//OPEN TURF ATMOS
/// the default air mix that open turfs spawn
#define OPENTURF_DEFAULT_ATMOS "o2=22;n2=82;TEMP=293.15"
#define OPENTURF_LOW_PRESSURE "o2=14;n2=30;TEMP=293.15"
/// -193,15°C telecommunications. also used for xenobiology slime killrooms
#define TCOMMS_ATMOS "n2=100;TEMP=80"
/// space
#define AIRLESS_ATMOS "TEMP=2.7"
/// -93.15°C snow and ice turfs
#define FROZEN_ATMOS "o2=22;n2=82;TEMP=180"
/// -14°C kitchen coldroom, just might loss your tail; higher amount of mol to reach about 101.3 kpA
#define KITCHEN_COLDROOM_ATMOS "o2=26;n2=97;TEMP=[COLD_ROOM_TEMP]"
/// used in the holodeck burn test program
#define BURNMIX_ATMOS "o2=2500;plasma=5000;TEMP=370"

//ATMOSPHERICS DEPARTMENT GAS TANK TURFS
#define ATMOS_TANK_N2O "n2o=6000;TEMP=293.15"
#define ATMOS_TANK_CO2 "co2=50000;TEMP=293.15"
#define ATMOS_TANK_PLASMA "plasma=70000;TEMP=293.15"
#define ATMOS_TANK_O2 "o2=100000;TEMP=293.15"
#define ATMOS_TANK_N2 "n2=100000;TEMP=293.15"
#define ATMOS_TANK_BZ "bz=100000;TEMP=293.15"
#define ATMOS_TANK_FREON "freon=100000;TEMP=293.15"
#define ATMOS_TANK_HALON "halon=100000;TEMP=293.15"
#define ATMOS_TANK_HEALIUM "healium=100000;TEMP=293.15"
#define ATMOS_TANK_H2 "hydrogen=100000;TEMP=293.15"
#define ATMOS_TANK_HYPERNOBLIUM "nob=100000;TEMP=293.15"
#define ATMOS_TANK_MIASMA "miasma=100000;TEMP=293.15"
#define ATMOS_TANK_NITRIUM "nitrium=100000;TEMP=293.15"
#define ATMOS_TANK_PLUOXIUM "pluox=100000;TEMP=293.15"
#define ATMOS_TANK_PROTO_NITRATE "proto_nitrate=100000;TEMP=293.15"
#define ATMOS_TANK_TRITIUM "tritium=100000;TEMP=293.15"
#define ATMOS_TANK_H2O "water_vapor=100000;TEMP=293.15"
#define ATMOS_TANK_ZAUKER "zauker=100000;TEMP=293.15"
#define ATMOS_TANK_HELIUM "helium=100000;TEMP=293.15"
#define ATMOS_TANK_ANTINOBLIUM "antinoblium=100000;TEMP=293.15"
#define ATMOS_TANK_AIRMIX "o2=2644;n2=10580;TEMP=293.15"

//LAVALAND
/// what pressure you have to be under to increase the effect of equipment meant for lavaland
#define LAVALAND_EQUIPMENT_EFFECT_PRESSURE 50

//ATMOS MIX IDS
#define LAVALAND_DEFAULT_ATMOS "LAVALAND_ATMOS"
#define ICEMOON_DEFAULT_ATMOS "ICEMOON_ATMOS"

//ATMOSIA GAS MONITOR TAGS
#define ATMOS_GAS_MONITOR_INPUT_O2 "o2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_O2 "o2_out"
#define ATMOS_GAS_MONITOR_SENSOR_O2 "o2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_PLAS "plas_in"
#define ATMOS_GAS_MONITOR_OUTPUT_PLAS "plas_out"
#define ATMOS_GAS_MONITOR_SENSOR_PLAS "plas_sensor"

#define ATMOS_GAS_MONITOR_INPUT_AIR "air_in"
#define ATMOS_GAS_MONITOR_OUTPUT_AIR "air_out"
#define ATMOS_GAS_MONITOR_SENSOR_AIR "air_sensor"

#define ATMOS_GAS_MONITOR_INPUT_MIX "mix_in"
#define ATMOS_GAS_MONITOR_OUTPUT_MIX "mix_out"
#define ATMOS_GAS_MONITOR_SENSOR_MIX "mix_sensor"

#define ATMOS_GAS_MONITOR_INPUT_N2O "n2o_in"
#define ATMOS_GAS_MONITOR_OUTPUT_N2O "n2o_out"
#define ATMOS_GAS_MONITOR_SENSOR_N2O "n2o_sensor"

#define ATMOS_GAS_MONITOR_INPUT_N2 "n2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_N2 "n2_out"
#define ATMOS_GAS_MONITOR_SENSOR_N2 "n2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_CO2 "co2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_CO2 "co2_out"
#define ATMOS_GAS_MONITOR_SENSOR_CO2 "co2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_BZ "bz_in"
#define ATMOS_GAS_MONITOR_OUTPUT_BZ "bz_out"
#define ATMOS_GAS_MONITOR_SENSOR_BZ "bz_sensor"

#define ATMOS_GAS_MONITOR_INPUT_FREON "freon_in"
#define ATMOS_GAS_MONITOR_OUTPUT_FREON "freon_out"
#define ATMOS_GAS_MONITOR_SENSOR_FREON "freon_sensor"

#define ATMOS_GAS_MONITOR_INPUT_HALON "halon_in"
#define ATMOS_GAS_MONITOR_OUTPUT_HALON "halon_out"
#define ATMOS_GAS_MONITOR_SENSOR_HALON "halon_sensor"

#define ATMOS_GAS_MONITOR_INPUT_HEALIUM "healium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_HEALIUM "healium_out"
#define ATMOS_GAS_MONITOR_SENSOR_HEALIUM "healium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_H2 "h2_in"
#define ATMOS_GAS_MONITOR_OUTPUT_H2 "h2_out"
#define ATMOS_GAS_MONITOR_SENSOR_H2 "h2_sensor"

#define ATMOS_GAS_MONITOR_INPUT_HYPERNOBLIUM "hypernoblium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_HYPERNOBLIUM "hypernoblium_out"
#define ATMOS_GAS_MONITOR_SENSOR_HYPERNOBLIUM "hypernoblium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_MIASMA "miasma_in"
#define ATMOS_GAS_MONITOR_OUTPUT_MIASMA "miasma_out"
#define ATMOS_GAS_MONITOR_SENSOR_MIASMA "miasma_sensor"

#define ATMOS_GAS_MONITOR_INPUT_NITRIUM "nitrium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_NITRIUM "nitrium_out"
#define ATMOS_GAS_MONITOR_SENSOR_NITRIUM "nitrium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_PLUOXIUM "pluoxium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_PLUOXIUM "pluoxium_out"
#define ATMOS_GAS_MONITOR_SENSOR_PLUOXIUM "pluoxium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_PROTO_NITRATE "proto-nitrate_in"
#define ATMOS_GAS_MONITOR_OUTPUT_PROTO_NITRATE "proto-nitrate_out"
#define ATMOS_GAS_MONITOR_SENSOR_PROTO_NITRATE "proto-nitrate_sensor"

#define ATMOS_GAS_MONITOR_INPUT_TRITIUM "tritium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_TRITIUM "tritium_out"
#define ATMOS_GAS_MONITOR_SENSOR_TRITIUM "tritium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_H2O "h2o_in"
#define ATMOS_GAS_MONITOR_OUTPUT_H2O "h2o_out"
#define ATMOS_GAS_MONITOR_SENSOR_H2O "h2o_sensor"

#define ATMOS_GAS_MONITOR_INPUT_ZAUKER "zauker_in"
#define ATMOS_GAS_MONITOR_OUTPUT_ZAUKER "zauker_out"
#define ATMOS_GAS_MONITOR_SENSOR_ZAUKER "zauker_sensor"

#define ATMOS_GAS_MONITOR_INPUT_HELIUM "helium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_HELIUM "helium_out"
#define ATMOS_GAS_MONITOR_SENSOR_HELIUM "helium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_ANTINOBLIUM "antinoblium_in"
#define ATMOS_GAS_MONITOR_OUTPUT_ANTINOBLIUM "antinoblium_out"
#define ATMOS_GAS_MONITOR_SENSOR_ANTINOBLIUM "antinoblium_sensor"

#define ATMOS_GAS_MONITOR_INPUT_INCINERATOR "incinerator_in"
#define ATMOS_GAS_MONITOR_OUTPUT_INCINERATOR "incinerator_out"
#define ATMOS_GAS_MONITOR_SENSOR_INCINERATOR "incinerator_sensor"

#define ATMOS_GAS_MONITOR_INPUT_ORDNANCE_LAB "ordnancelab_in"
#define ATMOS_GAS_MONITOR_OUTPUT_ORDNANCE_LAB "ordnancelab_out"
#define ATMOS_GAS_MONITOR_SENSOR_ORDNANCE_LAB "ordnancelab_sensor"

#define ATMOS_GAS_MONITOR_LOOP_DISTRIBUTION "distro-loop_meter"
#define ATMOS_GAS_MONITOR_LOOP_ATMOS_WASTE "atmos-waste_loop_meter"

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
