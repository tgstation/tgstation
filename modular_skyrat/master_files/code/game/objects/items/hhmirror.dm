/obj/item/hhmirror
	name = "Handheld Mirror"
	desc = "A handheld mirror that allows you to change your looks."
	icon = 'modular_skyrat/master_files/icons/obj/hhmirror.dmi'
	icon_state = "hhmirror"

/obj/item/hhmirror/attack_self(mob/user)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("Damn, that hairstyle be looking skewed, maybe head to the barber for a change?"))

/obj/item/hhmirror/fullmagic
	name = "Full Handheld Magic Mirror"
	desc = "A handheld mirror that allows you to change your... self?" //Later, maybe add a charge to the description.
	icon = 'modular_skyrat/master_files/icons/obj/hhmirror.dmi'
	icon_state = "hhmirrormagic"
	var/list/races_blacklist = list(SPECIES_SKELETON, "agent", "angel", SPECIES_SYNTH_MILITARY, SPECIES_ZOMBIE, "clockwork golem servant", SPECIES_ANDROID, SPECIES_SYNTH, SPECIES_MUSHROOM, SPECIES_ZOMBIE_HALLOWEEN, "memezombie")
	var/list/choosable_races = list()

/obj/item/hhmirror/fullmagic/New()
	if(!choosable_races.len)
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = new speciestype()
			if(!(S.id in races_blacklist))
				choosable_races += S.id
	..()

/obj/item/hhmirror/fullmagic/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "race", "gender", "hair", "eyes")

	switch(choice)
		if("name")
			var/newname = reject_bad_name(stripped_input(H, "Who are we again?", "Name change", H.name, MAX_NAME_LEN))

			if(!newname)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

		if("race")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in choosable_races
			newrace = GLOB.species_list[racechoice]

			if(!newrace)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.set_species(newrace, icon_update=0)

			if(H.dna.species.use_skintones)
				var/new_s_tone = input(user, "Choose your skin tone:", "Race change")  as null|anything in GLOB.skin_tones

				if(new_s_tone)
					H.skin_tone = new_s_tone
					H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

			if(MUTCOLORS in H.dna.species.species_traits)
				var/new_mutantcolor = input(user, "Choose your skin color:", "Race change",H.dna.features["mcolor"]) as color|null
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)

					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
						H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)

					else
						to_chat(H, "<span class='notice'>Invalid color. Your color is not bright enough.</span>")

			H.update_body()
			H.update_hair()
			H.update_body_parts()
			H.update_mutations_overlay() // no hulk lizard

		if("gender")
			if(!(H.gender in list("male", "female"))) //blame the patriarchy
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(H.gender == "male")
				if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "female"
					to_chat(H, "<span class='notice'>Man, you feel like a woman!</span>")
				else
					return

			else
				if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "male"
					to_chat(H, "<span class='notice'>Whoa man, you feel like a man!</span>")
				else
					return
			H.dna.update_ui_block(DNA_GENDER_BLOCK)
			H.update_body()
			H.update_mutations_overlay() //(hulk male/female)

		if("hair")
			var/hairchoice = tgui_alert(H, "Hair style or hair color?", "Change Hair", list("Style", "Color"))
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(hairchoice == "Style") //So you just want to use a mirror then?
				..()
			else
				var/new_hair_color = input(H, "Choose your hair color", "Hair Color",H.hair_color) as color|null
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
					H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(H.gender == "male")
					var/new_face_color = input(H, "Choose your facial hair color", "Hair Color",H.facial_hair_color) as color|null
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
				H.update_hair()

		if(BODY_ZONE_PRECISE_EYES)
			var/new_eye_color = input(H, "Choose your eye color", "Eye Color",H.eye_color) as color|null
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_eye_color)
				var/n_color = sanitize_hexcolor(new_eye_color)
				var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
				if(eyes)
					eyes.eye_color = n_color
				H.eye_color = n_color
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.dna.species.handle_body()

/obj/item/hhmirror/wracemagic
	name = "Raceless Handheld Magic Mirror"
	desc = "A handheld mirror that allows you to change your... self?" //Later, maybe add a charge to the description.
	icon = 'modular_skyrat/master_files/icons/obj/hhmirror.dmi'
	icon_state = "hhmirrormagic"
	var/charges = 4

/obj/item/hhmirror/wracemagic/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(!charges == 0) // Later, should also have a lock
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "gender", "hair", "eyes")

		switch(choice)
			if("name")
				var/newname = reject_bad_name(stripped_input(H, "Who are we again?", "Name change", H.name, MAX_NAME_LEN))

				if(!newname)
					return
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				H.real_name = newname
				H.name = newname
				if(H.dna)
					H.dna.real_name = newname
				if(H.mind)
					H.mind.name = newname

			if("gender")
				if(!(H.gender in list("male", "female"))) //blame the patriarchy
					return
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(H.gender == "male")
					if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
						H.gender = "female"
						to_chat(H, "<span class='notice'>Man, you feel like a woman!</span>")
					else
						return

				else
					if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
						H.gender = "male"
						to_chat(H, "<span class='notice'>Whoa man, you feel like a man!</span>")
					else
						return
				H.dna.update_ui_block(DNA_GENDER_BLOCK)
				H.update_body()
				H.update_mutations_overlay() //(hulk male/female)

			if("hair")
				var/hairchoice = tgui_alert(H, "Hair style or hair color?", "Change Hair", list("Style", "Color"))
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(hairchoice == "Style") //So you just want to use a mirror then?
					..()
				else
					var/new_hair_color = input(H, "Choose your hair color", "Hair Color",H.hair_color) as color|null
					if(new_hair_color)
						H.hair_color = sanitize_hexcolor(new_hair_color)
						H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
					if(H.gender == "male")
						var/new_face_color = input(H, "Choose your facial hair color", "Hair Color",H.facial_hair_color) as color|null
						if(new_face_color)
							H.facial_hair_color = sanitize_hexcolor(new_face_color)
							H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
					H.update_hair()

			if(BODY_ZONE_PRECISE_EYES)
				var/new_eye_color = input(H, "Choose your eye color", "Eye Color",H.eye_color) as color|null
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_eye_color)
					var/n_color = sanitize_hexcolor(new_eye_color)
					var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
					if(eyes)
						eyes.eye_color = n_color
					H.eye_color = n_color
					H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
					H.dna.species.handle_body()
		charges--
	if(charges == 0)
		qdel(src)
		to_chat(user, "The mirror crumbles to dust within your hands.")
