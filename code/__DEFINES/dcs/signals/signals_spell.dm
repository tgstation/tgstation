// Spells sent to or by signals

// TODO DOC
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_spell__pre_cast"
// TODO DOC
#define COMSIG_SPELL_BEFORE_CAST "spell_pre_cast"
	/// Return from COMSIG_MOB_BEFORE_SPELL_CAST or COMSIG_SPELL_BEFORE_CAST to cease the cast
	#define COMPONENT_CANCEL_SPELL (1<<0)
// TODO DOC
#define COMSIG_MOB_CAST_SPELL "mob_cast_spell"
// TODO DOC
#define COMSIG_SPELL_CAST "spell_cast"
// TODO DOC
#define COMSIG_MOB_AFTER_SPELL_CAST "mob_after_spell_cast"
// TODO DOC
#define COMSIG_SPELL_AFTER_CAST "spell_after_cast"
// TODO DOC
#define COMSIG_SPELL_CAN_INVOKE "spell_can_invoke"
	// TODO DOC
	#define COMPONENT_CANCEL_INVOKE (1<<0)
// TODO DOC
#define COMSIG_SPELL_CAST_REVERTED "spell_cast_revert"
// TODO DOC
#define COMSIG_SPELL_SET_STATPANEL "spell_set_statpanel"

/// From /datum/action/cooldown/spell/lichdom/cast(), sent to the item being imbued: (datum/action/cooldown/spell, mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
	/// Return to stop the cast and prevent the soul imbue
	#define COMPONENT_BLOCK_IMBUE (1 << 0)

/// From /datum/action/cooldown/spell/summonitem/cast(), sent to the item being marked for recall: (datum/action/cooldown/spell, mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	/// Return to stop the cast and prevent the item from being marked
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1 << 0)

/// From /datum/action/cooldown/spell/summonitem/cast(), sent to the item in hand being charged: (datum/action/cooldown/spell, mob/user)
#define COMSIG_ITEM_MAGICALLY_CHARGED "item_mark_retrieval"

	#define COMPONENT_ITEM_CHARGED (1 << 0)

	#define COMPONENT_ITEM_BURNT_OUT (1 << 1)
