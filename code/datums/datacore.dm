GLOBAL_DATUM_INIT(data_core, /datum/datacore, new)

//TODO: someone please get rid of this shit
/datum/datacore
	/// All of the crew records.
	var/list/general = list()
	var/print_count = 0
	var/crime_counter = 0
	/// This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()

/datum/data
	var/name

/datum/datacore/proc/manifest()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/N = i
		if(N.new_character)
			log_manifest(N.ckey,N.new_character.mind,N.new_character)
		if(ishuman(N.new_character))
			manifest_inject(N.new_character)
		CHECK_TICK

/datum/datacore/proc/manifest_modify(name, assignment, trim)
	var/datum/record/crew/found_record = find_record(name)
	if(found_record)
		found_record.rank = assignment
		found_record.trim = trim

/datum/datacore/proc/get_manifest()
	// First we build up the order in which we want the departments to appear in.
	var/list/manifest_out = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		manifest_out[department.department_name] = list()
	manifest_out[DEPARTMENT_UNASSIGNED] = list()

	var/list/departments_by_type = SSjob.joinable_departments_by_type
	for(var/datum/record/crew/record as anything in GLOB.data_core.general)
		var/name = record.name
		var/rank = record.rank // user-visible job
		var/trim = record.trim // internal jobs by trim type
		var/datum/job/job = SSjob.GetJob(trim)
		if(!job || !(job.job_flags & JOB_CREW_MANIFEST) || !LAZYLEN(job.departments_list)) // In case an unlawful custom rank is added.
			var/list/misc_list = manifest_out[DEPARTMENT_UNASSIGNED]
			misc_list[++misc_list.len] = list(
				"name" = name,
				"rank" = rank,
				)
			continue
		for(var/department_type as anything in job.departments_list)
			var/datum/job_department/department = departments_by_type[department_type]
			if(!department)
				stack_trace("get_manifest() failed to get job department for [department_type] of [job.type]")
				continue
			var/list/entry = list(
				"name" = name,
				"rank" = rank,
				)
			var/list/department_list = manifest_out[department.department_name]
			if(istype(job, department.department_head))
				department_list.Insert(1, null)
				department_list[1] = entry
			else
				department_list[++department_list.len] = entry

	// Trim the empty categories.
	for (var/department in manifest_out)
		if(!length(manifest_out[department]))
			manifest_out -= department

	return manifest_out

/datum/datacore/proc/get_manifest_html(monochrome = FALSE)
	var/list/manifest = get_manifest()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th></tr>
	"}
	for(var/department in manifest)
		var/list/entries = manifest[department]
		dat += "<tr><th colspan=3>[department]</th></tr>"
		//JUST
		var/even = FALSE
		for(var/entry in entries)
			var/list/entry_list = entry
			dat += "<tr[even ? " class='alt'" : ""]><td>[entry_list["name"]]</td><td>[entry_list["rank"]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "")
	dat = replacetext(dat, "\t", "")
	return dat


/datum/datacore/proc/manifest_inject(mob/living/carbon/human/person)
	set waitfor = FALSE
	if(!(person.mind?.assigned_role.job_flags & JOB_CREW_MANIFEST))
		return

	var/assignment = person.mind.assigned_role.title
	var/static/record_id_num = 1001
	var/id_number = num2hex(record_id_num++, 6)
	var/mutable_appearance/character_appearance = new(person.appearance)
	var/person_gender = "Other"
	if(person.gender == "male")
		person_gender = "Male"
	if(person.gender == "female")
		person_gender = "Female"

	new /datum/record/crew(
		age = person.age,
		blood_type = person.dna.blood_type,
		character_appearance = character_appearance,
		dna_string = person.dna.unique_enzymes,
		fingerprint = md5(person.dna.unique_identity),
		gender = person_gender,
		id_number = id_number,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = person.dna.species.name,
		trim = assignment,
		// Crew specific
		major_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY),
		major_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MAJOR_DISABILITY),
		minor_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY),
		minor_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MINOR_DISABILITY),
		quirk_notes = person.get_quirk_string(TRUE, CAT_QUIRK_NOTES),
	)

	new /datum/record/locked(
		age = person.age,
		blood_type = person.dna.blood_type,
		dna_string = person.dna.unique_enzymes,
		fingerprint = md5(person.dna.unique_identity),
		gender = person_gender,
		id_number = id_number,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = person.dna.species.name,
		trim = assignment,
		// Locked specific
		dna_ref = person.dna,
		mindref = person.mind,
	)

	return

//Todo: Add citations to the prinout - you get them from sec record's "citation" field, same as "crim" (which is frankly a terrible fucking field name)
///Standardized printed records. SPRs. Like SATs but for bad guys who probably didn't actually finish school. Input the records and out comes a paper.
/datum/datacore/proc/print_security_record(datum/record/crew/crew_record, atom/location)
	if(!istype(crew_record))
		stack_trace("called without any datacores! this may or may not be intentional!")
	if(!isatom(location)) //can't drop the paper if we didn't get passed an atom.
		CRASH("NO VALID LOCATION PASSED.")

	print_count++ //just alters the name of the paper.
	var/obj/item/paper/printed_paper = new(location)
	var/final_paper_text = "<CENTER><B>Security Record - (SR-[print_count])</B></CENTER><BR>"
	if(!istype(crew_record, /datum/record/crew) && general.Find(crew_record))
		final_paper_text += "<B>General Record Lost!</B><BR>"
		return

	final_paper_text += text("Name: [] ID: []<BR>\nGender: []<BR>\nAge: []<BR>", crew_record.name, crew_record.id_number, crew_record.gender, crew_record.age)
	final_paper_text += "\nSpecies: [crew_record.species]<BR>"
	final_paper_text += text("\nFingerprint: []<BR>", crew_record.fingerprint)
	final_paper_text += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []", crew_record.wanted_status)
	final_paper_text += "<BR>\n<BR>\nCrimes:<BR>\n"
	final_paper_text += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						</tr>"}
	for(var/datum/crime/crime in crew_record.crimes)
		final_paper_text += "<tr><td>[crime.name]</td>"
		final_paper_text += "<td>[crime.details]</td>"
		final_paper_text += "<td>[crime.author]</td>"
		final_paper_text += "<td>[crime.time]</td>"
		final_paper_text += "</tr>"
	final_paper_text += "</table>"

	final_paper_text += text("<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", crew_record.security_notes)
	printed_paper.name = text("CR-[] '[]'", print_count, crew_record.name)
	final_paper_text += "</TT>"
	printed_paper.add_raw_text(final_paper_text)
	printed_paper.update_appearance() //make sure we make the paper look like it has writing on it.
