/datum/computer_file/program/records
	filename = "ntrecords"
	filedesc = "Records"
	extended_desc = "Allows the user to view several basic records from the crew."
	category = PROGRAM_CATEGORY_MISC
	program_icon = "clipboard"
	program_icon_state = "crew"
	tgui_id = "NtosRecords"
	size = 4
	usage_flags = PROGRAM_TABLET | PROGRAM_LAPTOP
	available_on_ntnet = FALSE
	detomatix_resistance = DETOMATIX_RESIST_MINOR

	var/mode

/datum/computer_file/program/records/medical
	filedesc = "Medical Records"
	filename = "medrecords"
	program_icon = "book-medical"
	extended_desc = "Allows the user to view several basic medical records from the crew."
	transfer_access = list(ACCESS_MEDICAL, ACCESS_FLAG_COMMAND)
	available_on_ntnet = TRUE
	mode = "medical"

/datum/computer_file/program/records/security
	filedesc = "Security Records"
	filename = "secrecords"
	extended_desc = "Allows the user to view several basic security records from the crew."
	transfer_access = list(ACCESS_SECURITY, ACCESS_FLAG_COMMAND)
	available_on_ntnet = TRUE
	mode = "security"

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



/datum/computer_file/program/records/ui_data(mob/user)
	var/list/data = list()
	data["records"] = GetRecordsReadable()
	data["mode"] = mode
	return data
