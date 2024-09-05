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
	var/obj/effect/vc_obj

	/// Base px offset of the visual object in current aquarium aka current base position
	var/base_px = 0
	/// Base px offset of the visual object in current aquarium aka current base position
	var/base_py = 0
	//Current layer for the visual object
	var/base_layer

	/**
	 * Fish sprite how to:
	 * The aquarium icon state needs to be centered on 16,16 in the dmi and facing left by default.
	 * sprite_width/sprite_height are the sizes it will have in aquarium and used to control animation boundaries.
	 * Ideally these two vars represent the size of the aquarium icon state, but they can be one or two units shorter
	 * to give more room for the visual to float around inside the aquarium, since the aquarium tank frame overlay will likely
	 * cover the extra pixels anyway.
	 */

	/// Icon used for in aquarium sprite
	var/icon = 'icons/obj/aquarium/fish.dmi'
	/// If this is set this icon state will be used for the holder while icon_state will only be used for item/catalog. Transformation from source_width/height WON'T be applied.
	var/icon_state
	/// Applied to vc object only for use with greyscaled icons.
	var/aquarium_vc_color
	/// Transformation applied to the visual holder - used when scaled down sprites are used as in aquarium visual
	var/matrix/base_transform

	/// How the thing will be layered
	var/layer_mode = AQUARIUM_LAYER_MODE_AUTO

	/// If the starting position is randomised within bounds when inserted into aquarium.
	var/randomize_position = FALSE

	//Target sprite size for path/position calculations.
	var/sprite_height = 3
	var/sprite_width = 3

	/// Currently playing animation
	var/current_animation

	/// Does this behviour need additional processing in aquarium, will be added to SSobj processing on insertion
	var/processing = FALSE

	/// TODO: Change this into trait checked on aquarium insertion
	var/unique = FALSE

	/// Proc used to retrieve current animation state from the parent, optional
	var/animation_getter

	/// Signals of the parent that will trigger animation update
	var/animation_update_signals

	/// The current beauty this component gives to the aquarium it's in
	var/beauty

	/// The original value of the beauty this component had when initialized
	var/original_beauty

/datum/component/aquarium_content/Initialize(icon, animation_getter, animation_update_signals, beauty)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.animation_getter = animation_getter
	src.animation_update_signals = animation_update_signals
	src.beauty = original_beauty = beauty
	if(animation_update_signals)
		RegisterSignals(parent, animation_update_signals, PROC_REF(generate_animation))

	if(istype(parent,/obj/item/fish))
		InitializeFromFish()
	else if(istype(parent,/obj/item/aquarium_prop))
		InitializeFromProp()
	else
		InitializeOther()

	ADD_TRAIT(parent, TRAIT_FISH_CASE_COMPATIBILE, REF(src))
	RegisterSignal(parent, COMSIG_TRY_INSERTING_IN_AQUARIUM, PROC_REF(is_ready_to_insert))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(enter_aquarium))
	RegisterSignal(parent, COMSIG_FISH_PETTED, PROC_REF(on_fish_petted))

	//If component is added to something already in aquarium at the time initialize it properly.
	var/atom/movable/movable_parent = parent
	if(istype(movable_parent.loc, /obj/structure/aquarium))
		on_inserted(movable_parent.loc)

/// Sets visuals properties for fish
/datum/component/aquarium_content/proc/InitializeFromFish()
	var/obj/item/fish/fish = parent

	icon = fish.icon
	sprite_height = fish.sprite_height
	sprite_width = fish.sprite_width
	aquarium_vc_color = fish.aquarium_vc_color

	icon = fish.dedicated_in_aquarium_icon
	icon_state = fish.dedicated_in_aquarium_icon_state
	base_transform = matrix()

	randomize_position = TRUE

	RegisterSignal(fish, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_fish_status_changed))

/datum/component/aquarium_content/proc/on_fish_status_changed(obj/item/fish/source)
	SIGNAL_HANDLER
	var/old_beauty = beauty
	beauty = original_beauty
	if(source.status == FISH_DEAD)
		beauty = clamp(beauty + DEAD_FISH_BEAUTY, MIN_DEAD_FISH_BEAUTY, MAX_DEAD_FISH_BEAUTY)
	if(current_aquarium)
		change_aquarium_beauty(beauty - old_beauty)
	generate_animation()

/// Sets visuals properties for fish
/datum/component/aquarium_content/proc/InitializeFromProp()
	var/obj/item/aquarium_prop/prop = parent

	icon = prop.icon
	icon_state = prop.icon_state
	layer_mode = prop.layer_mode
	sprite_height = 32
	sprite_width = 32
	base_transform = matrix()

	unique = TRUE

/// Mostly for admin abuse
/datum/component/aquarium_content/proc/InitializeOther()
	sprite_width = 8
	sprite_height = 8

	var/matrix/matrix = matrix()
	var/x_scale = sprite_width / 32
	var/y_scale = sprite_height / 32
	matrix.Scale(x_scale, y_scale)
	base_transform = matrix


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
	//This is kinda awful but we're unaware of other fish
	if(unique)
		for(var/atom/movable/fish_or_prop in aquarium)
			if(fish_or_prop == parent)
				continue
			if(fish_or_prop.type == parent.type)
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
		vc_obj = generate_base_vc()

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

/datum/component/aquarium_content/proc/remove_visual_from_aquarium()
	current_aquarium.vis_contents -= vc_obj
	if(base_layer)
		current_aquarium.free_layer(base_layer)

/// Generates common visual object, propeties that don't depend on aquarium surface
/datum/component/aquarium_content/proc/generate_base_vc()
	var/obj/effect/visual = new
	apply_appearance(visual)
	visual.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_PLANE //plane so it shows properly in containers on inventory ui for handheld cases
	return visual

/// Applies icon,color and base scaling to our visual holder
/datum/component/aquarium_content/proc/apply_appearance(obj/effect/holder)
	holder.icon = icon
	holder.icon_state = icon_state
	holder.transform = matrix(base_transform)
	if(aquarium_vc_color)
		holder.color = aquarium_vc_color


/// Actually animates the vc holder
/datum/component/aquarium_content/proc/generate_animation(reset=FALSE)
	if(!current_aquarium)
		return
	var/next_animation = animation_getter ? call(parent,animation_getter)() : null
	if(current_animation == next_animation && !reset)
		return
	current_animation = next_animation
	switch(current_animation)
		if(AQUARIUM_ANIMATION_FISH_SWIM)
			swim_animation()
			return
		if(AQUARIUM_ANIMATION_FISH_DEAD)
			dead_animation()
			return

/// Create looping random path animation, pixel offsets parameters include offsets already
/datum/component/aquarium_content/proc/swim_animation()
	var/avg_width = round(sprite_width / 2)
	var/avg_height = round(sprite_height / 2)

	var/list/aq_properties = current_aquarium.get_surface_properties()
	var/px_min = aq_properties[AQUARIUM_PROPERTIES_PX_MIN] + avg_width - 16
	var/px_max = aq_properties[AQUARIUM_PROPERTIES_PX_MAX] - avg_width - 16
	var/py_min = aq_properties[AQUARIUM_PROPERTIES_PY_MIN] + avg_height - 16
	var/py_max = aq_properties[AQUARIUM_PROPERTIES_PY_MAX] - avg_width - 16

	var/origin_x = base_px
	var/origin_y = base_py
	var/prev_x = origin_x
	var/prev_y = origin_y
	animate(vc_obj, pixel_x = origin_x, time = 0, loop = -1) //Just to start the animation
	var/move_number = rand(3, 5) //maybe unhardcode this
	for(var/i in 1 to move_number)
		//If it's last movement, move back to start otherwise move to some random point
		var/target_x = i == move_number ? origin_x : rand(px_min,px_max) //could do with enforcing minimal delta for prettier zigzags
		var/target_y = i == move_number ? origin_y : rand(py_min,py_max)
		var/dx = prev_x - target_x
		var/dy = prev_y - target_y
		prev_x = target_x
		prev_y = target_y
		var/dist = abs(dx) + abs(dy)
		var/eyeballed_time = dist * 2 //2ds per px
		//Face the direction we're going
		var/matrix/dir_mx = matrix(base_transform)
		if(dx <= 0) //assuming default sprite is facing left here
			dir_mx.Scale(-1, 1)
		animate(transform = dir_mx, time = 0, loop = -1)
		animate(pixel_x = target_x, pixel_y = target_y, time = eyeballed_time, loop = -1)

/datum/component/aquarium_content/proc/dead_animation()
	//Set base_py to lowest possible value
	var/avg_height = round(sprite_height / 2)
	var/list/aq_properties = current_aquarium.get_surface_properties()
	var/py_min = aq_properties[AQUARIUM_PROPERTIES_PY_MIN] + avg_height - 16
	base_py = py_min
	animate(vc_obj, pixel_y = py_min, time = 1) //flop to bottom and end current animation.

/datum/component/aquarium_content/proc/set_vc_base_position()
	if(randomize_position)
		randomize_base_position()
	if(base_layer)
		current_aquarium.free_layer(base_layer)
	base_layer = current_aquarium.request_layer(layer_mode)
	vc_obj.layer = base_layer

/datum/component/aquarium_content/proc/on_fish_petted()
	SIGNAL_HANDLER

	new /obj/effect/temp_visual/heart(get_turf(parent))

/datum/component/aquarium_content/proc/randomize_base_position()
	var/list/aq_properties = current_aquarium.get_surface_properties()
	var/avg_width = round(sprite_width / 2)
	var/avg_height = round(sprite_height / 2)
	var/px_min = aq_properties[AQUARIUM_PROPERTIES_PX_MIN] + avg_width - 16
	var/px_max = aq_properties[AQUARIUM_PROPERTIES_PX_MAX] - avg_width - 16
	var/py_min = aq_properties[AQUARIUM_PROPERTIES_PY_MIN] + avg_height - 16
	var/py_max = aq_properties[AQUARIUM_PROPERTIES_PY_MAX] - avg_width - 16

	base_px = rand(px_min,px_max)
	base_py = rand(py_min,py_max)

	vc_obj.pixel_x = base_px
	vc_obj.pixel_y = base_py

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

#undef DEAD_FISH_BEAUTY
#undef MIN_DEAD_FISH_BEAUTY
#undef MAX_DEAD_FISH_BEAUTY
#undef MIN_AQUARIUM_BEAUTY
#undef MAX_AQUARIUM_BEAUTY
