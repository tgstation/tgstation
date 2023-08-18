/datum/action/cooldown/mob_cooldown/spit_ore
	name = "Spit Ore"
	desc = "Vomit out all of your consumed ores."
	click_to_activate = FALSE
	cooldown_time = 5 SECONDS

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
	/// are we currently burrowed
	var/burrowed = FALSE

/datum/action/cooldown/mob_cooldown/burrow/IsAvailable(feedback)
	. = ..()
	if (!.)
		return FALSE
	var/turf/location = get_turf(owner)
	if(!isasteroidturf(location))
		to_chat(owner, span_warning("You can only burrow in and out of mining turfs!"))
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/burrow/Activate()
	var/obj/effect/dummy/phased_mob/holder = null
	var/turf/current_loc = get_turf(owner)
	if(!do_after(owner, 3 SECONDS, target = current_loc))
		to_chat(owner, span_warning("You must stay still!"))
		return
	if(get_turf(owner) != current_loc)
		to_chat(owner, span_warning("Action cancelled, as you moved while reappearing."))
		return
	if(!burrowed)
		owner.visible_message(span_danger("[owner] buries into the ground, vanishing from sight!"))
		playsound(get_turf(owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
		holder = new /obj/effect/dummy/phased_mob(current_loc, owner)
		burrowed = TRUE
		return TRUE
	holder = owner.loc
	holder.eject_jaunter()
	holder = null
	burrowed = FALSE
	owner.visible_message(span_danger("[owner] emerges from the ground!"))
	playsound(get_turf(owner), 'sound/effects/break_stone.ogg', 50, TRUE, -1)
	StartCooldown()
	return TRUE
