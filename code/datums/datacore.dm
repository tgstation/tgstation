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
	var/mutable_appearance/character_appearance = new(person.appearance)
	var/person_gender = "Other"
	if(person.gender == "male")
		person_gender = "Male"
	if(person.gender == "female")
		person_gender = "Female"

	var/datum/record/locked/lockfile = new(
		age = person.age,
		blood_type = person.dna.blood_type,
		character_appearance = character_appearance,
		dna_string = person.dna.unique_enzymes,
		fingerprint = md5(person.dna.unique_identity),
		gender = person_gender,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = person.dna.species.name,
		trim = assignment,
		// Locked specifics
		dna_ref = person.dna,
		mind_ref = person.mind,
	)

	new /datum/record/crew(
		age = person.age,
		blood_type = person.dna.blood_type,
		character_appearance = character_appearance,
		dna_string = person.dna.unique_enzymes,
		fingerprint = md5(person.dna.unique_identity),
		gender = person_gender,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = person.dna.species.name,
		trim = assignment,
		// Crew specific
		lock_ref = REF(lockfile),
		major_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY),
		major_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MAJOR_DISABILITY),
		minor_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY),
		minor_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MINOR_DISABILITY),
		quirk_notes = person.get_quirk_string(TRUE, CAT_QUIRK_NOTES),
	)

	return

