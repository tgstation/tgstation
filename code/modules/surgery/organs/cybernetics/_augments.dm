/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/hacked = FALSE
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

	var/list/encode_info = AUGMENT_NO_REQ

/obj/item/organ/cyberimp/examine(mob/user)
	. = ..()
	if(hacked)
		. += "It seems to have been tinkered with."
	if(HAS_TRAIT(user,TRAIT_DIAGNOSTIC_HUD))
		var/display = ""
		var/list/check_list = encode_info[SECURITY_PROTOCOL]
		if(check_list.len)
			for(var/security in check_list)
				display += "[uppertext(security)], "
			. += "It's security protocols are [display] for the implant to function it requires at least one of them to be shared with the cyberlink."
		check_list = encode_info[ENCODE_PROTOCOL]
		if(check_list.len)
			display = ""
			for(var/encode in check_list)
				display += "[uppertext(encode)], "
			. += "It's encoding protocols are [display] for the implant to function it requires at least one of them to be shared with the cyberlink."
		check_list = encode_info[OPERATING_PROTOCOL]
		if(check_list.len)
			display = ""
			for(var/operating in check_list)
				display += "[uppertext(operating)], "
			. += "It's operating protocols are [display]for the implant to function it requires at least one of them to be shared with the cyberlink."

/obj/item/organ/cyberimp/emp_act(severity)
	. = ..()
	if(severity == EMP_HEAVY && prob(5))
		to_chat(owner,"<span class = 'danger'> cyberlink beeps: ERR03 HEAVY ELECTROMAGNETIC MALFUNCTION DETECTED IN [uppertext(name)].DAMAGE DETECTED, INTERNAL MEMORY DAMAGED. </span>")
		random_encode()
	else
		to_chat(owner,"<span class = 'danger'> cyberlink beeps: ERR02 ELECTROMAGNETIC MALFUNCTION DETECTED IN [uppertext(name)] </span>")


/obj/item/organ/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

/**
 * Updates implants
 *
 * Used when an implant is already installed and a new cyberlink is inserted, in this situation this proc fires, to update the compatibility of an implant.
 */
/obj/item/organ/cyberimp/proc/update_implants()
	return

/**
 * Randomly scrambles encode_info of an implant
 *
 * Every implant contains it's own encode_info, this info stores the data on what security, encoding and operating protocols it uses.
 * Implant is compatible if for every protocol catergory it shares at least 1 protocol in common with the link.
 * If it fails to meet that criteria, than it is incompatible and this proc returns FALSE. If it is compatibile returns TRUE
 */
/obj/item/organ/cyberimp/proc/random_encode()
	hacked = TRUE
	encode_info = list(	SECURITY_PROTOCOL = list(pick(SECURITY_NT1,SECURITY_NT2,SECURITY_NTX,SECURITY_TMSP,SECURITY_TOSP)), \
						ENCODE_PROTOCOL = list(pick(ENCODE_ENC1,ENCODE_ENC2,ENCODE_TENN,ENCODE_CSEP)), \
						OPERATING_PROTOCOL = list(pick(OPERATING_NTOS,OPERATING_TGMF,OPERATING_CSOF)))
/**
 * Checks compatibility of implant against the cyberlink
 *
 * Every implant contains it's own encode_info, this info stores the data on what security, encoding and operating protocols it uses.
 * Implant is compatible if for every protocol catergory it shares at least 1 protocol in common with the link.
 * If it fails to meet that criteria, than it is incompatible and this proc returns FALSE. If it is compatibile returns TRUE
 */
/obj/item/organ/cyberimp/proc/check_compatibility()
	var/obj/item/organ/cyberimp/cyberlink/link = owner.getorganslot(ORGAN_SLOT_LINK)

	for(var/info in encode_info)
		// We check if encode_info for this protocol categoru is NO_PROTOCOL meaning it is compatible with anything.
		if(encode_info[info] == NO_PROTOCOL)
			. = TRUE
			continue

		var/list/encrypted_information = encode_info[info]

		. = FALSE

		//We check for link here because implants that contain NO_PROTOCOL for every category should work even without an implant.
		if(!link)
			return

		//We check if our protocol category shares at least 1 protocol with the cyberlink
		for(var/protocol in encrypted_information)
			if(protocol in link.encode_info[info])
				. = TRUE

		//If it doesn't return FALSE
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
	var/obj/item/cyberlink_connector/connector
	var/extended = FALSE

/obj/item/organ/cyberimp/cyberlink/Insert(mob/living/carbon/M, special, drop_if_replaced)
	for(var/X in M.internal_organs)
		var/obj/item/organ/O = X
		if(!istype(O,/obj/item/organ/cyberimp))
			continue
		var/obj/item/organ/cyberimp/cyber = O
		cyber.update_implants()
	return ..()

/obj/item/organ/cyberimp/cyberlink/nt_low
	name = "NT Cyberlink 1.0"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/cyberlink/nt_high
	name = "NT Cyberlink 2.0"
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/cyberimp/cyberlink/terragov
	name = "Terran Cyberware System"
	encode_info = AUGMENT_TG_LEVEL

/obj/item/organ/cyberimp/cyberlink/syndicate
	name = "Cybersun Cybernetics Access System"
	encode_info = AUGMENT_SYNDICATE_LEVEL

/obj/item/organ/cyberimp/cyberlink/admin
	name = "G.O.D. Cybernetics System"
	encode_info = AUGMENT_ADMIN_LEVEL

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

/obj/item/autosurgeon/organ/cyberlink_admin
	starting_organ = /obj/item/organ/cyberimp/cyberlink/admin
	uses = 1

