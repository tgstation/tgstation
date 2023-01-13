#define TRAIT_SECURITY_HEADSET "security_headset"

/datum/component/security_headset
	VAR_PRIVATE
		power_bars_for_all_access = 2

		datum/weakref/last_known_radio_ref

		list/channels_to_give = list(
			RADIO_CHANNEL_COMMAND,
			RADIO_CHANNEL_ENGINEERING,
			RADIO_CHANNEL_MEDICAL,
			RADIO_CHANNEL_SCIENCE,
			RADIO_CHANNEL_SERVICE,
			RADIO_CHANNEL_SUPPLY,
		)

		list/filtered_channels = list()

/datum/component/security_headset/Initialize(...)
	. = ..()

	if (!istype(parent, /obj/item/encryptionkey))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/encryptionkey/key_parent = parent
	filtered_channels = assoc_to_keys(key_parent.channels)
	channels_to_give -= filtered_channels

	addtimer(CALLBACK(src, PROC_REF(deferred_init)), 0)

/datum/component/security_headset/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	ADD_TRAIT(parent, TRAIT_SECURITY_HEADSET, REF(src))

/datum/component/security_headset/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	REMOVE_TRAIT(parent, TRAIT_SECURITY_HEADSET, REF(src))

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

	var/last_known_radio = last_known_radio_ref?.resolve()
	if (!isnull(last_known_radio))
		UnregisterSignal(last_known_radio, COMSIG_RADIO_NEW_MESSAGE)
		last_known_radio_ref = null

	if (istype(atom_parent.loc, /obj/item/radio))
		last_known_radio_ref = WEAKREF(atom_parent.loc)
		RegisterSignal(atom_parent.loc, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(on_radio_message))

/datum/component/security_headset/proc/on_power_update(new_power_bars)
	var/atom/atom_parent = parent
	var/has_all_access = new_power_bars >= power_bars_for_all_access

	var/mob/living/carbon/holder = get(parent, /mob/living/carbon)
	if (!isnull(holder))
		atom_parent.balloon_alert(holder, has_all_access ? "security power upgraded" : "security power downgraded")
		addtimer(CALLBACK(parent, TYPE_PROC_REF(/atom, balloon_alert), holder, has_all_access ? "you can now listen to all departments" : "you can no longer listen to all departments"), 1 SECONDS)

	if (has_all_access)
		give_all_access()
	else
		drop_all_access()

	if (istype(atom_parent.loc, /obj/item/radio))
		var/obj/item/radio/radio = atom_parent.loc
		radio.recalculateChannels()

	return isnull(holder) ? NONE : POWER_BAR_DONT_REACT

/datum/component/security_headset/proc/give_all_access()
	var/obj/item/encryptionkey/encryption_key = parent

	for (var/channel in channels_to_give)
		encryption_key.channels[channel] = TRUE

/datum/component/security_headset/proc/drop_all_access()
	var/obj/item/encryptionkey/encryption_key = parent

	for (var/channel in channels_to_give)
		encryption_key.channels -= channel

/datum/component/security_headset/proc/on_radio_message(obj/item/radio/source, atom/movable/talking, message, channel)
	if (channel in filtered_channels)
		return NONE

	for (var/obj/item/encryptionkey/encryption_key in source)
		if (HAS_TRAIT(encryption_key, TRAIT_SECURITY_HEADSET))
			continue

		if (channel in encryption_key.channels)
			return NONE

	return COMPONENT_CANNOT_USE_RADIO
