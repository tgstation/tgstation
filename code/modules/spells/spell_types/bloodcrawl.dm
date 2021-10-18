/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	charge_max = 0
	clothes_req = FALSE
	//If you couldn't cast this while phased, you'd have a problem
	phase_allowed = TRUE
	selection_type = "range"
	range = 1
	cooldown_min = 0
	overlay = null
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	var/phased = FALSE

/obj/effect/proc_holder/spell/bloodcrawl/on_lose(mob/living/user)
	if(phased)
		user.phasein(get_turf(user), TRUE)

/obj/effect/proc_holder/spell/bloodcrawl/cast_check(skipcharge = 0,mob/user = usr)
	. = ..()
	if(!.)
		return FALSE
	var/area/noteleport_check = get_area(user)
	if(noteleport_check && noteleport_check.area_flags & NOTELEPORT)
		to_chat(user, span_danger("Some dull, universal force is between you and your other existence, preventing you from blood crawling."))
		return FALSE

/obj/effect/proc_holder/spell/bloodcrawl/choose_targets(mob/user = usr)
	for(var/obj/effect/decal/cleanable/target in range(range, get_turf(user)))
		if(target.can_bloodcrawl_in())
			perform(target)
			return
	revert_cast()
	to_chat(user, span_warning("There must be a nearby source of blood!"))

/obj/effect/proc_holder/spell/bloodcrawl/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(istype(user, /mob/living/simple_animal/hostile/imp/slaughter))
			var/mob/living/simple_animal/hostile/imp/slaughter/slaught = user
			slaught.current_hitstreak = 0
			slaught.wound_bonus = initial(slaught.wound_bonus)
			slaught.bare_wound_bonus = initial(slaught.bare_wound_bonus)
		if(phased)
			if(user.phasein(target))
				phased = FALSE
		else
			if(user.phaseout(target))
				phased = TRUE
		start_recharge()
		return
	revert_cast()
	to_chat(user, span_warning("You are unable to blood crawl!"))
