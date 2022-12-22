/datum/proc/status_alarm(alert_code) //Makes the status displays show the current security level for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	signal.data["command"] = "alert"
	signal.data["picture_state"] = alert_code

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)
