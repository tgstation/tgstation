
// Plane setter
/// Ok so hear me out yeah?
/// Lets imagine we know how many z levels are stacked on top of each other
/// If we know that, we can autogenerate plane masters to sit on top/below them
/// We only need as many plane masters as the maximum of all z level stacks
#define SET_PLANE(thing, new_value, z_reference) (thing.plane = MUTATE_PLANE(new_value, z_reference))
#define SET_PLANE_W_SCALAR(thing, new_value, multiplier) (thing.plane = GET_NEW_PLANE(new_value, multiplier))

// Lemon todo: There's way too many get_turf(src) calls using SET_PLANE
// You should make a macro just for that case, reduce code bloat
// Global todos:
// Figure out how the hell you want to handle points where upper plane stuff is rendered on lower planes (basically, mirages)
// Report that bug with vis_contents and overlays (if a turf is in another turf's vis contents, and has an overlay of its removed while neither turf is in view
// The removal will not display on the source turf until the other turf is loaded into view)
// Add a ui that can be used to visualize, edit and debug the plane master and rendering plane setup of any mob
// Add a shit ton of documentation, preferablely to the whole rendering pipeline
// Grock backdrops
// Run on live to make sure this isn't too laggy for some reason
// Test to see if it fixes the wallening bug
// Do something about the lighting pop in
// Do something about darkness being fucking cursed (potentially use layers to stick the darkness plane in its proper place on all levels? maybe? (yes, you can do this, with multiple render targets))
// Do something about emissives (when you do mutable appearances)
#define GET_NEW_PLANE(new_value, multiplier) ((new_value) - (PLANE_RANGE * (multiplier)))
#define MUTATE_PLANE(new_value, z_reference) (GET_NEW_PLANE(new_value, GET_TURF_PLANE_OFFSET(z_reference)))
#define GET_TURF_PLANE_OFFSET(z_reference) ((isatom(z_reference) && SSmapping.max_plane_offset) ? GET_Z_PLANE_OFFSET(z_reference.z) : 0)
#define GET_Z_PLANE_OFFSET(z) (SSmapping.z_level_to_plane_offset[z])

// Takes a z level, gets the lowest plane offset in its "stack"
#define GET_LOWEST_STACK_OFFSET(z) ((SSmapping.max_plane_offset) ? SSmapping.z_level_to_lowest_plane_offset[z] : 0)

/// Takes a plane, returns the canonical plane it represents
#define PLANE_TO_TRUE(plane) ((SSmapping.plane_offset_to_true) ? SSmapping.plane_offset_to_true["[plane]"] : plane)
/// Takes a true plane, returns the potential offset planes it could "hold"
#define TRUE_PLANE_TO_OFFSETS(plane) ((SSmapping.true_to_offset_planes) ? SSmapping.true_to_offset_planes["[plane]"] : list(plane))

#define OFFSET_RENDER_TARGET(render_target, offset) ("[(render_target)] #[(offset)]")
