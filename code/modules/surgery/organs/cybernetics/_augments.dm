/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

	var/list/encode_info = list(SECURITY_PROTOCOL = 0, ENCODE_PROTOCOL = 0, COMPATIBILITY_PROTOCOL = 0, OPERATING_PROTOCOL = 0)


/obj/item/organ/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()


/obj/item/organ/cyberimp/proc/check_compatibility()
	. = FALSE
	var/obj/item/organ/cyberimp/cyberlink/link = owner.getorganslot(ORGAN_SLOT_LINK)

	for(var/info in encode_info)

		if(encode_info[info] == 0)
			continue
		///we check this here because it is easier than to have 2 loops
		if(!link)
			return

		if(encode_info[info] != link.encode_info[info] && encode_info[info] != link.encode_info[COMPATIBILITY_PROTOCOL] && encode_info[COMPATIBILITY_PROTOCOL] != link.encode_info[info])
			return

	return TRUE
