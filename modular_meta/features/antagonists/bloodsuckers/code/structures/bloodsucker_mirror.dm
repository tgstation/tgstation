/// Blood mirror wallframe item.
/obj/item/wallframe/blood_mirror
	name = "scarlet mirror"
	desc = "A pool of stilled blood kept secure between unanchored glass and silver. Attach it to a wall to use."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_mirror"
	custom_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	result_path = /obj/structure/bloodsucker/mirror
	pixel_shift = 28

//Copied over from 'wall_mounted.dm' with necessary alterations
/obj/item/wallframe/blood_mirror/attach(turf/on_wall, mob/user)
	if(!IS_BLOODSUCKER(user))
		balloon_alert(user, "you don't understand its mounting mechanism!")
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(get_area(user) == bloodsuckerdatum.bloodsucker_lair_area)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] attaches [src] to the wall."),
			span_notice("You attach [src] to the wall."),
			span_hear("You hear clicking."))
		var/floor_to_wall = get_dir(user, on_wall)

		var/obj/structure/bloodsucker/mirror/hanging_object = new result_path(get_turf(user), floor_to_wall, TRUE)
		hanging_object.setDir(floor_to_wall)
		if(pixel_shift)
			switch(floor_to_wall)
				if(NORTH)
					hanging_object.pixel_y = pixel_shift
				if(SOUTH)
					hanging_object.pixel_y = -pixel_shift
				if(EAST)
					hanging_object.pixel_x = pixel_shift
				if(WEST)
					hanging_object.pixel_x = -pixel_shift
		transfer_fingerprints_to(hanging_object)
		hanging_object.bolt(user)
		qdel(src)
	else
		balloon_alert(user, "you can only mount it while in your lair!")


/// Blood mirror, allows bloodsuckers to remotely observe their vassals. Vassals being observed gain red eyes.
/// Lots of code from regular mirrors has been copied over here for obvious reasons.
/obj/structure/bloodsucker/mirror
	name = "scarlet mirror"
	desc = "It bleeds with visions of a world rendered in red."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_mirror"
	movement_type = FLOATING
	density = FALSE
	anchored = TRUE
	integrity_failure = 0.5
	max_integrity = 200
	vamp_desc = "This is a blood mirror, it will allow you to see through the eyes of your vassals remotely (though it will cause said eyes to redden as a side effect.) \n\
		It is warded against usage by unvassalized mortals with teleportation magic that can rend psyches asunder at the cost of its own integrity."
	vassal_desc = "This is a magical blood mirror that Bloodsuckers alone may use to watch over their devotees.\n\
		Those unworthy of the mirror who haven't been sworn to the service of a Bloodsucker may anger it if they attempt to use it."
	light_system = OVERLAY_LIGHT //It glows a bit when in use.
	light_range = 2
	light_power = 1.5
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_on = FALSE

	/// Boolean indicating whether or not the mirror is actively being used to observe someone.
	var/in_use = FALSE
	/// The mob currently using the mirror to observe someone (if any.)
	var/mob/living/carbon/human/current_user = null
	/// The mob currently being observed by someone using the mirror (if any.)
	var/mob/living/carbon/human/current_observed = null
	/// The typepath of the action used to stop observing someone with the mirror.
	var/datum/action/innate/mirror/observe_stop/stop_observe = /datum/action/innate/mirror/observe_stop
	/// The typepath of the action used to change the person observed while the mirror is active.
	var/datum/action/innate/mirror/observe_change/change_observe = /datum/action/innate/mirror/observe_change
	/// The original left eye color of the mob being observed.
	var/original_eye_color_left
	/// The original right eye color of the mob being observed.
	var/original_eye_color_right
	/// Boolean indicating whether or not the mirror is angry (see 'proc/katabasis' for more info.)
	var/mirror_will_not_forget_this = FALSE

/obj/structure/bloodsucker/mirror/Initialize(mapload)
	. = ..()
	var/static/list/reflection_filter = alpha_mask_filter(icon = icon('fulp_modules/icons/antagonists/bloodsuckers/vamp_obj.dmi', "blood_mirror_mask"))
	var/static/matrix/reflection_matrix = matrix(0.75, 0, 0, 0, 0.75, 0)
	var/datum/callback/can_reflect = CALLBACK(src, PROC_REF(can_reflect))
	var/list/update_signals = list(COMSIG_ATOM_BREAK)

	AddComponent(/datum/component/reflection, reflection_filter = reflection_filter, reflection_matrix = reflection_matrix, can_reflect = can_reflect, update_signals = update_signals)
	register_context()
	change_observe = new change_observe(src)
	stop_observe = new stop_observe(src)

/obj/structure/bloodsucker/mirror/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(in_use)
		stop_observing(current_user, current_observed)
	QDEL_NULL(stop_observe)

/obj/structure/bloodsucker/mirror/examine(mob/user)
	. = ..()
	if(in_use)
		. += span_cult_bold("It's glowing ominously and [current_user] is staring into it!")

/obj/structure/bloodsucker/mirror/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(IS_BLOODSUCKER(user) && broken && in_range(source, user))
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Clear Up"
		return CONTEXTUAL_SCREENTIP_SET

/// Default 'click_alt()' interaction overriden since mirrors are a unique case.
/obj/structure/bloodsucker/mirror/click_alt(mob/user)
	if(user == owner && user.Adjacent(src))
		if(broken)
			balloon_alert(user, "clear up [src]?")
		else
			balloon_alert(user, "unsecure [src]?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				if(broken) //Clear up broken mirrors by "gibbing" them.
					new /obj/effect/gibspawner/generic(src.loc)
					qdel(src)
				else
					new /obj/item/wallframe/blood_mirror(src.loc)
					playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
					user.visible_message(span_notice("[user.name] removes [src] from the wall."),
					span_notice("You remove [src] from the wall."),
					span_hear("You hear clicking."))
					qdel(src)

/// Copied from 'mirror/proc/can_reflect()'
/obj/structure/bloodsucker/mirror/proc/can_reflect(atom/movable/target)
	if(atom_integrity <= integrity_failure * max_integrity)
		return FALSE
	if(broken || !isliving(target) || HAS_TRAIT(target, TRAIT_NO_MIRROR_REFLECTION))
		return FALSE
	return TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/bloodsucker/mirror, 28)

/obj/structure/bloodsucker/mirror/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	bolt()

/obj/structure/bloodsucker/mirror/broken
	icon_state = "blood_mirror_broken"

/obj/structure/bloodsucker/mirror/broken/Initialize(mapload)
	. = ..()
	atom_break(null, mapload)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/bloodsucker/mirror/broken, 28)

/obj/structure/bloodsucker/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken)
		return
	src.visible_message(span_warning("Blood spews out of the mirror as it breaks!"))
	if(!owner && !mapload) //If we don't have an owner then just clear ourself up completely.
		new /obj/effect/gibspawner/generic(src.loc)
		qdel(src)
		return //This return might not be necessary since we've already qdel'd the mirror... idk
	icon_state = "blood_mirror_broken"
	if(!mapload)
		playsound(src, SFX_SHATTER, 70, TRUE)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 60, TRUE)
	if(desc == initial(desc))
		desc = "It's a suspended pool of darkened fragments resembling a scab."

	new /obj/effect/decal/cleanable/blood/splatter(src.loc)
	broken = TRUE

/**
 * Proc used by blood mirrors to allow a user to see from the perspective of a target.
 *
 * Made using 'dullahan.dm', '_machinery.dm', 'camera_advanced.dm', 'drug_effects.dm', and a lot of
 * other files as references.
 */
/obj/structure/bloodsucker/mirror/proc/begin_observing(mob/living/carbon/human/user, mob/living/carbon/human/observed)
	if(!observed)
		balloon_alert(user, "chosen vassal doesn't exist!")
		return

	if(!check_observability(user, observed))
		return

	user.reset_perspective(observed, TRUE)
	original_eye_color_left = observed.eye_color_left
	original_eye_color_right = observed.eye_color_right
	observed.eye_color_left = BLOODCULT_EYE
	observed.eye_color_right = BLOODCULT_EYE
	observed.update_body()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(length(bloodsuckerdatum.vassals) > 1)
		change_observe.Grant(user)
	stop_observe.Grant(user)

	START_PROCESSING(SSobj, src)
	user.add_client_colour(/datum/client_colour/glass_colour/red)
	set_light_on(TRUE)

	bloodsuckerdatum.blood_structure_in_use = src
	in_use = TRUE
	icon_state = "blood_mirror_active"
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 25, frequency = 0.75, use_reverb = TRUE)
	current_user = user
	current_observed = observed

/// Proc used by blood mirrors to stop observing. Arguments default to 'current_user' and 'current_observed'
/obj/structure/bloodsucker/mirror/proc/stop_observing(mob/living/carbon/human/user = current_user, mob/living/carbon/human/observed = current_observed)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)

	user.reset_perspective()
	change_observe.Remove(user)
	stop_observe.Remove(user)
	STOP_PROCESSING(SSobj, src)
	user.remove_client_colour(/datum/client_colour/glass_colour/red)
	set_light_on(FALSE)

	observed.eye_color_left = original_eye_color_left
	observed.eye_color_right = original_eye_color_right
	observed.update_body()

	in_use = FALSE
	if(broken)
		icon_state = "blood_mirror_broken"
	else
		icon_state = /obj/structure/bloodsucker/mirror::icon_state
	playsound(user, 'sound/effects/portal/portal_travel.ogg', 25, frequency = -0.75, use_reverb = TRUE)
	current_user = null
	current_observed = null
	bloodsuckerdatum.blood_structure_in_use = null

/// Proc used by blood mirrors to swap to a different vassal while one is already being observed.
/obj/structure/bloodsucker/mirror/proc/swap_observed(mob/living/carbon/human/new_observed)
	if(!new_observed)
		to_chat(current_user, span_warning("Your chosen vassal doesn't exist!"))
		return

	current_observed.eye_color_left = original_eye_color_left
	current_observed.eye_color_right = original_eye_color_right
	current_observed.update_body()

	original_eye_color_left = new_observed.eye_color_left
	original_eye_color_right = new_observed.eye_color_right
	new_observed.eye_color_left = BLOODCULT_EYE
	new_observed.eye_color_right = BLOODCULT_EYE
	new_observed.update_body()

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = current_user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum.blood_structure_in_use = src

	current_user.reset_perspective(new_observed)
	current_observed = new_observed
	playsound(src, 'sound/effects/portal/portal_travel.ogg', 25, frequency = 0.75, use_reverb = TRUE)

/// Checks if 'current_observed' and 'current_user' meet observability criteria.
/// Returns TRUE only once all checks are passed.
/obj/structure/bloodsucker/mirror/proc/check_observability(mob/living/carbon/human/user = current_user, mob/living/carbon/human/observed = current_observed)
	if(user.stat == DEAD)
		to_chat(user, span_danger("You are dead!"))
		return FALSE

	if(observed.stat == DEAD)
		to_chat(user, span_danger("[observed.name] is dead!"))
		return FALSE

	if(!observed.get_organ_slot(ORGAN_SLOT_EYES))
		balloon_alert(user, span_warning("[observed.name] has no eyes!"))
		return FALSE

	if(broken)
		balloon_alert(user, span_warning("[src] has broken!"))
		return FALSE

	if(!in_range(src, user))
		user.balloon_alert(user, span_warning("you're too far from [src]!"))
		return FALSE

	if(!user.mind.has_antag_datum(/datum/antagonist/bloodsucker)) //Unlikely, but still...
		balloon_alert(user, span_warning("you aren't a bloodsucker anymore!"))
		return FALSE
	return TRUE

/obj/structure/bloodsucker/mirror/process(seconds_per_tick)
	if(!check_observability())
		stop_observing()

/obj/structure/bloodsucker/mirror/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(broken)
		balloon_alert(user, "it's broken!")
		return

	if(IS_BLOODSUCKER(user))
		var/datum/antagonist/bloodsucker/user_bloodsucker_datum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker, FALSE)
		if(!length(user_bloodsucker_datum.vassals))
			balloon_alert(user, "no vassals!")
			return
		if(in_use)
			balloon_alert(user, "already in use!")
			return
		if(user_bloodsucker_datum.blood_structure_in_use)
			balloon_alert(user, "already using a mirror!")
			return

		var/list/vassal_name_list[0]
		for(var/datum/antagonist/vassal/vassal_datum as anything in user_bloodsucker_datum.vassals)
			vassal_name_list[vassal_datum.owner.name] = vassal_datum

		var/chosen
		if(length(vassal_name_list) > 1)
			chosen = tgui_input_list(user, "Select a vassal to watch over...", "Vassal Observation List", vassal_name_list)
		else
			chosen = vassal_name_list[1]

		if(!chosen)
			balloon_alert(user, "no vassal selected!")
			return

		var/datum/antagonist/vassal/chosen_datum = vassal_name_list[chosen]
		var/mob/chosen_datum_current = chosen_datum.owner.current
		if(chosen_datum_current.stat == DEAD)
			balloon_alert(user, "[chosen_datum_current.name] is dead!")
			return

		begin_observing(user, chosen_datum_current)
		return


	if(IS_VASSAL(user))
		balloon_alert(user, "you don't know how to use it!")
		return


	if(mirror_will_not_forget_this)
		katabasis(user, TRUE)
		return

	to_chat(user, span_warning("You peer deeply into [src], but the reflection you see is not your own. You are stunned as <b>it begins reaching towards you...</b>"))

	var/mob/living/carbon/human/victim = user //(Just for code readability purposes.)
	var/original_victim_loc = victim.loc
	victim.Stun(6 SECONDS, TRUE)
	victim.playsound_local(get_turf(victim), 'sound/music/antag/bloodcult/ghost_whisper.ogg', 20, frequency = 5)
	flash_color(victim, flash_time = 80) //Defaults to cult stun flash, which fits here.
	sleep(5 SECONDS)//Wait five seconds and then...

	if(broken)		//...return if the mirror is broken...
		return
	if(!src)		//...return if the mirror has been completely destroyed...
		return
	if(victim.loc != original_victim_loc) //...return and become angry if the victim has been moved...
		visible_message(span_warning("A dark red silhouette appears in [src], but as it bangs against the glass in vain."))
		mirror_will_not_forget_this = TRUE
		playsound('sound/effects/glass/glasshit.ogg')
		return

	katabasis(victim) //...make the victim undergo katabasis otherwise.

/**
 * The mirror is trapped, and this proc represents the trap's effects.
 * In short, it will deal moderate damage to its victim, teleport them to a random (mostly safe) location on the station,
 * give them a deep-rooted fear of blood, give them a severe negative moodlet, and then shatter itself.
 *
 * * victim - The person affected by this proc.
 * * aggressive - Increases mirror damage if true.
 */
/obj/structure/bloodsucker/mirror/proc/katabasis(mob/living/carbon/human/victim, var/aggressive = FALSE)
	//Damage
	if((victim.maxHealth - victim.get_total_damage()) >= victim.crit_threshold)
		var/refined_damage_amount = (victim.maxHealth - victim.get_total_damage()) * (aggressive ? 0.45 : 0.35)
		victim.adjustBruteLoss(refined_damage_amount)

	//Break mirror
	atom_break()

	//Flavor
	var/turf/victim_turf = get_turf(victim)
	playsound(victim_turf, 'sound/effects/hallucinations/veryfar_noise.ogg', 100, frequency = 1.25, use_reverb = TRUE)
	victim.visible_message(span_danger("A red hand erupts from [src], dragging [victim.name] away through broken glass!"),
	span_bolddanger(span_big("A crimson palm envelops your face, and with a horrible jolt it pulls you into [src]!")),
	span_warning("You briefly hear the sound of glass breaking accompanied by an eerie, almost fluid gust and a sudden thump!"),
	)

	//Find a reasonable/safe area and teleport the victim to it
	var/turf/target_turf = get_safe_random_station_turf(typesof(/area/station/commons))
	if(!target_turf)
		target_turf = get_safe_random_station_turf(typesof(/area/station/hallway))
	if(!target_turf)
		target_turf = get_safe_random_station_turf()

	do_teleport(victim, target_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE)

	//Nightmare, trauma, and mood event
	victim.playsound_local(get_turf(victim), 'sound/music/antag/bloodcult/ghost_whisper.ogg', 5, frequency = 0.75)
	victim.Sleeping(6 SECONDS)
	sleep(6 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...you were dragged through an infinite expanse of carmine..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...within it all things were stagnant— clotting to no end..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("...this place was where those of ages old once claimed their vitality..."))
	sleep(5 SECONDS)

	victim.Sleeping(5 SECONDS)
	to_chat(victim, span_warning("<b>...and soon, you're sure, those claims will be renewed.</b>"))
	victim.playsound_local(get_turf(victim), 'sound/effects/blob/blobattack.ogg', 60, frequency = -1)
	victim.gain_trauma(/datum/brain_trauma/mild/phobia/blood, TRAUMA_RESILIENCE_LOBOTOMY)
	victim.add_mood_event("blood_mirror", /datum/mood_event/bloodmirror)


/// The parent action datum for blood mirror action buttons.
/// (Mainly used for the icon changes.)
/datum/action/innate/mirror
	background_icon = 'modular_meta/features/antagonists/icons/bloodsuckers/bloodsucker_status_effects.dmi'
	background_icon_state = "template"

	button_icon = 'modular_meta/features/antagonists/icons/bloodsuckers/action_bloodsucker.dmi'

	overlay_icon = 'modular_meta/features/antagonists/icons/bloodsuckers/bloodsucker_status_effects.dmi'
	overlay_icon_state = "template_border"

/// The action button that allows players to stop using blood mirrors.
/datum/action/innate/mirror/observe_stop
	name = "Stop Overseeing"
	button_icon_state = "blind"

/datum/action/innate/mirror/observe_stop/Activate()
	var/datum/antagonist/bloodsucker/bloodsucker_datum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/obj/structure/bloodsucker/mirror/our_mirror = bloodsucker_datum.blood_structure_in_use

	if(!our_mirror)
		return

	our_mirror.stop_observing(our_mirror.current_user, our_mirror.current_observed)


/// The action button that allows players to change their observed vassal at an active blood mirror.
/datum/action/innate/mirror/observe_change
	name = "Swap Overseen"
	button_icon_state = "look"

/datum/action/innate/mirror/observe_change/Activate()
	var/datum/antagonist/bloodsucker/bloodsucker_datum = owner.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/obj/structure/bloodsucker/mirror/our_mirror = bloodsucker_datum.blood_structure_in_use

	if(!our_mirror)
		return

	var/list/vassal_name_list[0]
	for(var/datum/antagonist/vassal/vassal_datum as anything in bloodsucker_datum.vassals)
		vassal_name_list[vassal_datum.owner.name] = vassal_datum
	// Remove the one we're already observing...
	vassal_name_list.Remove(our_mirror.current_observed.name)

	var/chosen_vassal
	if(length(vassal_name_list) > 1)
		chosen_vassal = tgui_input_list(owner, "Select a different vassal to watch over...", "Vassal Observation List", vassal_name_list)
	else
		chosen_vassal = vassal_name_list[1]

	if(!chosen_vassal)
		return

	var/datum/antagonist/vassal/new_observed = vassal_name_list[chosen_vassal]
	var/mob/living/carbon/human/new_observed_current = new_observed.owner.current
	if(our_mirror.check_observability(owner, new_observed_current))
		our_mirror.swap_observed(new_observed_current)
