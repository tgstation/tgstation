/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/randomized = FALSE
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

	var/list/encode_info = AUGMENT_NO_REQ

/obj/item/organ/cyberimp/examine(mob/user)
	. = ..()
	if(randomized)
		. += "It seems to have been tinkered with."
	if(HAS_TRAIT(user,TRAIT_DIAGNOSTIC_HUD))
		var/display = ""
		for(var/security in encode_info[SECURITY_PROTOCOL])
			display += "[uppertext(security)], "
		. += "It's security protocols are [display] anything else is incompatible"
		display = ""
		for(var/encode in encode_info[ENCODE_PROTOCOL])
			display += "[uppertext(encode)], "
		. += "It's encoding protocols are [display] anything else is incompatible"
		display = ""
		for(var/operating in encode_info[OPERATING_PROTOCOL])
			display += "[uppertext(operating)], "
		. += "It's operating protocols are [display] anything else is incompatible"

/obj/item/organ/cyberimp/emp_act(severity)
	. = ..()
	to_chat(owner,"<span class = 'notice'> cyberlink beeps: ERR02 [name] ELECTROMAGNETIC MALFUNCTION DETECTED</span>")

/obj/item/organ/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

/obj/item/organ/cyberimp/proc/update_implants()
	return

/obj/item/organ/cyberimp/proc/random_encode()
	randomized = TRUE
	encode_info = list(	SECURITY_PROTOCOL = list(pick(SECURITY_NT1,SECURITY_NT2,SECURITY_NTX,SECURITY_TMSP,SECURITY_TOSP)), \
						ENCODE_PROTOCOL = list(pick(ENCODE_ENC1,ENCODE_ENC2,ENCODE_TENN,ENCODE_CSEP)), \
						OPERATING_PROTOCOL = list(pick(OPERATING_NTOS,OPERATING_TGMF,OPERATING_CSOF)))

/obj/item/organ/cyberimp/proc/check_compatibility()
	var/obj/item/organ/cyberimp/cyberlink/link = owner.getorganslot(ORGAN_SLOT_LINK)

	if(encode_info == AUGMENT_NO_REQ)
		return TRUE

	for(var/info in encode_info)

		if(encode_info[info] == 0)
			continue

		var/list/encrypted_information = encode_info[info]

		. = FALSE

		for(var/protocol in encrypted_information)
			if(protocol in link.encode_info[info])
				. = TRUE

		if(!.)
			return

/obj/item/organ/cyberimp/cyberlink
	name = "cybernetic brain link"
	desc = "Allows for smart communication between implants."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	slot = ORGAN_SLOT_LINK
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/cyberlink/Insert(mob/living/carbon/M, special, drop_if_replaced)
	for(var/X in M.internal_organs)
		var/obj/item/organ/O = X
		if(!istype(O,/obj/item/organ/cyberimp))
			continue
		var/obj/item/organ/cyberimp/cyber = O
		cyber.update_implants()
	. = ..()

/obj/item/organ/cyberimp/cyberlink/nt_low
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/cyberlink/nt_high
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/cyberimp/cyberlink/terragov
	encode_info = AUGMENT_TG_LEVEL

/obj/item/organ/cyberimp/cyberlink/syndicate
	encode_info = AUGMENT_SYNDICATE_LEVEL

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
