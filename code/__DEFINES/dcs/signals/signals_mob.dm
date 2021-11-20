///Called on /basic when updating its speed, from base of /mob/living/basic/update_basic_mob_varspeed(): ()
#define POST_BASIC_MOB_UPDATE_VARSPEED "post_basic_mob_update_varspeed"
///from base of /mob/Login(): ()
#define COMSIG_MOB_LOGIN "mob_login"
///from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
///from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
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

/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_MOVED "mob_client_moved"

///from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_ALLOWED "mob_allowed"
///from base of mob/anti_magic_check(): (mob/user, magic, holy, tinfoil, chargecost, self, protection_sources)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_BLOCK_MAGIC (1<<0)
///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"

///from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone)
#define COMSIG_MOB_APPLY_DAMAGE "mob_apply_damage"
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
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	// #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	/* #define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */

///from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT (1<<0)
///from /mob/living/emote(): ()
#define COMSIG_MOB_EMOTE "mob_emote"
///from base of mob/swap_hand(): (obj/item)
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"
	#define COMPONENT_BLOCK_SWAP (1<<0)
///from base of /mob/verb/pointed: (atom/A)
#define COMSIG_MOB_POINTED "mob_pointed"
///Mob is trying to open the wires of a target [/atom], from /datum/wires/interactable(): (atom/target)
#define COMSIG_TRY_WIRES_INTERACT "try_wires_interact"
	#define COMPONENT_CANT_INTERACT_WIRES (1<<0)
#define COMSIG_MOB_EMOTED(emote_key) "mob_emoted_[emote_key]"

///from base of mob/update_transform()
#define COMSIG_LIVING_POST_UPDATE_TRANSFORM "living_post_update_transform"

///from /obj/structure/door/crush(): (mob/living/crushed, /obj/machinery/door/crushing_door)
#define COMSIG_LIVING_DOORCRUSHED "living_doorcrush"
///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/extinguish_mob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
///from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
///sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of /mob/living/regenerate_limbs(): (noheal, excluded_limbs)
#define COMSIG_LIVING_REGENERATE_LIMBS "living_regen_limbs"
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
///from base of mob/living/set_body_position()
#define COMSIG_LIVING_SET_BODY_POSITION  "living_set_body_position"
///From post-can inject check of syringe after attack (mob/user)
#define COMSIG_LIVING_TRY_SYRINGE "living_try_syringe"
///From living/Life(). (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"

///from base of element/bane/activate(): (item/weapon, mob/user)
#define COMSIG_LIVING_BANED "living_baned"
///Sent when bloodcrawl ends in mob/living/phasein(): (phasein_decal)
#define COMSIG_LIVING_AFTERPHASEIN "living_phasein"

///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"

/// from /proc/healthscan(): (list/scan_results, advanced, mob/user, mode)
/// Consumers are allowed to mutate the scan_results list to add extra information
#define COMSIG_LIVING_HEALTHSCAN "living_healthscan"

///sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
///sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"

///sent when a mob/login() finishes: (client)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
//from base of client/MouseDown(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEUP "client_mouseup"
	#define COMPONENT_CLIENT_MOUSEUP_INTERCEPT (1<<0)
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!

///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Knockdown() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Paralyze() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/Unconscious() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
	#define COMPONENT_NO_STUN (1<<0) //For all of them
///from base of /mob/living/can_track(): (mob/user)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)
///from end of fully_heal(): (admin_revive)
#define COMSIG_LIVING_POST_FULLY_HEAL "living_post_fully_heal"
/// from start of /mob/living/handle_breathing(): (delta_time, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"

///Called on user, from base of /datum/strippable_item/try_(un)equip() (atom/target, obj/item/equipping?)
///also from /mob/living/stripPanel(Un)equip)()
#define COMSIG_TRY_STRIP "try_strip"
	#define COMPONENT_CANT_STRIP (1<<0)

///Called on user, from base of /datum/strippable_item/alternate_action() (atom/target)
#define COMSIG_TRY_ALT_ACTION "try_alt_action"
	#define COMPONENT_CANT_ALT_ACTION (1<<0)

///From /datum/component/creamed/Initialize()
#define COMSIG_MOB_CREAMED "mob_creamed"
///From /obj/item/gun/proc/check_botched()
#define COMSIG_MOB_CLUMSY_SHOOT_FOOT "mob_clumsy_shoot_foot"

///When a carbon mob hugs someone, this is called on the carbon that is hugging. (mob/living/hugger, mob/living/hugged)
#define COMSIG_CARBON_HUG "carbon_hug"
///When a carbon mob is hugged, this is called on the carbon that is hugged. (mob/living/hugger)
#define COMSIG_CARBON_HUGGED "carbon_hugged"
///When a carbon mob is headpatted, this is called on the carbon that is headpatted. (mob/living/headpatter)
#define COMSIG_CARBON_HEADPAT "carbon_headpatted"
///When a carbon mob has their tail pulled, this is called on the carbon that is the target. (mob/living/tailpuller)
#define COMSIG_CARBON_TAILPULL "carbon_tailpulled"
///Before a carbon mob is shoved, sent to the turf we're trying to shove onto (mob/living/carbon/shover, mob/living/carbon/target)
#define COMSIG_CARBON_DISARM_PRESHOVE "carbon_disarm_preshove"
	#define COMSIG_CARBON_ACT_SOLID (1<<0) //Tells disarm code to act as if the mob was shoved into something solid, even we we're not
///When a carbon mob is disarmed, this is sent to the turf we're trying to shove onto (mob/living/carbon/shover, mob/living/carbon/target, shove_blocked)
#define COMSIG_CARBON_DISARM_COLLIDE "carbon_disarm_collision"
	#define COMSIG_CARBON_SHOVE_HANDLED (1<<0)

///When a carbon slips. Called on /turf/open/handle_slip()
#define COMSIG_ON_CARBON_SLIP "carbon_slip"
///When a carbon gets a vending machine tilted on them
#define COMSIG_ON_VENDOR_CRUSH "carbon_vendor_crush"
// /mob/living/carbon physiology signals
#define COMSIG_CARBON_GAIN_WOUND "carbon_gain_wound" //from /datum/wound/proc/apply_wound() (/mob/living/carbon/C, /datum/wound/W, /obj/item/bodypart/L)
#define COMSIG_CARBON_LOSE_WOUND "carbon_lose_wound" //from /datum/wound/proc/remove_wound() (/mob/living/carbon/C, /datum/wound/W, /obj/item/bodypart/L)
///from base of /obj/item/bodypart/proc/attach_limb(): (new_limb, special) allows you to fail limb attachment
#define COMSIG_CARBON_ATTACH_LIMB "carbon_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
#define COMSIG_CARBON_REMOVE_LIMB "carbon_remove_limb" //from base of /obj/item/bodypart/proc/drop_limb(special, dismembered)
#define COMSIG_BODYPART_GAUZED "bodypart_gauzed" // from /obj/item/bodypart/proc/apply_gauze(/obj/item/stack/gauze)
#define COMSIG_BODYPART_GAUZE_DESTROYED "bodypart_degauzed" // from [/obj/item/bodypart/proc/seep_gauze] when it runs out of absorption

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_EQUIP_HAT "carbon_equip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_HAT "carbon_unequip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_SHOECOVER "carbon_unequip_shoecover"
#define COMSIG_CARBON_EQUIP_SHOECOVER "carbon_equip_shoecover"
///defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
///called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
///Called when someone attempts to cuff a carbon
#define COMSIG_CARBON_CUFF_ATTEMPTED "carbon_attempt_cuff"
///Called when a carbon mutates (source = dna, mutation = mutation added)
#define COMSIG_CARBON_GAIN_MUTATION "carbon_gain_mutation"
///Called when a carbon loses a mutation (source = dna, mutation = mutation lose)
#define COMSIG_CARBON_LOSE_MUTATION "carbon_lose_mutation"
///Called when a carbon becomes addicted (source = what addiction datum, addicted_mind = mind of the addicted carbon)
#define COMSIG_CARBON_GAIN_ADDICTION "carbon_gain_addiction"
///Called when a carbon is no longer addicted (source = what addiction datum was lost, addicted_mind = mind of the freed carbon)
#define COMSIG_CARBON_LOSE_ADDICTION "carbon_lose_addiction"
///Called when a carbon gets a brain trauma (source = carbon, trauma = what trauma was added) - this is before on_gain()
#define COMSIG_CARBON_GAIN_TRAUMA "carbon_gain_trauma"
///Called when a carbon loses a brain trauma (source = carbon, trauma = what trauma was removed)
#define COMSIG_CARBON_LOSE_TRAUMA "carbon_lose_trauma"
///Called when a carbon updates their health (source = carbon)
#define COMSIG_CARBON_HEALTH_UPDATE "carbon_health_update"
///Called when a carbon updates their sanity (source = carbon)
#define COMSIG_CARBON_SANITY_UPDATE "carbon_sanity_update"

// simple_animal signals
/// called when a simplemob is given sentience from a potion (target = person who sentienced)
#define COMSIG_SIMPLEMOB_SENTIENCEPOTION "simplemob_sentiencepotion"

// /mob/living/simple_animal/hostile signals
///before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK (1<<0) //cancel the attack, only works before attack happens
///after attackingtarget has happened, source is the attacker and target is the attacked, extra argument for if the attackingtarget was successful
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"
///from base of mob/living/simple_animal/hostile/regalrat: (mob/living/simple_animal/hostile/regalrat/king)
#define COMSIG_RAT_INTERACT "rat_interaction"

///from /obj/item/slapper/attack_atom(): (source=mob/living/slammer, obj/structure/table/slammed_table)
#define COMSIG_LIVING_SLAM_TABLE "living_slam_table"
///from /obj/item/slapper/attack_atom(): (source=obj/structure/table/slammed_table, mob/living/slammer)
#define COMSIG_TABLE_SLAMMED "table_slammed"
// /mob/living/carbon/human signals

///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT "human_disarm_hit"
///Whenever EquipRanked is called, called after job is set
#define COMSIG_JOB_RECEIVED "job_received"
///from /mob/living/carbon/human/proc/set_coretemperature(): (oldvalue, newvalue)
#define COMSIG_HUMAN_CORETEMP_CHANGE "human_coretemp_change"
///from /datum/species/handle_fire. Called when the human is set on fire and burning clothes and stuff
#define COMSIG_HUMAN_BURNING "human_burning"
///from base of atom/attack_hand(): (mob/user, modifiers)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
///from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
///from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
///from base of obj/item/afterattack_secondary(): (atom/target, mob/user, proximity_flag, click_parameters)
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
///(NOT on humans) from mob/living/*/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///FROM mob/living/simple_animal/hostile/ooze/eat_atom(): (atom/target, edible_flags)
#define COMSIG_OOZE_EAT_ATOM "ooze_eat_atom"
	#define COMPONENT_ATOM_EATEN  (1<<0)
