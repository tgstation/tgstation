/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "splats the"
	density = 0
	var/color //brown, gray and white, leave blank for random
	layer = 2.5		//so they can hide under objects
	swap_on_mobbump = 0
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

/mob/living/simple_animal/mouse/Life()
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

/mob/living/simple_animal/mouse/white
	color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	color = "brown"
	icon_state = "mouse_brown"

/mob/living/simple_animal/mouse/New()
	if(!color)
		color = pick( list("brown","gray","white") )
	icon_state = "mouse_[color]"
	icon_living = "mouse_[color]"
	icon_dead = "mouse_[color]_dead"
	desc = "It's a small [color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"


/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[color]_splat"
	src.icon_state = "mouse_[color]_splat"

/proc/ismouse(var/obj/O)
	return istype(O,/mob/living/simple_animal/mouse)

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Mouse"

//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/welded = 0
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
		if(!v.welded)
			vent_found = v
			break
		else
			welded = 1
	if(vent_found)
		if(vent_found.network&&vent_found.network.normal_members.len)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in vent_found.network.normal_members)
				if(temp_vent.loc == loc)
					continue
				vents.Add(temp_vent)
			var/list/choices = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
				if(vent.loc.z != loc.z)
					continue
				var/atom/a = get_turf(vent)
				choices.Add(a.loc)
			var/turf/startloc = loc
			var/obj/selection = input("Select a destination.", "Duct System") in choices
			var/selection_position = choices.Find(selection)
			if(loc==startloc)
				var/obj/target_vent = vents[selection_position]
				if(target_vent)
					for(var/mob/O in oviewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
					loc = target_vent.loc
			else
				src << "\blue You need to remain still while entering a vent."
		else
			src << "\blue This vent is not connected to anything."
	else if(welded)
		src << "\red That vent is welded."
	else
		src << "\blue You must be standing on or beside an air vent to enter it."
	return

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/mouse/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Mouse"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)

//make mice fit under tables etc? this was hacky, and not working
/*
/mob/living/simple_animal/mouse/Move(var/dir)

	var/turf/target_turf = get_step(src,dir)
	//CanReachThrough(src.loc, target_turf, src)
	var/can_fit_under = 0
	if(target_turf.ZCanPass(get_turf(src),1))
		can_fit_under = 1

	..(dir)
	if(can_fit_under)
		src.loc = target_turf
	for(var/d in cardinal)
		var/turf/O = get_step(T,d)
		//Simple pass check.
		if(O.ZCanPass(T, 1) && !(O in open) && !(O in closed) && O in possibles)
			open += O
			*/

mob/living/simple_animal/mouse/restrained() //Hotfix to stop mice from doing things with MouseDrop
	return 1

/mob/living/simple_animal/mouse/HasEntered(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			M << "\blue \icon[src] Squeek!"
			M << 'sound/effects/mousesqueek.ogg'
	..()