// We need these as global vars due to objects being nested inside of other
// objects (ie. containers/backpacks/etc.) which are handled in various map
// exporter procs

/// Keeps track of how many objects are saved per turf during map export
GLOBAL_VAR_INIT(TGM_objs, 0)
/// Keeps track of how many mobs are saved per turf during map export
GLOBAL_VAR_INIT(TGM_mobs, 0)
