///Malus to the beauty value if the fish content is dead
#define DEAD_FISH_BEAUTY -500
///Prevents more impressive fishes from providing a positive beauty even when dead.
#define MAX_DEAD_FISH_BEAUTY -200
///Some fish are already so ugly, they can't get much worse when dead
#define MIN_DEAD_FISH_BEAUTY -600

///Defines that clamp the beauty of the aquarium, to prevent it from making most areas great or horrid all by itself.
#define MIN_AQUARIUM_BEAUTY -3500
#define MAX_AQUARIUM_BEAUTY 6000

/// Allows movables to be inserted/displayed in aquariums.
/datum/component/aquarium_content
	/// Keeps track of our current aquarium.
	var/obj/structure/aquarium/current_aquarium

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

	/// The current beauty this component gives to the aquarium it's in
	var/beauty

	/// The original value of the beauty this component had when initialized
	var/original_beauty

/datum/component/aquarium_content/Initialize(animation_update_signals, beauty)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.animation_update_signals = animation_update_signals
	src.beauty = original_beauty = beauty
	if(animation_update_signals)
		RegisterSignals(parent, animation_update_signals, PROC_REF(generate_animation))

	ADD_TRAIT(parent, TRAIT_FISH_CASE_COMPATIBILE, REF(src))
	RegisterSignal(parent, COMSIG_TRY_INSERTING_IN_AQUARIUM, PROC_REF(is_ready_to_insert))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(enter_aquarium))

	if(isfish(parent))
		RegisterSignal(parent, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_fish_status_changed))

	//If component is added to something already in aquarium at the time initialize it properly.
	var/atom/movable/movable_parent = parent
	if(istype(movable_parent.loc, /obj/structure/aquarium))
		on_inserted(movable_parent.loc)

/datum/component/aquarium_content/proc/on_fish_status_changed(obj/item/fish/source)
	SIGNAL_HANDLER
	var/old_beauty = beauty
	beauty = original_beauty
	if(source.status == FISH_DEAD)
		beauty = clamp(beauty + DEAD_FISH_BEAUTY, MIN_DEAD_FISH_BEAUTY, MAX_DEAD_FISH_BEAUTY)
	if(current_aquarium)
		change_aquarium_beauty(beauty - old_beauty)
	generate_animation()

/datum/component/aquarium_content/PreTransfer()
	. = ..()
	REMOVE_TRAIT(parent, TRAIT_FISH_CASE_COMPATIBILE, REF(src))

/datum/component/aquarium_content/Destroy(force)
	if(current_aquarium)
		remove_from_aquarium()
	QDEL_NULL(vc_obj)
	return ..()

/datum/component/aquarium_content/proc/enter_aquarium(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(istype(movable_parent.loc, /obj/structure/aquarium))
		on_inserted(movable_parent.loc)

/datum/component/aquarium_content/proc/is_ready_to_insert(datum/source, obj/structure/aquarium/aquarium)
	SIGNAL_HANDLER
	if(HAS_TRAIT(parent, TRAIT_UNIQUE_AQUARIUM_CONTENT))
		for(var/atom/movable/content as anything in aquarium)
			if(content == parent)
				continue
			if(content.type == parent.type)
				return COMSIG_CANNOT_INSERT_IN_AQUARIUM
	return COMSIG_CAN_INSERT_IN_AQUARIUM

/datum/component/aquarium_content/proc/on_inserted(atom/aquarium)
	current_aquarium = aquarium
	RegisterSignal(current_aquarium, COMSIG_ATOM_EXITED, PROC_REF(on_removed))
	RegisterSignal(current_aquarium, COMSIG_AQUARIUM_SURFACE_CHANGED, PROC_REF(on_surface_changed))
	RegisterSignal(current_aquarium, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_fluid_changed))

	if(processing)
		START_PROCESSING(SSobj, src)

	//If we don't have vc object yet build it
	if(!vc_obj)
		generate_base_vc()

	//Set default position and layer
	set_vc_base_position()
	generate_animation(reset = TRUE)

	//Finally add it to to objects vis_contents
	current_aquarium.vis_contents |= vc_obj

	change_aquarium_beauty(beauty)

///Modifies the beauty of the aquarium when content is added or removed, or when fishes die or live again somehow.
/datum/component/aquarium_content/proc/change_aquarium_beauty(change)
	if(QDELETED(current_aquarium) || !change)
		return
	var/old_clamped_beauty = clamp(current_aquarium.current_beauty, MIN_AQUARIUM_BEAUTY, MAX_AQUARIUM_BEAUTY)
	current_aquarium.current_beauty += change
	var/new_clamped_beauty = clamp(current_aquarium.current_beauty, MIN_AQUARIUM_BEAUTY, MAX_AQUARIUM_BEAUTY)
	if(new_clamped_beauty == old_clamped_beauty)
		return
	if(current_aquarium.current_beauty)
		current_aquarium.RemoveElement(/datum/element/beauty, current_aquarium.current_beauty)
	if(current_aquarium.current_beauty)
		current_aquarium.AddElement(/datum/element/beauty, current_aquarium.current_beauty)

/// Aquarium surface changed in some way, we need to recalculate base position and aninmation
/datum/component/aquarium_content/proc/on_surface_changed()
	SIGNAL_HANDLER
	set_vc_base_position()
	generate_animation(reset = TRUE) //our animation start point changed, gotta redo

/datum/component/aquarium_content/proc/on_fluid_changed()
	SIGNAL_HANDLER
	generate_animation()

///Sends a signal to the parent to get them to update the aquarium animation of the visual object
/datum/component/aquarium_content/proc/generate_animation(reset=FALSE)
	if(!current_aquarium)
		return
	SEND_SIGNAL(parent, COMSIG_AQUARIUM_CONTENT_DO_ANIMATION, reset ? null : current_animation, current_aquarium, vc_obj)

/datum/component/aquarium_content/proc/remove_visual_from_aquarium()
	current_aquarium.vis_contents -= vc_obj
	if(vc_obj.layer)
		current_aquarium.free_layer(vc_obj.layer)

/// Generates common visual object, propeties that don't depend on aquarium surface
/datum/component/aquarium_content/proc/generate_base_vc()
	vc_obj = new
	vc_obj.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_PLANE //plane so it shows properly in containers on inventory ui for handheld cases
	SEND_SIGNAL(parent, COMSIG_AQUARIUM_CONTENT_GENERATE_APPEARANCE, vc_obj)

/datum/component/aquarium_content/proc/set_vc_base_position()
	SEND_SIGNAL(parent, AQUARIUM_CONTENT_RANDOMIZE_POSITION, current_aquarium, vc_obj)
	if(vc_obj.layer)
		current_aquarium.free_layer(vc_obj.layer)
	vc_obj.layer = current_aquarium.request_layer(vc_obj.layer_mode)

/datum/component/aquarium_content/proc/on_removed(obj/structure/aquarium/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(parent != gone)
		return
	remove_from_aquarium()

/datum/component/aquarium_content/proc/remove_from_aquarium()
	change_aquarium_beauty(-beauty)
	UnregisterSignal(current_aquarium, list(COMSIG_AQUARIUM_SURFACE_CHANGED, COMSIG_AQUARIUM_FLUID_CHANGED, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EXITED))
	remove_visual_from_aquarium()
	current_aquarium = null

///The visual overlay of the aquarium content. It holds a few vars that we can modity them during signals.
/obj/effect/aquarium
	layer = 0 //set on set_vc_base_position
	/// Base px offset of the visual object in current aquarium aka current base position
	var/base_px = 0
	/// Base px offset of the visual object in current aquarium aka current base position
	var/base_py = 0
	/// How the visual will be layered
	var/layer_mode = AQUARIUM_LAYER_MODE_AUTO

#undef DEAD_FISH_BEAUTY
#undef MIN_DEAD_FISH_BEAUTY
#undef MAX_DEAD_FISH_BEAUTY
#undef MIN_AQUARIUM_BEAUTY
#undef MAX_AQUARIUM_BEAUTY
