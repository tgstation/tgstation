/**
 * Takes a selected key and turns it into a pAI.
 * Ideally this is an observer, but you do not have to play nice.
 */
/client/proc/make_pai()
	set category = "Admin.Fun"
	set name = "Make pAI"
	set desc = "Creates a pAI at your current location using the specified key."

	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		return

	var/list/available = list()
	for(var/mob/player as anything in GLOB.player_list)
		if(player.key && player.client)
			available.Add(player)
	var/mob/choice = tgui_input_list(usr, "Choose a player to play the pAI", "Spawn pAI", sort_names(available))
	if(isnull(choice))
		return
	var/chosen_name = tgui_input_text(choice, "Enter your pAI name", "pAI Name", "Personal AI", MAX_NAME_LEN)
	if (isnull(chosen_name))
		return
	if(!isobserver(choice))
		if(tgui_alert(usr, "[choice.key] isn't ghosting right now. Are you sure you want to yank them out of their body and place them in this pAI?", "Spawn pAI Confirmation", list("Yes", "No")) != "Yes")
			return
		var/mob/living/person = choice
		if(isliving(choice))
			person.gib() // Why? Because it's funny
	var/obj/item/pai_card/card = new(get_turf(usr))
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = chosen_name
	pai.real_name = pai.name
	pai.key = choice.key
	card.set_personality(pai)
	if(SSpai.candidates[choice.key])
		SSpai.candidates.Remove(choice.key)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
