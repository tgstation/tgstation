/datum/blobtype/multiplex
	var/list/blobtypes
	var/typeshare

/datum/blobtype/multiplex/New(list/blobtypes)
	for (var/bt in blobtypes)
		if (ispath(bt))
			src.blobtypes |= new bt()
		else if (istype(bt, /datum/blobtype))
			src.blobtypes += bt
	 typeshare = (0.8 * length(src.blobtypes)) - (length(src.blobtypes)-1) // 1 is 80%, 2 are 60% etc

/datum/blobtype/multiplex/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag, coefficient = 1) //when the blob takes damage, do this
	for (var/datum/blobtype/bt in blobtypes)
		. += bt.damage_reaction(B, damage, damage_type, damage_flag, coefficient*typeshare)

/datum/blobtype/multiplex/death_reaction(obj/structure/blob/B, damage_flag, coefficient = 1) //when a blob dies, do this
	for (var/datum/blobtype/bt in blobtypes)
		. += bt.death_reaction(B, damage_flag, coefficient*typeshare)

/datum/blobtype/multiplex/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O, coefficient = 1) //when the blob expands, do this
	for (var/datum/blobtype/bt in blobtypes)
		. += bt.expand_reaction(B, newB, T, O, coefficient*typeshare)

/datum/blobtype/multiplex/tesla_reaction(obj/structure/blob/B, power, coefficient = 1) //when the blob is hit by a tesla bolt, do this
	for (var/datum/blobtype/bt in blobtypes)
		. += bt.tesla_reaction(B, power, coefficient*typeshare)
	if (prob(. / length(blobtypes) * 100))
		return 1

/datum/blobtype/multiplex/extinguish_reaction(obj/structure/blob/B, coefficient = 1) //when the blob is hit with water, do this
	for (var/datum/blobtype/bt in blobtypes)
		. += bt.extinguish_reaction(B, coefficient*typeshare)

/datum/blobtype/multiplex/emp_reaction(obj/structure/blob/B, severity, coefficient = 1) //when the blob is hit with an emp, do this
	for (var/datum/blobtype/bt in blobtypes)
		. += bt.emp_reaction(B, severity, coefficient*typeshare)
