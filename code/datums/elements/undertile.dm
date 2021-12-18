///Add to an object if you want to be able to be hidden under tiles
/datum/element/undertile
	element_flags = ELEMENT_BESPOKE | COMPONENT_DUPE_HIGHLANDER
	id_arg_index = 2

	///the invisiblity trait applied, like TRAIT_T_RAY_VISIBLE
	var/invisibility_trait
	///level of invisibility applied when under a tile. Could be INVISIBILITY_OBSERVER if you still want it to be visible to ghosts
	var/invisibility_level
	///an overlay for the tile if we wish to apply that
	var/tile_overlay
	///whether we use alpha or not. TRUE uses ALPHA_UNDERTILE because otherwise we have 200 different instances of this element for different alphas
	var/use_alpha
	///We will switch between anchored and unanchored. for stuff like satchels that shouldn't be pullable under tiles but are otherwise unanchored
	var/use_anchor

	///whether we are nullspacing the target when their tile is covered. we dont do much management here as we assume the target is correctly
	///using and setting their associated_loc var.
	var/nullspace_target

/datum/element/undertile/Attach(datum/target, invisibility_trait, invisibility_level = INVISIBILITY_MAXIMUM, tile_overlay, use_alpha = TRUE, use_anchor = FALSE, nullspace_target = FALSE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.invisibility_trait = invisibility_trait
	src.invisibility_level = invisibility_level
	src.tile_overlay = tile_overlay
	src.use_alpha = use_alpha
	src.use_anchor = use_anchor
	src.nullspace_target = nullspace_target

	RegisterSignal(target, COMSIG_OBJ_HIDE, .proc/hide)

	//if(nullspace_target) //TODOKYLER: add to this because we need to manage target based on what happens to its associated_loc

///called when a tile has been covered or uncovered
/datum/element/undertile/proc/hide(atom/movable/source, covered)
	SIGNAL_HANDLER

	source.invisibility = covered ? invisibility_level : 0

	var/turf/acting_loc
	if(nullspace_target)
		acting_loc = source.associated_loc

	else
		acting_loc = get_turf(source)

	if(covered)
		if(invisibility_trait)
			ADD_TRAIT(source, invisibility_trait, ELEMENT_TRAIT(type))
		if(tile_overlay)
			acting_loc.add_overlay(tile_overlay)
		if(use_alpha)
			source.alpha = ALPHA_UNDERTILE
		if(use_anchor)
			source.set_anchored(TRUE)
		if(nullspace_target)
			source.loc = null //we dont do this often, but if something is supposed to nullspace it should be setting and using associated_loc correctly anyways

	else
		if(invisibility_trait)
			REMOVE_TRAIT(source, invisibility_trait, ELEMENT_TRAIT(type))
		if(tile_overlay)
			acting_loc.overlays -= tile_overlay
		if(use_alpha)
			source.alpha = 255
		if(use_anchor)
			source.set_anchored(FALSE)
		if(nullspace_target)
			source.loc = acting_loc

/datum/element/undertile/Detach(atom/movable/AM, visibility_trait, invisibility_level = INVISIBILITY_MAXIMUM)
	. = ..()

	hide(AM, FALSE)
