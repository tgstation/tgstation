
// Plane setter
/// Ok so hear me out yeah?
/// Lets imagine we know how many z levels are stacked on top of each other
/// If we know that, we can autogenerate plane masters to sit on top/below them
/// We only need as many plane masters as the maximum of all z level stacks
#define SET_PLANE(thing, new_value, z_reference) (thing.plane = MUTATE_PLANE(new_value, z_reference))

// Lemon todo: There's way too many get_turf(src) calls using SET_PLANE
// You should make a macro just for that case, reduce code bloat
#define MUTATE_PLANE(new_value, z_reference) (GET_NEW_PLANE(new_value, GET_TURF_PLANE_OFFSET(z_reference)))
#define GET_TURF_PLANE_OFFSET(z_reference) ((isatom(z_reference) && SSmapping.max_plane_offset) ? GET_Z_PLANE_OFFSET(z_reference.z) : 0)
#define GET_Z_PLANE_OFFSET(z) (SSmapping.z_level_to_plane_offset[z])
#define SET_PLANE_W_SCALAR(thing, new_value, multiplier) (thing.plane = GET_NEW_PLANE(new_value, multiplier))
#define GET_NEW_PLANE(new_value, multiplier) ((new_value) - (PLANE_RANGE * (multiplier)))

/// Takes a plane, returns the canonical plane it represents
#define PLANE_TO_TRUE(plane) (GLOB.offset_to_true_plane["[plane]"])
/// Takes a true plane, returns the potential offset planes it could "hold"
#define TRUE_PLANE_TO_OFFSETS(plane) (GLOB.true_to_offset_planes["[plane]"])

#define OFFSET_RENDER_TARGET(render_target, offset) ("[(render_target)] #[(offset)]")
