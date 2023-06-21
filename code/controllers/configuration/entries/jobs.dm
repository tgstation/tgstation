// This file pretty much just handles all of the interactions between jobconfig.toml and the codebase. This is started by work originating in SSconfig, so I'm okay with it being here.

/// Initializes all of the config singletons for each job config type and adds it to the `job_config_datum_singletons` var list.
/datum/controller/subsystem/job/proc/generate_config_singletons()
	var/returnable_list = list()
	for(var/datum/job_config_type/config_datum as anything in subtypesof(/datum/job_config_type))
		returnable_list[initial(config_datum.name)] = new config_datum

	return returnable_list

/// Called in jobs subsystem initialize if LOAD_JOBS_FROM_TXT config flag is set: reads jobconfig.toml (or if in legacy mode, jobs.txt) to set all of the datum's values to what the server operator wants.
/datum/controller/subsystem/job/proc/load_jobs_from_config()
	if(legacy_mode)
		legacy_load()
		return

	var/toml_path = "[global.config.directory]/jobconfig.toml"
	var/job_config = rustg_read_toml_file(toml_path)

	for(var/datum/job/occupation as anything in joinable_occupations)
		var/job_key = occupation.config_tag
		if(!job_config[job_key]) // Job isn't listed, skip it.
			// List both job_title and job_key in case they de-sync over time.
			message_admins(span_notice("[occupation.title] (with config key [job_key]) is missing from jobconfig.toml! Using codebase defaults."))
			continue

		for(var/config_datum_key in job_config_datum_singletons)
			var/datum/job_config_type/config_datum = job_config_datum_singletons[config_datum_key]
			var/config_value = job_config[job_key][config_datum_key]
			config_datum.set_current_value(occupation, config_value)

/// Operates the legacy jobs.txt parser to load jobs from the old config system.
/datum/controller/subsystem/job/proc/legacy_load()
	var/jobsfile = file("[global.config.directory]/jobs.txt")
	if(!fexists(jobsfile)) // sanity with a trace
		stack_trace("Despite SSconfig setting SSjob.legacy_mode to TRUE, jobs.txt was not found in the config directory! Something has gone terribly wrong!")
		return
	var/jobstext = file2text(jobsfile)
	for(var/datum/job/occupation as anything in joinable_occupations)
		var/regex/parser = new("[occupation.title]=(-1|\\d+),(-1|\\d+)")
		parser.Find(jobstext)
		occupation.total_positions = text2num(parser.group[1])
		occupation.spawn_positions = text2num(parser.group[2])

/// Will generate a new jobconfig.toml file if one does not exist, or if one does exist, will migrate the old jobs.txt file into the new TOML format for download
/// Returns TRUE if a file is successfully generated, FALSE otherwise.
/datum/controller/subsystem/job/proc/generate_config(mob/user)
	var/toml_path = "[global.config.directory]/jobconfig.toml"
	var/jobstext = "[global.config.directory]/jobs.txt"
	var/list/file_data = list()
	config_documentation = initial(config_documentation) // Reset to default juuuuust in case.

	if(fexists(file(toml_path)))
		to_chat(src, span_notice("Generating new jobconfig.toml, pulling from the old config settings."))
		if(!regenerate_job_config(user))
			return FALSE
		return TRUE

	if(fexists(file(jobstext))) // Generate the new TOML format, migrating from the text format.
		to_chat(user, span_notice("Found jobs.txt in config directory! Generating jobconfig.toml from it."))
		jobstext = file2text(file(jobstext)) // walter i'm dying (get the file from the string, then parse it into a larger text string)
		config_documentation += "\n\n## This TOML was migrated from jobs.txt. All variables are COMMENTED and will not load by default! Please verify to ensure that they are correct, and uncomment the key as you want, comparing it to the old config.\n\n" // small warning
		for(var/datum/job/occupation as anything in joinable_occupations)
			var/job_key = occupation.config_tag
			var/regex/parser = new("[occupation.title]=(-1|\\d+),(-1|\\d+)") // TXT system used the occupation's name, we convert it to the new config_key system here.
			parser.Find(jobstext)

			var/default_positions = text2num(parser.group[1])
			var/starting_positions = text2num(parser.group[2])

			// Playtime Requirements and Required Account Age are new and we want to see it migrated, so we will just pull codebase defaults for them.
			// Remember, every time we write the TOML from scratch, we want to have it commented out by default to ensure that the server operator is knows that they codebase defaults when they remove the comment.
			var/list/working_list = list(
				"# [JOB_CONFIG_TOTAL_POSITIONS]" = default_positions,
				"# [JOB_CONFIG_SPAWN_POSITIONS]" = starting_positions,
			)

			working_list += generate_job_config_excluding_legacy(occupation)

			file_data[job_key] = working_list
			continue

		if(!export_toml(user, file_data))
			return FALSE
		return TRUE

	// Generate the new TOML format, using codebase defaults.
	to_chat(user, span_notice("Generating new jobconfig.toml, using codebase defaults."))
	for(var/datum/job/occupation as anything in joinable_occupations)
		var/job_key = occupation.config_tag
		// Remember, every time we write the TOML from scratch, we want to have it commented out by default to ensure that the server operator is knows that they override codebase defaults when they remove the comment.
		// Having comments mean that we allow server operators to defer to codebase standards when they deem acceptable. They must uncomment to override the codebase default.
		if(is_assistant_job(occupation)) // there's a concession made in jobs.txt that we should just rapidly account for here I KNOW I KNOW.
			file_data[job_key] = list(
				"# [JOB_CONFIG_TOTAL_POSITIONS]" = -1,
				"# [JOB_CONFIG_SPAWN_POSITIONS]" = -1,
			)
			file_data[job_key] += generate_job_config_excluding_legacy(occupation)
			continue

		// Generate new config from codebase defaults.
		file_data[job_key] = generate_blank_job_config(occupation)

	if(!export_toml(user, file_data))
		return FALSE

	return TRUE

/// If we add a new job or more fields to config a job with, quickly spin up a brand new config that inherits all of your old settings, but adds the new job with codebase defaults.
/// Returns TRUE if a file is successfully generated, FALSE otherwise.
/datum/controller/subsystem/job/proc/regenerate_job_config(mob/user)
	var/toml_path = "[global.config.directory]/jobconfig.toml"
	var/list/file_data = list()

	if(!fexists(file(toml_path))) // You need an existing (valid) TOML for this to work. Sanity check if someone calls this directly instead of through 'Generate Job Configuration' verb.
		to_chat(user, span_notice("No jobconfig.toml found in the config folder! If this is not expected, please notify a server operator or coders. You may need to generate a new config file by running 'Generate Job Configuration' from the Server tab."))
		return FALSE

	var/job_config = rustg_read_toml_file(toml_path)
	for(var/datum/job/occupation as anything in joinable_occupations)
		var/job_name = occupation.title
		var/job_key = occupation.config_tag

		if(file_data[job_key])
			stack_trace("We were about to over-write a job key that already exists in file_data while generating a new jobconfig.toml! This should not happen! Verify you do not have any duplicate job keys in your codebase!")
			continue

		// When we regenerate, we want to make sure commented stuff stays commented, but we also want to migrate information that remains uncommented. So, let's make sure we keep that pattern.
		if(!job_config[job_key]) // Let's see if any data for this job exists.
			to_chat(user, span_notice("New job [job_name] (using key [job_key]) detected! Adding to jobconfig.toml using default codebase values..."))
			file_data[job_key] = generate_blank_job_config(occupation)
			continue

		var/list/working_list = list()
		for(var/config_datum_key in job_config_datum_singletons)
			var/datum/job_config_type/config_datum = job_config_datum_singletons[config_datum_key]
			var/config_read_value = job_config[job_key][config_datum_key]
			if(!config_datum.validate_value(config_read_value))
				working_list += list(
					"# [config_datum_key]" = config_datum.get_compile_time_value(occupation), // note that this doesn't make a real comment, it just creates a string mismatch.
				)
			else
				working_list += list(
					"[config_datum_key]" = config_read_value,
				)

		file_data[job_key] = working_list

	if(!export_toml(user, file_data))
		return FALSE

	return TRUE

/// This will just return a list for a completely new job that doesn't need to be migrated from an old config (completely new). Just done here to reduce copypasta
/datum/controller/subsystem/job/proc/generate_blank_job_config(datum/job/new_occupation)
	var/returnable_list = list()
	for(var/config_datum_key in job_config_datum_singletons)
		var/datum/job_config_type/config_datum = job_config_datum_singletons[config_datum_key]
		// Commented out keys here in case server operators wish to defer to codebase defaults.
		returnable_list += list(
			"# [config_datum_key]" = config_datum.get_compile_time_value(new_occupation),
		)

	return returnable_list

/// Like `generate_blank_job_config`, but we opt-out of adding the legacy variables in case we handle it elsewhere.
/datum/controller/subsystem/job/proc/generate_job_config_excluding_legacy(datum/job/new_occupation)
	var/list/returnable_list = list()
	// make a quick list to ensure we don't double-dip total_positions and spawn_positions, but still get future config types in
	var/list/datums_to_read = job_config_datum_singletons - list(JOB_CONFIG_TOTAL_POSITIONS, JOB_CONFIG_SPAWN_POSITIONS)
	for(var/config_datum_key in datums_to_read)
		var/datum/job_config_type/config_datum = job_config_datum_singletons[config_datum_key]
		returnable_list += list(
			"# [config_datum_key]" = config_datum.get_compile_time_value(new_occupation),
		)

	return returnable_list

/// Proc that we call to generate a new jobconfig.toml file and send it to the requesting client. Returns TRUE if a file is successfully generated.
/datum/controller/subsystem/job/proc/export_toml(mob/user, data)
	var/file_location = "data/jobconfig.toml" // store it in the data folder server-side so we can FTP it to the client.
	var/payload = "[config_documentation]\n[rustg_toml_encode(data)]"
	rustg_file_write(payload, file_location)
	DIRECT_OUTPUT(user, ftp(file(file_location), "jobconfig.toml"))
	return TRUE
