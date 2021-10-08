#define MECHA_INT_FIRE (1<<0)
#define MECHA_INT_TEMP_CONTROL (1<<1)
#define MECHA_INT_SHORT_CIRCUIT (1<<2)
#define MECHA_INT_TANK_BREACH (1<<3)
#define MECHA_INT_CONTROL_LOST (1<<4)

#define ADDING_ACCESS_POSSIBLE (1<<0)
#define ADDING_MAINT_ACCESS_POSSIBLE (1<<1)
#define CANSTRAFE (1<<2)
#define LIGHTS_ON (1<<3)
#define SILICON_PILOT (1<<4)
#define IS_ENCLOSED (1<<5)
#define HAS_LIGHTS (1<<6)
#define QUIET_STEPS (1<<7)
#define QUIET_TURNS (1<<8)
///blocks using equipment and melee attacking.
#define CANNOT_INTERACT (1<<9)
/// posibrains can drive this mecha
#define MMI_COMPATIBLE (1<<10)

#define MECHA_MELEE (1 << 0)
#define MECHA_RANGED (1 << 1)

#define MECHA_FRONT_ARMOUR 1
#define MECHA_SIDE_ARMOUR 2
#define MECHA_BACK_ARMOUR 3

#define MECHA_LOCKED 0
#define MECHA_SECURE_BOLTS 1
#define MECHA_LOOSE_BOLTS 2
#define MECHA_OPEN_HATCH 3
