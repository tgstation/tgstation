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

	/// Signals for the aquarium we're in that trigger an animation update
	var/list/animation_update_signals

/datum/component/aquarium_content/Initialize(animation_update_signals)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.animation_update_signals = islist(animation_update_signals) ? animation_update_signals : list(animation_update_signals)

	ADD_TRAIT(parent, TRAIT_AQUARIUM_CONTENT, REF(src))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(enter_aquarium))

	//If component is added to something already in aquarium at the time initialize it properly.
	var/atom/movable/movable_parent = parent
	if(movable_parent.loc && HAS_TRAIT(movable_parent.loc, TRAIT_IS_AQUARIUM))
		on_inserted(movable_parent.loc)

/datum/component/aquarium_content/Destroy(force)
	var/atom/movable/movable = parent
	if(movable.loc && HAS_TRAIT(movable.loc, TRAIT_IS_AQUARIUM))
		remove_from_aquarium(movable.loc)
	QDEL_NULL(vc_obj)
	REMOVE_TRAIT(parent, TRAIT_AQUARIUM_CONTENT, REF(src))
	return ..()

/datum/component/aquarium_content/proc/enter_aquarium(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(HAS_TRAIT(movable_parent.loc, TRAIT_IS_AQUARIUM))
		on_inserted(movable_parent.loc)

/datum/component/aquarium_content/proc/on_inserted(atom/movable/aquarium)
	RegisterSignal(aquarium, COMSIG_ATOM_EXITED, PROC_REF(on_removed))
	RegisterSignal(aquarium, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_fluid_changed))
	RegisterSignals(aquarium, animation_update_signals, PROC_REF(animation_update_signal_proc))

	if(processing)
		START_PROCESSING(SSobj, src)

	//If we don't have vc object yet build it
	if(!vc_obj)
		generate_base_vc(aquarium)

	//Set default position and layer
	set_vc_base_position()
	generate_animation(reset = TRUE)

	//Finally add it to to objects vis_contents
	aquarium.vis_contents |= vc_obj

/datum/component/aquarium_content/proc/on_fluid_changed(datum/source, new_fluid_type)
	SIGNAL_HANDLER
	vc_obj.fluid_type = new_fluid_type
	generate_animation()

///Called when one of the signals in the 'animation_update_signals' is sent
/datum/component/aquarium_content/proc/animation_update_signal_proc(datum/source)
	generate_animation()

///Sends a signal to the parent to get them to update the aquarium animation of the visual object
/datum/component/aquarium_content/proc/generate_animation(reset = FALSE)
	var/atom/movable/movable = parent
	SEND_SIGNAL(movable, COMSIG_AQUARIUM_CONTENT_DO_ANIMATION, reset ? null : current_animation, vc_obj)

/// Generates common visual object, propeties that don't depend on aquarium surface
/datum/component/aquarium_content/proc/generate_base_vc(atom/movable/aquarium)
	vc_obj = new
	vc_obj.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_PLANE //plane so it shows properly in containers on inventory ui for handheld cases
	SEND_SIGNAL(parent, COMSIG_AQUARIUM_CONTENT_GENERATE_APPEARANCE, vc_obj, aquarium)

/datum/component/aquarium_content/proc/set_vc_base_position()
	var/atom/movable/movable = parent
	SEND_SIGNAL(movable.loc, COMSIG_AQUARIUM_SET_VISUAL, vc_obj) //set the necessary layer as well as the pixel bounds first
	SEND_SIGNAL(movable, COMSIG_AQUARIUM_CONTENT_RANDOMIZE_POSITION, movable.loc, vc_obj)

/datum/component/aquarium_content/proc/on_removed(atom/movable/aquarium, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(parent != gone)
		return
	remove_from_aquarium(aquarium)

/datum/component/aquarium_content/proc/remove_from_aquarium(atom/movable/aquarium)
	UnregisterSignal(aquarium, list(COMSIG_AQUARIUM_FLUID_CHANGED, COMSIG_ATOM_EXITED) + animation_update_signals)
	SEND_SIGNAL(aquarium, COMSIG_AQUARIUM_REMOVE_VISUAL, vc_obj)

///The visual overlay of the aquarium content. It can hold a few vars with values about the component of the aquarium it's in.
/obj/effect/aquarium
	layer = 0 //set on set_vc_base_position
	/// How the visual will be layered
	var/layer_mode = AQUARIUM_LAYER_MODE_AUTO
	///minimum pixel x, inherited from the aquarium
	var/aquarium_zone_min_pw
	///maximum pixel x, inherited from the aquarium
	var/aquarium_zone_max_pw
	///minimum pixel y, inherited from the aquarium
	var/aquarium_zone_min_pz
	///maximum pixel y, inherited from the aquarium
	var/aquarium_zone_max_pz
	///The current fluid type, inherited fom the aquarium
	var/fluid_type
