///Called on user, from base of /datum/strippable_item/alternate_action() (atom/target)
#define COMSIG_TRY_ALT_ACTION "try_alt_action"
	#define COMPONENT_CANT_ALT_ACTION (1<<0)
///Called on /basic when updating its speed, from base of /mob/living/basic/update_basic_mob_varspeed(): ()
#define POST_BASIC_MOB_UPDATE_VARSPEED "post_basic_mob_update_varspeed"
///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
///from base of /mob/mind_initialize
#define COMSIG_MOB_MIND_INITIALIZED "mob_mind_inited"
///from base of mob/set_stat(): (new_stat, old_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
///from base of mob/reagent_check(): (datum/reagent/chem, seconds_per_tick, times_fired)
#define COMSIG_MOB_REAGENT_CHECK "mob_reagent_check"
	///stops the reagent check call
	#define COMSIG_MOB_STOP_REAGENT_CHECK (1<<0)
///from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
///from base of mob/MiddleClickOn(): (atom/A)
#define COMSIG_MOB_MIDDLECLICKON "mob_middleclickon"
///from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)
///from base of mob/alt_click_on_secodary(): (atom/A)
#define COMSIG_MOB_ALTCLICKON_SECONDARY "mob_altclickon_secondary"
/// From base of /mob/living/simple_animal/bot/proc/bot_step()
#define COMSIG_MOB_BOT_PRE_STEP "mob_bot_pre_step"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMPONENT_MOB_BOT_BLOCK_PRE_STEP COMPONENT_MOVABLE_BLOCK_PRE_MOVE
/// From base of /mob/living/simple_animal/bot/proc/bot_step()
#define COMSIG_MOB_BOT_STEP "mob_bot_step"

/// From base of /mob/proc/update_held_items
#define COMSIG_MOB_UPDATE_HELD_ITEMS "mob_update_held_items"

/// From base of /client/Move(): (list/move_args)
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// From base of /client/Move(): (new_loc, direction)
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	/// The argument of move_args which corresponds to the loc we're moving to
	#define MOVE_ARG_NEW_LOC 1
	/// The arugment of move_args which dictates our movement direction
	#define MOVE_ARG_DIRECTION 2
/// From base of /client/Move(): (direction, old_dir)
#define COMSIG_MOB_CLIENT_MOVED "mob_client_moved"
/// From base of /client/proc/change_view() (mob/source, new_size)
#define COMSIG_MOB_CLIENT_CHANGE_VIEW "mob_client_change_view"
/// From base of /mob/proc/reset_perspective() : ()
#define COMSIG_MOB_RESET_PERSPECTIVE "mob_reset_perspective"
/// from base of /client/proc/set_eye() : (atom/old_eye, atom/new_eye)
#define COMSIG_CLIENT_SET_EYE "client_set_eye"
/// from base of /datum/view_data/proc/afterViewChange() : (view)
#define COMSIG_VIEWDATA_UPDATE "viewdata_update"

/// Sent from /proc/do_after if someone starts a do_after action bar.
#define COMSIG_DO_AFTER_BEGAN "mob_do_after_began"
/// Sent from /proc/do_after once a do_after action completes, whether via the bar filling or via interruption.
#define COMSIG_DO_AFTER_ENDED "mob_do_after_ended"

///from mind/transfer_to. Sent to the receiving mob.
#define COMSIG_MOB_MIND_TRANSFERRED_INTO "mob_mind_transferred_into"
/// From /mob/proc/ghostize() Called when a mob sucessfully ghosts
#define COMSIG_MOB_GHOSTIZED "mob_ghostized"

///from base of obj/allowed(mob/M): (/obj) returns ACCESS_ALLOWED if mob has id access to the obj
#define COMSIG_MOB_TRIED_ACCESS "tried_access"
	#define ACCESS_ALLOWED (1<<0)
	#define ACCESS_DISALLOWED (1<<1)
	#define LOCKED_ATOM_INCOMPATIBLE (1<<2)

///from base of mob/can_cast_magic(): (mob/user, magic_flags, charge_cost)
#define COMSIG_MOB_RESTRICT_MAGIC "mob_cast_magic"
///from base of mob/can_block_magic(): (mob/user, casted_magic_flags, charge_cost)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_MAGIC_BLOCKED (1<<0)

///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
///from base of hud/show_to(): (datum/hud/hud_source)
#define COMSIG_MOB_HUD_REFRESHED "mob_hud_refreshed"

///from base of mob/set_sight(): (new_sight, old_sight)
#define COMSIG_MOB_SIGHT_CHANGE "mob_sight_changed"
///from base of mob/set_invis_see(): (new_invis, old_invis)
#define COMSIG_MOB_SEE_INVIS_CHANGE "mob_see_invis_change"


///from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
#define COMSIG_MOB_APPLY_DAMAGE "mob_apply_damage"
///from /mob/living/proc/apply_damage(), works like above but after the damage is actually inflicted: (damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
#define COMSIG_MOB_AFTER_APPLY_DAMAGE "mob_after_apply_damage"
///from base of /mob/living/attack_alien(): (user)
#define COMSIG_MOB_ATTACK_ALIEN "mob_attack_alien"
///from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
///from /mob/living/handle_eye_contact(): (mob/living/other_mob)
#define COMSIG_MOB_EYECONTACT "mob_eyecontact"
	/// return this if you want to block printing this message to this person, if you want to print your own (does not affect the other person's message)
	#define COMSIG_BLOCK_EYECONTACT (1<<0)
///from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	#define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	#define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7
	#define SPEECH_FILTERPROOF 8
	#define SPEECH_RANGE 9
	#define SPEECH_SAYMODE 10

///from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)
///from /mob/living/emote(): ()
#define COMSIG_MOB_EMOTE "mob_emote"
///from base of mob/swap_hand(): (obj/item/currently_held_item)
#define COMSIG_MOB_SWAPPING_HANDS "mob_swapping_hands"
	#define COMPONENT_BLOCK_SWAP (1<<0)
/// from base of mob/swap_hand(): ()
/// Performed after the hands are swapped.
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"
///from base of /mob/verb/pointed: (atom/A)
#define COMSIG_MOB_POINTED "mob_pointed"
///Mob is trying to open the wires of a target [/atom], from /datum/wires/interactable(): (atom/target)
#define COMSIG_TRY_WIRES_INTERACT "try_wires_interact"
	#define COMPONENT_CANT_INTERACT_WIRES (1<<0)
///Mob is trying to emote, from /datum/emote/proc/run_emote(): (key, params, type_override, intentional)
#define COMSIG_MOB_PRE_EMOTED "mob_pre_emoted"
	#define COMPONENT_CANT_EMOTE (1<<0)
#define COMSIG_MOB_EMOTED(emote_key) "mob_emoted_[emote_key]"
///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
//from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"
///Called on user, from base of /datum/strippable_item/try_(un)equip() (atom/target, obj/item/equipping?)
#define COMSIG_TRY_STRIP "try_strip"
	#define COMPONENT_CANT_STRIP (1<<0)
///From /datum/component/creamed/Initialize()
#define COMSIG_MOB_CREAMED "mob_creamed"
///From /obj/item/gun/proc/check_botched()
#define COMSIG_MOB_CLUMSY_SHOOT_FOOT "mob_clumsy_shoot_foot"
///from /obj/item/hand_item/slapper/attack_atom(): (source=obj/structure/table/slammed_table, mob/living/slammer)
#define COMSIG_TABLE_SLAMMED "table_slammed"
///from base of atom/attack_hand(): (mob/user, modifiers)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
///from base of obj/item/afterattack(): (atom/target, obj/item/weapon, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of obj/item/afterattack_secondary(): (atom/target, obj/item/weapon, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK_SECONDARY "mob_item_afterattack_secondary"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_ATTACK_QDELETED "mob_item_attack_qdeleted"
///from base of mob/RangedAttack(): (atom/A, modifiers)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from base of mob/ranged_secondary_attack(): (atom/target, modifiers)
#define COMSIG_MOB_ATTACK_RANGED_SECONDARY "mob_attack_ranged_secondary"
///From base of atom/ctrl_click(): (atom/A)
#define COMSIG_MOB_CTRL_CLICKED "mob_ctrl_clicked"
///From base of mob/update_movespeed():area
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"
/// From /atom/movable/screen/zone_sel/proc/set_selected_zone.
/// Fires when the user has changed their selected body target.
#define COMSIG_MOB_SELECTED_ZONE_SET "mob_set_selected_zone"
/// from base of [/client/proc/handle_spam_prevention] (message, mute_type)
#define COMSIG_MOB_AUTOMUTE_CHECK "client_automute_check" // The check is performed by the client.
	/// Prevents the automute system checking this client for repeated messages.
	#define WAIVE_AUTOMUTE_CHECK (1<<0)
///From base of /turf/closed/mineral/proc/gets_drilled(): (turf/closed/mineral/rock, give_exp)
#define COMSIG_MOB_MINED "mob_mined"
///Sent by pilot of mech in base of /obj/vehicle/sealed/mecha/relaymove(): (/obj/vehicle/sealed/mecha/mech)
#define COMSIG_MOB_DROVE_MECH "mob_drove_mech"
///Sent by pilot of mech in /obj/vehicle/sealed/mecha/on_mouseclick when using mech equipment : (/obj/vehicle/sealed/mecha/mech)
#define COMSIG_MOB_USED_MECH_EQUIPMENT "mob_used_mech_equipment"
///Sent by pilot of mech in /obj/vehicle/sealed/mecha/on_mouseclick when triggering mech punch : (/obj/vehicle/sealed/mecha/mech)
#define COMSIG_MOB_USED_MECH_MELEE "mob_used_mech_melee"

///from living/flash_act(), when a mob is successfully flashed.
#define COMSIG_MOB_FLASHED "mob_flashed"
/// from /obj/item/assembly/flash/flash_carbon, to the mob flashing another carbon
#define COMSIG_MOB_PRE_FLASHED_CARBON "mob_pre_flashed_carbon"
	/// Return to override deviation to be full deviation (fail the flash, usually)
	#define DEVIATION_OVERRIDE_FULL (1<<0)
	/// Return to override deviation to be partial deviation
	#define DEVIATION_OVERRIDE_PARTIAL (1<<1)
	/// Return to override deviation to be no deviation
	#define DEVIATION_OVERRIDE_NONE (1<<2)
	/// Return to stop the flash entirely
	#define STOP_FLASH (1<<3)
/// from /obj/item/assembly/flash/flash_carbon, to the mob flashing another carbon
#define COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON "mob_success_flashed_carbon"

/// from mob/get_status_tab_items(): (list/items)
#define COMSIG_MOB_GET_STATUS_TAB_ITEMS "mob_get_status_tab_items"

/// from /mob/living/carbon/human/can_equip(): (mob/living/carbon/human/source_human, obj/item/equip_target, slot)
#define COMSIG_HUMAN_EQUIPPING_ITEM "mob_equipping_item"
	/// cancels the equip.
	#define COMPONENT_BLOCK_EQUIP (1<<0)

/// from mob/proc/dropItemToGround()
#define COMSIG_MOB_DROPPING_ITEM "mob_dropping_item"

/// from /mob/proc/change_mob_type() : ()
#define COMSIG_PRE_MOB_CHANGED_TYPE "mob_changed_type"
	#define COMPONENT_BLOCK_MOB_CHANGE (1<<0)
/// from /mob/proc/change_mob_type_unchecked() : ()
#define COMSIG_MOB_CHANGED_TYPE "mob_changed_type"
