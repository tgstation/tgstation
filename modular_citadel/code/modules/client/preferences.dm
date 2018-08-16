#define DEFAULT_SLOT_AMT	2
#define HANDS_SLOT_AMT		2
#define BACKPACK_SLOT_AMT	4

/datum/preferences
	//gear
	var/gear_points = 10
	var/list/gear_categories
	var/list/chosen_gear
	var/gear_tab

	//pref vars
	var/screenshake = 100
	var/damagescreenshake = 2
	var/arousable = TRUE
	var/widescreenpref = TRUE
	var/autostand = TRUE

	//vore prefs
	var/toggleeatingnoise = TRUE
	var/toggledigestionnoise = TRUE
	var/hound_sleeper = TRUE
	var/cit_toggles = TOGGLES_CITADEL

	// stuff that was in base
	max_save_slots = 10
	features = list("mcolor" = "FFF",
		"tail_lizard" = "Smooth",
		"tail_human" = "None",
		"snout" = "Round",
		"horns" = "None",
		"ears" = "None",
		"wings" = "None",
		"frills" = "None",
		"spines" = "None",
		"body_markings" = "None",
		"legs" = "Normal Legs",
		"moth_wings" = "Plain",
		"mcolor2" = "FFF",
		"mcolor3" = "FFF",
		"mam_body_markings" = "None",
		"mam_ears" = "None",
		"mam_tail" = "None",
		"mam_tail_animated" = "None",
		"xenodorsal" = "None",
		"xenohead" = "None",
		"xenotail" = "None",
		"taur" = "None",
		"exhibitionist" = FALSE,
		"genitals_use_skintone" = FALSE,
		"has_cock" = FALSE,
		"cock_shape" = "Human",
		"cock_length" = 6,
		"cock_girth_ratio" = COCK_GIRTH_RATIO_DEF,
		"cock_color" = "fff",
		"has_sheath" = FALSE,
		"sheath_color" = "fff",
		"has_balls" = FALSE,
		"balls_internal" = FALSE,
		"balls_color" = "fff",
		"balls_amount" = 2,
		"balls_sack_size" = BALLS_SACK_SIZE_DEF,
		"balls_size" = BALLS_SIZE_DEF,
		"balls_cum_rate" = CUM_RATE,
		"balls_cum_mult" = CUM_RATE_MULT,
		"balls_efficiency" = CUM_EFFICIENCY,
		"balls_fluid" = "semen",
		"has_ovi" = FALSE,
		"ovi_shape" = "knotted",
		"ovi_length" = 6,
		"ovi_color" = "fff",
		"has_eggsack" = FALSE,
		"eggsack_internal" = TRUE,
		"eggsack_color" = "fff",
		"eggsack_size" = BALLS_SACK_SIZE_DEF,
		"eggsack_egg_color" = "fff",
		"eggsack_egg_size" = EGG_GIRTH_DEF,
		"has_breasts" = FALSE,
		"breasts_color" = "fff",
		"breasts_size" = "C",
		"breasts_shape" = "Pair",
		"breasts_fluid" = "milk",
		"has_vag" = FALSE,
		"vag_shape" = "Human",
		"vag_color" = "fff",
		"vag_clits" = 1,
		"vag_clit_diam" = 0.25,
		"has_womb" = FALSE,
		"womb_cum_rate" = CUM_RATE,
		"womb_cum_mult" = CUM_RATE_MULT,
		"womb_efficiency" = CUM_EFFICIENCY,
		"womb_fluid" = "femcum",
		"ipc_screen" = "Sunburst",
		"ipc_antenna" = "None",
		"flavor_text" = ""
		)

/datum/preferences/New(client/C)
	..()
	LAZYINITLIST(chosen_gear)

/datum/preferences/proc/citadel_dat_replace(current_tab)
	var/mob/user
	//This proc is for menus other than game pref and char pref
	. = "<center>"
	. += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a>"
	. += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>Character Appearance</a>"
	. += "<a href='?_src_=prefs;preference=tab;tab=3' [current_tab == 3 ? "class='linkOn'" : ""]>Loadout</a>"
	. += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"

	if(!path)
		. += "<div class='notice'>Please create an account to save your preferences</div>"

	. += "</center>"

	. += "<HR>"

	//Character Appearance
	if(current_tab == 2)
		update_preview_icon(nude=TRUE)
		user << browse_rsc(preview_icon, "previewicon.png")
		. += "<table><tr><td width='340px' height='300px' valign='top'>"
		. += "<div class='statusDisplay'><center><img src=previewicon.png width=[preview_icon.Width()] height=[preview_icon.Height()]></center></div>"
		. += "<a href='?_src_=prefs;preference=flavor_text;task=input'><b>Set Flavor Text</b></a><br>"
		if(lentext(features["flavor_text"]) <= 40)
			if(!lentext(features["flavor_text"]))
				. += "\[...\]"
			else
				. += "[features["flavor_text"]]"
		else
			. += "[TextPreview(features["flavor_text"])]...<BR>"
		. += "<h2>Body</h2>"
		. += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : "Female"]</a><BR>"
		. += "<b>Species:</b><a href='?_src_=prefs;preference=species;task=input'>[pref_species.id]</a><BR>"
		. += "<a href='?_src_=prefs;preference=all;task=random'>Random Body</A><BR>"
		. += "<a href='?_src_=prefs;preference=all'>Always Random Body: [be_random_body ? "Yes" : "No"]</A><BR>"
		if((MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))
			. += "<b>Primary Color: </b><span style='border: 1px solid #161616; background-color: #[features["mcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color;task=input'>Change</a><BR>"
			. += "<b>Secondary Color: </b><span style='border: 1px solid #161616; background-color: #[features["mcolor2"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color2;task=input'>Change</a><BR>"
			. += "<b>Tertiary Color: </b><span style='border: 1px solid #161616; background-color: #[features["mcolor3"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color3;task=input'>Change</a><BR>"
		if(pref_species.use_skintones)
			. += "<b>Skin Tone: </b><a href='?_src_=prefs;preference=s_tone;task=input'>[skin_tone]</a><BR>"
			. += "<b>Genitals Use Skintone:</b><a href='?_src_=prefs;preference=genital_colour'>[features["genitals_use_skintone"] == TRUE ? "Enabled" : "Disabled"]</a><BR>"

		if(HAIR in pref_species.species_traits)
			. += "<b>Hair Style: </b><a href='?_src_=prefs;preference=hair_style;task=input'>[hair_style]</a><BR>"
			. += "<b>Hair Color: </b><span style='border:1px solid #161616; background-color: #[hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a><BR>"
			. += "<b>Facial Hair Style: </b><a href='?_src_=prefs;preference=facial_hair_style;task=input'>[facial_hair_style]</a><BR>"
			. += "<b>Facial Hair Color: </b><span style='border: 1px solid #161616; background-color: #[facial_hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a><BR>"
		if(EYECOLOR in pref_species.species_traits)
			. += "<b>Eye Color: </b><span style='border: 1px solid #161616; background-color: #[eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>"
		if("tail_lizard" in pref_species.mutant_bodyparts)
			. += "<b>Tail: </b><a href='?_src_=prefs;preference=tail_lizard;task=input'>[features["tail_lizard"]]</a><BR>"
		else if("mam_tail" in pref_species.mutant_bodyparts)
			. += "<b>Tail: </b><a href='?_src_=prefs;preference=mam_tail;task=input'>[features["mam_tail"]]</a><BR>"
		else if("tail_human" in pref_species.mutant_bodyparts)
			. += "<b>Tail: </b><a href='?_src_=prefs;preference=tail_human;task=input'>[features["tail_human"]]</a><BR>"
		if("snout" in pref_species.mutant_bodyparts)
			. += "<b>Snout: </b><a href='?_src_=prefs;preference=snout;task=input'>[features["snout"]]</a><BR>"
		if("horns" in pref_species.mutant_bodyparts)
			. += "<b>Horns: </b><a href='?_src_=prefs;preference=horns;task=input'>[features["horns"]]</a><BR>"
		if("frills" in pref_species.mutant_bodyparts)
			. += "<b>Frills: </b><a href='?_src_=prefs;preference=frills;task=input'>[features["frills"]]</a><BR>"
		if("spines" in pref_species.mutant_bodyparts)
			. += "<b>Spines: </b><a href='?_src_=prefs;preference=spines;task=input'>[features["spines"]]</a><BR>"
		if("body_markings" in pref_species.mutant_bodyparts)
			. += "<b>Body Markings: </b><a href='?_src_=prefs;preference=body_markings;task=input'>[features["body_markings"]]</a><BR>"
		else if("mam_body_markings" in pref_species.mutant_bodyparts)
			. += "<b>Body Markings: </b><a href='?_src_=prefs;preference=mam_body_markings;task=input'>[features["mam_body_markings"]]</a><BR>"
		if("mam_ears" in pref_species.mutant_bodyparts)
			. += "<b>Ears: </b><a href='?_src_=prefs;preference=mam_ears;task=input'>[features["mam_ears"]]</a><BR>"
		else if("ears" in pref_species.mutant_bodyparts)
			. += "<b>Ears: </b><a href='?_src_=prefs;preference=ears;task=input'>[features["ears"]]</a><BR>"
		if("legs" in pref_species.mutant_bodyparts)
			. += "<b>Legs: </b><a href='?_src_=prefs;preference=legs;task=input'>[features["legs"]]</a><BR>"
		if("moth_wings" in pref_species.mutant_bodyparts)
			. += "<b>Moth wings</b><a href='?_src_=prefs;preference=moth_wings;task=input'>[features["moth_wings"]]</a><BR>"
		if("taur" in pref_species.mutant_bodyparts)
			. += "<b>Taur: </b><a href='?_src_=prefs;preference=taur;task=input'>[features["taur"]]</a><BR>"
		if("wings" in pref_species.mutant_bodyparts && GLOB.r_wings_list.len >1)
			. += "<b>Wings: </b><a href='?_src_=prefs;preference=wings;task=input'>[features["wings"]]</a><BR>"
		if("xenohead" in pref_species.mutant_bodyparts)
			. += "<b>Caste: </b><a href='?_src_=prefs;preference=xenohead;task=input'>[features["xenohead"]]</a><BR>"
		if("xenotail" in pref_species.mutant_bodyparts)
			. += "<b>Tail: </b><a href='?_src_=prefs;preference=xenotail;task=input'>[features["xenotail"]]</a><BR>"
		if("xenodorsal" in pref_species.mutant_bodyparts)
			. += "<b>Dorsal Tubes: </b><a href='?_src_=prefs;preference=xenodorsal;task=input'>[features["xenodorsal"]]</a><BR>"
		if("ipc_screen" in pref_species.mutant_bodyparts)
			. += "<b>Screen:</b><a href='?_src_=prefs;preference=ipc_screen;task=input'>[features["ipc_screen"]]</a><BR>"
		if("ipc_antenna" in pref_species.mutant_bodyparts)
			. += "<b>Antenna:</b><a href='?_src_=prefs;preference=ipc_antenna;task=input'>[features["ipc_antenna"]]</a><BR>"

		. += "</td><td width='300px' height='300px' valign='top'>"

		. += "<h2>Clothing & Equipment</h2>"

		. += "<b>Underwear:</b><a href ='?_src_=prefs;preference=underwear;task=input'>[underwear]</a><br>"
		. += "<b>Undershirt:</b><a href ='?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a><br>"
		. += "<b>Socks:</b><a href ='?_src_=prefs;preference=socks;task=input'>[socks]</a><br>"
		. += "<b>Backpack:</b><a href ='?_src_=prefs;preference=bag;task=input'>[backbag]</a><br>"
		. += "<b>Uplink Location:</b><a href ='?_src_=prefs;preference=uplink_loc;task=input'>[uplink_spawn_loc]</a><br>"

		. += "<h2>Genitals</h2>"
		if(NOGENITALS in pref_species.species_traits)
			. += "<b>Your species ([pref_species.name]) does not support genitals!</b><br>"
		else
			. += "<b>Has Penis:</b><a href='?_src_=prefs;preference=has_cock'>[features["has_cock"] == TRUE ? "Yes" : "No"]</a><BR>"
			if(features["has_cock"] == TRUE)
				if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
					. += "<b>Penis Color:</b><span style='border: 1px solid #161616; background-color: #[skintone2hex(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<BR>"
				else
					. += "<b>Penis Color:</b><span style='border: 1px solid #161616; background-color: #[features["cock_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=cock_color;task=input'>Change</a><BR>"
				. += "<b>Penis Shape:</b> <a href='?_src_=prefs;preference=cock_shape;task=input'>[features["cock_shape"]]</a><BR>"
				. += "<b>Penis Length:</b> <a href='?_src_=prefs;preference=cock_length;task=input'>[features["cock_length"]] inch(es)</a><BR>"
				. += "<b>Has Testicles:</b><a href='?_src_=prefs;preference=has_balls'>[features["has_balls"] == TRUE ? "Yes" : "No"]</a><BR>"
				if(features["has_balls"] == TRUE)
					if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
						. += "<b>Testicles Color:</b><span style='border: 1px solid #161616; background-color: #[skintone2hex(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<BR>"
					else
						. += "<b>Testicles Color:</b><span style='border: 1px solid #161616; background-color: #[features["balls_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=balls_color;task=input'>Change</a><BR>"
			. += "<b>Has Vagina:</b><a href='?_src_=prefs;preference=has_vag'>[features["has_vag"] == TRUE ? "Yes" : "No"]</a><BR>"
			if(features["has_vag"])
				. += "<b>Vagina Type:</b> <a href='?_src_=prefs;preference=vag_shape;task=input'>[features["vag_shape"]]</a><BR>"
				if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
					. += "<b>Vagina Color:</b><span style='border: 1px solid #161616; background-color: #[skintone2hex(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<BR>"
				else
					. += "<b>Vagina Color:</b><span style='border: 1px solid #161616; background-color: #[features["vag_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=vag_color;task=input'>Change</a><BR>"
				. += "<b>Has Womb:</b><a href='?_src_=prefs;preference=has_womb'>[features["has_womb"] == TRUE ? "Yes" : "No"]</a><BR>"
			. += "<b>Has Breasts:</b><a href='?_src_=prefs;preference=has_breasts'>[features["has_breasts"] == TRUE ? "Yes" : "No"]</a><BR>"
			if(features["has_breasts"])
				if(pref_species.use_skintones && features["genitals_use_skintone"] == TRUE)
					. += "<b>Color:</b><span style='border: 1px solid #161616; background-color: #[skintone2hex(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<BR>"
				else
					. += "<b>Color:</b><span style='border: 1px solid #161616; background-color: #[features["breasts_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=breasts_color;task=input'>Change</a><BR>"
				. += "<b>Cup Size:</b><a href='?_src_=prefs;preference=breasts_size;task=input'>[features["breasts_size"]]</a><br>"
				. += "<b>Breast Shape:</b><a href='?_src_=prefs;preference=breasts_shape;task=input'>[features["breasts_shape"]]</a><br>"
			/*
			. += "<h3>Ovipositor</h3>"
			. += "<b>Has Ovipositor:</b><a href='?_src_=prefs;preference=has_ovi'>[features["has_ovi"] == TRUE ? "Yes" : "No"]</a>"
			if(features["has_ovi"])
				. += "<b>Ovi Color:</b><span style='border: 1px solid #161616; background-color: #[features["ovi_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ovi_color;task=input'>Change</a>"
				. += "<h3>Eggsack</h3>"
				. += "<b>Has Eggsack:</b><a href='?_src_=prefs;preference=has_eggsack'>[features["has_eggsack"] == TRUE ? "Yes" : "No"]</a><BR>"
				if(features["has_eggsack"] == TRUE)
					. += "<b>Color:</b><span style='border: 1px solid #161616; background-color: #[features["eggsack_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eggsack_color;task=input'>Change</a>"
					. += "<b>Egg Color:</b><span style='border: 1px solid #161616; background-color: #[features["eggsack_egg_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=egg_color;task=input'>Change</a>"
					. += "<b>Egg Size:</b><a href='?_src_=prefs;preference=egg_size;task=input'>[features["eggsack_egg_size"]]\" Diameter</a>"
			. += "</td>"
			*/
			. += "</td></tr></table>"

/datum/preferences/proc/process_citadel_link(mob/user, list/href_list)
	if("input")
		switch(href_list["preference"])
			if("flavor_text")
				var/msg = stripped_multiline_input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(features["flavor_text"]), MAX_MESSAGE_LEN*2, TRUE) as null|message
				if(!isnull(msg))
					msg = copytext(msg, 1, MAX_MESSAGE_LEN*2)
					features["flavor_text"] = msg

			if("hair")
				var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference","#"+hair_color) as color|null
				if(new_hair)
					hair_color = sanitize_hexcolor(new_hair)

			if("hair_style")
				var/new_hair_style
				if(gender == MALE)
					new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_male_list
				else
					new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_female_list
				if(new_hair_style)
					hair_style = new_hair_style

			if("next_hair_style")
				if (gender == MALE)
					hair_style = next_list_item(hair_style, GLOB.hair_styles_male_list)
				else
					hair_style = next_list_item(hair_style, GLOB.hair_styles_female_list)

			if("previous_hair_style")
				if (gender == MALE)
					hair_style = previous_list_item(hair_style, GLOB.hair_styles_male_list)
				else
					hair_style = previous_list_item(hair_style, GLOB.hair_styles_female_list)

			if("facial")
				var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference","#"+facial_hair_color) as color|null
				if(new_facial)
					facial_hair_color = sanitize_hexcolor(new_facial)
				if("facial_hair_style")
					var/new_facial_hair_style
					if(gender == MALE)
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_male_list
					else
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_female_list
					if(new_facial_hair_style)
						facial_hair_style = new_facial_hair_style

			if("next_facehair_style")
				if (gender == MALE)
					facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_male_list)
				else
					facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_female_list)
				if("previous_facehair_style")
					if (gender == MALE)
						facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_male_list)
					else
						facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_female_list)

			if("underwear")
				var/new_underwear
				if(gender == MALE)
					new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_m
				else
					new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in GLOB.underwear_f
				if(new_underwear)
					underwear = new_underwear

			if("undershirt")
				var/new_undershirt
				if(gender == MALE)
					new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_m
				else
					new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in GLOB.undershirt_f
				if(new_undershirt)
					undershirt = new_undershirt

			if("socks")
				var/new_socks
				new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in GLOB.socks_list
				if(new_socks)
					socks = new_socks

			if("eyes")
				var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference","#"+eye_color) as color|null
				if(new_eyes)
					eye_color = sanitize_hexcolor(new_eyes)

			if("species")
				var/result = input(user, "Select a species", "Species Selection") as null|anything in GLOB.roundstart_races
				if(result)
					var/newtype = GLOB.species_list[result]
					pref_species = new newtype()
					//Now that we changed our species, we must verify that the mutant colour is still allowed.
					var/temp_hsv = RGBtoHSV(features["mcolor"])
					if(features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
						features["mcolor"] = pref_species.default_color
					if(features["mcolor2"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
						features["mcolor2"] = pref_species.default_color
					if(features["mcolor3"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#202020")[3]))
						features["mcolor3"] = pref_species.default_color

			if("mutant_color")
				var/new_mutantcolor = input(user, "Choose your character's alien/mutant color:", "Character Preference","#"+features["mcolor"]) as color|null
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)
					if(new_mutantcolor == "#000000")
						features["mcolor"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3]) // mutantcolors must be bright, but only if they affect the skin
						features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
					else
						to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

			if("mutant_color2")
				var/new_mutantcolor = input(user, "Choose your character's secondary alien/mutant color:", "Character Preference") as color|null
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)
					if(new_mutantcolor == "#000000")
						features["mcolor2"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3]) // mutantcolors must be bright, but only if they affect the skin
						features["mcolor2"] = sanitize_hexcolor(new_mutantcolor)
					else
						to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

			if("mutant_color3")
				var/new_mutantcolor = input(user, "Choose your character's tertiary alien/mutant color:", "Character Preference") as color|null
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)
					if(new_mutantcolor == "#000000")
						features["mcolor3"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3]) // mutantcolors must be bright, but only if they affect the skin
						features["mcolor3"] = sanitize_hexcolor(new_mutantcolor)
					else
						to_chat(user, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")

			if("ipc_screen")
				var/new_ipc_screen
				new_ipc_screen = input(user, "Choose your character's screen:", "Character Preference") as null|anything in GLOB.ipc_screens_list
				if(new_ipc_screen)
					features["ipc_screen"] = new_ipc_screen

			if("ipc_antenna")
				var/new_ipc_antenna
				new_ipc_antenna = input(user, "Choose your character's antenna:", "Character Preference") as null|anything in GLOB.ipc_antennas_list
				if(new_ipc_antenna)
					features["ipc_antenna"] = new_ipc_antenna

			if("tail_lizard")
				var/new_tail
				new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_lizard
				if(new_tail)
					features["tail_lizard"] = new_tail
					if(new_tail != "None")
						features["taur"] = "None"

			if("tail_human")
				var/list/snowflake_tails_list = list("Normal" = null)
				for(var/path in GLOB.tails_list_human)
					var/datum/sprite_accessory/tails/human/instance = GLOB.tails_list_human[path]
					if(istype(instance, /datum/sprite_accessory))
						var/datum/sprite_accessory/S = instance
						if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
							snowflake_tails_list[S.name] = path
				var/new_tail
				new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in snowflake_tails_list
				if(new_tail)
					features["tail_human"] = new_tail
					if(new_tail != "None")
						features["taur"] = "None"

			if("mam_tail")
				var/list/snowflake_tails_list = list("Normal" = null)
				for(var/path in GLOB.mam_tails_list)
					var/datum/sprite_accessory/mam_tails/instance = GLOB.mam_tails_list[path]
					if(istype(instance, /datum/sprite_accessory))
						var/datum/sprite_accessory/S = instance
						if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
							snowflake_tails_list[S.name] = path
				var/new_tail
				new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in snowflake_tails_list
				if(new_tail)
					features["mam_tail"] = new_tail
					if(new_tail != "None")
						features["taur"] = "None"

			if("snout")
				var/new_snout
				new_snout = input(user, "Choose your character's snout:", "Character Preference") as null|anything in GLOB.snouts_list
				if(new_snout)
					features["snout"] = new_snout

			if("horns")
				var/new_horns
				new_horns = input(user, "Choose your character's horns:", "Character Preference") as null|anything in GLOB.horns_list
				if(new_horns)
					features["horns"] = new_horns

			if("ears")
				var/new_ears
				new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in GLOB.ears_list
				if(new_ears)
					features["ears"] = new_ears

			if("wings")
				var/new_wings
				new_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.r_wings_list
				if(new_wings)
					features["wings"] = new_wings

			if("frills")
				var/new_frills
				new_frills = input(user, "Choose your character's frills:", "Character Preference") as null|anything in GLOB.frills_list
				if(new_frills)
					features["frills"] = new_frills

			if("spines")
				var/new_spines
				new_spines = input(user, "Choose your character's spines:", "Character Preference") as null|anything in GLOB.spines_list
				if(new_spines)
					features["spines"] = new_spines

			if("body_markings")
				var/new_body_markings
				new_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in GLOB.body_markings_list
				if(new_body_markings)
					features["body_markings"] = new_body_markings

			if("legs")
				var/new_legs
				new_legs = input(user, "Choose your character's legs:", "Character Preference") as null|anything in GLOB.legs_list
				if(new_legs)
					features["legs"] = new_legs

			if("moth_wings")
				var/new_moth_wings
				new_moth_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.moth_wings_list
				if(new_moth_wings)
					features["moth_wings"] = new_moth_wings

			if("s_tone")
				var/new_s_tone = input(user, "Choose your character's skin-tone:", "Character Preference")  as null|anything in GLOB.skin_tones
				if(new_s_tone)
					skin_tone = new_s_tone

			if("taur")
				var/list/snowflake_taur_list = list("Normal" = null)
				for(var/path in GLOB.taur_list)
					var/datum/sprite_accessory/taur/instance = GLOB.taur_list[path]
					if(istype(instance, /datum/sprite_accessory))
						var/datum/sprite_accessory/S = instance
						if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
							snowflake_taur_list[S.name] = path
				var/new_taur
				new_taur = input(user, "Choose your character's tauric body:", "Character Preference") as null|anything in snowflake_taur_list
				if(new_taur)
					features["taur"] = new_taur
					if(new_taur != "None")
						features["mam_tail"] = "None"
						features["xenotail"] = "None"

			if("ears")
				var/list/snowflake_ears_list = list("Normal" = null)
				for(var/path in GLOB.ears_list)
					var/datum/sprite_accessory/ears/instance = GLOB.ears_list[path]
					if(istype(instance, /datum/sprite_accessory))
						var/datum/sprite_accessory/S = instance
						if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
							snowflake_ears_list[S.name] = path
				var/new_ears
				new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in snowflake_ears_list
				if(new_ears)
					features["ears"] = new_ears

			if("mam_ears")
				var/list/snowflake_ears_list = list("Normal" = null)
				for(var/path in GLOB.mam_ears_list)
					var/datum/sprite_accessory/mam_ears/instance = GLOB.mam_ears_list[path]
					if(istype(instance, /datum/sprite_accessory))
						var/datum/sprite_accessory/S = instance
						if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
							snowflake_ears_list[S.name] = path
				var/new_ears
				new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in snowflake_ears_list
				if(new_ears)
					features["mam_ears"] = new_ears

			if("mam_body_markings")
				var/list/snowflake_markings_list = list("Normal" = null)
				for(var/path in GLOB.mam_body_markings_list)
					var/datum/sprite_accessory/mam_body_markings/instance = GLOB.mam_body_markings_list[path]
					if(istype(instance, /datum/sprite_accessory))
						var/datum/sprite_accessory/S = instance
						if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
							snowflake_markings_list[S.name] = path
				var/new_mam_body_markings
				new_mam_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in snowflake_markings_list
				if(new_mam_body_markings)
					features["mam_body_markings"] = new_mam_body_markings

			//Xeno Bodyparts
			if("xenohead")//Head or caste type
				var/new_head
				new_head = input(user, "Choose your character's caste:", "Character Preference") as null|anything in GLOB.xeno_head_list
				if(new_head)
					features["xenohead"] = new_head

			if("xenotail")//Currently one one type, more maybe later if someone sprites them. Might include animated variants in the future.
				var/new_tail
				new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.xeno_tail_list
				if(new_tail)
					features["xenotail"] = new_tail

			if("xenodorsal")
				var/new_dors
				new_dors = input(user, "Choose your character's dorsal tube type:", "Character Preference") as null|anything in GLOB.xeno_dorsal_list
				if(new_dors)
					features["xenodorsal"] = new_dors
			//Genital code
			if("cock_color")
				var/new_cockcolor = input(user, "Penis color:", "Character Preference") as color|null
				if(new_cockcolor)
					var/temp_hsv = RGBtoHSV(new_cockcolor)
					if(new_cockcolor == "#000000")
						features["cock_color"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3])
						features["cock_color"] = sanitize_hexcolor(new_cockcolor)
					else
						user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

			if("cock_length")
				var/new_length = input(user, "Penis length in inches:\n([COCK_SIZE_MIN]-[COCK_SIZE_MAX])", "Character Preference") as num|null
				if(new_length)
					features["cock_length"] = max(min( round(text2num(new_length)), COCK_SIZE_MAX),COCK_SIZE_MIN)

			if("cock_shape")
				var/new_shape
				new_shape = input(user, "Penis shape:", "Character Preference") as null|anything in GLOB.cock_shapes_list
				if(new_shape)
					features["cock_shape"] = new_shape

			if("balls_color")
				var/new_ballscolor = input(user, "Testicle Color:", "Character Preference") as color|null
				if(new_ballscolor)
					var/temp_hsv = RGBtoHSV(new_ballscolor)
					if(new_ballscolor == "#000000")
						features["balls_color"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3])
						features["balls_color"] = sanitize_hexcolor(new_ballscolor)
					else
						user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

			if("egg_size")
				var/new_size
				var/list/egg_sizes = list(1,2,3)
				new_size = input(user, "Egg Diameter(inches):", "Egg Size") as null|anything in egg_sizes
				if(new_size)
					features["eggsack_egg_size"] = new_size

			if("egg_color")
				var/new_egg_color = input(user, "Egg Color:", "Character Preference") as color|null
				if(new_egg_color)
					var/temp_hsv = RGBtoHSV(new_egg_color)
					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3])
						features["eggsack_egg_color"] = sanitize_hexcolor(new_egg_color)
					else
						user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

			if("breasts_size")
				var/new_size
				new_size = input(user, "Breast Size", "Character Preference") as null|anything in GLOB.breasts_size_list
				if(new_size)
					features["breasts_size"] = new_size

			if("breasts_shape")
				var/new_shape
				new_shape = input(user, "Breast Shape", "Character Preference") as null|anything in GLOB.breasts_shapes_list
				if(new_shape)
					features["breasts_shape"] = new_shape

			if("breasts_color")
				var/new_breasts_color = input(user, "Breast Color:", "Character Preference") as color|null
				if(new_breasts_color)
					var/temp_hsv = RGBtoHSV(new_breasts_color)
					if(new_breasts_color == "#000000")
						features["breasts_color"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3])
						features["breasts_color"] = sanitize_hexcolor(new_breasts_color)
					else
						user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

			if("vag_shape")
				var/new_shape
				new_shape = input(user, "Vagina Type", "Character Preference") as null|anything in GLOB.vagina_shapes_list
				if(new_shape)
					features["vag_shape"] = new_shape

			if("vag_color")
				var/new_vagcolor = input(user, "Vagina color:", "Character Preference") as color|null
				if(new_vagcolor)
					var/temp_hsv = RGBtoHSV(new_vagcolor)
					if(new_vagcolor == "#000000")
						features["vag_color"] = pref_species.default_color
					else if((MUTCOLORS_PARTSONLY in pref_species.species_traits) || ReadHSV(temp_hsv)[3] >= ReadHSV("#202020")[3])
						features["vag_color"] = sanitize_hexcolor(new_vagcolor)
					else
						user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

/datum/preferences/proc/is_loadout_slot_available(slot)
	var/list/L
	LAZYINITLIST(L)
	for(var/i in chosen_gear)
		var/datum/gear/G = i
		var/occupied_slots = L[slot_to_string(initial(G.category))] ? L[slot_to_string(initial(G.category))] + 1 : 1
		LAZYSET(L, slot_to_string(initial(G.category)), occupied_slots)
	switch(slot)
		if(SLOT_IN_BACKPACK)
			if(L[slot_to_string(SLOT_IN_BACKPACK)] < BACKPACK_SLOT_AMT)
				return TRUE
		if(SLOT_HANDS)
			if(L[slot_to_string(SLOT_HANDS)] < HANDS_SLOT_AMT)
				return TRUE
		else
			if(L[slot_to_string(slot)] < DEFAULT_SLOT_AMT)
				return TRUE

datum/preferences/copy_to(mob/living/carbon/human/character, icon_updates = 1)
	..()
	character.give_genitals(TRUE)
	character.flavor_text = features["flavor_text"] //Let's update their flavor_text at least initially
	character.canbearoused = arousable
	if(icon_updates)
		character.update_genitals()
