/// From /datum/surgery/New(): (datum/surgery/surgery, surgery_location (body zone), obj/item/bodypart/targeted_limb)
#define COMSIG_MOB_SURGERY_STARTED "mob_surgery_started"

/// From /datum/surgery_step/success(): (datum/surgery_step/step, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
#define COMSIG_MOB_SURGERY_STEP_SUCCESS "mob_surgery_step_success"

/// From /obj/item/shockpaddles/do_help, after the defib do_after is complete, but before any effects are applied: (mob/living/defibber, obj/item/shockpaddles/source)
#define COMSIG_DEFIBRILLATOR_PRE_HELP_ZAP "carbon_being_defibbed"
	/// Return to stop default defib handling
	#define COMPONENT_DEFIB_STOP (1<<0)

/// From /obj/item/shockpaddles/proc/do_success(): (obj/item/shockpaddles/source)
#define COMSIG_DEFIBRILLATOR_SUCCESS "defib_success"
	// #define COMPONENT_DEFIB_STOP (1<<0) // Same return, to stop default defib handling

/// From /obj/item/shockpaddles/proc/do_disarm(), sent to the shock-ee in non-revival scenarios: (obj/item/shockpaddles/source)
#define COMSIG_HEARTATTACK_DEFIB "heartattack_defib"

/// From /datum/surgery/can_start(): (mob/source, datum/surgery/surgery, mob/living/patient)
#define COMSIG_SURGERY_STARTING "surgery_starting"
	#define COMPONENT_CANCEL_SURGERY (1<<0)
	#define COMPONENT_FORCE_SURGERY (1<<1)
