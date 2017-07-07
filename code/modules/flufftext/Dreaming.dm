/mob/living/carbon/proc/dream()
	set waitfor = 0
	dreaming = TRUE
	var/list/dreams = GLOB.dream_strings.Copy()
	for(var/obj/item/weapon/bedsheet/sheet in loc)
		dreams += sheet.dream_messages
	for(var/i in 1 to rand(3, rand(5, 10)))
		var/dream_image = pick_n_take(dreams)
		to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")
		sleep(rand(30,60))
		if(stat != UNCONSCIOUS || InCritical())
			break
	dreaming = FALSE
	return 1

/mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming)
		dream()

/mob/living/carbon/var/dreaming = FALSE