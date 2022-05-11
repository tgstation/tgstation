
// Plane setter
/// Ok so hear me out yeah?
/// Lets imagine we know how many z levels are stacked on top of each other
/// If we know that, we can autogenerate plane masters to sit on top/below them
/// We only need as many plane masters as the maximum of all z level stacks
#define SET_PLANE(thing, new_value, z_reference) (SET_PLANE_W_SCALAR(thing, new_value, SSmapping.z_level_to_plane_offset[z_reference.z]))
#define SET_PLANE_W_SCALAR(thing, new_value, multiplier) (thing.plane = GET_NEW_PLANE(new_value, multiplier))
#define GET_NEW_PLANE(new_value, multiplier) ((new_value) - (PLANE_RANGE * (multiplier)))
