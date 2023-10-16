/datum/action/cooldown/mob_cooldown/lay_eggs
	name = "Lay Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into a normal spider."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "lay_eggs"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	cooldown_time = 0
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE
	///How long it takes for a broodmother to lay eggs.
	var/egg_lay_time = 4 SECONDS
	///The type of egg we create
	var/egg_type = /obj/effect/mob_spawn/ghost_role/spider

/datum/action/cooldown/mob_cooldown/lay_eggs/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED), PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/lay_eggs/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_MOVABLE_MOVED, COMSIG_DO_AFTER_BEGAN, COMSIG_DO_AFTER_ENDED))

/datum/action/cooldown/mob_cooldown/lay_eggs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(DOING_INTERACTION(owner, DOAFTER_SOURCE_SPIDER))
		if (feedback)
			owner.balloon_alert(owner, "busy!")
		return FALSE
	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
	if(eggs)
		if (feedback)
			owner.balloon_alert(owner, "already eggs here!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/lay_eggs/Activate(atom/target)
	owner.balloon_alert_to_viewers("laying eggs...")
	StartCooldown(360 SECONDS, 360 SECONDS)
	if(!do_after(owner, egg_lay_time, target = get_turf(owner), interaction_key = DOAFTER_SOURCE_SPIDER))
		owner.balloon_alert(owner, "interrupted!")
		StartCooldown(0 SECONDS)
		return
	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(owner)
	if(eggs)
		owner.balloon_alert(owner, "already eggs here!")
	else
		lay_egg()
	StartCooldown()

/datum/action/cooldown/mob_cooldown/lay_eggs/proc/lay_egg()
	var/obj/effect/mob_spawn/ghost_role/spider/new_eggs = new egg_type(get_turf(owner))
	new_eggs.faction = owner.faction
	var/datum/action/cooldown/mob_cooldown/set_spider_directive/spider_directive = locate() in owner.actions
	if (spider_directive)
		new_eggs.directive = spider_directive.current_directive

/datum/action/cooldown/mob_cooldown/lay_eggs/enriched
	name = "Lay Enriched Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into a greater spider.  Requires you drain a human per cluster of these eggs."
	button_icon_state = "lay_enriched_eggs"
	egg_type = /obj/effect/mob_spawn/ghost_role/spider/enriched
	/// How many charges we have to make eggs
	var/charges = 0

/datum/action/cooldown/mob_cooldown/lay_eggs/enriched/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if (charges <= 0)
		if (feedback)
			owner.balloon_alert(owner, "must feed first!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/lay_eggs/enriched/lay_egg()
	charges--
	return ..()
