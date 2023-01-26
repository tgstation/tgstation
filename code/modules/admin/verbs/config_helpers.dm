/// Verbs created to help server operators with generating certain config files.

ADMIN_VERB(server, generate_job_configuration, "", R_SERVER)
	if(tgui_alert(usr, "This verb is not at all useful if you are not a server operator with access to the configuration folder. Do you wish to proceed?", "Generate jobconfig.toml for download", list("Yes", "No")) != "Yes")
		return

	if(!SSjob.generate_config(usr))
		to_chat(usr, span_warning("Job configuration file could not be generated. Check the server logs / runtimes / above warning messages for more information."))
		return

	to_chat(usr, span_notice("Job configuration file generated. Download prompt should appear now."))

