/mob/camera/ai_eye/remote/holo/setLoc(turf/destination, force_update = FALSE)
	// If we're moving outside the space of our projector, then just... don't
	var/obj/machinery/holopad/H = origin
	if(!H?.move_hologram(eye_user, destination))
		sprint = initial(sprint) // Reset sprint so it doesn't balloon in our calling proc
		return
	return ..()

/obj/machinery/holopad/remove_eye_control(mob/living/user)
	if(user.client)
		user.reset_perspective(null)
	user.remote_control = null

//this datum manages it's own references

/datum/holocall
	///the one that called
	var/mob/living/user
	///the holopad that sent the call to another holopad
	var/obj/machinery/holopad/calling_holopad
	///the one that answered the call (may be null)
	var/obj/machinery/holopad/connected_holopad
	///populated with all holopads that are either being dialed or have that have answered us, will be cleared out to just connected_holopad once answered
	var/list/dialed_holopads

	///user's eye, once connected
	var/mob/camera/ai_eye/remote/holo/eye
	///user's hologram, once connected
	var/obj/effect/overlay/holo_pad_hologram/hologram
	///hangup action
	var/datum/action/innate/end_holocall/hangup

	var/call_start_time
	///calls from a head of staff autoconnect, if the receiving pad is not secure.
	var/head_call = FALSE

//creates a holocall made by `caller` from `calling_pad` to `callees`
/datum/holocall/New(mob/living/caller, obj/machinery/holopad/calling_pad, list/callees, elevated_access = FALSE)
	call_start_time = world.time
	user = caller
	calling_pad.outgoing_call = src
	calling_holopad = calling_pad
	head_call = elevated_access
	dialed_holopads = list()

	for(var/obj/machinery/holopad/connected_holopad as anything in callees)
		if(!QDELETED(connected_holopad) && connected_holopad.is_operational)
			dialed_holopads += connected_holopad
			if(head_call)
				if(connected_holopad.secure)
					calling_pad.say("Auto-connection refused, falling back to call mode.")
					connected_holopad.say("Incoming call.")
				else
					connected_holopad.say("Incoming connection.")
			else
				connected_holopad.say("Incoming call.")
			connected_holopad.set_holocall(src)

	if(!dialed_holopads.len)
		calling_pad.say("Connection failure.")
		qdel(src)
		return

	testing("Holocall started")

//cleans up ALL references :)
/datum/holocall/Destroy()
	QDEL_NULL(hangup)
	QDEL_NULL(eye)

	if(connected_holopad && !QDELETED(hologram))
		hologram = null
		connected_holopad.clear_holo(user)

	user = null

	//Hologram survived holopad destro
	if(!QDELETED(hologram))
		hologram.HC = null
		QDEL_NULL(hologram)
	hologram = null

	for(var/obj/machinery/holopad/dialed_holopad as anything in dialed_holopads)
		dialed_holopad.set_holocall(src, FALSE)

	dialed_holopads.Cut()

	if(calling_holopad)//if the call is answered, then calling_holopad wont be in dialed_holopads and thus wont have set_holocall(src, FALSE) called
		calling_holopad.callee_hung_up()
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
		var/area/A = get_area(connected_holopad)
		calling_holopad.say("[A] holopad disconnected.")
	else if(H == calling_holopad && connected_holopad)
		connected_holopad.say("[user] disconnected.")

	ConnectionFailure(H, TRUE)

//Forcefully disconnects disconnected_holopad from a call. Pads not in the call are ignored.
/datum/holocall/proc/ConnectionFailure(obj/machinery/holopad/disconnected_holopad, graceful = FALSE)
	testing("Holocall connection failure: graceful [graceful]")
	if(disconnected_holopad == connected_holopad || disconnected_holopad == calling_holopad)
		if(!graceful && disconnected_holopad != calling_holopad)
			calling_holopad.say("Connection failure.")
		qdel(src)
		return

	disconnected_holopad.set_holocall(src, FALSE)

	dialed_holopads -= disconnected_holopad
	if(!dialed_holopads.len)
		if(graceful)
			calling_holopad.say("Call rejected.")
		testing("No recipients, terminating")
		qdel(src)

///Answers a call made to answering_holopad which cannot be the calling holopad. Pads not in the call are ignored
/datum/holocall/proc/Answer(obj/machinery/holopad/answering_holopad)
	testing("Holocall answer")
	if(answering_holopad == calling_holopad)
		CRASH("How cute, a holopad tried to answer itself.")

	if(!(answering_holopad in dialed_holopads))
		return

	if(connected_holopad)
		CRASH("Multi-connection holocall")

	for(var/obj/machinery/holopad/other_dialed_holopad as anything in dialed_holopads)
		if(other_dialed_holopad == answering_holopad)
			continue
		Disconnect(other_dialed_holopad)

	for(var/datum/holocall/previously_answered_holocall as anything in answering_holopad.holo_calls)//disconnect the other holocalls answering_holopad is occupied with
		if(previously_answered_holocall != src)
			previously_answered_holocall.Disconnect(answering_holopad)

	connected_holopad = answering_holopad

	if(!Check())
		return

	calling_holopad.callee_picked_up()
	hologram = answering_holopad.activate_holo(user)
	hologram.HC = src

	//eyeobj code is horrid, this is the best copypasta I could make
	eye = new
	eye.origin = answering_holopad
	eye.eye_initialized = TRUE
	eye.eye_user = user
	eye.name = "Camera Eye ([user.name])"
	user.remote_control = eye
	user.reset_perspective(eye)
	eye.setLoc(answering_holopad.loc)

	hangup = new(eye, src)
	hangup.Grant(user)
	playsound(answering_holopad, 'sound/machines/ping.ogg', 100)
	answering_holopad.say("Connection established.")

//Checks the validity of a holocall and qdels itself if it's not. Returns TRUE if valid, FALSE otherwise
/datum/holocall/proc/Check()
	for(var/obj/machinery/holopad/dialed_holopad as anything in dialed_holopads)
		if(!dialed_holopad.is_operational)
			ConnectionFailure(dialed_holopad)

	if(QDELETED(src))
		return FALSE

	. = !QDELETED(user) && !user.incapacitated() && !QDELETED(calling_holopad) && calling_holopad.is_operational && user.loc == calling_holopad.loc

	if(.)
		if(!connected_holopad)
			. = world.time < (call_start_time + HOLOPAD_MAX_DIAL_TIME)
			if(!.)
				calling_holopad.say("No answer received.")

	if(!.)
		testing("Holocall Check fail")
		qdel(src)

/datum/action/innate/end_holocall
	name = "End Holocall"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "camera_off"
	var/datum/holocall/hcall

/datum/action/innate/end_holocall/New(Target, datum/holocall/HC)
	..()
	hcall = HC

/datum/action/innate/end_holocall/Activate()
	hcall.Disconnect(hcall.calling_holopad)


//RECORDS
/datum/holorecord
	var/caller_name = "Unknown" //Caller name
	var/image/caller_image
	var/list/entries = list()
	var/language = /datum/language/common //Initial language, can be changed by HOLORECORD_LANGUAGE entries

/datum/holorecord/proc/set_caller_image(mob/user)
	var/olddir = user.dir
	user.setDir(SOUTH)
	caller_image = image(user)
	user.setDir(olddir)

/obj/item/disk/holodisk
	name = "holorecord disk"
	desc = "Stores recorder holocalls."
	icon_state = "holodisk"
	obj_flags = UNIQUE_RENAME
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	var/datum/holorecord/record
	//Preset variables
	var/preset_image_type
	var/preset_record_text

/obj/item/disk/holodisk/Initialize(mapload)
	. = ..()
	if(preset_record_text)
		INVOKE_ASYNC(src, PROC_REF(build_record))

/obj/item/disk/holodisk/Destroy()
	QDEL_NULL(record)
	return ..()

/obj/item/disk/holodisk/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/holodisk))
		var/obj/item/disk/holodisk/holodiskOriginal = W
		if (holodiskOriginal.record)
			if (!record)
				record = new
			record.caller_name = holodiskOriginal.record.caller_name
			record.caller_image = holodiskOriginal.record.caller_image
			record.entries = holodiskOriginal.record.entries.Copy()
			record.language = holodiskOriginal.record.language
			to_chat(user, span_notice("You copy the record from [holodiskOriginal] to [src] by connecting the ports!"))
			name = holodiskOriginal.name
		else
			to_chat(user, span_warning("[holodiskOriginal] has no record on it!"))
	..()

/obj/item/disk/holodisk/proc/build_record()
	record = new
	var/list/lines = splittext(preset_record_text,"\n")
	for(var/line in lines)
		var/prepared_line = trim(line)
		if(!length(prepared_line))
			continue
		var/splitpoint = findtext(prepared_line," ")
		if(!splitpoint)
			continue
		var/command = copytext(prepared_line, 1, splitpoint)
		var/value = copytext(prepared_line, splitpoint + length(prepared_line[splitpoint]))
		switch(command)
			if("DELAY")
				var/delay_value = text2num(value)
				if(!delay_value)
					continue
				record.entries += list(list(HOLORECORD_DELAY,delay_value))
			if("NAME")
				if(!record.caller_name)
					record.caller_name = value
				else
					record.entries += list(list(HOLORECORD_RENAME,value))
			if("SAY")
				record.entries += list(list(HOLORECORD_SAY,value))
			if("SOUND")
				record.entries += list(list(HOLORECORD_SOUND,value))
			if("LANGUAGE")
				var/lang_type = text2path(value)
				if(ispath(lang_type,/datum/language))
					record.entries += list(list(HOLORECORD_LANGUAGE,lang_type))
			if("PRESET")
				var/preset_type = text2path(value)
				if(ispath(preset_type,/datum/preset_holoimage))
					record.entries += list(list(HOLORECORD_PRESET,preset_type))
	if(!preset_image_type)
		record.caller_image = image('icons/mob/simple/animal.dmi',"old")
	else
		var/datum/preset_holoimage/H = new preset_image_type
		record.caller_image = H.build_image()

//These build caller image from outfit and some additional data, for use by mappers for ruin holorecords
/datum/preset_holoimage
	var/nonhuman_mobtype //Fill this if you just want something nonhuman
	var/outfit_type
	var/species_type = /datum/species/human

/datum/preset_holoimage/proc/build_image()
	if(nonhuman_mobtype)
		var/mob/living/L = nonhuman_mobtype
		. = image(initial(L.icon),initial(L.icon_state))
	else
		var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy("HOLODISK_PRESET")
		if(species_type)
			mannequin.set_species(species_type)
		if(outfit_type)
			mannequin.equipOutfit(outfit_type,TRUE)
		mannequin.setDir(SOUTH)
		. = image(mannequin)
		unset_busy_human_dummy("HOLODISK_PRESET")

/datum/preset_holoimage/clown
	outfit_type = /datum/outfit/job/clown

/datum/preset_holoimage/engineer
	outfit_type = /datum/outfit/job/engineer

/datum/preset_holoimage/corgi
	nonhuman_mobtype = /mob/living/basic/pet/dog/corgi

/datum/preset_holoimage/engineer/mod
	outfit_type = /datum/outfit/job/engineer/mod

/datum/preset_holoimage/engineer/ce
	outfit_type = /datum/outfit/job/ce

/datum/preset_holoimage/engineer/ce/mod
	outfit_type = /datum/outfit/job/ce/mod

/datum/preset_holoimage/engineer/atmos
	outfit_type = /datum/outfit/job/atmos

/datum/preset_holoimage/engineer/atmos/mod
	outfit_type = /datum/outfit/job/atmos/mod

/datum/preset_holoimage/researcher
	outfit_type = /datum/outfit/job/scientist

/datum/preset_holoimage/captain
	outfit_type = /datum/outfit/job/captain

/datum/preset_holoimage/nanotrasenprivatesecurity
	outfit_type = /datum/outfit/nanotrasensoldiercorpse

/datum/preset_holoimage/syndicatebattlecruisercaptain
	outfit_type = /datum/outfit/syndicate_empty/battlecruiser

/datum/preset_holoimage/hivebot
	nonhuman_mobtype = /mob/living/simple_animal/hostile/hivebot

/datum/preset_holoimage/ai
	nonhuman_mobtype = /mob/living/silicon/ai

/datum/preset_holoimage/robot
	nonhuman_mobtype = /mob/living/silicon/robot

/datum/preset_holoimage/assistant
	outfit_type = /datum/outfit/job/assistant

/obj/item/disk/holodisk/example
	preset_image_type = /datum/preset_holoimage/clown
	preset_record_text = {"
	NAME Clown
	DELAY 10
	SAY Why did the chaplain cross the maint ?
	DELAY 20
	SAY He wanted to get to the other side!
	SOUND clownstep
	DELAY 30
	LANGUAGE /datum/language/narsie
	SAY Helped him get there!
	DELAY 10
	SAY ALSO IM SECRETLY A GORILLA
	DELAY 10
	PRESET /datum/preset_holoimage/gorilla
	NAME Gorilla
	LANGUAGE /datum/language/common
	SAY OOGA
	DELAY 20"}

/obj/item/disk/holodisk/donutstation/whiteship
	name = "Blackbox Print-out #DS024"
	desc = "A holodisk containing the last viable recording of DS024's blackbox."
	preset_image_type = /datum/preset_holoimage/engineer/ce
	preset_record_text = {"
	NAME Geysr Shorthalt
	SAY Engine renovations complete and the ships been loaded. We all ready?
	DELAY 25
	PRESET /datum/preset_holoimage/engineer
	NAME Jacob Ullman
	SAY Lets blow this popsicle stand of a station.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/atmos
	NAME Lindsey Cuffler
	SAY Uh, sir? Shouldn't we call for a secondary shuttle? The bluespace drive on this thing made an awfully weird noise when we jumped here..
	DELAY 30
	PRESET /datum/preset_holoimage/engineer/ce
	NAME Geysr Shorthalt
	SAY Pah! Ship techie at the dock said to give it a good few kicks if it started acting up, let me just..
	DELAY 25
	SOUND punch
	SOUND sparks
	DELAY 10
	SOUND punch
	SOUND sparks
	DELAY 10
	SOUND punch
	SOUND sparks
	SOUND warpspeed
	DELAY 15
	PRESET /datum/preset_holoimage/engineer/atmos
	NAME Lindsey Cuffler
	SAY Uhh.. is it supposed to be doing that??
	DELAY 15
	PRESET /datum/preset_holoimage/engineer/ce
	NAME Geysr Shorthalt
	SAY See? Working as intended. Now, are we all ready?
	DELAY 10
	PRESET /datum/preset_holoimage/engineer
	NAME Jacob Ullman
	SAY Is it supposed to be glowing like that?
	DELAY 20
	SOUND explosion

	"}

/obj/item/disk/holodisk/ruin/snowengieruin
	name = "Blackbox Print-out #EB412"
	desc = "A holodisk containing the last moments of EB412. There's a bloody fingerprint on it."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	NAME Dave Tundrale
	SAY Maria, how's Build?
	DELAY 10
	NAME Maria Dell
	PRESET /datum/preset_holoimage/engineer/atmos
	SAY It's fine, don't worry. I've got Plastic on it. And frankly, i'm kinda busy with, the, uhhm, incinerator.
	DELAY 30
	NAME Dave Tundrale
	PRESET /datum/preset_holoimage/engineer
	SAY Aight, wonderful. The science mans been kinda shit though. No RCDs-
	DELAY 20
	NAME Maria Dell
	PRESET /datum/preset_holoimage/engineer/atmos
	SAY Enough about your RCDs. They're not even that important, just bui-
	DELAY 15
	SOUND explosion
	DELAY 10
	SAY Oh, shit!
	DELAY 10
	PRESET /datum/preset_holoimage/engineer/atmos/mod
	LANGUAGE /datum/language/narsie
	NAME Unknown
	SAY RISE, MY LORD!!
	DELAY 10
	LANGUAGE /datum/language/common
	NAME Plastic
	PRESET /datum/preset_holoimage/engineer/mod
	SAY Fuck, fuck, fuck!
	DELAY 20
	NAME Maria Dell
	PRESET /datum/preset_holoimage/engineer/atmos
	SAY GEORGE, WAIT-
	DELAY 10
	PRESET /datum/preset_holoimage/corgi
	NAME Blackbox Automated Message
	SAY Connection lost. Dumping audio logs to disk.
	DELAY 50"}

/obj/item/disk/holodisk/ruin/ghost_restaurant
	name = "Blackbox Print-out #NG234"
	preset_image_type = /datum/preset_holoimage/assistant
	preset_record_text = {"
	NAME Aron Blue
	SAY Message from NTGrub Themed Surprise Deliveries, Trademark.
	DELAY 20
	NAME Henry Fresh
	SAY Must you always say the full name, dude?
	DELAY 20
	NAME Aron Blue
	SAY Ahem!
	DELAY 20
	NAME Aron Blue
	SAY It says that they loved our new robot themes!
	DELAY 20
	NAME Henry Fresh
	SAY Oh dang!
	DELAY 20
	NAME Henry Fresh
	SAY Will we be moved to the main team?
	DELAY 20
	NAME Aron Blue
	SAY Hell yeah we will! High five!
	DELAY 20
	SOUND punch
	NAME Henry Fresh
	SAY High five!
	DELAY 20
	NAME Henry Fresh
	SAY Oh, new order. Its for, hah, *Funny Food*.
	DELAY 20
	NAME Aron Blue
	SAY Easy!
	DELAY 20
	NAME Aron Blue
	SAY I will dress up this robot as a clown.
	DELAY 20
	NAME Henry Fresh
	SAY Well, if you are that basic, lets make it ask for a Banana Pie.
	DELAY 20
	NAME Aron Blue
	SAY Gateway to Planetside Pagliacci 15 is open.
	DELAY 20
	NAME Aron Blue
	SAY Feels appropriate.
	DELAY 15
	SOUND clown_step
	DELAY 10
	SOUND sparks
	DELAY 10
	NAME Aron Blue
	SAY Next order is for a simple farm dish.
	DELAY 20
	NAME Henry Fresh
	SAY Unlike you, I am creative.
	DELAY 20
	NAME Henry Fresh
	SAY I'll dress it up as a scarecrow.
	SOUND rustle
	DELAY 20
	NAME Aron Blue
	SAY Let's ask for uuuh, Hot Potato.
	DELAY 20
	NAME Henry Fresh
	SAY Send it to the new place. Firebase Balthazord.
	DELAY 20
	NAME Henry Fresh
	SAY Wait.
	DELAY 10
	NAME Henry Fresh
	SAY You know its called Baked Potato, right?
	DELAY 10
	SOUND sparks
	DELAY 20
	NAME Aron Blue
	SAY Shut up, they'll know what I meant!
	DELAY 20
	SOUND sparks
	DELAY 10
	NAME Henry Fresh
	SAY Its back.
	DELAY 20
	NAME Henry Fresh
	SAY Haha, it brought a raw potato.
	DELAY 20
	NAME Aron Blue
	SAY HENRY ITS TICK-
	DELAY 20
	SOUND explosion
	DELAY 20
	PRESET /datum/preset_holoimage/corgi
	NAME Blackbox Automated Message
	SAY Connection lost. Dumping audio logs to disk.
	DELAY 50
	"}

/obj/item/disk/holodisk/ruin/space/travelers_rest
	name = "Owner's memo"
	desc = "A holodisk containing a small memo from the previous owner, addressed to someone else."
	preset_image_type = /datum/preset_holoimage/engineer/atmos
	preset_record_text = {"
		NAME Space Adventurer
		SOUND PING
		DELAY 20
		SAY Hey, I left you this message for when you come back.
		DELAY 50
		SAY I picked up an emergency signal from a freighter and I'm going there to search for some goodies.
		DELAY 50
		SAY You can crash here if you need to, but make sure to check the anchor cables before you leave.
		DELAY 50
		SAY If you don't, this thing might drift off into space.
		DELAY 50
		SAY Then some weirdo could find it and potentially claim it as their own.
		DELAY 50
		SAY Anyway, gotta go, see ya!
		DELAY 40
		SOUND sparks
	"}
