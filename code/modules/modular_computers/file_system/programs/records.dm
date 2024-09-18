/datum/computer_file/program/records
	filename = "ntrecords"
	filedesc = "Records"
	extended_desc = "Allows the user to view several basic records from the crew."
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_icon = "clipboard"
	program_open_overlay = "crew"
	tgui_id = "NtosRecords"
	size = 4
	can_run_on_flags = PROGRAM_PDA | PROGRAM_LAPTOP
	program_flags = NONE
	detomatix_resistance = DETOMATIX_RESIST_MINOR

	var/mode

/datum/computer_file/program/records/medical
	filedesc = "Medical Records"
	filename = "medrecords"
	program_icon = "book-medical"
	extended_desc = "Allows the user to view several basic medical records from the crew."
	download_access = list(ACCESS_MEDICAL, ACCESS_FLAG_COMMAND)
	program_flags = PROGRAM_ON_NTNET_STORE
	mode = "medical"

/datum/computer_file/program/records/security
	filedesc = "Security Records"
	filename = "secrecords"
	extended_desc = "Allows the user to view several basic security records from the crew."
	download_access = list(ACCESS_SECURITY, ACCESS_FLAG_COMMAND)
	program_flags = PROGRAM_ON_NTNET_STORE
	mode = "security"
	detomatix_resistance = DETOMATIX_RESIST_MINOR

/datum/computer_file/program/records/proc/GetRecordsReadable()
	var/list/all_records = list()

	switch(mode)
		if("security")
			for(var/datum/record/crew/person in GLOB.manifest.general)
				var/list/current_record = list()

				current_record["age"] = person.age
				current_record["fingerprint"] = person.fingerprint
				current_record["gender"] = person.gender
				current_record["name"] = person.name
				current_record["rank"] = person.rank
				current_record["species"] = person.species
				current_record["wanted"] = person.wanted_status
				current_record["voice"] = person.voice

				all_records += list(current_record)
		if("medical")
			for(var/datum/record/crew/person in GLOB.manifest.general)
				var/list/current_record = list()

				current_record["bloodtype"] = person.blood_type
				current_record["ma_dis"] = person.major_disabilities_desc
				current_record["mi_dis"] = person.minor_disabilities_desc
				current_record["physical_status"] = person.physical_status
				current_record["mental_status"] = person.mental_status
				current_record["name"] = person.name
				current_record["notes"] = person.medical_notes

				all_records += list(current_record)

	return all_records

/datum/computer_file/program/records/ui_static_data(mob/user)
	var/list/data = list()
	data["records"] = GetRecordsReadable()
	data["mode"] = mode
	return data
