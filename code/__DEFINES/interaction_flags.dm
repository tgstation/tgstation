/// whether can_interact() checks for anchored. only works on movables.
#define INTERACT_ATOM_REQUIRES_ANCHORED (1<<0)
/// calls try_interact() on attack_hand() and returns that.
#define INTERACT_ATOM_ATTACK_HAND (1<<1)
/// automatically calls and returns ui_interact() on interact().
#define INTERACT_ATOM_UI_INTERACT (1<<2)
/// user must be dextrous
#define INTERACT_ATOM_REQUIRES_DEXTERITY (1<<3)
/// ignores incapacitated check
#define INTERACT_ATOM_IGNORE_INCAPACITATED (1<<4)
/// incapacitated check ignores restrained
#define INTERACT_ATOM_IGNORE_RESTRAINED (1<<5)
/// incapacitated check checks grab
#define INTERACT_ATOM_CHECK_GRAB (1<<6)
/// prevents leaving fingerprints automatically on attack_hand
#define INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND (1<<7)
/// adds hiddenprints instead of fingerprints on interact
#define INTERACT_ATOM_NO_FINGERPRINT_INTERACT (1<<8)
/// allows this atom to skip the adjacency check
#define INTERACT_ATOM_ALLOW_USER_LOCATION (1<<9)
/// ignores mobility check
#define INTERACT_ATOM_IGNORE_MOBILITY (1<<10)
// Bypass all adjacency checks for mouse drop
#define INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT (1<<11)
/// Bypass all can_perform_action checks for mouse drop
#define INTERACT_ATOM_MOUSEDROP_IGNORE_USABILITY (1<<12)
/// Bypass all adjacency and other checks for mouse drop
#define INTERACT_ATOM_MOUSEDROP_IGNORE_CHECKS (INTERACT_ATOM_MOUSEDROP_IGNORE_ADJACENT | INTERACT_ATOM_MOUSEDROP_IGNORE_USABILITY)
/// calls try_interact() on attack_paw() and returns that.
#define INTERACT_ATOM_ATTACK_PAW (1<<13)

/// attempt pickup on attack_hand for items
#define INTERACT_ITEM_ATTACK_HAND_PICKUP (1<<0)

/// can_interact() while open
#define INTERACT_MACHINE_OPEN (1<<0)
/// can_interact() while offline
#define INTERACT_MACHINE_OFFLINE (1<<1)
/// try to interact with wires if open
#define INTERACT_MACHINE_WIRES_IF_OPEN (1<<2)
/// let silicons interact
#define INTERACT_MACHINE_ALLOW_SILICON (1<<3)
/// let silicons interact while open
#define INTERACT_MACHINE_OPEN_SILICON (1<<4)
/// must be silicon to interact
#define INTERACT_MACHINE_REQUIRES_SILICON (1<<5)
/// the user must have vision to interact (blind people need not apply)
#define INTERACT_MACHINE_REQUIRES_SIGHT (1<<6)
/// the user must be able to read to interact
#define INTERACT_MACHINE_REQUIRES_LITERACY (1<<7)
