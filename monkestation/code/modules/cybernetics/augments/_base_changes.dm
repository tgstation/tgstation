/datum/bodypart_overlay/simple/proc/unique_properties(obj/item/organ/internal/cyberimp/called_from)
	return

/obj/item/organ/internal/cyberimp
	var/hacked = FALSE
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

	var/list/encode_info = AUGMENT_NO_REQ

	///are we a visual implant
	var/visual_implant = FALSE
	/// The bodypart overlay datum we should apply to whatever mob we are put into
	var/datum/bodypart_overlay/simple/bodypart_overlay
	/// What limb we are inside of, used for tracking when and how to remove our overlays and all that
	var/obj/item/bodypart/ownerlimb
	///how many times we failed to hack this
	var/failed_count = 0

/obj/item/organ/internal/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay) // <- this is old code that is better replaced with bodypart_overlays
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

/obj/item/organ/internal/cyberimp/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/organ/internal/cyberimp/Destroy()
	if(ownerlimb && visual_implant)
		remove_from_limb()
	return ..()

/obj/item/organ/internal/cyberimp/examine(mob/user)
	. = ..()
	if(hacked)
		. += "It seems to have been tinkered with."
	if(HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
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
			. += "It's operating protocols are [display]for the implant to function it requires the operating protocols match the cyberlink's."
	else
		. += "You can see the encoding information of this implant by wearing a diagnostic hud or medical hud."

/obj/item/organ/internal/cyberimp/emp_act(severity)
	. = ..()
	if(severity == EMP_HEAVY && prob(5) && !owner)
		to_chat(owner,"<span class = 'danger'> cyberlink beeps: ERR03 HEAVY ELECTROMAGNETIC MALFUNCTION DETECTED IN [uppertext(name)].DAMAGE DETECTED, INTERNAL MEMORY DAMAGED. </span>")
		random_encode()
	else
		to_chat(owner,"<span class = 'danger'> cyberlink beeps: ERR02 ELECTROMAGNETIC MALFUNCTION DETECTED IN [uppertext(name)] </span>")

/obj/item/organ/internal/cyberimp/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	var/obj/item/bodypart/limb = receiver.get_bodypart(deprecise_zone(zone))
	. = ..()
	if(visual_implant)
		if(!.)
			return
		if(!limb)
			return FALSE

		ownerlimb = limb
		add_to_limb(ownerlimb)

/obj/item/organ/internal/cyberimp/add_to_limb(obj/item/bodypart/bodypart)
	bodypart_overlay = new bodypart_overlay()
	bodypart_overlay.unique_properties(src)
	ownerlimb = bodypart
	ownerlimb.add_bodypart_overlay(bodypart_overlay)
	owner.update_body_parts()
	return ..()

/obj/item/organ/internal/cyberimp/remove_from_limb()
	ownerlimb.remove_bodypart_overlay(bodypart_overlay)
	QDEL_NULL(bodypart_overlay)
	ownerlimb = null
	owner.update_body_parts()
	return ..()

/**
 * Updates implants
 *
 * Used when an implant is already installed and a new cyberlink is inserted, in this situation this proc fires, to update the compatibility of an implant.
 */
/obj/item/organ/internal/cyberimp/proc/update_implants()
	return

/**
 * Randomly scrambles encode_info of an implant
 *
 * Every implant contains it's own encode_info, this info stores the data on what security, encoding and operating protocols it uses.
 * Implant is compatible if for every protocol catergory it shares at least 1 protocol in common with the link.
 * If it fails to meet that criteria, than it is incompatible and this proc returns FALSE. If it is compatibile returns TRUE
 */
/obj/item/organ/internal/cyberimp/proc/random_encode()
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
/obj/item/organ/internal/cyberimp/proc/check_compatibility()
	var/obj/item/organ/internal/cyberimp/cyberlink/link = owner.get_organ_slot(ORGAN_SLOT_LINK)

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

/obj/item/organ/internal/cyberimp/cyberlink
	name = "cybernetic brain link"
	desc = "Allows for smart communication between implants."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	slot = ORGAN_SLOT_LINK
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/cyberlink_connector/connector
	var/extended = FALSE

/obj/item/organ/internal/cyberimp/cyberlink/Insert(mob/living/carbon/M, special, drop_if_replaced)
	for(var/X in M.organs)
		var/obj/item/organ/O = X
		if(!istype(O,/obj/item/organ/internal/cyberimp))
			continue
		var/obj/item/organ/internal/cyberimp/cyber = O
		cyber.update_implants()
	return ..()

/obj/item/organ/internal/cyberimp/cyberlink/nt_low
	name = "NT Cyberlink 1.0"
	encode_info = AUGMENT_NT_LOWLEVEL_LINK

/obj/item/organ/internal/cyberimp/cyberlink/nt_high
	name = "NT Cyberlink 2.0"
	encode_info = AUGMENT_NT_HIGHLEVEL_LINK

/obj/item/organ/internal/cyberimp/cyberlink/terragov
	name = "Terran Cyberware System"
	encode_info = AUGMENT_TG_LEVEL_LINK

/obj/item/organ/internal/cyberimp/cyberlink/syndicate
	name = "Cybersun Cybernetics Access System"
	encode_info = AUGMENT_SYNDICATE_LEVEL_LINK

/obj/item/organ/internal/cyberimp/cyberlink/admin
	name = "G.O.D. Cybernetics System"
	encode_info = AUGMENT_ADMIN_LEVEL_LINK

/obj/item/autosurgeon/organ/cyberlink_nt_low
	starting_organ = /obj/item/organ/internal/cyberimp/cyberlink/nt_low
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_nt_high
	starting_organ = /obj/item/organ/internal/cyberimp/cyberlink/nt_high
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_terragov
	starting_organ = /obj/item/organ/internal/cyberimp/cyberlink/terragov
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_syndicate
	starting_organ = /obj/item/organ/internal/cyberimp/cyberlink/syndicate
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_admin
	starting_organ = /obj/item/organ/internal/cyberimp/cyberlink/admin
	uses = 1
