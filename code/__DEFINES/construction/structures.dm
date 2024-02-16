//Defines for construction states

//ai core defines
#define EMPTY_CORE 0
#define CIRCUIT_CORE 1
#define SCREWED_CORE 2
#define CABLED_CORE 3
#define GLASS_CORE 4
#define AI_READY_CORE 5

//girder construction states
#define GIRDER_NORMAL 0
#define GIRDER_REINF_STRUTS 1
#define GIRDER_REINF 2
#define GIRDER_DISPLACED 3
#define GIRDER_DISASSEMBLED 4
#define GIRDER_TRAM 5

//rwall construction states
#define INTACT 0
#define SUPPORT_LINES 1
#define COVER 2
#define CUT_COVER 3
#define ANCHOR_BOLTS 4
#define SUPPORT_RODS 5
#define SHEATH 6

//window construction states
#define WINDOW_OUT_OF_FRAME 0
#define WINDOW_IN_FRAME 1
#define WINDOW_SCREWED_TO_FRAME 2

//reinforced window construction states
#define RWINDOW_FRAME_BOLTED 3
#define RWINDOW_BARS_CUT 4
#define RWINDOW_POPPED 5
#define RWINDOW_BOLTS_OUT 6
#define RWINDOW_BOLTS_HEATED 7
#define RWINDOW_SECURE 8

//tram structure construction states
#define TRAM_OUT_OF_FRAME 0
#define TRAM_IN_FRAME 1
#define TRAM_SCREWED_TO_FRAME 2

//airlock assembly construction states
#define AIRLOCK_ASSEMBLY_NEEDS_WIRES 0
#define AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS 1
#define AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER 2

//blast door (de)construction states
#define BLASTDOOR_NEEDS_WIRES 0
#define BLASTDOOR_NEEDS_ELECTRONICS 1
#define BLASTDOOR_FINISHED 2

//floodlights because apparently we use defines now
#define FLOODLIGHT_NEEDS_WIRES 0
#define FLOODLIGHT_NEEDS_LIGHTS 1
#define FLOODLIGHT_NEEDS_SECURING 2

//Construction defines for the pinion airlock
#define GEAR_SECURE 1
#define GEAR_LOOSE 2

// Stationary gas tanks
#define TANK_FRAME 0
#define TANK_PLATING_UNSECURED 1

