/datum/action/cooldown/mob_cooldown/spit_ore
	name = "Spit Ore"
	desc = "Vomit out all of your consumed ores."
	click_to_activate = FALSE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/mob_cooldown/spit_ore/IsAvailable(feedback)
	var/mob/living/basic/mining/goldgrub/grub_owner = owner
	if(grub_owner.burrowed)
		if(feedback)
			grub_owner.balloon_alert(grub_owner, "currently underground!")
		return FALSE

	if(!length(grub_owner.contents))
		if(feedback)
			grub_owner.balloon_alert(grub_owner, "no ores to spit!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/spit_ore/Activate()
	var/mob/living/basic/mining/goldgrub/grub_owner = owner
	grub_owner.barf_contents()
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/burrow
	name = "Burrow"
	desc = "Burrow under soft ground, evading predators and increasing your speed."
	cooldown_time = 7 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/burrow/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	var/turf/location = get_turf(owner)
	if(!isasteroidturf(location) && !ismineralturf(location))
		if(feedback)
			owner.balloon_alert(owner, "available only on mining floor or wall!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/burrow/Activate()
	var/mob/living/basic/mining/goldgrub/grub_owner = owner
	var/obj/effect/dummy/phased_mob/holder = null
	var/turf/current_loc = get_turf(owner)
	if(!do_after(owner, 3 SECONDS, target = current_loc))
		owner.balloon_alert(owner, "need to stay still!")
		return
	if(get_turf(owner) != current_loc)
		to_chat(owner, span_warning("Action cancelled, as you moved while reappearing."))
		return
	if(!grub_owner.burrowed)
		owner.visible_message(span_danger("[owner] buries into the ground, vanishing from sight!"))
		playsound(get_turf(owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(current_loc, owner)
		grub_owner.burrowed = TRUE
		return TRUE
	holder = owner.loc
	holder.eject_jaunter()
	holder = null
	grub_owner.burrowed = FALSE
	owner.visible_message(span_danger("[owner] emerges from the ground!"))
	if(ismineralturf(current_loc))
		var/turf/closed/mineral/mineral_turf = current_loc
		mineral_turf.gets_drilled(owner)
	playsound(current_loc, 'sound/effects/break_stone.ogg', 50, TRUE, -1)
	StartCooldown()
	return TRUE
