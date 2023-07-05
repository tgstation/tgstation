// Bitflag defines used to ascertain the _why_ this emote is being executed to determine how intentional it was (either user-initiated or game-initiated)
/// This emote was forced by the game, default to this if it's not a user actually executing this emote.
#define EMOTE_EXECUTION_FORCED NONE
/// This emote was executed by the user via keybindings.
#define EMOTE_EXECUTION_USER_KEYBINDING (1 << 0)
/// This emote was executed by the user typing it out manually (e.g. writing out "*moan" in chat).
#define EMOTE_EXECUTION_USER_CHAT (1 << 1)
