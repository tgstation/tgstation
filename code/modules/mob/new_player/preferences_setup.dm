datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
	proc/randomize_appearance_for(var/mob/living/carbon/human/H)
		if(H)
			if(H.gender == MALE)
				gender = MALE
			else
				gender = FEMALE
		s_tone = random_skin_tone()
		h_style = random_hair_style(gender, species)
		f_style = random_facial_hair_style(gender, species)
		randomize_hair_color("hair")
		randomize_hair_color("facial")
		randomize_eyes_color()
		underwear = rand(1,underwear_m.len)
		backbag = 2
		age = rand(AGE_MIN,AGE_MAX)
		if(H)
			copy_to(H,1)


	proc/randomize_hair_color(var/target = "hair")
		if(prob (75) && target == "facial") // Chance to inherit hair color
			r_facial = r_hair
			g_facial = g_hair
			b_facial = b_hair
			return

		var/red
		var/green
		var/blue

		var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
		switch(col)
			if("blonde")
				red = 255
				green = 255
				blue = 0
			if("black")
				red = 0
				green = 0
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 51
			if("copper")
				red = 255
				green = 153
				blue = 0
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("wheat")
				red = 255
				green = 255
				blue = 153
			if("old")
				red = rand (100, 255)
				green = red
				blue = red
			if("punk")
				red = rand (0, 255)
				green = rand (0, 255)
				blue = rand (0, 255)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		switch(target)
			if("hair")
				r_hair = red
				g_hair = green
				b_hair = blue
			if("facial")
				r_facial = red
				g_facial = green
				b_facial = blue

	proc/randomize_eyes_color()
		var/red
		var/green
		var/blue

		var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
		switch(col)
			if("black")
				red = 0
				green = 0
				blue = 0
			if("grey")
				red = rand (100, 200)
				green = red
				blue = red
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 0
			if("blue")
				red = 51
				green = 102
				blue = 204
			if("lightblue")
				red = 102
				green = 204
				blue = 255
			if("green")
				red = 0
				green = 102
				blue = 0
			if("albino")
				red = rand (200, 255)
				green = rand (0, 150)
				blue = rand (0, 150)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		r_eyes = red
		g_eyes = green
		b_eyes = blue

	proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack")
		switch(backbag)
			if(2)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', backpack), ICON_OVERLAY)
			if(3)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', satchel), ICON_OVERLAY)
			if(4)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
		return clothes_s


	proc/update_preview_icon(var/for_observer=0)		//seriously. This is horrendous.
		preview_icon_front = null
		preview_icon_side = null
		preview_icon = null

		var/g = "m"
		if(gender == FEMALE)	g = "f"

		var/icon/icobase
		var/datum/species/current_species = all_species[species]

		if(current_species)
			icobase = current_species.icobase
		else
			icobase = 'icons/mob/human_races/r_human.dmi'

		var/fat=""
		if(disabilities&DISABILITY_FLAG_FAT && current_species.flags & CAN_BE_FAT)
			fat="_fat"
		preview_icon = new /icon(icobase, "torso_[g][fat]")
		preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "head_[g]"), ICON_OVERLAY)

		for(var/name in list("l_arm","r_arm","l_leg","r_leg","l_foot","r_foot","l_hand","r_hand"))
			// make sure the organ is added to the list so it's drawn
			if(organ_data[name] == null)
				organ_data[name] = null

		for(var/name in organ_data)
			if(organ_data[name] == "amputated") continue

			var/o_icobase=icobase
			if(organ_data[name] == "peg")
				o_icobase='icons/mob/human_races/o_peg.dmi'
			else if(organ_data[name] == "cyborg")
				o_icobase='icons/mob/human_races/o_robot.dmi'

			var/icon/temp = new /icon(o_icobase, "[name]")

			preview_icon.Blend(temp, ICON_OVERLAY)

		// Skin tone
		if(current_species && (current_species.flags & HAS_SKIN_TONE))
			if (s_tone >= 0)
				preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			else
				preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			eyes_s.Blend(hair_s, ICON_OVERLAY)

		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			eyes_s.Blend(facial_s, ICON_OVERLAY)

		var/icon/clothes_s = null

		// UNIFORM DMI
		var/uniform_dmi=current_species.uniform_icons
		if(disabilities&DISABILITY_FLAG_FAT && current_species.fat_uniform_icons)
			uniform_dmi=current_species.fat_uniform_icons

		// SHOES DMI
		var/feet_dmi=current_species.shoes_icons

		if(!for_observer)
			// Commenting this check so that, if all else fails, the preview icon is never naked. - N3X
			//if(job_civilian_low & ASSISTANT) //This gives the preview icon clothes depending on which job(if any) is set to 'high'
			clothes_s = new /icon(uniform_dmi, "grey_s")
			clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
			clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")

			//else
			if(job_civilian_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
				switch(job_civilian_high)
					if(HOP)
						clothes_s = new /icon(uniform_dmi, "hop_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(BARTENDER)
						clothes_s = new /icon(uniform_dmi, "ba_suit_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(BOTANIST)
						clothes_s = new /icon(uniform_dmi, "hydroponics_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "ggloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apron"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-hyd")
					if(CHEF)
						clothes_s = new /icon(uniform_dmi, "chef_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "chef"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(JANITOR)
						clothes_s = new /icon(uniform_dmi, "janitor_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(LIBRARIAN)
						clothes_s = new /icon(uniform_dmi, "red_suit_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(QUARTERMASTER)
						clothes_s = new /icon(uniform_dmi, "qm_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(CARGOTECH)
						clothes_s = new /icon(uniform_dmi, "cargotech_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(MINER)
						clothes_s = new /icon(uniform_dmi, "miner_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng")
					if(LAWYER)
						clothes_s = new /icon(uniform_dmi, "internalaffairs_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(CHAPLAIN)
						clothes_s = new /icon(uniform_dmi, "chapblack_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(CLOWN)
						clothes_s = new /icon(uniform_dmi, "clown_s")
						clothes_s.Blend(new /icon(feet_dmi, "clown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "clownpack"), ICON_OVERLAY)
					if(MIME)
						clothes_s = new /icon(uniform_dmi, "mime_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suspenders"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")

			else if(job_medsci_high)
				switch(job_medsci_high)
					if(RD)
						clothes_s = new /icon(uniform_dmi, "director_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "clipboard"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-tox")
					if(SCIENTIST)
						clothes_s = new /icon(uniform_dmi, "toxinswhite_s")
						clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-tox")
					if(CHEMIST)
						clothes_s = new /icon(uniform_dmi, "chemistrywhite_s")
						clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-chem")
					if(CMO)
						clothes_s = new /icon(uniform_dmi, "cmo_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-med")
					if(DOCTOR)
						clothes_s = new /icon(uniform_dmi, "medical_s")
						clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-med","medicalpack")
					if(GENETICIST)
						clothes_s = new /icon(uniform_dmi, "geneticswhite_s")
						clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-gen")
					if(VIROLOGIST)
						clothes_s = new /icon(uniform_dmi, "virologywhite_s")
						clothes_s.Blend(new /icon(feet_dmi, "white"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/mask.dmi', "sterile"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-vir","medicalpack")
					if(ROBOTICIST)
						clothes_s = new /icon(uniform_dmi, "robotics_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")

			else if(job_engsec_high)
				switch(job_engsec_high)
					if(CAPTAIN)
						clothes_s = new /icon(uniform_dmi, "captain_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "caparmor"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-cap")
					if(HOS)
						clothes_s = new /icon(uniform_dmi, "hosred_s")
						clothes_s.Blend(new /icon(feet_dmi, "jackboots"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-sec","securitypack")
					if(WARDEN)
						clothes_s = new /icon(uniform_dmi, "warden_s")
						clothes_s.Blend(new /icon(feet_dmi, "jackboots"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-sec","securitypack")
					if(DETECTIVE)
						clothes_s = new /icon(uniform_dmi, "detective_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(OFFICER)
						clothes_s = new /icon(uniform_dmi, "secred_s")
						clothes_s.Blend(new /icon(feet_dmi, "jackboots"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "helmet"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-sec","securitypack")
					if(CHIEF)
						clothes_s = new /icon(uniform_dmi, "chief_s")
						clothes_s.Blend(new /icon(feet_dmi, "brown"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng","engiepack")
					if(ENGINEER)
						clothes_s = new /icon(uniform_dmi, "engine_s")
						clothes_s.Blend(new /icon(feet_dmi, "orange"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-eng","engiepack")
					if(ATMOSTECH)
						clothes_s = new /icon(uniform_dmi, "atmos_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(ROBOTICIST)
						clothes_s = new /icon(uniform_dmi, "robotics_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
						clothes_s.Blend(new /icon('icons/mob/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
						clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(AI)//Gives AI and borgs assistant-wear, so they can still customize their character
						clothes_s = new /icon(uniform_dmi, "grey_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")
					if(CYBORG)
						clothes_s = new /icon(uniform_dmi, "grey_s")
						clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
						clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")

		// Observers get tourist outfit.
		else
			clothes_s = new /icon(uniform_dmi, "tourist_s")
			clothes_s.Blend(new /icon(feet_dmi, "black"), ICON_UNDERLAY)
			clothes_s=blend_backpack(clothes_s,backbag,"satchel-norm")

		if(disabilities & NEARSIGHTED)
			preview_icon.Blend(new /icon('icons/mob/eyes.dmi', "glasses"), ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)
		if(clothes_s)
			preview_icon.Blend(clothes_s, ICON_OVERLAY)
		preview_icon_front = new(preview_icon, dir = SOUTH)
		preview_icon_side = new(preview_icon, dir = WEST)

		eyes_s = null
		clothes_s = null