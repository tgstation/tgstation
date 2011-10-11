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
		underwear = pick(0,1)
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
		//Women are more likely to have longer hair.
		var/temp = gender==FEMALE&&prob(80) ? pick(2,6,8) : rand(1,9)
		switch(temp)
			if(1)
				h_style = "Short Hair"
			if(2)
				h_style = "Long Hair"
			if(3)
				h_style = "Cut Hair"
			if(4)
				h_style = "Mohawk"
			if(5)
				h_style = "Balding"
			if(6)
				h_style = "Fag"
			if(7)
				h_style = "Bedhead"
			if(8)
				h_style = "Dreadlocks"
			else
				h_style = "bald"

	proc/randomize_facial()
		var/temp = prob(50) ? 14 : rand(1,13)//50% of not having a beard. Otherwise get a random one.
		switch(temp)
			if(1)
				f_style = "Watson"
			if(2)
				f_style = "Chaplin"
			if(3)
				f_style = "Selleck"
			if(4)
				f_style = "Neckbeard"
			if(5)
				f_style = "Full Beard"
			if(6)
				f_style = "Long Beard"
			if(7)
				f_style = "Van Dyke"
			if(8)
				f_style = "Elvis"
			if(9)
				f_style = "Abe"
			if(10)
				f_style = "Chinstrap"
			if(11)
				f_style = "Hipster"
			if(12)
				f_style = "Goatee"
			if(13)
				f_style = "Hogan"
			else
				f_style = "bald"

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
		del(preview_icon)

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

		var/h_style_r = null
		switch(h_style)
			if("Short Hair")
				h_style_r = "hair_a"
			if("Long Hair")
				h_style_r = "hair_b"
			if("Cut Hair")
				h_style_r = "hair_c"
			if("Mohawk")
				h_style_r = "hair_d"
			if("Balding")
				h_style_r = "hair_e"
			if("Fag")
				h_style_r = "hair_f"
			if("Bedhead")
				h_style_r = "hair_bedhead"
			if("Dreadlocks")
				h_style_r = "hair_dreads"
			else
				h_style_r = "bald"

		var/f_style_r = null
		switch(f_style)
			if ("Watson")
				f_style_r = "facial_watson"
			if ("Chaplin")
				f_style_r = "facial_chaplin"
			if ("Selleck")
				f_style_r = "facial_selleck"
			if ("Neckbeard")
				f_style_r = "facial_neckbeard"
			if ("Full Beard")
				f_style_r = "facial_fullbeard"
			if ("Long Beard")
				f_style_r = "facial_longbeard"
			if ("Van Dyke")
				f_style_r = "facial_vandyke"
			if ("Elvis")
				f_style_r = "facial_elvis"
			if ("Abe")
				f_style_r = "facial_abe"
			if ("Chinstrap")
				f_style_r = "facial_chin"
			if ("Hipster")
				f_style_r = "facial_hip"
			if ("Goatee")
				f_style_r = "facial_gt"
			if ("Hogan")
				f_style_r = "facial_hogan"
			else
				f_style_r = "bald"

		var/icon/hair_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[h_style_r]_s")
		hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

		var/icon/facial_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[f_style_r]_s")
		facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

		var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")

		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(mouth_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)

		del(mouth_s)
		del(facial_s)
		del(hair_s)
		del(eyes_s)