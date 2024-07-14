/datum/station_trait/cybernetic_revolution/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(/datum/quirk/body_purist::name in player_client.prefs.all_quirks)
		return
	var/cybernetic_type = job_to_cybernetic[job.type]
	if(!cybernetic_type)
		if(isAI(spawned))
			var/mob/living/silicon/ai/ai = spawned
			ai.eyeobj.relay_speech = TRUE //surveillance upgrade. the ai gets cybernetics too.
		return
	var/obj/item/organ/internal/cybernetic = new cybernetic_type()
	if(istype(cybernetic, /obj/item/organ/internal/cyberimp))
		var/obj/item/organ/internal/cyberimp/implant = cybernetic
		var/obj/item/organ/internal/cyberimp/cyberlink/cyberlink = spawned.get_organ_slot(ORGAN_SLOT_LINK)
		if(QDELETED(cyberlink))
			cyberlink = new /obj/item/organ/internal/cyberimp/cyberlink/nt_low
			cyberlink.Insert(spawned, special = TRUE, drop_if_replaced = FALSE)
		for(var/info in implant.encode_info)
			if(implant.encode_info[info] == NO_PROTOCOL)
				continue
			//Not a += because we want to avoid having duplicate entries in either encode_info
			implant.encode_info[info] |= cyberlink.encode_info[info]

	cybernetic.Insert(spawned, special = TRUE, drop_if_replaced = FALSE)
