

GLOBAL_VAR_CONST(access_security, 1) // Security equipment
GLOBAL_VAR_CONST(access_brig, 2) // Brig timers and permabrig
GLOBAL_VAR_CONST(access_armory, 3)
GLOBAL_VAR_CONST(access_forensics_lockers, 4)
GLOBAL_VAR_CONST(access_medical, 5)
GLOBAL_VAR_CONST(access_morgue, 6)
GLOBAL_VAR_CONST(access_tox, 7)
GLOBAL_VAR_CONST(access_tox_storage, 8)
GLOBAL_VAR_CONST(access_genetics, 9)
GLOBAL_VAR_CONST(access_engine, 10)
GLOBAL_VAR_CONST(access_engine_equip, 11)
GLOBAL_VAR_CONST(access_maint_tunnels, 12)
GLOBAL_VAR_CONST(access_external_airlocks, 13)
GLOBAL_VAR_CONST(access_emergency_storage, 14)
GLOBAL_VAR_CONST(access_change_ids, 15)
GLOBAL_VAR_CONST(access_ai_upload, 16)
GLOBAL_VAR_CONST(access_teleporter, 17)
GLOBAL_VAR_CONST(access_eva, 18)
GLOBAL_VAR_CONST(access_heads, 19)
GLOBAL_VAR_CONST(access_captain, 20)
GLOBAL_VAR_CONST(access_all_personal_lockers, 21)
GLOBAL_VAR_CONST(access_chapel_office, 22)
GLOBAL_VAR_CONST(access_tech_storage, 23)
GLOBAL_VAR_CONST(access_atmospherics, 24)
GLOBAL_VAR_CONST(access_bar, 25)
GLOBAL_VAR_CONST(access_janitor, 26)
GLOBAL_VAR_CONST(access_crematorium, 27)
GLOBAL_VAR_CONST(access_kitchen, 28)
GLOBAL_VAR_CONST(access_robotics, 29)
GLOBAL_VAR_CONST(access_rd, 30)
GLOBAL_VAR_CONST(access_cargo, 31)
GLOBAL_VAR_CONST(access_construction, 32)
GLOBAL_VAR_CONST(access_chemistry, 33)
GLOBAL_VAR_CONST(access_cargo_bot, 34)
GLOBAL_VAR_CONST(access_hydroponics, 35)
GLOBAL_VAR_CONST(access_manufacturing, 36)
GLOBAL_VAR_CONST(access_library, 37)
GLOBAL_VAR_CONST(access_lawyer, 38)
GLOBAL_VAR_CONST(access_virology, 39)
GLOBAL_VAR_CONST(access_cmo, 40)
GLOBAL_VAR_CONST(access_qm, 41)
GLOBAL_VAR_CONST(access_court, 42)
GLOBAL_VAR_CONST(access_surgery, 45)
GLOBAL_VAR_CONST(access_theatre, 46)
GLOBAL_VAR_CONST(access_research, 47)
GLOBAL_VAR_CONST(access_mining, 48)
GLOBAL_VAR_CONST(access_mining_office, 49) //not in use
GLOBAL_VAR_CONST(access_mailsorting, 50)
GLOBAL_VAR_CONST(access_mint, 51)
GLOBAL_VAR_CONST(access_mint_vault, 52)
GLOBAL_VAR_CONST(access_heads_vault, 53)
GLOBAL_VAR_CONST(access_mining_station, 54)
GLOBAL_VAR_CONST(access_xenobiology, 55)
GLOBAL_VAR_CONST(access_ce, 56)
GLOBAL_VAR_CONST(access_hop, 57)
GLOBAL_VAR_CONST(access_hos, 58)
GLOBAL_VAR_CONST(access_RC_announce, 59) //Request console announcements
GLOBAL_VAR_CONST(access_keycard_auth, 60) //Used for events which require at least two people to confirm them
GLOBAL_VAR_CONST(access_tcomsat, 61) // has access to the entire telecomms satellite / machinery
GLOBAL_VAR_CONST(access_gateway, 62)
GLOBAL_VAR_CONST(access_sec_doors, 63) // Security front doors
GLOBAL_VAR_CONST(access_mineral_storeroom, 64)
GLOBAL_VAR_CONST(access_minisat, 65)
GLOBAL_VAR_CONST(access_weapons, 66) //Weapon authorization for secbots
GLOBAL_VAR_CONST(access_network, 67)
GLOBAL_VAR_CONST(access_cloning, 68) //Cloning room

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
	Mostly for admin fun times.*/
GLOBAL_VAR_CONST(access_cent_general, 101)//General facilities.
GLOBAL_VAR_CONST(access_cent_thunder, 102)//Thunderdome.
GLOBAL_VAR_CONST(access_cent_specops, 103)//Special Ops.
GLOBAL_VAR_CONST(access_cent_medical, 104)//Medical/Research
GLOBAL_VAR_CONST(access_cent_living, 105)//Living quarters.
GLOBAL_VAR_CONST(access_cent_storage, 106)//Generic storage areas.
GLOBAL_VAR_CONST(access_cent_teleporter, 107)//Teleporter.
GLOBAL_VAR_CONST(access_cent_captain, 109)//Captain's office/ID comp/AI.
GLOBAL_VAR_CONST(access_cent_bar, 110) // The non-existent Centcom Bar

	//The Syndicate
GLOBAL_VAR_CONST(access_syndicate, 150)//General Syndicate Access
GLOBAL_VAR_CONST(access_syndicate_leader, 151)//Nuke Op Leader Access

	//Away Missions or Ruins
	/*For generic away-mission/ruin access. Why would normal crew have access to a long-abandoned derelict
	or a 2000 year-old temple? */
GLOBAL_VAR_CONST(access_away_general, 200)//General facilities.
GLOBAL_VAR_CONST(access_away_maint, 201)//Away maintenance
GLOBAL_VAR_CONST(access_away_med, 202)//Away medical
GLOBAL_VAR_CONST(access_away_sec, 203)//Away security
GLOBAL_VAR_CONST(access_away_engine, 204)//Away engineering
GLOBAL_VAR_CONST(access_away_generic1, 205)//Away generic access
GLOBAL_VAR_CONST(access_away_generic2, 206)
GLOBAL_VAR_CONST(access_away_generic3, 207)
GLOBAL_VAR_CONST(access_away_generic4, 208)

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0" as text
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0" as text

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

/obj/proc/text2access(access_text)
	. = list()
	if(!access_text)
		return
	var/list/split = splittext(access_text,";")
	for(var/x in split)
		var/n = text2num(x)
		if(n)
			. += n

//Call this before using req_access or req_one_access directly
/obj/proc/gen_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!req_access)
		req_access = list()
		for(var/a in text2access(req_access_txt))
			req_access += a
	if(!req_one_access)
		req_one_access = list()
		for(var/b in text2access(req_one_access_txt))
			req_one_access += b

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
			return list(GLOB.access_cent_general)
		if("Custodian")
			return list(GLOB.access_cent_general, GLOB.access_cent_living, GLOB.access_cent_storage)
		if("Thunderdome Overseer")
			return list(GLOB.access_cent_general, GLOB.access_cent_thunder)
		if("Centcom Official")
			return list(GLOB.access_cent_general, GLOB.access_cent_living)
		if("Medical Officer")
			return list(GLOB.access_cent_general, GLOB.access_cent_living, GLOB.access_cent_medical)
		if("Death Commando")
			return list(GLOB.access_cent_general, GLOB.access_cent_specops, GLOB.access_cent_living, GLOB.access_cent_storage)
		if("Research Officer")
			return list(GLOB.access_cent_general, GLOB.access_cent_specops, GLOB.access_cent_medical, GLOB.access_cent_teleporter, GLOB.access_cent_storage)
		if("Special Ops Officer")
			return list(GLOB.access_cent_general, GLOB.access_cent_thunder, GLOB.access_cent_specops, GLOB.access_cent_living, GLOB.access_cent_storage)
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
			return list(GLOB.access_cent_general, GLOB.access_cent_living, GLOB.access_cent_bar)

/proc/get_all_accesses()
	return list(GLOB.access_security, GLOB.access_sec_doors, GLOB.access_brig, GLOB.access_armory, GLOB.access_forensics_lockers, GLOB.access_court,
	            GLOB.access_medical, GLOB.access_genetics, GLOB.access_morgue, GLOB.access_rd,
	            GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_chemistry, GLOB.access_engine, GLOB.access_engine_equip, GLOB.access_maint_tunnels,
	            GLOB.access_external_airlocks, GLOB.access_change_ids, GLOB.access_ai_upload,
	            GLOB.access_teleporter, GLOB.access_eva, GLOB.access_heads, GLOB.access_captain, GLOB.access_all_personal_lockers,
	            GLOB.access_tech_storage, GLOB.access_chapel_office, GLOB.access_atmospherics, GLOB.access_kitchen,
	            GLOB.access_bar, GLOB.access_janitor, GLOB.access_crematorium, GLOB.access_robotics, GLOB.access_cargo, GLOB.access_construction,
	            GLOB.access_hydroponics, GLOB.access_library, GLOB.access_lawyer, GLOB.access_virology, GLOB.access_cmo, GLOB.access_qm, GLOB.access_surgery,
	            GLOB.access_theatre, GLOB.access_research, GLOB.access_mining, GLOB.access_mailsorting, GLOB.access_weapons,
	            GLOB.access_heads_vault, GLOB.access_mining_station, GLOB.access_xenobiology, GLOB.access_ce, GLOB.access_hop, GLOB.access_hos, GLOB.access_RC_announce,
	            GLOB.access_keycard_auth, GLOB.access_tcomsat, GLOB.access_gateway, GLOB.access_mineral_storeroom, GLOB.access_minisat, GLOB.access_network, GLOB.access_cloning)

/proc/get_all_centcom_access()
	return list(GLOB.access_cent_general, GLOB.access_cent_thunder, GLOB.access_cent_specops, GLOB.access_cent_medical, GLOB.access_cent_living, GLOB.access_cent_storage, GLOB.access_cent_teleporter, GLOB.access_cent_captain)

/proc/get_ert_access(class)
	switch(class)
		if("commander")
			return get_all_centcom_access()
		if("sec")
			return list(GLOB.access_cent_general, GLOB.access_cent_specops, GLOB.access_cent_living)
		if("eng")
			return list(GLOB.access_cent_general, GLOB.access_cent_specops, GLOB.access_cent_living, GLOB.access_cent_storage)
		if("med")
			return list(GLOB.access_cent_general, GLOB.access_cent_specops, GLOB.access_cent_medical, GLOB.access_cent_living)

/proc/get_all_syndicate_access()
	return list(GLOB.access_syndicate, GLOB.access_syndicate)

/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //station general
			return list(GLOB.access_kitchen,GLOB.access_bar, GLOB.access_hydroponics, GLOB.access_janitor, GLOB.access_chapel_office, GLOB.access_crematorium, GLOB.access_library, GLOB.access_theatre, GLOB.access_lawyer)
		if(2) //security
			return list(GLOB.access_sec_doors, GLOB.access_weapons, GLOB.access_security, GLOB.access_brig, GLOB.access_armory, GLOB.access_forensics_lockers, GLOB.access_court, GLOB.access_hos)
		if(3) //medbay
			return list(GLOB.access_medical, GLOB.access_genetics, GLOB.access_cloning, GLOB.access_morgue, GLOB.access_chemistry, GLOB.access_virology, GLOB.access_surgery, GLOB.access_cmo)
		if(4) //research
			return list(GLOB.access_research, GLOB.access_tox, GLOB.access_tox_storage, GLOB.access_genetics, GLOB.access_robotics, GLOB.access_xenobiology, GLOB.access_minisat, GLOB.access_rd, GLOB.access_network)
		if(5) //engineering and maintenance
			return list(GLOB.access_construction, GLOB.access_maint_tunnels, GLOB.access_engine, GLOB.access_engine_equip, GLOB.access_external_airlocks, GLOB.access_tech_storage, GLOB.access_atmospherics, GLOB.access_tcomsat, GLOB.access_minisat, GLOB.access_ce)
		if(6) //supply
			return list(GLOB.access_mailsorting, GLOB.access_mining, GLOB.access_mining_station, GLOB.access_mineral_storeroom, GLOB.access_cargo, GLOB.access_qm)
		if(7) //command
			return list(GLOB.access_heads, GLOB.access_RC_announce, GLOB.access_keycard_auth, GLOB.access_change_ids, GLOB.access_ai_upload, GLOB.access_teleporter, GLOB.access_eva, GLOB.access_gateway, GLOB.access_all_personal_lockers, GLOB.access_heads_vault, GLOB.access_hop, GLOB.access_captain)

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
		if(GLOB.access_cargo)
			return "Cargo Bay"
		if(GLOB.access_cargo_bot)
			return "Delivery Chutes"
		if(GLOB.access_security)
			return "Security"
		if(GLOB.access_brig)
			return "Holding Cells"
		if(GLOB.access_court)
			return "Courtroom"
		if(GLOB.access_forensics_lockers)
			return "Forensics"
		if(GLOB.access_medical)
			return "Medical"
		if(GLOB.access_genetics)
			return "Genetics Lab"
		if(GLOB.access_morgue)
			return "Morgue"
		if(GLOB.access_tox)
			return "R&D Lab"
		if(GLOB.access_tox_storage)
			return "Toxins Lab"
		if(GLOB.access_chemistry)
			return "Chemistry Lab"
		if(GLOB.access_rd)
			return "RD Office"
		if(GLOB.access_bar)
			return "Bar"
		if(GLOB.access_janitor)
			return "Custodial Closet"
		if(GLOB.access_engine)
			return "Engineering"
		if(GLOB.access_engine_equip)
			return "Power Equipment"
		if(GLOB.access_maint_tunnels)
			return "Maintenance"
		if(GLOB.access_external_airlocks)
			return "External Airlocks"
		if(GLOB.access_emergency_storage)
			return "Emergency Storage"
		if(GLOB.access_change_ids)
			return "ID Console"
		if(GLOB.access_ai_upload)
			return "AI Chambers"
		if(GLOB.access_teleporter)
			return "Teleporter"
		if(GLOB.access_eva)
			return "EVA"
		if(GLOB.access_heads)
			return "Bridge"
		if(GLOB.access_captain)
			return "Captain"
		if(GLOB.access_all_personal_lockers)
			return "Personal Lockers"
		if(GLOB.access_chapel_office)
			return "Chapel Office"
		if(GLOB.access_tech_storage)
			return "Technical Storage"
		if(GLOB.access_atmospherics)
			return "Atmospherics"
		if(GLOB.access_crematorium)
			return "Crematorium"
		if(GLOB.access_armory)
			return "Armory"
		if(GLOB.access_construction)
			return "Construction"
		if(GLOB.access_kitchen)
			return "Kitchen"
		if(GLOB.access_hydroponics)
			return "Hydroponics"
		if(GLOB.access_library)
			return "Library"
		if(GLOB.access_lawyer)
			return "Law Office"
		if(GLOB.access_robotics)
			return "Robotics"
		if(GLOB.access_virology)
			return "Virology"
		if(GLOB.access_cmo)
			return "CMO Office"
		if(GLOB.access_qm)
			return "Quartermaster"
		if(GLOB.access_surgery)
			return "Surgery"
		if(GLOB.access_theatre)
			return "Theatre"
		if(GLOB.access_manufacturing)
			return "Manufacturing"
		if(GLOB.access_research)
			return "Science"
		if(GLOB.access_mining)
			return "Mining"
		if(GLOB.access_mining_office)
			return "Mining Office"
		if(GLOB.access_mailsorting)
			return "Cargo Office"
		if(GLOB.access_mint)
			return "Mint"
		if(GLOB.access_mint_vault)
			return "Mint Vault"
		if(GLOB.access_heads_vault)
			return "Main Vault"
		if(GLOB.access_mining_station)
			return "Mining EVA"
		if(GLOB.access_xenobiology)
			return "Xenobiology Lab"
		if(GLOB.access_hop)
			return "HoP Office"
		if(GLOB.access_hos)
			return "HoS Office"
		if(GLOB.access_ce)
			return "CE Office"
		if(GLOB.access_RC_announce)
			return "RC Announcements"
		if(GLOB.access_keycard_auth)
			return "Keycode Auth."
		if(GLOB.access_tcomsat)
			return "Telecommunications"
		if(GLOB.access_gateway)
			return "Gateway"
		if(GLOB.access_sec_doors)
			return "Brig"
		if(GLOB.access_mineral_storeroom)
			return "Mineral Storage"
		if(GLOB.access_minisat)
			return "AI Satellite"
		if(GLOB.access_weapons)
			return "Weapon Permit"
		if(GLOB.access_network)
			return "Network Access"
		if(GLOB.access_cloning)
			return "Cloning Room"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(GLOB.access_cent_general)
			return "Code Grey"
		if(GLOB.access_cent_thunder)
			return "Code Yellow"
		if(GLOB.access_cent_storage)
			return "Code Orange"
		if(GLOB.access_cent_living)
			return "Code Green"
		if(GLOB.access_cent_medical)
			return "Code White"
		if(GLOB.access_cent_teleporter)
			return "Code Blue"
		if(GLOB.access_cent_specops)
			return "Code Black"
		if(GLOB.access_cent_captain)
			return "Code Gold"
		if(GLOB.access_cent_bar)
			return "Code Scotch"

/proc/get_all_jobs()
	return list("Assistant", "Captain", "Head of Personnel", "Bartender", "Cook", "Botanist", "Quartermaster", "Cargo Technician",
				"Shaft Miner", "Clown", "Mime", "Janitor", "Curator", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer",
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
