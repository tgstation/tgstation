/// Make a sticky web under yourself for area fortification
/datum/action/cooldown/mob_cooldown/lay_web
	name = "Spin Web"
	desc = "Spin a web to slow down potential prey."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "lay_web"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	cooldown_time = 0 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE
	/// How long it takes to lay a web
	var/webbing_time = 4 SECONDS

/datum/action/cooldown/mob_cooldown/lay_web/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/lay_web/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))

/datum/action/cooldown/mob_cooldown/lay_web/IsAvailable(feedback = FALSE)
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
	if(HAS_TRAIT(owner.loc, TRAIT_SPINNING_WEB_TURF))
		if (feedback)
			owner.balloon_alert(owner, "already being webbed!")
		return FALSE
	if(obstructed_by_other_web())
		if (feedback)
			owner.balloon_alert(owner, "already webbed!")
		return FALSE
	return TRUE

/// Returns true if there's a web we can't put stuff on in our turf
/datum/action/cooldown/mob_cooldown/lay_web/proc/obstructed_by_other_web()
	return !!(locate(/obj/structure/spider/stickyweb) in get_turf(owner))

/datum/action/cooldown/mob_cooldown/lay_web/Activate()
	. = ..()
	var/turf/spider_turf = get_turf(owner)
	var/obj/structure/spider/stickyweb/web = locate() in spider_turf
	if(web)
		owner.balloon_alert_to_viewers("sealing web...")
	else
		owner.balloon_alert_to_viewers("spinning web...")
	ADD_TRAIT(spider_turf, TRAIT_SPINNING_WEB_TURF, REF(src))
	if(do_after(owner, webbing_time, target = spider_turf, interaction_key = DOAFTER_SOURCE_SPIDER) && owner.loc == spider_turf)
		plant_web(spider_turf, web)
	else
		owner?.balloon_alert(owner, "interrupted!") // Null check because we might have been interrupted via being disintegrated
	REMOVE_TRAIT(spider_turf, TRAIT_SPINNING_WEB_TURF, REF(src))
	build_all_button_icons()

/// Creates a web in the current turf
/datum/action/cooldown/mob_cooldown/lay_web/proc/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb(target_turf)

/// Variant for genetics, created webs only allow the creator passage
/datum/action/cooldown/mob_cooldown/lay_web/genetic
	desc = "Spin a web. Only you will be able to traverse your web easily."
	cooldown_time = 4 SECONDS //the same time to lay a web

/datum/action/cooldown/mob_cooldown/lay_web/genetic/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb/genetic(target_turf, owner)

/// Variant which allows webs to be stacked into walls
/datum/action/cooldown/mob_cooldown/lay_web/sealer
	desc = "Spin a web to slow down potential prey. Webs can be stacked to make solid structures."

/datum/action/cooldown/mob_cooldown/lay_web/sealer/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	if (existing_web)
		qdel(existing_web)
		new /obj/structure/spider/stickyweb/sealed(target_turf)
		return
	new /obj/structure/spider/stickyweb(target_turf)

/datum/action/cooldown/mob_cooldown/lay_web/sealer/obstructed_by_other_web()
	return !!(locate(/obj/structure/spider/stickyweb/sealed) in get_turf(owner))

/datum/action/cooldown/mob_cooldown/lay_web/solid_web
	name = "Spin Solid Web"
	desc = "Spin a web to obstruct potential prey."
	button_icon_state = "lay_solid_web"
	cooldown_time = 0 SECONDS
	webbing_time = 5 SECONDS

/datum/action/cooldown/mob_cooldown/lay_web/solid_web/obstructed_by_other_web()
	return !!(locate(/obj/structure/spider/solid) in get_turf(owner))

/datum/action/cooldown/mob_cooldown/lay_web/solid_web/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/solid(target_turf)

/datum/action/cooldown/mob_cooldown/lay_web/web_passage
	name = "Spin Web Passage"
	desc = "Spin a web passage to hide the nest from prey view."
	button_icon_state = "lay_web_passage"
	cooldown_time = 0 SECONDS
	webbing_time = 4 SECONDS

/datum/action/cooldown/mob_cooldown/lay_web/web_passage/obstructed_by_other_web()
	return !!(locate(/obj/structure/spider/passage) in get_turf(owner))

/datum/action/cooldown/mob_cooldown/lay_web/web_passage/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/passage(target_turf)


/datum/action/cooldown/mob_cooldown/lay_web/sticky_web
	name = "Spin Sticky Web"
	desc = "Spin a sticky web to trap intruders."
	button_icon_state = "lay_sticky_web"
	cooldown_time = 20 SECONDS
	webbing_time = 3 SECONDS

/datum/action/cooldown/mob_cooldown/lay_web/sticky_web/obstructed_by_other_web()
	return !!(locate(/obj/structure/spider/sticky) in get_turf(owner))

/datum/action/cooldown/mob_cooldown/lay_web/sticky_web/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/sticky(target_turf)

/datum/action/cooldown/mob_cooldown/lay_web/web_spikes
	name = "Spin Web Spikes"
	desc = "Extrude silk spikes to dissuade invaders."
	button_icon_state = "lay_web_spikes"
	cooldown_time = 40 SECONDS
	webbing_time = 3 SECONDS

/datum/action/cooldown/mob_cooldown/lay_web/web_spikes/obstructed_by_other_web()
	return !!(locate(/obj/structure/spider/spikes) in get_turf(owner))

/datum/action/cooldown/mob_cooldown/lay_web/web_spikes/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/spikes(target_turf)

/// Makes a solid statue which you can use as cover
/datum/action/cooldown/mob_cooldown/web_effigy
	name = "Web Effigy"
	desc = "Shed durable webbing in the shape of your body. It is intimidating and can obstruct attackers. \
		It will decay after some time."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "shed_web_carcass"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	cooldown_time = 60 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/web_effigy/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "invalid location!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/web_effigy/Activate()
	new /obj/structure/spider/effigy(get_turf(owner))
	return ..()
