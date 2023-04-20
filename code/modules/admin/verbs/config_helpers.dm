/// Verbs created to help server operators with generating certain config files.

ADMIN_VERB(generate_job_config, "Generate Job Configuration", "Generate a job configuration file for the server. If it already exists it will be re-generated based off of the existing values.", R_SERVER, VERB_CATEGORY_SERVER)
	if(tgui_alert(user, "This verb is not at all useful if you are not a server operator with access to the configuration folder. Do you wish to proceed?", "Generate jobconfig.toml for download", list("Yes", "No")) != "Yes")
		return

	if(SSjob.generate_config(user.mob))
		to_chat(user, span_notice("Job configuration file generated. Download prompt should appear now."))
	else
		to_chat(user, span_warning("Job configuration file could not be generated. Check the server logs / runtimes / above warning messages for more information."))
