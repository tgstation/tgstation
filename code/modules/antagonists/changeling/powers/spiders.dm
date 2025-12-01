/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating a cluster of eggs which will grow into a deadly arachnid. Costs 45 chemicals."
	helptext = "The spiders are ruthless creatures, and may attack their creators when fully grown. Requires at least 3 DNA absorptions."
	button_icon_state = "spread_infestation"
	chemical_cost = 45
	dna_cost = 1
	req_absorbs = 3

// Ensures that you cannot horrifically cheese the game by spawning spiders while in the vents
/datum/action/changeling/spiders/can_be_used_by(mob/living/user)
	if (!isopenturf(user.loc))
		var/turf/user_turf = get_turf(user)
		user_turf.balloon_alert(user, "not enough space!")
		return FALSE
	return ..()

//Makes a spider egg cluster. Allows you enable further general havok by introducing spiders to the station.
/datum/action/changeling/spiders/sting_action(mob/user)
	..()
	new /obj/effect/mob_spawn/ghost_role/spider/bloody(user.loc)
	return TRUE
