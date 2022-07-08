
// Plane setter
/// Ok so hear me out yeah?
/// Lets imagine we know how many z levels are stacked on top of each other
/// If we know that, we can autogenerate plane masters to sit on top/below them
/// We only need as many plane masters as the maximum of all z level stacks
#define SET_PLANE_IMPLICIT(thing, new_value) (SET_PLANE_EXPLICIT(thing, new_value, thing))
#define SET_PLANE_EXPLICIT(thing, new_value, source) do {\
		var/turf/_our_turf = get_turf(source);\
		SET_PLANE(thing, new_value, _our_turf);\
	}\
	while (FALSE)

#define SET_PLANE(thing, new_value, z_reference) (thing.plane = MUTATE_PLANE(new_value, z_reference))
#define SET_PLANE_W_SCALAR(thing, new_value, multiplier) (thing.plane = GET_NEW_PLANE(new_value, multiplier))

// Lemon todo:
// Consider adding a low spec mode if possible, seen too many fps complaints, concerning
// AIs can see through static via openspace, fix that too
// Lemon todo: There's way too many get_turf(src) calls using SET_PLANE
// You should make a macro just for that case, reduce code bloat
// Global todos:
// Add a shit ton of documentation, preferablely to the whole rendering pipeline
// Test to see if it fixes the wallening bug
#define GET_NEW_PLANE(new_value, multiplier) (SSmapping.plane_offset_blacklist?["[new_value]"] ? new_value : (new_value) - (PLANE_RANGE * (multiplier)))
#define MUTATE_PLANE(new_value, z_reference) (GET_NEW_PLANE(new_value, GET_TURF_PLANE_OFFSET(z_reference)))
#define GET_TURF_PLANE_OFFSET(z_reference) ((isatom(z_reference) && SSmapping.max_plane_offset) ? GET_Z_PLANE_OFFSET(z_reference.z) : 0)
#define GET_Z_PLANE_OFFSET(z) (SSmapping.z_level_to_plane_offset[z])

// Takes a z level, gets the lowest plane offset in its "stack"
#define GET_LOWEST_STACK_OFFSET(z) ((SSmapping.max_plane_offset) ? SSmapping.z_level_to_lowest_plane_offset[z] : 0)

/// Takes a plane, returns the canonical plane it represents
#define PLANE_TO_TRUE(plane) ((SSmapping.plane_offset_to_true) ? SSmapping.plane_offset_to_true["[plane]"] : plane)
/// Takes a true plane, returns the potential offset planes it could "hold"
#define TRUE_PLANE_TO_OFFSETS(plane) ((SSmapping.true_to_offset_planes) ? SSmapping.true_to_offset_planes["[plane]"] : list(plane))

// Lemon todo: somehow ensure this works with plane offset blacklists
// Maybe get rid of bespoke render targets, and just add a PLANE_TARGET macro or something
#define OFFSET_RENDER_TARGET(render_target, offset) (SSmapping.render_offset_blacklist?["[render_target]"] ? \
														_OFFSET_RENDER_TARGET(render_target, 0) : _OFFSET_RENDER_TARGET(render_target, offset))
#define _OFFSET_RENDER_TARGET(render_target, offset) ("[(render_target)] #[(offset)]")
