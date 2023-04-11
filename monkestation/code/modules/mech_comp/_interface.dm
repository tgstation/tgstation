/datum/mcinterface
	var/obj/item/mcobject/owner

	///A list of mcinterfaces that we are recieving from
	var/list/datum/mcinterface/inputs = list()
	///A list of mcinterfaces that we are outputting to
	var/list/datum/mcinterface/outputs = list()

/datum/mcinterface/New(obj/item/mcobject/_owner)
	owner = _owner
	RegisterSignal()

/datum/mcinterface/Destroy(force, ...)
	owner = null
	ClearConnections()
	return ..()

/datum/mcinterface/proc/ClearConnections()
	if(length(inputs) || length(outputs))
		. = TRUE

	for(var/datum/mcinterface/I as anything in inputs)
		RemoveInput(I)
	for(var/datum/mcinterface/I as anything in outputs)
		RemoveOutput(I)

////
////// MESSAGES
////

///Add an interface to our inputs, and add us to their outputs. Origin is an arg used to prevent an infinite loop of add/remove
/datum/mcinterface/proc/AddInput(datum/mcinterface/target, act, origin)
	if(origin == src)
		return
	origin ||= src
	target.AddOutput(src, act, origin)
	inputs[target] = act

///Add an interface to our outputs, and add us to their inputs. Origin is an arg used to prevent an infinite loop of add/remove
/datum/mcinterface/proc/AddOutput(datum/mcinterface/target, act, origin)
	if(origin == src)
		return
	origin ||= src
	target.AddInput(src, act, origin)
	outputs[target] = act

///Remove an interface from our inputs, and remove us from their outputs. Origin is an arg used to prevent an infinite loop of add/remove
/datum/mcinterface/proc/RemoveInput(datum/mcinterface/target, origin)
	if(origin == src)
		return
	origin ||= src
	target.RemoveOutput(src, origin)
	inputs -= target

///Remove an interface from our outputs, and remove us from their inputs. Origin is an arg used to prevent an infinite loop of add/remove
/datum/mcinterface/proc/RemoveOutput(datum/mcinterface/target, origin)
	if(origin == src)
		return
	origin ||= src
	SEND_SIGNAL(src, MCACT_REMOVE_OUTPUT, target)
	target.RemoveInput(src, origin)
	outputs -= target

///Send an mcmessage to our outputs
/datum/mcinterface/proc/Send(datum/mcmessage/message, datum/mcmessage/cached_message)
	SHOULD_NOT_SLEEP(TRUE)
	if(isnull(message))
		CRASH("Ahhhhhh null message aaaaaahhhhhh (dies)")

	if(!istype(message))
		if(cached_message)
			cached_message.cmd = message
			message = cached_message
		else
			message = MC_WRAP_MESSAGE(message)

	//By now the message is a proper message datum
	if(message.CheckSender(src))
		return FALSE

	message.AddSender(src)

	for(var/datum/mcinterface/I as anything in outputs)
		var/action = SEND_SIGNAL(src, MCACT_PRE_SEND_MESSAGE, I, message)
		//Note: a target not handling a signal returns 0.
		if(action == MCSEND_RETURN) //The component wants signal processing to stop NOW
			return .
		if(action == MCSEND_CANCEL) //The component wants this signal to be skipped
			continue
		var/obj/item/mcobject/O = I.owner
		call(O, O.inputs[outputs[I]])(message.Copy())
		. = TRUE
		if(action == MCSEND_RETURN_AFTER) //The component wants signal processing to stop AFTER this signal
			return .
	return .
