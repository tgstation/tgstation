GLOBAL_DATUM_INIT(manifest, /datum/manifest, new)

/** Stores crew records. */
/datum/manifest
	/// All of the crew records.
	var/list/general = list()
	/// This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()
	/// Total number of security rapsheet prints. Changes the header.
	var/print_count = 0

/// Builds the list of crew records for all crew members.
/datum/manifest/proc/build()
	// List of mobs we want to mass insert into the manifest table at round start
	var/list/players_to_log = list()
	for(var/mob/dead/new_player/readied_player as anything in GLOB.new_player_list)
		if(readied_player.new_character)
			log_manifest(readied_player.ckey, readied_player.new_character.mind, readied_player.new_character)
			players_to_log[readied_player.ckey] = readied_player.new_character
		if(ishuman(readied_player.new_character))
			inject(readied_player.new_character)
		CHECK_TICK
	if(length(players_to_log))
		SSblackbox.ReportRoundstartManifest(players_to_log)

/// Gets the current manifest.
/datum/manifest/proc/get_manifest()
	// First we build up the order in which we want the departments to appear in.
	var/list/manifest_out = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		manifest_out[department.department_name] = list()
	manifest_out[DEPARTMENT_UNASSIGNED] = list()

	var/list/departments_by_type = SSjob.joinable_departments_by_type
	for(var/datum/record/crew/target as anything in GLOB.manifest.general)
		var/name = target.name
		var/rank = target.rank // user-visible job
		var/trim = target.trim // internal jobs by trim type
		var/datum/job/job = SSjob.get_job(trim)
		if(!job || !(job.job_flags & JOB_CREW_MANIFEST) || !LAZYLEN(job.departments_list)) // In case an unlawful custom rank is added.
			var/list/misc_list = manifest_out[DEPARTMENT_UNASSIGNED]
			misc_list[++misc_list.len] = list(
				"name" = name,
				"rank" = rank,
				"trim" = trim,
				)
			continue
		for(var/department_type in job.departments_list)
			//Jobs under multiple departments should only be displayed if this is their first department or the command department
			if(job.departments_list[1] != department_type && !(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
				continue
			var/datum/job_department/department = departments_by_type[department_type]
			if(!department)
				stack_trace("get_manifest() failed to get job department for [department_type] of [job.type]")
				continue
			var/list/entry = list(
				"name" = name,
				"rank" = rank,
				"trim" = trim,
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

/// Returns the manifest as an html.
/datum/manifest/proc/get_html(monochrome = FALSE)
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


/// Injects a record into the manifest.
/datum/manifest/proc/inject(mob/living/carbon/human/person, atom/appearance_proxy)
	set waitfor = FALSE
	if(!(person.mind?.assigned_role.job_flags & JOB_CREW_MANIFEST))
		return

	// Attempt to get assignment from ID, otherwise default to mind.
	var/obj/item/card/id/id_card = person.get_idcard(hand_first = FALSE)
	var/assignment = id_card?.get_trim_assignment() || person.mind.assigned_role.title

	var/mutable_appearance/character_appearance = new(appearance_proxy?.appearance || person.appearance)
	var/person_gender = "Other"
	if(person.gender == "male")
		person_gender = "Male"
	if(person.gender == "female")
		person_gender = "Female"
	var/datum/dna/stored/record_dna = new()
	person.dna.copy_dna(record_dna)

	var/datum/record/locked/lockfile = new(
		age = person.age,
		blood_type = person.get_bloodtype()?.name || "UNKNOWN",
		character_appearance = character_appearance,
		dna_string = record_dna.unique_enzymes,
		fingerprint = md5(record_dna.unique_identity),
		gender = person_gender,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = record_dna.species.name,
		trim = assignment,
		// Locked specifics
		locked_dna = record_dna,
		mind_ref = person.mind,
	)

	new /datum/record/crew(
		age = person.age,
		blood_type = person.get_bloodtype()?.name || "UNKNOWN",
		character_appearance = character_appearance,
		dna_string = record_dna.unique_enzymes,
		fingerprint = md5(record_dna.unique_identity),
		gender = person_gender,
		initial_rank = assignment,
		name = person.real_name,
		rank = assignment,
		species = record_dna.species.name,
		trim = assignment,
		// Crew specific
		lock_ref = REF(lockfile),
		major_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE),
		major_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MAJOR_DISABILITY),
		minor_disabilities = person.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, from_scan = TRUE),
		minor_disabilities_desc = person.get_quirk_string(TRUE, CAT_QUIRK_MINOR_DISABILITY),
		quirk_notes = person.get_quirk_string(TRUE, CAT_QUIRK_NOTES),
	)

/// Edits the rank and trim of the found record.
/datum/manifest/proc/modify(name, assignment, trim)
	var/datum/record/crew/target = find_record(name)
	if(!target)
		return

	target.rank = assignment
	target.trim = trim

///Removes a record based on its name.
/datum/manifest/proc/remove(name)
	var/datum/record/crew/target = find_record(name)
	if(!target)
		return
	general -= target
	qdel(target)

/**
 * Using the name to find the record, and person in reference to the body, we recreate photos for the manifest (and records).
 * Args:
 * - name - The name of the record we're looking for, which should be the name of the person.
 * - person - The mob we're taking pictures of to update the records.
 * - add_height_chart - If we should add a height chart to the background of the photo.
 */
/datum/manifest/proc/change_pictures(name, mob/living/person, add_height_chart = FALSE)
	var/datum/record/crew/target = find_record(name)
	if(!target)
		return FALSE

	target.character_appearance = new(person.appearance)
	target.recreate_manifest_photos(add_height_chart)
	return TRUE

/datum/manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/manifest/ui_status(mob/user, datum/ui_state/state)
	return (isnewplayer(user) || isobserver(user) || isAI(user) || ispAI(user) || user.client?.holder) ? UI_INTERACTIVE : UI_CLOSE

/datum/manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CrewManifest")
		ui.open()

/datum/manifest/ui_data(mob/user)
	var/list/positions = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/open = 0
		var/list/exceptions = list()
		for(var/datum/job/job as anything in department.department_jobs)
			if(job.total_positions == -1)
				exceptions += job.title
				continue
			var/open_slots = job.total_positions - job.current_positions
			if(open_slots < 1)
				continue
			open += open_slots
		positions[department.department_name] = list("exceptions" = exceptions, "open" = open)

	return list(
		"manifest" = get_manifest(),
		"positions" = positions
	)
