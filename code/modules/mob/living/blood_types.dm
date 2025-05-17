/datum/blood_type
	/// Name of the blood type.
	var/name = "?"
	/// A description of the blood type.
	var/desc
	/// Unique identifier for the blood type in the global list of singletons. Typically this is just the name, but some blood types might have the same name (e.g. evil blood)
	var/id
	/// Shown color of the blood type.
	var/color = BLOOD_COLOR_RED
	/// Additional lightness multiplier for the blood color, useful for when the default lightness from the greyscaling doesn't cut it and you want something more vibrant.
	/// When set, color will be transformed into a matrix with coefficients multiplied by this value
	var/lightness_mult = null
	/// The cached color matrix for blood with a lightness_mult. We only need to calculate this once since blood types are singletons
	var/list/blood_color_matrix
	/// Blood types that are safe to use with people that have this blood type (for blood transfusions)
	var/compatible_types = list()
	/// What reagent is represented by this blood type?
	var/datum/reagent/reagent_type = /datum/reagent/blood
	/// What chem is used to restore this blood type (outside of itself, of course)?
	var/datum/reagent/restoration_chem = /datum/reagent/iron
	/// Whether or not this blood type should create blood trails, blood sprays, etc
	var/no_bleed_overlays
	/// Exclude abstract root types from being initialized by defining them here
	var/root_abstract_type
	/// If this blood type is meant to persist across species changes
	var/is_species_universal

/datum/blood_type/New()
	. = ..()
	id = name
	compatible_types |= type_key()

/datum/blood_type/Destroy(force)
	if(!force)
		stack_trace("qdel called on blood type singleton! (use FORCE if necessary)")
		return QDEL_HINT_LETMELIVE

	return ..()

/**
 * Key used to identify this blood type in compatible_types
 *
 * Allows for more complex or dynamically generated blood types
 */
/datum/blood_type/proc/type_key()
	return type

/// Returns blood color or color matrix
/// Useful when you want to have a blood color with values out of normal hex bounds for that acidic look
/// set dynamic to TRUE to redo the matrix each time (e.g. for clown blood dynamically shifting each time)
/datum/blood_type/proc/get_color(dynamic = FALSE)
	if(isnull(lightness_mult))
		return color

	if(!isnull(blood_color_matrix) && !dynamic)
		return blood_color_matrix

	blood_color_matrix = color_to_full_rgba_matrix(color)
	for(var/i in 1 to min(length(blood_color_matrix), 16))
		if (length(blood_color_matrix) == 12 && i > 9) // Don't modify constants
			break
		if (length(blood_color_matrix) >= 16 && i % 4 == 0) // Don't modify alpha either
			continue
		blood_color_matrix[i] *= lightness_mult

	return blood_color_matrix

// human blood type, for organizational purposes mainly
/datum/blood_type/human
	desc = "Blood cells suspended in plasma, the most abundant of which being the hemoglobin-containing red blood cells."
	root_abstract_type = /datum/blood_type/human

/datum/blood_type/human/a_minus
	name = BLOOD_TYPE_A_MINUS
	compatible_types = list(/datum/blood_type/human/a_minus, /datum/blood_type/human/o_minus)

/datum/blood_type/human/a_plus
	name = BLOOD_TYPE_A_PLUS
	compatible_types = list(/datum/blood_type/human/a_minus, /datum/blood_type/human/a_plus, /datum/blood_type/human/o_minus, /datum/blood_type/human/o_plus)

/datum/blood_type/human/b_minus
	name = BLOOD_TYPE_B_MINUS
	compatible_types = list(
		/datum/blood_type/human/b_minus,
		/datum/blood_type/human/o_minus,
	)

/datum/blood_type/human/b_plus
	name = BLOOD_TYPE_B_PLUS
	compatible_types = list(
		/datum/blood_type/human/b_minus,
		/datum/blood_type/human/b_plus,
		/datum/blood_type/human/o_minus,
		/datum/blood_type/human/o_plus,
	)

/datum/blood_type/human/ab_minus
	name = BLOOD_TYPE_AB_MINUS
	compatible_types = list(
		/datum/blood_type/human/a_minus,
		/datum/blood_type/human/b_minus,
		/datum/blood_type/human/ab_minus,
		/datum/blood_type/human/o_minus,
	)

/datum/blood_type/human/ab_plus
	name = BLOOD_TYPE_AB_PLUS
	compatible_types = list(
		/datum/blood_type/human/a_minus,
		/datum/blood_type/human/a_plus,
		/datum/blood_type/human/b_minus,
		/datum/blood_type/human/b_plus,
		/datum/blood_type/human/o_minus,
		/datum/blood_type/human/o_plus,
		/datum/blood_type/human/ab_minus,
		/datum/blood_type/human/ab_plus,
	)

/datum/blood_type/human/o_minus
	name = BLOOD_TYPE_O_MINUS
	compatible_types = list(
		/datum/blood_type/human/o_minus,
	)

/datum/blood_type/human/o_plus
	name = BLOOD_TYPE_O_PLUS
	compatible_types = list(
		/datum/blood_type/human/o_minus,
		/datum/blood_type/human/o_plus,
	)

/datum/blood_type/animal
	name = BLOOD_TYPE_ANIMAL
	compatible_types = list(
		/datum/blood_type/animal,
	)

/datum/blood_type/lizard
	name = BLOOD_TYPE_LIZARD
	color = BLOOD_COLOR_LIZARD
	compatible_types = list(
		/datum/blood_type/lizard,
	)

/datum/blood_type/ethereal
	name = BLOOD_TYPE_ETHEREAL
	color = /datum/reagent/consumable/liquidelectricity::color
	lightness_mult = 1.255 // for more vibrant gatorade coloring
	compatible_types = list(
		/datum/blood_type/ethereal,
	)

/datum/blood_type/oil
	name = BLOOD_TYPE_OIL
	color = BLOOD_COLOR_OIL
	reagent_type = /datum/reagent/fuel/oil

/datum/blood_type/vampire
	name = BLOOD_TYPE_VAMPIRE
	compatible_types = list(
		/datum/blood_type/vampire,
	)

/datum/blood_type/meat // why does this exist
	name = BLOOD_TYPE_MEAT

/datum/blood_type/universal
	name = BLOOD_TYPE_UNIVERSAL

/datum/blood_type/universal/New()
	. = ..()
	compatible_types = subtypesof(/datum/blood_type)

/datum/blood_type/xeno
	name = BLOOD_TYPE_XENO
	color = BLOOD_COLOR_XENO
	lightness_mult = 1.255 // For parity with pre-refactor xeno blood sprites
	compatible_types = list(/datum/blood_type/xeno)

/// April fool's blood for clowns
/datum/blood_type/clown
	name = BLOOD_TYPE_CLOWN
	reagent_type = /datum/reagent/colorful_reagent
	lightness_mult = 1.255
	is_species_universal = TRUE
	/// The cached list of random colors to pick from
	var/list/random_color_list

/datum/blood_type/clown/get_color(dynamic = TRUE)
	// Set up the random color list if we haven't done that yet. Only need to do this once.
	if(isnull(random_color_list))
		var/datum/reagent/colorful_reagent/clown_blood = new
		random_color_list = clown_blood.random_color_list.Copy()
		qdel(clown_blood)

	color = pick(random_color_list)
	return ..()

/// Slimeperson blood, aka 'toxin' blood type
/datum/blood_type/slime
	name = BLOOD_TYPE_TOX
	color = /datum/reagent/toxin/slimejelly::color
	reagent_type = /datum/reagent/toxin/slimejelly
	no_bleed_overlays = TRUE

/// Podpeople blood
/datum/blood_type/water
	name = BLOOD_TYPE_H2O
	color = /datum/reagent/water::color
	reagent_type = /datum/reagent/water
	no_bleed_overlays = TRUE

/// Snail blood
/datum/blood_type/snail
	name = BLOOD_TYPE_SNAIL
	reagent_type = /datum/reagent/lube

/// An abstract-ish blood type used particularly for species with blood set to random reagents, such as podpeople
/datum/blood_type/random_chemical
	root_abstract_type = /datum/blood_type/random_chemical

/datum/blood_type/random_chemical/New(datum/reagent/reagent_type)
	. = ..()
	src.name = initial(reagent_type.name)
	src.color = initial(reagent_type.color)
	src.reagent_type = reagent_type
	src.restoration_chem = reagent_type
	src.root_abstract_type = null

/datum/blood_type/random_chemical/type_key()
	return reagent_type
