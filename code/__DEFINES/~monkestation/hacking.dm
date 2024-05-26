// Tool types, if you add new ones please add them to /obj/item/debug/omnitool in code/game/objects/items/debug_items.dm
#define TOOL_HACKING "hacking"
GLOBAL_LIST_EMPTY(hacking_actions_by_key)
/// Cooldown for hacking attacks
#define HACKING_ATTACK_COOLDOWN_DURATION 2 SECONDS
#define ishackingtool(O) (istype(O, /obj/item/ddos))

#define TRAIT_DANCING "dancing_trait"
#define EMOTE_TRAIT "trait_source_emote"
