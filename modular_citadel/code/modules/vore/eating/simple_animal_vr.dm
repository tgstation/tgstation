///////////////////// Simple Animal /////////////////////
/mob/living/simple_animal
	var/isPredator = FALSE 					//Are they capable of performing and pre-defined vore actions for their species?
	var/swallowTime = 5 SECONDS 				//How long it takes to eat its prey in 1/10 of a second. The default is 5 seconds.
	var/list/prey_excludes = list()		//For excluding people from being eaten.

//
// Simple proc for animals to have their digestion toggled on/off externally
//
/mob/living/simple_animal/verb/toggle_digestion()
	set name = "Toggle Animal's Digestion"
	set desc = "Enables digestion on this mob for 20 minutes."
	set category = "Object"
	set src in oview(1)

	var/datum/belly/B = vore_organs[vore_selected]
	if(faction != usr.faction)
		to_chat(usr,"<span class='warning'>This predator isn't friendly, and doesn't give a shit about your opinions of it digesting you.</span>")
		return
	if(B.digest_mode == "Hold")
		var/confirm = alert(usr, "Enabling digestion on [name] will cause it to digest all stomach contents. Using this to break OOC prefs is against the rules. Digestion will disable itself after 20 minutes.", "Enabling [name]'s Digestion", "Enable", "Cancel")
		if(confirm == "Enable")
			B.digest_mode = "Digest"
			sleep(20 MINUTES) //12000=20 minutes
			B.digest_mode = "Hold"
	else
		var/confirm = alert(usr, "This mob is currently set to digest all stomach contents. Do you want to disable this?", "Disabling [name]'s Digestion", "Disable", "Cancel")
		if(confirm == "Disable")
			B.digest_mode = "Hold"

//
// Simple nom proc for if you get ckey'd into a simple_animal mob! Avoids grabs.
//
/mob/living/simple_animal/proc/animal_nom(var/mob/living/T in oview(1))
	set name = "Animal Nom"
	set category = "Vore"
	set desc = "Since you can't grab, you get a verb!"

	if (stat != CONSCIOUS)
		return
	if (T.devourable == FALSE)
		to_chat(usr, "<span class='warning'>You can't eat this!</span>")
		return
	return feed_grabbed_to_self(src,T)