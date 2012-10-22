//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/var/const/access_security = 1
/var/const/access_brig = 2
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
/var/const/access_clown = 43
/var/const/access_mime = 44
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

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"

/obj/New()
	..()
	//NOTE: If a room requires more than one access (IE: Morgue + medbay) set the req_acesss_txt to "5;6" if it requires 5 and 6
	if(src.req_access_txt)
		var/list/req_access_str = dd_text2list(req_access_txt,";")
		if(!req_access)
			req_access = list()
		for(var/x in req_access_str)
			var/n = text2num(x)
			if(n)
				req_access += n

	if(src.req_one_access_txt)
		var/list/req_one_access_str = dd_text2list(req_one_access_txt,";")
		if(!req_one_access)
			req_one_access = list()
		for(var/x in req_one_access_str)
			var/n = text2num(x)
			if(n)
				req_one_access += n



//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/silicon))
		//AI can do whatever he wants
		return 1
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.get_active_hand()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(george.get_active_hand() && (istype(george.get_active_hand(), /obj/item/weapon/card/id) || istype(george.get_active_hand(), /obj/item/device/pda)) && src.check_access(george.get_active_hand()))
			return 1
	return 0

/obj/proc/check_access(obj/item/weapon/card/id/I)

	if (istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id

	if(!src.req_access && !src.req_one_access) //no requirements
		return 1
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len && (!src.req_one_access || !src.req_one_access.len)) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in I.access) //has an access from the single access list
				return 1
		return 0
	return 1


/obj/proc/check_access_list(var/list/L)
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


/proc/get_access(job)
	switch(job)
		if("Geneticist")
			return list(access_medical, access_morgue, access_genetics)
		if("Station Engineer")
			return list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction)
		if("Assistant")
			return list()
		if("Chaplain")
			return list(access_morgue, access_chapel_office, access_crematorium)
		if("Detective")
			return list(access_security, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court)
		if("Medical Doctor")
			return list(access_medical, access_morgue, access_surgery)
		if("Botanist")	// -- TLE
			return list(access_hydroponics, access_morgue) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
		if("Librarian") // -- TLE
			return list(access_library)
		if("Lawyer") //Muskets 160910
			return list(access_lawyer, access_court)
		if("Captain")
			return get_all_accesses()
		if("Security Officer")
			return list(access_security, access_brig, access_court,access_maint_tunnels) // Massively requested that sec get there maintenance access back //
		if("Warden")
			return list(access_security, access_brig, access_armory, access_court,access_maint_tunnels)
		if("Scientist")
			return list(access_tox, access_tox_storage, access_research, access_xenobiology)
		if("Head of Security")
			return list(access_medical, access_morgue, access_tox, access_tox_storage, access_chemistry, access_genetics, access_court,
			            access_teleporter, access_heads, access_tech_storage, access_security, access_brig, access_atmospherics,
			            access_maint_tunnels, access_bar, access_janitor, access_kitchen, access_robotics, access_armory, access_hydroponics,
			            access_theatre, access_research, access_hos, access_RC_announce, access_forensics_lockers, access_keycard_auth)
		if("Head of Personnel")
			return list(access_security, access_brig, access_court, access_forensics_lockers,
			            access_tox, access_tox_storage, access_chemistry, access_medical, access_genetics, access_engine,
			            access_emergency_storage, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
			            access_crematorium, access_kitchen, access_robotics, access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_hydroponics, access_lawyer,
			            access_theatre, access_chapel_office, access_library, access_research, access_mining, access_heads_vault, access_mining_station,
			            access_clown, access_mime, access_hop, access_RC_announce, access_keycard_auth)
		if("Atmospheric Technician")
			return list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_construction)
		if("Bartender")
			return list(access_bar)
		if("Chemist")
			return list(access_medical, access_chemistry)
		if("Janitor")
			return list(access_janitor, access_maint_tunnels)
		if("Clown")
			return list(access_clown, access_theatre)
		if("Mime")
			return list(access_mime, access_theatre)
		if("Chef")
			return list(access_kitchen, access_morgue)
		if("Roboticist")
			return list(access_robotics, access_tech_storage, access_morgue)  //As a job that handles so many corpses, it makes sense for them to have morgue access.
		if("Cargo Technician")
			return list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
		if("Shaft Miner")
			return list(access_mining, access_mint, access_mining_station)
		if("Quartermaster")
			return list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
		if("Chief Engineer")
			return list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_ai_upload, access_construction, access_robotics,
			            access_mint, access_ce, access_RC_announce, access_keycard_auth, access_tcomsat)
		if("Research Director")
			return list(access_rd, access_heads, access_tox, access_genetics,
			            access_tox_storage, access_teleporter,
			            access_research, access_robotics, access_xenobiology,
			            access_RC_announce, access_keycard_auth, access_tcomsat)
		if("Virologist")
			return list(access_medical, access_virology)
		if("Chief Medical Officer")
			return list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth)
		else
			return list()

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
	return list(access_security, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_genetics, access_morgue, access_rd,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_emergency_storage, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_cargo_bot, access_construction,
	            access_hydroponics, access_library, access_manufacturing, access_lawyer, access_virology, access_cmo, access_qm, access_clown, access_mime, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting, access_mint_vault, access_mint,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)
		if(2) //medbay
			return list(access_medical, access_genetics, access_morgue, access_chemistry, access_virology, access_surgery, access_cmo)
		if(3) //research
			return list(access_research, access_tox, access_tox_storage, access_xenobiology, access_rd)
		if(4) //engineering and maintenance
			return list(access_engine, access_engine_equip, access_maint_tunnels, access_external_airlocks, access_tech_storage, access_atmospherics, access_construction, access_robotics, access_ce)
		if(5) //command
			return list(access_heads, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_all_personal_lockers, access_heads_vault, access_RC_announce, access_keycard_auth, access_tcomsat, access_hop, access_captain)
		if(6) //station general
			return list(access_kitchen,access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer, access_clown, access_mime)
		if(7) //supply
			return list(access_cargo, access_cargo_bot, access_mailsorting, access_qm, access_mining, access_mining_station)

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
			return "Brig Cells"
		if(access_court)
			return "Courtroom"
		if(access_forensics_lockers)
			return "Detective's Office"
		if(access_medical)
			return "Medical"
		if(access_genetics)
			return "Genetics Lab"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "Research Lab"
		if(access_tox_storage)
			return "Toxins Storage"
		if(access_chemistry)
			return "Chemistry Lab"
		if(access_rd)
			return "RD Private"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Custodial Closet"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "APCs"
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
			return "Captain Private"
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
		if(access_cmo)
			return "CMO Private"
		if(access_qm)
			return "Quartermaster's Office"
/*		if(access_clown)
			return "HONK! Access"
		if(access_mime)
			return "Silent Access"*/
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
			return "Delivery Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining Station EVA"
		if(access_xenobiology)
			return "Xenobiology Lab"
		if(access_hop)
			return "HoP Private"
		if(access_hos)
			return "HoS Private"
		if(access_ce)
			return "CE Private"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth. Device"
		if(access_tcomsat)
			return "Telecommunications"

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

/proc/get_all_jobs()
	return list("Assistant", "Captain", "Head of Personnel", "Bartender", "Chef", "Botanist", "Quartermaster", "Cargo Technician",
				"Shaft Miner", /*"Clown", "Mime", */"Janitor", "Librarian", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer",
				"Atmospheric Technician", "Roboticist", "Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist",
				"Research Director", "Scientist", "Head of Security", "Warden", "Detective", "Security Officer")

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

/obj/proc/GetJobName()
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/jobName
	var/realJobName

	if(istype(src, /obj/item/device/pda))
		if(src:id)
			jobName = src:id:assignment
			realJobName = src:id:assignment_real_title
	if(istype(src, /obj/item/weapon/card/id))
		jobName = src:assignment
		realJobName = src:id:assignment_real_title

	if(realJobName in get_all_jobs())
		return jobName

	return "Unknown"
