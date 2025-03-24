/// Cube rarities
#define COMMON_CUBE 1
#define UNCOMMON_CUBE 2
#define RARE_CUBE 3
#define EPIC_CUBE 4
#define LEGENDARY_CUBE 5
#define MYTHICAL_CUBE 6

// Cube examine flags, used for anything that doesn't inherently already add an examine string
/// Is a tool
#define CUBE_TOOL (1<<0)
/// Is an egg
#define CUBE_EGG (1<<1)
/// Can butcher things
#define CUBE_BUTCHER (1<<2)
/// Is a laser gun
#define CUBE_LASER (1<<3)
/// Is leashed to a mob
#define CUBE_LEASHED (1<<4)
/// Does sitcom laughs
#define CUBE_FUNNY (1<<5)
/// Can initiate surgery
#define CUBE_SURGICAL (1<<6)
/// Is a much better weapon
#define CUBE_WEAPON (1<<7)
/// Steals life on hit
#define CUBE_VAMPIRIC (1<<8)
/// is a gps
#define CUBE_GPS (1<<9)
/// Is a circuit shell
#define CUBE_CIRCUIT (1<<10)
/// Can store items
#define CUBE_STORAGE (1<<11)
/// Can be fished in
#define CUBE_FISH (1<<12)
/// Can edit religions using it
#define CUBE_FAITH (1<<13)
