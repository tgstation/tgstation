#define AIR_ALARM_WARNING_MIN (1 << 0)
#define AIR_ALARM_HAZARD_MIN (1 << 1)
#define AIR_ALARM_WARNING_MAX (1 << 2)
#define AIR_ALARM_HAZARD_MAX (1 << 3)
#define AIR_ALARM_ALL (AIR_ALARM_WARNING_MIN | AIR_ALARM_HAZARD_MIN | AIR_ALARM_WARNING_MAX | AIR_ALARM_HAZARD_MAX)

///TLV datums wont check limits set to this
#define TLV_DONT_CHECK -1
///the gas mixture is within the bounds of both warning and hazard limits
#define TLV_NO_DANGER 0
///the gas value is outside the warning limit but within the hazard limit, the air alarm will go into warning mode
#define TLV_OUTSIDE_WARNING_LIMIT 1
///the gas is outside the hazard limit, the air alarm will go into hazard mode
#define TLV_OUTSIDE_HAZARD_LIMIT 2

// A datum for dealing with threshold limit values
/datum/tlv
	var/warning_min = 0
	var/warning_max = 0
	var/hazard_min = 0
	var/hazard_max = 0

/** Initialize a TLV and set it's values if given arguments, mostly for map varedits.
 * We provide this functionality but please consider not doing this and making proper subtypes.
 * Only by doing the latter will [datum/tlv/proc/reset_values] work.
 */
/datum/tlv/New(min2 as num, min1 as num, max1 as num, max2 as num)
	if(min2)
		hazard_min = min2
	if(min1)
		warning_min = min1
	if(max1)
		warning_max = max1
	if(max2)
		hazard_max = max2

/datum/tlv/proc/get_danger_level(val)
	if(hazard_max != TLV_DONT_CHECK && val >= hazard_max)
		return TLV_OUTSIDE_HAZARD_LIMIT
	if(hazard_min != TLV_DONT_CHECK && val <= hazard_min)
		return TLV_OUTSIDE_HAZARD_LIMIT
	if(warning_max != TLV_DONT_CHECK && val >= warning_max)
		return TLV_OUTSIDE_WARNING_LIMIT
	if(warning_min != TLV_DONT_CHECK && val <= warning_min)
		return TLV_OUTSIDE_WARNING_LIMIT

	return TLV_NO_DANGER

/** Set this particular TLV
 *
 * Arguments:
 * * threshold_type: What kind of variable do we want to set. Accepts bitfield subsets of [AIR_ALARM_ALL].
 * * value: How much to set it to. Accepts a number or [TLV_DONT_CHECK]
 */
/datum/tlv/proc/set_value(threshold_type, value)
	if(threshold_type & AIR_ALARM_WARNING_MIN)
		warning_min = value
	if(threshold_type & AIR_ALARM_HAZARD_MIN)
		hazard_min = value
	if(threshold_type & AIR_ALARM_WARNING_MAX)
		warning_max = value
	if(threshold_type & AIR_ALARM_HAZARD_MAX)
		hazard_max = value

/** Reset this particular TLV to it's original value.
 *
 * Arguments:
 * * threshold_type: What kind of variable do we want to set. Accepts bitfield subsets of [AIR_ALARM_ALL].
 */
/datum/tlv/proc/reset_values(threshold_type)
	if(threshold_type & AIR_ALARM_WARNING_MIN)
		warning_min = initial(warning_min)
	if(threshold_type & AIR_ALARM_HAZARD_MIN)
		hazard_min = initial(hazard_min)
	if(threshold_type & AIR_ALARM_WARNING_MAX)
		warning_max = initial(warning_max)
	if(threshold_type & AIR_ALARM_HAZARD_MAX)
		hazard_max = initial(hazard_max)

/datum/tlv/no_checks
	warning_min = TLV_DONT_CHECK
	hazard_min = TLV_DONT_CHECK
	warning_max = TLV_DONT_CHECK
	hazard_max = TLV_DONT_CHECK

/datum/tlv/dangerous
	warning_min = TLV_DONT_CHECK
	hazard_min = TLV_DONT_CHECK
	warning_max = 0.2
	hazard_max = 0.5

/datum/tlv/oxygen
	warning_min = 19
	hazard_min = 16
	warning_max = TLV_DONT_CHECK
	hazard_max = TLV_DONT_CHECK

/datum/tlv/carbon_dioxide
	warning_min = TLV_DONT_CHECK
	hazard_min = TLV_DONT_CHECK
	warning_max = 5
	hazard_max = 10

/datum/tlv/pressure
	warning_min = WARNING_LOW_PRESSURE
	hazard_min = HAZARD_LOW_PRESSURE
	warning_max = WARNING_HIGH_PRESSURE
	hazard_max = HAZARD_HIGH_PRESSURE

/datum/tlv/temperature
	warning_min = BODYTEMP_COLD_WARNING_1+10
	hazard_min = BODYTEMP_COLD_WARNING_1
	warning_max = BODYTEMP_HEAT_WARNING_1-27
	hazard_max = BODYTEMP_HEAT_WARNING_1

/datum/tlv/cold_room_pressure
	warning_min = ONE_ATMOSPHERE * 0.9
	hazard_min = ONE_ATMOSPHERE * 0.8
	warning_max = ONE_ATMOSPHERE * 1.1
	hazard_max = ONE_ATMOSPHERE * 1.2

/datum/tlv/cold_room_temperature
	warning_min = COLD_ROOM_TEMP - 20
	hazard_min = COLD_ROOM_TEMP - 40
	warning_max = COLD_ROOM_TEMP + 20
	hazard_max = COLD_ROOM_TEMP + 40
