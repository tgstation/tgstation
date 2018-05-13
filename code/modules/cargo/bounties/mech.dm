/datum/bounty/item/mech/New()
	description = "Upper management has requested a [name] mech be sent as soon as possible. Ship one, and receive bonus payment on top of the export payment."
	reward = 8000

/datum/bounty/item/mech/ship(obj/O)
	if(!applies_to(O))
		return
	if(istype(O, /obj/mecha))
		var/obj/mecha/M = O
		M.wreckage = null // So the mech doesn't explode.

/datum/bounty/item/mech/ripley
	name = "APLU \"Ripley\""
	wanted_types = list(/obj/mecha/working/ripley)

/datum/bounty/item/mech/odysseus
	name = "Odysseus"
	wanted_types = list(/obj/mecha/medical/odysseus)

/datum/bounty/item/mech/gygax
	name = "Gygax"
	wanted_types = list(/obj/mecha/combat/gygax)

/datum/bounty/item/mech/durand
	name = "Durand"
	wanted_types = list(/obj/mecha/combat/durand)

/datum/bounty/item/mech/durand
	name = "Phazon"
	wanted_types = list(/obj/mecha/combat/phazon)

