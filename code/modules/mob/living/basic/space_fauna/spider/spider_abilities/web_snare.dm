/// Make a solid web trap to trap intruders and pray
/datum/action/cooldown/web_snare
	name = "Spin Web Snare"
	desc = "Spin a web snare to hide the nest from prey view."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "lay_web_snare"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	cooldown_time = 20 SECONDS
	/// How long it takes to lay a web
	var/webbing_time = 4 SECONDS

/datum/action/cooldown/web_snare/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/web_snare/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))

/datum/action/cooldown/web_snare/IsAvailable(feedback = FALSE)
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
	if(obstructed_by_other_web_snare())
		if (feedback)
			owner.balloon_alert(owner, "already webbed!")
		return FALSE
	return TRUE

/// Returns true if there's a web we can't put stuff on in our turf
/datum/action/cooldown/web_snare/proc/obstructed_by_other_web_snare()
	return !!(locate(/obj/structure/spider/snare) in get_turf(owner))

/datum/action/cooldown/web_snare/Activate()
	. = ..()
	var/turf/spider_turf = get_turf(owner)
	var/obj/structure/spider/websnare = locate() in spider_turf
	if(websnare)
		owner.balloon_alert_to_viewers("sealing web...")
	else
		owner.balloon_alert_to_viewers("spinning web...")

	if(do_after(owner, webbing_time, target = spider_turf, interaction_key = DOAFTER_SOURCE_SPIDER) && owner.loc == spider_turf)
		plant_websnare(spider_turf, websnare)
	else
		owner?.balloon_alert(owner, "interrupted!") // Null check because we might have been interrupted via being disintegrated
	build_all_button_icons()

	/// Creates a web in the current turf
/datum/action/cooldown/web_snare/proc/plant_websnare(turf/target_turf, obj/structure/spider/snare/existing_web)
	new /obj/structure/spider/snare(target_turf)
