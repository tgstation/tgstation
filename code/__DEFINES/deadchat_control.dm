///Will execute a single command after the cooldown based on player votes.
#define DEMOCRACY_MODE (1<<0)
///Allows each player to do a single command every cooldown.
#define ANARCHY_MODE (1<<1)
///Mutes the democracy mode messages send to orbiters at the end of each cycle. Useful for when the cooldown is so low it'd get spammy.
#define MUTE_DEMOCRACY_MESSAGES (1<<2)
