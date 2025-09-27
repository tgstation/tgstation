/obj/item/fake_identity_kit
	name = "fake identity kit"
	desc = "All of the paperwork you need to get a fresh start and a perfect alibi, plus a little digital assistance to insert you into crew records."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "docs_mulligan"
	w_class = WEIGHT_CLASS_TINY
	interaction_flags_click = NEED_LITERACY|NEED_LIGHT|NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING
	/// What do we set up our "new arrival" as?
	var/assigned_job = JOB_ASSISTANT

/obj/item/fake_identity_kit/examine_more(mob/user)
	. = ..()
	. += span_info("Using this kit after exposure to Mulligan serum will create a fake identity for your new appearance.")
	. += span_info("This will add you to various station manifests, create an Assistant-level ID card, and announce your arrival over the radio.")

/obj/item/fake_identity_kit/attack_self(mob/living/carbon/human/user, modifiers)
	. = ..()
	if (!ishuman(user))
		balloon_alert(user, "can't pass as employee!")
		return
	if (find_record(user.real_name))
		balloon_alert(user, "records already exist!")
		return

	user.temporarilyRemoveItemFromInventory(src)
	user.playsound_local(user, 'sound/items/cards/cardshuffle.ogg', 50, TRUE)

	var/obj/item/card/id/advanced/original_id = user.get_idcard(hand_first = FALSE)
	if (original_id)
		user.temporarilyRemoveItemFromInventory(original_id)

	var/datum/job/job = SSjob.get_job(assigned_job)
	user.mind.set_assigned_role(job)

	var/datum/outfit/job_outfit = job.outfit
	var/id_trim = job_outfit::id_trim
	var/obj/item/card/id/advanced/fake_id = new()

	if (id_trim)
		SSid_access.apply_trim_to_card(fake_id, id_trim)
		shuffle_inplace(fake_id.access)

	fake_id.registered_name = user.real_name
	if(user.age)
		fake_id.registered_age = user.age
	fake_id.update_label()
	fake_id.update_icon()

	var/placed_in = user.equip_in_one_of_slots(fake_id, list(
			LOCATION_ID,
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		), qdel_on_fail = FALSE, indirect_action = TRUE)
	if (isnull(placed_in))
		fake_id.forceMove(user.drop_location())
		to_chat(user, span_warning("You drop your new ID card on the ground."))
	else
		to_chat(user, span_notice("You quickly put your new ID card [placed_in]."))

	user.update_ID_card()

	var/mob/living/carbon/human/dummy/consistent/dummy = new() // For manifest rendering, unfortunately
	dummy.physique = user.physique
	user.dna.copy_dna(dummy.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
	user.copy_clothing_prefs(dummy)
	dummy.updateappearance(icon_update = TRUE, mutcolor_update = TRUE, mutations_overlay_update = TRUE)
	dummy.dress_up_as_job(job, visual_only = TRUE, player_client = user.client)

	GLOB.manifest.inject(user, appearance_proxy = dummy)
	QDEL_NULL(dummy)

	if (original_id)
		var/returned_to = user.equip_in_one_of_slots(original_id, list(
			LOCATION_BACKPACK,
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_HANDS,
		), qdel_on_fail = FALSE, indirect_action = TRUE)
		if (isnull(returned_to))
			fake_id.forceMove(user.drop_location())
			to_chat(user, span_warning("You drop your old ID card on the ground."))
		else
			to_chat(user, span_notice("You stash your old ID card [returned_to]."))

	var/obj/item/arrival_announcer/announcer = new(user.drop_location())
	user.put_in_hands(announcer)
	to_chat(user, span_notice("You quickly eat the leftover paperwork, leaving only the signaller used to announce your arrival on the station."))
	qdel(src)

/obj/item/arrival_announcer
	name = "arrivals announcement signaller"
	desc = "A radio signaller which uses a backdoor in the NT announcement system to trigger a fake announcement that you have just arrived there, then self-destructs."
	icon_state = "signaller"
	inhand_icon_state = "signaler"
	icon = 'icons/obj/devices/new_assemblies.dmi'
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING

/obj/item/arrival_announcer/attack_self(mob/living/user, modifiers)
	. = ..()
	if (!isliving(user))
		return

	var/name = user.real_name
	var/datum/record/manifest_data = find_record(name)
	if (isnull(manifest_data))
		balloon_alert(user, "no records found!")
		return
	var/job = manifest_data.rank
	if (tgui_alert(user, "Announce arrival of [name] as [job]?", "Are you ready?", list("Yes", "No"), timeout = 30 SECONDS) != "Yes")
		return
	if (QDELETED(src) || !user.can_perform_action(src, interaction_flags_click))
		return

	announce_arrival(user, job, announce_to_ghosts = FALSE)
	do_sparks(1, FALSE, user)
	new /obj/effect/decal/cleanable/ash(user.drop_location())
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)
