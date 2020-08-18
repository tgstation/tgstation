
/**
  * Component for clothing items that can pick up blood from decals and spread it around everywhere when walking, such as shoes or suits with integrated shoes.
  */
/datum/component/bloodysoles
	/// The type of the last grub pool we stepped in, used to decide the type of footprints to make
	var/last_blood_state = BLOOD_STATE_NOT_BLOODY

	/// How much of each grubby type we have on our feet
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)

	/// The ITEM_SLOT_* slot the item is equipped on, if it is.
	var/equipped_slot

	/// The parent item but casted into atom type for easier use.
	var/atom/parent_atom

	/// Either the mob carrying the item, or the mob itself for the /feet component subtype
	var/mob/living/carbon/wielder

	/// The world.time when we last picked up blood
	var/last_pickup

/datum/component/bloodysoles/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	parent_atom = parent

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(parent, COMSIG_IS_BLOODY, .proc/is_bloody)
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/on_clean)

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
	return equipped_slot in wielder.check_obscured_slots(TRUE)

/**
  * Run to update the icon of the parent
  */
/datum/component/bloodysoles/proc/update_icon()
	var/obj/item/parent_item = parent
	parent_item.update_slot_icon()

/**
  * Called when the parent item is equipped by someone
  *
  * Used to register our wielder
  */
/datum/component/bloodysoles/proc/on_equip(datum/source, mob/equipper, slot)
	if(!iscarbon(equipper))
		return
	var/obj/item/parent_item = parent
	if(!(parent_item.slot_flags & slot))
		unregister()
		return

	equipped_slot = slot
	wielder = equipper
	RegisterSignal(wielder, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(wielder, COMSIG_STEP_ON_BLOOD, .proc/on_step_blood)

/**
  * Called when the parent item has been dropped
  *
  * Used to deregister our wielder
  */
/datum/component/bloodysoles/proc/on_drop(datum/source, mob/dropper)
	unregister()

/**
  * Called when the wielder has moved
  *
  * Used to make bloody footprints on the ground
  */
/datum/component/bloodysoles/proc/on_moved(datum/source, OldLoc, Dir, Forced)
	if(bloody_shoes[last_blood_state] == 0)
		return
	if(QDELETED(wielder) || is_obscured())
		return
	if(!(wielder.mobility_flags & MOBILITY_STAND) || !wielder.has_gravity(wielder.loc))
		return

	// Share the blood on our boots between us and the floor
	var/blood_in_decal = bloody_shoes[last_blood_state] / 2

	// Add footprints in old loc if we have enough cream
	if(blood_in_decal >= BLOOD_FOOTPRINTS_MIN)
		for(var/obj/effect/decal/cleanable/blood/footprints/FP in get_turf(OldLoc))
			if (FP.blood_state == last_blood_state)
				FP.shoe_types |= parent.type
				if (!(FP.exited_dirs & wielder.dir))
					FP.exited_dirs |= wielder.dir
					FP.update_icon()

	// If we picked up the blood on this tick in on_step_blood, don't make footprints at the same place
	if(last_pickup && last_pickup == world.time)
		return

	// Find if new loc already has a footprint with this blood type
	var/obj/effect/decal/cleanable/blood/footprints/existing_footprint
	var/turf/T = get_turf(parent_atom)
	for(var/obj/effect/decal/cleanable/blood/footprints/FP in T)
		if (FP.blood_state == last_blood_state)
			existing_footprint = FP
			break

	// Create new footprints
	if(blood_in_decal >= BLOOD_FOOTPRINTS_MIN)
		bloody_shoes[last_blood_state] -= blood_in_decal
		if(bloody_shoes[last_blood_state] < (BLOOD_FOOTPRINTS_MIN * 2))
			// If this is true we won't be able to make any footprints next step, so give this last footprint the rest of our blood
			blood_in_decal += bloody_shoes[last_blood_state]
			bloody_shoes[last_blood_state] = 0

		if(existing_footprint)
			existing_footprint.shoe_types |= parent.type
			if (!(existing_footprint.entered_dirs & wielder.dir))
				existing_footprint.entered_dirs |= wielder.dir
				existing_footprint.update_icon()
		else
			var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
			FP.blood_state = last_blood_state
			FP.entered_dirs |= wielder.dir
			FP.bloodiness = blood_in_decal
			FP.add_blood_DNA(parent_atom.return_blood_DNA())
			FP.update_icon()

		update_icon()

/**
  * Called when the wielder steps in a pool of blood
  *
  * Used to make the parent item bloody
  */
/datum/component/bloodysoles/proc/on_step_blood(datum/source, obj/effect/decal/cleanable/pool)
	if(QDELETED(wielder) || is_obscured())
		return

	last_blood_state = pool.blood_state

	// Share the blood between our boots and the blood pool
	var/total_bloodiness = pool.bloodiness + bloody_shoes[last_blood_state]

	// We can however be limited by how much blood we can hold
	var/new_our_bloodiness = min(BLOOD_ITEM_MAX, total_bloodiness / 2)

	bloody_shoes[last_blood_state] = new_our_bloodiness
	pool.bloodiness = total_bloodiness - new_our_bloodiness // Give the pool the remaining blood incase we were limited

	parent_atom.add_blood_DNA(pool.return_blood_DNA())
	update_icon()

	last_pickup = world.time

/**
  * Called by code asking if it's bloody or not, usually for determining blood overlays
  */
/datum/component/bloodysoles/proc/is_bloody(datum/source)
	return bloody_shoes[BLOOD_STATE_HUMAN] > 0

/**
  * Called when the parent item is being washed
  */
/datum/component/bloodysoles/proc/on_clean(datum/source, clean_types)
	if(!(clean_types & CLEAN_TYPE_BLOOD) || last_blood_state == BLOOD_STATE_NOT_BLOODY)
		return

	bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	last_blood_state = BLOOD_STATE_NOT_BLOODY
	update_icon()
	return TRUE


/**
  * Like its parent but can be applied to carbon mobs instead of clothing items
  */
/datum/component/bloodysoles/feet

/datum/component/bloodysoles/feet/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	parent_atom = parent
	wielder = parent

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/on_clean)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(parent, COMSIG_STEP_ON_BLOOD, .proc/on_step_blood)
	RegisterSignal(parent, COMSIG_IS_BLOODY, .proc/is_bloody)

/datum/component/bloodysoles/feet/update_icon()
	if(ishuman(wielder))
		testing("Update icon - is bloody: [is_bloody() ? "Yes" : "No"] - has shoes: [wielder.shoes ? "Yes" : "No"]")
		// Monkeys get no bloody feet :(
		if(is_bloody() && !wielder.shoes)
			wielder.overlays_standing[SHOES_LAYER] = mutable_appearance('icons/effects/blood.dmi', "shoeblood", -SHOES_LAYER)
			wielder.apply_overlay(SHOES_LAYER)
		else
			wielder.update_inv_shoes()

/datum/component/bloodysoles/feet/is_obscured()
	if(wielder.shoes)
		return TRUE
	return ITEM_SLOT_FEET in wielder.check_obscured_slots(TRUE)

/datum/component/bloodysoles/feet/on_moved(datum/source, OldLoc, Dir, Forced)
	if(wielder.get_num_legs(FALSE) < 2)
		return

	..()

/datum/component/bloodysoles/feet/on_step_blood(datum/source, obj/effect/decal/cleanable/pool)
	if(wielder.get_num_legs(FALSE) < 2)
		return

	..()
