// Values used to determine if an obj should render on the minimap
/// Obj should never render on the minimap
#define MINIMAP_RENDER_NEVER 0
/// Obj should render on the minimap when visible
#define MINIMAP_RENDER_NORMAL 1
/// Obj should always render on the minimap, even when not normally visible
#define MINIMAP_RENDER_ALWAYS 2

// Priority levels for rendering on the minimap. Higher priorities are drawn on top of lower priorities

#define MINIMAP_PRIORITY_DOOR 80
#define MINIMAP_PRIORITY_SOLAR 75
#define MINIMAP_PRIORITY_WINDOW 70
#define MINIMAP_PRIORITY_GRILLE 65
#define MINIMAP_PRIORITY_LATTICE 63
#define MINIMAP_PRIORITY_CABLE 60
#define MINIMAP_PRIORITY_RAILING 55
