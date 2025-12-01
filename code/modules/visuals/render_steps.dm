/**
 * Internal atom that uses render relays to apply "appearance things" to a render source
 * Branch, subtypes have behavior
*/
/atom/movable/render_step
	name = "render step"
	plane = DEFAULT_PLANE
	layer = FLOAT_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	//Why?
	//render_targets copy the transform of the target as well, but vis_contents also applies the transform
	//we'll display using that, so we gotta reset
	appearance_flags = KEEP_APART|KEEP_TOGETHER|RESET_TRANSFORM

/atom/movable/render_step/Initialize(mapload, atom/source)
	. = ..()
	verbs.Cut() //Cargo cultttttt

	if(!source)
		return

	render_source = source.render_target
	SET_PLANE_EXPLICIT(src, initial(plane), source)
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_source_deleting))

/atom/movable/render_step/ex_act(severity)
	return FALSE

/atom/movable/render_step/singularity_act()
	return

/atom/movable/render_step/singularity_pull(atom/singularity, current_size)
	return

/atom/movable/render_step/blob_act()
	return

//Prevents people from moving these after creation, because they shouldn't be.
/atom/movable/render_step/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()

/atom/movable/render_step/proc/on_source_deleting(atom/source)
	SIGNAL_HANDLER

	if(!QDELING(src))
		qdel(src)

/**
 * Render step that modfies an atom's color
 * Useful for creating coherent emissive blockers out of things like glass floors by lowering alpha statically using matrixes
 * Other stuff too I'm sure
 */
/atom/movable/render_step/color
	name = "color step"
	//RESET_COLOR is obvious I hope
	appearance_flags = KEEP_APART|KEEP_TOGETHER|RESET_COLOR|RESET_TRANSFORM

/atom/movable/render_step/color/Initialize(mapload, atom/source, color)
	. = ..()
	src.color = color

/**
 * Render step that makes the passed in render source block emissives
 *
 * Copies an appearance vis render_target and render_source on to the emissive blocking plane.
 * This means that the atom in question will block any emissive sprites.
 * This should only be used internally. If you are directly creating more of these, you're
 * almost guaranteed to be doing something wrong.
 */
/atom/movable/render_step/emissive_blocker
	name = "emissive blocker"
	plane = EMISSIVE_PLANE
	appearance_flags = EMISSIVE_APPEARANCE_FLAGS|RESET_TRANSFORM

/atom/movable/render_step/emissive_blocker/Initialize(mapload, atom/source)
	. = ..()
	src.color = GLOB.em_block_color

/**
 * Render step that makes the passed in render source GLOW
 *
 * Copies an appearance vis render_target and render_source on to the emissive plane
 */
/atom/movable/render_step/emissive
	name = "emissive"
	plane = EMISSIVE_PLANE
	appearance_flags = EMISSIVE_APPEARANCE_FLAGS|RESET_TRANSFORM

/atom/movable/render_step/emissive/Initialize(mapload, source)
	. = ..()
	src.color = GLOB.emissive_color
