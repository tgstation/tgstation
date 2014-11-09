//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/var/const/access_security = 1 // Security equipment
/var/const/access_brig = 2 // Brig timers and permabrig
/var/const/access_armory = 3
/var/const/access_forensics_lockers= 4
/var/const/access_medical = 5
/var/const/access_morgue = 6
/var/const/access_tox = 7			// Research and Development
/var/const/access_tox_storage = 8	// Toxins mixing and storage
/var/const/access_genetics = 9
/var/const/access_engine = 10		// Power Engines
/var/const/access_engine_equip= 11	// Engineering Foyer
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
/var/const/access_cargo = 31		// Cargo Bay
/var/const/access_construction = 32	// Vacant office, etc
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
/var/const/access_clown = 43
/var/const/access_mime = 44
/var/const/access_surgery = 45
/var/const/access_theatre = 46
/var/const/access_research = 47		// Research Division hallway
/var/const/access_mining = 48
/var/const/access_mining_office = 49 //not in use
/var/const/access_mailsorting = 50	// Cargo Office
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
/var/const/access_psychiatrist = 64 // Psychiatrist's office
/var/const/access_salvage_captain = 65 // Salvage ship captain's quarters
/var/const/access_weapons = 66 //Weapon authorization for secbots
/var/const/access_taxi = 67 // Taxi drivers
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
/var/const/access_cent_creed = 108//Creed's office.
/var/const/access_cent_captain = 109//Captain's office/ID comp/AI.

	//The Syndicate
/var/const/access_syndicate = 150//General Syndicate Access

	//MONEY
/var/const/access_crate_cash = 200

// /VG/ SPECIFIC SHIT
/var/const/access_paramedic = 500
/var/const/access_mechanic = 501

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"			// A user must have ALL of these accesses to use the object
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"		// If this list is populated, a user must have at least ONE of these accesses to use the object

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(var/mob/M)
	set_up_access()
	if(!M)
		return 0 // I guess?  This seems to happen when AIs use something.
	if(M.hasFullAccess()) // AI, robots, adminghosts, etc.
		return 1
	var/list/ACL = M.GetAccess()
	return can_access(ACL,req_access,req_one_access)

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/proc/set_up_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!src.req_access)
		src.req_access = list()
		if(src.req_access_txt)
			var/list/req_access_str = text2list(req_access_txt,";")
			for(var/x in req_access_str)
				var/n = text2num(x)
				if(n)
					req_access += n

	if(!src.req_one_access)
		src.req_one_access = list()
		if(src.req_one_access_txt)
			var/list/req_one_access_str = text2list(req_one_access_txt,";")
			for(var/x in req_one_access_str)
				var/n = text2num(x)
				if(n)
					req_one_access += n

/obj/proc/check_access(obj/item/I)
	set_up_access()
	var/list/ACL = list()
	if(I)
		ACL=I.GetAccess()
	return can_access(ACL,req_access,req_one_access)


/obj/proc/check_access_list(var/list/L)
	set_up_access()
	if(!src.req_access  && !src.req_one_access)	return 1
	if(!istype(src.req_access, /list))	return 1
	if(!src.req_access.len && (!src.req_one_access || !src.req_one_access.len))	return 1
	if(!L)	return 0
	if(!istype(L, /list))	return 0
	for(var/req in src.req_access)
		if(!(req in L)) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in L) //has an access from the single access list
				return 1
		return 0
	return 1

// /vg/ - Generic Access Checks.
// Allows more flexible access checks.
/proc/can_access(var/list/L, var/list/req_access=null,var/list/req_one_access=null)
	// No perms set?  He's in.
	if(!req_access  && !req_one_access)
		return 1
	// Fucked permissions set?  He's in.
	if(!istype(req_access, /list))
		return 1
	// Blank permissions set?  He's in.
	if(!req_access.len && (!req_one_access || !req_one_access.len))
		return 1

	// User doesn't have any accesses?  Fuck off.
	if(!L)	return 0
	if(!istype(L, /list))	return 0

	// Doesn't have a req_access
	for(var/req in req_access)
		if(!(req in L)) //doesn't have this access
			return 0

	// If he has at least one req_one access, he's in.
	if(req_one_access && req_one_access.len)
		for(var/req in req_one_access)
			if(req in L) //has an access from the single access list
				return 1
		return 0
	return 1

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(access_cent_general)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Intel Officer")
			return list(access_cent_general, access_cent_living)
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical)
		if("Death Commando")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_teleporter, access_cent_storage)
		if("BlackOps Commander")
			return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_living, access_cent_storage, access_cent_creed)
		if("Supreme Commander")
			return get_all_centcom_access()

/proc/get_all_accesses()
	return list(access_security, access_sec_doors, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_genetics, access_morgue, access_rd,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction,
	            access_hydroponics, access_library, access_lawyer, access_virology, access_psychiatrist, access_cmo, access_qm, access_clown, access_mime, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting,access_weapons,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat, access_gateway, /*vg paramedic*/, access_paramedic, access_mechanic, access_taxi)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_sec_doors, access_weapons, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)
		if(2) //medbay
			return list(access_medical, access_genetics, access_morgue, access_chemistry, access_paramedic, access_virology, access_surgery, access_cmo)
		if(3) //research
			return list(access_research, access_tox, access_tox_storage, access_robotics, access_xenobiology, access_rd)
		if(4) //engineering and maintenance
			return list(access_construction, access_maint_tunnels, access_engine, access_engine_equip, access_external_airlocks, access_tech_storage, access_atmospherics, access_ce)
		if(5) //command
			return list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_tcomsat, access_gateway, access_all_personal_lockers, access_heads_vault, access_hop, access_captain)
		if(6) //station general
			return list(access_kitchen,access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer, access_clown, access_mime)
		if(7) //supply
			return list(access_mailsorting, access_mining, access_mining_station, access_cargo, access_qm, access_taxi)

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(0)
			return "All"
		if(1) //security
			return "Security"
		if(2) //medbay
			return "Medbay"
		if(3) //research
			return "Research"
		if(4) //engineering and maintenance
			return "Engineering"
		if(5) //command
			return "Command"
		if(6) //station general
			return "Station General"
		if(7) //supply
			return "Supply"


/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Cargo Bot Delivery"
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
			return "Research Director"
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
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
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
			return "Construction Areas"
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
		if(access_psychiatrist)
			return "Psychiatrist's Office"
		if(access_cmo)
			return "Chief Medical Officer"
		if(access_qm)
			return "Quartermaster"
		if(access_clown)
			return "HONK! Access"
		if(access_mime)
			return "Silent Access"
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
			return "Head of Personnel"
		if(access_hos)
			return "Head of Security"
		if(access_ce)
			return "Chief Engineer"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth. Device"
		if(access_tcomsat)
			return "Telecommunications"
		if(access_gateway)
			return "Gateway"
		if(access_sec_doors)
			return "Brig"
// /vg/ shit
		if(access_paramedic)
			return "Paramedic Station"
		if(access_weapons)
			return "Weapon Permit"
		if(access_taxi)
			return "Taxi Shuttle"


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
		if(access_cent_creed)
			return "Code Silver"
		if(access_cent_captain)
			return "Code Gold"

// Cache - N3X
var/global/list/all_jobs
/proc/get_all_jobs()
	// Have cache?  Use cache.
	if(all_jobs)
		return all_jobs

	// Rebuild cache.
	all_jobs=list()
	for(var/jobtype in typesof(/datum/job) - /datum/job)
		var/datum/job/jobdatum = new jobtype
		if(jobdatum.info_flag & JINFO_SILICON) continue
		all_jobs.Add(jobdatum.title)
	return all_jobs

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

//gets the actual job rank (ignoring alt titles)
//this is used solely for sechuds
/obj/proc/GetJobRealName()
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/rank
	var/assignment
	if(istype(src, /obj/item/device/pda))
		if(src:id)
			rank = src:id:rank
			assignment = src:id:assignment
	else if(istype(src, /obj/item/weapon/card/id))
		rank = src:rank
		assignment = src:assignment

	if( rank in get_all_jobs() )
		return rank

	if( assignment in get_all_jobs() )
		return assignment

	return "Unknown"

//gets the alt title, failing that the actual job rank
//this is unused
/obj/proc/sdsdsd()	//GetJobDisplayName
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/assignment
	if(istype(src, /obj/item/device/pda))
		if(src:id)
			assignment = src:id:assignment
	else if(istype(src, /obj/item/weapon/card/id))
		assignment = src:assignment

	if(assignment)
		return assignment

	return "Unknown"

proc/FindNameFromID(var/mob/living/carbon/human/H)
	ASSERT(istype(H))
	var/obj/item/weapon/card/id/C = H.get_active_hand()
	if( istype(C) || istype(C, /obj/item/device/pda) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

	C = H.wear_id

	if( istype(C) || istype(C, /obj/item/device/pda) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			return ID.registered_name

proc/get_all_job_icons() //For all existing HUD icons
	return get_all_jobs() + list("Prisoner")

/obj/proc/GetJobName() //Used in secHUD icon generation
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/jobName

	if(istype(src, /obj/item/device/pda))
		if(src:id)
			jobName = src:id:assignment
	if(istype(src, /obj/item/weapon/card/id))
		jobName = src:assignment

	if(jobName in get_all_job_icons()) //Check if the job has a hud icon
		return jobName
	if(jobName in get_all_centcom_jobs()) //Return with the NT logo if it is a Centcom job
		return "Centcom"
	return "Unknown" //Return unknown if none of the above apply

