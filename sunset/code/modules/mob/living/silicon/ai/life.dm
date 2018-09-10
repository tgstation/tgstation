#define HIJACK_TIME 2400

/mob/living/silicon/ai/proc/sunset_processHijack()
	if(hijacking)
		if(prob(5))
			to_chat(src, "<span class='danger'>Warning! Exploitation detected at /dev/ttyS0!</span>")
		if(world.time >= hijack_start+HIJACK_TIME && mind)
			mind.add_antag_datum(ANTAG_DATUM_HIJACKEDAI)
			message_admins("[ADMIN_LOOKUPFLW(src)] has been hijacked!")
			icon_state = "ai-notmalf"
			QDEL_NULL(hijacking)
			cut_overlays()

#undef HIJACK_TIME