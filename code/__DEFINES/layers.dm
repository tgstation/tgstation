//Defines for atom layers
//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define
#define ABOVE_OPEN_TURF_LAYER TURF_LAYER + 0.01 //2.01
#define CLOSED_TURF_LAYER TURF_LAYER + 0.05 //2.05
#define ABOVE_NORMAL_TURF_LAYER CLOSED_TURF_LAYER + 0.03 //2.08
#define LATTICE_LAYER TURF_LAYER + 0.2 //2.2
#define DISPOSAL_PIPE_LAYER TURF_LAYER + 0.3 //2.3
#define PIPE_LAYER DISPOSAL_PIPE_LAYER + 0.05 //2.35
#define WIRE_LAYER PIPE_LAYER + 0.05 //2.4
#define WIRE_TERMINAL_LAYER WIRE_LAYER  + 0.05 //2.45

#define LOW_OBJ_LAYER OBJ_LAYER - 0.5 //2.5
#define OPEN_DOOR_LAYER OBJ_LAYER - 0.3 //2.7
#define PROJECTILE_HIT_THRESHHOLD_LAYER OBJ_LAYER - 0.25 //2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER OBJ_LAYER - 0.2 //2.8
#define BELOW_OBJ_LAYER OBJ_LAYER - 0.1 //2.9
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_DOOR_LAYER OBJ_LAYER + 0.1 //3.1
#define CLOSED_FIREDOOR_LAYER CLOSED_DOOR_LAYER + 0.01 //3.11
#define ABOVE_OBJ_LAYER OBJ_LAYER + 0.2 //3.2
#define SIGN_LAYER OBJ_LAYER + 0.4 //3.4
#define HIGH_OBJ_LAYER OBJ_LAYER + 0.5 //3.5

#define BELOW_MOB_LAYER MOB_LAYER - 0.3 //3.7
#define LYING_MOB_LAYER MOB_LAYER - 0.2 //3.8
//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define ABOVE_MOB_LAYER MOB_LAYER + 0.1 //4.1
#define WALL_OBJ_LAYER MOB_LAYER + 0.25 //4.25
#define EDGED_TURF_LAYER MOB_LAYER + 0.3 //4.3
#define ON_EDGED_TURF_LAYER EDGED_TURF_LAYER + 0.05 //4.35
#define LARGE_MOB_LAYER MOB_LAYER + 0.4 //4.4
#define ABOVE_ALL_MOB_LAYER MOB_LAYER + 0.5 //4.5

#define SPACEVINE_LAYER FLY_LAYER - 0.2 //4.8
#define SPACEVINE_MOB_LAYER SPACEVINE_LAYER + 0.1 //4.9
//#define FLY_LAYER 5 //For easy recordkeeping; this is a byond define

#define GHOST_LAYER 6
#define AREA_LAYER 10
#define MASSIVE_OBJ_LAYER 11
#define POINT_LAYER 12
#define LIGHTING_LAYER 15

//HUD layer defines
#define FLASH_LAYER FULLSCREEN_LAYER - 0.1
#define FULLSCREEN_LAYER 18
#define DAMAGE_LAYER FULLSCREEN_LAYER + 0.1
#define BLIND_LAYER DAMAGE_LAYER + 0.1
#define CRIT_LAYER BLIND_LAYER + 0.1
#define HUD_LAYER 19
#define ABOVE_HUD_LAYER HUD_LAYER + 0.1

//weird misc layer defines
#define OVERWATCH_LAYER 25
#define REALLYHIGH_LAYER 50
#define ABSURD_LAYER 99