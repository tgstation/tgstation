/datum/ambition_template
	///Name of the template. Has to be unique
	var/name
	///If defined, only the antags in the whitelists will see the template
	var/list/antag_whitelist
	///If defined, only the jobs in the whitelist will see the template
	var/list/job_whitelist

	///Narrative given by the template
	var/narrative = ""
	///Objectives given by the templates
	var/list/objectives = list()
	///Intensity given by the template
	var/intensity = 0
	///Tips displayed to the antag
	var/list/tips

/datum/ambition_template/blank
	name = "Blank"

/datum/ambition_template/money_problems
	name = "Money Problems"
	narrative = "In need of money for personal reasons, tired of living like a drone, for measly wages, you're out to get some money to satisfy your needs and debts!"
	objectives = list("Acquire 20,000 credits.")
	tips = list("You should add an objective on your main money making plan!", "You could buy a gun and mug people, but make sure to conceal your identity, you can do this with a mask from a chameleon kit, and agent ID, or you'll risk being wanted quite quickly", "Setting up a shop is not a bad idea! Consider partnering up with cargo or science people for goods or implants", "If you're feeling brave you can bust the vault up!")

/datum/ambition_template/data_theft
	name = "Data Theft"
	narrative = "You have been selected out of Donk. Co's leagues of potential sleeper operatives for one particular task."
	objectives = list("Steal the Blackbox.", "Escape on the emergency shuttle alive and out of custody.")
	tips = list("You should add an objective on how you plan to go about this task.", "The Blackbox is located in Telecomms on most Stations.", "The Blackbox doesn't fit in most bags. You'd need a bag of holding to hide it!")
	antag_whitelist = list("Traitor")

/datum/ambition_template/apex_predator
	name = "Apex Predator"
	narrative = "You have come here with one goal in mind - the hunt."
	objectives = list("Hunt down all armed crew members for the sport of the task.")
	tips = list("Unarmed crew pose no challenge and are not worthy of the hunt.", "When blending in for stealthier assassinations, it's ideal to pick a disguise that makes sense in that location.")
	antag_whitelist = list("Changeling")
