/datum/component/nullspace_undertile
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

	///the overlay applied to parent's associated_loc when the turf doesnt show its undertiles at all
	var/mutable_appearance/tile_overlay

	///the underlaylay applied to parent's associated_loc when the turf is UNDERFLOOR_VISIBLE and parent is set to nullspace in that case.
	///essentially its parents appearance manually copied on any changes and applied as an underlay to its associated_loc.
	///used so we can keep our maptick improvements when parent is on a turf that shows undertiles but doesnt allow interacting with them.
	var/mutable_appearance/nullspace_underlay

	///applies this trait to parent when its completely hidden.
	var/invisibility_trait

/datum/component/nullspace_undertile/Initialize(mutable_appearance/tile_overlay, invisibility_trait, nullspace_when_underfloor_visible = FALSE)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/obj_parent = parent

	src.tile_overlay = tile_overlay
	src.invisibility_trait = invisibility_trait

	if(nullspace_when_underfloor_visible)
		nullspace_underlay = new()
		nullspace_underlay.appearance = obj_parent.appearance
		RegisterSignal(parent, COMSIG_ATOM_UPDATED_APPEARANCE, .proc/on_updated_appearance)

	RegisterSignal(parent, COMSIG_OBJ_HIDE, .proc/on_hide)

/datum/component/nullspace_undertile/UnregisterFromParent()
	. = ..()
	on_hide(parent, UNDERFLOOR_VISIBLE)

/datum/component/nullspace_undertile/proc/on_hide(obj/source, underfloor_accessibility)
	SIGNAL_HANDLER

	var/turf/real_loc = source.associated_loc
	if(!real_loc)
		CRASH("[parent] had a nullspace_undertile component without a used associated_loc!")

	switch(underfloor_accessibility)
		if(UNDERFLOOR_HIDDEN)
			source.loc = null
			if(tile_overlay)
				real_loc.add_overlay(tile_overlay)
			if(nullspace_underlay)
				real_loc.underlays -= nullspace_underlay
			if(invisibility_trait)
				ADD_TRAIT(parent, invisibility_trait, TRAIT_GENERIC)

		if(UNDERFLOOR_VISIBLE)
			if(nullspace_underlay) //if this exists then we nullspace in this case
				source.loc = null
				real_loc.underlays += nullspace_underlay
			else
				source.loc = real_loc
			if(tile_overlay)
				real_loc.cut_overlay(tile_overlay)
			if(invisibility_trait)
				REMOVE_TRAIT(parent, invisibility_trait, TRAIT_GENERIC)

		if(UNDERFLOOR_INTERACTABLE)
			source.loc = real_loc
			if(tile_overlay)
				real_loc.cut_overlay(tile_overlay)
			if(nullspace_underlay)
				real_loc.underlays -= nullspace_underlay
			if(invisibility_trait)
				REMOVE_TRAIT(parent, invisibility_trait, TRAIT_GENERIC)

/datum/component/nullspace_undertile/proc/on_updated_appearance(obj/source, updates)
	SIGNAL_HANDLER

	var/turf/real_loc = source.associated_loc
	if(!real_loc)
		nullspace_underlay.appearance = source.appearance
		return

	real_loc.underlays -= nullspace_underlay

	nullspace_underlay.appearance = source.appearance

	if(real_loc.underfloor_accessibility == UNDERFLOOR_VISIBLE)
		real_loc.underlays += nullspace_underlay

