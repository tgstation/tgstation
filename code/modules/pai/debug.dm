/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = tgui_input_list(usr, "Choose a player to play the pAI", "Spawn pAI", sort_names(available))
	if(isnull(choice))
		return
	if(!isobserver(choice))
		var/confirm = tgui_alert(usr, "[choice.key] isn't ghosting right now. Are you sure you want to yank them out of their body and place them in this pAI?", "Spawn pAI Confirmation", list("Yes", "No"))
		if(confirm != "Yes")
			return
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)

	var/chosen_name = input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text|null

	if (isnull(chosen_name))
		return

	pai.name = chosen_name
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/pai_candidate/candidate in SSpai.candidates)
		if(candidate.key == choice.key)
			SSpai.candidates.Remove(candidate)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
