#define MC_BOOL_TRUE "1"
#define MC_BOOL_FALSE "0"

///The max range that two devices can be linked.
#define MC_LINK_RANGE 15


//Config entries
#define MC_CFG_UNLINK_ALL "Unlink All"
#define MC_CFG_UNLINK "Unlink Input"
#define MC_CFG_LINK "Link Device"
#define MC_CFG_OUTPUT_MESSAGE "Set Output Message"
#define MC_CFG_SET_TRIGGER "Set Trigger"

///For use in Initialize(), add inputs to our input list.
#define MC_ADD_INPUT(name, proc) inputs[name] = PROC_REF(proc)
#define MC_ADD_CONFIG(name, proc) configs[name] = PROC_REF(proc)
#define MC_ADD_TRIGGER MC_ADD_CONFIG(MC_CFG_SET_TRIGGER, set_trigger)

///Turn text into an mcmessage
#define MC_WRAP_MESSAGE(text) new /datum/mcmessage(text)


//Mechcomp signals. These are extremely special and thus dont use the COMSIG prefix.

///An output is being removed from our interface's output list (target)
#define MCACT_REMOVE_OUTPUT "mc_remove_output"
///An input is being removed from our interface's input list (target)
#define MCACT_REMOVE_INPUT "mc_remove_input"
///An output is being added to our interface's output list (target)
#define MCACT_ADD_OUTPUT "mc_add_output"
///An input is being added to our interface's input list (target)
#define MCACT_ADD_INPUT "mc_add_input"
///Called before sending a message incase we need to greeble it
#define MCACT_PRE_SEND_MESSAGE "mc_pre_message_send"
	#define MCSEND_OK 0
	#define MCSEND_CANCEL (1<<0)
	#define MCSEND_RETURN (1<<2)
	#define MCSEND_RETURN_AFTER (1<<3)
