/datum/blood_type
	/// Displayed name of the blood type.
	var/name = "?"
	/// Shown color of the blood type.
	var/color = COLOR_BLOOD
	/// Blood types that are safe to use with people that have this blood type.
	var/compatible_types = list()

/datum/blood_type/a_minus
	name = "A-"
	compatible_types = list(/datum/blood_type/a_minus, /datum/blood_type/o_minus)

/datum/blood_type/a_plus
	name = "A+"
	compatible_types = list(/datum/blood_type/a_minus, /datum/blood_type/a_plus, /datum/blood_type/o_minus, /datum/blood_type/o_plus)

/datum/blood_type/b_minus
	name = "B-"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/o_minus)

/datum/blood_type/b_plus
	name = "B+"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/b_plus, /datum/blood_type/o_minus, /datum/blood_type/o_plus)

/datum/blood_type/ab_minus
	name = "AB-"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/a_minus, /datum/blood_type/ab_minus, /datum/blood_type/o_minus)

/datum/blood_type/ab_plus
	name = "AB+"
	compatible_types = list(/datum/blood_type/b_minus, /datum/blood_type/a_minus, /datum/blood_type/ab_minus, /datum/blood_type/o_minus)

/datum/blood_type/o_minus
	name = "O-"
	compatible_types = list(/datum/blood_type/o_minus)

/datum/blood_type/o_plus
	name = "O+"
	compatible_types = list(/datum/blood_type/o_minus, /datum/blood_type/o_plus)

/datum/blood_type/lizard
	name = "L"
	color = rgb(0, 150, 150)
	compatible_types = list(/datum/blood_type/lizard)

/datum/blood_type/universal
	name = "U"

/datum/blood_type/universal/New()
	. = ..()
	compatible_types = subtypesof(/datum/blood_type)
