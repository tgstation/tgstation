/// Make a solid web under yourself for area fortification
/datum/action/cooldown/solid_web
	name = "Spin Solid Web"
	desc = "Spin a web to slow down potential prey."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "lay_solid_web"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	cooldown_time = 0 SECONDS
	/// How long it takes to lay a web
	var/webbing_time = 5 SECONDS

/datum/action/cooldown/solid_web/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/solid_web/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))

/datum/action/cooldown/solid_web/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(DOING_INTERACTION(owner, DOAFTER_SOURCE_SPIDER))
		if (feedback)
			owner.balloon_alert(owner, "busy!")
		return FALSE
	if(!isturf(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "invalid location!")
		return FALSE
	if(obstructed_by_other_solid_web())
		if (feedback)
			owner.balloon_alert(owner, "already webbed!")
		return FALSE
	return TRUE

/// Returns true if there's a web we can't put stuff on in our turf
/datum/action/cooldown/solid_web/proc/obstructed_by_other_solid_web()
	return !!(locate(/obj/structure/spider/solid) in get_turf(owner))

/datum/action/cooldown/solid_web/Activate()
	. = ..()
	var/turf/spider_turf = get_turf(owner)
	var/obj/structure/spider/solidweb = locate() in spider_turf
	if(solidweb)
		owner.balloon_alert_to_viewers("sealing web...")
	else
		owner.balloon_alert_to_viewers("spinning web...")

	if(do_after(owner, webbing_time, target = spider_turf, interaction_key = DOAFTER_SOURCE_SPIDER) && owner.loc == spider_turf)
		plant_solidweb(spider_turf, solidweb)
	else
		owner?.balloon_alert(owner, "interrupted!") // Null check because we might have been interrupted via being disintegrated
	build_all_button_icons()

/// Creates a web in the current turf
/datum/action/cooldown/solid_web/proc/plant_solidweb(turf/target_turf, obj/structure/spider/solid/existing_web)
	new /obj/structure/spider/solid(target_turf)

