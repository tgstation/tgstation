/**
 * Component for clothing items that can pick up blood from decals and spread it around everywhere when walking, such as shoes or suits with integrated shoes.
 */
/datum/component/bloodysoles
	/// The ITEM_SLOT_* slot the item is equipped on, if it is.
	var/equipped_slot
	/// What percentage of the bloodiness is deposited on the ground per step
	var/blood_dropped_per_step = 3
	/// Bloodiness on our clothines
	VAR_FINAL/total_bloodiness = 0
	/// Either the mob carrying the item, or the mob itself for the /feet component subtype
	VAR_FINAL/mob/living/carbon/wielder
	/// The world.time when we last picked up blood
	VAR_FINAL/last_pickup
	/// How much blood can we hold maximum
	var/max_bloodiness = BLOOD_ITEM_MAX
	/// Multiplier on how much blood taken from pools
	var/share_mod = 1

/datum/component/bloodysoles/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/bloodysoles/Destroy()
	wielder = null
	return ..()

/**
 * Unregisters from the wielder if necessary
 */
/datum/component/bloodysoles/proc/unregister()
	if(!QDELETED(wielder))
		UnregisterSignal(wielder, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(wielder, COMSIG_STEP_ON_BLOOD)
	wielder = null
	equipped_slot = null

/**
 * Returns true if the parent item is obscured by something else that the wielder is wearing
 */
/datum/component/bloodysoles/proc/is_obscured()
	return (wielder.check_covered_slots() & equipped_slot) || is_under_feet_covered()

/**
 * Returns true if the parent item is worn in the ITEM_SLOT_ICLOTHING slot and the
 * wielder is wearing something on their shoes.
 *
 * Allows for jumpsuits to cover feet without getting all bloodied when their wearer
 * is wearing shoes.
 */
/datum/component/bloodysoles/proc/is_under_feet_covered()
	if(!(equipped_slot & ITEM_SLOT_ICLOTHING))
		return FALSE

	return !isnull(wielder.shoes)

/**
 * Run to update the icon of the parent
 */
/datum/component/bloodysoles/proc/update_icon()
	var/obj/item/parent_item = parent
	parent_item.update_slot_icon()

/// Called whenever the value of bloody_soles changes to update our icon and behavior
/datum/component/bloodysoles/proc/change_blood_amount(some_amount)
	total_bloodiness = clamp(round(total_bloodiness + some_amount, 0.1), 0, max_bloodiness)
	update_icon()

	if(!wielder)
		return

	if(total_bloodiness <= BLOOD_FOOTPRINTS_MIN * 2) // Need twice that amount to make footprints
		UnregisterSignal(wielder, COMSIG_MOVABLE_MOVED)
	else
		RegisterSignal(wielder, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), override = TRUE)

/**
 * Run to equally share the blood between us and a decal
 */
/datum/component/bloodysoles/proc/share_blood(obj/effect/decal/cleanable/blood/pool)
	// Share the blood between our boots and the blood pool
	var/new_total_bloodiness = min(max_bloodiness, share_mod * (pool.bloodiness + total_bloodiness) / 2)
	if(new_total_bloodiness == total_bloodiness || new_total_bloodiness == 0)
		return FALSE

	var/delta = new_total_bloodiness - total_bloodiness
	pool.adjust_bloodiness(-1 * delta)
	change_blood_amount(delta)

	if(!ishuman(parent))
		var/atom/to_bloody = parent
		to_bloody.add_blood_DNA(GET_ATOM_BLOOD_DNA(pool))
		return TRUE

	var/bloody_slots = ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING|ITEM_SLOT_FEET
	var/mob/living/carbon/human/to_bloody = parent
	if(to_bloody.body_position == LYING_DOWN)
		bloody_slots |= ITEM_SLOT_HEAD|ITEM_SLOT_MASK|ITEM_SLOT_GLOVES

	to_bloody.add_blood_DNA_to_items(GET_ATOM_BLOOD_DNA(pool), bloody_slots)
	return TRUE

/**
 * Adds blood to an existing (or new) footprint
 */
/datum/component/bloodysoles/proc/add_blood_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint, bloodiness_to_add, exiting = FALSE, no_dna = FALSE)
	add_parent_to_footprint(footprint)
	footprint.adjust_bloodiness(bloodiness_to_add)
	if (!no_dna)
		footprint.add_blood_DNA(get_blood_dna())
	var/new_alpha = min(BLOODY_FOOTPRINT_BASE_ALPHA + (255 - BLOODY_FOOTPRINT_BASE_ALPHA) * footprint.bloodiness / (BLOOD_ITEM_MAX * BLOOD_TO_UNITS_MULTIPLIER), 255)
	if(new_alpha > footprint.alpha)
		footprint.alpha = new_alpha
	if(exiting)
		footprint.exited_dirs |= wielder.dir
	else
		footprint.entered_dirs |= wielder.dir
	footprint.update_appearance()

/// Fetches this component's blood DNA
/datum/component/bloodysoles/proc/get_blood_dna()
	var/atom/atom_parent = parent
	return GET_ATOM_BLOOD_DNA(atom_parent)

/**
 * Adds the parent type to the footprint's shoe_types var
 */
/datum/component/bloodysoles/proc/add_parent_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint)
	LAZYOR(footprint.shoe_types, parent.type)

/**
 * Called when the parent item is equipped by someone
 *
 * Used to register our wielder
 */
/datum/component/bloodysoles/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!iscarbon(equipper))
		return
	var/obj/item/parent_item = parent
	if(!(parent_item.slot_flags & slot))
		unregister()
		return

	equipped_slot = slot
	wielder = equipper
	if(total_bloodiness > BLOOD_FOOTPRINTS_MIN * 2)
		RegisterSignal(wielder, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(wielder, COMSIG_STEP_ON_BLOOD, PROC_REF(on_step_blood))

/**
 * Called when the parent item has been dropped
 *
 * Used to deregister our wielder
 */
/datum/component/bloodysoles/proc/on_drop(datum/source, mob/dropper)
	SIGNAL_HANDLER
	unregister()

/**
 * Called when the wielder has moved
 *
 * Used to make bloody footprints on the ground
 */
/datum/component/bloodysoles/proc/on_moved(datum/source, atom/old_loc, Dir, Forced)
	SIGNAL_HANDLER

	if(total_bloodiness <= 0)
		return
	if(QDELETED(wielder) || is_obscured())
		return
	if(wielder.body_position == LYING_DOWN || (wielder.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	var/atom/parent_atom = parent
	var/blood_used = round(total_bloodiness / 3, 0.01)
	// This is more of a sanity check than an actual concern, but *just* in case
	var/blood_flags = has_blood_flag(get_blood_dna(), BLOOD_ADD_DNA | BLOOD_COVER_TURFS)

	// Add footprints in old loc if we have enough cream
	if(blood_used >= BLOOD_FOOTPRINTS_MIN)
		var/turf/old_loc_turf = get_turf(old_loc)
		var/obj/effect/decal/cleanable/blood/footprints/old_loc_prints = locate() in old_loc_turf
		if(!(blood_flags & BLOOD_COVER_TURFS))
			if(blood_flags & BLOOD_ADD_DNA)
				old_loc_prints?.add_blood_DNA(get_blood_dna())
		else if(old_loc_prints)
			add_blood_to_footprint(old_loc_prints, 0, TRUE) // Add no actual blood, just update sprite
		else if(locate(/obj/effect/decal/cleanable/blood) in old_loc_turf)
			// No footprints in the tile we left, but there was some other blood pool there. Add exit footprints on it
			change_blood_amount(-1 * blood_used)
			old_loc_prints = new(old_loc_turf, null, get_blood_dna())
			old_loc_prints.alpha = 0
			if(!QDELETED(old_loc_prints)) // prints merged
				add_blood_to_footprint(old_loc_prints, blood_used, TRUE, no_dna = TRUE)
			blood_used = round(total_bloodiness / 3, 0.01)

	// If we picked up the blood on this tick in on_step_blood, don't make footprints at the same place
	if(last_pickup == world.time)
		return

	if(blood_used < BLOOD_FOOTPRINTS_MIN)
		return

	// Create new footprints
	var/turf/new_loc_turf = get_turf(parent_atom)
	var/obj/effect/decal/cleanable/blood/footprints/new_loc_prints = locate() in new_loc_turf
	if(new_loc_prints)
		if(blood_flags & BLOOD_COVER_TURFS)
			add_blood_to_footprint(new_loc_prints, 0, FALSE) // Add no actual blood, just update sprite
			return
		if(blood_flags & BLOOD_ADD_DNA)
			new_loc_prints.add_blood_DNA(get_blood_dna())
		return

	if(!(blood_flags & BLOOD_COVER_TURFS))
		return

	change_blood_amount(-1 * blood_used)
	new_loc_prints = new(new_loc_turf, null, get_blood_dna())
	new_loc_prints.alpha = 0
	if(!QDELETED(new_loc_prints)) // prints merged
		add_blood_to_footprint(new_loc_prints, blood_used, FALSE, no_dna = TRUE)

/**
 * Called when the wielder steps in a pool of blood
 *
 * Used to make the parent item bloody
 */
/datum/component/bloodysoles/proc/on_step_blood(datum/source, obj/effect/decal/cleanable/pool)
	SIGNAL_HANDLER

	if(QDELETED(wielder) || is_obscured() || (wielder.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	/// The character is agile enough to not mess their clothing and hands just from one blood splatter at floor
	if(HAS_TRAIT(wielder, TRAIT_LIGHT_STEP))
		return

	// Don't share from other feetprints, not super realistic but I think it ruins the effect a bit
	if(istype(pool, /obj/effect/decal/cleanable/blood/footprints))
		return

	share_blood(pool)
	last_pickup = world.time

/**
 * Called when the parent item is being washed
 */
/datum/component/bloodysoles/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_BLOOD))
		return NONE

	total_bloodiness = 0
	var/obj/item/clothing/shoes/parent_shoes = parent
	if(!istype(parent_shoes)) // if we are wearing shoes, wash() will already be calling update_worn_shoes() so we don't have to do it twice
		update_icon()
	return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/**
 * Like its parent but can be applied to carbon mobs instead of clothing items
 */
/datum/component/bloodysoles/feet
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	equipped_slot = ITEM_SLOT_FEET
	var/static/mutable_appearance/bloody_feet

	/// List of DNA on mob's feet, so we can handle it separately from blood on mob's hands
	var/list/blood_DNA = null

/datum/component/bloodysoles/feet/Initialize(list/new_blood)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	wielder = parent

	if(!bloody_feet)
		bloody_feet = mutable_appearance('icons/effects/blood.dmi', "shoeblood", SHOES_LAYER)

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_STEP_ON_BLOOD, PROC_REF(on_step_blood))
	RegisterSignals(parent, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(shoecover))

	if(new_blood)
		blood_DNA = new_blood
		update_icon()

/datum/component/bloodysoles/feet/InheritComponent(datum/component/bloodysoles/feet/soles, original, list/new_blood)
	if (!length(new_blood))
		return

	LAZYOR(blood_DNA, new_blood)
	update_icon()

/datum/component/bloodysoles/feet/share_blood(obj/effect/decal/cleanable/pool)
	. = ..()
	if (!.)
		return
	LAZYOR(blood_DNA, GET_ATOM_BLOOD_DNA(pool))
	update_icon()

/datum/component/bloodysoles/feet/update_icon()
	if(!ishuman(wielder) || HAS_TRAIT(wielder, TRAIT_NO_BLOOD_OVERLAY))
		return

	wielder.remove_overlay(SHOES_LAYER)
	if(!total_bloodiness || is_obscured())
		wielder.update_worn_shoes()
		return

	bloody_feet.color = wielder.get_blood_dna_color()
	wielder.overlays_standing[SHOES_LAYER] = bloody_feet
	wielder.apply_overlay(SHOES_LAYER)

/datum/component/bloodysoles/feet/add_parent_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint)
	if(!ishuman(wielder))
		LAZYSET(footprint.species_types, "unknown", TRUE)
		return

	// Find any leg of our human and add that to the footprint, instead of the default which is to just add the human type
	for(var/obj/item/bodypart/leg/affecting in wielder.bodyparts)
		if(!affecting.bodypart_disabled)
			LAZYSET(footprint.species_types, affecting.limb_id, TRUE)

/datum/component/bloodysoles/feet/is_under_feet_covered()
	return !isnull(wielder.shoes)

/datum/component/bloodysoles/feet/on_moved(datum/source, OldLoc, Dir, Forced)
	if(wielder.num_legs >= 2)
		return ..()

/datum/component/bloodysoles/feet/on_step_blood(datum/source, obj/effect/decal/cleanable/pool)
	if(wielder.num_legs >= 2)
		return ..()

/datum/component/bloodysoles/feet/proc/shoecover(datum/source, obj/item/item)
	SIGNAL_HANDLER
	if ((item.body_parts_covered & FEET) || (item.flags_inv & HIDESHOES))
		update_icon()

/datum/component/bloodysoles/feet/get_blood_dna()
	return blood_DNA

/**
 * Simplified version of the kind applied to carbons for simple/basic mobs, primarily robots
 */
/datum/component/bloodysoles/bot
	max_bloodiness = 150
	share_mod = 0.75

/datum/component/bloodysoles/bot/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	wielder = parent
	RegisterSignal(wielder, COMSIG_STEP_ON_BLOOD, PROC_REF(on_step_blood))

/datum/component/bloodysoles/bot/is_obscured()
	return FALSE

/datum/component/bloodysoles/bot/is_under_feet_covered()
	return FALSE

/datum/component/bloodysoles/bot/add_parent_to_footprint(obj/effect/decal/cleanable/blood/footprints/footprint)
	LAZYSET(footprint.species_types, "bot", TRUE)

/datum/component/bloodysoles/bot/update_icon()
	// Future idea: Bot blood overlays
	return
