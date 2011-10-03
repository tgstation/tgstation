#define UI_OLD 0
#define UI_NEW 1

var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm --rastaf
//some autodetection here.
	"traitor" = IS_MODE_COMPILED("traitor"),
	"operative" = IS_MODE_COMPILED("nuclear"),
	"changeling" = IS_MODE_COMPILED("changeling"),
	"wizard" = IS_MODE_COMPILED("wizard"),
	"malf AI" = IS_MODE_COMPILED("malfunction"),
	"revolutionary" = IS_MODE_COMPILED("revolution"),
	"alien candidate" = 1, //always show
	"pai candidate" = 1, // -- TLE
	"cultist" = IS_MODE_COMPILED("cult"),
	"infested monkey" = IS_MODE_COMPILED("monkey"),
)
/*
var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm --rastaf
//some autodetection here.
	"traitor" = ispath(text2path("/datum/game_mode/traitor")),
	"operative" = ispath(text2path("/datum/game_mode/nuclear")),
	"changeling" = ispath(text2path("/datum/game_mode/changeling")),
	"wizard" = ispath(text2path("/datum/game_mode/wizard")),
	"malf AI" = ispath(text2path("/datum/game_mode/malfunction")),
	"revolutionary" = ispath(text2path("/datum/game_mode/revolution")),
	"alien candidate" = 1, //always show
	"cultist" = ispath(text2path("/datum/game_mode/cult")),
	"infested monkey" = ispath(text2path("/datum/game_mode/monkey")),
)
*/

datum/preferences
	var/real_name
	var/gender = MALE
	var/age = 30.0
	var/b_type = "A+"

	var/be_special //bitfields. See defines in setup.dm. --rastaf0
	var/midis = 1
	var/lastchangelog = 0 // size of last seen changelog file -- rastaf0
	var/ooccolor = "#b82e00"
	var/be_random_name = 0
	var/underwear = 1
	var/bubbles = 0 // 0 if the player doesn't want bubbles to appear

	var/occupation[length(occupations)]
	var/datum/jobs/wanted_jobs = list()

	var/h_style = "Short Hair"
	var/f_style = "Shaved"

	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0

	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0

	var/s_tone = 0
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	var/UI = UI_OLD // saving the whole .DMI in preferences is not a good idea. --rastaf0 //'screen1_old.dmi' // Skie

	var/icon/preview_icon = null

	New()
		randomize_name()
		for(var/n in occupation)
			n=1
		..()

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
		if (gender == MALE)
			real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))

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

	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>[real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preferences=1;b_random_name=1\">[be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[age]</a>"

		dat += "<br>"
		dat += "<b>UI Style:</b> <a href=\"byond://?src=\ref[user];preferences=1;UI=input\"><b>[UI == UI_NEW ? "New" : "Old"]</b></a><br>"
		dat += "<b>Play admin midis:</b> <a href=\"byond://?src=\ref[user];preferences=1;midis=input\"><b>[midis == 1 ? "Yes" : "No"]</b></a><br>"
		//dat += "<b>Show chat bubbles:</b> <a href=\"byond://?src=\ref[user];preferences=1;bubbles=input\"><b>[bubbles == 1 ? "Yes" : "No"]</b></a><br>"

		if((user.client) && (user.client.holder) && (user.client.holder.rank) && (user.client.holder.rank == "Game Master"))
			dat += "<hr><b>OOC</b><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;ooccolor=input'>Change colour</a> <font face=\"fixedsys\" size=\"3\" color=\"[ooccolor]\"><table style='display:inline;'  bgcolor=\"[ooccolor]\"><tr><td>__</td></tr></table></font>"

		dat += "<hr><b>Occupation Choices</b><br>"
		dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>Set Preferences</b></a><br>"

		dat += "<hr><table><tr><td><b>Body</b> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;s_tone=random;underwear=random;age=random;b_type=random;hair=random;h_style=random;facial=random;f_style=random;eyes=random\">&reg;</A>)" // Random look
		dat += "<br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[b_type]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preferences=1;s_tone=input'>[-s_tone + 35]/220<br></a>"

		if(!IsGuestKey(user.key))
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=1\"><b>[underwear == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]\"><table style='display:inline;' bgcolor=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]\"><tr><td>__</td></tr></table></font> "

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;h_style=input'>[h_style]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]\"><tr><td>__</td></tr></table></font> "

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;f_style=input'>[f_style]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]\"><tr><td>__</td></tr></table></font>"

		dat += "<hr>"
		if(!jobban_isbanned(user, "Syndicate"))
			var/n = 0
			for (var/i in special_roles)
				if(special_roles[i]) //if mode is available on the server
					dat += "<b>Be [i]:</b> <a href=\"byond://?src=\ref[user];preferences=1;be_special=[n]\"><b>[src.be_special&(1<<n) ? "Yes" : "No"]</b></a><br>"
				n++
		else
			dat += "<b>You are banned from being syndicate.</b>"
			src.be_special = 0
		dat += "<hr>"

		if (!IsGuestKey(user.key))
			dat += "<a href='byond://?src=\ref[user];preferences=1;load=1'>Load Setup</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;save=1'>Save Setup</a><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(dat, "window=preferences;size=300x710")

	proc/SetChoices(mob/user, changedjob)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are in red.<br>"
		for(var/job in occupations)
			if(!occupation[job])
				occupation[job] = 0
			if(jobban_isbanned(user, job))
				HTML += "<font color=red>[job]</font><br>"
				continue
			if((occupation["Assistant"] != 0) && (job != "Assistant"))
				HTML += "<font color=orange>[job]</font><br>"
				continue
			if((job in command_positions) || (job == "AI"))//Bold head jobs
				HTML += "<b>[job]<a href=\"byond://?src=\ref[user];preferences=1;occ=1;job=[job]\"></b>"
			else
				HTML += "[job]<a href=\"byond://?src=\ref[user];preferences=1;occ=1;job=[job]\">"

			if(job == "Assistant")//Assistant is special
				if(occupation[job] != 0)
					HTML += "<font color=green>\[Yes]</font>"
				else
					HTML += "<font color=red>\[No]</font>"
				HTML += "</a><br>"
				continue

			switch(occupation[job])
				if(0)
					HTML += "<font color=red>\[NEVER]</font>"
				if(1)
					HTML += "<font color=blue>\[High]</font>"
				if(2)
					HTML += "<font color=green>\[Medium]</font>"
				if(3)
					HTML += "<font color=orange>\[Low]</font>"
				else HTML += "*"+occupation[job]+"*"
			HTML += "</a><br>"

		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=0;job=cancel\">\[Done\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_occupation;size=320x600")
		return

	proc/SetJob(mob/user, job="Captain")
		if((!(occupations.Find(job)) && !(assistant_occupations.Find(job)) && (job != "No Preference")))
			user << browse(null, "window=mob_occupation")
			ShowChoices(user)
			return

		if(job == "Assistant")
			if(occupation[job] == 0)
				occupation[job] = 4
			else
				occupation[job] = 0
			SetChoices(user)
			return 1

		if(occupation[job] == 2)//Only one job may be set to "High"
			for(var/j in occupation)
				if(occupation[j] == 1)
					occupation[j] = 2

		occupation[job] = (occupation[job]-1)
		if(occupation[job] < 0)
			occupation[job] = 3

		SetChoices(user)

		return 1

	proc/process_link(mob/user, list/link_tags)

		if (link_tags["occ"])
			if (link_tags["cancel"])
				user << browse(null, "window=\ref[user]occupation")
				return
			else if(link_tags["job"])
				SetJob(user, link_tags["job"])
			else
				SetChoices(user)

			return 1

		if (link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")
					if(!new_name || (new_name == "Unknown") || (new_name == "floor") || (new_name == "wall") || (new_name == "r-wall"))
						alert("Don't do this")
						return

				if("random")
					randomize_name()

			if(new_name)
				if(length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				real_name = new_name

		if (link_tags["age"])
			switch(link_tags["age"])
				if ("input")
					var/new_age = input(user, "Please select type in age: 20-45", "Character Generation")  as num
					if(new_age)
						age = max(min(round(text2num(new_age)), 45), 20)
				if ("random")
					age = rand (20, 45)

		if (link_tags["b_type"])
			switch(link_tags["b_type"])
				if ("input")
					var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if (new_b_type)
						b_type = new_b_type
				if ("random")
					b_type = pickweight ( list ("A+" = 31, "A-" = 7, "B+" = 8, "B-" = 2, "AB+" = 2, "AB-" = 1, "O+" = 40, "O-" = 9))


		if (link_tags["hair"])
			switch(link_tags["hair"])
				if ("input")
					var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
					if(new_hair)
						r_hair = hex2num(copytext(new_hair, 2, 4))
						g_hair = hex2num(copytext(new_hair, 4, 6))
						b_hair = hex2num(copytext(new_hair, 6, 8))
				if ("random")
					randomize_hair_color("hair")

/*
		if (link_tags["r_hair"])
			var/new_component = input(user, "Please select red hair component: 1-255", "Character Generation")  as text

			if (new_component)
				r_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_hair"])
			var/new_component = input(user, "Please select green hair component: 1-255", "Character Generation")  as text

			if (new_component)
				g_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_hair"])
			var/new_component = input(user, "Please select blue hair component: 1-255", "Character Generation")  as text

			if (new_component)
				b_hair = max(min(round(text2num(new_component)), 255), 1)
*/

		if (link_tags["facial"])
			switch(link_tags["facial"])
				if ("input")
					var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))
				if ("random")
					randomize_hair_color("facial")

/*
		if (link_tags["r_facial"])
			var/new_component = input(user, "Please select red facial component: 1-255", "Character Generation")  as text

			if (new_component)
				r_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_facial"])
			var/new_component = input(user, "Please select green facial component: 1-255", "Character Generation")  as text

			if (new_component)
				g_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_facial"])
			var/new_component = input(user, "Please select blue facial component: 1-255", "Character Generation")  as text

			if (new_component)
				b_facial = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["eyes"])
			switch(link_tags["eyes"])
				if ("input")
					var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))
				if ("random")
					randomize_eyes_color()

/*
		if (link_tags["r_eyes"])
			var/new_component = input(user, "Please select red eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				r_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_eyes"])
			var/new_component = input(user, "Please select green eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				g_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_eyes"])
			var/new_component = input(user, "Please select blue eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				b_eyes = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["s_tone"])
			switch(link_tags["s_tone"])
				if ("random")
					randomize_skin_tone()
				if("input")
					var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text
					if (new_tone)
						s_tone = max(min(round(text2num(new_tone)), 220), 1)
						s_tone = -s_tone + 35

		if (link_tags["h_style"])
			switch(link_tags["h_style"])
				if ("random")
					if (gender == FEMALE)
						h_style = pickweight ( list ("Cut Hair" = 5, "Short Hair" = 5, "Long Hair" = 5, "Mohawk" = 5, "Balding" = 1, "Fag" = 5, "Bedhead" = 5, "Dreadlocks" = 5, "Bald" = 5))
					else
						h_style = pickweight ( list ("Cut Hair" = 5, "Short Hair" = 5, "Long Hair" = 5, "Mohawk" = 5, "Balding" = 5, "Fag" = 5, "Bedhead" = 5, "Dreadlocks" = 5, "Bald" = 5))

				if("input")
					var/new_style = input(user, "Please select hair style", "Character Generation")  as null|anything in list( "Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Fag", "Bedhead", "Dreadlocks", "Bald" )
					if (new_style)
						h_style = new_style

		if (link_tags["ooccolor"])
			var/ooccolor = input(user, "Please select OOC colour.", "OOC colour") as color

			if(ooccolor)
				src.ooccolor = ooccolor

		if (link_tags["f_style"])
			switch(link_tags["f_style"])
				if ("random")
					if (gender == FEMALE)
						f_style = pickweight ( list("Watson" = 1, "Chaplin" = 1, "Selleck" = 1, "Full Beard" = 1, "Long Beard" = 1, "Neckbeard" = 1, "Van Dyke" = 1, "Elvis" = 1, "Abe" = 1, "Chinstrap" = 1, "Hipster" = 1, "Goatee" = 1, "Hogan" = 1, "Shaved" = 100))
					else
						f_style = pickweight ( list("Watson" = 1, "Chaplin" = 1, "Selleck" = 1, "Full Beard" = 1, "Long Beard" = 1, "Neckbeard" = 1, "Van Dyke" = 1, "Elvis" = 1, "Abe" = 1, "Chinstrap" = 1, "Hipster" = 1, "Goatee" = 1, "Hogan" = 1, "Shaved" = 10))
				if("input")
					var/new_style = input(user, "Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")
					if (new_style)
						f_style = new_style

		if (link_tags["gender"])
			if (gender == MALE)
				gender = FEMALE
			else
				gender = MALE

		if (link_tags["UI"])
			if (UI == UI_OLD)
				UI = UI_NEW
			else
				UI = UI_OLD

		if (link_tags["midis"])
			midis = (midis+1)%2

		if (link_tags["bubbles"])
			bubbles = !bubbles

		if (link_tags["underwear"])
			if(!IsGuestKey(user.key))
				switch(link_tags["underwear"])
					if ("random")
						if (prob (75))
							underwear = 1
						else
							underwear = 0
					if("input")
						if (underwear == 1)
							underwear = 0
						else
							underwear = 1

		if (link_tags["be_special"])
			src.be_special^=(1<<text2num(link_tags["be_special"])) //bitwize magic, sorry for that. --rastaf0

		if (link_tags["b_random_name"])
			be_random_name = !be_random_name

		if(!IsGuestKey(user.key))
			if(link_tags["save"])
				savefile_save(user)

			else if(link_tags["load"])
				if (!savefile_load(user, 0))
					alert(user, "You do not have a savefile.")

		if (link_tags["reset_all"])
			gender = MALE
			randomize_name()

			age = 30
			for(var/o in occupation)
				occupation[o] = 0
			underwear = 1
			//be_syndicate = 0
			be_special = 0
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
			UI = UI_OLD
			midis = 1
			bubbles = 1


		ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character, safety = 0)
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

		switch (UI)
			if (UI_OLD)
				character.UI = 'screen1_old.dmi'
			if (UI_NEW)
				character.UI = 'screen1.dmi'

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

		character.underwear = underwear == 1 ? pick(1,2,3,4,5) : 0

		character.update_face()
		character.update_body()

		if(!safety)//To prevent run-time errors due to null datum when using randomize_appearance_for()
			spawn(10)
				if(character&&character.client)
					character.client.midis = midis
					character.client.bubbles = bubbles
					character.client.ooccolor = ooccolor
					character.client.be_alien = be_special&BE_ALIEN
					character.client.be_pai = be_special&BE_PAI

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
#undef UI_OLD
#undef UI_NEW