

/var/const/access_security = 1 // Security equipment
/var/const/access_brig = 2 // Brig timers and permabrig
/var/const/access_armory = 3
/var/const/access_forensics_lockers= 4
/var/const/access_medical = 5
/var/const/access_morgue = 6
/var/const/access_tox = 7
/var/const/access_tox_storage = 8
/var/const/access_genetics = 9
/var/const/access_engine = 10
/var/const/access_engine_equip= 11
/var/const/access_maint_tunnels = 12
/var/const/access_external_airlocks = 13
/var/const/access_emergency_storage = 14
/var/const/access_change_ids = 15
/var/const/access_ai_upload = 16
/var/const/access_teleporter = 17
/var/const/access_eva = 18
/var/const/access_heads = 19
/var/const/access_captain = 20
/var/const/access_all_personal_lockers = 21
/var/const/access_chapel_office = 22
/var/const/access_tech_storage = 23
/var/const/access_atmospherics = 24
/var/const/access_bar = 25
/var/const/access_janitor = 26
/var/const/access_crematorium = 27
/var/const/access_kitchen = 28
/var/const/access_robotics = 29
/var/const/access_rd = 30
/var/const/access_cargo = 31
/var/const/access_construction = 32
/var/const/access_chemistry = 33
/var/const/access_cargo_bot = 34
/var/const/access_hydroponics = 35
/var/const/access_manufacturing = 36
/var/const/access_library = 37
/var/const/access_lawyer = 38
/var/const/access_virology = 39
/var/const/access_cmo = 40
/var/const/access_qm = 41
/var/const/access_court = 42
/var/const/access_surgery = 45
/var/const/access_theatre = 46
/var/const/access_research = 47
/var/const/access_mining = 48
/var/const/access_mining_office = 49 //not in use
/var/const/access_mailsorting = 50
/var/const/access_mint = 51
/var/const/access_mint_vault = 52
/var/const/access_heads_vault = 53
/var/const/access_mining_station = 54
/var/const/access_xenobiology = 55
/var/const/access_ce = 56
/var/const/access_hop = 57
/var/const/access_hos = 58
/var/const/access_RC_announce = 59 //Request console announcements
/var/const/access_keycard_auth = 60 //Used for events which require at least two people to confirm them
/var/const/access_tcomsat = 61 // has access to the entire telecomms satellite / machinery
/var/const/access_gateway = 62
/var/const/access_sec_doors = 63 // Security front doors
/var/const/access_mineral_storeroom = 64
/var/const/access_minisat = 65
/var/const/access_weapons = 66 //Weapon authorization for secbots
/var/const/access_network = 67
/var/const/access_cloning = 68 //Cloning room

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
/var/const/Mostly for admin fun times.*/
/var/const/access_cent_general = 101//General facilities.
/var/const/access_cent_thunder = 102//Thunderdome.
/var/const/access_cent_specops = 103//Special Ops.
/var/const/access_cent_medical = 104//Medical/Research
/var/const/access_cent_living = 105//Living quarters.
/var/const/access_cent_storage = 106//Generic storage areas.
/var/const/access_cent_teleporter = 107//Teleporter.
/var/const/access_cent_captain = 109//Captain's office/ID comp/AI.
/var/const/access_cent_bar = 110 // The non-existent Centcom Bar

	//The Syndicate
/var/const/access_syndicate = 150//General Syndicate Access
/var/const/access_syndicate_leader = 151//Nuke Op Leader Access

	//Away Missions or Ruins
	/*For generic away-mission/ruin access. Why would normal crew have access to a long-abandoned derelict
	or a 2000 year-old temple? */
/var/const/access_away_general = 200//General facilities.
/var/const/access_away_maint = 201//Away maintenance
/var/const/access_away_med = 202//Away medical
/var/const/access_away_sec = 203//Away security
/var/const/access_away_engine = 204//Away engineering
/var/const/access_away_generic1 = 205//Away generic access
/var/const/access_away_generic2 = 206
/var/const/access_away_generic3 = 207
/var/const/access_away_generic4 = 208

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return TRUE
	if(issilicon(M))
		if(ispAI(M))
			return FALSE
		return TRUE	//AI can do whatever it wants
	if(IsAdminGhost(M))
		//Access can't stop the abuse
		return TRUE
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || src.check_access(H.wear_id))
			return TRUE
	else if(ismonkey(M) || isalienadult(M))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(check_access(george.get_active_held_item()))
			return TRUE
	else if(isanimal(M))
		var/mob/living/simple_animal/A = M
		if(check_access(A.get_active_held_item()) || check_access(A.access_card))
			return TRUE
	return FALSE

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

//Call this before using req_access or req_one_access directly
/obj/proc/gen_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!src.req_access)
		src.req_access = list()
		if(src.req_access_txt)
			var/list/req_access_str = splittext(req_access_txt,";")
			for(var/x in req_access_str)
				var/n = text2num(x)
				if(n)
					req_access += n

	if(!src.req_one_access)
		src.req_one_access = list()
		if(src.req_one_access_txt)
			var/list/req_one_access_str = splittext(req_one_access_txt,";")
			for(var/x in req_one_access_str)
				var/n = text2num(x)
				if(n)
					req_one_access += n

/obj/proc/check_access(obj/item/I)
	gen_access()

	if(!istype(src.req_access, /list)) //something's very wrong
		return TRUE

	var/list/L = src.req_access
	if(!L.len && (!src.req_one_access || !src.req_one_access.len)) //no requirements
		return TRUE
	if(!I)
		return FALSE
	for(var/req in src.req_access)
		if(!(req in I.GetAccess())) //doesn't have this access
			return FALSE
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in I.GetAccess()) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE


/obj/proc/check_access_list(list/L)
	if(!src.req_access  && !src.req_one_access)
		return TRUE
	if(!istype(src.req_access, /list))
		return TRUE
	if(!src.req_access.len && (!src.req_one_access || !src.req_one_access.len))
		return TRUE
	if(!L)
		return FALSE
	if(!istype(L, /list))
		return FALSE
	for(var/req in src.req_access)
		if(!(req in L)) //doesn't have this access
			return FALSE
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in L) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(access_cent_general)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Centcom Official")
			return list(access_cent_general, access_cent_living)
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical)
		if("Death Commando")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_teleporter, access_cent_storage)
		if("Special Ops Officer")
			return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_living, access_cent_storage)
		if("Admiral")
			return get_all_centcom_access()
		if("Centcom Commander")
			return get_all_centcom_access()
		if("Emergency Response Team Commander")
			return get_ert_access("commander")
		if("Security Response Officer")
			return get_ert_access("sec")
		if("Engineer Response Officer")
			return get_ert_access("eng")
		if("Medical Response Officer")
			return get_ert_access("med")
		if("Centcom Bartender")
			return list(access_cent_general, access_cent_living, access_cent_bar)

/proc/get_all_accesses()
	return list(access_security, access_sec_doors, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_genetics, access_morgue, access_rd,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction,
	            access_hydroponics, access_library, access_lawyer, access_virology, access_cmo, access_qm, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting, access_weapons,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat, access_gateway, access_mineral_storeroom, access_minisat, access_network, access_cloning)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_captain)

/proc/get_ert_access(class)
	switch(class)
		if("commander")
			return get_all_centcom_access()
		if("sec")
			return list(access_cent_general, access_cent_specops, access_cent_living)
		if("eng")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("med")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_living)

/proc/get_all_syndicate_access()
	return list(access_syndicate, access_syndicate)

/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //station general
			return list(access_kitchen,access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer)
		if(2) //security
			return list(access_sec_doors, access_weapons, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)
		if(3) //medbay
			return list(access_medical, access_genetics, access_cloning, access_morgue, access_chemistry, access_virology, access_surgery, access_cmo)
		if(4) //research
			return list(access_research, access_tox, access_tox_storage, access_genetics, access_robotics, access_xenobiology, access_minisat, access_rd, access_network)
		if(5) //engineering and maintenance
			return list(access_construction, access_maint_tunnels, access_engine, access_engine_equip, access_external_airlocks, access_tech_storage, access_atmospherics, access_tcomsat, access_minisat, access_ce)
		if(6) //supply
			return list(access_mailsorting, access_mining, access_mining_station, access_mineral_storeroom, access_cargo, access_qm)
		if(7) //command
			return list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_gateway, access_all_personal_lockers, access_heads_vault, access_hop, access_captain)

/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "All"
		if(1) //station general
			return "General"
		if(2) //security
			return "Security"
		if(3) //medbay
			return "Medbay"
		if(4) //research
			return "Research"
		if(5) //engineering and maintenance
			return "Engineering"
		if(6) //supply
			return "Supply"
		if(7) //command
			return "Command"

/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Delivery Chutes"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Holding Cells"
		if(access_court)
			return "Courtroom"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_genetics)
			return "Genetics Lab"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "R&D Lab"
		if(access_tox_storage)
			return "Toxins Lab"
		if(access_chemistry)
			return "Chemistry Lab"
		if(access_rd)
			return "RD Office"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Custodial Closet"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "Power Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlocks"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Console"
		if(access_ai_upload)
			return "AI Chambers"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Bridge"
		if(access_captain)
			return "Captain"
		if(access_all_personal_lockers)
			return "Personal Lockers"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydroponics)
			return "Hydroponics"
		if(access_library)
			return "Library"
		if(access_lawyer)
			return "Law Office"
		if(access_robotics)
			return "Robotics"
		if(access_virology)
			return "Virology"
		if(access_cmo)
			return "CMO Office"
		if(access_qm)
			return "Quartermaster"
		if(access_surgery)
			return "Surgery"
		if(access_theatre)
			return "Theatre"
		if(access_manufacturing)
			return "Manufacturing"
		if(access_research)
			return "Science"
		if(access_mining)
			return "Mining"
		if(access_mining_office)
			return "Mining Office"
		if(access_mailsorting)
			return "Cargo Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining EVA"
		if(access_xenobiology)
			return "Xenobiology Lab"
		if(access_hop)
			return "HoP Office"
		if(access_hos)
			return "HoS Office"
		if(access_ce)
			return "CE Office"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth."
		if(access_tcomsat)
			return "Telecommunications"
		if(access_gateway)
			return "Gateway"
		if(access_sec_doors)
			return "Brig"
		if(access_mineral_storeroom)
			return "Mineral Storage"
		if(access_minisat)
			return "AI Satellite"
		if(access_weapons)
			return "Weapon Permit"
		if(access_network)
			return "Network Access"
		if(access_cloning)
			return "Cloning Room"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_cent_general)
			return "Code Grey"
		if(access_cent_thunder)
			return "Code Yellow"
		if(access_cent_storage)
			return "Code Orange"
		if(access_cent_living)
			return "Code Green"
		if(access_cent_medical)
			return "Code White"
		if(access_cent_teleporter)
			return "Code Blue"
		if(access_cent_specops)
			return "Code Black"
		if(access_cent_captain)
			return "Code Gold"
		if(access_cent_bar)
			return "Code Scotch"

/proc/get_all_jobs()
	return list("Assistant", "Captain", "Head of Personnel", "Bartender", "Cook", "Botanist", "Quartermaster", "Cargo Technician",
				"Shaft Miner", "Clown", "Mime", "Janitor", "Librarian", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer",
				"Atmospheric Technician", "Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist",
				"Research Director", "Scientist", "Roboticist", "Head of Security", "Warden", "Detective", "Security Officer")

/proc/get_all_job_icons() //For all existing HUD icons
	return get_all_jobs() + list("Prisoner")

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Centcom Official","Medical Officer","Death Commando","Research Officer","Special Ops Officer","Admiral","Centcom Commander","Emergency Response Team Commander","Security Response Officer","Engineer Response Officer", "Medical Response Officer","Centcom Bartender")

/obj/item/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/weapon/card/id/I = GetID()
	if(!I)
		return
	var/jobName = I.assignment
	if(jobName in get_all_job_icons()) //Check if the job has a hud icon
		return jobName
	if(jobName in get_all_centcom_jobs()) //Return with the NT logo if it is a Centcom job
		return "Centcom"
	return "Unknown" //Return unknown if none of the above apply
