#define HOLOPAD_MAX_DIAL_TIME 200

/mob/camera/aiEye/remote/holo/setLoc()
	. = ..()
	var/obj/machinery/holopad/H = origin
	H.move_hologram(eye_user, loc)

//this datum manages it's own references

/datum/holocall
	var/mob/living/user	//the one that called
	var/obj/machinery/holopad/calling_holopad	//the one that sent the call
	var/obj/machinery/holopad/connected_holopad	//the one that answered the call (may be null)
	var/list/dialed_holopads	//all things called, will be cleared out to just connected_holopad once answered

	var/mob/camera/aiEye/remote/holo/eye	//user's eye, once connected
	var/obj/effect/overlay/holo_pad_hologram/hologram	//user's hologram, once connected
	var/datum/action/innate/end_holocall/hangup	//hangup action

	var/call_start_time

//creates a holocall made by `caller` from `calling_pad` to `callees`
/datum/holocall/New(mob/living/caller, obj/machinery/holopad/calling_pad, list/callees)
	call_start_time = world.time
	user = caller
	calling_pad.outgoing_call = src
	calling_holopad = calling_pad
	dialed_holopads = list()

	for(var/I in callees)
		var/obj/machinery/holopad/H = I
		if(!QDELETED(H) && H.is_operational())
			dialed_holopads += H
			H.say("Incoming call.")
			LAZYADD(H.holo_calls, src)

	if(!dialed_holopads.len)
		calling_pad.say("Connection failure.")
		qdel(src)
		return
	
	testing("Holocall started")

//cleans up ALL references :)
/datum/holocall/Destroy()
	QDEL_NULL(hangup)

	var/user_good = !QDELETED(user)
	if(user_good)
		user.reset_perspective()
		user.remote_control = null
	
	if(!QDELETED(eye))
		if(user_good && user.client)
			for(var/datum/camerachunk/chunk in eye.visibleCameraChunks)
				chunk.remove(eye)
		qdel(eye)
	eye = null
	
	user = null
	
	if(hologram)
		hologram.HC = null
		hologram = null

	for(var/I in dialed_holopads)
		var/obj/machinery/holopad/H = I
		LAZYREMOVE(H.holo_calls, src)
	dialed_holopads.Cut()

	if(calling_holopad)
		calling_holopad.outgoing_call = null
		calling_holopad.SetLightsAndPower()
		calling_holopad = null
	if(connected_holopad)
		connected_holopad.SetLightsAndPower()
		connected_holopad = null
	
	testing("Holocall destroyed")

	return ..()

//Gracefully disconnects a holopad `H` from a call. Pads not in the call are ignored. Notifies participants of the disconnection
/datum/holocall/proc/Disconnect(obj/machinery/holopad/H)
	testing("Holocall disconnect")
	if(H == connected_holopad)
		calling_holopad.say("[usr] disconnected.")
	else if(H == calling_holopad && connected_holopad)
		connected_holopad.say("[usr] disconnected.")

	ConnectionFailure(H, TRUE)

//Forcefully disconnects a holopad `H` from a call. Pads not in the call are ignored.
/datum/holocall/proc/ConnectionFailure(obj/machinery/holopad/H, graceful = FALSE)
	testing("Holocall connection failure: graceful [graceful]")
	if(H == connected_holopad || H == calling_holopad)
		if(!graceful && H != calling_holopad)
			calling_holopad.say("Connection failure.")
		qdel(src)
		return

	LAZYREMOVE(H.holo_calls, src)
	dialed_holopads -= H
	if(!dialed_holopads.len)
		if(graceful)
			calling_holopad.say("Call rejected.")
		testing("No recipients, terminating")
		qdel(src)

//Answers a call made to a holopad `H` which cannot be the calling holopad. Pads not in the call are ignored
/datum/holocall/proc/Answer(obj/machinery/holopad/H)
	testing("Holocall answer")
	if(H == calling_holopad)
		CRASH("How cute, a holopad tried to answer itself.")

	if(!(H in dialed_holopads))
		return

	if(connected_holopad)
		CRASH("Multi-connection holocall")

	for(var/I in dialed_holopads)
		if(I == H)
			continue
		Disconnect(I)
	
	for(var/I in H.holo_calls)
		var/datum/holocall/HC = I
		if(HC != src)
			HC.Disconnect(H)

	connected_holopad = H

	if(!Check())
		return

	hologram = H.activate_holo(user)
	hologram.HC = src

	//eyeobj code is horrid, this is the best copypasta I could make
	eye = new
	eye.origin = H
	eye.eye_initialized = TRUE
	eye.eye_user = user
	eye.name = "Camera Eye ([user.name])"
	user.remote_control = eye
	user.reset_perspective(eye)
	eye.setLoc(H.loc)

	hangup = new(eye, src)

//Checks the validity of a holocall and qdels itself if it's not. Returns TRUE if valid, FALSE otherwise
/datum/holocall/proc/Check()
	for(var/I in dialed_holopads)
		var/obj/machinery/holopad/H = I
		if(!H.is_operational())
			ConnectionFailure(H)
	
	if(QDELETED(src))
		return FALSE

	. = !QDELETED(user) && !user.incapacitated() && !QDELETED(calling_holopad) && calling_holopad.is_operational() && user.loc == calling_holopad.loc

	if(.)
		if(!connected_holopad)
			. = world.time < (call_start_time + HOLOPAD_MAX_DIAL_TIME)
			if(!.)
				calling_holopad.say("No answer recieved.")
				calling_holopad.temp = ""

	if(!.)
		testing("Holocall Check fail")
		qdel(src)

/datum/action/innate/end_holocall
	name = "End Holocall"
	button_icon_state = "camera_off"
	var/datum/holocall/hcall

/datum/action/innate/end_holocall/New(Target, datum/holocall/HC)
	..()
	hcall = HC

/datum/action/innate/end_holocall/Activate()
	hcall.Disconnect(hcall.calling_holopad)
