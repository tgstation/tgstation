#define GET_ATOM_SHIFF_FINGERPRINTS(atom) atom.forensics?.fingerprints
#define GET_ATOM_SHIFF_BLOOD_DNA(atom) atom.forensics?.blood_DNA

// MARK: Vulpkanin skills
/datum/action/cooldown/sniff
	name = "Вынюхать"
	desc = "Вы обнюхиваете предмет и определяете, кто с ним взаимодействовал. Также, вы можете запомнить запах определённого человека, обнюхав его."
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	cooldown_time = 2 SECONDS
	button_icon = 'icons/bandastation/mob/species/vulpkanin/skills.dmi'
	button_icon_state = "sniff"
	overlay_icon = 'icons/bandastation/mob/species/vulpkanin/skills.dmi'
	overlay_icon_state = "frame_border"
	background_icon = 'icons/bandastation/mob/species/vulpkanin/skills.dmi'
	background_icon_state = "frame"
	click_to_activate = TRUE
	var/list/sniffed_species_ue = list()
	var/list/sniffed_species_ui = list()
	var/cast_time = 2 SECONDS

/datum/action/cooldown/sniff/Grant(mob/granted_to)
	. = ..()
	RegisterSignal(granted_to, COMSIG_CARBON_VULPKANIN_SNIFF, PROC_REF(smoke))

/datum/action/cooldown/sniff/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, COMSIG_CARBON_VULPKANIN_SNIFF, PROC_REF(smoke))

/datum/action/cooldown/sniff/proc/smoke()
	StartCooldown(300 SECONDS)

/datum/action/cooldown/sniff/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	on_who.update_icons()

/datum/action/cooldown/sniff/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	on_who.update_icons()

/datum/action/cooldown/sniff/PreActivate(atom/target)
	if(get_dist(owner, target) > 1)
		return FALSE
	if(ishuman(target))
		owner.emote("sniffle", message = target.name, intentional = TRUE)
	else
		owner.emote("sniffle")
	if(HAS_TRAIT(owner, TRAIT_ANOSMIA))
		return TRUE

	var/mob/living/carbon/human/H = owner
	if(istype(H) && (H.has_smoke_protection() || H.can_breathe_internals()))
		return TRUE

	return ..()

/obj/item/cigarette/handle_reagents(seconds_per_tick)
	..()
	var/mob/living/carbon/smoker = loc
	if(istype(smoker))
		if(src == smoker.wear_mask)
			SEND_SIGNAL(smoker, "testsig")
	else if(istype(smoker, /obj/item/clothing/mask/gas))
		smoker = smoker.loc
		if(istype(smoker) && smoker.get_item_by_slot(ITEM_SLOT_MASK) == loc)
			SEND_SIGNAL(smoker, "testsig")

/datum/action/cooldown/sniff/Activate(atom/target)
	var/list/fingerprints = GET_ATOM_SHIFF_FINGERPRINTS(target)
	var/list/blood = GET_ATOM_SHIFF_BLOOD_DNA(target)

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		sniffed_species_ue[H.dna.unique_enzymes] = H.real_name
		sniffed_species_ui[md5(H.dna.unique_identity)] = H.real_name
	if(ishuman(target))
		if(do_after(owner, cast_time, target = target))
			var/mob/living/carbon/human/H = target
			sniffed_species_ue[H.dna.unique_enzymes] = H.name
			sniffed_species_ui[md5(H.dna.unique_identity)] = H.name
			to_chat(owner, "Вы запомнили запах [H.name]")
			StartCooldown()
			return TRUE

	if(!length(fingerprints) && !length(blood))
		StartCooldown()
		return TRUE

	var/list/fingerprint_output = list()
	var/list/blood_output = list()

	for(var/mob/living/carbon/human/A as anything in GLOB.human_list)
		if(!A.dna)
			continue
		if(A.dna.unique_enzymes in blood)
			blood_output[A.dna.unique_enzymes] = list()
			blood_output[A.dna.unique_enzymes]["Gender"] = A.gender
			blood_output[A.dna.unique_enzymes]["Species"] = A.dna.species.name
			blood_output[A.dna.unique_enzymes]["Color"] = colorize_string(A.dna.unique_enzymes + A.dna.unique_identity)
		var/h = md5(A.dna.unique_identity)
		if(h in fingerprints)
			fingerprint_output[h] = list()
			fingerprint_output[h]["Gender"] = A.gender
			fingerprint_output[h]["Species"] = A.dna.species.name
			fingerprint_output[h]["Color"] = colorize_string(A.dna.unique_enzymes + A.dna.unique_identity)

	if(fingerprints)
		for(var/i in fingerprints)
			if(!sniffed_species_ui[i])
				continue
			fingerprint_output[i]["Name"] = sniffed_species_ui[i]
	if(blood)
		for(var/i in blood)
			if(!sniffed_species_ue[i])
				continue
			blood_output[i]["Name"] = sniffed_species_ue[i]

	var/list/message = list()
	if(length(fingerprint_output) > 0)
		message += "<B>Вы чувствуете запах:</B>"
		for(var/i in fingerprint_output)
			var/name = fingerprint_output[i]["Name"] ? fingerprint_output[i]["Name"] : "Неизвестный"
			message += "<font color='#[fingerprint_output[i]["Color"]]'>[name], [fingerprint_output[i]["Gender"]], [fingerprint_output[i]["Species"]]</font>"
		to_chat(owner, jointext(message, "\n&bull; "))
	message = list()
	if(length(blood_output) > 0)
		message += "<B>Вы чувствуете запах <font color='red'>крови</font>:</B>"
		for(var/i in blood_output)
			var/name = blood_output[i]["Name"] ? blood_output[i]["Name"] : "Неизвестный"
			message += "<font color='#[blood_output[i]["Color"]]'>[name], [blood_output[i]["Gender"]], [blood_output[i]["Species"]]</font>"
		to_chat(owner, jointext(message, "\n&bull; "))

	StartCooldown()
	return TRUE

#undef GET_ATOM_SHIFF_FINGERPRINTS
#undef GET_ATOM_SHIFF_BLOOD_DNA
