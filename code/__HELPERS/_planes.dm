// This file contains helper macros for plane operations
// See the planes section of Visuals.md for more detail, but essentially
// When we render multiz, we do it by placing all atoms on lower levels on well, lower planes
// This is done with stacks of plane masters (things we use to apply effects to planes)
// These macros exist to facilitate working with this system, and other associated small bits

/// Takes an atom to change the plane of, a new plane value, and something that can be used as a reference to a z level as input
/// Modifies the new value to match the plane we actually want. Note, if you pass in an already offset plane the offsets will add up
/// Use PLANE_TO_TRUE() to avoid this
#define SET_PLANE(thing, new_value, z_reference) (thing.plane = MUTATE_PLANE(new_value, z_reference))

/// Takes a plane and a z reference, and offsets the plane by the mutation
/// The SSmapping.max_plane_offset bit here is technically redundant, but saves a bit of work in the base case
/// And the base case is important to me. Non multiz shouldn't get hit too bad by this code
#define MUTATE_PLANE(new_value, z_reference) ((SSmapping.max_plane_offset) ? GET_NEW_PLANE(new_value, GET_TURF_PLANE_OFFSET(z_reference)) : (new_value))

/// Takes a z reference that we are unsure of, sanity checks it
/// Returns either its offset, or 0 if it's not a valid ref
/// Will return the reference's PLANE'S offset if we can't get anything out of the z level. We do our best
#define GET_TURF_PLANE_OFFSET(z_reference) ((SSmapping.max_plane_offset && isatom(z_reference)) ? (z_reference.z ? GET_Z_PLANE_OFFSET(z_reference.z) : PLANE_TO_OFFSET(z_reference.plane)) : 0)
/// Essentially just an unsafe version of GET_TURF_PLANE_OFFSET()
/// Takes a z value we returns its offset with a list lookup
/// Will runtime during parts of init. Be careful :)
#define GET_Z_PLANE_OFFSET(z) (SSmapping.z_level_to_plane_offset[z])

/// Takes a plane to offset, and the multiplier to use, and well, does the offsetting
/// Respects a blacklist we use to remove redundant plane masters, such as hud objects
#define GET_NEW_PLANE(new_value, multiplier) (SSmapping.plane_offset_blacklist?["[new_value]"] ? new_value : (new_value) - (PLANE_RANGE * (multiplier)))

// Now for the more niche things

/// Takes an object, new plane, and multiplier, and offsets the plane
/// This is for cases where you have a multiplier precalculated, and just want to use it
/// Often an optimization, sometimes a necessity
#define SET_PLANE_W_SCALAR(thing, new_value, multiplier) (thing.plane = GET_NEW_PLANE(new_value, multiplier))


/// Implicit plane set. We take the turf from the object we're changing the plane of, and use ITS z as a spokesperson for our plane value
#define SET_PLANE_IMPLICIT(thing, new_value) SET_PLANE_EXPLICIT(thing, new_value, thing)

// This is an unrolled and optimized version of SET_PLANE, for use anywhere where you are unsure of a source's "turfness"
// We do also try and guess at what the thing's z level is, even if it's not a z
// The plane is cached to allow for fancy stuff to be eval'd once, rather then often
#define SET_PLANE_EXPLICIT(thing, new_value, source) \
	do {\
		if(SSmapping.max_plane_offset) {\
			var/_cached_plane = new_value;\
			var/turf/_our_turf = get_turf(source);\
			if(_our_turf){\
				thing.plane = GET_NEW_PLANE(_cached_plane, GET_Z_PLANE_OFFSET(_our_turf.z));\
			}\
			else if(source) {\
				thing.plane = GET_NEW_PLANE(_cached_plane, PLANE_TO_OFFSET(source.plane));\
			}\
			else {\
				thing.plane = _cached_plane;\
			}\
		}\
		else {\
			thing.plane = new_value;\
		}\
	}\
	while (FALSE)

// Now for macros that exist to get info from SSmapping
// Mostly about details of planes, or z levels

/// Takes a z level, gets the lowest plane offset in its "stack"
#define GET_LOWEST_STACK_OFFSET(z) ((SSmapping.max_plane_offset) ? SSmapping.z_level_to_lowest_plane_offset[z] : 0)
/// Takes a plane, returns the canonical, unoffset plane it represents
#define PLANE_TO_TRUE(plane) ((SSmapping.plane_offset_to_true) ? SSmapping.plane_offset_to_true["[plane]"] : plane)
/// Takes a plane, returns the offset it uses
#define PLANE_TO_OFFSET(plane) ((SSmapping.plane_to_offset) ? SSmapping.plane_to_offset["[plane]"] : plane)
/// Takes a plane, returns TRUE if it is of critical priority, FALSE otherwise
#define PLANE_IS_CRITICAL(plane) ((SSmapping.plane_to_offset) ? !!SSmapping.critical_planes["[plane]"] : FALSE)
/// Takes a true plane, returns the offset planes that would canonically represent it
#define TRUE_PLANE_TO_OFFSETS(plane) ((SSmapping.true_to_offset_planes) ? SSmapping.true_to_offset_planes["[plane]"] : list(plane))
/// Takes a render target and an offset, returns a canonical render target string for it
#define OFFSET_RENDER_TARGET(render_target, offset) (_OFFSET_RENDER_TARGET(render_target, SSmapping.render_offset_blacklist?["[render_target]"] ? 0 : offset))
/// Helper macro for the above
/// Honestly just exists to make the pattern of render target strings more readable
#define _OFFSET_RENDER_TARGET(render_target, offset) ("[(render_target)] #[(offset)]")

// Known issues:
// Potentially too much client load? Hard to tell due to not having a potato pc to hand.
// This is solvable with lowspec preferences, which would not be hard to implement
// Player popups will now render their effects, like overlay lights. this is fixable, but I've not gotten to it
// I think overlay lights can render on the wrong z layer. s fucked

/// Whitelist of planes allowed to use TOPDOWN_LAYER
GLOBAL_LIST_INIT(topdown_planes, list(
		"[FLOOR_PLANE]" = TRUE,
	))

#define IS_TOPDOWN_PLANE(plane) GLOB.topdown_planes["[PLANE_TO_TRUE(plane)]"]

/// Checks if a passed in MA or atom is allowed to have its current plane/layer matchup
/proc/check_topdown_validity(mutable_appearance/thing_to_check)
	if(istype(thing_to_check, /atom/movable/screen/plane_master))
		return
	if(IS_TOPDOWN_PLANE(thing_to_check.plane))
		if(thing_to_check.layer - TOPDOWN_LAYER < 0 || thing_to_check.layer >= BACKGROUND_LAYER)
			stack_trace("[thing_to_check] ([thing_to_check.type]) was expected to have a TOPDOWN_LAYER layer due to its plane, but it DID NOT! layer: ([thing_to_check.layer]) plane: ([thing_to_check.plane])")
	else if(thing_to_check.layer - TOPDOWN_LAYER >= 0 && thing_to_check.layer < BACKGROUND_LAYER)
		stack_trace("[thing_to_check] ([thing_to_check.type] is NOT ALLOWED to have a TOPDOWN_LAYER layer due to its plane, but it did! layer: ([thing_to_check.layer]) plane: ([thing_to_check.plane])")
