/// Keeps track of how many objects are saved per turf during map export
GLOBAL_VAR_INIT(TGM_objs, 0)
/// Keeps track of how many mobs are saved per turf during map export
GLOBAL_VAR_INIT(TGM_mobs, 0)

/// Keeps track of how many mobs total are saved during map export
GLOBAL_VAR_INIT(TGM_total_mobs, 0)
/// Keeps track of how many objs total are saved during map export
GLOBAL_VAR_INIT(TGM_total_objs, 0)
/// Keeps track of how many turfs total are saved during map export
GLOBAL_VAR_INIT(TGM_total_turfs, 0)
/// Keeps track of how many areas total are saved during map export
GLOBAL_VAR_INIT(TGM_total_areas, 0)

/// A cache of typepaths used via replace_saved_object_type() during map export
GLOBAL_LIST_EMPTY(map_export_typepath_cache)
/// A cache of typepaths used via get_save_vars() during map export
GLOBAL_LIST_EMPTY(map_export_save_vars_cache)
