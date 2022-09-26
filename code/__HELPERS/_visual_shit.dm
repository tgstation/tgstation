
// Plane setter
/// Ok so hear me out yeah?
/// Lets imagine we know how many z levels are stacked on top of each other
/// If we know that, we can autogenerate plane masters to sit on top/below them
/// We only need as many plane masters as the maximum of all z level stacks
#define SET_PLANE_IMPLICIT(thing, new_value) SET_PLANE_EXPLICIT(thing, new_value, thing)

// This is an unrolled and optimized version of SET_PLANE, for use anywhere where you are unsure of a source's "turfness"
// The plane is cached to allow for fancy stuff to be eval'd once, rather then often
#define SET_PLANE_EXPLICIT(thing, new_value, source) \
	do {\
		if(SSmapping.max_plane_offset) {\
			var/_cached_plane = new_value;\
			var/turf/_our_turf = get_turf(source);\
			if(_our_turf){\
				thing.plane = GET_NEW_PLANE(_cached_plane, GET_Z_PLANE_OFFSET(_our_turf.z));\
			}\
		}\
		else {\
			thing.plane = new_value;\
		}\
	}\
	while (FALSE)

#define SET_PLANE(thing, new_value, z_reference) (thing.plane = MUTATE_PLANE(new_value, z_reference))
#define SET_PLANE_W_SCALAR(thing, new_value, multiplier) (thing.plane = GET_NEW_PLANE(new_value, multiplier))

// Known issues:
// Potentially too much client load? Hard to tell due to not having a potato pc to hand.
// This is solvable with lowspec preferences, which would not be hard to implement
//
// Player popups will now render their effects, like overlay lights. this is fixable, but I've not gotten to it
//
// I think overlay lights can render on the wrong z layer. s fucked
#define GET_NEW_PLANE(new_value, multiplier) (SSmapping.plane_offset_blacklist?["[new_value]"] ? new_value : (new_value) - (PLANE_RANGE * (multiplier)))
// Yes the offset check here is redundant, but it optimizes single z init, which is very important to me
#define MUTATE_PLANE(new_value, z_reference) ((SSmapping.max_plane_offset) ? GET_NEW_PLANE(new_value, GET_TURF_PLANE_OFFSET(z_reference)) : (new_value))
#define GET_TURF_PLANE_OFFSET(z_reference) ((isatom(z_reference) && SSmapping.max_plane_offset) ? GET_Z_PLANE_OFFSET(z_reference.z) : 0)
#define GET_Z_PLANE_OFFSET(z) (SSmapping.z_level_to_plane_offset[z])

// Takes a z level, gets the lowest plane offset in its "stack"
#define GET_LOWEST_STACK_OFFSET(z) ((SSmapping.max_plane_offset) ? SSmapping.z_level_to_lowest_plane_offset[z] : 0)

/// Takes a plane, returns the canonical plane it represents
#define PLANE_TO_TRUE(plane) ((SSmapping.plane_offset_to_true) ? SSmapping.plane_offset_to_true["[plane]"] : plane)
/// Takes a plane, returns the offset it uses
#define PLANE_TO_OFFSET(plane) ((SSmapping.plane_to_offset) ? SSmapping.plane_to_offset["[plane]"] : plane)
/// Takes a true plane, returns the potential offset planes it could "hold"
#define TRUE_PLANE_TO_OFFSETS(plane) ((SSmapping.true_to_offset_planes) ? SSmapping.true_to_offset_planes["[plane]"] : list(plane))

#define OFFSET_RENDER_TARGET(render_target, offset) (SSmapping.render_offset_blacklist?["[render_target]"] ? \
														_OFFSET_RENDER_TARGET(render_target, 0) : _OFFSET_RENDER_TARGET(render_target, offset))
#define _OFFSET_RENDER_TARGET(render_target, offset) ("[(render_target)] #[(offset)]")
