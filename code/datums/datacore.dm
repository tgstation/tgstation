
/datum/datacore
	var/medical[] = list()
	var/medicalPrintCount = 0
	var/general[] = list()
	var/security[] = list()
	var/securityPrintCount = 0
	var/securityCrimeCounter = 0
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()

/datum/data
	var/name = "data"

/datum/data/record
	name = "record"
	var/list/fields = list()

/datum/data/crime
	name = "crime"
	var/crimeName = ""
	var/crimeDetails = ""
	var/author = ""
	var/time = ""
	var/dataId = 0

/datum/datacore/proc/createCrimeEntry(cname = "", cdetails = "", author = "", time = "")
	var/datum/data/crime/c = new /datum/data/crime
	c.crimeName = cname
	c.crimeDetails = cdetails
	c.author = author
	c.time = time
	c.dataId = ++securityCrimeCounter
	return c

/datum/datacore/proc/addMinorCrime(id = "", var/datum/data/crime/crime)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["mi_crim"]
			crimes |= crime
			return

/datum/datacore/proc/removeMinorCrime(id, cDataId)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["mi_crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					return

/datum/datacore/proc/removeMajorCrime(id, cDataId)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["ma_crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					return

/datum/datacore/proc/addMajorCrime(id = "", var/datum/data/crime/crime)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["ma_crim"]
			crimes |= crime
			return

/datum/datacore/proc/manifest(var/nosleep = 0)
	spawn()
		if(!nosleep)
			sleep(40)
		for(var/mob/living/carbon/human/H in player_list)
			manifest_inject(H)
		return

/datum/datacore/proc/manifest_modify(var/name, var/assignment)
	var/datum/data/record/foundrecord = find_record("name", name, data_core.general)
	if(foundrecord)
		foundrecord.fields["rank"] = assignment

/datum/datacore/proc/get_manifest(monochrome, OOC)
	var/list/heads = list()
	var/list/sec = list()
	var/list/eng = list()
	var/list/med = list()
	var/list/sci = list()
	var/list/sup = list()
	var/list/civ = list()
	var/list/bot = list()
	var/list/misc = list()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th></tr>
	"}
	var/even = 0
	// sort mobs
	for(var/datum/data/record/t in data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/department = 0
		if(rank in command_positions)
			heads[name] = rank
			department = 1
		if(rank in security_positions)
			sec[name] = rank
			department = 1
		if(rank in engineering_positions)
			eng[name] = rank
			department = 1
		if(rank in medical_positions)
			med[name] = rank
			department = 1
		if(rank in science_positions)
			sci[name] = rank
			department = 1
		if(rank in supply_positions)
			sup[name] = rank
			department = 1
		if(rank in civilian_positions)
			civ[name] = rank
			department = 1
		if(rank in nonhuman_positions)
			bot[name] = rank
			department = 1
		if(!department && !(name in heads))
			misc[name] = rank
	if(heads.len > 0)
		dat += "<tr><th colspan=3>Heads</th></tr>"
		for(var/name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td></tr>"
			even = !even
	if(sec.len > 0)
		dat += "<tr><th colspan=3>Security</th></tr>"
		for(var/name in sec)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sec[name]]</td></tr>"
			even = !even
	if(eng.len > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(var/name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td></tr>"
			even = !even
	if(med.len > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(var/name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td></tr>"
			even = !even
	if(sci.len > 0)
		dat += "<tr><th colspan=3>Science</th></tr>"
		for(var/name in sci)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sci[name]]</td></tr>"
			even = !even
	if(sup.len > 0)
		dat += "<tr><th colspan=3>Supply</th></tr>"
		for(var/name in sup)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sup[name]]</td></tr>"
			even = !even
	if(civ.len > 0)
		dat += "<tr><th colspan=3>Civilian</th></tr>"
		for(var/name in civ)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[civ[name]]</td></tr>"
			even = !even
	// in case somebody is insane and added them to the manifest, why not
	if(bot.len > 0)
		dat += "<tr><th colspan=3>Silicon</th></tr>"
		for(var/name in bot)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[bot[name]]</td></tr>"
			even = !even
	// misc guys
	if(misc.len > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(var/name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "")
	dat = replacetext(dat, "\t", "")
	return dat


var/record_id_num = 1001
/datum/datacore/proc/manifest_inject(var/mob/living/carbon/human/H)
	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		var/assignment
		if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		var/id = num2hex(record_id_num++,6)
		var/image = get_id_photo(H)
		var/obj/item/weapon/photo/photo_front = new()
		var/obj/item/weapon/photo/photo_side = new()
		photo_front.photocreate(null, icon(image, dir = SOUTH))
		photo_side.photocreate(null, icon(image, dir = WEST))

		//These records should ~really~ be merged or something
		//General Record
		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		if(config.mutant_races)
			G.fields["species"]	= H.dna.species.name
		G.fields["fingerprint"]	= md5(H.dna.uni_identity)
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= H.gender
		G.fields["photo_front"]	= photo_front
		G.fields["photo_side"]	= photo_side
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["blood_type"]	= H.blood_type
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
		S.fields["mi_crim"]		= list()
		S.fields["ma_crim"]		= list()
		S.fields["notes"]		= "No notes."
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")	//surely this should just be id, like the others?
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= H.gender
		L.fields["blood_type"]	= H.blood_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["enzymes"]		= H.dna.struc_enzymes
		L.fields["identity"]	= H.dna.uni_identity
		L.fields["species"]		= H.dna.species.type
		L.fields["features"]	= H.dna.features
		L.fields["image"]		= image
		locked += L
	return

/datum/datacore/proc/get_id_photo(var/mob/living/carbon/human/H)
	var/icon/photo = null
	var/g = (H.gender == FEMALE) ? "f" : "m"
	if(!config.mutant_races || H.dna.species.use_skintones)
		photo = icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[H.skin_tone]_[g]_s")
	else
		photo = icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[H.dna.species.id]_[g]_s")
		photo.Blend("#[H.dna.features["mcolor"]]", ICON_MULTIPLY)

	var/icon/eyes_s
	if(EYECOLOR in H.dna.species.specflags)
		eyes_s = icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[H.dna.species.eyes]_s")
		eyes_s.Blend("#[H.eye_color]", ICON_MULTIPLY)

	var/datum/sprite_accessory/S
	S = hair_styles_list[H.hair_style]
	if(S && (HAIR in H.dna.species.specflags))
		var/icon/hair_s = icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		hair_s.Blend("#[H.hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	S = facial_hair_styles_list[H.facial_hair_style]
	if(S && (FACEHAIR in H.dna.species.specflags))
		var/icon/facial_s = icon("icon" = S.icon, "icon_state" = "[S.icon_state]_s")
		facial_s.Blend("#[H.facial_hair_color]", ICON_MULTIPLY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	if(eyes_s)
		photo.Blend(eyes_s, ICON_OVERLAY)

	var/icon/clothes_s = null
	switch(H.mind.assigned_role)
		if("Assistant")
			clothes_s = icon('icons/mob/uniform.dmi', "grey_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Scientist")
			clothes_s = icon('icons/mob/uniform.dmi', "toxinswhite_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat_tox"), ICON_OVERLAY)
		if("Station Engineer")
			clothes_s = icon('icons/mob/uniform.dmi', "engine_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Security Officer")
			clothes_s = icon('icons/mob/uniform.dmi', "security_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
		if("Medical Doctor")
			clothes_s = icon('icons/mob/uniform.dmi', "medical_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat"), ICON_OVERLAY)
		if("Cargo Technician")
			clothes_s = icon('icons/mob/uniform.dmi', "cargo_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Shaft Miner")
			clothes_s = icon('icons/mob/uniform.dmi', "miner_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Atmospheric Technician")
			clothes_s = icon('icons/mob/uniform.dmi', "atmos_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Botanist")
			clothes_s = icon('icons/mob/uniform.dmi', "hydroponics_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "ggloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "apron"), ICON_OVERLAY)
		if("Chemist")
			clothes_s = icon('icons/mob/uniform.dmi', "chemistrywhite_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat_chem"), ICON_OVERLAY)
		if("Cook")
			clothes_s = icon('icons/mob/uniform.dmi', "chef_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "chef"), ICON_OVERLAY)
		if("Janitor")
			clothes_s = icon('icons/mob/uniform.dmi', "janitor_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Geneticist")
			clothes_s = icon('icons/mob/uniform.dmi', "geneticswhite_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat_gen"), ICON_OVERLAY)
		if("Virologist")
			clothes_s = icon('icons/mob/uniform.dmi', "virologywhite_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat_vir"), ICON_OVERLAY)
		if("Roboticist")
			clothes_s = icon('icons/mob/uniform.dmi', "robotics_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat"), ICON_OVERLAY)
		if("Lawyer")
			clothes_s = icon('icons/mob/uniform.dmi', "bluesuit_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
		if("Clown")
			clothes_s = icon('icons/mob/uniform.dmi', "clown_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "clown"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
		if("Mime")
			clothes_s = icon('icons/mob/uniform.dmi', "mime_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "suspenders"), ICON_OVERLAY)
		if("Bartender")
			clothes_s = icon('icons/mob/uniform.dmi', "ba_suit_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "armor"), ICON_OVERLAY)
		if("Quartermaster")
			clothes_s = icon('icons/mob/uniform.dmi', "qm_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Chaplain")
			clothes_s = icon('icons/mob/uniform.dmi', "chapblack_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Research Director")
			clothes_s = icon('icons/mob/uniform.dmi', "director_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat"), ICON_OVERLAY)
		if("Chief Medical Officer")
			clothes_s = icon('icons/mob/uniform.dmi', "cmo_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "labcoat_cmo"), ICON_OVERLAY)
		if("Captain")
			clothes_s = icon('icons/mob/uniform.dmi', "captain_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "capcarapace"), ICON_OVERLAY)
		if("Head of Security")
			clothes_s = icon('icons/mob/uniform.dmi', "hos_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "hostrench"), ICON_OVERLAY)
		if("Warden")
			clothes_s = icon('icons/mob/uniform.dmi', "warden_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "warden_jacket"), ICON_OVERLAY)
		if("Detective")
			clothes_s = icon('icons/mob/uniform.dmi', "detective_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
			clothes_s.Blend(icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
			clothes_s.Blend(icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
		if("Chief Engineer")
			clothes_s = icon('icons/mob/uniform.dmi', "chief_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
			clothes_s.Blend(icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Head of Personnel")
			clothes_s = icon('icons/mob/uniform.dmi', "hop_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Librarian")
			clothes_s = icon('icons/mob/uniform.dmi', "red_suit_s")
			clothes_s.Blend(icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)

	if(clothes_s)
		photo.Blend(clothes_s, ICON_OVERLAY)

	return photo
