SUBSYSTEM_DEF(radio)
	name = "Radio"
	flags = SS_NO_FIRE|SS_NO_INIT

	var/list/datum/radio_frequency/frequencies = list()
	var/list/saymodes = list()

/datum/controller/subsystem/radio/PreInit()
	for(var/_SM in subtypesof(/datum/saymode))
		var/datum/saymode/SM = new _SM()
		saymodes[SM.key] = SM
	return ..()

/// Gets the say mode associated with the given key, if available to the given user.
/datum/controller/subsystem/radio/proc/get_available_say_mode(mob/living/user, key)
	var/datum/saymode/selected_saymode = SSradio.saymodes[key]
	if(isnull(selected_saymode))
		return
	if(!selected_saymode.can_be_used_by(user))
		return
	return selected_saymode

/datum/controller/subsystem/radio/proc/add_object(obj/device, new_frequency as num, filter = null as text|null)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]
	if(!frequency)
		frequencies[f_text] = frequency = new(new_frequency)
	frequency.add_listener(device, filter)
	return frequency

/datum/controller/subsystem/radio/proc/remove_object(obj/device, old_frequency)
	var/f_text = num2text(old_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]
	if(frequency)
		frequency.remove_listener(device)
		// let's don't delete frequencies in case a non-listener keeps a reference
	return 1

/datum/controller/subsystem/radio/proc/return_frequency(new_frequency as num)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]
	if(!frequency)
		frequencies[f_text] = frequency = new(new_frequency)
	return frequency
