/// Stun everyone wearing a particular departmental headset
/obj/item/headset_overloader
	name = "headset disruptor"
	desc = "A device which broadcasts an intense and sudden burst of sound to a specified frequency."
	icon = 'icons/obj/devices/tool.dmi'
	icon_state = "implantpad-1"
	w_class = WEIGHT_CLASS_SMALL
	/// Which department are we going to antagonise?
	var/selected_department
	/// Did we use it all up?
	var/expended = FALSE

/obj/item/headset_overloader/interact(mob/user)
	. = ..()
	if (expended)
		balloon_alert(user, "charge expended!")
		return

	if (isnull(selected_department))
		var/static/list/department_channels = list(
			RADIO_CHANNEL_ENGINEERING,
			RADIO_CHANNEL_MEDICAL,
			RADIO_CHANNEL_SCIENCE,
			RADIO_CHANNEL_SECURITY,
			RADIO_CHANNEL_SERVICE,
			RADIO_CHANNEL_SUPPLY,
		)

		var/picked = tgui_input_list(user, "Choose a channel to disrupt.", "Channel Selector", department_channels)
		if (isnull(picked))
			return
		selected_department = picked
		balloon_alert(user, "selected [picked]")
		return

	if (is_within_radio_jammer_range(src))
		balloon_alert(user, "jammed!")
		return

	var/frequency = GLOB.radiochannels[selected_department]
	var/list/all_radios_of_our_frequency = GLOB.all_radios["[frequency]"]

	if (!LAZYLEN(all_radios_of_our_frequency))
		balloon_alert(user, "no devices found!")
		return

	for(var/obj/item/radio/receiver in all_radios_of_our_frequency)
		if (!receiver.can_receive(frequency, levels = SSmapping.get_connected_levels(get_turf(src))))
			continue
		playsound(receiver, 'sound/items/airhorn.ogg', vol = 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		var/mob/living/headset_wearer = receiver.loc
		receiver.Shake()
		if (!isliving(headset_wearer) || !headset_wearer.can_hear())
			continue
		to_chat(headset_wearer, span_boldbig("BWAAAAAAAAAAAHHH!!!"))
		to_chat(headset_wearer, span_warning("Your head fills with an unbearable ringing..."))
		headset_wearer.Paralyze(8 SECONDS)
		headset_wearer.set_confusion_if_lower(15 SECONDS)
		headset_wearer.apply_status_effect(/datum/status_effect/airhorn_deafness)

		var/mob/living/carbon/carbon_wearer = headset_wearer
		if (!iscarbon(carbon_wearer))
			continue
		carbon_wearer.dropItemToGround(receiver)

	playsound(src, 'sound/items/timer.ogg', 50, vary = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	icon_state = "implantpad-0"
	expended = TRUE

/obj/item/headset_overloader/examine(mob/user)
	. = ..()
	if (expended)
		. += span_warning("The screen has burnt out.")
		return
	if (!isnull(selected_department))
		. += span_notice("It has been tuned to the [selected_department] frequency.")

/// I don't want to do a whole refactor to add grouped deafness status effects and helpers in this PR sorry
/datum/status_effect/airhorn_deafness
	id = "airhorn_deafness"
	alert_type = null
	duration = 30 SECONDS

/datum/status_effect/airhorn_deafness/on_apply()
	ADD_TRAIT(owner, TRAIT_DEAF, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/airhorn_deafness/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DEAF, TRAIT_STATUS_EFFECT(id))
	return ..()
