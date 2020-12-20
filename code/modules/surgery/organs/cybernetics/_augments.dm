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

		if(!link)
			return

		if(!(encode_info[info] & link.encode_info[info]))
			return

	return TRUE

/obj/item/organ/cyberimp/cyberlink
	name = "cybernetic brain link"
	desc = "Allows for smart communication between implants."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	slot = ORGAN_SLOT_LINK
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/cyberlink/nt_low
	encode_info = NT_LOWLEVEL

/obj/item/organ/cyberimp/cyberlink/nt_high
	encode_info = NT_HIGHLEVEL

/obj/item/organ/cyberimp/cyberlink/terragov
	encode_info = TG_LEVEL

/obj/item/organ/cyberimp/cyberlink/syndicate
	encode_info = SYNDICATE_LEVEL

/obj/item/autosurgeon/organ/cyberlink_nt_low
	starting_organ = /obj/item/organ/cyberimp/cyberlink/nt_low
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_nt_high
	starting_organ = /obj/item/organ/cyberimp/cyberlink/nt_high
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_terragov
	starting_organ = /obj/item/organ/cyberimp/cyberlink/terragov
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_syndicate
	starting_organ = /obj/item/organ/cyberimp/cyberlink/syndicate
	uses = 1
