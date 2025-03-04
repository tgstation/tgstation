// All the procs that admins can use to view something like a global list in a cleaner manner than just View Variables are contained in this file.


/datum/admins/proc/list_investigate_log(list/log, name)
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return

	var/title = "[full_capitalize(name)] Log"
	var/parts = list()
	if(length(log))
		parts += "<b>Showing last [length(log)] [name]s.</b>"
		parts += "<hr>"
		parts += "<ul>"
		for(var/entry in log)
			parts += "<li>[entry]</li>"
		parts += "</ul>"
	else
		parts += "<i>The [name] log is empty.</i>"

	var/datum/browser/browser = new(usr, ckey(title), title, 800, 500)
	browser.set_content(jointext(parts, ""))
	browser.open()

/datum/admins/proc/list_bombers()
	list_investigate_log(GLOB.bombers, "bomber")

/datum/admins/proc/list_signalers()
	list_investigate_log(GLOB.investigate_signaler, "signaler")

/datum/admins/proc/list_law_changes()
	list_investigate_log(GLOB.lawchanges, "law change")

/datum/admins/proc/list_dna()
	var/data = "<b>Showing DNA from blood.</b><hr>"
	data += "<table cellspacing=5 border=1><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
	for(var/entry in GLOB.human_list)
		var/mob/living/carbon/human/subject = entry
		if(subject.ckey)
			data += "<tr><td>[subject]</td><td>[subject.dna.unique_enzymes]</td><td>[subject.dna.blood_type]</td></tr>"
	data += "</table>"

	var/datum/browser/browser = new(usr, "DNA", "DNA Log", 440, 410)
	browser.set_content(data)
	browser.open()

/datum/admins/proc/list_fingerprints() //kid named fingerprints
	var/data = "<b>Showing Fingerprints.</b><hr>"
	data += "<table cellspacing=5 border=1><tr><th>Name</th><th>Fingerprints</th></tr>"
	for(var/entry in GLOB.human_list)
		var/mob/living/carbon/human/subject = entry
		if(subject.ckey)
			data += "<tr><td>[subject]</td><td>[md5(subject.dna.unique_identity)]</td></tr>"
	data += "</table>"

	var/datum/browser/browser = new(usr, "fingerprints", "Fingerprint Log", 440, 410)
	browser.set_content(data)
	browser.open()

/datum/admins/proc/show_manifest()
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The game hasn't started yet!")
		return
	GLOB.manifest.ui_interact(usr)

/datum/admins/proc/output_ai_laws()
	var/law_bound_entities = 0
	for(var/mob/living/silicon/subject as anything in GLOB.silicon_mobs)
		law_bound_entities++

		var/message = ""

		if(isAI(subject))
			message += "<b>AI [key_name(subject, usr)]'s laws:</b>"
		else if(iscyborg(subject))
			var/mob/living/silicon/robot/borg = subject
			message += "<b>CYBORG [key_name(subject, usr)] [borg.connected_ai?"(Slaved to: [key_name(borg.connected_ai)])":"(Independent)"]: laws:</b>"
		else if (ispAI(subject))
			message += "<b>pAI [key_name(subject, usr)]'s laws:</b>"
		else
			message += "<b>SOMETHING SILICON [key_name(subject, usr)]'s laws:</b>"

		message += "<br>"

		if (!subject.laws)
			message += "[key_name(subject, usr)]'s laws are null?? Contact a coder."
		else
			message += jointext(subject.laws.get_law_list(include_zeroth = TRUE), "<br>")

		to_chat(usr, message, confidential = TRUE)

	if(!law_bound_entities)
		to_chat(usr, "<b>No law bound entities located</b>", confidential = TRUE)
