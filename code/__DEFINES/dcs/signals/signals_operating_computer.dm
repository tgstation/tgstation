// /obj/machinery/computer/operating signals

/// Fired when a autopsy surgery completes.
/// (mob/living/target)
#define COMSIG_OPERATING_COMPUTER_AUTOPSY_COMPLETE "operating_computer_autopsy_complete"

/// Fired on the loc when an operating table is created.
/// (obj/machinery/computer/operating/operating_computer)
#define COMSIG_OPERATING_COMPUTER_INITIALIZED "operating_computer_initialized"

// /datum/component/links_to_operating_computers signals

/// Fired on an operating computer when either it initializes next to a link,
/// or one is created next to an existing operating computer.
/// (datum/component/links_to_operating_computers/link, list/mob/living/carbon/patients)
#define COMSIG_LINKS_TO_OPERATING_COMPUTERS_INITIALIZED "links_to_operating_computer_initialized"

/// Fired when a patient is added to the linked object.
/// (mob/living/carbon/patient)
#define COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_ADDED "links_to_operating_computers_patient_added"

/// Fired when a patient is removed from the linked object
/// (mob/living/carbon/patient)
#define COMSIG_LINKS_TO_OPERATING_COMPUTERS_PATIENT_REMOVED "links_to_operating_computers_patient_removed"
