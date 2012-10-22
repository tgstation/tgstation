
/obj/effect/datacore/proc/manifest(var/nosleep = 0)
	spawn()
		if(!nosleep)
			sleep(40)
		for(var/mob/living/carbon/human/H in player_list)
			manifest_inject(H)
		return

/obj/effect/datacore/proc/manifest_modify(var/name, var/assignment, var/alt_title = null)
	var/datum/data/record/foundrecord

	for(var/datum/data/record/t in data_core.general)
		if (t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
	if(alt_title)
		foundrecord.fields["real_rank"] = alt_title
	else
		foundrecord.fields["real_rank"] = assignment



/obj/effect/datacore/proc/manifest_inject(var/mob/living/carbon/human/H)
	if(H.mind && (H.mind.assigned_role != "MODE"))
		var/assignment
		if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		var/id = add_zero(num2hex(rand(1, 1.6777215E7)), 6)	//this was the best they could come up with? A large random number? *sigh*


		//General Record
		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["real_rank"]	= H.mind.assigned_role
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		G.fields["fingerprint"]	= md5(H.dna.uni_identity)
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= H.gender
		G.fields["species"]		= H.get_species()
		G.fields["photo"]		= get_id_photo(H)
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["b_type"]		= H.b_type
		M.fields["b_dna"]		= H.dna.unique_enzymes
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		M.fields["notes"]		= "No notes."
		medical += M

		//Security Record
		var/datum/data/record/S = new()
		S.fields["id"]			= id
		S.fields["name"]		= H.real_name
		S.fields["criminal"]	= "None"
		S.fields["mi_crim"]		= "None"
		S.fields["mi_crim_d"]	= "No minor crime convictions."
		S.fields["ma_crim"]		= "None"
		S.fields["ma_crim_d"]	= "No major crime convictions."
		S.fields["notes"]		= "No notes."
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")
		L.fields["name"]		= H.real_name
		L.fields["rank"] = H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= H.gender
		L.fields["b_type"]		= H.b_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["enzymes"]		= H.dna.struc_enzymes
		L.fields["identity"]	= H.dna.uni_identity
		L.fields["image"]		= getFlatIcon(H,0)	//This is god-awful
		locked += L
	return


proc/get_id_photo(var/mob/living/carbon/human/H)
	var/icon/preview_icon = null

	var/g = "m"
	if (H.gender == FEMALE)
		g = "f"
	switch(H.get_species())
		if("Tajaran")
			preview_icon = new /icon('icons/effects/species.dmi', "tajaran_[g]_s")
			preview_icon.Blend(new /icon('icons/effects/species.dmi', "tajtail_s"), ICON_OVERLAY)
		if( "Soghun")
			preview_icon = new /icon('icons/effects/species.dmi', "lizard_[g]_s")
			preview_icon.Blend(new /icon('icons/effects/species.dmi', "sogtail_s"), ICON_OVERLAY)
		if("Skrell")
			preview_icon = new /icon('icons/effects/species.dmi', "skrell_[g]_s")
		else
			preview_icon = new /icon('human.dmi', "torso_[g]_s")
			preview_icon.Blend(new /icon('human.dmi', "chest_[g]_s"), ICON_OVERLAY)
			preview_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)
			preview_icon.Blend(new /icon('human.dmi', "head_[g]_s"), ICON_OVERLAY)

			for(var/datum/organ/external/E in H.organs)
				if(E.status & ORGAN_CUT_AWAY) continue

				var/icon/temp = new /icon('human.dmi', "[E.name]_s")
				if(E.status & ORGAN_ROBOT)
					temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))

				preview_icon.Blend(temp, ICON_OVERLAY)

	// Skin tone
	if(H.get_species() == "Human")
		if (H.s_tone >= 0)
			preview_icon.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s")
	eyes_s.Blend(rgb(H.r_eyes, H.g_eyes, H.b_eyes), ICON_ADD)

	var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		hair_s.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
	if(facial_hair_style)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		facial_s.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/clothes_s = null
	switch(H.mind.assigned_role)
		if("Head of Personnel")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hop_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Bartender")
			clothes_s = new /icon('icons/mob/uniform.dmi', "ba_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Botanist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hydroponics_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Chef")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Janitor")
			clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Librarian")
			clothes_s = new /icon('icons/mob/uniform.dmi', "red_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Quartermaster")
			clothes_s = new /icon('icons/mob/uniform.dmi', "qm_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Cargo Technician")
			clothes_s = new /icon('icons/mob/uniform.dmi', "cargotech_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Shaft Miner")
			clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Lawyer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "lawyer_blue_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Chaplain")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chapblack_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Research Director")
			clothes_s = new /icon('icons/mob/uniform.dmi', "director_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if("Scientist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "toxinswhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
		if("Chemist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
		if("Chief Medical Officer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "cmo_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
		if("Medical Doctor")
			clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if("Geneticist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "geneticswhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
		if("Virologist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "virologywhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
		if("Captain")
			clothes_s = new /icon('icons/mob/uniform.dmi', "captain_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Head of Security")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hosred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Warden")
			clothes_s = new /icon('icons/mob/uniform.dmi', "warden_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Detective")
			clothes_s = new /icon('icons/mob/uniform.dmi', "detective_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
		if("Security Officer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "secred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Chief Engineer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chief_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Station Engineer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "engine_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Atmospheric Technician")
			clothes_s = new /icon('icons/mob/uniform.dmi', "atmos_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Roboticist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "robotics_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		else
			clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	del(eyes_s)
	del(clothes_s)

	return preview_icon