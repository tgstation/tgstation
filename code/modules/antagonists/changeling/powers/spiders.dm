/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating a cluster of eggs which will grow into a deadly arachnid. Costs 45 chemicals."
	helptext = "The spiders are ruthless creatures, and may attack their creators when fully grown. Requires at least 3 DNA absorptions."
	button_icon_state = "spread_infestation"
	chemical_cost = 45
	dna_cost = 1
	req_absorbs = 3

//Makes a spider egg cluster. Allows you enable further general havok by introducing spiders to the station.
/datum/action/changeling/spiders/sting_action(mob/user)
	..()
	new /obj/effect/mob_spawn/ghost_role/spider/bloody(user.loc)
	return TRUE
