/obj/item/clothing/under
	icon = 'uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	protective_temperature = T0C + 50
	heat_transfer_coefficient = 0.30
	permeability_coefficient = 0.90
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/


	examine()
		set src in view()
		..()
		switch(src.sensor_mode)
			if(0)
				usr << "Its sensors appear to be disabled."
			if(1)
				usr << "Its binary life sensors appear to be enabled."
			if(2)
				usr << "Its vital tracker appears to be enabled."
			if(3)
				usr << "Its vital tracker and tracking beacon appear to be enabled."


	verb/toggle()
		set name = "Toggle Suit Sensors"
		set category = "Object"
		set src in usr
		var/mob/M = usr
		if (istype(M, /mob/dead/)) return
		if (usr.stat) return
		if(src.has_sensor >= 2)
			usr << "The controls are locked."
			return 0
		if(src.has_sensor <= 0)
			usr << "This suit does not have any sensors"
			return 0
		src.sensor_mode += 1
		if(src.sensor_mode > 3)
			src.sensor_mode = 0
		switch(src.sensor_mode)
			if(0)
				usr << "You disable your suit's remote sensing equipment."
			if(1)
				usr << "Your suit will now report whether you are live or dead."
			if(2)
				usr << "Your suit will now report your vital lifesigns."
			if(3)
				usr << "Your suit will now report your vital lifesigns as well as your coordinate position."
		..()


/obj/item/clothing/under/rank/New()
	sensor_mode = pick(0,1,2,3)
	..()
