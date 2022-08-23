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
	GLOB.data_core.medical -= src
	GLOB.data_core.security -= src
	GLOB.data_core.general -= src
	GLOB.data_core.locked -= src
	. = ..()

/// A helper proc to get the front photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/data/record/proc/get_front_photo()
	return get_photo("photo_front", SOUTH)

/// A helper proc to get the side photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/data/record/proc/get_side_photo()
	return get_photo("photo_side", WEST)

/**
 * You shouldn't be calling this directly, use `get_front_photo()` or `get_side_photo()`
 * instead.
 *
 * This is the proc that handles either fetching (if it was already generated before) or
 * generating (if it wasn't) the specified photo from the specified record. This is only
 * intended to be used by records that used to try to access `fields["photo_front"]` or
 * `fields["photo_side"]`, and will return an empty icon if there isn't any of the necessary
 * fields.
 *
 * Arguments:
 * * field_name - The name of the key in the `fields` list, of the record itself.
 * * orientation - The direction in which you want the character appearance to be rotated
 * in the outputed photo.
 *
 * Returns an empty `/icon` if there was no `character_appearance` entry in the `fields` list,
 * returns the generated/cached photo otherwise.
 */
/datum/data/record/proc/get_photo(field_name, orientation)
	if(fields[field_name])
		return fields[field_name]

	if(!fields["character_appearance"])
		return new /icon()

	var/mutable_appearance/character_appearance = fields["character_appearance"]
	character_appearance.setDir(orientation)

	var/icon/picture_image = getFlatIcon(character_appearance)

	var/datum/picture/picture = new
	picture.picture_name = "[fields["name"]]"
	picture.picture_desc = "This is [fields["name"]]."
	picture.picture_image = picture_image

	var/obj/item/photo/photo = new(null, picture)
	fields[field_name] = photo
	return photo

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
		// We need to compile the overlays now, otherwise we're basically copying an empty icon.
		COMPILE_OVERLAYS(H)
		var/mutable_appearance/character_appearance = new(H.appearance)

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
		G.fields["character_appearance"] = character_appearance
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
		L.fields["character_appearance"] = character_appearance
		L.fields["mindref"] = H.mind
		locked += L
	return

/datum/datacore/proc/get_id_photo(mob/living/carbon/human/human, show_directions = list(SOUTH))
	return get_flat_existing_human_icon(human, show_directions)

//Todo: Add citations to the prinout - you get them from sec record's "citation" field, same as "crim" (which is frankly a terrible fucking field name)
///Standardized printed records. SPRs. Like SATs but for bad guys who probably didn't actually finish school. Input the records and out comes a paper.
/proc/print_security_record(datum/data/record/general_data, datum/data/record/security, atom/location)
	if(!istype(general_data) && !istype(security))
		stack_trace("called without any datacores! this may or may not be intentional!")
	if(!isatom(location)) //can't drop the paper if we didn't get passed an atom.
		CRASH("NO VALID LOCATION PASSED.")

	GLOB.data_core.securityPrintCount++ //just alters the name of the paper.
	var/obj/item/paper/printed_paper = new(location)
	var/final_paper_text = "<CENTER><B>Security Record - (SR-[GLOB.data_core.securityPrintCount])</B></CENTER><BR>"
	if((istype(general_data, /datum/data/record) && GLOB.data_core.general.Find(general_data)))
		final_paper_text += text("Name: [] ID: []<BR>\nGender: []<BR>\nAge: []<BR>", general_data.fields["name"], general_data.fields["id"], general_data.fields["gender"], general_data.fields["age"])
		final_paper_text += "\nSpecies: [general_data.fields["species"]]<BR>"
		final_paper_text += text("\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", general_data.fields["fingerprint"], general_data.fields["p_stat"], general_data.fields["m_stat"])
	else
		final_paper_text += "<B>General Record Lost!</B><BR>"
	if((istype(security, /datum/data/record) && GLOB.data_core.security.Find(security)))
		final_paper_text += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []", security.fields["criminal"])

		final_paper_text += "<BR>\n<BR>\nCrimes:<BR>\n"
		final_paper_text +={"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Crime</th>
<th>Details</th>
<th>Author</th>
<th>Time Added</th>
</tr>"}
		for(var/datum/data/crime/c in security.fields["crim"])
			final_paper_text += "<tr><td>[c.crimeName]</td>"
			final_paper_text += "<td>[c.crimeDetails]</td>"
			final_paper_text += "<td>[c.author]</td>"
			final_paper_text += "<td>[c.time]</td>"
			final_paper_text += "</tr>"
		final_paper_text += "</table>"

		final_paper_text += text("<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", security.fields["notes"])
		var/counter = 1
		while(security.fields[text("com_[]", counter)])
			final_paper_text += text("[]<BR>", security.fields[text("com_[]", counter)])
			counter++
		printed_paper.name = text("SR-[] '[]'", GLOB.data_core.securityPrintCount, general_data.fields["name"])
	else //if no security record
		final_paper_text += "<B>Security Record Lost!</B><BR>"
		printed_paper.name = text("SR-[] '[]'", GLOB.data_core.securityPrintCount, "Record Lost")
	final_paper_text += "</TT>"
	printed_paper.add_raw_text(final_paper_text)
	printed_paper.update_appearance() //make sure we make the paper look like it has writing on it.
