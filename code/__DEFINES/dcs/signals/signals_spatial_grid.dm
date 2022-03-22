//spatial grid signals

///Called from base of /datum/controller/subsystem/spatial_grid/proc/enter_cell: (/atom/movable)
#define SPATIAL_GRID_CELL_ENTERED(contents_type) "spatial_grid_cell_entered_[contents_type]"
///Called from base of /datum/controller/subsystem/spatial_grid/proc/exit_cell: (/atom/movable)
#define SPATIAL_GRID_CELL_EXITED(contents_type) "spatial_grid_cell_exited_[contents_type]"
