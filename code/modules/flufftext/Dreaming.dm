/mob/living/carbon/proc/dream()
	set waitfor = 0
	var/list/dreams = GLOB.dream_strings.Copy()
	for(var/obj/item/weapon/bedsheet/sheet in loc)
		dreams += sheet.dream_messages
	var/list/dream_images = list()
	for(var/i in 1 to rand(3, rand(5, 10)))
		dream_images += pick_n_take(dreams)
		dreaming++
	for(var/i in 1 to dream_images.len)
		addtimer(CALLBACK(src, .proc/experience_dream, dream_images[i]), ((i - 1) * rand(30,60)))
	return 1

/mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming)
		dream()

/mob/living/carbon/proc/experience_dream(dream_image)
	dreaming--
	if(stat != UNCONSCIOUS || InCritical())
		return
	to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")
