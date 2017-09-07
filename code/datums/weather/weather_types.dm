//Different types of weather.

/datum/weather/floor_is_lava //The Floor is Lava: Makes all turfs damage anyone on them unless they're standing on a solid object.
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = "<span class='warning'>Waves of heat emanate from the ground...</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>The floor is lava! Get on top of something!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 600
	weather_overlay = "lava"

	end_message = "<span class='danger'>The ground cools and returns to its usual form.</span>"
	end_duration = 0

	area_type = /area
	protected_areas = list(/area/space)
	target_z = ZLEVEL_STATION

	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only
	immunity_type = "lava"

/datum/weather/floor_is_lava/impact(mob/living/L)
	for(var/obj/structure/O in L.loc)
		if(O.density)
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	L.adjustFireLoss(3)


/datum/weather/advanced_darkness //Advanced Darkness: Restricts the vision of all affected mobs to a single tile in the cardinal directions.
	name = "advanced darkness"
	desc = "Everything in the area is effectively blinded, unable to see more than a foot or so around itself."

	telegraph_message = "<span class='warning'>The lights begin to dim... is the power going out?</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>This isn't your average everday darkness... this is <i>advanced</i> darkness!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 300

	end_message = "<span class='danger'>At last, the darkness recedes.</span>"
	end_duration = 0

	area_type = /area
	target_z = ZLEVEL_STATION

/datum/weather/advanced_darkness/update_areas()
	for(var/V in impacted_areas)
		var/area/A = V
		if(stage == MAIN_STAGE)
			A.invisibility = 0
			A.set_opacity(TRUE)
			A.layer = overlay_layer
			A.icon = 'icons/effects/weather_effects.dmi'
			A.icon_state = "darkness"
		else
			A.invisibility = INVISIBILITY_MAXIMUM
			A.set_opacity(FALSE)


/datum/weather/ash_storm //Ash Storms: Common happenings on lavaland. Heavily obscures vision and deals heavy fire damage to anyone caught outside.
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_sound = 'sound/lavaland/ash_storm_windup.ogg'
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/lavaland/ash_storm_start.ogg'
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounce'>The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_sound = 'sound/lavaland/ash_storm_end.ogg'
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_z = ZLEVEL_LAVALAND

	immunity_type = "ash"

	probability = 90

/datum/weather/ash_storm/proc/is_ash_immune(mob/living/L)
	if(istype(L.loc, /obj/mecha)) //Mechs are immune
		return TRUE
	if(ishuman(L)) //Are you immune?
		var/mob/living/carbon/human/H = L
		var/thermal_protection = H.get_thermal_protection()
		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return TRUE
	if(istype(L.loc, /mob/living) && L.loc != L) //Matryoshka check
		return is_ash_immune(L.loc)
	return FALSE //RIP you

/datum/weather/ash_storm/impact(mob/living/L)
	if(is_ash_immune(L))
		return
	L.adjustFireLoss(4)

/datum/weather/ash_storm/emberfall //Emberfall: An ash storm passes by, resulting in harmless embers falling like snow. 10% to happen in place of an ash storm.
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_sound = 'sound/lavaland/ash_storm_windup.ogg'
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"

	aesthetic = TRUE

	probability = 10

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
	target_z = ZLEVEL_STATION

	immunity_type = "rad"

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm("alert")


/datum/weather/rad_storm/impact(mob/living/L)
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


/datum/weather/acid_rain
	name = "acid rain"
	desc = "Some stay dry and others feel the pain"

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>Stinging droplets start to fall upon you..</span>"
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = "<span class='userdanger'><i>Your skin melts underneath the rain!</i></span>"
	weather_overlay = "acid_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/ambience/acidrain_mid.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The rain starts to dissipate.</span>"
	end_sound = 'sound/ambience/acidrain_end.ogg'

	area_type = /area/lavaland/surface/outdoors
	target_z = ZLEVEL_LAVALAND

	immunity_type = "acid" // temp


/datum/weather/acid_rain/impact(mob/living/L)
	var/resist = L.getarmor(null, "acid")
	if(prob(max(0,100-resist)))
		L.acid_act(20,20)
