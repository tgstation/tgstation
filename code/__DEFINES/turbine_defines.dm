///Multiplier for converting work into rpm and rpm into power
#define TURBINE_RPM_CONVERSION 15
///Efficiency of the turbine to turn work into energy, higher values will yield more power
#define TURBINE_ENERGY_RECTIFICATION_MULTIPLIER 0.25
///Max allowed damage per tick
#define TURBINE_MAX_TAKEN_DAMAGE 10
///Amount of damage healed when under the heat threshold
#define TURBINE_DAMAGE_HEALING 2
///Amount of damage that the machine must have to start launching alarms to the engi comms
#define TURBINE_DAMAGE_ALARM_START 15
///Multiplier when converting the gas energy into gas work
#define TURBINE_WORK_CONVERSION_MULTIPLIER 0.01
///Multiplier when converting gas work back into heat
#define TURBINE_HEAT_CONVERSION_MULTIPLIER 0.005
///Amount of energy removed from the work done by the stator due to the consumption from the compressor working on the gases
#define TURBINE_COMPRESSOR_STATOR_INTERACTION_MULTIPLIER 0.15
///Tiers for turbine parts
#define TURBINE_PART_TIER_ONE 1
#define TURBINE_PART_TIER_TWO 2
#define TURBINE_PART_TIER_THREE 3
#define TURBINE_PART_TIER_FOUR 4
