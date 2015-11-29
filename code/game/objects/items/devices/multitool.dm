// Multitool -- A multitool is used for hacking electronic devices.

#define DETECT_TICKER_PERIOD	10 //in deciseconds
#define DETECT_AI				1
#define DETECT_PAI				2
#define DETECT_RECORDER			4
#define DETECT_ANALYZER			8

 //////////////////////////////////////////////////////////

/obj/item/device/multitool
	name					= "multitool"
	desc					= "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state				= "multitool"
	flags					= FPRINT
	siemens_coefficient		= 1
	force					= 5.0
	w_class					= 2.0
	throwforce				= 5.0
	throw_range				= 15
	throw_speed				= 3
	starting_materials		= list(MAT_IRON = 50, MAT_GLASS = 20)
	w_type					= RECYK_ELECTRONIC
	melt_temperature		= MELTPOINT_SILICON
	origin_tech				= "magnets=1;engineering=1"
	// VG: We dun changed dis so we can link simple machines. - N3X
	var/obj/machinery/buffer // simple machine buffer for device linkage
	var/clone				= 0 // If this is on cloning will happen, this is handled in machinery code.

/obj/item/device/multitool/proc/IsBufferA(var/typepath)
	if(!buffer)
		return 0
	return istype(buffer,typepath)

/obj/item/device/multitool/attack_self(var/mob/user)
	if(!buffer && !clone) // Can't enable cloning without buffer.
		return

	clone = !clone
	if(clone)
		to_chat(user, "<span class='notice'>You enable cloning on \the [src].</span>")
	else
		to_chat(user, "<span class='notice'>You disable cloning on \the [src].</span>")

/obj/item/device/multitool/examine(var/mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Cloning is [clone ? "enabled" : "disabled"].</span>")

/////////////////////////
//Disguised AI detector// - changes color based on proximity to various surveillance devices
/////////////////////////

/obj/item/device/multitool/ai_detect
	var/detected = 0 //bitflags

/obj/item/device/multitool/ai_detect/New()
	spawn() src.ticker()

/obj/item/device/multitool/ai_detect/proc/ticker()
	var/mob/M
	var/range
	var/turf/our_turf
	var/turf/T
	while(src && !src.gcDestroyed)
		detected = 0
		our_turf = get_turf(src)
		range = range(8,our_turf)

		//Search for AIs and people looking through sec cams
		if(cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))
			var/datum/camerachunk/chunk = cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)
			if(chunk && chunk.seenby.len)
				for(M in chunk.seenby)
					if(get_dist(src,M) < 8)
						src.detected |= DETECT_AI
						break

		for(T in range) //Search for pAIs
			if(src.findItem(/mob/living/silicon/pai,T))
				src.detected |= DETECT_PAI
				break

		for(T in range) //Search for recorders
			if(src.findItem(/obj/item/device/taperecorder,T))
				src.detected |= DETECT_RECORDER
				break

		for(T in range) //Search for analyzers
			if(src.findComponent(/obj/item/device/assembly/voice,T))
				src.detected |= DETECT_ANALYZER
				break

		src.update_icon()
		sleep(DETECT_TICKER_PERIOD)
	return

/obj/item/device/multitool/ai_detect/proc/findItem(pathToFind,atom/thingToSearch)
	if(locate(pathToFind) in thingToSearch.contents) return 1
	for(var/mob/living/carbon/mob in thingToSearch)
		if(.(pathToFind,mob)) return 1
	return 0

/obj/item/device/multitool/ai_detect/proc/findComponent(pathToFind,atom/thingToSearch)
	if(locate(pathToFind) in thingToSearch.contents) return 1
	for(var/obj/item/device/assembly_holder/assembly in thingToSearch)
		if(.(pathToFind,assembly)) return 1
	for(var/obj/item/device/transfer_valve/valve in thingToSearch)
		if(.(pathToFind,valve)) return 1
	for(var/mob/living/carbon/mob in thingToSearch)
		if(.(pathToFind,mob)) return 1
	return 0

obj/item/device/multitool/ai_detect/update_icon()
	if(src.detected)
		if(src.detected & DETECT_AI)
			src.icon_state = "[initial(src.icon_state)]_red"
		else if(src.detected & DETECT_PAI)
			src.icon_state = "[initial(src.icon_state)]_orange"
		else if(src.detected & DETECT_RECORDER)
			src.icon_state = "[initial(src.icon_state)]_yellow"
		else if(src.detected & DETECT_ANALYZER)
			src.icon_state = "[initial(src.icon_state)]_blue"
	else src.icon_state = initial(src.icon_state)
	return

obj/item/device/multitool/ai_detect/examine(mob/user)
	..()
	if(src.detected)
		user << "<span class='info'>The screen displays:</span>"
		if(DETECT_AI) 		to_chat(user, "<span class='info'>AI detected</span>")
		if(DETECT_PAI)  	to_chat(user, "<span class='info'>pAI detected></span>")
		if(DETECT_RECORDER)	to_chat(user, "<span class='info'>Tape recorder detected</span>")
		if(DETECT_ANALYZER)	to_chat(user, "<span class='info'>Voice analyzer detected</span>")

////////////////////////////////////////////////////////////////////////
#undef DETECT_TICKER_PERIOD
#undef DETECT_AI
#undef DETECT_PAI
#undef DETECT_RECORDER
#undef DETECT_ANALYZER
