/// Allows us to intercept overlay lighting's well, light overlays
/// Normally these are static, but by giving them a render source and copying their base appearance
/// Animating this datum's child objects allows us to do SO much fun stuff
/datum/light_middleman
	/// Owning parent we're interceeding for
	/// Could in theory be a turf but lies to areas means we have to pick something to type it as
	var/atom/movable/parent
	/// The holder we are currently displaying our light on
	var/atom/movable/light_holder
	/// Holds the primary light source
	var/obj/effect/abstract/light_middleman/primary_intercept
	/// Exists to hold the cone so children can modify it if they want
	var/obj/effect/abstract/light_middleman/cone_intercept
	/// Are we overriding the light already?
	var/overriding = FALSE
	/// Weakref to the object we are displaying our effects on
	var/datum/weakref/holder_ref

/datum/light_middleman/New(atom/parent, unique_string)
	. = ..()
	if(!IS_OVERLAY_LIGHT_SYSTEM(parent.light_system))
		stack_trace("Attempted to create a light middleman with a parent [parent.type] that does not use overlay lighting! This will not work.")
	if(isturf(parent))
		stack_trace("Warning, becuase overlay lights are basically never used on turfs, since they don't move,\
			vis contents replacement has not yet been implemented for them (see changeturf for why this is needed)!")
	src.parent = parent
	primary_intercept = new()
	cone_intercept = new()
	var/static/uuid = 0
	uuid = WRAP_UID(uuid + 1)
	primary_intercept.render_target = "*[unique_string]_[uuid]_target"
	cone_intercept.render_target = "[primary_intercept.render_target]_cone" // made to mirror how overlay lights work

/datum/light_middleman/Destroy(force)
	stop_overriding_light()
	QDEL_NULL(primary_intercept)
	QDEL_NULL(cone_intercept)
	parent = null
	light_holder = null
	return ..()

/datum/light_middleman/proc/being_overriding_light(unique_string)
	if(overriding)
		return
	overriding = TRUE
	// We register here because our later set render source will always trigger a refresh and thus let us capture appearances properly
	// Assuming there's an overlay light on the other side
	RegisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_APPLIED, PROC_REF(light_applied))
	RegisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_REMOVED, PROC_REF(light_removed))
	parent.set_light_render_source(primary_intercept.render_target)

/datum/light_middleman/proc/stop_overriding_light()
	if(!overriding)
		return
	overriding = FALSE
	UnregisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_APPLIED)
	UnregisterSignal(parent, COMSIG_ATOM_OVERLAY_LIGHT_REMOVED)
	var/atom/movable/old_holder = holder_ref?.resolve()
	if(old_holder)
		old_holder.vis_contents -= primary_intercept
		old_holder.vis_contents -= cone_intercept
		holder_ref = null
	parent.set_light_render_source("")

/datum/light_middleman/proc/light_applied(datum/source, image/visible_mask, image/cone, atom/movable/light_holder)
	SIGNAL_HANDLER
	var/atom/movable/old_holder = holder_ref?.resolve()
	// If we were somewhere before, clean us out
	if(old_holder)
		old_holder.vis_contents -= primary_intercept
		old_holder.vis_contents -= cone_intercept
		holder_ref = null

	// how we make sure we're in the client's view
	light_holder.vis_contents += primary_intercept
	// Avoids unneeded effects clientside
	if(IS_OVERLAY_CONE_LIGHT_SYSTEM(parent.light_system))
		light_holder.vis_contents += cone_intercept

	old_holder = WEAKREF(light_holder)

	var/old_target = primary_intercept.render_target
	var/old_cone_target = cone_intercept.render_target
	// This will halt any animations we have ongoing so if you care about that you've gotta react to it properly
	primary_intercept.appearance = visible_mask
	cone_intercept.appearance = cone
	// set ourselves up to render back onto the visible mask
	primary_intercept.render_source = ""
	primary_intercept.render_target = old_target
	cone_intercept.render_source = ""
	cone_intercept.render_target = old_cone_target
	// Dir is important I'm told
	primary_intercept.vis_flags |= VIS_INHERIT_DIR
	cone_intercept.vis_flags |= VIS_INHERIT_DIR
	// Will double apply, here we go gang
	primary_intercept.transform = null
	cone_intercept.transform = null
	primary_intercept.color = null
	cone_intercept.color = null
	primary_intercept.alpha = 255
	cone_intercept.alpha = 255
	// Sometimes can be BLEND_SUBTRACT, we don't want that
	primary_intercept.blend_mode = BLEND_ADD
	cone_intercept.blend_mode = BLEND_ADD
	/// Allows users to hook into a refresh so they can remake their modifications to our intercepts
	SEND_SIGNAL(src, COMSIG_LIGHT_MIDDLEMAN_UPDATED)

/datum/light_middleman/proc/light_removed(datum/source, atom/movable/light_holder)
	SIGNAL_HANDLER
	light_holder.vis_contents -= primary_intercept
	light_holder.vis_contents -= cone_intercept
	holder_ref = null

/// Just... cause it's better then not having a bespoke type
/obj/effect/abstract/light_middleman
