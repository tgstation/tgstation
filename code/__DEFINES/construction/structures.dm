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

///The blast door is missing wires, first step of construction.
#define BLASTDOOR_NEEDS_WIRES 0
///The blast door needs electronics, second step of construction.
#define BLASTDOOR_NEEDS_ELECTRONICS 1
///The blast door is fully constructed.
#define BLASTDOOR_FINISHED 2

//floodlights because apparently we use defines now
#define FLOODLIGHT_NEEDS_WIRES 0
#define FLOODLIGHT_NEEDS_LIGHTS 1
#define FLOODLIGHT_NEEDS_SECURING 2

//Construction defines for the pinion airlock
#define GEAR_SECURE 1
#define GEAR_LOOSE 2

//Stationary gas tanks
#define TANK_FRAME 0
#define TANK_PLATING_UNSECURED 1

// Frame (de/con)struction states
/// Frame is empty, no wires no board
#define FRAME_STATE_EMPTY 0
/// Frame has been wired
#define FRAME_STATE_WIRED 1
/// Frame has a board installed, it is safe to assume if in this state then circuit is non-null (but you never know)
#define FRAME_STATE_BOARD_INSTALLED 2
/// Frame is empty, no circuit board yet
#define FRAME_COMPUTER_STATE_EMPTY FRAME_STATE_EMPTY
/// Frame now has a board installed, it is safe to assume beyond this state, circuit is non-null (but you never know)
#define FRAME_COMPUTER_STATE_BOARD_INSTALLED 1
/// Board has been secured
#define FRAME_COMPUTER_STATE_BOARD_SECURED 2
/// Frame has been wired
#define FRAME_COMPUTER_STATE_WIRED 3
/// Frame has had glass applied to it
#define FRAME_COMPUTER_STATE_GLASSED 4

///The camera assembly is wrenched in (aka placed on the wall), and wrenching will deconstruct.
#define CAMERA_STATE_WRENCHED 1
///The camera assembly is welded in place, so won't come off from wrench anymore.
#define CAMERA_STATE_WELDED 2
///The camera assembly is wired and ready to finish construction.
#define CAMERA_STATE_WIRED 3
///The camera assembly is finished construction fully, and is currently chilling in the camera machine.
#define CAMERA_STATE_FINISHED 4
