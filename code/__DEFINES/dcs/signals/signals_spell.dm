// Signals sent to or by spells

// Generic spell signals

/// Sent from /datum/action/cooldown/spell/before_cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_spell__pre_cast"
/// Sent from /datum/action/cooldown/spell/before_cast() to the spell: (atom/cast_on)
#define COMSIG_SPELL_BEFORE_CAST "spell_pre_cast"
	/// Return from COMSIG_MOB_BEFORE_SPELL_CAST or COMSIG_SPELL_BEFORE_CAST to cease the cast.
	#define COMPONENT_CANCEL_SPELL (1<<0)
// Sent from /datum/action/cooldown/spell/cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_CAST_SPELL "mob_cast_spell"
/// Sent from /datum/action/cooldown/spell/cast() to the spell: (atom/cast_on)
#define COMSIG_SPELL_CAST "spell_cast"
// Sent from /datum/action/cooldown/spell/after_cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_AFTER_SPELL_CAST "mob_after_spell_cast"
/// Sent from /datum/action/cooldown/spell/after_cast() to the spell: (atom/cast_on)
#define COMSIG_SPELL_AFTER_CAST "spell_after_cast"
/// Sent from /datum/action/cooldown/spell/can_invoke() to the spell: ()
#define COMSIG_SPELL_CAN_INVOKE "spell_can_invoke"
	/// Return to stop and return FALSE from can_invoke(), which prevents the user from invoking / casting the spell
	#define COMPONENT_CANCEL_INVOKE (1<<0)
/// Sent from /datum/action/cooldown/spell/reset_spell_cooldown() to the spell: ()
#define COMSIG_SPELL_CAST_RESET "spell_cast_reset"

// Spell type signals

// Pointed projectiles
/// Sent from /datum/action/cooldown/spell/pointed/projectile/on_cast_hit: (atom/hit, atom/firer, obj/projectile/source)
#define COMSIG_SPELL_PROJECTILE_HIT "spell_projectile_hit"

// AOE spells
/// Sent from /datum/action/cooldown/spell/aoe/cast: (list/atoms_affected, atom/caster)
#define COMSIG_SPELL_AOE_ON_CAST "spell_aoe_cast"

// Cone spells
/// Sent from /datum/action/cooldown/spell/cone/cast: (list/atoms_affected, atom/caster)
#define COMSIG_SPELL_CONE_ON_CAST "spell_cone_cast"
/// Sent from /datum/action/cooldown/spell/cone/do_cone_effects: (list/atoms_affected, atom/caster, level)
#define COMSIG_SPELL_CONE_ON_LAYER_EFFECT "spell_cone_cast_effect"

// Touch spells
/// Sent from /datum/action/cooldown/spell/touch/do_hand_hit: (atom/hit, mob/living/carbon/caster, obj/item/melee/touch_attack/hand)
#define COMSIG_SPELL_TOUCH_HAND_HIT "spell_touch_hand_cast"

// Jaunt Spells
/// Sent from datum/action/cooldown/spell/jaunt/enter_jaunt, to the mob jaunting: (obj/effect/dummy/phased_mob/jaunt, datum/action/cooldown/spell/spell)
#define COMSIG_MOB_ENTER_JAUNT "spell_mob_enter_jaunt"
/// Sent from datum/action/cooldown/spell/jaunt/exit_jaunt, after the mob exited jaunt: (datum/action/cooldown/spell/spell)
#define COMSIG_MOB_AFTER_EXIT_JAUNT "spell_mob_after_exit_jaunt"

// Signals for specific spells

// Lichdom
/// Sent from /datum/action/cooldown/spell/lichdom/cast(), to the item being imbued: (datum/action/cooldown/spell/spell, mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
	/// Return to stop the cast and prevent the soul imbue
	#define COMPONENT_BLOCK_IMBUE (1 << 0)

// Instant Summons
/// Sent from /datum/action/cooldown/spell/summonitem/cast(), to the item being marked for recall: (datum/action/cooldown/spell/spell, mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	/// Return to stop the cast and prevent the item from being marked
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1 << 0)

// Charge
/// Sent from /datum/action/cooldown/spell/charge/cast(), to the item in hand being charged: (datum/action/cooldown/spell, mob/user)
#define COMSIG_ITEM_MAGICALLY_CHARGED "item_mark_retrieval"
	/// Return if an item was successfuly recharged
	#define COMPONENT_ITEM_CHARGED (1 << 0)
	/// Return if the item had a negative side effect occur while recharging
	#define COMPONENT_ITEM_BURNT_OUT (1 << 1)
