///called on /living when attempting to pick up an item, from base of /mob/living/put_in_hand_check(): (obj/item/I)
#define COMSIG_LIVING_TRY_PUT_IN_HAND "living_try_put_in_hand"
	/// Can't pick up
	#define COMPONENT_LIVING_CANT_PUT_IN_HAND (1<<0)

// Organ signals
/// Called on the organ when it is implanted into someone (mob/living/carbon/receiver)
#define COMSIG_ORGAN_IMPLANTED "organ_implanted"
/// Called on the organ when it is removed from someone (mob/living/carbon/old_owner)
#define COMSIG_ORGAN_REMOVED "organ_removed"
/// Called when an organ is being regenerated with a new copy in species regenerate_organs (obj/item/organ/replacement)
#define COMSIG_ORGAN_BEING_REPLACED "organ_being_replaced"
/// Called when an organ gets surgically removed (mob/living/user, mob/living/carbon/old_owner, target_zone, obj/item/tool)
#define COMSIG_ORGAN_SURGICALLY_REMOVED "organ_surgically_removed"
/// Called when an organ gets surgically removed (mob/living/user, mob/living/carbon/new_owner, target_zone, obj/item/tool)
#define COMSIG_ORGAN_SURGICALLY_INSERTED "organ_surgically_inserted"

///Called when movement intent is toggled.
#define COMSIG_MOVE_INTENT_TOGGLED "move_intent_toggled"

///from base of mob/update_transform()
#define COMSIG_LIVING_POST_UPDATE_TRANSFORM "living_post_update_transform"

/// from /datum/status_effect/incapacitating/stamcrit/on_apply()
#define COMSIG_LIVING_ENTER_STAMCRIT "living_enter_stamcrit"
///from /obj/structure/door/crush(): (mob/living/crushed, /obj/machinery/door/crushing_door)
#define COMSIG_LIVING_DOORCRUSHED "living_doorcrush"
///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/ignite_mob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/extinguish_mob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
///from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
	/// Block the electrocute_act() proc from proceeding
	#define COMPONENT_LIVING_BLOCK_SHOCK (1<<0)
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
///from base of mob/living/set_body_position(): (new_position, old_position)
#define COMSIG_LIVING_SET_BODY_POSITION  "living_set_body_position"
/// Sent to a mob being injected with a syringe when the do_after initiates
#define COMSIG_LIVING_TRY_SYRINGE_INJECT "living_try_syringe_inject"
/// Sent to a mob being withdrawn from with a syringe when the do_after initiates
#define COMSIG_LIVING_TRY_SYRINGE_WITHDRAW "living_try_syringe_withdraw"
///from base of mob/living/set_usable_legs()
#define COMSIG_LIVING_LIMBLESS_SLOWDOWN  "living_limbless_slowdown"
///From living/Life(). (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"
	/// Block the Life() proc from proceeding... this should really only be done in some really wacky situations.
	#define COMPONENT_LIVING_CANCEL_LIFE_PROCESSING (1<<0)
///From living/set_resting(): (new_resting, silent, instant)
#define COMSIG_LIVING_RESTING "living_resting"

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_LIVING_BANED "living_baned"

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_OBJECT_PRE_BANING "obj_pre_baning"
	#define COMPONENT_CANCEL_BANING (1<<0)

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_OBJECT_ON_BANING "obj_on_baning"

// adjust_x_loss messages sent from /mob/living/proc/adjust[x]Loss
/// Returned from all the following messages if you actually aren't going to apply any change
#define COMPONENT_IGNORE_CHANGE (1<<0)
// Each of these messages sends the damagetype even though it is inferred by the signal so you can pass all of them to the same proc if required
/// Send when bruteloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_BRUTE_DAMAGE "living_adjust_brute_damage"
/// Send when fireloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_BURN_DAMAGE "living_adjust_burn_damage"
/// Send when oxyloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_OXY_DAMAGE "living_adjust_oxy_damage"
/// Send when toxloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_TOX_DAMAGE "living_adjust_tox_damage"
/// Send when staminaloss is modified (type, amount, forced)
#define COMSIG_LIVING_ADJUST_STAMINA_DAMAGE "living_adjust_stamina_damage"

/// List of signals sent when you receive any damage except stamina
#define COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES list(\
	COMSIG_LIVING_ADJUST_BRUTE_DAMAGE,\
	COMSIG_LIVING_ADJUST_BURN_DAMAGE,\
	COMSIG_LIVING_ADJUST_OXY_DAMAGE,\
	COMSIG_LIVING_ADJUST_TOX_DAMAGE,\
)
/// List of signals sent when you receive any kind of damage at all
#define COMSIG_LIVING_ADJUST_ALL_DAMAGE_TYPES (COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES + COMSIG_LIVING_ADJUST_STAMINA_DAMAGE)


/// from base of mob/living/updatehealth()
#define COMSIG_LIVING_HEALTH_UPDATE "living_health_update"
/// from base of mob/living/updatestamina()
#define COMSIG_LIVING_STAMINA_UPDATE "living_stamina_update"
///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"

///from base of mob/living/gib(): (drop_bitflags)
///Note that it is fired regardless of whether the mob was dead beforehand or not.
#define COMSIG_LIVING_GIBBED "living_gibbed"

///from base of mob/living/Write_Memory(): (dead, gibbed)
#define COMSIG_LIVING_WRITE_MEMORY "living_write_memory"
	#define COMPONENT_DONT_WRITE_MEMORY (1<<0)

/// from /proc/healthscan(): (list/scan_results, advanced, mob/user, mode)
/// Consumers are allowed to mutate the scan_results list to add extra information
#define COMSIG_LIVING_HEALTHSCAN "living_healthscan"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!

///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Knockdown() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Paralyze() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/incapacitate() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_INCAPACITATE "living_incapacitate"
///from base of mob/living/Unconscious() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
/// from mob/living/check_stun_immunity(): (check_flags)
#define COMSIG_LIVING_GENERIC_STUN_CHECK "living_check_stun"
	#define COMPONENT_NO_STUN (1<<0) //For all of them
///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)
///from end of fully_heal(): (heal_flags)
#define COMSIG_LIVING_POST_FULLY_HEAL "living_post_fully_heal"
/// from start of /mob/living/handle_breathing(): (seconds_per_tick, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"
///from /obj/item/hand_item/slapper/attack_atom(): (source=mob/living/slammer, obj/structure/table/slammed_table)
#define COMSIG_LIVING_SLAM_TABLE "living_slam_table"
///from /obj/item/hand_item/slapper/attack(): (source=mob/living/slapper, mob/living/slapped)
#define COMSIG_LIVING_SLAP_MOB "living_slap_mob"
///from /obj/item/hand_item/slapper/attack(): (source=mob/living/slapper, mob/living/slapped)
#define COMSIG_LIVING_SLAPPED "living_slapped"
/// from /mob/living/*/UnarmedAttack(), before sending [COMSIG_LIVING_UNARMED_ATTACK]: (mob/living/source, atom/target, proximity, modifiers)
/// The only reason this exists is so hulk can fire before Fists of the North Star.
/// Note that this is called before [/mob/living/proc/can_unarmed_attack] is called, so be wary of that.
#define COMSIG_LIVING_EARLY_UNARMED_ATTACK "human_pre_attack_hand"
/// from mob/living/*/UnarmedAttack(): (mob/living/source, atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"
///From base of mob/living/MobBump(): (mob/bumped, mob/living/bumper)
#define COMSIG_LIVING_PRE_MOB_BUMP "movable_pre_bump"
	#define COMPONENT_LIVING_BLOCK_PRE_MOB_BUMP (1<<0)
///From base of mob/living/MobBump() (mob/living)
#define COMSIG_LIVING_MOB_BUMP "living_mob_bump"
///From base of mob/living/MobBump() (mob/living)
#define COMSIG_LIVING_MOB_BUMPED "living_mob_bumped"
///From base of mob/living/Bump() (turf/closed)
#define COMSIG_LIVING_WALL_BUMP "living_wall_bump"
///From base of turf/closed/Exited() (turf/closed)
#define COMSIG_LIVING_WALL_EXITED "living_wall_exited"
///From base of mob/living/ZImpactDamage() (mob/living, levels, turf/t)
#define COMSIG_LIVING_Z_IMPACT "living_z_impact"
	/// Just for the signal return, does not run normal living handing of z fall damage for mobs
	#define ZIMPACT_CANCEL_DAMAGE (1<<0)
	/// Do not show default z-impact message
	#define ZIMPACT_NO_MESSAGE (1<<1)
	/// Do not do the spin animation when landing
	#define ZIMPACT_NO_SPIN (1<<2)

/// From mob/living/try_speak(): (message, ignore_spam, forced)
#define COMSIG_MOB_TRY_SPEECH "living_vocal_speech"
	/// Return to skip can_speak check, IE, forcing success. Overrides below.
	#define COMPONENT_IGNORE_CAN_SPEAK (1<<0)
	/// Return if the mob cannot speak.
	#define COMPONENT_CANNOT_SPEAK (1<<1)

/// From mob/living/treat_message(): (list/message_args)
#define COMSIG_LIVING_TREAT_MESSAGE "living_treat_message"
	/// The index of message_args that corresponds to the actual message
	#define TREAT_MESSAGE_ARG 1
	#define TREAT_TTS_MESSAGE_ARG 2
	#define TREAT_TTS_FILTER_ARG 3
	#define TREAT_CAPITALIZE_MESSAGE 4

///From obj/item/toy/crayon/spraycan
#define COMSIG_LIVING_MOB_PAINTED "living_mob_painted"

///From obj/closet/supplypod/return_victim: (turf/destination)
#define COMSIG_LIVING_RETURN_FROM_CAPTURE "living_return_from_capture"

///From mob/living/proc/wabbajack(): (randomize_type)
#define COMSIG_LIVING_PRE_WABBAJACKED "living_mob_wabbajacked"
	/// Return to stop the rest of the wabbajack from triggering.
	#define STOP_WABBAJACK (1<<0)
///From mob/living/proc/on_wabbajack(): (mob/living/new_mob)
#define COMSIG_LIVING_ON_WABBAJACKED "living_wabbajacked"

/// From /datum/status_effect/shapechange_mob/on_apply(): (mob/living/shape)
#define COMSIG_LIVING_SHAPESHIFTED "living_shapeshifted"
/// From /datum/status_effect/shapechange_mob/after_unchange(): (mob/living/caster)
#define COMSIG_LIVING_UNSHAPESHIFTED "living_unshapeshifted"

///From /obj/effect/rune/convert/do_sacrifice() : (list/invokers)
#define COMSIG_LIVING_CULT_SACRIFICED "living_cult_sacrificed"
	/// Return to stop the sac from occurring
	#define STOP_SACRIFICE (1<<0)
	/// Don't send a message for sacrificing this thing, we have our own
	#define SILENCE_SACRIFICE_MESSAGE (1<<1)
	/// Don't send a message for sacrificing this thing UNLESS it's the cult target
	#define SILENCE_NONTARGET_SACRIFICE_MESSAGE (1<<2)
	/// Dusts the target instead of gibbing them (no soulstone)
	#define DUST_SACRIFICE (1<<3)

/// From /mob/living/befriend() : (mob/living/new_friend)
#define COMSIG_LIVING_BEFRIENDED "living_befriended"

/// From /obj/item/proc/pickup(): (/obj/item/picked_up_item)
#define COMSIG_LIVING_PICKED_UP_ITEM "living_picked_up_item"

/// From /mob/living/unfriend() : (mob/living/old_friend)
#define COMSIG_LIVING_UNFRIENDED "living_unfriended"

/// From /obj/effect/temp_visual/resonance/burst() : (mob/creator, mob/living/hit_living)
#define COMSIG_LIVING_RESONATOR_BURST "living_resonator_burst"

/// From /obj/projectile/on_parry() : (obj/projectile/parried_projectile)
#define COMSIG_LIVING_PROJECTILE_PARRIED "living_projectile_parried"
	/// Return to prevent the projectile from executing any code in on_parry()
	#define INTERCEPT_PARRY_EFFECTS (1<<0)

/// From /turf/closed/mineral/gibtonite/defuse() : (det_time)
#define COMSIG_LIVING_DEFUSED_GIBTONITE "living_defused_gibtonite"

/// From /obj/item/kinetic_crusher/afterattack() : (mob/living/target, obj/item/kinetic_crusher/crusher, backstabbed)
#define COMSIG_LIVING_CRUSHER_DETONATE "living_crusher_detonate"

/// From /obj/structure/geyser/attackby() : (obj/structure/geyser/geyser)
#define COMSIG_LIVING_DISCOVERED_GEYSER "living_discovered_geyser"

/// From /datum/ai/behavior/climb_tree/perform() : (mob/living/basic/living_pawn)
#define COMSIG_LIVING_CLIMB_TREE "living_climb_tree"

///from /mob/living/proc/check_block(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
#define COMSIG_LIVING_CHECK_BLOCK "living_check_block"
	#define FAILED_BLOCK NONE
	#define SUCCESSFUL_BLOCK (1<<0)

///Hit by successful disarm attack (mob/living/attacker, zone_targeted, item/weapon)
#define COMSIG_LIVING_DISARM_HIT "living_disarm_hit"
///Before a living mob is shoved, sent to the turf we're trying to shove onto (mob/living/shover, mob/living/target)
#define COMSIG_LIVING_DISARM_PRESHOVE "living_disarm_preshove"
	#define COMSIG_LIVING_ACT_SOLID (1<<0) //Tells disarm code to act as if the mob was shoved into something solid, even we we're not
///When a living mob is disarmed, this is sent to the turf we're trying to shove onto (mob/living/shover, mob/living/target, shove_blocked)
#define COMSIG_LIVING_DISARM_COLLIDE "living_disarm_collision"
	#define COMSIG_LIVING_SHOVE_HANDLED (1<<0)

/// Sent on a mob from /datum/component/mob_chain when component is attached with it as the "front" : (mob/living/basic/tail)
#define COMSIG_MOB_GAINED_CHAIN_TAIL "living_gained_chain_tail"
/// Sent on a mob from /datum/component/mob_chain when component is detached from it as the "front" : (mob/living/basic/tail)
#define COMSIG_MOB_LOST_CHAIN_TAIL "living_detached_chain_tail"
/// Sent from a 'contract chain' button on a mob chain
#define COMSIG_MOB_CHAIN_CONTRACT "living_chain_contracted"

/// Sent from `obj/item/reagent_containers/applicator/pill/on_consumption`: (obj/item/reagent_containers/applicator/pill/pill, mob/feeder)
#define COMSIG_LIVING_PILL_CONSUMED "living_pill_consumed"

/// Sent from a mob to their loc when starting to remove cuffs on itself
#define COMSIG_MOB_REMOVING_CUFFS "living_removing_cuffs"
	/// Sent as a reply to above from any atom that wishs to stop self-cuff removal
	#define COMSIG_MOB_BLOCK_CUFF_REMOVAL (1<<0)

/// Sent to a mob grabbing another mob: (mob/living/grabbing)
#define COMSIG_LIVING_GRAB "living_grab"
	// Return COMPONENT_CANCEL_ATTACK_CHAIN / COMPONENT_SKIP_ATTACK_CHAIN to stop the grab

/// From /datum/component/edible/get_perceived_food_quality(): (datum/component/edible/edible, list/extra_quality)
#define COMSIG_LIVING_GET_PERCEIVED_FOOD_QUALITY "get_perceived_food_quality"

///Called when living finish eat (/datum/component/edible/proc/On_Consume)
#define COMSIG_LIVING_FINISH_EAT "living_finish_eat"

/// From /datum/element/basic_eating/try_eating()
#define COMSIG_MOB_PRE_EAT "mob_pre_eat"
	///cancel eating attempt
	#define COMSIG_MOB_CANCEL_EAT (1<<0)

/// From /datum/element/basic_eating/finish_eating()
#define COMSIG_MOB_ATE "mob_ate"
	///cancel post eating
	#define COMSIG_MOB_TERMINATE_EAT (1<<0)

///From mob/living/proc/throw_mode_on and throw_mode_off
#define COMSIG_LIVING_THROW_MODE_TOGGLE "living_throw_mode_toggle"
///from /atom/movable/screen/alert/give/proc/handle_transfer(): (taker, item)
#define COMSIG_LIVING_ITEM_GIVEN "living_item_given"
/// From mob/living/proc/on_fall
#define COMSIG_LIVING_THUD "living_thud"
///From /datum/component/happiness()
#define COMSIG_MOB_HAPPINESS_CHANGE "happiness_change"
/// From /obj/item/melee/baton/baton_effect(): (datum/source, mob/living/user, /obj/item/melee/baton)
#define COMSIG_MOB_BATONED "mob_batoned"

/// From /obj/machinery/gibber/startgibbing(): (mob/living/user, /obj/machinery/gibber, list/results)
#define COMSIG_LIVING_GIBBER_ACT "living_gibber_act"

/// Sent to the mob when their mind is slaved
#define COMSIG_MOB_ENSLAVED_TO "mob_enslaved_to"
/// From /obj/item/proc/attack_atom: (mob/living/attacker, atom/attacked, list/modifiers)
#define COMSIG_LIVING_ATTACK_ATOM "living_attack_atom"
/// From /mob/living/proc/stop_leaning()
#define COMSIG_LIVING_STOPPED_LEANING "living_stopped_leaning"

/// When a living mob is table slamming another mob: (mob/living/slammed, obj/structure/table/slammed_table)
#define COMSIG_LIVING_TABLE_SLAMMING "living_table_slamming"
/// When a living mob is table slamming another mob, neck grab (so a limb slam): (mob/living/slammed, obj/structure/table/slammed_table)
#define COMSIG_LIVING_TABLE_LIMB_SLAMMING "living_table_limb_slamming"

/// From /mob/living/get_examine_name(mob/user) : (mob/examined, visible_name, list/name_override)
/// Allows mobs to override how they perceive others when examining
#define COMSIG_LIVING_PERCEIVE_EXAMINE_NAME "living_perceive_examine_name"
	#define COMPONENT_EXAMINE_NAME_OVERRIDEN (1<<0)

/// From /obj/item/book/bible/attack() : (mob/living/user, obj/item/book/bible/bible, bless_result)
#define COMSIG_LIVING_BLESSED "living_blessed"
