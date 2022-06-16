// Object signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj signals
///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE "obj_hide"
/// from /obj/item/toy/crayon/spraycan/afterattack: (color_is_dark)
#define COMSIG_OBJ_PAINTED "obj_painted"

// /obj/machinery signals

///from /obj/machinery/atom_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"
///from /obj/machinery/set_occupant(atom/movable/O): (new_occupant)
#define COMSIG_MACHINERY_SET_OCCUPANT "machinery_set_occupant"
///from /obj/machinery/destructive_scanner/proc/open(aggressive): Runs when the destructive scanner scans a group of objects. (list/scanned_atoms)
#define COMSIG_MACHINERY_DESTRUCTIVE_SCAN "machinery_destructive_scan"
///from /obj/machinery/computer/arcade/prizevend(mob/user, prizes = 1)
#define COMSIG_ARCADE_PRIZEVEND "arcade_prizevend"
///from /datum/controller/subsystem/air/proc/start_processing_machine: ()
#define COMSIG_MACHINERY_START_PROCESSING_AIR "start_processing_air"
///from /datum/controller/subsystem/air/proc/stop_processing_machine: ()
#define COMSIG_MACHINERY_STOP_PROCESSING_AIR "stop_processing_air"

///from /obj/machinery/can_interact(mob/user): Called on user when attempting to interact with a machine (obj/machinery/machine)
#define COMSIG_TRY_USE_MACHINE "try_use_machine"
	/// Can't interact with the machine
	#define COMPONENT_CANT_USE_MACHINE_INTERACT (1<<0)
	/// Can't use tools on the machine
	#define COMPONENT_CANT_USE_MACHINE_TOOLS (1<<1)

///from obj/machinery/iv_drip/IV_attach(target, usr) : (attachee)
#define COMSIG_IV_ATTACH "iv_attach"
///from obj/machinery/iv_drip/IV_detach() : (detachee)
#define COMSIG_IV_DETACH "iv_detach"


// /obj/machinery/computer/teleporter
/// from /obj/machinery/computer/teleporter/proc/set_target(target, old_target)
#define COMSIG_TELEPORTER_NEW_TARGET "teleporter_new_target"

// /obj/machinery/power/supermatter_crystal signals
/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM delam reaches the point of sounding alarms
#define COMSIG_SUPERMATTER_DELAM_START_ALARM "sm_delam_start_alarm"
/// from /obj/machinery/power/supermatter_crystal/process_atmos(); when the SM sounds an audible alarm
#define COMSIG_SUPERMATTER_DELAM_ALARM "sm_delam_alarm"

// /obj/machinery/atmospherics/components/unary/cryo_cell signals

/// from /obj/machinery/atmospherics/components/unary/cryo_cell/set_on(bool): (on)
#define COMSIG_CRYO_SET_ON "cryo_set_on"

// /obj/machinery/atmospherics/components/binary/valve signals

/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"

/// from /obj/machinery/atmospherics/set_on(active): (on)
#define COMSIG_ATMOS_MACHINE_SET_ON "atmos_machine_set_on"

/// from /obj/machinery/light_switch/set_lights(), sent to every switch in the area: (status)
#define COMSIG_LIGHT_SWITCH_SET "light_switch_set"

/// from /obj/machinery/fire_alarm/reset(), /obj/machinery/fire_alarm/alarm(): (status)
#define COMSIG_FIREALARM_ON_TRIGGER "firealarm_trigger"
#define COMSIG_FIREALARM_ON_RESET "firealarm_reset"

// /obj access signals

#define COMSIG_OBJ_ALLOWED "door_try_to_activate"
	#define COMPONENT_OBJ_ALLOW (1<<0)

#define COMSIG_AIRLOCK_SHELL_ALLOWED "airlock_shell_try_allowed"
	#define COMPONENT_AIRLOCK_SHELL_ALLOW (1<<0)

// /obj/machinery/door/airlock signals

//from /obj/machinery/door/airlock/open(): (forced)
#define COMSIG_AIRLOCK_OPEN "airlock_open"
//from /obj/machinery/door/airlock/close(): (forced)
#define COMSIG_AIRLOCK_CLOSE "airlock_close"
///from /obj/machinery/door/airlock/set_bolt():
#define COMSIG_AIRLOCK_SET_BOLT "airlock_set_bolt"
// /obj/item signals

///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
/// A mob has just equipped an item. Called on [/mob] from base of [/obj/item/equipped()]: (/obj/item/equipped_item, slot)
#define COMSIG_MOB_EQUIPPED_ITEM "mob_equipped_item"
/// A mob has just unequipped an item.
#define COMSIG_MOB_UNEQUIPPED_ITEM "mob_unequipped_item"
///called on [/obj/item] before unequip from base of [mob/proc/doUnEquip]: (force, atom/newloc, no_move, invdrop, silent)
#define COMSIG_ITEM_PRE_UNEQUIP "item_pre_unequip"
	///only the pre unequip can be cancelled
	#define COMPONENT_ITEM_BLOCK_UNEQUIP (1<<0)
///called on [/obj/item] AFTER unequip from base of [mob/proc/doUnEquip]: (force, atom/newloc, no_move, invdrop, silent)
#define COMSIG_ITEM_POST_UNEQUIP "item_post_unequip"
///from base of obj/item/on_grind(): ())
#define COMSIG_ITEM_ON_GRIND "on_grind"
///from base of obj/item/on_juice(): ()
#define COMSIG_ITEM_ON_JUICE "on_juice"
///from /obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params) when an object is used as compost: (mob/user)
#define COMSIG_ITEM_ON_COMPOSTED "on_composted"
///Called when an item is dried by a drying rack:
#define COMSIG_ITEM_DRIED "item_dried"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"

/// Sebt from obj/item/ui_action_click(): (mob/user, datum/action)
#define COMSIG_ITEM_UI_ACTION_CLICK "item_action_click"
	/// Return to prevent the default behavior (attack_selfing) from ocurring.
	#define COMPONENT_ACTION_HANDLED (1<<0)

///from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"
///from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
	#define COMPONENT_HIT_REACTION_BLOCK (1<<0)
///called on item when microwaved (): (obj/machinery/microwave/M)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
	#define COMPONENT_SUCCESFUL_MICROWAVE (1<<0)
///called on item when created through microwaving (): (obj/machinery/microwave/M, cooking_efficiency)
#define COMSIG_ITEM_MICROWAVE_COOKED "microwave_cooked"
///from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_BLOCK_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)
///Called when an object is grilled ontop of a griddle
#define COMSIG_ITEM_GRILLED "item_griddled"
	#define COMPONENT_HANDLED_GRILLING (1<<0)
///Called when an object is turned into another item through grilling ontop of a griddle
#define COMSIG_GRILL_COMPLETED "item_grill_completed"
///Called when an object is meant to be grilled through a grill: (atom/fry_object, grill_time)
#define COMSIG_GRILL_FOOD "item_grill_food"
//Called when an object is in an oven
#define COMSIG_ITEM_BAKED "item_baked"
	#define COMPONENT_HANDLED_BAKING (1<<0)
	#define COMPONENT_BAKING_GOOD_RESULT (1<<1)
	#define COMPONENT_BAKING_BAD_RESULT (1<<2)
///Called when an object is turned into another item through baking in an oven
#define COMSIG_BAKE_COMPLETED "item_bake_completed"
///Called when an armor plate is successfully applied to an object
#define COMSIG_ARMOR_PLATED "armor_plated"
///Called when an item gets recharged by the ammo powerup
#define COMSIG_ITEM_RECHARGED "item_recharged"
///Called when an item is being offered, from [/obj/item/proc/on_offered(mob/living/carbon/offerer)]
#define COMSIG_ITEM_OFFERING "item_offering"
	///Interrupts the offer proc
	#define COMPONENT_OFFER_INTERRUPT (1<<0)
///Called when an someone tries accepting an offered item, from [/obj/item/proc/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)]
#define COMSIG_ITEM_OFFER_TAKEN "item_offer_taken"
	///Interrupts the offer acceptance
	#define COMPONENT_OFFER_TAKE_INTERRUPT (1<<0)
/// sent from obj/effect/attackby(): (/obj/effect/hit_effect, /mob/living/attacker, params)
#define COMSIG_ITEM_ATTACK_EFFECT "item_effect_attacked"

///from base of [/obj/item/proc/tool_check_callback]: (mob/living/user)
#define COMSIG_TOOL_IN_USE "tool_in_use"
///from base of [/obj/item/proc/tool_start_check]: (mob/living/user)
#define COMSIG_TOOL_START_USE "tool_start_use"
///from [/obj/item/proc/disableEmbedding]:
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"
///from [/obj/effect/mine/proc/triggermine]:
#define COMSIG_MINE_TRIGGERED "minegoboom"
///from [/obj/structure/closet/supplypod/proc/preOpen]:
#define COMSIG_SUPPLYPOD_LANDED "supplypodgoboom"

///from /obj/item/storage/book/bible/afterattack(): (mob/user, proximity)
#define COMSIG_BIBLE_SMACKED "bible_smacked"
	///stops the bible chain from continuing. When all of the effects of the bible smacking have been moved to a signal we can kill this
	#define COMSIG_END_BIBLE_CHAIN (1<<0)
///Closets
///From base of [/obj/structure/closet/proc/insert]: (atom/movable/inserted)
#define COMSIG_CLOSET_INSERT "closet_insert"
	///used to interrupt insertion
	#define COMPONENT_CLOSET_INSERT_INTERRUPT (1<<0)

///From open: (forced)
#define COMSIG_CLOSET_PRE_OPEN "closet_pre_open"
	#define BLOCK_OPEN (1<<0)
///From open: (forced)
#define COMSIG_CLOSET_POST_OPEN "closet_post_open"

///a deliver_first element closet was successfully delivered
#define COMSIG_CLOSET_DELIVERED "crate_delivered"

///Eigenstasium
///From base of [/datum/controller/subsystem/eigenstates/proc/use_eigenlinked_atom]: (var/target)
#define COMSIG_EIGENSTATE_ACTIVATE "eigenstate_activate"

// /obj signals for economy
///called when the payment component tries to charge an account.
#define COMSIG_OBJ_ATTEMPT_CHARGE "obj_attempt_simple_charge"
	#define COMPONENT_OBJ_CANCEL_CHARGE  (1<<0)
///Called when a payment component changes value
#define COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE "obj_attempt_simple_charge_change"

// /obj/item signals for economy
///called before an item is sold by the exports system.
#define COMSIG_ITEM_PRE_EXPORT "item_pre_sold"
	/// Stops the export from calling sell_object() on the item, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT (1<<0)
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_EXPORTED "item_sold"
	/// Stops the export from adding the export information to the report, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT_REPORT (1<<0)
///called when a wrapped up item is opened by hand
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"

// /obj/item/clothing signals

///from [/mob/living/carbon/human/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"
///from base of /obj/item/clothing/suit/space/proc/toggle_spacesuit(): (obj/item/clothing/suit/space/suit)
#define COMSIG_SUIT_SPACE_TOGGLE "suit_space_toggle"

// /obj/item/implant signals
///from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
///from base of /obj/item/implant/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
///called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)

/// called on implants, after a successful implantation: (mob/living/target, mob/user, silent, force)
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"

/// called on implants, after an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_IMPLANT_REMOVED "implant_removed"

/// called as a mindshield is implanted: (mob/user)
#define COMSIG_PRE_MINDSHIELD_IMPLANT "pre_mindshield_implant"
	/// Did they successfully get mindshielded?
	#define COMPONENT_MINDSHIELD_PASSED (NONE)
	/// Did they resist the mindshield?
	#define COMPONENT_MINDSHIELD_RESISTED (1<<0)

/// called once a mindshield is implanted: (mob/user)
#define COMSIG_MINDSHIELD_IMPLANTED "mindshield_implanted"
	/// Are we the reason for deconversion?
	#define COMPONENT_MINDSHIELD_DECONVERTED (1<<0)

///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER

// /obj/item/pda signals

///called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_TABLET_CHANGE_ID "comsig_tablet_change_id"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)
#define COMSIG_TABLET_CHECK_DETONATE "pda_check_detonate"
	#define COMPONENT_TABLET_NO_DETONATE (1<<0)

// /obj/item/radio signals

///called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"

// /obj/item/pen signals

///called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)
#define COMSIG_PEN_ROTATED "pen_rotated"

// /obj/item/gun signals

///called in /obj/item/gun/fire_gun (user, target, flag, params)
#define COMSIG_GUN_TRY_FIRE "gun_try_fire"
	#define COMPONENT_CANCEL_GUN_FIRE (1<<0)
///called in /obj/item/gun/process_fire (src, target, params, zone_override)
#define COMSIG_MOB_FIRED_GUN "mob_fired_gun"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GUN_FIRED "gun_fired"
///called in /obj/item/gun/process_chamber (src)
#define COMSIG_GUN_CHAMBER_PROCESSED "gun_chamber_processed"
///called in /obj/item/gun/ballistic/process_chamber (casing)
#define COMSIG_CASING_EJECTED "casing_ejected"

// Jetpack things
// Please kill me

//called in /obj/item/tank/jetpack/proc/turn_on() : ()
#define COMSIG_JETPACK_ACTIVATED "jetpack_activated"
	#define JETPACK_ACTIVATION_FAILED (1<<0)
//called in /obj/item/tank/jetpack/proc/turn_off() : ()
#define COMSIG_JETPACK_DEACTIVATED "jetpack_deactivated"

//called in /obj/item/organ/cyberimp/chest/thrusters/proc/toggle() : ()
#define COMSIG_THRUSTER_ACTIVATED "jetmodule_activated"
	#define THRUSTER_ACTIVATION_FAILED (1<<0)
//called in /obj/item/organ/cyberimp/chest/thrusters/proc/toggle() : ()
#define COMSIG_THRUSTER_DEACTIVATED "jetmodule_deactivated"

// /obj/effect/proc_holder/spell signals

///called from /obj/effect/proc_holder/spell/cast_check (src)
#define COMSIG_MOB_PRE_CAST_SPELL "mob_cast_spell"
	/// Return to cancel the cast from beginning.
	#define COMPONENT_CANCEL_SPELL (1<<0)
///called from /obj/effect/proc_holder/spell/perform (src)
#define COMSIG_MOB_CAST_SPELL "mob_cast_spell"

/// Sent from /obj/effect/proc_holder/spell/targeted/lichdom/cast(), to the item being imbued: (mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
	/// Returns to block this item from being imbued into a phylactery
	#define COMPONENT_BLOCK_IMBUE (1 << 0)
/// Sent from /obj/effect/proc_holder/spell/targeted/summonitem/cast(), to the item being marked : ()
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	/// Returns to block this item from being marked for instant summons
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1<<0)

/// Sent from /obj/effect/proc_holder/spell/targeted/charge/cast(), to the item in hand being charged: (obj/effect/proc_holder/spell/targeted/charge/spell, mob/living/caster)
#define COMSIG_ITEM_MAGICALLY_CHARGED "item_magic_charged"
	/// Returns if an item was successfuly recharged
	#define COMPONENT_ITEM_CHARGED (1 << 0)
	/// Returns if the item had a negative side effect occur while recharging
	#define COMPONENT_ITEM_BURNT_OUT (1 << 1)

// /obj/item/camera signals

///from /obj/item/camera/captureimage(): (atom/target, mob/user)
#define COMSIG_CAMERA_IMAGE_CAPTURED "camera_image_captured"

// /obj/item/grenade signals

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_DETONATE "grenade_prime"
//called from many places in grenade code (armed_by, nade, det_time, delayoverride)
#define COMSIG_MOB_GRENADE_ARMED "grenade_mob_armed"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"

// /obj/projectile signals (sent to the firer)

///from base of /obj/projectile/proc/on_hit(), like COMSIG_PROJECTILE_ON_HIT but on the projectile itself and with the hit limb (if any): (atom/movable/firer, atom/target, Angle, hit_limb)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///from the base of /obj/projectile/proc/fire(): ()
#define COMSIG_PROJECTILE_FIRE "projectile_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///from [/obj/item/proc/tryEmbed] sent when trying to force an embed (mainly for projectiles and eating glass)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"
	#define COMPONENT_EMBED_SUCCESS (1<<1)
// FROM [/obj/item/proc/updateEmbedding] sent when an item's embedding properties are changed : ()
#define COMSIG_ITEM_EMBEDDING_UPDATE "item_embedding_update"

///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"

// /obj/vehicle/sealed/car/vim signals

///from /datum/action/vehicle/sealed/noise/chime/Trigger(): ()
#define COMSIG_VIM_CHIME_USED "vim_chime_used"
///from /datum/action/vehicle/sealed/noise/buzz/Trigger(): ()
#define COMSIG_VIM_BUZZ_USED "vim_buzz_used"
///from /datum/action/vehicle/sealed/headlights/vim/Trigger(): (headlights_on)
#define COMSIG_VIM_HEADLIGHTS_TOGGLED "vim_headlights_toggled"

// /obj/vehicle/sealed/mecha signals

///sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_TRIGGER "mecha_action_activate"

///sent from clicking while you have no equipment selected. Sent before cooldown and adjacency checks, so you can use this for infinite range things if you want.
#define COMSIG_MECHA_MELEE_CLICK "mecha_action_melee_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_MELEE_CLICK (1<<0)
///sent from clicking while you have equipment selected.
#define COMSIG_MECHA_EQUIPMENT_CLICK "mecha_action_equipment_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_EQUIPMENT_CLICK (1<<0)

#define COMSIG_ITEM_ATTACK "item_attack"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
//from base of obj/item/attack_self_secondary(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF_SECONDARY "item_attack_self_secondary"
///from base of obj/item/attack_atom(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
/// From base of [/obj/item/proc/pre_attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK_SECONDARY "item_pre_attack_secondary"
	#define COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN (1<<0)
	#define COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN (1<<1)
	#define COMPONENT_SECONDARY_CALL_NORMAL_ATTACK_CHAIN (1<<2)
/// From base of [/obj/item/proc/attack_secondary()]: (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_SECONDARY "item_pre_attack_secondary"
///from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/afterattack_secondary(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_ITEM_AFTERATTACK_SECONDARY "item_afterattack_secondary"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"

///from /obj/item/assembly/proc/pulsed()
#define COMSIG_ASSEMBLY_PULSED "assembly_pulsed"

///from base of /obj/item/mmi/set_brainmob(): (mob/living/brain/new_brainmob)
#define COMSIG_MMI_SET_BRAINMOB "mmi_set_brainmob"

/// from base of /obj/item/slimepotion/speed/afterattack(): (obj/target, /obj/src, mob/user)
#define COMSIG_SPEED_POTION_APPLIED "speed_potion"
	#define SPEED_POTION_STOP (1<<0)
