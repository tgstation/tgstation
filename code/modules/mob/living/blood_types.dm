/datum/blood_type
	/// Name of the blood type.
	var/name = "?"
	/// A description of the blood type.
	var/desc
	/// Unique identifier for the blood type in the global list of singletons. Typically this is just the name, but some blood types might have the same name (e.g. evil blood)
	var/id
	/// What DNA string does this bloodtype have by default, if not set by a mob?
	var/dna_string = "Unknown DNA"
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
	/// Splash and expose behaviors for this blood type's reagent, to prevent water-blood covered items
	var/expose_flags = BLOOD_ADD_DNA | BLOOD_COVER_MOBS | BLOOD_COVER_TURFS | BLOOD_COVER_ITEMS | BLOOD_TRANSFER_VIRAL_DATA

/datum/blood_type/New()
	. = ..()
	id = name
	compatible_types |= type_key()
	if (!desc)
		desc = reagent_type::description

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

/// Name of the reagent we use for blood
/datum/blood_type/proc/get_blood_name()
	return reagent_type::name

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

/// Returns blood color for mob damage overlays
/datum/blood_type/proc/get_damage_color(mob/living/carbon/victim)
	return get_color()

/**
 * Used to handle any unique facets of blood spawned of this blood type
 *
 * You don't need to worry about updating the icon of the decal,
 * it will be handled automatically after setup is finished
 *
 * Arguments
 * * blood - the blood being set up
 * * new_splat - whether this is a newly instantiated blood decal, or an existing one this blood is being added to
 */
/datum/blood_type/proc/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	if (new_splat && !blood.decal_reagent)
		blood.decal_reagent = reagent_type
	else if (blood.reagents && blood.bloodiness) // If reagents don't exist yet, we'll be added via lazyloading
		blood.reagents.add_reagent(reagent_type, round(blood.bloodiness / (GET_ATOM_BLOOD_DNA_LENGTH(blood) - 1) * BLOOD_TO_UNITS_MULTIPLIER, CHEMICAL_VOLUME_ROUNDING)) // -1 as this happens before bloodiness is adjusted

// Human blood type, for organizational purposes mainly
/datum/blood_type/human
	desc = "Blood cells suspended in plasma, the most abundant of which being the hemoglobin-containing red blood cells."
	dna_string = "Human DNA"
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

/datum/blood_type/human/universal
	name = BLOOD_TYPE_UNIVERSAL

/datum/blood_type/human/universal/New()
	. = ..()
	compatible_types = subtypesof(/datum/blood_type)

/datum/blood_type/animal
	name = BLOOD_TYPE_ANIMAL
	desc = "Blood cells suspended in plasma, the most abundant of which being the hemoglobin-containing red blood cells."
	dna_string = "Animal DNA"

/datum/blood_type/lizard
	name = BLOOD_TYPE_LIZARD
	desc = "Green sulfhemoglobin subtype-based blood, which while less effective at transporting oxygen, \
		is capable of withstanding much higher temperatures without breaking down or clotting."
	dna_string = "Lizard DNA"
	color = BLOOD_COLOR_LIZARD

/datum/blood_type/ethereal
	name = BLOOD_TYPE_ETHEREAL
	dna_string = "Ethereal DNA"
	color = /datum/reagent/consumable/liquidelectricity::color
	lightness_mult = 1.255 // for more vibrant gatorade coloring
	reagent_type = /datum/reagent/consumable/liquidelectricity

/datum/blood_type/ethereal/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	. = ..()
	blood.emissive_alpha = max(blood.emissive_alpha, new_splat ? 188 : 125)
	if (new_splat)
		return
	blood.can_dry = FALSE

/datum/blood_type/oil
	name = BLOOD_TYPE_OIL
	dna_string = "Oil"
	color = BLOOD_COLOR_OIL
	reagent_type = /datum/reagent/fuel/oil
	restoration_chem = /datum/reagent/fuel
	expose_flags = BLOOD_COVER_MOBS | BLOOD_COVER_TURFS | BLOOD_COVER_ITEMS

/datum/blood_type/oil/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	. = ..()
	if (!new_splat)
		return

	// Oil blood will never dry and can be ignited with fire
	blood.can_dry = FALSE
	blood.dry_prefix = null
	blood.dry_desc = null

	// Always force our decals to have our reagent, we don't want liquid gibs from oily guts
	blood.decal_reagent = reagent_type

	// Oily guts are not converted to robotic ones, so you can still have your biomechanical abominations >X)
	if (!istype(blood, /obj/effect/decal/cleanable/blood/gibs))
		blood.AddElement(/datum/element/easy_ignite)

	// Replace only the default description
	if (blood.desc == /obj/effect/decal/cleanable/blood::desc)
		blood.desc = /obj/effect/decal/cleanable/blood/oil::desc

/datum/blood_type/vampire
	name = BLOOD_TYPE_VAMPIRE
	dna_string = "Hemovore DNA"

/datum/blood_type/meat // why does this exist
	name = BLOOD_TYPE_MEAT
	dna_string = "Meaty DNA"

/datum/blood_type/xeno
	name = BLOOD_TYPE_XENO
	desc = "An incredibly potent mineral acid, somehow capable of carrying oxygen."
	dna_string = "Alien DNA"
	color = BLOOD_COLOR_XENO
	lightness_mult = 1.255 // For parity with pre-refactor xeno blood sprites
	reagent_type = /datum/reagent/toxin/acid
	// Viruses cannot survive in acid
	expose_flags = BLOOD_ADD_DNA | BLOOD_COVER_MOBS | BLOOD_COVER_TURFS | BLOOD_COVER_ITEMS

/datum/blood_type/xeno/get_blood_name()
	return "Acid"

/datum/blood_type/xeno/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	. = ..()
	if (!new_splat)
		return

	// Replace only the default description
	if (blood.desc == /obj/effect/decal/cleanable/blood::desc)
		blood.desc = "It's green and acidic. It looks like... <i>blood?</i>"

/// April fool's blood for clowns
/datum/blood_type/clown
	name = BLOOD_TYPE_CLOWN
	dna_string = "Clown DNA"
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
	dna_string = "Slime DNA"
	color = /datum/reagent/toxin/slimejelly::color
	reagent_type = /datum/reagent/toxin/slimejelly
	restoration_chem = /datum/reagent/stable_plasma // Because normal plasma already refills our blood

/datum/blood_type/slime/New(new_color)
	. = ..()
	if (!new_color)
		return
	color = new_color
	id = type_key() // Should not be a singleton for perf/memory reasons considering how easy it is to swap colors

/datum/blood_type/slime/type_key()
	return "_[name]_[color]"

/// Podpeople blood
/datum/blood_type/water
	name = BLOOD_TYPE_H2O
	dna_string = "Plant DNA"
	color = /datum/reagent/water::color
	reagent_type = /datum/reagent/water
	restoration_chem = null
	no_bleed_overlays = TRUE
	expose_flags = BLOOD_ADD_DNA | BLOOD_TRANSFER_VIRAL_DATA

/// Prevents awkward grey wounds on the mob while keeping bleed overlays looking like water leaking from a balloon
/datum/blood_type/water/get_damage_color(mob/living/carbon/victim)
	return COLOR_LIME

/// Snail blood
/datum/blood_type/snail
	name = BLOOD_TYPE_SNAIL
	dna_string = "Snail DNA"
	reagent_type = /datum/reagent/lube
	restoration_chem = /datum/reagent/silicon

/datum/blood_type/snail/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat)
	. = ..()
	if(blood.bloodiness < BLOOD_AMOUNT_PER_DECAL)
		return
	var/slip_amt = new_splat ? 4 SECONDS : 1 SECONDS
	var/slip_flags = new_splat ? (NO_SLIP_WHEN_WALKING | SLIDE) : (NO_SLIP_WHEN_WALKING)
	blood.AddComponent(/datum/component/slippery, slip_amt, slip_flags)

/// An abstract-ish blood type used particularly for species with blood set to random reagents, such as podpeople
/datum/blood_type/random_chemical
	root_abstract_type = /datum/blood_type/random_chemical

/datum/blood_type/random_chemical/New(datum/reagent/reagent)
	name = initial(reagent.name)
	desc = initial(reagent.description)
	. = ..()
	id = type_key()
	color = initial(reagent.color)
	reagent_type = reagent
	root_abstract_type = null

/datum/blood_type/random_chemical/type_key()
	return reagent_type

// Similar to the random reagents bloodtype, this one creates a 'but evil' bloodtype
/datum/blood_type/evil
	root_abstract_type = /datum/blood_type/evil

/datum/blood_type/evil/New(datum/blood_type/real_blood_type, list/real_compatible_types)
	name = real_blood_type.name
	desc = real_blood_type.desc
	. = ..()
	dna_string = real_blood_type.dna_string
	id = type_key()
	color = BLOOD_COLOR_BLACK // why it gotta be black though
	reagent_type = real_blood_type.reagent_type
	restoration_chem = real_blood_type.restoration_chem
	compatible_types = LAZYCOPY(real_compatible_types) | type_key()
	root_abstract_type = null

/datum/blood_type/evil/type_key()
	return "[name]_but_evil"
