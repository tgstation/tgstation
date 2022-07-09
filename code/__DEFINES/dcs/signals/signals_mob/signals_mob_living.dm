///called on /living when attempting to pick up an item, from base of /mob/living/put_in_hand_check(): (obj/item/I)
#define COMSIG_LIVING_TRY_PUT_IN_HAND "living_try_put_in_hand"
	/// Can't pick up
	#define COMPONENT_LIVING_CANT_PUT_IN_HAND (1<<0)

// Organ signals
/// Called on the organ when it is implanted into someone (mob/living/carbon/receiver)
#define COMSIG_ORGAN_IMPLANTED "comsig_organ_implanted"
/// Called when using the *wag emote
#define COMSIG_ORGAN_WAG_TAIL "comsig_wag_tail"
/// Called on the organ when it is removed from someone (mob/living/carbon/old_owner)
#define COMSIG_ORGAN_REMOVED "comsig_organ_removed"

///from base of mob/update_transform()
#define COMSIG_LIVING_POST_UPDATE_TRANSFORM "living_post_update_transform"

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

///from base of mob/living/death(): (gibbed)
#define COMSIG_LIVING_DEATH "living_death"

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
///from /obj/item/hand_item/slapper/attack_atom(): (source=mob/living/slammer, obj/structure/table/slammed_table)
#define COMSIG_LIVING_SLAM_TABLE "living_slam_table"
///from /obj/item/hand_item/slapper/attack(): (source=mob/living/slapper, mob/living/slapped)
#define COMSIG_LIVING_SLAP_MOB "living_slap_mob"
///(NOT on humans) from mob/living/*/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"
///From base of mob/living/MobBump() (mob/living)
#define COMSIG_LIVING_MOB_BUMP "living_mob_bump"
///From base of mob/living/ZImpactDamage() (mob/living, levels, turf/t)
#define COMSIG_LIVING_Z_IMPACT "living_z_impact"
	#define NO_Z_IMPACT_DAMAGE (1<<0)

/// From mob/living/treat_message(): (list/message_args)
#define COMSIG_LIVING_TREAT_MESSAGE "living_treat_message"

///From obj/item/toy/crayon/spraycan
#define COMSIG_LIVING_MOB_PAINTED "living_mob_painted"
