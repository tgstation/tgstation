/datum/action/cooldown/spell/jaunt/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"

	range = 1

/datum/action/cooldown/spell/jaunt/bloodcrawl/cast(mob/living/cast_on)
	. = ..()
	for(var/obj/effect/decal/cleanable/blood_nearby in range(range, get_turf(cast_on)))
		if(blood_nearby.can_bloodcrawl_in())
			perform(blood_nearby, cast_on)
			return

	revert_cast()
	to_chat(user, span_warning("There must be a nearby source of blood!"))

/datum/action/cooldown/spell/jaunt/bloodcrawl/proc/enter_bloodcrawl(obj/effect/decal/cleanable/blood, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = jaunter.phasein(blood)
	else
		. = jaunter.phaseout(blood)

	if(!.)
		revert_cast()
		to_chat(jaunter, span_warning("You are unable to blood crawl!"))
