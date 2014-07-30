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
	pass_flags = PASSTABLE
	small = 1
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	density = 0
	var/_color //brown, gray and white, leave blank for random
	layer = MOB_LAYER
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0

/mob/living/simple_animal/mouse/Life()
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

	if(!ckey && stat == CONSCIOUS && prob(0.5))
		stat = UNCONSCIOUS
		icon_state = "mouse_[_color]_sleep"
		wander = 0
		speak_chance = 0
		//snuffles
	else if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			icon_state = "mouse_[_color]"
			wander = 1
		else if(prob(5))
			emote("snuffles")

/mob/living/simple_animal/mouse/New()
	..()
	// Mice IDs
	if(name == initial(name))
		name = "[name] ([rand(1, 1000)])"
	if(!_color)
		_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[_color]"
	icon_living = "mouse_[_color]"
	icon_dead = "mouse_[_color]_dead"
	desc = "It's a small [_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."


/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[_color]_splat"
	src.icon_state = "mouse_[_color]_splat"
	if(client)
		client.time_died_as_mouse = world.time

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"

//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return

	if(src.stat != CONSCIOUS)	return

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
			if(!choices)
				src << "\red This vent isn't connected to anything."
			var/obj/selection = input("Select a destination.", "Duct System") in choices
			var/selection_position = choices.Find(selection)
			if(loc==startloc)
				var/obj/target_vent = vents[selection_position]
				if(target_vent)
					/*
					for(var/mob/O in oviewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
					*/
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
	set category = "Object"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
		*/
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)
		*/

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

///mob/living/simple_animal/mouse/restrained() //Hotfix to stop mice from doing things with MouseDrop
//	return 1

/mob/living/simple_animal/mouse/start_pulling(var/atom/movable/AM)//Prevents mouse from pulling things
	src << "<span class='warning'>You are too small to pull anything.</span>"
	return

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			M << "\blue \icon[src] Squeek!"
			M << 'sound/effects/mousesqueek.ogg'
	..()

/mob/living/simple_animal/mouse/Die()
	if(client)
		client.time_died_as_mouse = world.time
	..()

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	_color = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
