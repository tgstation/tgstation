GLOBAL_LIST_INIT(globalDreamMessages,world.file2list("strings/dreamthings.txt"))


/mob/living/carbon/proc/handle_dreams()
	if(InCritical())
		return
	var/list/dreams = list()
	for(var/obj/item/weapon/bedsheet/bedsheet in range(0,src))
		if(bedsheet.loc != loc) // bedsheets in your backpack don't give you dreams.
			continue
		dreams += bedsheet.dreamMessage
		if(bedsheet.dreamSound && prob(10))
			playsound_local(get_turf(src), bedsheet.dreamSound, rand(40,100))
	if(!length(dreams))
		dreams = GLOB.globalDreamMessages
	show_dream("<span class='notice'><i>... [pick(dreams)] ...</i></span>")
	for(var/i in 1 to rand(1, rand(2,6)))
		addtimer(CALLBACK(src, .proc/show_dream, "<span class='notice'><i>... [pick(dreams)] ...</i></span>"),40*i+rand(0,30))

/mob/living/carbon/proc/show_dream(message)
	if(!InCritical() && stat == UNCONSCIOUS)
		to_chat(src, message)
