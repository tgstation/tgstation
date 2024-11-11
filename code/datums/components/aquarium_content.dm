/// Allows movables to be inserted/displayed in aquariums.
/datum/component/aquarium_content

	//This is visual effect holder that will end up in aquarium's vis_contents
	var/obj/effect/aquarium/vc_obj

	/**
	 * Fish sprite how to:
	 * The aquarium icon state needs to be centered on 16,16 in the dmi and facing left by default.
	 * sprite_width/sprite_height are the sizes it will have in aquarium and used to control animation boundaries.
	 * Ideally these two vars represent the size of the aquarium icon state, but they can be one or two units shorter
	 * to give more room for the visual to float around inside the aquarium, since the aquarium tank frame overlay will likely
	 * cover the extra pixels anyway.
	 */

	/// Currently playing animation
	var/current_animation

	/// Does this behviour need additional processing in aquarium, will be added to SSobj processing on insertion
	var/processing = FALSE

	/// Signals of the parent that will trigger animation update
	var/animation_update_signals

/datum/component/aquarium_content/Initialize(animation_update_signals)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.animation_update_signals = animation_update_signals
	if(animation_update_signals)
		RegisterSignals(parent, animation_update_signals, PROC_REF(generate_animation))

	ADD_TRAIT(parent, TRAIT_FISH_CASE_COMPATIBILE, REF(src))
	RegisterSignal(parent, COMSIG_TRY_INSERTING_IN_AQUARIUM, PROC_REF(is_ready_to_insert))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(enter_aquarium))

	//If component is added to something already in aquarium at the time initialize it properly.
	var/atom/movable/movable_parent = parent
	if(isaquarium(movable_parent.loc))
		on_inserted(movable_parent.loc)

/datum/component/aquarium_content/PreTransfer()
	. = ..()
	REMOVE_TRAIT(parent, TRAIT_FISH_CASE_COMPATIBILE, REF(src))

/datum/component/aquarium_content/Destroy(force)
	var/atom/movable/movable = parent
	if(isaquarium(movable.loc))
		remove_from_aquarium(movable.loc)
	QDEL_NULL(vc_obj)
	return ..()

/datum/component/aquarium_content/proc/enter_aquarium(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(isaquarium(movable_parent.loc))
		on_inserted(movable_parent.loc)

/datum/component/aquarium_content/proc/is_ready_to_insert(datum/source, atom/movable/aquarium)
	SIGNAL_HANDLER
	if(HAS_TRAIT(parent, TRAIT_UNIQUE_AQUARIUM_CONTENT))
		for(var/atom/movable/content as anything in aquarium)
			if(content == parent)
				continue
			if(content.type == parent.type)
				return COMSIG_CANNOT_INSERT_IN_AQUARIUM
	return COMSIG_CAN_INSERT_IN_AQUARIUM

/datum/component/aquarium_content/proc/on_inserted(atom/movable/aquarium)
	RegisterSignal(aquarium, COMSIG_ATOM_EXITED, PROC_REF(on_removed))
	RegisterSignal(aquarium, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_fluid_changed))

	if(processing)
		START_PROCESSING(SSobj, src)

	//If we don't have vc object yet build it
	if(!vc_obj)
		generate_base_vc()

	//Set default position and layer
	set_vc_base_position()
	generate_animation(reset = TRUE)

	//Finally add it to to objects vis_contents
	aquarium.vis_contents |= vc_obj

/datum/component/aquarium_content/proc/on_fluid_changed(datum/source, new_fluid_type)
	SIGNAL_HANDLER
	vc_obj.fluid_type = new_fluid_type
	generate_animation()

///Sends a signal to the parent to get them to update the aquarium animation of the visual object
/datum/component/aquarium_content/proc/generate_animation(reset=FALSE)
	var/atom/movable/movable = parent
	SEND_SIGNAL(parent, COMSIG_AQUARIUM_CONTENT_DO_ANIMATION, reset ? null : current_animation, movable.loc, vc_obj)

/// Generates common visual object, propeties that don't depend on aquarium surface
/datum/component/aquarium_content/proc/generate_base_vc()
	vc_obj = new
	vc_obj.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_PLANE //plane so it shows properly in containers on inventory ui for handheld cases
	SEND_SIGNAL(parent, COMSIG_AQUARIUM_CONTENT_GENERATE_APPEARANCE, vc_obj)

/datum/component/aquarium_content/proc/set_vc_base_position()
	var/atom/movable/movable = parent
	SEND_SIGNAL(movable, COMSIG_AQUARIUM_CONTENT_RANDOMIZE_POSITION, movable.loc, vc_obj)
	SEND_SIGNAL(movable.loc, COMSIG_AQUARIUM_SET_VISUAL, vc_obj)

/datum/component/aquarium_content/proc/on_removed(atom/movable/aquarium, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(parent != gone)
		return
	remove_from_aquarium(aquarium)

/datum/component/aquarium_content/proc/remove_from_aquarium(atom/movable/aquarium)
	UnregisterSignal(aquarium, list(COMSIG_AQUARIUM_FLUID_CHANGED, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EXITED))
	SEND_SIGNAL(aquarium, COMSIG_AQUARIUM_REMOVE_VISUAL, vc_obj)

///The visual overlay of the aquarium content. It can hold a few vars with values about the component of the aquarium it's in.
/obj/effect/aquarium
	layer = 0 //set on set_vc_base_position
	/// How the visual will be layered
	var/layer_mode = AQUARIUM_LAYER_MODE_AUTO
	///minimum pixel x, inherited from the aquarium
	var/aquarium_zone_min_px
	///maximum pixel x, inherited from the aquarium
	var/aquarium_zone_max_px
	///minimum pixel y, inherited from the aquarium
	var/aquarium_zone_min_py
	///maximum pixel y, inherited from the aquarium
	var/aquarium_zone_max_py
	///The current fluid type, inherited fom the aquarium
	var/fluid_type
