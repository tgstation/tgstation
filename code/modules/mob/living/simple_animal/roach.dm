/mob/living/simple_animal/cockroach
	name = "cockroach"

	desc = "A small insect, able to survive in almost every environment."

	size = SIZE_TINY

	icon_state = "cockroach"
	icon_living = "cockroach"
	icon_dead = "mouse_gray_dead"

	emote_hear = list("hisses")

	pass_flags = PASSTABLE | PASSGRILLE | PASSMACHINE

	speak_chance = 1

	maxHealth = 4
	health = 4

	response_help  = "pets the"
	response_disarm = "pokes the"
	response_harm   = "stomps on the"

	density = 0

	minbodytemp = 273.15		//Can't survive at below 0 C
	maxbodytemp = INFINITY

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	treadmill_speed = 0
	turns_per_move = 2 //2 life ticks / move

	size = SIZE_TINY
	stop_automated_movement_when_pulled = 0

/mob/living/simple_animal/cockroach/New()
	..()

	pixel_x = rand(-20, 20)
	pixel_y = rand(-20, 20)

	maxHealth = rand(1,5)
	health = maxHealth

/mob/living/simple_animal/cockroach/Die()
	var/obj/effect/decal/remains = new /obj/effect/decal/cleanable/cockroach_remains(src.loc)
	remains.dir = src.dir
	remains.pixel_x = src.pixel_x
	remains.pixel_y = src.pixel_y

	if(flying)
		animate(remains, pixel_y = pixel_y - 8, 5, 1) //Fall down gracefully

	..()

	qdel(src)

/mob/living/simple_animal/cockroach/wander_move(turf/dest)
	..()

	//First, check for any food in our new surroundings
	for(var/obj/item/weapon/reagent_containers/food/F in loc)
		//If there is food, climb on it (using pixel_x and pixel_y manipulation)
		animate(src, pixel_x = F.pixel_x + rand(-4,4), pixel_y = F.pixel_y + rand(-4,4), rand(10,20), 1)

		if(flying)
			stop_flying(anim = 0)

		spawn()
			turns_since_move -= rand(5,20) //Stay here for a while. turns_since_move is set to 0 immediately after this proc, so the spawn() is required.

		return //Don't do anything after that

	//Then, check for any trash
	for(var/obj/item/trash/T in loc)
		//If there is trash, climb under it (using pixel_x, pixel_y and layer manipulation)
		animate(src, pixel_x = T.pixel_x, pixel_y = T.pixel_y, rand(10,30), 1)

		layer = T.layer - 0.01

		if(flying)
			stop_flying(anim = 0)

		spawn()
			turns_since_move -= rand(5,20) //Stay here for a while

		return

	//If there's no food, check for any walls to climb on
	var/turf/simulated/wall/T = dest //If we attempted to move into a wall
	if(istype(T))
		var/check_dir = get_dir(src, dest)

		//Climb on it!
		var/new_px = rand(-8,8) + cos(dir2angle(check_dir)) * 32
		var/new_py = rand(-8,8) + sin(dir2angle(check_dir)) * 32

		//Modify pixel_x and pixel_y to make it look like the cockroach is on the wall
		animate(src, pixel_x = new_px, rand(5,15), 1, ELASTIC_EASING)
		animate(src, pixel_y = new_py, rand(5,15), 1, ELASTIC_EASING)

		return

	//No food, trash, walls or anything - just modify our pixel_x and pixel_y
	animate(src, pixel_x = rand(-20,20), pixel_y = rand(-20,20), (flying ? 5 : 15) , 1) //This animation takes 1.5 seconds, or 0.5 if flying

/mob/living/simple_animal/cockroach/Move()
	..()

	layer = initial(layer) //Since cucarachas can hide under trash (which modifies their layer), this is kinda necessary

/mob/living/simple_animal/cockroach/adjustBruteLoss() //When receiving damage
	..()

	if(health > 0) //Still alive
		start_flying()

		if(usr)
			var/mob/user = usr
			var/turf/new_location = get_step(src, turn(get_dir(src,user),180)) //Walk away from the source of the damage

			wander_move(new_location)

		spawn(rand(4,10) SECONDS)
			stop_flying()

/mob/living/simple_animal/cockroach/proc/start_flying(var/anim = 1)
	if(isUnconscious()) return

	speed = -4
	turns_since_move = 5 //Remove any delay

	icon_state = "cockroach_fly"

	flying = 1
	speak_chance = 5

	turns_per_move = 1

	response_help  = "attepts to pet the"
	response_disarm = "tries to catch the"
	response_harm   = "swats the"


	if(anim) animate(src, pixel_y = pixel_y + 8, 10, 1, ELASTIC_EASING)

/mob/living/simple_animal/cockroach/proc/stop_flying(var/anim = 1)
	speed = initial(speed)
	icon_state = icon_living

	flying = 0
	speak_chance = initial(speak_chance)
	turns_per_move = initial(turns_per_move)

	response_help  = initial(response_help)
	response_disarm = initial(response_disarm)
	response_harm   = initial(response_harm)

	if(anim) animate(src, pixel_y = pixel_y - 8, 5, 1, ELASTIC_EASING)

/mob/living/simple_animal/cockroach/ex_act()
	start_flying()

	spawn(10 SECONDS)
		stop_flying()
