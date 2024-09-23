// Signals sent to or by spells

// Generic spell signals


/// Sent from /datum/action/cooldown/spell/before_cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_spell_pre_cast"
/// Sent from /datum/action/cooldown/spell/before_cast() to the spell: (atom/cast_on)
#define COMSIG_SPELL_BEFORE_CAST "spell_pre_cast"
	/// Return to prevent the spell cast from continuing.
	#define SPELL_CANCEL_CAST (1 << 0)
	/// Return from before cast signals to prevent the spell from giving off sound or invocation.
	#define SPELL_NO_FEEDBACK (1 << 1)
	/// Return from before cast signals to prevent the spell from going on cooldown before aftercast.
	#define SPELL_NO_IMMEDIATE_COOLDOWN (1 << 2)

/// Sent to an mob when a [/datum/action/cooldown/spell] calls try_invoke() to the caster: (datum/action/cooldown/spell/spell, feedback)
#define COMSIG_MOB_TRY_INVOKE_SPELL "try_invoke_spell"
	/// The spell gets canceled
	#define SPELL_INVOCATION_FAIL SPELL_CANCEL_CAST
	/// The spell always succeeds to invoke regardless of following checks
	#define SPELL_INVOCATION_ALWAYS_SUCCEED (1 << 1)

/// Sent from /datum/action/cooldown/spell/set_click_ability() to the caster: (datum/action/cooldown/spell/spell)
#define COMSIG_MOB_SPELL_ACTIVATED "mob_spell_active"
	/// Same as spell_cancel_cast, as they're able to be used interchangeably
	#define SPELL_CANCEL_ACTIVATION SPELL_CANCEL_CAST

/// Sent from /datum/action/cooldown/spell/cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_CAST_SPELL "mob_cast_spell"
/// Sent from /datum/action/cooldown/spell/cast() to the spell: (atom/cast_on)
#define COMSIG_SPELL_CAST "spell_cast"
// Sent from /datum/action/cooldown/spell/after_cast() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on)
#define COMSIG_MOB_AFTER_SPELL_CAST "mob_after_spell_cast"
/// Sent from /datum/action/cooldown/spell/after_cast() to the spell: (atom/cast_on)
#define COMSIG_SPELL_AFTER_CAST "spell_after_cast"
/// Sent from /datum/action/cooldown/spell/reset_spell_cooldown() to the spell: ()
#define COMSIG_SPELL_CAST_RESET "spell_cast_reset"
/// Sent from /datum/action/cooldown/spell/proc/invocation() to the mob: (datum/source, /datum/action/cooldown/spell/spell, list/invocation)
#define COMSIG_MOB_PRE_INVOCATION "spell_pre_invocation"
	///index for the invocation message string
	#define INVOCATION_MESSAGE 1
	///index for the invocation type string
	#define INVOCATION_TYPE 2
	///index for the invocation garble probability number
	#define INVOCATION_GARBLE_PROB 3

// Spell type signals

// Pointed projectiles
// Sent from /datum/action/cooldown/spell/pointed/projectile/fire_projectile() to the caster: (datum/action/cooldown/spell/spell, atom/cast_on, obj/projectile/to_fire)
#define COMSIG_MOB_SPELL_PROJECTILE "mob_spell_projectile"
/// Sent from /datum/action/cooldown/spell/pointed/projectile/on_cast_hit: (atom/firer, atom/target, atom/hit, angle, hit_limb)
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
/// Sent from datum/action/cooldown/spell/jaunt/before_cast, before the mob enters jaunting as a pre-check: (datum/action/cooldown/spell/spell)
#define COMSIG_MOB_PRE_JAUNT "spell_mob_pre_jaunt"
	#define COMPONENT_BLOCK_JAUNT (1<<0)
/// Sent from datum/action/cooldown/spell/jaunt/enter_jaunt, to the mob jaunting: (obj/effect/dummy/phased_mob/jaunt, datum/action/cooldown/spell/spell)
#define COMSIG_MOB_ENTER_JAUNT "spell_mob_enter_jaunt"
/// Set from /obj/effect/dummy/phased_mob after the mob is ejected from its contents: (obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
#define COMSIG_MOB_EJECTED_FROM_JAUNT "spell_mob_eject_jaunt"
/// Sent from datum/action/cooldown/spell/jaunt/exit_jaunt, after the mob exited jaunt: (datum/action/cooldown/spell/spell)
#define COMSIG_MOB_AFTER_EXIT_JAUNT "spell_mob_after_exit_jaunt"
/// Sent from /obj/effect/dummy/phased_mob/proc/phased_check when moving to the holder object: (/obj/effect/dummy/phased_mob, mob/living/phaser, turf/newloc)
#define COMSIG_MOB_PHASED_CHECK "mob_phased_check"
	/// Return this to cancel the phased move
	#define COMPONENT_BLOCK_PHASED_MOVE (1 << 0)

/// Sent from/datum/action/cooldown/spell/jaunt/bloodcrawl/slaughter_demon/try_enter_jaunt,
/// to any unconscious / critical mobs being dragged when the jaunter enters blood:
/// (datum/action/cooldown/spell/jaunt/bloodcrawl/crawl, mob/living/jaunter, obj/effect/decal/cleanable/blood)
#define COMSIG_LIVING_BLOOD_CRAWL_PRE_CONSUMED "living_pre_consumed_by_bloodcrawl"
/// Sent from/datum/action/cooldown/spell/jaunt/bloodcrawl/slaughter_demon/consume_victim,
/// to the victim being consumed by the slaughter demon.
/// (datum/action/cooldown/spell/jaunt/bloodcrawl/crawl, mob/living/jaunter)
#define COMSIG_LIVING_BLOOD_CRAWL_CONSUMED "living_consumed_by_bloodcrawl"
	/// Return at any point to stop the bloodcrawl "consume" process from continuing.
	#define COMPONENT_STOP_CONSUMPTION (1 << 0)

// Signals for specific spells

// Lichdom
/// Sent from /datum/action/cooldown/spell/lichdom/cast(), to the item being imbued: (datum/action/cooldown/spell/spell, mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
	/// Return to stop the cast and prevent the soul imbue
	#define COMPONENT_BLOCK_IMBUE (1 << 0)

/// Sent from /datum/action/cooldown/spell/aoe/knock/cast(), to every nearby turf (for connect loc): (datum/action/cooldown/spell/aoe/knock/spell, mob/living/caster)
#define COMSIG_ATOM_MAGICALLY_UNLOCKED "atom_magic_unlock"

// Instant Summons
/// Sent from /datum/action/cooldown/spell/summonitem/cast(), to the item being marked for recall: (datum/action/cooldown/spell/spell, mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	/// Return to stop the cast and prevent the item from being marked
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1 << 0)
///When an object is retrieved by a magic recall spell. This will apply to all containers, mobs, etc. that are pulled by the spell.
#define COMSIG_MAGIC_RECALL "magic_recall"


// Charge
/// Sent from /datum/action/cooldown/spell/charge/cast(), to the item in hand being charged: (datum/action/cooldown/spell/spell, mob/user)
#define COMSIG_ITEM_MAGICALLY_CHARGED "item_magic_charged"
	/// Return if an item was successful recharged
	#define COMPONENT_ITEM_CHARGED (1 << 0)
	/// Return if the item had a negative side effect occur while recharging
	#define COMPONENT_ITEM_BURNT_OUT (1 << 1)
