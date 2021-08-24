/** liters in a normal breath. note that breaths are taken once every 4 life ticks, which is 8 seconds
 * Addendum for people tweaking this value in the future.
 * Because o2 tank release values/human o2 requirements are very strictly set to the same pressure, small errors can cause breakage
 * This comes from QUANTIZE being used in /datum/gas_mixture.remove(), forming a slight sawtooth pattern of the added/removed gas, centered on the actual pressure
 * Changing BREATH_VOLUME can set us on the lower half of this sawtooth, making humans unable to breath at standard pressure.
 * There's no good way I can come up with to hardcode a fix for this. So if you're going to change this variable
 * graph the functions that describe how it is used/how it interacts with breath code, and pick something on the upper half of the sawtooth
 *
**/
#define BREATH_VOLUME 1.99
/// Amount of air to take a from a tile
#define BREATH_PERCENTAGE (BREATH_VOLUME/CELL_VOLUME)

//Defines for N2O and Healium euphoria moodlets
#define EUPHORIA_INACTIVE 0
#define EUPHORIA_ACTIVE 1
#define EUPHORIA_LAST_FLAG 2

#define MIASMA_CORPSE_MOLES 0.02
#define MIASMA_GIBS_MOLES 0.005

#define MIN_TOXIC_GAS_DAMAGE 1
#define MAX_TOXIC_GAS_DAMAGE 10

// Pressure limits.
/// This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define HAZARD_HIGH_PRESSURE 550
/// This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_HIGH_PRESSURE 325
/// This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define WARNING_LOW_PRESSURE 50
/// This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)
#define HAZARD_LOW_PRESSURE 20

/// This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5

/// The natural temperature for a body
#define BODYTEMP_NORMAL 310.15
/// This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_DIVISOR 28
/// Minimum amount of kelvin moved toward 310K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_AUTORECOVERY_MINIMUM 3
///Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_COLD_DIVISOR 15
/// Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR 15
/// The maximum number of degrees that your body can cool in 1 tick, due to the environment, when in a cold area.
#define BODYTEMP_COOLING_MAX -30
/// The maximum number of degrees that your body can heat up in 1 tick, due to the environment, when in a hot area.
#define BODYTEMP_HEATING_MAX 30
/// The body temperature limit the human body can take before it starts taking damage from heat.
/// This also affects how fast the body normalises it's temperature when hot.
/// 340k is about 66c, and rather high for a human.
#define BODYTEMP_HEAT_DAMAGE_LIMIT (BODYTEMP_NORMAL + 30)
/// The body temperature limit the human body can take before it starts taking damage from cold.
/// This also affects how fast the body normalises it's temperature when cold.
/// 270k is about -3c, that is below freezing and would hurt over time.
#define BODYTEMP_COLD_DAMAGE_LIMIT (BODYTEMP_NORMAL - 40)
/// The body temperature limit the human body can take before it will take wound damage.
#define BODYTEMP_HEAT_WOUND_LIMIT (BODYTEMP_NORMAL + 90) // 400.5 k
/// The modifier on cold damage limit hulks get ontop of their regular limit
#define BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER 25
/// The modifier on cold damage hulks get.
#define HULK_COLD_DAMAGE_MOD 2

// Body temperature warning icons
/// The temperature the red icon is displayed.
#define BODYTEMP_HEAT_WARNING_3 (BODYTEMP_HEAT_DAMAGE_LIMIT + 360) //+700k
/// The temperature the orange icon is displayed.
#define BODYTEMP_HEAT_WARNING_2 (BODYTEMP_HEAT_DAMAGE_LIMIT + 120) //460K
/// The temperature the yellow icon is displayed.
#define BODYTEMP_HEAT_WARNING_1 (BODYTEMP_HEAT_DAMAGE_LIMIT) //340K
/// The temperature the light green icon is displayed.
#define BODYTEMP_COLD_WARNING_1 (BODYTEMP_COLD_DAMAGE_LIMIT) //270k
/// The temperature the cyan icon is displayed.
#define BODYTEMP_COLD_WARNING_2 (BODYTEMP_COLD_DAMAGE_LIMIT - 70) //200k
/// The temperature the blue icon is displayed.
#define BODYTEMP_COLD_WARNING_3 (BODYTEMP_COLD_DAMAGE_LIMIT - 150) //120k

/// The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define PRESSURE_DAMAGE_COEFFICIENT 2
#define MAX_HIGH_PRESSURE_DAMAGE 2
/// The amount of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).
#define LOW_PRESSURE_DAMAGE 2

/// Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this
#define COLD_SLOWDOWN_FACTOR 20


//CLOTHES

/// what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MIN_TEMP_PROTECT 2.0
/// Thermal insulation works both ways /Malkevin
#define SPACE_HELM_MAX_TEMP_PROTECT 1500
/// what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MIN_TEMP_PROTECT 2.0
/// The min cold protection of a space suit without the heater active
#define SPACE_SUIT_MIN_TEMP_PROTECT_OFF 72
#define SPACE_SUIT_MAX_TEMP_PROTECT 1500

/// Cold protection for firesuits
#define FIRE_SUIT_MIN_TEMP_PROTECT 60
/// what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_SUIT_MAX_TEMP_PROTECT 30000
/// Cold protection for fire helmets
#define FIRE_HELM_MIN_TEMP_PROTECT 60
/// for fire helmet quality items (red and white hardhats)
#define FIRE_HELM_MAX_TEMP_PROTECT 30000

/// what max_heat_protection_temperature is set to for firesuit quality suits and helmets. MUST NOT BE 0.
#define FIRE_IMMUNITY_MAX_TEMP_PROTECT 35000

/// For normal helmets
#define HELMET_MIN_TEMP_PROTECT 160
/// For normal helmets
#define HELMET_MAX_TEMP_PROTECT 600
/// For armor
#define ARMOR_MIN_TEMP_PROTECT 160
/// For armor
#define ARMOR_MAX_TEMP_PROTECT 600

/// For some gloves (black and)
#define GLOVES_MIN_TEMP_PROTECT 2.0
/// For some gloves
#define GLOVES_MAX_TEMP_PROTECT 1500
/// For gloves
#define SHOES_MIN_TEMP_PROTECT 2.0
/// For gloves
#define SHOES_MAX_TEMP_PROTECT 1500
