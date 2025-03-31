#define CAR_LAYER 4.5
#define O_LIGHTING_VISUAL_LAYER 17

GLOBAL_LIST_EMPTY(car_list)
SUBSYSTEM_DEF(carpool)
	name = "Car Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_OBJ
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 5

	var/list/currentrun = list()

/datum/controller/subsystem/carpool/stat_entry(msg)
	var/list/activelist = GLOB.car_list
	msg = "CARS:[length(activelist)]"
	return ..()

/datum/controller/subsystem/carpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/activelist = GLOB.car_list
		src.currentrun = activelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/vampire_car/CAR = currentrun[currentrun.len]
		--currentrun.len

		if (QDELETED(CAR))
			GLOB.car_list -= CAR
			if(QDELETED(CAR))
				log_world("Found a null in car list!")
			continue

		if(MC_TICK_CHECK)
			return
		CAR.handle_caring()

/obj/item/gas_can
	name = "gas can"
	desc = "Stores gasoline or pure fire death."
	icon_state = "gasoline"
	icon = 'code/modules/vehicles/cars/items.dmi'

	w_class = WEIGHT_CLASS_SMALL
	var/stored_gasoline = 0

/obj/item/gas_can/examine(mob/user)
	. = ..()
	. += "<b>Gas</b>: [stored_gasoline]/1000"

/obj/item/gas_can/full
	stored_gasoline = 1000

/obj/item/gas_can/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(istype(get_turf(A), /turf/open/floor) && !istype(A, /obj/vampire_car) && !istype(A, /mob/living/carbon/human))
		if(!proximity)
			return
		if(stored_gasoline < 50)
			return
		stored_gasoline = max(0, stored_gasoline-50)
		playsound(get_turf(src), 'code/modules/vehicles/cars/gas_splat.ogg', 50, TRUE)
	if(istype(A, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = A
		if(!proximity)
			return
		if(stored_gasoline < 50)
			return
		stored_gasoline = max(0, stored_gasoline-50)
		H.fire_stacks = min(10, H.fire_stacks+10)
		playsound(get_turf(H), 'code/modules/vehicles/cars/gas_splat.ogg', 50, TRUE)
		user.visible_message("<span class='warning'>[user] covers [A] in something flammable!</span>")


/obj/vampire_car/attack_hand(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.combat_mode)
			var/atom/throw_target = get_edge_target_turf(src, user.dir)
			playsound(get_turf(src), 'code/modules/vehicles/cars/bump.ogg', 100, FALSE)
			get_damage(10)
			throw_at(throw_target, rand(4, 6), 4, user)

/obj/vampire_car
	name = "car"
	desc = "Take me home, country roads..."
	icon_state = "2"
	icon = 'code/modules/vehicles/cars/cars.dmi'
	anchored = TRUE
	plane = GAME_PLANE
	layer = CAR_LAYER
	density = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	throwforce = 150

	var/last_vzhzh = 0

	var/image/Fari
	var/fari_on = FALSE

	var/mob/living/driver
	var/list/passengers = list()
	var/max_passengers = 3

	var/speed = 1	//Future
	var/stage = 1
	var/on = FALSE

	var/health = 400
	var/maxhealth = 400
	var/repairing = FALSE

	var/last_beep = 0

	var/exploded = FALSE
	var/beep_sound = 'code/modules/vehicles/cars/beep.ogg'

	var/gas = 1000


/obj/vampire_car/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	get_damage(5)
	for(var/mob/living/L in src)
		if(prob(50))
			L.apply_damage(P.damage, P.damage_type, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST))

/obj/vampire_car/click_alt(mob/user)
	if(!repairing)
		repairing = TRUE
		var/mob/living/L

		if(driver)
			L = driver
		else if(length(passengers))
			L = pick(passengers)
		else
			to_chat(user, "<span class='notice'>There's no one in [src].</span>")
			repairing = FALSE
			return

		user.visible_message("<span class='warning'>[user] begins pulling someone out of [src]!</span>", \
			"<span class='warning'>You begin pulling [L] out of [src]...</span>")
		if(do_after(user, 5 SECONDS, src))
			var/datum/action/carr/exit_car/C = locate() in L.actions
			user.visible_message("<span class='warning'>[user] has managed to get [L] out of [src].</span>", \
				"<span class='warning'>You've managed to get [L] out of [src].</span>")
			if(C)
				C.Trigger()
		else
			to_chat(user, "<span class='warning'>You've failed to get [L] out of [src].</span>")
		repairing = FALSE
		return

/obj/vampire_car/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/gas_can))
		var/obj/item/gas_can/G = I
		if(G.stored_gasoline && gas < 1000 && isturf(user.loc))
			var/gas_to_transfer = min(1000-gas, min(100, max(1, G.stored_gasoline)))
			G.stored_gasoline = max(0, G.stored_gasoline-gas_to_transfer)
			gas = min(1000, gas+gas_to_transfer)
			playsound(loc, 'code/modules/vehicles/cars/gas_fill.ogg', 25, TRUE)
			to_chat(user, "<span class='notice'>You transfer [gas_to_transfer] fuel to [src].</span>")
		return

	if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(!I.tool_start_check(user, amount=1))
			return
		if(!repairing)
			if(health >= maxhealth)
				to_chat(user, "<span class='notice'>[src] is already fully repaired.</span>")
				return
			repairing = TRUE

			var time_to_repair = (maxhealth - health) / 8 //Repair 4hp for every second spent repairing
			var start_time = world.time

			user.visible_message("<span class='notice'>[user] begins repairing [src]...</span>", \
				"<span class='notice'>You begin repairing [src]. Stop at any time to only partially repair it.</span>")
			if(do_after(user, time_to_repair SECONDS, src))
				health = maxhealth
				playsound(src, 'code/modules/vehicles/cars/repair.ogg', 50, TRUE)
				user.visible_message("<span class='notice'>[user] repairs [src].</span>", \
					"<span class='notice'>You finish repairing all the dents on [src].</span>")
				color = "#ffffff"
				repairing = FALSE
				return
			else
				get_damage((world.time - start_time) * -2 / 5) //partial repair
				playsound(src, 'code/modules/vehicles/cars/repair.ogg', 50, TRUE)
				user.visible_message("<span class='notice'>[user] repairs [src].</span>", \
					"<span class='notice'>You repair some of the dents on [src].</span>")
				color = "#ffffff"
				repairing = FALSE
				return
		return

	else
		if(I.force)
			get_damage(round(I.force/2))
			for(var/mob/living/L in src)
				if(prob(50))
					L.apply_damage(round(I.force/2), I.damtype, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST))

			if(!driver && !length(passengers) && last_beep+70 < world.time)
				last_beep = world.time
				playsound(src, 'code/modules/vehicles/cars/signal.ogg', 50, FALSE)
	..()

/obj/vampire_car/Destroy()
	GLOB.car_list -= src
	. = ..()
	for(var/mob/living/L in src)
		L.forceMove(loc)
		var/datum/action/carr/exit_car/E = locate() in L.actions
		if(E)
			qdel(E)
		var/datum/action/carr/fari_vrubi/F = locate() in L.actions
		if(F)
			qdel(F)
		var/datum/action/carr/engine/N = locate() in L.actions
		if(N)
			qdel(N)
		var/datum/action/carr/stage/S = locate() in L.actions
		if(S)
			qdel(S)
		var/datum/action/carr/beep/B = locate() in L.actions
		if(B)
			qdel(B)

/obj/vampire_car/examine(mob/user)
	. = ..()
	if(user.loc == src)
		. += "<b>Gas</b>: [gas]/1000"
	if(health < maxhealth && health >= maxhealth-(maxhealth/4))
		. += "It's slightly dented..."
	if(health < maxhealth-(maxhealth/4) && health >= maxhealth/2)
		. += "It has some major dents..."
	if(health < maxhealth/2 && health >= maxhealth/4)
		. += "It's heavily damaged..."
	if(health < maxhealth/4)
		. += "<span class='warning'>It appears to be falling apart...</span>"
	if(driver || length(passengers))
		. += "<span class='notice'>\nYou see the following people inside:</span>"
		for(var/mob/living/rider in src)
			. += "<span class='notice'>* [rider]</span>"
	. += "You cant Alt-click to remove occupant."

/obj/vampire_car/proc/get_damage(var/cost)
	if(cost > 0)
		health = max(0, health-cost)
	if(cost < 0)
		health = min(maxhealth, health-cost)

	if(health == 0)
		on = FALSE
		set_light(0)
		color = "#919191"
		if(!exploded && prob(10))
			exploded = TRUE
			for(var/mob/living/L in src)
				L.forceMove(loc)
				var/datum/action/carr/exit_car/E = locate() in L.actions
				if(E)
					qdel(E)
				var/datum/action/carr/fari_vrubi/F = locate() in L.actions
				if(F)
					qdel(F)
				var/datum/action/carr/engine/N = locate() in L.actions
				if(N)
					qdel(N)
				var/datum/action/carr/stage/S = locate() in L.actions
				if(S)
					qdel(S)
				var/datum/action/carr/beep/B = locate() in L.actions
				if(B)
					qdel(B)
			explosion(loc,0,1,3,4)
			GLOB.car_list -= src
			qdel(src)
	else if(prob(50) && health <= maxhealth/2)
		on = FALSE
		loc.balloon_alert(driver, "engine stops")
		set_light(0)
	return

/datum/action/carr/fari_vrubi
	name = "Toggle Light"
	desc = "Toggle light on/off."
	button_icon_state = "lights"

/datum/action/carr/fari_vrubi/Trigger(trigger_flags)
	if(istype(owner.loc, /obj/vampire_car))
		var/obj/vampire_car/V = owner.loc
		if(!V.fari_on)
			V.fari_on = TRUE
			V.add_overlay(V.Fari)
			to_chat(owner, "<span class='notice'>You toggle [V]'s lights.</span>")
			playsound(V, 'code/modules/vehicles/cars/magin.ogg', 40, TRUE)
		else
			V.fari_on = FALSE
			V.cut_overlay(V.Fari)
			to_chat(owner, "<span class='notice'>You toggle [V]'s lights.</span>")
			playsound(V, 'code/modules/vehicles/cars/magout.ogg', 40, TRUE)

/datum/action/carr/beep
	name = "Signal"
	desc = "Beep-beep."
	button_icon_state = "beep"

/datum/action/carr/beep/Trigger(trigger_flags)
	if(istype(owner.loc, /obj/vampire_car))
		var/obj/vampire_car/V = owner.loc
		if(V.last_beep+10 < world.time)
			V.last_beep = world.time
			playsound(V.loc, V.beep_sound, 60, FALSE)

/datum/action/carr/stage
	name = "Toggle Transmission"
	desc = "Toggle transmission to 1, 2 or 3."
	button_icon_state = "stage"

/datum/action/carr/stage/Trigger(trigger_flags)
	if(istype(owner.loc, /obj/vampire_car))
		var/obj/vampire_car/V = owner.loc
		if(V.stage < 3)
			V.stage = V.stage+1
		else
			V.stage = 1
		to_chat(owner, "<span class='notice'>You enable [V]'s transmission at [V.stage].</span>")

/datum/action/carr/engine
	name = "Toggle Engine"
	desc = "Toggle engine on/off."
	button_icon_state = "keys"

/datum/action/carr/engine/Trigger(trigger_flags)
	if(istype(owner.loc, /obj/vampire_car))
		var/obj/vampire_car/V = owner.loc
		if(!V.on)
			if(V.health == V.maxhealth)
				V.on = TRUE
				playsound(V, 'code/modules/vehicles/cars/start.ogg', 50, TRUE)
				to_chat(owner, "<span class='notice'>You managed to start [V]'s engine.</span>")
				return
			if(prob(100*(V.health/V.maxhealth)))
				V.on = TRUE
				playsound(V, 'code/modules/vehicles/cars/start.ogg', 50, TRUE)
				to_chat(owner, "<span class='notice'>You managed to start [V]'s engine.</span>")
				return
			else
				to_chat(owner, "<span class='warning'>You failed to start [V]'s engine.</span>")
				return
		else
			V.on = FALSE
			playsound(V, 'code/modules/vehicles/cars/stop.ogg', 50, TRUE)
			to_chat(owner, "<span class='notice'>You stop [V]'s engine.</span>")
			V.set_light(0)
			return

/datum/action/carr/exit_car
	name = "Exit"
	desc = "Exit the vehicle."
	button_icon_state = "exit"

/datum/action/carr/exit_car/Trigger(trigger_flags)
	if(istype(owner.loc, /obj/vampire_car))
		var/obj/vampire_car/V = owner.loc
		if(V.driver == owner)
			V.driver = null
		if(owner in V.passengers)
			V.passengers -= owner
		owner.forceMove(V.loc)

		var/list/exit_side = list(
			SIMPLIFY_DEGREES(V.movement_vector + 90),
			SIMPLIFY_DEGREES(V.movement_vector - 90)
		)
		for(var/angle in exit_side)
			if(get_step(owner, angle2dir(angle)).density)
				exit_side.Remove(angle)
		var/list/exit_alt = GLOB.alldirs.Copy()
		for(var/dir in exit_alt)
			if(get_step(owner, dir).density)
				exit_alt.Remove(dir)
		if(length(exit_side))
			owner.Move(get_step(owner, angle2dir(pick(exit_side))))
		else if(length(exit_alt))
			owner.Move(get_step(owner, exit_alt))

		to_chat(owner, "<span class='notice'>You exit [V].</span>")
		if(owner)
			if(owner.client)
				owner.client.pixel_x = 0
				owner.client.pixel_y = 0
		playsound(V, 'code/modules/vehicles/cars/door.ogg', 50, TRUE)
		for(var/datum/action/carr/C in owner.actions)
			qdel(C)

/mob/living/carbon/human/mouse_drop_dragged(atom/over_object)
	if(istype(over_object, /obj/vampire_car) && get_dist(src, over_object) < 2)
		var/obj/vampire_car/V = over_object

		if(V.driver && (length(V.passengers) >= V.max_passengers))
			to_chat(src, "<span class='warning'>There's no space left for you in [V].")
			return

		visible_message("<span class='notice'>[src] begins entering [V]...</span>", \
			"<span class='notice'>You begin entering [V]...</span>")
		if(do_after(src, 1 SECONDS, over_object))
			if(!V.driver)
				forceMove(over_object)
				V.driver = src
				var/datum/action/carr/exit_car/E = new()
				E.Grant(src)
				var/datum/action/carr/fari_vrubi/F = new()
				F.Grant(src)
				var/datum/action/carr/engine/N = new()
				N.Grant(src)
				var/datum/action/carr/stage/S = new()
				S.Grant(src)
				var/datum/action/carr/beep/B = new()
				B.Grant(src)
			else if(length(V.passengers) < V.max_passengers)
				forceMove(over_object)
				V.passengers += src
				var/datum/action/carr/exit_car/E = new()
				E.Grant(src)
			visible_message("<span class='notice'>[src] enters [V].</span>", \
				"<span class='notice'>You enter [V].</span>")
			playsound(V, 'code/modules/vehicles/cars/door.ogg', 50, TRUE)
			return
		else
			to_chat(src, "<span class='warning'>You fail to enter [V].")
			return

/obj/vampire_car/Bump(atom/A)
	if(!A)
		return

	var/prev_speed
	if(!istype(A, /mob/living))
		prev_speed = round(abs(speed_in_pixels)/8)

	if(istype(A, /mob/living))
		prev_speed = round(abs(speed_in_pixels)* 0.95)
		var/mob/living/hit_mob = A
		switch(hit_mob.mob_size)
			if(MOB_SIZE_HUGE) 	//gangrel warforms, werewolves, bears, ppl with fortitude
				playsound(src, 'code/modules/vehicles/cars/bump.ogg', 75, TRUE)
				speed_in_pixels = 0
				impact_delay = world.time
				hit_mob.Knockdown(3 SECONDS)
			if(MOB_SIZE_LARGE)	//ppl with fat bodytype
				playsound(src, 'code/modules/vehicles/cars/bump.ogg', 60, TRUE)
				speed_in_pixels = round(speed_in_pixels * 0.9)
				hit_mob.Knockdown(3 SECONDS)
			if(MOB_SIZE_SMALL)	//small animals
				playsound(src, 'code/modules/vehicles/cars/bump.ogg', 40, TRUE)
				speed_in_pixels = round(speed_in_pixels * 0.9)
				hit_mob.Paralyze(3 SECONDS)
				hit_mob.Knockdown(3 SECONDS)
			else				//everything else
				playsound(src, 'code/modules/vehicles/cars/bump.ogg', 50, TRUE)
				speed_in_pixels = round(speed_in_pixels * 0.9)
				hit_mob.Paralyze(3 SECONDS)
				hit_mob.Knockdown(3 SECONDS)

	else
		playsound(src, 'code/modules/vehicles/cars/bump.ogg', 75, TRUE)
		speed_in_pixels = 0
		impact_delay = world.time

	last_pos["x_pix"] = 0
	last_pos["y_pix"] = 0
	for(var/mob/living/L in src)
		if(L)
			if(L.client)
				L.client.pixel_x = 0
				L.client.pixel_y = 0
	if(istype(A, /mob/living))
		var/mob/living/L = A
		var/dam2 = prev_speed
		L.apply_damage(dam2, BRUTE, BODY_ZONE_CHEST)
		var/dam = prev_speed
		if(driver)
			if(HAS_TRAIT(driver, TRAIT_EXP_DRIVER))
				dam = round(dam*0.5)
		get_damage(dam*0.5)
	else
		var/dam = prev_speed
		if(driver)
			if(HAS_TRAIT(driver, TRAIT_EXP_DRIVER))
				dam = round(dam*0.5)
			driver.apply_damage(round(dam*0.5), BRUTE, BODY_ZONE_CHEST)
		get_damage(dam*0.5)
	return

/obj/vampire_car/retro
	icon_state = "1"
	max_passengers = 1
	dir = WEST

/obj/vampire_car/retro/second
	icon_state = "2"

/obj/vampire_car/retro/third
	icon_state = "3"

/obj/vampire_car/rand
	icon_state = "4"
	dir = WEST

/obj/vampire_car/rand/camarilla
	icon_state = "6"

/obj/vampire_car/retro/rand/camarilla
	icon_state = "5"

/obj/vampire_car/rand/anarch
	icon_state = "6"

/obj/vampire_car/retro/rand/anarch
	icon_state = "5"

/obj/vampire_car/rand/clinic
	icon_state = "6"

/obj/vampire_car/retro/rand/clinic
	icon_state = "5"

/obj/vampire_car/limousine
	icon_state = "limo"
	max_passengers = 6
	dir = WEST

/obj/vampire_car/limousine/giovanni
	icon_state = "giolimo"
	max_passengers = 6
	dir = WEST

/obj/vampire_car/limousine/camarilla
	icon_state = "limo"
	max_passengers = 6
	dir = WEST

/obj/vampire_car/police
	icon_state = "police"
	max_passengers = 3
	dir = WEST
	beep_sound = 'code/modules/vehicles/cars/veevoo.ogg'
	var/color_blue = FALSE
	var/last_color_change = 0

/obj/vampire_car/police/handle_caring()
	if(fari_on)
		if(last_color_change+10 <= world.time)
			last_color_change = world.time
			if(color_blue)
				color_blue = FALSE
				set_light(0)
				set_light(4, 6, "#ff0000")
			else
				color_blue = TRUE
				set_light(0)
				set_light(4, 6, "#0000ff")
	else
		if(last_color_change+10 <= world.time)
			last_color_change = world.time
			set_light(0)
	..()

/obj/vampire_car/taxi
	icon_state = "taxi"
	max_passengers = 3
	dir = WEST

/obj/vampire_car/track
	icon_state = "track"
	max_passengers = 6
	dir = WEST

/obj/vampire_car/track/volkswagen
	icon_state = "volkswagen"

/obj/vampire_car/track/ambulance
	icon_state = "ambulance"

/proc/get_dist_in_pixels(var/pixel_starts_x, var/pixel_starts_y, var/pixel_ends_x, var/pixel_ends_y)
	var/total_x = abs(pixel_starts_x-pixel_ends_x)
	var/total_y = abs(pixel_starts_y-pixel_ends_y)
	return round(sqrt(total_x*total_x + total_y*total_y))


/proc/get_angle_diff(var/angle_a, var/angle_b)
	return ((angle_b - angle_a) + 180) % 360 - 180;

/obj/vampire_car
	var/movement_vector = 0		//0-359 degrees
	var/speed_in_pixels = 0		// 16 pixels (turf is 2x2m) = 1 meter per 1 SECOND (process fire). Minus equals to reverse, max should be 444
	var/last_pos = list("x" = 0, "y" = 0, "x_pix" = 0, "y_pix" = 0, "x_frwd" = 0, "y_frwd" = 0)
	var/impact_delay = 0
	glide_size = 96

/obj/vampire_car/Initialize(mapload)
	. = ..()
	Fari = new (src)
	Fari.icon = 'code/modules/vehicles/cars/light_cone_car.dmi'
	Fari.icon_state = "light"
	Fari.pixel_x = -64
	Fari.pixel_y = -64
	Fari.layer = O_LIGHTING_VISUAL_LAYER
	Fari.plane = O_LIGHTING_VISUAL_PLANE
	Fari.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	Fari.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
//	Fari.vis_flags = NONE
	Fari.alpha = 110
	gas = rand(100, 1000)
	GLOB.car_list += src
	last_pos["x"] = x
	last_pos["y"] = y
//	last_pos["x_pix"] = 32
//	last_pos["y_pix"] = 32
	switch(dir)
		if(SOUTH)
			movement_vector = 180
		if(EAST)
			movement_vector = 90
		if(WEST)
			movement_vector = 270
	add_overlay(image(icon = src.icon, icon_state = src.icon_state, pixel_x = -32, pixel_y = -32))
	icon_state = "empty"

/obj/vampire_car/setDir(newdir)
	. = ..()
	apply_vector_angle()

/obj/vampire_car/Moved(atom/OldLoc, Dir, forced, list/old_locs, momentum_change)
	. = ..()
	last_pos["x"] = x
	last_pos["y"] = y

/obj/vampire_car/proc/handle_caring()
	speed_in_pixels = max(speed_in_pixels, -64)
	var/used_vector = movement_vector
	var/used_speed = speed_in_pixels

	if(gas <= 0)
		on = FALSE
		set_light(0)
		if(driver)
			to_chat(driver, "<span class='warning'>No fuel in the tank!</span>")
	if(on)
		if(last_vzhzh+10 < world.time)
			playsound(src, 'code/modules/vehicles/cars/work.ogg', 25, FALSE)
			last_vzhzh = world.time
	if(!on || !driver)
		speed_in_pixels = (speed_in_pixels < 0 ? -1 : 1) * max(abs(speed_in_pixels) - 15, 0)

	forceMove(locate(last_pos["x"], last_pos["y"], z))
	pixel_x = last_pos["x_pix"]
	pixel_y = last_pos["y_pix"]
	var/moved_x = round(sin(used_vector)*used_speed)
	var/moved_y = round(cos(used_vector)*used_speed)
	if(used_speed != 0)
		var/true_movement_angle = used_vector
		if(used_speed < 0)
			true_movement_angle = SIMPLIFY_DEGREES(used_vector+180)
		var/turf/check_turf = locate( \
			x + (moved_x < 0 ? -1 : 1) * round(max(abs(moved_x), 36) / 32), \
			y + (moved_y < 0 ? -1 : 1) * round(max(abs(moved_y), 36) / 32), \
			z
		)
		//to_chat(world, "--check_turf [check_turf] X: [check_turf.x] Y: [check_turf.y] Z:[z] used_speed:[used_speed]")
		//to_chat(world, "--moved_x:[moved_x], moved_y:[moved_y] ")
		var/turf/hit_turf
		var/mob/living/hit_mob
		var/list/in_line = get_line(src, check_turf)
		for(var/turf/T in in_line)
			var/dist_to_hit = get_dist_in_pixels(last_pos["x"]*32+last_pos["x_pix"], last_pos["y"]*32+last_pos["y_pix"], T.x*32, T.y*32)
			//to_chat(world, "_dist_to_hit [dist_to_hit] T.density [T.density]")
			if(T.density)
				if(dist_to_hit <= used_speed)
					if(!hit_turf || dist_to_hit < get_dist_in_pixels(last_pos["x"]*32+last_pos["x_pix"], last_pos["y"]*32+last_pos["y_pix"], hit_turf.x*32, hit_turf.y*32))
						hit_turf = T
						//message_admins("ht:[hit_turf], dist_to_hit:[dist_to_hit] ")
			for(var/obj/O as obj|mob in T.contents)
				if(istype(O, /mob/living))
					hit_mob = O
					hit_turf = null
				if(O.density && O != src)
					//to_chat(world, "dist_to_hit [dist_to_hit] O [O] O.density [O.density])]")
					if(!hit_turf || dist_to_hit < get_dist_in_pixels(last_pos["x"]*32+last_pos["x_pix"], last_pos["y"]*32+last_pos["y_pix"], hit_turf.x*32, hit_turf.y*32))
						hit_turf = O.loc
						//message_admins("hit_mob:[hit_turf] ")

			if(hit_mob)
				Bump(hit_mob)
				//to_chat(world, "I can't pass MOB [hit_mob] at [hit_turf.x] x [hit_turf.y] YEAA)]")
		if(hit_turf)
			Bump(hit_turf)
			//to_chat(world, "I can't pass that [hit_turf] at [hit_turf.x] x [hit_turf.y] FUCK)]")
			// var/bearing = get_angle_raw(x, y, pixel_x, pixel_y, hit_turf.x, hit_turf.y, 0, 0)
			var/actual_distance = get_dist_in_pixels(last_pos["x"]*32+last_pos["x_pix"], last_pos["y"]*32+last_pos["y_pix"], hit_turf.x*32, hit_turf.y*32)-32
			moved_x = round(sin(true_movement_angle)*actual_distance)
			moved_y = round(cos(true_movement_angle)*actual_distance)
			if(last_pos["x"]*32+last_pos["x_pix"] > hit_turf.x*32)
				moved_x = max((hit_turf.x*32+32)-(last_pos["x"]*32+last_pos["x_pix"]), moved_x)
			if(last_pos["x"]*32+last_pos["x_pix"] < hit_turf.x*32)
				moved_x = min((hit_turf.x*32-32)-(last_pos["x"]*32+last_pos["x_pix"]), moved_x)
			if(last_pos["y"]*32+last_pos["y_pix"] > hit_turf.y*32)
				moved_y = max((hit_turf.y*32+32)-(last_pos["y"]*32+last_pos["y_pix"]), moved_y)
			if(last_pos["y"]*32+last_pos["y_pix"] < hit_turf.y*32)
				moved_y = min((hit_turf.y*32-32)-(last_pos["y"]*32+last_pos["y_pix"]), moved_y)
	var/turf/west_turf = get_step(src, WEST)
	if(length(west_turf))
		moved_x = max(-8-last_pos["x_pix"], moved_x)
	var/turf/east_turf = get_step(src, EAST)
	if(length(east_turf))
		moved_x = min(8-last_pos["x_pix"], moved_x)
	var/turf/north_turf = get_step(src, NORTH)
	if(length(north_turf))
		moved_y = min(8-last_pos["y_pix"], moved_y)
	var/turf/south_turf = get_step(src, SOUTH)
	if(length(south_turf))
		moved_y = max(-8-last_pos["y_pix"], moved_y)

	for(var/mob/living/rider in src)
		if(rider)
			if(rider.client)
				rider.client.pixel_x = last_pos["x_frwd"]
				rider.client.pixel_y = last_pos["y_frwd"]
				animate(rider.client, \
					pixel_x = last_pos["x_pix"] + moved_x * 2, \
					pixel_y = last_pos["y_pix"] + moved_y * 2, \
					SScarpool.wait, 1)

	animate(src, pixel_x = last_pos["x_pix"]+moved_x, pixel_y = last_pos["y_pix"]+moved_y, SScarpool.wait, 1)

	last_pos["x_frwd"] = last_pos["x_pix"] + moved_x * 2
	last_pos["y_frwd"] = last_pos["y_pix"] + moved_y * 2
	last_pos["x_pix"] = last_pos["x_pix"] + moved_x
	last_pos["y_pix"] = last_pos["y_pix"] + moved_y

	var/x_add = (last_pos["x_pix"] < 0 ? -1 : 1) * round((abs(last_pos["x_pix"]) + 16) / 32)
	var/y_add = (last_pos["y_pix"] < 0 ? -1 : 1) * round((abs(last_pos["y_pix"]) + 16) / 32)

	last_pos["x_frwd"] -= x_add * 32
	last_pos["y_frwd"] -= y_add * 32
	last_pos["x_pix"] -= x_add * 32
	last_pos["y_pix"] -= y_add * 32

	last_pos["x"] = clamp(last_pos["x"] + x_add, 1, world.maxx)
	last_pos["y"] = clamp(last_pos["y"] + y_add, 1, world.maxy)

/obj/vampire_car/relaymove(mob/living/carbon/human/driver, direct)
	if(world.time-impact_delay < 20)
		return
	if(driver.IsUnconscious() || HAS_TRAIT(driver, TRAIT_INCAPACITATED) || HAS_TRAIT(driver, TRAIT_RESTRAINED))
		return
	var/turn_speed = min(abs(speed_in_pixels) / 10, 3)
	switch(direct)
		if(NORTH)
			controlling(1, 0)
		if(NORTHEAST)
			controlling(1, turn_speed)
		if(NORTHWEST)
			controlling(1, -turn_speed)
		if(SOUTH)
			controlling(-1, 0)
		if(SOUTHEAST)
			controlling(-1, turn_speed)
		if(SOUTHWEST)
			controlling(-1, -turn_speed)
		if(EAST)
			controlling(0, turn_speed)
		if(WEST)
			controlling(0, -turn_speed)

/obj/vampire_car/proc/controlling(var/adjusting_speed, var/adjusting_turn)
	var/drift = 1
	if(driver)
		if(HAS_TRAIT(driver, TRAIT_EXP_DRIVER))
			drift = 2
	var/adjust_true = adjusting_turn
	if(speed_in_pixels != 0)
		movement_vector = SIMPLIFY_DEGREES(movement_vector+adjust_true)
		apply_vector_angle()
	if(adjusting_speed)
		if(on)
			if(adjusting_speed > 0 && speed_in_pixels <= 0)
				playsound(src, 'code/modules/vehicles/cars/stopping.ogg', 10, FALSE)
				speed_in_pixels = speed_in_pixels+adjusting_speed*3
				movement_vector = SIMPLIFY_DEGREES(movement_vector+adjust_true*drift)
			else if(adjusting_speed < 0 && speed_in_pixels > 0)
				playsound(src, 'code/modules/vehicles/cars/stopping.ogg', 10, FALSE)
				speed_in_pixels = speed_in_pixels+adjusting_speed*3
				movement_vector = SIMPLIFY_DEGREES(movement_vector+adjust_true*drift)
			else
				speed_in_pixels = min(stage*64, max(-stage*64, speed_in_pixels+adjusting_speed*stage))
				playsound(src, 'code/modules/vehicles/cars/drive.ogg', 10, FALSE)
		else
			if(adjusting_speed > 0 && speed_in_pixels < 0)
				playsound(src, 'code/modules/vehicles/cars/stopping.ogg', 10, FALSE)
				speed_in_pixels = min(0, speed_in_pixels+adjusting_speed*3)
				movement_vector = SIMPLIFY_DEGREES(movement_vector+adjust_true*drift)
			else if(adjusting_speed < 0 && speed_in_pixels > 0)
				playsound(src, 'code/modules/vehicles/cars/stopping.ogg', 10, FALSE)
				speed_in_pixels = max(0, speed_in_pixels+adjusting_speed*3)
				movement_vector = SIMPLIFY_DEGREES(movement_vector+adjust_true*drift)

/obj/vampire_car/proc/apply_vector_angle()
	var/turn_state = round(SIMPLIFY_DEGREES(movement_vector + 22.5) / 45)
	dir = GLOB.modulo_angle_to_dir[turn_state + 1]
	var/minus_angle = turn_state * 45

	var/matrix/M = matrix()
	M.Turn(movement_vector - minus_angle)
	transform = M


#undef CAR_LAYER
#undef O_LIGHTING_VISUAL_LAYER
