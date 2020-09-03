/datum/pocket_event/debug
	name = "Debug event"
	desc = "Does literally nothing but scream that it works."

/datum/pocket_event/debug/on_add(datum/pocket_dim_customizer/dim)
	message_admins("This works!")

/datum/pocket_event/emp_on_break
	name = "Emp filled walls"
	desc = "Creates an emp pulse when floor or wall is destroyed."

/datum/pocket_event/emp_on_break/on_bump(datum/source,datum/og_source)
	if(!isturf(og_source))
		return
	var/turf/blast = og_source
	empulse(blast, 2, 4, 1)

/datum/pocket_event/explosion
	name = "Emp filled walls"
	desc = "Creates an emp pulse when floor or wall is destroyed."

/datum/pocket_event/explosion/on_bump(datum/source,datum/og_source)
	if(!isturf(og_source))
		return
	var/turf/blast = og_source
	explosion(blast, 0, 1, 2, 3)
