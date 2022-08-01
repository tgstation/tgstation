GLOBAL_DATUM_INIT(data_core, /datum/datacore, new)

//TODO: someone please get rid of this shit
/datum/datacore
	var/list/medical = list()
	var/medicalPrintCount = 0
	var/list/general = list()
	var/list/security = list()
	var/securityPrintCount = 0
	var/securityCrimeCounter = 0
	///This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()

/datum/data
	var/name = "data"

/datum/data/record
	name = "record"
	var/list/fields = list()

/datum/data/record/Destroy()
	if(src in GLOB.data_core.medical)
		GLOB.data_core.medical -= src
	if(src in GLOB.data_core.security)
		GLOB.data_core.security -= src
	if(src in GLOB.data_core.general)
		GLOB.data_core.general -= src
	if(src in GLOB.data_core.locked)
		GLOB.data_core.locked -= src
	. = ..()

/datum/data/crime
	name = "crime"
	var/crimeName = ""
	var/crimeDetails = ""
	var/author = ""
	var/time = ""
	var/fine = 0
	var/paid = 0
	var/dataId = 0

/datum/datacore/proc/createCrimeEntry(cname = "", cdetails = "", author = "", time = "", fine = 0)
	var/datum/data/crime/c = new /datum/data/crime
	c.crimeName = cname
	c.crimeDetails = cdetails
	c.author = author
	c.time = time
	c.fine = fine
	c.paid = 0
	c.dataId = ++securityCrimeCounter
	return c

/datum/datacore/proc/addCitation(id = "", datum/data/crime/crime)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["citation"]
			crimes |= crime
			return

/datum/datacore/proc/removeCitation(id, cDataId)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["citation"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					return

/datum/datacore/proc/payCitation(id, cDataId, amount)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["citation"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crime.paid = crime.paid + amount
					var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SEC)
					D.adjust_money(amount)
					return

/**
 * Adds crime to security record.
 *
 * Is used to add single crime to someone's security record.
 * Arguments:
 * * id - record id.
 * * datum/data/crime/crime - premade array containing every variable, usually created by createCrimeEntry.
 */
/datum/datacore/proc/addCrime(id = "", datum/data/crime/crime)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["crim"]
			crimes |= crime
			return

/**
 * Deletes crime from security record.
 *
 * Is used to delete single crime to someone's security record.
 * Arguments:
 * * id - record id.
 * * cDataId - id of already existing crime.
 */
/datum/datacore/proc/removeCrime(id, cDataId)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crimes -= crime
					return

/**
 * Adds details to a crime.
 *
 * Is used to add or replace details to already existing crime.
 * Arguments:
 * * id - record id.
 * * cDataId - id of already existing crime.
 * * details - data you want to add.
 */
/datum/datacore/proc/addCrimeDetails(id, cDataId, details)
	for(var/datum/data/record/R in security)
		if(R.fields["id"] == id)
			var/list/crimes = R.fields["crim"]
			for(var/datum/data/crime/crime in crimes)
				if(crime.dataId == text2num(cDataId))
					crime.crimeDetails = details
					return

/datum/datacore/proc/manifest()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/N = i
		if(N.new_character)
			log_manifest(N.ckey,N.new_character.mind,N.new_character)
		if(ishuman(N.new_character))
			manifest_inject(N.new_character)
		CHECK_TICK

/datum/datacore/proc/manifest_modify(name, assignment, trim)
	var/datum/data/record/foundrecord = find_record("name", name, GLOB.data_core.general)
	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["trim"] = trim


/datum/datacore/proc/get_manifest()
	// First we build up the order in which we want the departments to appear in.
	var/list/manifest_out = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		manifest_out[department.department_name] = list()
	manifest_out[DEPARTMENT_UNASSIGNED] = list()

	var/list/departments_by_type = SSjob.joinable_departments_by_type
	for(var/datum/data/record/record as anything in GLOB.data_core.general)
		var/name = record.fields["name"]
		var/rank = record.fields["rank"] // user-visible job
		var/trim = record.fields["trim"] // internal jobs by trim type
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


/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H)
	set waitfor = FALSE
	var/static/list/show_directions = list(SOUTH, WEST)
	if(H.mind?.assigned_role.job_flags & JOB_CREW_MANIFEST)
		var/assignment = H.mind.assigned_role.title

		var/static/record_id_num = 1001
		var/id = num2hex(record_id_num++,6)
		var/image = get_id_photo(H, show_directions)
		var/datum/picture/pf = new
		var/datum/picture/ps = new
		pf.picture_name = "[H]"
		ps.picture_name = "[H]"
		pf.picture_desc = "This is [H]."
		ps.picture_desc = "This is [H]."
		pf.picture_image = icon(image, dir = SOUTH)
		ps.picture_image = icon(image, dir = WEST)
		var/obj/item/photo/photo_front = new(null, pf)
		var/obj/item/photo/photo_side = new(null, ps)

		//These records should ~really~ be merged or something
		//General Record
		var/datum/data/record/G = new()
		G.fields["id"] = id
		G.fields["name"] = H.real_name
		G.fields["rank"] = assignment
		G.fields["trim"] = assignment
		G.fields["initial_rank"] = assignment
		G.fields["age"] = H.age
		G.fields["species"] = H.dna.species.name
		G.fields["fingerprint"] = md5(H.dna.unique_identity)
		G.fields["p_stat"] = "Active"
		G.fields["m_stat"] = "Stable"
		G.fields["gender"] = H.gender
		if(H.gender == "male")
			G.fields["gender"] = "Male"
		else if(H.gender == "female")
			G.fields["gender"] = "Female"
		else
			G.fields["gender"] = "Other"
		G.fields["photo_front"] = photo_front
		G.fields["photo_side"] = photo_side
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"] = id
		M.fields["name"] = H.real_name
		M.fields["blood_type"] = H.dna.blood_type
		M.fields["b_dna"] = H.dna.unique_enzymes
		M.fields["mi_dis"] = H.get_quirk_string(!medical, CAT_QUIRK_MINOR_DISABILITY)
		M.fields["mi_dis_d"] = H.get_quirk_string(medical, CAT_QUIRK_MINOR_DISABILITY)
		M.fields["ma_dis"] = H.get_quirk_string(!medical, CAT_QUIRK_MAJOR_DISABILITY)
		M.fields["ma_dis_d"] = H.get_quirk_string(medical, CAT_QUIRK_MAJOR_DISABILITY)
		M.fields["cdi"] = "None"
		M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
		M.fields["notes"] = H.get_quirk_string(!medical, CAT_QUIRK_NOTES)
		M.fields["notes_d"] = H.get_quirk_string(medical, CAT_QUIRK_NOTES)
		medical += M

		//Security Record
		var/datum/data/record/S = new()
		S.fields["id"] = id
		S.fields["name"] = H.real_name
		S.fields["criminal"] = "None"
		S.fields["citation"] = list()
		S.fields["crim"] = list()
		S.fields["notes"] = "No notes."
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"] = md5("[H.real_name][assignment]") //surely this should just be id, like the others?
		L.fields["name"] = H.real_name
		L.fields["rank"] = assignment
		L.fields["trim"] = assignment
		G.fields["initial_rank"] = assignment
		L.fields["age"] = H.age
		L.fields["gender"] = H.gender
		if(H.gender == "male")
			G.fields["gender"] = "Male"
		else if(H.gender == "female")
			G.fields["gender"] = "Female"
		else
			G.fields["gender"] = "Other"
		L.fields["blood_type"] = H.dna.blood_type
		L.fields["b_dna"] = H.dna.unique_enzymes
		L.fields["identity"] = H.dna.unique_identity
		L.fields["species"] = H.dna.species.type
		L.fields["features"] = H.dna.features
		L.fields["image"] = image
		L.fields["mindref"] = H.mind
		locked += L
	return

/datum/datacore/proc/get_id_photo(mob/living/carbon/human/human, show_directions = list(SOUTH))
	return get_flat_existing_human_icon(human, show_directions)
