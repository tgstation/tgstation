// Various modular computer signals.

/// From /obj/item/modular_computer/proc/store_file: (datum/computer_file/file_storing)
#define COMSIG_MODULAR_COMPUTER_FILE_STORE "comsig_modular_computer_file_store"
/// From /obj/item/modular_computer/proc/remove_file: (datum/computer_file/file_removing)
#define COMSIG_MODULAR_COMPUTER_FILE_DELETE "comsig_modular_computer_file_delete"
/// From /obj/item/modular_computer/proc/store_file: (datum/computer_file/file_source, obj/item/modular_computer/host)
#define COMSIG_COMPUTER_FILE_STORE "comsig_computer_file_store"
/// From /obj/item/modular_computer/proc/store_file: ()
#define COMSIG_COMPUTER_FILE_DELETE "comsig_computer_file_delete"

/// from /obj/item/modular_computer/imprint_id(): (name, job)
#define COMSIG_MODULAR_PDA_IMPRINT_UPDATED "comsig_modular_pda_imprint_updated"
/// from /obj/item/modular_computer/reset_id(): ()
#define COMSIG_MODULAR_PDA_IMPRINT_RESET "comsig_modular_pda_imprint_reset"

/// From /datum/computer_file/program/nt_pay/make_payment: (payment_result)
#define COMSIG_MODULAR_PROGRAM_NT_PAY_RESULT "comsig_modular_program_nt_pay_result"

/// From /datum/computer_file/program/messenger/receive_message, sent to the computer: (signal/subspace/messaging/tablet_message/signal, sender_job, sender_name)
#define COMSIG_MODULAR_PDA_MESSAGE_RECEIVED "comsig_modular_pda_message_received"
