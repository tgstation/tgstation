TGS_DEFINE_AND_SET_GLOBAL(tgs, null)

/datum/tgs_api
	var/datum/tgs_version/version
	var/datum/tgs_event_handler/event_handler

/datum/tgs_api/New(datum/tgs_event_handler/event_handler, datum/tgs_version/version)
	. = ..()
	src.event_handler = event_handler
	src.version = version

/datum/tgs_api/latest
	parent_type = /datum/tgs_api/v5

TGS_PROTECT_DATUM(/datum/tgs_api)

/datum/tgs_api/proc/ApiVersion()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/OnWorldNew(datum/tgs_event_handler/event_handler)
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/OnInitializationComplete()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/OnTopic(T)
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/OnReboot()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/InstanceName()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/TestMerges()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/EndProcess()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/Revision()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/ChatChannelInfo()
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/ChatBroadcast(message, list/channels)
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/ChatTargetedBroadcast(message, admin_only)
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/ChatPrivateMessage(message, datum/tgs_chat_user/user)
	return TGS_UNIMPLEMENTED

/datum/tgs_api/proc/SecurityLevel()
	return TGS_UNIMPLEMENTED
