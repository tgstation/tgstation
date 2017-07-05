GLOBAL_LIST_INIT(globalDreamMessages,list(
		"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
		"voices from all around","deep space","a doctor","the engine","a traitor","an ally","darkness",
		"light","a scientist","a monkey","a catastrophe","a loved one","a gun","warmth","freezing","the sun",
		"a hat","the Luna","a ruined station","a planet","plasma","air","the medical bay","the bridge","blinking lights",
		"a blue light","an abandoned laboratory","Nanotrasen","The Syndicate","blood","healing","power","respect",
		"riches","space","a crash","happiness","pride","a fall","water","flames","ice","melons","flying"))


/mob/living/carbon/proc/handle_dreams()
	if(stat != UNCONSCIOUS || InCritical())
		return
	var/list/dreams = list()
	for(var/obj/item/weapon/bedsheet/bedsheet in range(0,src))
		if(bedsheet.loc != loc) // bedsheets in your backpack don't give you dreams.
			continue
		dreams += bedsheet.dreamMessage
		if(bedsheet.dreamSound && prob(10))
			src << bedsheet.dreamSound
	if(!length(dreams))
		dreams = GLOB.globalDreamMessages
	to_chat(src, "<span class='notice'><i>... [pick(dreams)] ...</i></span>")
