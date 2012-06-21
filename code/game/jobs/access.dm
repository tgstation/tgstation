/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"

/obj/var/list/req_combined_access = null
/obj/var/req_combined_access_txt = "0"

/obj/New()
	//NOTE: If a room requires more than one access (IE: Morgue + medbay) set the req_acesss_txt to "5;6" if it requires 5 and 6
	if(req_access_txt)
		var/list/req_access_str = dd_text2list(req_access_txt,";")
		if(!req_access)
			req_access = list()
		for(var/x in req_access_str)
			var/n = text2num(x)
			if(n)
				req_access |= n

	if(req_combined_access_txt)
		var/list/req_access_str = dd_text2list(req_combined_access_txt,";")
		if(!req_combined_access)
			req_combined_access = list()
		for(var/x in req_access_str)
			var/n = text2num(x)
			if(n)
				req_combined_access |= n

	..()

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
		if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(george.equipped() && (istype(george.equipped(), /obj/item/weapon/card/id) || istype(george.equipped(), /obj/item/device/pda)) && src.check_access(george.equipped()))
			return 1
	return 0

/obj/proc/check_access(obj/item/weapon/card/id/I)

	if (istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id

	if(!req_access) //no requirements
		return 1
	if(!istype(req_access, /list)) //something's very wrong
		return 1
	if(!req_access.len) //no requirements
		if(!req_combined_access || !islist(req_combined_access) || !req_combined_access.len)
			return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(req in I.access) //has an access from the single access list
			return 1
	if(req_combined_access && req_combined_access.len)
		for(var/req in req_combined_access)
			if(!req in I.access)
				return 0
		return 1
	return 0


/obj/proc/check_access_list(var/list/L)
	if(!req_access)
		return 1
	if(!istype(req_access, /list))
		return 1
	if(!req_access.len)
		if(!req_combined_access || !islist(req_combined_access) || !req_combined_access.len)
			return 1
	if(!L)
		return 0
	if(!istype(L, /list))
		return 0
	for(var/req in req_access)
		if(req in L) //has an access from the single access list
			return 1
	if(req_combined_access && req_combined_access.len)
		for(var/req in req_combined_access)
			if(!req in L)
				return 0
		return 1
	return 0


/proc/get_access(job)
	switch(job)
		if("Geneticist")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS)
		if("Station Engineer")
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION)
		if("Assistant")
			return list()
		if("Chaplain")
			return list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM)
		if("Detective")
			return list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT)
		if("Medical Doctor")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_VIROLOGY)
		if("Botanist")	// -- TLE
			return list(ACCESS_HYDROPONICS) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT
		if("Librarian") // -- TLE
			return list(ACCESS_LIBRARY)
		if("Lawyer") //Muskets 160910
			return list(ACCESS_LAWYER, ACCESS_COURT)
		if("Captain")
			return get_all_accesses()
		if("Security Officer")
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
		if("Warden")
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
		if("Scientist")
			return list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY)
		if("Head of Security")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_COURT,
			            ACCESS_TELEPORTER, ACCESS_HEADS, ACCESS_TECH_STORAGE, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ATMOSPHERICS,
			            ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_KITCHEN, ACCESS_ROBOTICS, ACCESS_ARMORY, ACCESS_HYDROPONICS,
			            ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_FORENSICS_LOCKERS, ACCESS_KEYCARD_AUTH)
		if("Head of Personnel")
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_ENGINE,
			            ACCESS_EMERGENCY_STORAGE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_ROBOTICS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH)
		if("Atmospheric Technician")
			return list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EMERGENCY_STORAGE)
		if("Bartender")
			return list(ACCESS_BAR)
		if("Chemist")
			return list(ACCESS_MEDICAL, ACCESS_CHEMISTRY)
		if("Janitor")
			return list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)
		if("Clown")
			return list(ACCESS_CLOWN, ACCESS_THEATRE)
		if("Mime")
			return list(ACCESS_MIME, ACCESS_THEATRE)
		if("Chef")
			return list(ACCESS_KITCHEN)
		if("Roboticist")
			return list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE) //As a job that handles so many corpses, it makes sense for them to have morgue access.
		if("Cargo Technician")
			return list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING)
		if("Shaft Miner")
			return list(ACCESS_MINING, ACCESS_MINT, ACCESS_MINING_STATION)
		if("Quartermaster")
			return list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION)
		if("Chief Engineer")
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_AI_UPLOAD, ACCESS_CONSTRUCTION, ACCESS_ROBOTICS,
			            ACCESS_MINT, ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)
		if("Research Director")
			return list(ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS,
			            ACCESS_TOX_STORAGE, ACCESS_TELEPORTER,
			            ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY,
			            ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)
//		if("Virologist")
//			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_VIROLOGY)
		if("Chief Medical Officer")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH)
		else
			return list()

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(ACCESS_CENT_GENERAL)
		if("Custodian")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Thunderdome Overseer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
		if("Intel Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("Medical Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
		if("Death Commando")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Research Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
		if("BlackOps Commander")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_CREED)
		if("Supreme Commander")
			return get_all_centcom_access()

/proc/get_all_accesses()
	return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT,
	            ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_MORGUE, ACCESS_RD,
	            ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS,
	            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD,
	            ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS,
	            ACCESS_TECH_STORAGE, ACCESS_CHAPEL_OFFICE, ACCESS_ATMOSPHERICS, ACCESS_KITCHEN,
	            ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_ROBOTICS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_CONSTRUCTION,
	            ACCESS_HYDROPONICS, ACCESS_LIBRARY, ACCESS_MANUFACTURING, ACCESS_LAWYER, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_QM, ACCESS_CLOWN, ACCESS_MIME, ACCESS_SURGERY,
	            ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_MAILSORTING, ACCESS_MINT_VAULT, ACCESS_MINT,
	            ACCESS_HEADS_VAULT, ACCESS_MINING_STATION, ACCESS_XENOBIOLOGY, ACCESS_CE, ACCESS_HOP, ACCESS_HOS, ACCESS_RC_ANNOUNCE,
	            ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)

/proc/get_all_centcom_access()
	return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_TELEPORTER, ACCESS_CENT_CREED, ACCESS_CENT_CAPTAIN)

/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_HOS)
		if(2) //medbay
			return list(ACCESS_MEDICAL, ACCESS_GENETICS, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_CMO)
		if(3) //research
			return list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_XENOBIOLOGY, ACCESS_RD)
		if(4) //engineering and maintenance
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_CONSTRUCTION, ACCESS_ROBOTICS, ACCESS_CE)
		if(5) //command
			return list(ACCESS_HEADS, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_HEADS_VAULT, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_HOP, ACCESS_CAPTAIN)
		if(6) //station general
			return list(ACCESS_KITCHEN,ACCESS_BAR, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_THEATRE, ACCESS_LAWYER, ACCESS_CLOWN, ACCESS_MIME)
		if(7) //supply
			return list(ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION)

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
		if(ACCESS_CARGO)
			return "Cargo Bay"
		if(ACCESS_CARGO_BOT)
			return "Cargo Bot Delivery"
		if(ACCESS_SECURITY)
			return "Security"
		if(ACCESS_BRIG)
			return "Brig Cells"
		if(ACCESS_COURT)
			return "Courtroom"
		if(ACCESS_FORENSICS_LOCKERS)
			return "Detective's Office"
		if(ACCESS_MEDICAL)
			return "Medical"
		if(ACCESS_GENETICS)
			return "Genetics Lab"
		if(ACCESS_MORGUE)
			return "Morgue"
		if(ACCESS_TOX)
			return "Research Lab"
		if(ACCESS_TOX_STORAGE)
			return "Toxins Storage"
		if(ACCESS_CHEMISTRY)
			return "Chemistry Lab"
		if(ACCESS_RD)
			return "RD Private"
		if(ACCESS_BAR)
			return "Bar"
		if(ACCESS_JANITOR)
			return "Custodial Closet"
		if(ACCESS_ENGINE)
			return "Engineering"
		if(ACCESS_ENGINE_EQUIP)
			return "APCs"
		if(ACCESS_MAINT_TUNNELS)
			return "Maintenance"
		if(ACCESS_EXTERNAL_AIRLOCKS)
			return "External Airlocks"
		if(ACCESS_EMERGENCY_STORAGE)
			return "Emergency Storage"
		if(ACCESS_CHANGE_IDS)
			return "ID Computer"
		if(ACCESS_AI_UPLOAD)
			return "AI Upload"
		if(ACCESS_TELEPORTER)
			return "Teleporter"
		if(ACCESS_EVA)
			return "EVA"
		if(ACCESS_HEADS)
			return "Bridge"
		if(ACCESS_CAPTAIN)
			return "Captain's Quarters"
		if(ACCESS_ALL_PERSONAL_LOCKERS)
			return "Personal Lockers"
		if(ACCESS_CHAPEL_OFFICE)
			return "Chapel Office"
		if(ACCESS_TECH_STORAGE)
			return "Technical Storage"
		if(ACCESS_ATMOSPHERICS)
			return "Atmospherics"
		if(ACCESS_CREMATORIUM)
			return "Crematorium"
		if(ACCESS_ARMORY)
			return "Armory"
		if(ACCESS_CONSTRUCTION)
			return "Construction Areas"
		if(ACCESS_KITCHEN)
			return "Kitchen"
		if(ACCESS_HYDROPONICS)
			return "Hydroponics"
		if(ACCESS_LIBRARY)
			return "Library"
		if(ACCESS_LAWYER)
			return "Law Office"
		if(ACCESS_ROBOTICS)
			return "Robotics"
		if(ACCESS_VIROLOGY)
			return "Virology"
		if(ACCESS_CMO)
			return "CMO Private"
		if(ACCESS_QM)
			return "Quartermaster's Office"
		if(ACCESS_CLOWN)
			return "HONK! Access"
		if(ACCESS_MIME)
			return "Silent Access"
		if(ACCESS_SURGERY)
			return "Operating Room"
		if(ACCESS_THEATRE)
			return "Theatre"
		if(ACCESS_MANUFACTURING)
			return "Manufacturing"
		if(ACCESS_RESEARCH)
			return "Research"
		if(ACCESS_MINING)
			return "Mining"
		if(ACCESS_MINING_OFFICE)
			return "Mining Office"
		if(ACCESS_MAILSORTING)
			return "Delivery Office"
		if(ACCESS_MINT)
			return "Mint"
		if(ACCESS_MINT_VAULT)
			return "Mint Vault"
		if(ACCESS_HEADS_VAULT)
			return "Main Vault"
		if(ACCESS_MINING_STATION)
			return "Mining Station EVA"
		if(ACCESS_XENOBIOLOGY)
			return "Xenobiology Lab"
		if(ACCESS_HOP)
			return "HoP Private"
		if(ACCESS_HOS)
			return "HoS Private"
		if(ACCESS_CE)
			return "CE Private"
		if(ACCESS_RC_ANNOUNCE)
			return "RC Announcements"
		if(ACCESS_KEYCARD_AUTH)
			return "Keycode Auth. Device"
		if(ACCESS_TCOMSAT)
			return "Telecoms Satellite"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_CENT_GENERAL)
			return "Code Grey"
		if(ACCESS_CENT_THUNDER)
			return "Code Yellow"
		if(ACCESS_CENT_STORAGE)
			return "Code Orange"
		if(ACCESS_CENT_LIVING)
			return "Code Green"
		if(ACCESS_CENT_MEDICAL)
			return "Code White"
		if(ACCESS_CENT_TELEPORTER)
			return "Code Blue"
		if(ACCESS_CENT_SPECOPS)
			return "Code Black"
		if(ACCESS_CENT_CREED)
			return "Code Silver"
		if(ACCESS_CENT_CAPTAIN)
			return "Code Gold"

/proc/get_all_jobs()
	return list("Assistant", "Captain", "Head of Personnel", "Bartender", "Chef", "Botanist", "Quartermaster", "Cargo Technician",
				"Shaft Miner", "Janitor", "Librarian", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer",
				"Atmospheric Technician", "Roboticist", "Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist",
				"Research Director", "Scientist", "Head of Security", "Warden", "Detective", "Security Officer")

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

/obj/proc/GetJobName()
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/jobName
	var/list/accesses = list()

	if(istype(src, /obj/item/device/pda))
		if(src:id)
			jobName = src:id:assignment
			accesses = src:id:access
	if(istype(src, /obj/item/weapon/card/id))
		jobName = src:assignment
		accesses = src:access

	if(jobName in get_all_jobs())
		return jobName

	// hack for alt titles
	if(istype(loc, /mob))
		var/mob/M = loc
		if(M.mind.role_alt_title == jobName && M.mind.assigned_role in get_all_jobs())
			return M.mind.assigned_role

	var/centcom = 0
	for(var/i = 1, i <= accesses.len, i++)
		if(accesses[i] > 100)
			centcom = 1
			break
	if(centcom)
		return "centcom"
	else
		return "Unknown"
