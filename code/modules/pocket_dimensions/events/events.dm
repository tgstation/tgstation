/datum/pocket_event/emp_on_break
	name = "Emp on touch"
	desc = "Creates an emp pulse when floor or wall is destroyed."

/datum/pocket_event/emp_on_break/on_bump(datum/pocket_dim_customizer/dim,datum/og_source)
	if(!isturf(og_source))
		return
	var/turf/blast = og_source
	empulse(blast, 2, 4, 1)

/datum/pocket_event/explosion
	name = "Explode on touch"
	desc = "Creates an emp pulse when floor or wall is destroyed."

/datum/pocket_event/explosion/on_bump(datum/pocket_dim_customizer/dim,datum/og_source)
	if(!isturf(og_source))
		return
	var/turf/blast = og_source
	explosion(blast, 0, 1, 2, 3)

/datum/pocket_event/collapse
	name = "Collapse on breach"
	desc = "Collapses the room when the wall is broken"

/datum/pocket_event/explosion/on_breach(datum/pocket_dim_customizer/dim,turf/cause)
	dim.strip_pocket_dimension()

