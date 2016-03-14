//DANCE DANCE REVOLUTION

#define DDR_STAND 0
#define DDR_LIE   1

/obj/structure/dance_dance_revolution
	name = "Dance Dance Revolution"
	desc = "A spin on an old classic."

	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"

	density = 1
	anchored = 1

	var/mob/living/dancer = null

	var/current_instruction = DDR_STAND
	var/current_dir = NORTH
	var/progress_counter = 0
	var/max_progress = 70

	var/list/direction_effects = list()
	var/list/instruction_effects = list()

	var/process_delay = 15 //in deciseconds

/obj/structure/dance_dance_revolution/Destroy()
	stop_game()

	..()

/obj/structure/dance_dance_revolution/proc/stop_game()
	dancer = null
	progress_counter = 0
	process_delay = initial(process_delay)

/obj/structure/dance_dance_revolution/proc/start_game()
	current_instruction = DDR_STAND
	current_dir = NORTH

	direction_effects = list()
	for(var/obj/effect/ddr_direction/D in get_area(src))
		direction_effects.Add(D)

	instruction_effects = list()
	for(var/obj/effect/ddr_instruction/D in get_area(src))
		instruction_effects.Add(D)

	spawn()
		process()

/obj/structure/dance_dance_revolution/proc/win()
	to_chat(dancer, "<span class='info'>You win!</span>")

	stop_game()
	playsound(get_turf(src), 'sound/machines/ding2.ogg', 50)

	spawn()
		for(var/obj/effect/ddr_loot/E in get_area(src))
			var/turf/T = get_turf(E)
			T.visible_message("<span class='danger'>\The [T] melts away!</span>")
			T.ChangeTurf(/turf/simulated/floor/plating)
			qdel(E)
			sleep(10)

/obj/structure/dance_dance_revolution/proc/lose()
	to_chat(dancer, "<span class='userdanger'>You lose! Your muscles hurt from all the dancing.</span>")
	visible_message("<span class='notice'>A red screen briefly flashes on \the [src].</span>")
	dancer.Weaken(5)

	for(var/i=0 to rand(1,5))
		dancer.adjustBruteLoss(rand(1,5))

	stop_game()
	playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50)

/obj/structure/dance_dance_revolution/proc/update_effects()
	for(var/obj/effect/E in direction_effects)
		animate(E, transform = turn(matrix(), dir2angle(current_dir)), time = 1)

	for(var/obj/effect/E in instruction_effects)
		switch(current_instruction)
			if(DDR_STAND) E.icon_state = "getup"
			if(DDR_LIE) E.icon_state = "getdown"

/obj/structure/dance_dance_revolution/process()
	if(!dancer) return stop_game() //No dancer
	if(!isturf(loc)) return stop_game()
	if(!isturf(dancer.loc)) return lose() //Dancer isn't in a turf
	if(dancer.loc.loc != src.loc.loc) return lose() //Dancer left the area

	//Check if dancer fulfilled the previous task
	if(progress_counter > 0)
		if(dancer.dir != current_dir)
			return lose()

		switch(current_instruction)
			if(DDR_STAND)
				if(dancer.lying == 1) return lose()
			if(DDR_LIE)
				if(dancer.lying == 0) return lose()

	//Update counters
	progress_counter++

	if(progress_counter > max_progress)
		return win()

	if((progress_counter % 10) == 0)
		process_delay = max(process_delay-1, 10)
		visible_message("<span class='info'>\The [src] speeds up!</span>")

	//Give new task

	if(progress_counter > max_progress*0.8) //last 20% of the game = added difficulty
		current_instruction = rand(DDR_STAND, DDR_LIE)

	current_dir = pick(cardinal - current_dir)

	for(var/obj/effect/E in direction_effects)
		animate(E, transform = turn(matrix(), dir2angle(current_dir)), time = 1)

	for(var/obj/effect/E in instruction_effects)
		switch(current_instruction)
			if(DDR_STAND) E.icon_state = "getup"
			if(DDR_LIE) E.icon_state = "getdown"

	sleep(process_delay)
	.()

/obj/structure/dance_dance_revolution/attack_hand(mob/user)
	if(dancer)
		to_chat(user, "<span class='info'>It's [dancer]'s turn! Wait until \he is done dancing.</span>")
		return

	dancer = user
	user.visible_message("<span class='notice'>[user] activates \the [src]!</span>", "<span class='info'>You activate \the [src].</span>")

	spawn(10)
		visible_message("<span class='danger'>3...</span>")
		playsound(get_turf(src), 'sound/machines/click.ogg', 50)
		sleep(10)
		visible_message("<span class='danger'>2...</span>")
		playsound(get_turf(src), 'sound/machines/click.ogg', 50)
		sleep(10)
		visible_message("<span class='danger'>1...</span>")
		playsound(get_turf(src), 'sound/machines/click.ogg', 50)
		sleep(10)
		visible_message("<span class='userdanger'>Go!</span>")
		playsound(get_turf(src), 'sound/machines/chime.ogg', 50)
		start_game()

/obj/effect/ddr_direction //Direction in which you should be facing
	name = "arrow"
	desc = "An enormous hologram slightly hovering above the floor."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "arrow"

/obj/effect/ddr_instruction //Stand / Lie
	name = "instructions"
	desc = "An enormous hologram slightly hovering above the floor."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "getup"

/obj/effect/ddr_loot //Turfs under these effects turn into plating when the game is won
	name = "Dance Dance Revolution loot pathway"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"

	invisibility = 101

#undef DDR_STAND
#undef DDR_LIE