datum/preferences
	//The mob should have a gender you want before running this proc.
	proc/randomize_appearance_for(var/mob/living/carbon/human/H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE
		randomize_skin_tone()
		randomize_hair(gender)
		randomize_hair_color("hair")
		if(gender == MALE)//only for dudes.
			randomize_facial()
			randomize_hair_color("facial")
		randomize_eyes_color()
		underwear = 1
		b_type = pick("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")
		age = rand(19,35)
		copy_to(H,1)

	proc/randomize_name()
		if(gender == MALE)
			real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
		return

	proc/randomize_hair(var/gender)
		// Generate list of all possible hairs via typesof(), subtract the parent type however
		var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair

		// List of hair datums. Used in pick() to select random hair
		var/list/hairs = list()

		// Loop through potential hairs
		for(var/x in all_hairs)
			var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x

			if(gender == FEMALE && H.choose_female) // if female and hair is female-suitable, add to possible hairs
				hairs.Add(H)

			else if(gender != FEMALE && H.choose_male) // if male and hair is male-suitable, add to hairs
				hairs.Add(H)

			else
				del(H) // delete if incompatible

		if(hairs.len > 0) // if hairs could be generated
			hair_style = pick(hairs) // assign random hair
			h_style = hair_style.name

	proc/randomize_facial() // uncommented, see randomize_hair() for commentation
		var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair

		var/list/fhairs = list()

		for(var/x in all_fhairs)
			var/datum/sprite_accessory/facial_hair/H = new x

			if(gender == FEMALE && H.choose_female)
				fhairs.Add(H)
			else if(gender != FEMALE && H.choose_male)
				fhairs.Add(H)
			else
				del(H)

		if(fhairs.len > 0)
			facial_hair_style = pick(fhairs)
			f_style = facial_hair_style.name

	proc/randomize_skin_tone()
		var/tone

		var/tmp = pickweight ( list ("caucasian" = 55, "afroamerican" = 15, "african" = 10, "latino" = 10, "albino" = 5, "weird" = 5))
		switch (tmp)
			if ("caucasian")
				tone = -45 + 35
			if ("afroamerican")
				tone = -150 + 35
			if ("african")
				tone = -200 + 35
			if ("latino")
				tone = -90 + 35
			if ("albino")
				tone = -1 + 35
			if ("weird")
				tone = -(rand (1, 220)) + 35

		s_tone = min(max(tone + rand (-25, 25), -185), 34)

	proc/randomize_hair_color(var/target = "hair")
		if (prob (75) && target == "facial") // Chance to inherit hair color
			r_facial = r_hair
			g_facial = g_hair
			b_facial = b_hair
			return

		var/red
		var/green
		var/blue

		var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
		switch (col)
			if ("blonde")
				red = 255
				green = 255
				blue = 0
			if ("black")
				red = 0
				green = 0
				blue = 0
			if ("chestnut")
				red = 153
				green = 102
				blue = 51
			if ("copper")
				red = 255
				green = 153
				blue = 0
			if ("brown")
				red = 102
				green = 51
				blue = 0
			if ("wheat")
				red = 255
				green = 255
				blue = 153
			if ("old")
				red = rand (100, 255)
				green = red
				blue = red
			if ("punk")
				red = rand (0, 255)
				green = rand (0, 255)
				blue = rand (0, 255)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		switch (target)
			if ("hair")
				r_hair = red
				g_hair = green
				b_hair = blue
			if ("facial")
				r_facial = red
				g_facial = green
				b_facial = blue

	proc/randomize_eyes_color()
		var/red
		var/green
		var/blue

		var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino", "weird")
		switch (col)
			if ("black")
				red = 0
				green = 0
				blue = 0
			if ("grey")
				red = rand (100, 200)
				green = red
				blue = red
			if ("brown")
				red = 102
				green = 51
				blue = 0
			if ("chestnut")
				red = 153
				green = 102
				blue = 0
			if ("blue")
				red = 51
				green = 102
				blue = 204
			if ("lightblue")
				red = 102
				green = 204
				blue = 255
			if ("green")
				red = 0
				green = 102
				blue = 0
			if ("albino")
				red = rand (200, 255)
				green = rand (0, 150)
				blue = rand (0, 150)
			if ("weird")
				red = rand (0, 255)
				green = rand (0, 255)
				blue = rand (0, 255)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		r_eyes = red
		g_eyes = green
		b_eyes = blue

	proc/update_preview_icon()
		del(preview_icon_front)
		del(preview_icon_side)
		var/icon/preview_icon = null

		var/g = "m"
		if (gender == MALE)
			g = "m"
		else if (gender == FEMALE)
			g = "f"

		preview_icon = new /icon('human.dmi', "body_[g]_s")

		// Skin tone
		if (s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		if (underwear > 0)
			preview_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)

		var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)


		// Hair and facial hair, improved by Doohl
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)


		var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")

		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(mouth_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)
		preview_icon_front = new(preview_icon, dir = SOUTH)
		preview_icon_side = new(preview_icon, dir = WEST)
		
		del(preview_icon)
		del(mouth_s)
		del(facial_s)
		del(hair_s)
		del(eyes_s)


	proc/style_to_datum()
		// use h_style and f_style to load /datum hairs

		// hairs
		for(var/x in typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair)
			var/datum/sprite_accessory/hair/H = new x
			if(H.name == h_style)
				hair_style = H
			else
				del(H)

		// facial hairs
		for(var/x in typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair)
			var/datum/sprite_accessory/facial_hair/H = new x
			if(H.name == f_style)
				facial_hair_style = H
			else
				del(H)