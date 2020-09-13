SUBSYSTEM_DEF(radio)
	name = "Radio"
	flags = SS_NO_FIRE|SS_NO_INIT
	var/list/saymodes = list()
	var/list/frequencies = list()


/datum/controller/subsystem/radio/PreInit(timeofday)
	for(var/_SM in subtypesof(/datum/saymode))
		var/datum/saymode/SM = new _SM()
		saymodes[SM.key] = SM
	return ..()

// had to keep this one in.  It is used for updating the status windows mainly
/datum/controller/subsystem/radio/proc/return_frequency(freq)
	var/f_text = istext(freq) ? freq : num2text(freq)
	var/datum/radio_frequency/frequency = frequencies[f_text]
	if(!frequency)
		frequencies[f_text] = frequency = new(f_text)
	return frequency

// have to be done manualy because there are datums that just need to send a message to status displays
// or small objects.  If location is null, then its game wide to all devices on that freq, otherwise
// its bassed off the z location of the location
/datum/controller/subsystem/radio/proc/station_brodcast(freq, datum/signal/signal, atom/location=null)
	var/datum/radio_frequency/frequency = return_frequency(freq)
	for(var/datum/component/radio_interface/dest in frequency.devices)
		if(!location || location.z == 2) // 2 is a hack till I figure out how to tell if your on the station
			SEND_SIGNAL(dest.parent, COMSIG_RADIO_RECEIVE_DATA, signal)

