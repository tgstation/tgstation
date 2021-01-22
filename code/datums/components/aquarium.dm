#define AQUARIUM_ANIMATION_FISH_SWIM "fish"
#define AQUARIUM_ANIMATION_FISH_DEAD "dead"

#define AQUARIUM_PROPERTIES_PX_MIN "px_min"
#define AQUARIUM_PROPERTIES_PX_MAX "px_max"
#define AQUARIUM_PROPERTIES_PY_MIN "py_min"
#define AQUARIUM_PROPERTIES_PY_MAX "py_max"

#define AQUARIUM_LAYER_MODE_BOTTOM "bottom"
#define AQUARIUM_LAYER_MODE_TOP "top"
#define AQUARIUM_LAYER_MODE_AUTO "auto"

/datum/component/aquarium_content
	/// This is a datum that describes our in-aquarium functionality
	var/datum/aquarium_behaviour/properties

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

/datum/component/aquarium_content/Initialize(property_type)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	if(ispath(property_type,/datum/aquarium_behaviour))
		properties = new property_type
	else
		CRASH("Invalid property type provided for aquarium content component")
	properties.parent = src

	RegisterSignal(parent, COMSIG_AQUARIUM_INSERT_READY, .proc/is_ready_to_insert)
	RegisterSignal(parent, COMSIG_AQUARIUM_INSERTED, .proc/on_inserted)
	RegisterSignal(parent, COMSIG_AQUARIUM_REMOVED, .proc/on_removed)
	RegisterSignal(parent, COMSIG_AQUARIUM_FISH_CASE_STASIS, .proc/on_tank_stasis)

/datum/component/aquarium_content/Destroy(force, silent)
	if(current_aquarium)
		remove_from_aquarium()
	QDEL_NULL(vc_obj)
	QDEL_NULL(properties)
	return ..()

/datum/component/aquarium_content/proc/is_ready_to_insert(datum/source,atom/aquarium_object)
	SIGNAL_HANDLER
	//This is kinda awful but we're unaware of other fish
	if(properties.unique)
		for(var/atom/movable/AM in aquarium_object)
			if(AM == parent)
				continue
			var/datum/component/aquarium_content/other_content = AM.GetComponent(/datum/component/aquarium_content)
			if(other_content && other_content.properties.type == properties.type)
				return 0
	return AQUARIUM_CONTENT_READY_TO_INSERT

/datum/component/aquarium_content/proc/on_inserted(datum/source,atom/aquarium)
	SIGNAL_HANDLER

	current_aquarium = aquarium

	RegisterSignal(current_aquarium,COMSIG_AQUARIUM_SURFACE_CHANGED, .proc/on_surface_changed)
	RegisterSignal(current_aquarium,COMSIG_AQUARIUM_FEEDING, .proc/on_feeding)
	RegisterSignal(current_aquarium,COMSIG_AQUARIUM_FLUID_CHANGED,.proc/on_fluid_changed)
	RegisterSignal(current_aquarium, COMSIG_AQUARIUM_STIRRED, .proc/on_stirred)
	if(properties.processing)
		START_PROCESSING(SSobj,properties)

	//If we don't have vc object yet build it
	if(!vc_obj)
		vc_obj = generate_base_vc()

	//Set default position and layer
	set_vc_base_position()
	generate_animation()

	//Finally add it to to objects vis_contents
	current_aquarium.vis_contents |= vc_obj


/// Aquarium surface changed in some way, we need to recalculate base position and aninmation
/datum/component/aquarium_content/proc/on_surface_changed()
	SIGNAL_HANDLER
	set_vc_base_position()
	generate_animation() //our animation start point changed, gotta redo

/// Aquarium surface changed in some way, we need to recalculate base position and aninmation
/datum/component/aquarium_content/proc/on_stirred()
	SIGNAL_HANDLER
	generate_animation()

/datum/component/aquarium_content/proc/on_feeding(datum/source, datum/reagents/feed_reagents)
	SIGNAL_HANDLER
	properties.on_feeding(feed_reagents)

/datum/component/aquarium_content/proc/on_fluid_changed()
	SIGNAL_HANDLER
	properties.on_fluid_changed()

/datum/component/aquarium_content/proc/remove_visual_from_aquarium()
	current_aquarium.vis_contents -= vc_obj
	if(base_layer)
		current_aquarium.free_layer(base_layer)


/// Generates common visual object, propeties that don't depend on aquarium surface
/datum/component/aquarium_content/proc/generate_base_vc()
	if(!properties)
		CRASH("Generating visual without properties.")

	var/obj/effect/visual = new
	properties.apply_appearance(visual)
	visual.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_PLANE //plane so it shows properly in containers on inventory ui for handheld cases
	return visual

/// Actually animates the vc holder
/datum/component/aquarium_content/proc/generate_animation()
	switch(properties.current_animation)
		if(AQUARIUM_ANIMATION_FISH_SWIM)
			swim_animation()
			return
		if(AQUARIUM_ANIMATION_FISH_DEAD)
			dead_animation()
			return


/// Create looping random path animation, pixel offsets parameters include offsets already
/datum/component/aquarium_content/proc/swim_animation()
	var/avg_width = round(properties.sprite_width/2)
	var/avg_height = round(properties.sprite_height/2)

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
	var/move_number = rand(3,5) //maybe unhardcode this
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
		var/matrix/dir_mx = properties.base_transform()
		if(dx <= 0) //assuming default sprite is facing left here
			dir_mx.Scale(-1,1)
		animate(transform=dir_mx,time=0,loop = -1)
		animate(pixel_x=target_x,pixel_y = target_y, time = eyeballed_time, loop = -1)

/datum/component/aquarium_content/proc/dead_animation()
	//Set base_py to lowest possible value
	var/avg_height = round(properties.sprite_height/2)
	var/list/aq_properties = current_aquarium.get_surface_properties()
	var/py_min = aq_properties[AQUARIUM_PROPERTIES_PY_MIN] + avg_height - 16
	base_py = py_min
	animate(vc_obj, pixel_y = py_min, time = 1) //flop to bottom and end current animation.


/// Floating to top animation.
/datum/component/aquarium_content/proc/float_animation()
	return


/datum/component/aquarium_content/proc/set_vc_base_position()
	var/list/aq_properties = current_aquarium.get_surface_properties()
	if(properties.randomize_position)
		var/avg_width = round(properties.sprite_width/2)
		var/avg_height = round(properties.sprite_height/2)
		var/px_min = aq_properties[AQUARIUM_PROPERTIES_PX_MIN] + avg_width - 16
		var/px_max = aq_properties[AQUARIUM_PROPERTIES_PX_MAX] - avg_width - 16
		var/py_min = aq_properties[AQUARIUM_PROPERTIES_PY_MIN] + avg_height - 16
		var/py_max = aq_properties[AQUARIUM_PROPERTIES_PY_MAX] - avg_width - 16

		base_px = rand(px_min,px_max)
		base_py = rand(py_min,py_max)

		vc_obj.pixel_x = base_px
		vc_obj.pixel_y = base_py

	if(base_layer)
		current_aquarium.free_layer(base_layer)
	base_layer = current_aquarium.request_layer(properties.layer_mode)
	vc_obj.layer = base_layer

/datum/component/aquarium_content/proc/on_removed(datum/source,aquarium)
	SIGNAL_HANDLER
	remove_from_aquarium()

/datum/component/aquarium_content/proc/remove_from_aquarium()
	UnregisterSignal(current_aquarium,list(COMSIG_AQUARIUM_SURFACE_CHANGED,COMSIG_AQUARIUM_FLUID_CHANGED,COMSIG_AQUARIUM_FEEDING,COMSIG_AQUARIUM_STIRRED))
	remove_visual_from_aquarium()
	current_aquarium = null
	//We do not stop processing properties here. We want fish to die outside of aquariums after first insert. We only stop processing in properties.death or destroy

/datum/component/aquarium_content/proc/on_tank_stasis()
	SIGNAL_HANDLER
	// Stop processing until inserted into aquarium again.
	STOP_PROCESSING(SSobj, properties)

/datum/component/aquarium_content/Destroy(force, silent)
	if(current_aquarium)
		remove_from_aquarium()
	QDEL_NULL(properties)
	. = ..()

