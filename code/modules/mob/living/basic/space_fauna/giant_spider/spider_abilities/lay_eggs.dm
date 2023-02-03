/datum/action/innate/spider/lay_eggs
	name = "Lay Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into a normal spider."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "lay_eggs"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS
	///How long it takes for a broodmother to lay eggs.
	var/egg_lay_time = 12 SECONDS
	///The type of egg we create
	var/egg_type = /obj/effect/mob_spawn/ghost_role/spider

/datum/action/innate/spider/lay_eggs/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_status_on_signal))

/datum/action/innate/spider/lay_eggs/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))

/datum/action/innate/spider/lay_eggs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!isspider(owner))
		return FALSE
	if(DOING_INTERACTION(owner, INTERACTION_SPIDER_KEY))
		return FALSE
	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
	if(eggs)
		if (feedback)
			owner.balloon_alert(owner, "already eggs here!")
		return FALSE
	return TRUE

/datum/action/innate/spider/lay_eggs/Activate()
	owner.visible_message(
		span_notice("[owner] begins to lay a cluster of eggs."),
		span_notice("You begin to lay a cluster of eggs."),
	)


	var/mob/living/simple_animal/animal_owner = owner
	if(istype(animal_owner))
		animal_owner.stop_automated_movement = TRUE

	if(do_after(owner, egg_lay_time, target = get_turf(owner), interaction_key = INTERACTION_SPIDER_KEY))
		var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
		if(eggs)
			owner.balloon_alert(owner, "already eggs here!")
		else
			lay_egg()
		build_all_button_icons(UPDATE_BUTTON_STATUS)

	if(istype(animal_owner))
		animal_owner.stop_automated_movement = FALSE

/datum/action/innate/spider/lay_eggs/proc/lay_egg()
	var/obj/effect/mob_spawn/ghost_role/spider/new_eggs = new egg_type(get_turf(owner))
	new_eggs.faction = owner.faction
	var/datum/action/set_spider_directive/spider_command = locate() in owner.actions
	if (spider_command)
		new_eggs.directive = spider_command.current_directive

/datum/action/innate/spider/lay_eggs/enriched
	name = "Lay Enriched Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into a greater spider.  Requires you drain a human per cluster of these eggs."
	button_icon_state = "lay_enriched_eggs"
	egg_type = /obj/effect/mob_spawn/ghost_role/spider/enriched
	/// How many charges we have to make eggs
	var/charges = 0

/datum/action/innate/spider/lay_eggs/enriched/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if (charges <= 0)
		if (feedback)
			owner.balloon_alert(owner, "must feed first!")
		return FALSE
	return TRUE

/datum/action/innate/spider/lay_eggs/enriched/lay_egg()
	charges--
	return ..()
