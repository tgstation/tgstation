///sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
///sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"
///called from /obj/item/borg/cyborghug/attack proc
#define COMSIG_BORG_HUG_MOB "borg_hug_mob"
	///returned if this action was handled by signal handler.
	#define COMSIG_BORG_HUG_HANDLED 1
///called from /mob/living/silicon/attack_hand proc
#define COMSIG_MOB_PAT_BORG "mob_pat_borg"
