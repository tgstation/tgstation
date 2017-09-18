//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>The air begins to grow warm.</span>"

	weather_message = "<span class='userdanger'><i>You feel waves of heat wash over you! Find shelter!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"

	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle)
	target_z = ZLEVEL_STATION_PRIMARY

	immunity_type = "rad"

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm("alert")


/datum/weather/rad_storm/weather_act(mob/living/L)
	var/resist = L.getarmor(null, "rad")
	if(prob(40))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.dna && H.dna.species)
				if(!(RADIMMUNE in H.dna.species.species_traits))
					if(prob(max(0,100-resist)))
						H.randmuti()
						if(prob(50))
							if(prob(90))
								H.randmutb()
							else
								H.randmutg()
							H.domutcheck()
		L.rad_act(20,1)

/datum/weather/rad_storm/end()
	if(..())
		return
	priority_announce("The radiation threat has passed. Please return to your workplaces.", "Anomaly Alert")
	status_alarm()

/datum/weather/rad_storm/proc/status_alarm(command)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	var/atom/movable/virtualspeaker/virt = new /atom/movable/virtualspeaker(null)
	status_signal.source = virt
	status_signal.transmission_method = 1
	status_signal.data["command"] = "shuttle"

	if(command == "alert")
		status_signal.data["command"] = "alert"
		status_signal.data["picture_state"] = "radiation"

	frequency.post_signal(src, status_signal)
