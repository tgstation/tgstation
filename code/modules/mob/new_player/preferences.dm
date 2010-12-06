datum/preferences
	var/real_name
	var/gender = MALE
	var/age = 30.0
	var/b_type = "A+"

	var/be_syndicate
	var/midis = 1
	var/ooccolor = "#b82e00"
	var/be_random_name = 0
	var/underwear = 1

	var/occupation1 = "No Preference"
	var/occupation2 = "No Preference"
	var/occupation3 = "No Preference"

	var/h_style = "Short Hair"
	var/f_style = "Shaved"

	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0

	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0

	var/s_tone = 0.0
	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0

	var/UI = 'screen1_old.dmi' // Skie

	var/icon/preview_icon = null

	New()
		randomize_name()

		..()

	proc/randomize_name()
		if (gender == MALE)
			real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))

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

		src.s_tone = min(max(tone + rand (-25, 25), -185), 34)

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
		del(src.preview_icon)

		var/g = "m"
		if (src.gender == MALE)
			g = "m"
		else if (src.gender == FEMALE)
			g = "f"

		src.preview_icon = new /icon('human.dmi', "body_[g]_s")

		// Skin tone
		if (src.s_tone >= 0)
			src.preview_icon.Blend(rgb(src.s_tone, src.s_tone, src.s_tone), ICON_ADD)
		else
			src.preview_icon.Blend(rgb(-src.s_tone,  -src.s_tone,  -src.s_tone), ICON_SUBTRACT)

		if (src.underwear > 0)
			src.preview_icon.Blend(new /icon('human.dmi', "underwear[src.underwear]_[g]_s"), ICON_OVERLAY)

		var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
		eyes_s.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), ICON_ADD)

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
		hair_s.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), ICON_ADD)

		var/icon/facial_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[f_style_r]_s")
		facial_s.Blend(rgb(src.r_facial, src.g_facial, src.b_facial), ICON_ADD)

		var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")

		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(mouth_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

		src.preview_icon.Blend(eyes_s, ICON_OVERLAY)

		del(mouth_s)
		del(facial_s)
		del(hair_s)
		del(eyes_s)

	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/list/destructive = assistant_occupations.Copy()
		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>[src.real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preferences=1;b_random_name=1\">[src.be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[src.gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[src.age]</a>"

		dat += "<br>"
		dat += "<b>UI Style:</b> <a href=\"byond://?src=\ref[user];preferences=1;UI=input\"><b>[src.UI == 'screen1.dmi' ? "New" : "Old"]</b></a><br>"
		dat += "<b>Play admin midis:</b> <a href=\"byond://?src=\ref[user];preferences=1;midis=input\"><b>[src.midis == 1 ? "Yes" : "No"]</b></a><br>"

		if(user.client.holder)
			if(user.client.holder.rank)
				if(user.client.holder.rank == "Host")
					dat += "<hr><b>OOC</b><br>"
					dat += "<a href='byond://?src=\ref[user];preferences=1;ooccolor=input'>Change colour</a> <font face=\"fixedsys\" size=\"3\" color=\"[ooccolor]\"><table bgcolor=\"[ooccolor]\"><tr><td>IM</td></tr></table></font>"

		dat += "<hr><b>Occupation Choices</b><br>"
		if (destructive.Find(src.occupation1))
			dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>[occupation1]</b></a><br>"
		else
			if (jobban_isbanned(user, src.occupation1))
				src.occupation1 = "Assistant"
			if (jobban_isbanned(user, src.occupation2))
				src.occupation2 = "Assistant"
			if (jobban_isbanned(user, src.occupation3))
				src.occupation3 = "Assistant"
			if (src.occupation1 != "No Preference")
				dat += "\tFirst Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>[occupation1]</b></a><br>"

				if (destructive.Find(src.occupation2))
					dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\"><b>[occupation2]</b></a><BR>"

				else
					if (src.occupation2 != "No Preference")
						dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\"><b>[occupation2]</b></a><BR>"
						dat += "\tLast Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=3\"><b>[occupation3]</b></a><BR>"

					else
						dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\">No Preference</a><br>"
			else
				dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\">No Preference</a><br>"

		dat += "<hr><table><tr><td><b>Body</b> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;s_tone=random;underwear=random;age=random;b_type=random;hair=random;h_style=random;facial=random;f_style=random;eyes=random\">&reg;</A>)" // Random look
		dat += "<br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[src.b_type]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preferences=1;s_tone=input'>[-src.s_tone + 35]/220<br></a>"

		if (!IsGuestKey(user.key))
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=1\"><b>[src.underwear == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_hair, 2)][num2hex(src.g_hair, 2)][num2hex(src.b_hair, 2)]\"><table bgcolor=\"#[num2hex(src.r_hair, 2)][num2hex(src.g_hair, 2)][num2hex(src.b_hair)]\"><tr><td>IM</td></tr></table></font>"
/*
		dat += " <font color=\"#[num2hex(src.r_hair, 2)]0000\">Red</font> - <a href='byond://?src=\ref[user];preferences=1;r_hair=input'>[src.r_hair]</a>"
		dat += " <font color=\"#00[num2hex(src.g_hair, 2)]00\">Green</font> - <a href='byond://?src=\ref[user];preferences=1;g_hair=input'>[src.g_hair]</a>"
		dat += " <font color=\"#0000[num2hex(src.b_hair, 2)]\">Blue</font> - <a href='byond://?src=\ref[user];preferences=1;b_hair=input'>[src.b_hair]</a><br>"
*/
		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;h_style=input'>[src.h_style]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_facial, 2)][num2hex(src.g_facial, 2)][num2hex(src.b_facial, 2)]\"><table bgcolor=\"#[num2hex(src.r_facial, 2)][num2hex(src.g_facial, 2)][num2hex(src.b_facial)]\"><tr><td>GO</td></tr></table></font>"
/*
		dat += " <font color=\"#[num2hex(src.r_facial, 2)]0000\">Red</font> - <a href='byond://?src=\ref[user];preferences=1;r_facial=input'>[src.r_facial]</a>"
		dat += " <font color=\"#00[num2hex(src.g_facial, 2)]00\">Green</font> - <a href='byond://?src=\ref[user];preferences=1;g_facial=input'>[src.g_facial]</a>"
		dat += " <font color=\"#0000[num2hex(src.b_facial, 2)]\">Blue</font> - <a href='byond://?src=\ref[user];preferences=1;b_facial=input'>[src.b_facial]</a><br>"
*/
		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;f_style=input'>[src.f_style]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_eyes, 2)][num2hex(src.g_eyes, 2)][num2hex(src.b_eyes, 2)]\"><table bgcolor=\"#[num2hex(src.r_eyes, 2)][num2hex(src.g_eyes, 2)][num2hex(src.b_eyes)]\"><tr><td>KU</td></tr></table></font>"
/*
		dat += " <font color=\"#[num2hex(src.r_eyes, 2)]0000\">Red</font> - <a href='byond://?src=\ref[user];preferences=1;r_eyes=input'>[src.r_eyes]</a>"
		dat += " <font color=\"#00[num2hex(src.g_eyes, 2)]00\">Green</font> - <a href='byond://?src=\ref[user];preferences=1;g_eyes=input'>[src.g_eyes]</a>"
		dat += " <font color=\"#0000[num2hex(src.b_eyes, 2)]\">Blue</font> - <a href='byond://?src=\ref[user];preferences=1;b_eyes=input'>[src.b_eyes]</a>"
*/
		dat += "<hr>"
		if(!jobban_isbanned(user, "Syndicate"))
			dat += "<b>Be syndicate?:</b> <a href =\"byond://?src=\ref[user];preferences=1;b_syndicate=1\"><b>[(src.be_syndicate ? "Yes" : "No")]</b></a><br>"
		else
			dat += "<b> You are banned from being syndicate.</b>"
			src.be_syndicate = 0
		dat += "<hr>"

		if (!IsGuestKey(user.key))
			dat += "<a href='byond://?src=\ref[user];preferences=1;load=1'>Load Setup</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;save=1'>Save Setup</a><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(dat, "window=preferences;size=300x710")

	proc/SetChoices(mob/user, occ=1)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		switch(occ)
			if(1.0)
				HTML += "<b>Which occupation would you like most?</b><br><br>"
			if(2.0)
				HTML += "<b>Which occupation would you like if you couldn't have your first?</b><br><br>"
			if(3.0)
				HTML += "<b>Which occupation would you like if you couldn't have the others?</b><br><br>"
			else
		for(var/job in uniquelist(occupations + assistant_occupations) )
			if ((job!="AI" || config.allow_ai) && !jobban_isbanned(user, job))
				HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=[job]\">[job]</a><br>"

		if(!jobban_isbanned(user, "Captain"))
			HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=Captain\">Captain</a><br>"
		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=No Preference\">\[No Preference\]</a><br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];cancel\">\[Cancel\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_occupation;size=320x600")
		return

	proc/SetJob(mob/user, occ=1, job="Captain")
		if ((!( occupations.Find(job) ) && !( assistant_occupations.Find(job) ) && job != "Captain"))
			return
		if (job=="AI" && (!config.allow_ai))
			return
		if (jobban_isbanned(user, job))
			return

		switch(occ)
			if(1.0)
				if (job == occupation1)
					user << browse(null, "window=mob_occupation")
					return
				else
					if (job == "No Preference")
						src.occupation1 = "No Preference"
					else
						if (job == src.occupation2)
							job = src.occupation1
							src.occupation1 = src.occupation2
							src.occupation2 = job
						else
							if (job == src.occupation3)
								job = src.occupation1
								src.occupation1 = src.occupation3
								src.occupation3 = job
							else
								src.occupation1 = job
			if(2.0)
				if (job == src.occupation2)
					user << browse(null, "window=mob_occupation")
					return
				else
					if (job == "No Preference")
						if (src.occupation3 != "No Preference")
							src.occupation2 = src.occupation3
							src.occupation3 = "No Preference"
						else
							src.occupation2 = "No Preference"
					else
						if (job == src.occupation1)
							if (src.occupation2 == "No Preference")
								user << browse(null, "window=mob_occupation")
								return
							job = src.occupation2
							src.occupation2 = src.occupation1
							src.occupation1 = job
						else
							if (job == src.occupation3)
								job = src.occupation2
								src.occupation2 = src.occupation3
								src.occupation3 = job
							else
								src.occupation2 = job
			if(3.0)
				if (job == src.occupation3)
					user << browse(null, "window=mob_occupation")
					return
				else
					if (job == "No Preference")
						src.occupation3 = "No Preference"
					else
						if (job == src.occupation1)
							if (src.occupation3 == "No Preference")
								user << browse(null, "window=mob_occupation")
								return
							job = src.occupation3
							src.occupation3 = src.occupation1
							src.occupation1 = job
						else
							if (job == src.occupation2)
								if (src.occupation3 == "No Preference")
									user << browse(null, "window=mob_occupation")
									return
								job = src.occupation3
								src.occupation3 = src.occupation2
								src.occupation2 = job
							else
								src.occupation3 = job

		user << browse(null, "window=mob_occupation")
		ShowChoices(user)

		return 1

	proc/process_link(mob/user, list/link_tags)

		if (link_tags["occ"])
			if (link_tags["cancel"])
				user << browse(null, "window=\ref[user]occupation")
				return
			else if(link_tags["job"])
				src.SetJob(user, text2num(link_tags["occ"]), link_tags["job"])
			else
				src.SetChoices(user, text2num(link_tags["occ"]))

			return 1

		if (link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")
					if(!new_name || (new_name == "Unknown"))
						alert("Don't do this")
						return

				if("random")
					src.randomize_name()

			if(new_name)
				if(length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				src.real_name = new_name

		if (link_tags["age"])
			switch(link_tags["age"])
				if ("input")
					var/new_age = input(user, "Please select type in age: 20-45", "Character Generation")  as num
					if(new_age)
						src.age = max(min(round(text2num(new_age)), 45), 20)
				if ("random")
					src.age = rand (20, 45)

		if (link_tags["b_type"])
			switch(link_tags["b_type"])
				if ("input")
					var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if (new_b_type)
						src.b_type = new_b_type
				if ("random")
					src.b_type = pickweight ( list ("A+" = 31, "A-" = 7, "B+" = 8, "B-" = 2, "AB+" = 2, "AB-" = 1, "O+" = 40, "O-" = 9))


		if (link_tags["hair"])
			switch(link_tags["hair"])
				if ("input")
					var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
					if(new_hair)
						src.r_hair = hex2num(copytext(new_hair, 2, 4))
						src.g_hair = hex2num(copytext(new_hair, 4, 6))
						src.b_hair = hex2num(copytext(new_hair, 6, 8))
				if ("random")
					randomize_hair_color("hair")

/*
		if (link_tags["r_hair"])
			var/new_component = input(user, "Please select red hair component: 1-255", "Character Generation")  as text

			if (new_component)
				src.r_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_hair"])
			var/new_component = input(user, "Please select green hair component: 1-255", "Character Generation")  as text

			if (new_component)
				src.g_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_hair"])
			var/new_component = input(user, "Please select blue hair component: 1-255", "Character Generation")  as text

			if (new_component)
				src.b_hair = max(min(round(text2num(new_component)), 255), 1)
*/

		if (link_tags["facial"])
			switch(link_tags["facial"])
				if ("input")
					var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
					if(new_facial)
						src.r_facial = hex2num(copytext(new_facial, 2, 4))
						src.g_facial = hex2num(copytext(new_facial, 4, 6))
						src.b_facial = hex2num(copytext(new_facial, 6, 8))
				if ("random")
					randomize_hair_color("facial")

/*
		if (link_tags["r_facial"])
			var/new_component = input(user, "Please select red facial component: 1-255", "Character Generation")  as text

			if (new_component)
				src.r_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_facial"])
			var/new_component = input(user, "Please select green facial component: 1-255", "Character Generation")  as text

			if (new_component)
				src.g_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_facial"])
			var/new_component = input(user, "Please select blue facial component: 1-255", "Character Generation")  as text

			if (new_component)
				src.b_facial = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["eyes"])
			switch(link_tags["eyes"])
				if ("input")
					var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
					if(new_eyes)
						src.r_eyes = hex2num(copytext(new_eyes, 2, 4))
						src.g_eyes = hex2num(copytext(new_eyes, 4, 6))
						src.b_eyes = hex2num(copytext(new_eyes, 6, 8))
				if ("random")
					randomize_eyes_color()

/*
		if (link_tags["r_eyes"])
			var/new_component = input(user, "Please select red eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				src.r_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_eyes"])
			var/new_component = input(user, "Please select green eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				src.g_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_eyes"])
			var/new_component = input(user, "Please select blue eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				src.b_eyes = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["s_tone"])
			switch(link_tags["s_tone"])
				if ("random")
					randomize_skin_tone()
				if("input")
					var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text
					if (new_tone)
						src.s_tone = max(min(round(text2num(new_tone)), 220), 1)
						src.s_tone = -src.s_tone + 35

		if (link_tags["h_style"])
			switch(link_tags["h_style"])
				if ("random")
					src.h_style = pick ("Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Fag", "Bedhead", "Dreadlocks", "Bald")
				if("input")
					var/new_style = input(user, "Please select hair style", "Character Generation")  as null|anything in list( "Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Fag", "Bedhead", "Dreadlocks", "Bald" )
					if (new_style)
						src.h_style = new_style

		if (link_tags["ooccolor"])
			var/ooccolor = input(user, "Please select OOC colour.", "OOC colour") as color

			if(ooccolor)
				src.ooccolor = ooccolor

		if (link_tags["f_style"])
			switch(link_tags["f_style"])
				if ("random")
					if (src.gender == FEMALE)
						src.f_style = pickweight ( list("Watson" = 1, "Chaplin" = 1, "Selleck" = 1, "Full Beard" = 1, "Long Beard" = 1, "Neckbeard" = 1, "Van Dyke" = 1, "Elvis" = 1, "Abe" = 1, "Chinstrap" = 1, "Hipster" = 1, "Goatee" = 1, "Hogan" = 1, "Shaved" = 100))
					else
						src.f_style = pickweight ( list("Watson" = 1, "Chaplin" = 1, "Selleck" = 1, "Full Beard" = 1, "Long Beard" = 1, "Neckbeard" = 1, "Van Dyke" = 1, "Elvis" = 1, "Abe" = 1, "Chinstrap" = 1, "Hipster" = 1, "Goatee" = 1, "Hogan" = 1, "Shaved" = 10))
				if("input")
					var/new_style = input(user, "Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")
					if (new_style)
						src.f_style = new_style

		if (link_tags["gender"])
			if (src.gender == MALE)
				src.gender = FEMALE
			else
				src.gender = MALE

		if (link_tags["UI"])
			if (src.UI == 'screen1.dmi')
				src.UI = 'screen1_old.dmi'
			else
				src.UI = 'screen1.dmi'

		if (link_tags["midis"])
			if (src.midis)
				src.midis = 0
			else
				src.midis = 1

		if (link_tags["underwear"])
			if(!IsGuestKey(user.key))
				switch(link_tags["underwear"])
					if ("random")
						if (prob (75))
							src.underwear = 1
						else
							src.underwear = 0
					if("input")
						if (src.underwear == 1)
							src.underwear = 0
						else
							src.underwear = 1

		if (link_tags["b_syndicate"])
			src.be_syndicate = !( src.be_syndicate )

		if (link_tags["b_random_name"])
			src.be_random_name = !src.be_random_name

		if(!IsGuestKey(user.key))
			if(link_tags["save"])
				src.savefile_save(user)

			else if(link_tags["load"])
				if (!src.savefile_load(user, 0))
					alert(user, "You do not have a savefile.")

		if (link_tags["reset_all"])
			gender = MALE
			randomize_name()

			age = 30
			occupation1 = "No Preference"
			occupation2 = "No Preference"
			occupation3 = "No Preference"
			underwear = 1
			be_syndicate = 0
			be_random_name = 0
			r_hair = 0.0
			g_hair = 0.0
			b_hair = 0.0
			r_facial = 0.0
			g_facial = 0.0
			b_facial = 0.0
			h_style = "Short Hair"
			f_style = "Shaved"
			r_eyes = 0.0
			g_eyes = 0.0
			b_eyes = 0.0
			s_tone = 0.0
			b_type = "A+"
			UI = 'screen1_old.dmi'
			midis = 1


		src.ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character)
		if(be_random_name)
			randomize_name()
		character.real_name = real_name

		character.gender = gender

		character.age = age
		character.b_type = b_type

		character.r_eyes = r_eyes
		character.g_eyes = g_eyes
		character.b_eyes = b_eyes

		character.r_hair = r_hair
		character.g_hair = g_hair
		character.b_hair = b_hair

		character.r_facial = r_facial
		character.g_facial = g_facial
		character.b_facial = b_facial

		character.s_tone = s_tone

		character.h_style = h_style
		character.f_style = f_style

		character.UI = UI

		switch(h_style)
			if("Short Hair")
				character.hair_icon_state = "hair_a"
			if("Long Hair")
				character.hair_icon_state = "hair_b"
			if("Cut Hair")
				character.hair_icon_state = "hair_c"
			if("Mohawk")
				character.hair_icon_state = "hair_d"
			if("Balding")
				character.hair_icon_state = "hair_e"
			if("Fag")
				character.hair_icon_state = "hair_f"
			if("Bedhead")
				character.hair_icon_state = "hair_bedhead"
			if("Dreadlocks")
				character.hair_icon_state = "hair_dreads"
			else
				character.hair_icon_state = "bald"

		switch(f_style)
			if ("Watson")
				character.face_icon_state = "facial_watson"
			if ("Chaplin")
				character.face_icon_state = "facial_chaplin"
			if ("Selleck")
				character.face_icon_state = "facial_selleck"
			if ("Neckbeard")
				character.face_icon_state = "facial_neckbeard"
			if ("Full Beard")
				character.face_icon_state = "facial_fullbeard"
			if ("Long Beard")
				character.face_icon_state = "facial_longbeard"
			if ("Van Dyke")
				character.face_icon_state = "facial_vandyke"
			if ("Elvis")
				character.face_icon_state = "facial_elvis"
			if ("Abe")
				character.face_icon_state = "facial_abe"
			if ("Chinstrap")
				character.face_icon_state = "facial_chin"
			if ("Hipster")
				character.face_icon_state = "facial_hip"
			if ("Goatee")
				character.face_icon_state = "facial_gt"
			if ("Hogan")
				character.face_icon_state = "facial_hogan"
			else
				character.face_icon_state = "bald"

		if (underwear == 1)
			character.underwear = pick(1,2,3,4,5)
		else
			character.underwear = 0

		character.update_face()
		character.update_body()

		spawn(10)
			character.client.midis = midis
			character.client.ooccolor = ooccolor

/*

	if (!M.real_name || M.be_random_name)
		if (M.gender == "male")
			M.real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			M.real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
	for(var/mob/living/carbon/human/H in world)
		if(cmptext(H.real_name,M.real_name))
			usr << "You are using a name that is very similar to a currently used name, please choose another one using Character Setup."
			return
	if(cmptext("Unknown",M.real_name))
		usr << "This name is reserved for use by the game, please choose another one using Character Setup."
		return

*/