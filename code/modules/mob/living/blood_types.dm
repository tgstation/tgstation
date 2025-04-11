/datum/blood_type
	/// Displayed name of the blood type.
	var/name = "?"
	/// A description of the blood type.
	var/desc
	/// Shown color of the blood type.
	var/color = BLOOD_COLOR_RED
	/// Additional lightness multiplier for the blood color
	/// When set, color will be transformed into a matrix with coefficients multiplied by this value
	var/lightness_mult = null
	/// Blood types that are safe to use with people that have this blood type.
	var/compatible_types = list()
	/// What reagent is represented by this blood type?
	var/datum/reagent/reagent_type = /datum/reagent/blood
	/// What chem is used to restore this blood type (outside of itself, of course)?
	var/datum/reagent/restoration_chem = /datum/reagent/iron
	/// Whether or not this blood type should create blood trails, blood sprays, etc
	var/no_bleed_overlays

/datum/blood_type/New()
	. = ..()
	compatible_types |= type_key()

/datum/blood_type/Destroy(force)
	if(!force)
		stack_trace("qdel called on blood type singleton! (use FORCE if necessary)")
		return QDEL_HINT_LETMELIVE

	return ..()

/**
 * Key used to identify this blood type in the global blood_types list
 *
 * Allows for more complex or dynamically generated blood types
 */
/datum/blood_type/proc/type_key()
	return type

/// Returns blood color or color matrix
/// Useful when you want to have a blood color with values out of normal hex bounds for that acidic look
/datum/blood_type/proc/get_color()
	if(isnull(lightness_mult))
		return color

	var/static/list/blood_matrix = color_to_full_rgba_matrix(color)
	for(var/i in 1 to min(length(blood_matrix), 16))
		if (length(blood_matrix) == 12 && i > 9) // Don't modify constants
			break
		if (length(blood_matrix) >= 16 && i % 4 == 0) // Don't modify alpha either
			continue
		blood_matrix[i] *= lightness_mult
	return blood_matrix

/datum/blood_type/a_minus
	name = "A-"
	compatible_types = list(/datum/blood_type/a_minus, /datum/blood_type/o_minus)

/datum/blood_type/a_plus
	name = "A+"
	compatible_types = list(/datum/blood_type/a_minus, /datum/blood_type/a_plus, /datum/blood_type/o_minus, /datum/blood_type/o_plus)

/datum/blood_type/b_minus
	name = "B-"
	compatible_types = list(
		/datum/blood_type/b_minus,
		/datum/blood_type/o_minus,
	)

/datum/blood_type/b_plus
	name = "B+"
	compatible_types = list(
		/datum/blood_type/b_minus,
		/datum/blood_type/b_plus,
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus,
	)

/datum/blood_type/ab_minus
	name = "AB-"
	compatible_types = list(
		/datum/blood_type/a_minus,
		/datum/blood_type/b_minus,
		/datum/blood_type/ab_minus,
		/datum/blood_type/o_minus,
	)

/datum/blood_type/ab_plus
	name = "AB+"
	compatible_types = list(
		/datum/blood_type/a_minus,
		/datum/blood_type/a_plus,
		/datum/blood_type/b_minus,
		/datum/blood_type/b_plus,
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus,
		/datum/blood_type/ab_minus,
		/datum/blood_type/ab_plus,
	)

/datum/blood_type/o_minus
	name = "O-"
	compatible_types = list(
		/datum/blood_type/o_minus,
	)

/datum/blood_type/o_plus
	name = "O+"
	compatible_types = list(
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus,
	)

/datum/blood_type/animal
	name = "Y-"
	compatible_types = list(
		/datum/blood_type/animal,
	)

/datum/blood_type/lizard
	name = "L"
	compatible_types = list(
		/datum/blood_type/lizard,
	)

/datum/blood_type/ethereal
	name = "LE"
	color = /datum/reagent/consumable/liquidelectricity::color
	compatible_types = list(
		/datum/blood_type/ethereal,
	)

/datum/blood_type/oil
	name = "Oil"
	color = "#1f1a00"
	reagent_type = /datum/reagent/fuel/oil

/datum/blood_type/vampire
	name = "V"
	compatible_types = list(
		/datum/blood_type/vampire,
	)

/datum/blood_type/meat // why does this exist
	name = "MT-"

/datum/blood_type/universal
	name = "U"

/datum/blood_type/universal/New()
	. = ..()
	compatible_types = subtypesof(/datum/blood_type)

/datum/blood_type/xeno
	name = "X*"
	color = BLOOD_COLOR_XENO
	lightness_mult = 1.255 // For parity with pre-refactor xeno blood sprites
	compatible_types = list(/datum/blood_type/xeno)

/// April fool's blood for clowns
/datum/blood_type/clown
	name = "C"
	reagent_type = /datum/reagent/colorful_reagent

/// Slimeperson blood, aka 'toxin' blood type
/datum/blood_type/slime
	name = "TOX"
	color = /datum/reagent/toxin/slimejelly::color
	reagent_type = /datum/reagent/toxin/slimejelly
	no_bleed_overlays = TRUE

/// Podpeople blood
/datum/blood_type/water
	name = "H2O"
	color = /datum/reagent/water::color
	reagent_type = /datum/reagent/water
	no_bleed_overlays = TRUE

/// Snaiil blood
/datum/blood_type/snail
	name = "Lube"
	reagent_type = /datum/reagent/lube

/// An abstract-ish blood type used particularly for species with blood set to random reagents, such as podpeople
/datum/blood_type/random_chemical

/datum/blood_type/random_chemical/New(datum/reagent/reagent_type)
	. = ..()
	src.name = initial(reagent_type.name)
	src.color = initial(reagent_type.color)
	src.reagent_type = reagent_type
	src.restoration_chem = reagent_type

/datum/blood_type/random_chemical/type_key()
	return reagent_type
