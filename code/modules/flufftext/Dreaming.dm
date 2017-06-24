/mob/living/carbon/proc/dream()
	set waitfor = 0
	dreaming = TRUE
	var/list/dreams = list(
		"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
		"voices from all around","deep space","a doctor","the engine","a traitor","an ally","darkness",
		"light","a scientist","a monkey","a catastrophe","a loved one","a gun","warmth","freezing","the sun",
		"a hat","the Luna","a ruined station","a planet","plasma","air","the medical bay","the bridge","blinking lights",
		"a blue light","an abandoned laboratory","Nanotrasen","The Syndicate","blood","healing","power","respect",
		"riches","space","a crash","happiness","pride","a fall","water","flames","ice","melons","flying"
		)
	for(var/i in 1 to rand(1, rand(3, 7)))
		var/dream_image = pick(dreams)
		dreams -= dream_image
		to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")
		sleep(rand(40,70))
		if(stat != UNCONSCIOUS || InCritical())
			break
	dreaming = FALSE
	return 1

/mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming)
		dream()

/mob/living/carbon/var/dreaming = FALSE