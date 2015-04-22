var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber)

/mob/living/carbon/slime/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)

/mob/living/carbon/monkey/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)

/mob/living/silicon/robot/mommi/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)

/mob/living/simple_animal/borer/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)

/mob/living/simple_animal/mouse/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)

/mob/living/simple_animal/spiderbot/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)

/mob/living/carbon/alien/AltClickOn(var/atom/A)
	if(is_type_in_list(A,ventcrawl_machinery))
		src.ventcrawl(A)
		return
	..(A)
