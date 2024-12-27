/datum/bounty/item/mech/New()
	..()
	description = "Upper management has requested one [name] mech be sent as soon as possible. Ship it to receive a large payment."

/datum/bounty/item/mech/ship(obj/shipped)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/mecha/mecha = shipped
	mecha.wreckage = null // So the mech doesn't explode.

/datum/bounty/item/mech/ripleymk2
	name = "APLU MK-II \"Ripley\""
	reward = CARGO_CRATE_VALUE * 26
	wanted_types = list(/obj/vehicle/sealed/mecha/ripley/mk2 = TRUE)

/datum/bounty/item/mech/clarke
	name = "Clarke"
	reward = CARGO_CRATE_VALUE * 32
	wanted_types = list(/obj/vehicle/sealed/mecha/clarke = TRUE)

/datum/bounty/item/mech/odysseus
	name = "Odysseus"
	reward = CARGO_CRATE_VALUE * 22
	wanted_types = list(/obj/vehicle/sealed/mecha/odysseus = TRUE)

/datum/bounty/item/mech/gygax
	name = "Gygax"
	reward = CARGO_CRATE_VALUE * 56
	wanted_types = list(/obj/vehicle/sealed/mecha/gygax = TRUE)

/datum/bounty/item/mech/durand
	name = "Durand"
	reward = CARGO_CRATE_VALUE * 40
	wanted_types = list(/obj/vehicle/sealed/mecha/durand = TRUE)
