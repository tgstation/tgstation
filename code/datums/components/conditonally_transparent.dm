/datum/component/conditionally_transparent
	/// Delay used before starting to fade in
	var/transparency_delay
	/// midpoint alpha to animate between when fading in
	var/in_midpoint_alpha
	/// alpha to use when invisible
	var/transparent_alpha
	/// Delay used before starting to fade in
	var/opacity_delay
	/// midpoint alpha to animate between when fading out
	var/out_midpoint_alpha

/datum/component/conditionally_transparent/Initialize(
	list/transparent_signals,
	list/opaque_signals,
	start_transparent,
	transparency_delay,
	in_midpoint_alpha,
	transparent_alpha,
	opacity_delay,
	out_midpoint_alpha,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	src.transparency_delay = transparency_delay
	src.in_midpoint_alpha = in_midpoint_alpha
	src.transparent_alpha = transparent_alpha
	src.opacity_delay = opacity_delay
	src.out_midpoint_alpha = out_midpoint_alpha
	if(start_transparent)
		atom_parent.alpha = transparent_alpha
		atom_parent.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	RegisterSignals(atom_parent, transparent_signals, PROC_REF(make_transparent))
	RegisterSignals(atom_parent, opaque_signals, PROC_REF(make_opaque))

/datum/component/conditionally_transparent/Destroy(force)
	var/atom/atom_parent = parent
	if(atom_parent.alpha == transparent_alpha)
		atom_parent.alpha = initial(atom_parent.alpha)
		atom_parent.mouse_opacity = initial(atom_parent.mouse_opacity)
	return ..()

/datum/component/conditionally_transparent/proc/make_transparent(datum/source)
	SIGNAL_HANDLER
	var/atom/atom_parent = parent
// Current CI version of spaceman doesn't support delay and bumping it makes tgs mad so we're gonna do this till ci matches 1.9
#ifndef SPACEMAN_DMM
	animate(atom_parent, alpha = in_midpoint_alpha, easing = QUAD_EASING, time = 0.7 SECONDS, delay = transparency_delay)
	animate(alpha = transparent_alpha, easing = QUAD_EASING, time = 0.3 SECONDS)
#endif
	addtimer(VARSET_CALLBACK(atom_parent, mouse_opacity, MOUSE_OPACITY_TRANSPARENT), transparency_delay + (1 SECONDS))

/datum/component/conditionally_transparent/proc/make_opaque(datum/source)
	SIGNAL_HANDLER
	var/atom/atom_parent = parent
#ifndef SPACEMAN_DMM
	animate(atom_parent, alpha = out_midpoint_alpha, easing = QUAD_EASING, time = 0.7 SECONDS, delay = opacity_delay)
	animate(alpha = 255, easing = QUAD_EASING, time = 0.3 SECONDS)
#endif
	addtimer(VARSET_CALLBACK(atom_parent, mouse_opacity, initial(atom_parent.mouse_opacity)), opacity_delay + (1 SECONDS))
