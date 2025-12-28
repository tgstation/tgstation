/// From /datum/surgery_operation/try_perform(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_LIVING_SURGERY_STARTED "mob_surgery_started"
/// From /datum/surgery_operation/try_perform(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_LIVING_SURGERY_FINISHED "mob_surgery_finished"
/// From /datum/surgery_operation/success(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_LIVING_SURGERY_SUCCESS "mob_surgery_step_success"
/// From /datum/surgery_operation/failure(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_LIVING_SURGERY_FAILED "mob_surgery_step_failed"

/// From /obj/item/shockpaddles/do_help, after the defib do_after is complete, but before any effects are applied: (mob/living/defibber, obj/item/shockpaddles/source)
#define COMSIG_DEFIBRILLATOR_PRE_HELP_ZAP "carbon_being_defibbed"
	/// Return to stop default defib handling
	#define COMPONENT_DEFIB_STOP (1<<0)

/// From /obj/item/shockpaddles/proc/do_success(): (obj/item/shockpaddles/source)
#define COMSIG_DEFIBRILLATOR_SUCCESS "defib_success"
	// #define COMPONENT_DEFIB_STOP (1<<0) // Same return, to stop default defib handling

/// From /obj/item/shockpaddles/proc/do_disarm(), sent to the shock-ee in non-revival scenarios: (obj/item/shockpaddles/source)
#define COMSIG_HEARTATTACK_DEFIB "heartattack_defib"

/// Sent from /mob/living/perform_surgery: (mob/living/patient, list/possible_operations)
#define COMSIG_LIVING_OPERATING_ON "living_operating_on"
/// Sent from /mob/living/perform_surgery: (mob/living/patient, list/possible_operations)
#define COMSIG_LIVING_BEING_OPERATED_ON "living_being_operated_on"
