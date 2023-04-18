/datum/zap_information
	var/atom/source
	var/zap_range
	var/power
	var/zap_flags
	var/list/shocked_targets

/datum/zap_information/proc/zap()
	return SSzaps.process_zap(src)

/proc/tesla_zap(atom/source, zap_range = 3, power, zap_flags = ZAP_DEFAULT_FLAGS, list/shocked_targets = list(), immediate = FALSE)
	if(!SSzaps.can_fire)
		return

	var/datum/zap_information/zap = new
	zap.source = source
	zap.zap_range = zap_range
	zap.zap_flags = zap_flags
	zap.shocked_targets = shocked_targets
	zap.power = power

	SSzaps.processing.Insert(2 * immediate, zap)

/datum/zap_information/supermatter
	var/atom/zapstart
	var/range
	var/zap_str
	var/list/targets_hit
	var/zap_cutoff
	var/power_level
	var/zap_icon
	var/color

/datum/zap_information/supermatter/zap()
	return SSzaps.process_supermatter_zap(src)

/proc/supermatter_zap(atom/zapstart = src, range = 5, zap_str = 4000, zap_flags = ZAP_SUPERMATTER_FLAGS, list/targets_hit = list(), zap_cutoff = 1500, power_level = 0, zap_icon = DEFAULT_ZAP_ICON_STATE, color = null, immediate = FALSE)
	if(!SSzaps.can_fire)
		return

	var/datum/zap_information/supermatter/supermatter_zap = new
	supermatter_zap.zapstart = zapstart
	supermatter_zap.range = range
	supermatter_zap.zap_str = zap_str
	supermatter_zap.zap_flags = zap_flags
	supermatter_zap.targets_hit = targets_hit
	supermatter_zap.zap_cutoff = zap_cutoff
	supermatter_zap.power_level = power_level
	supermatter_zap.zap_icon = zap_icon
	supermatter_zap.color = color

	SSzaps.processing.Insert(2 * immediate, supermatter_zap)
