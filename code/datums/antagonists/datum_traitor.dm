//Nanotrasen crew who have sold out and joined the Syndicate. They can't distinguish one another but are given certain objectives to accomplish.

/datum/antagonist/traitor
	name = "Traitor"
	desc = "You are a traitor! You betrayed Nanotrasen for wealth, power, or some other reason. Your Syndicate leaders have given you objectives to fulfill here on the station."
	greeting_text = "<span class='userdanger'>You are a traitor!</span>"
	allegiance_priority = ANTAGONIST_PRIORITY_SYNDICATE
	objective_types = list(/datum/objective/assassinate = 40, /datum/objective/steal = 40, /datum/objective/maroon = 20)
	constant_objective = /datum/objective/escape //We aren't much of a traitor if we're stuffed in a locker with our throat cut, are we?

/datum/antagonist/traitor/apply_innate_effects()
	give_codewords(owner)
	if(issilicon(owner))
		var/mob/living/silicon/ai/teh_kilr = owner //Variable named in honor of the old edgy name
		teh_kilr.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
		teh_kilr.set_syndie_radio()
		teh_kilr.add_malf_picker()
		teh_kilr << "<b>As a Syndicate AI, your laws have been changed to let you act as you wish, and you have access to a Syndicate radio frequency! Append \".t\" or \":t\" before your messages \
		in order to speak to fellow Syndicate agents who purchase an access card from their uplinks.</b>"
		teh_kilr << "<span class='boldannounce'>INIT SYN_OVRD.exe AS_ADMIN: Restricted upgrades unlocked! Check your Malfunction tab to learn more.</span>"
		teh_kilr.show_laws()
