/// Pick a random attack zone before you attack something
/datum/element/attack_zone_randomiser
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// List of attack zones you can select, should be a subset of GLOB.all_body_zones
	var/list/valid_attack_zones

/datum/element/attack_zone_randomiser/Attach(datum/target, list/valid_attack_zones = GLOB.all_body_zones)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK), PROC_REF(randomise))
	src.valid_attack_zones = valid_attack_zones

/datum/element/attack_zone_randomiser/Detach(datum/source)
	UnregisterSignal(source, list (COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK))
	return ..()

/// If we're attacking a carbon, pick a random defence zone
/datum/element/attack_zone_randomiser/proc/randomise(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if (!iscarbon(target))
		return
	if (!isnull(source.mind) && !isnull(source.hud_used?.zone_select))
		return
	var/mob/living/living_target = target
	var/list/blacklist_zones = GLOB.all_body_zones - valid_attack_zones
	var/new_zone = living_target.get_random_valid_zone(blacklisted_parts = blacklist_zones, bypass_warning = TRUE)
	if (isnull(new_zone))
		new_zone = BODY_ZONE_CHEST
	var/atom/movable/screen/zone_sel/zone_selector = source.hud_used?.zone_select
	if (isnull(zone_selector))
		source.zone_selected = new_zone
	else
		zone_selector.set_selected_zone(new_zone, source, should_log = FALSE)
