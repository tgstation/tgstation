/// Verbs created to help server operators with generating certain config files.

/client/proc/generate_job_config()
	set name = "Generate Job Configuration"
	set category = "Server"
	set desc = "Generate a job configuration (jobconfig.toml) file for the server. If TOML file already exists, will re-generate it based off the already existing config values. Will migrate from the old jobs.txt format if necessary."

	if(!check_rights(R_SERVER))
		return

	if(tgui_alert(usr, "This verb is not at all useful if you are not a server operator with access to the configuration folder. Do you wish to proceed?", "Generate jobconfig.toml for download", list("Yes", "No")) != "Yes")
		return

	if(SSjob.generate_config(usr))
		to_chat(usr, span_notice("Job configuration file generated. Download prompt should appear now."))
	else
		to_chat(usr, span_warning("Job configuration file could not be generated. Check the server logs / runtimes / above warning messages for more information."))

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Generate Job Configuration") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
