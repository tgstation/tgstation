// Burial (burial/, block 2): the rot of the dead, digging, graves and the dead bodies of the map (Ratwood
// datums/components/rotting.dm, roguejobs/gravedigger/, turfs/open/floor/roguefloor.dm, structures/roguetown/deadbodies.dm).

/// What the rot has made of a body (/mob/living/carbon/proc/rogue_rot_stage()): sound flesh, rotted flesh, bare bones.
#define ROGUE_ROT_FRESH 0
#define ROGUE_ROT_ROTTEN 1
#define ROGUE_ROT_BONES 2

/// Source of what the rot puts on a body: TRAIT_NOBLOOD of bones, TRAIT_PARALYSIS of rotted limbs.
#define ROGUE_ROT_TRAIT "rogue_rot"
/// Ratwood SKIN_COLOR_ROT: rotted flesh, drawn over the colours of the species at this limb colour priority.
#define ROGUE_ROT_SKIN_COLOR "#878f79"
#define ROGUE_LIMB_COLOR_ROT 25

/// From a corpse on every tick of its rot, after the time is counted and before the rot works on the body: (amount, in
/// deciseconds). Returning COMPONENT_ROGUE_ROT_SPARE spares the body this tick - for Pestra's mercy, a deadite rising.
#define COMSIG_LIVING_ROGUE_ROT_TICK "living_rogue_rot_tick"
	#define COMPONENT_ROGUE_ROT_SPARE (1<<0)
/// From a body when what the rot made of it changes: (new_stage, old_stage), ROGUE_ROT_* both.
#define COMSIG_LIVING_ROGUE_ROT_STAGE "living_rogue_rot_stage"

/// How deep a hole in the ground is (Ratwood dirthole stage): two holes, a pit big enough for a coffin, a filled grave.
#define ROGUE_HOLE_SHALLOW 1
#define ROGUE_HOLE_DEEP 2
#define ROGUE_HOLE_PIT 3
#define ROGUE_HOLE_GRAVE 4

/// Ratwood's shovel sounds: earth dug up (the copy husbandry/ keeps) and earth thrown down.
#define ROGUE_BURIAL_DIG_SOUND 'modular_redtard/husbandry/sound/dig_shovel.ogg'
#define ROGUE_BURIAL_EMPTY_SOUND 'modular_redtard/burial/sound/empty_shovel.ogg'
