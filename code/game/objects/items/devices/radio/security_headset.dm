/datum/component/security_headset
	VAR_PRIVATE
		has_all_access = FALSE

		power_bars_for_all_access = 2

		datum/weakref/last_known_radio_ref

		list/channels_to_give = list(
			RADIO_CHANNEL_COMMAND = FREQ_LISTENING,
			RADIO_CHANNEL_ENGINEERING = FREQ_LISTENING,
			RADIO_CHANNEL_MEDICAL = FREQ_LISTENING,
			RADIO_CHANNEL_SCIENCE = FREQ_LISTENING,
			RADIO_CHANNEL_SERVICE = FREQ_LISTENING,
			RADIO_CHANNEL_SUPPLY = FREQ_LISTENING,
		)

/datum/component/security_headset/Initialize(...)
	if (!istype(parent, /obj/item/encryptionkey))
		return COMPONENT_INCOMPATIBLE

	addtimer(CALLBACK(src, PROC_REF(deferred_init)), 0)

/datum/component/security_headset/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/component/security_headset/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/security_headset/proc/on_move()
	SIGNAL_HANDLER
	recalculate_radio()

/datum/component/security_headset/proc/deferred_init()
	var/obj/item/encryptionkey/key_parent = parent
	key_parent.AddComponent(/datum/component/power_bar_reactor, CALLBACK(src, PROC_REF(on_power_update)), POWER_BAR_DEPARTMENT_SECURITY)
	recalculate_radio()

/datum/component/security_headset/proc/recalculate_radio()
	var/atom/atom_parent = parent

	if (IS_WEAKREF_OF(last_known_radio_ref, atom_parent.loc))
		return

	var/obj/item/radio/last_known_radio = last_known_radio_ref?.resolve()
	if (!isnull(last_known_radio))
		UnregisterSignal(last_known_radio, list(COMSIG_RADIO_NEW_MESSAGE, COMSIG_RADIO_CHANNELS_RECALCULATED))
		last_known_radio.recalculateChannels()
		last_known_radio_ref = null

	if (istype(atom_parent.loc, /obj/item/radio))
		last_known_radio_ref = WEAKREF(atom_parent.loc)
		RegisterSignal(atom_parent.loc, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(on_radio_message))
		RegisterSignal(atom_parent.loc, COMSIG_RADIO_CHANNELS_RECALCULATED, PROC_REF(radio_channels_recalculated))
		var/obj/item/radio/new_last_known_radio = atom_parent.loc
		new_last_known_radio.recalculateChannels()

/datum/component/security_headset/proc/on_power_update(new_power_bars)
	has_all_access = new_power_bars >= power_bars_for_all_access

	var/atom/atom_parent = parent
	var/obj/item/radio/radio = last_known_radio_ref?.resolve()
	var/mob/living/carbon/holder = get(parent, /mob/living/carbon)
	radio?.recalculateChannels()
	if (!isnull(holder))
		atom_parent.balloon_alert(holder, has_all_access ? "security power upgraded" : "security power downgraded")
		addtimer(CALLBACK(parent, TYPE_PROC_REF(/atom, balloon_alert), holder, has_all_access ? "you can now listen to all departments" : "you can no longer listen to all departments"), 1 SECONDS)

	return POWER_BAR_DONT_REACT

/datum/component/security_headset/proc/radio_channels_recalculated(obj/item/radio/source, list/channel_list, list/special_channel_list)
	SIGNAL_HANDLER

	if (!has_all_access)
		return

	channel_list |= channels_to_give

/datum/component/security_headset/proc/on_radio_message(obj/item/radio/source, atom/movable/talking, message, channel)
	SIGNAL_HANDLER

	// Check if the channel is natively unlocked, if so do nothing
	for (var/obj/item/encryptionkey/key as anything in source.get_keys())
		if (channel in key.channels)
			return NONE


	// Channels unlocked are listen only. If none of your keys unlock the channel, you can't talk on it.
	if(!(channel in channels_to_give))
		return NONE
	if(isliving(talking))
		source.balloon_alert(talking, "channel is listen only!")
	return COMPONENT_CANNOT_USE_RADIO
