// Organs.


// Alien organs
/datum/export/organ/alien/get_cost(O, contr = 0, emag = 0)
	. = ..()
	if(emag) // Syndicate really wants some new bio-weapons.
		. *= 2

/datum/export/organ/alien/brain
	cost = 2000
	unit_name = "alien brain"
	export_types = list(/obj/item/organ/brain/alien)

/datum/export/organ/alien/acid
	cost = 1500
	unit_name = "alien acid gland"
	export_types = list(/obj/item/organ/alien/acid)

/datum/export/organ/alien/hivenode
	cost = 2000
	unit_name = "alien hive node"
	export_types = list(/obj/item/organ/alien/hivenode)

/datum/export/organ/alien/neurotoxin
	cost = 2000
	unit_name = "alien neurotoxin gland"
	export_types = list(/obj/item/organ/alien/neurotoxin)

/datum/export/organ/alien/resinspinner
	cost = 1000
	unit_name = "alien resin spinner"

/datum/export/organ/alien/plasmavessel
	cost = 1000
	unit_name = "alien plasma vessel"
	export_types = list(/obj/item/organ/alien/plasmavessel)

/datum/export/organ/alien/plasmavessel/get_cost(obj/item/organ/alien/plasmavessel/P)
	return ..() + (P.max_plasma * 2) + (P.plasma_rate * 20)



/datum/export/organ/alien/embryo
	cost = 5000 // Allows buyer to set up his own alien farm.
	unit_name = "alien embryo"
	export_types = list(/obj/item/organ/body_egg/alien_embryo)

/datum/export/organ/alien/eggsac
	cost = 10000 // Even better than a single embryo.
	unit_name = "alien egg sac"
	export_types = list(/obj/item/organ/alien/eggsac)


// Other alien organs.
/datum/export/organ/alien/abductor
	cost = 2500
	unit_name = "abductor gland"
	export_types = list(/obj/item/organ/gland)

/datum/export/organ/alien/changeling_egg
	cost = 50000 // Holy. Fuck.
	unit_name = "changeling egg"
	export_types = list(/obj/item/organ/body_egg/changeling_egg)


/datum/export/organ/hivelord
	cost = 1500
	unit_name = "active hivelord core"
	export_types = list(/obj/item/organ/hivelord_core)

/datum/export/organ/alien/plasmavessel/get_cost(obj/item/organ/hivelord_core/C)
	if(C.inert)
		return ..() / 3
	if(C.preserved)
		return ..() * 2
	return ..()


// Human organs.

// Do not put human brains here, they are not sellable for a purpose.
// If they would be sellable, X-Porter cannon's finishing move (selling victim's organs) will be instakill with no revive.

/datum/export/organ/human
	contraband = TRUE
	include_subtypes = FALSE

/datum/export/organ/human/heart
	cost = 500
	unit_name = "heart"
	export_types = list(/obj/item/organ/heart)

/datum/export/organ/human/lungs
	cost = 400
	unit_name = "pair"
	message = "of lungs"
	export_types = list(/obj/item/organ/lungs)

/datum/export/organ/human/appendix
	cost = 50
	unit_name = "appendix"
	export_types = list(/obj/item/organ/appendix)

/datum/export/organ/human/appendix/get_cost(obj/item/organ/appendix/O)
	if(O.inflamed)
		return 0
	return ..()