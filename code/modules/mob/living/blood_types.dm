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
	/// Blood types that are safe to use with people that have this blood type (for blood transfusions)
	var/list/compatible_types = list()
	/// What reagent is represented by this blood type?
	var/datum/reagent/reagent_type = /datum/reagent/blood
	/// What chem is used to restore this blood type (outside of itself, of course)?
	var/datum/reagent/restoration_chem = /datum/reagent/iron
	/// Exclude abstract root types from being initialized by defining them here
	var/root_abstract_type
	/// If this blood type is meant to persist across species changes
	var/is_species_universal
	/// Splash and expose behaviors for this blood type's reagent, to prevent water-blood covered items, as well as information transfer flags
	var/blood_flags = BLOOD_ADD_DNA | BLOOD_COVER_ALL | BLOOD_TRANSFER_VIRAL_DATA

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
	return capitalize(LOWER_TEXT(reagent_type::name))

/// Type string of this bloodtype. Used to prevent "Oil type: Oil" scenarios
/datum/blood_type/proc/get_type()
	if (reagent_type != /datum/reagent/blood)
		return null
	return name

/// Returns blood color or color matrix
/// Useful when you want to have a blood color with values out of normal hex bounds for that acidic look
/// set dynamic to TRUE to redo the matrix each time (e.g. for clown blood dynamically shifting each time)
/datum/blood_type/proc/get_color(dynamic = FALSE)
	return color

/// Returns blood color for mob damage overlays
/datum/blood_type/proc/get_damage_color(mob/living/carbon/victim)
	return get_color()

/// Returns blood color for wound bleeding overlays
/datum/blood_type/proc/get_wound_color(mob/living/carbon/victim)
	return get_color()

/// Returns emissive value for an atom
/// is_worn - Emissive is being fetched for a mob overlay and not the item itself
/datum/blood_type/proc/get_emissive_alpha(atom/source, is_worn = FALSE)
	return 0

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
	if(new_splat && !blood.decal_reagent)
		blood.decal_reagent = reagent_type
	else if(blood.reagents && blood.bloodiness) // If reagents don't exist yet, we'll be added via lazyloading
		blood.reagents.add_reagent(reagent_type, round(blood.bloodiness / (GET_ATOM_BLOOD_DNA_LENGTH(blood) - 1) * BLOOD_TO_UNITS_MULTIPLIER, CHEMICAL_VOLUME_ROUNDING)) // -1 as this happens before bloodiness is adjusted


/**
 * Helper proc to make a blood splatter from the passed mob of this type
 *
 * Arguments
 * * bleeding - the mob bleeding the blood, note we assume this blood type is that mob's blood
 * * blood_turf - the turf to spawn the blood on
 * * drip - whether to spawn a drip or a splatter
 */
/datum/blood_type/proc/make_blood_splatter(mob/living/bleeding, turf/blood_turf, drip = FALSE)
	if(!(blood_flags & BLOOD_COVER_TURFS))
		return

	if(isgroundlessturf(blood_turf))
		blood_turf = GET_TURF_BELOW(blood_turf)

	if(isnull(blood_turf) || isclosedturf(blood_turf))
		return

	var/list/temp_blood_DNA
	if(drip)
		var/new_blood = /obj/effect/decal/cleanable/blood/drip::bloodiness
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in blood_turf
		if(isnull(drop))
			var/obj/effect/decal/cleanable/blood/splatter = locate() in blood_turf
			if(!QDELETED(splatter) && !splatter.dried)
				splatter.add_mob_blood(bleeding)
				splatter.adjust_bloodiness(new_blood)
				return splatter

			drop = new(blood_turf, bleeding.get_static_viruses(), bleeding.get_blood_dna_list())
			if(!QDELETED(drop))
				drop.random_icon_states -= drop.icon_state
			return drop

		if(length(drop.random_icon_states))
			// Handle adding a single drip to the base atom
			// Makes use of viscontents so every drip can dry at an individual rate (with an individual color)
			var/obj/effect/decal/cleanable/blood/drip/new_drop = new(drop, null, bleeding.get_blood_dna_list())
			new_drop.bloodiness = 0
			new_drop.icon_state = pick_n_take(drop.random_icon_states)
			new_drop.color = color
			new_drop.vis_flags |= (VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID)
			new_drop.appearance_flags |= (RESET_COLOR)
			drop.gender = PLURAL
			drop.base_name = "drips of"
			drop.vis_contents += new_drop
			// Handle adding blood to the base atom
			drop.adjust_bloodiness(new_blood)
			drop.add_mob_blood(bleeding)
			drop.add_diseases(bleeding.get_static_viruses())
			return drop

		temp_blood_DNA = GET_ATOM_BLOOD_DNA(drop) // We transfer the dna from the drip to the splatter
		qdel(drop) // The drip is replaced by a bigger splatter

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/splatter = locate() in blood_turf
	if(isnull(splatter) || splatter.dried)
		splatter = new(blood_turf, bleeding.get_static_viruses(), bleeding.get_blood_dna_list())
		if(QDELETED(splatter)) //Give it up
			return null
	else
		splatter.adjust_bloodiness(BLOOD_AMOUNT_PER_DECAL)
		splatter.add_diseases(bleeding.get_static_viruses())
		splatter.add_mob_blood(bleeding) // Give blood info to the blood decal

	if(LAZYLEN(temp_blood_DNA))
		splatter.add_blood_DNA(temp_blood_DNA)
	return splatter

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
	reagent_type = /datum/reagent/consumable/liquidelectricity

/datum/blood_type/ethereal/get_emissive_alpha(atom/source, is_worn = FALSE)
	if (is_worn)
		return 102
	return 125

/datum/blood_type/ethereal/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	. = ..()
	blood.emissive_alpha = max(blood.emissive_alpha, new_splat ? 125 : 63)
	if (new_splat)
		return
	blood.can_dry = FALSE

/datum/blood_type/oil
	name = BLOOD_TYPE_OIL
	dna_string = "Oil"
	color = BLOOD_COLOR_OIL
	reagent_type = /datum/reagent/fuel/oil
	restoration_chem = /datum/reagent/fuel
	blood_flags = BLOOD_COVER_ALL

/datum/blood_type/oil/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	. = ..()
	if (!new_splat)
		return

	// Oil blood will never dry and can be ignited with fire or anything sufficiently hot
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
	reagent_type = /datum/reagent/toxin/acid
	// Viruses cannot survive in acid
	blood_flags = BLOOD_ADD_DNA | BLOOD_COVER_ALL

/datum/blood_type/xeno/get_blood_name()
	return "Acid" // "pool of sulphuric acid" is a bit too lengthy of a name

/datum/blood_type/xeno/set_up_blood(obj/effect/decal/cleanable/blood/blood, new_splat = FALSE)
	. = ..()
	if (!new_splat)
		return
	blood.can_dry = FALSE
	// Replace only the default description
	if (blood.desc == /obj/effect/decal/cleanable/blood::desc)
		blood.desc = "It's green and acidic. It looks like... <i>blood?</i>"

/// April fool's blood for clowns
/datum/blood_type/clown
	name = BLOOD_TYPE_CLOWN
	dna_string = "Clown DNA"
	reagent_type = /datum/reagent/colorful_reagent
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

// Ensures that lighter slimefolk look half-decent when wounded and bleeding
/datum/blood_type/slime/get_wound_color(mob/living/carbon/victim)
	return victim.dna?.features?[FEATURE_MUTANT_COLOR] || get_color()
/datum/blood_type/slime/get_damage_color(mob/living/carbon/victim)
	return victim.dna?.features?[FEATURE_MUTANT_COLOR] || get_color()

/// Podpeople blood
/datum/blood_type/water
	name = BLOOD_TYPE_H2O
	dna_string = "Plant DNA"
	color = /datum/reagent/water::color
	reagent_type = /datum/reagent/water
	restoration_chem = null
	blood_flags = BLOOD_ADD_DNA | BLOOD_TRANSFER_VIRAL_DATA

// Prevents awkward grey wounds on the mob while keeping bleed overlays looking like water leaking from a balloon
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
