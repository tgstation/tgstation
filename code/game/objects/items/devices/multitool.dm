// Multitool -- A multitool is used for hacking electronic devices.
 
#define DETECT_TICKER_PERIOD	10 //in deciseconds
#define DETECT_AI				1
#define DETECT_PAI				2
#define DETECT_RECORDER			4
#define DETECT_ANALYZER			8
 
 //////////////////////////////////////////////////////////
 
/obj/item/device/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	m_amt = 50
	g_amt = 20
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	origin_tech = "magnets=1;engineering=1"
	// VG: We dun changed dis so we can link simple machines. - N3X
	var/obj/machinery/buffer // simple machine buffer for device linkage
/obj/item/device/multitool/proc/IsBufferA(var/typepath)
	if(!buffer)
		return 0
	return istype(buffer,typepath)
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
	
obj/item/device/multitool/ai_detect/examine()
	..()
	if(src.detected) usr << "The screen displays:"
	if(src.detected & DETECT_AI) usr << "AI detected"
	if(src.detected & DETECT_PAI) usr << "pAI detected"
	if(src.detected & DETECT_RECORDER) usr << "Tape recorder detected"
	if(src.detected & DETECT_ANALYZER) usr << "Voice analyzer detected"
	
////////////////////////////////////////////////////////////////////////
#undef DETECT_TICKER_PERIOD
#undef DETECT_AI
#undef DETECT_PAI
#undef DETECT_RECORDER
#undef DETECT_ANALYZER
