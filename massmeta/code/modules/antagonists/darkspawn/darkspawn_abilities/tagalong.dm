//Melds with a mob's shadow, allowing the caster to "shadow" (HA) them while they're not in darkness.
/datum/action/innate/darkspawn/tagalong
	name = "Tagalong"
	id = "tagalong"
	desc = "Melds with a target's shadow, causing you to invisibly follow them. Only works in lit areas, and you will be forced out if you hold any items. Costs 30 Psi."
	button_icon_state = "tagalong"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 30
	psi_addendum = ", but is free to cancel"
	lucidity_price = 2
	var/datum/status_effect/tagalong/tagalong

/datum/action/innate/darkspawn/tagalong/IsAvailable(feedback = FALSE)
	if(istype(owner, /mob/living/simple_animal/hostile/crawling_shadows))
		return
	return ..()

/datum/action/innate/darkspawn/tagalong/process()
	psi_cost = 30 * isnull(tagalong)

/datum/action/innate/darkspawn/tagalong/Activate()
	if(tagalong)
		QDEL_NULL(tagalong)
		return
	if(owner.get_active_held_item() || owner.get_inactive_held_item())
		to_chat(owner, span_warning("Your hands must be empty to accompany someone!"))
		return
	var/list/targets = list()
	var/mob/living/target
	var/turf/T
	for(var/mob/living/L in range(7, owner) - owner)
		T = get_turf(L)
		if(!isdarkspawn(L) && L.stat != DEAD && T.get_lumcount() >= DARKSPAWN_DIM_LIGHT)
			targets += L
	if(!targets.len)
		to_chat(owner, span_warning("There is nobody nearby in any lit areas!"))
		return
	if(targets.len == 1)
		target = targets[1]
	else
		target = input(owner, "Choose a target to accompany.", "Tagalong") as null|anything in targets
		if(!target)
			return
	var/mob/living/L = owner
	tagalong = L.apply_status_effect(STATUS_EFFECT_TAGALONG, target)
	to_chat(owner, "<span class='velvet'><b>iahz</b><br>\
	You slip into [target]'s shadow. This will last five minutes, until canceled, or you are forced out.</span>")
	owner.forceMove(target)
	return TRUE
