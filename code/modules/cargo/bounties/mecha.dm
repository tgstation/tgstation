/datum/bounty/item/mech
	wanted_types = list(/obj/item/mecha_diagnostic = TRUE)
	/// What mech do we need data of inside this mecha diagnostic?
	var/required_data = null

/datum/bounty/item/mech/New()
	..()
	description = "Upper management has requested holodiagnostic scans of \a [name] mech be sent as soon as possible. A diagnostic holoscan can be generated from inside a new mecha. Ship it to receive a large payment."

/datum/bounty/item/mech/applies_to(obj/shipped)
	. = ..()
	if(istype(shipped, /obj/vehicle/sealed/mecha))
		shipped.balloon_alert_to_viewers("make diagnostic from inside!")

	var/obj/item/mecha_diagnostic/diagnostic_sheet = shipped
	if(!diagnostic_sheet.mech_data)
		CRASH("Diagnostic sheet submitted with no mech data contained!")
	if(istype(diagnostic_sheet.mech_data, required_data))
		return TRUE
	return FALSE

/datum/bounty/item/mech/ripleymk2
	name = "APLU MK-II \"Ripley\""
	reward = CARGO_CRATE_VALUE * 6.5
	required_data = /obj/vehicle/sealed/mecha/ripley/mk2

/datum/bounty/item/mech/clarke
	name = "Clarke"
	reward = CARGO_CRATE_VALUE * 12
	required_data = /obj/vehicle/sealed/mecha/clarke

/datum/bounty/item/mech/odysseus
	name = "Odysseus"
	reward = CARGO_CRATE_VALUE * 5.5
	required_data = /obj/vehicle/sealed/mecha/odysseus

/datum/bounty/item/mech/gygax
	name = "Gygax"
	reward = CARGO_CRATE_VALUE * 28
	required_data = /obj/vehicle/sealed/mecha/gygax

/datum/bounty/item/mech/durand
	name = "Durand"
	reward = CARGO_CRATE_VALUE * 20
	required_data = /obj/vehicle/sealed/mecha/durand
