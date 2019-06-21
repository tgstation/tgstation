/*#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2
#define VEHICLE_CONTROL_KIDNAPPED 4 //Can't leave vehicle voluntarily, has to resist.
//Car trait flags
#define CAN_KIDNAP 1*/

/obj/vehicle/sealed
	var/mouse_pointer

/obj/vehicle/sealed/car
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	var/car_traits = NONE //Bitflag for special behavior such as kidnapping
	var/engine_sound = 'sound/toolbox/car/carrev.ogg'
	var/last_enginesound_time
	var/engine_sound_length = 20 //Set this to the length of the engine sound
	var/escape_time = 60 //Time it takes to break out of the car
	default_driver_move = FALSE

/obj/vehicle/sealed/car/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = movedelay
	D.slowvalue = 0

/obj/vehicle/sealed/car/driver_move(mob/user, direction)
	if(key_type && !is_key(inserted_key))
		to_chat(user, "<span class='warning'>[src] has no key inserted!</span>")
		return FALSE
	if(!canmove)
		return
	var/datum/component/riding/R = GetComponent(/datum/component/riding)
	R.handle_ride(user, direction)
	if(world.time < last_enginesound_time + engine_sound_length)
		return
	last_enginesound_time = world.time
	playsound(src, engine_sound, 100, TRUE)

/obj/vehicle/sealed/car/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/remove_key, VEHICLE_CONTROL_DRIVE)
	if(car_traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/sealed/DumpKidnappedMobs, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/MouseDrop_T(atom/dropping, mob/M)
	if(!M.canmove || M.stat || M.restrained())
		return FALSE
	if((car_traits & CAN_KIDNAP) && isliving(dropping) && M != dropping)
		var/mob/living/L = dropping
		L.visible_message("<span class='warning'>[M] starts forcing [L] into [src]!</span>")
		mob_try_forced_enter(M, L)
	return ..()

/obj/vehicle/sealed/car/mob_try_exit(mob/M, mob/user, silent = FALSE)
	if(M == user && (occupants[M] & VEHICLE_CONTROL_KIDNAPPED))
		to_chat(user, "<span class='notice'>You push against the back of [src] trunk to try and get out.</span>")
		if(!do_after(user, escape_time, target = src))
			return FALSE
		to_chat(user,"<span class='danger'>[user] gets out of [src]</span>")
		mob_exit(M, silent)
		return TRUE
	mob_exit(M, silent)
	return TRUE

/obj/vehicle/sealed/car/attacked_by(obj/item/I, mob/living/user)
	if(!I.force)
		return
	if(occupants[user])
		to_chat(user, "<span class='notice'>Your attack bounces off of the car's padded interior.</span>")
		return
	return ..()

/obj/vehicle/sealed/car/attack_hand(mob/living/user)
	. = ..()
	if(!(car_traits & CAN_KIDNAP))
		return
	if(occupants[user])
		return
	to_chat(user, "<span class='notice'>You start opening [src]'s trunk.</span>")
	if(do_after(user, 30))
		if(return_amount_of_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
			to_chat(user, "<span class='notice'>The people stuck in [src]'s trunk all come tumbling out.</span>")
			DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)
		else
			to_chat(user, "<span class='notice'>It seems [src]'s trunk was empty.</span>")

/obj/vehicle/sealed/car/proc/mob_try_forced_enter(mob/forcer, mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	var/atom/old_loc = loc
	if(do_mob(forcer, M, get_enter_delay(M), extra_checks=CALLBACK(src, /obj/vehicle/sealed/car/proc/is_car_stationary, old_loc)))
		mob_forced_enter(M, silent)
		return TRUE
	return FALSE

/obj/vehicle/sealed/car/proc/is_car_stationary(atom/old_loc)
	return (old_loc == loc)

/obj/vehicle/sealed/car/proc/mob_forced_enter(mob/M, silent = FALSE)
	if(!silent)
		M.visible_message("<span class='warning'>[M] is forced into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/proc/update_mouse_pointer(mob/living/L)
	if(!L.client)
		return
	L.client.mouse_pointer_icon = initial(L.client.mouse_pointer_icon)
	if(mouse_pointer && L.loc == src)
		L.client.mouse_pointer_icon = mouse_pointer

//clowncar
/obj/vehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is beyond me."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "clowncar"
	max_integrity = 150
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 20
	max_occupants = 50
	movedelay = 0.6
	car_traits = CAN_KIDNAP
	key_type = /obj/item/bikehorn
	key_type_exact = FALSE
	var/droppingoil = FALSE
	var/RTDcooldown = 150
	var/lastRTDtime = 0
	var/cannonmode = FALSE
	var/cannonbusy = FALSE

/obj/vehicle/sealed/car/clowncar/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn/clowncar, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.assigned_role == "Clown") //Ensures only clowns can drive the car. (Including more at once)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/mob_forced_enter(mob/M, silent = FALSE)
	. = ..()
	playsound(src, pick('sound/toolbox/car/clowncar_load1.ogg', 'sound/toolbox/car/clowncar_load2.ogg'), 75)

/obj/vehicle/sealed/car/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(33))
		visible_message("<span class='danger'>[src] spews out a ton of space lube!</span>")
		new /obj/effect/particle_effect/foam(loc) //YEET

/obj/vehicle/sealed/car/clowncar/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/reagent_containers/food/snacks/grown/banana))
		var/obj/item/reagent_containers/food/snacks/grown/banana/banana = I
		obj_integrity += min(banana.seed.potency, max_integrity-obj_integrity)
		to_chat(user, "<span class='danger'>You use the [banana] to repair the [src]!</span>")
		qdel(banana)

/obj/vehicle/sealed/car/clowncar/Bump(atom/movable/M)
	. = ..()
	if(isliving(M))
		if(ismegafauna(M))
			return
		var/mob/living/L = M
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.Knockdown(40) //I play to make sprites go horizontal
		L.visible_message("<span class='warning'>[src] rams into [L] and sucks him up!</span>") //fuck off shezza this isn't ERP.
		mob_forced_enter(L)
		playsound(src, pick('sound/toolbox/car/clowncar_ram1.ogg', 'sound/toolbox/car/clowncar_ram2.ogg', 'sound/toolbox/car/clowncar_ram3.ogg'), 75)
	else if(istype(M, /turf/closed))
		visible_message("<span class='warning'>[src] rams into [M] and crashes!</span>")
		playsound(src, pick('sound/toolbox/car/clowncar_crash1.ogg', 'sound/toolbox/car/clowncar_crash2.ogg'), 75)
		playsound(src, 'sound/toolbox/car/clowncar_crashpins.ogg', 75)
		DumpMobs(TRUE)

/obj/vehicle/sealed/car/clowncar/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='danger'>You scramble the clowncar child safety lock and a panel with 6 colorful buttons appears!</span>")
	initialize_controller_action_type(/datum/action/vehicle/sealed/RollTheDice, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/Cannon, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/clowncar/Destroy()
	playsound(src, 'sound/toolbox/car/clowncar_fart.ogg', 100)
	return ..()

/obj/vehicle/sealed/car/clowncar/after_move(direction)
	. = ..()
	if(droppingoil)
		new /obj/effect/decal/cleanable/oil/slippery(loc)

/obj/vehicle/sealed/car/clowncar/proc/RollTheDice(mob/user)
	if(world.time - lastRTDtime < RTDcooldown)
		to_chat(user, "<span class='notice'>The button panel is currently recharging.</span>")
		return
	lastRTDtime = world.time
	var/randomnum = rand(1,6)
	switch(randomnum)
		if(1)
			visible_message("<span class='danger'>[user] has pressed one of the colorful buttons on [src] and a special banana peel drops out of it.</span>")
			new /obj/item/grown/bananapeel/specialpeel(loc)
		if(2)
			visible_message("<span class='danger'>[user] has pressed one of the colorful buttons on [src] and unknown chemicals flood out of it.</span>")
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(get_random_reagent_id(), 100)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, loc, R)
			foam.start()
		if(3)
			visible_message("<span class='danger'>[user] has pressed one of the colorful buttons on [src] and the clown car turns on its singularity disguise system.</span>")
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			addtimer(CALLBACK(src, .proc/ResetIcon), 100)
		if(4)
			visible_message("<span class='danger'>[user] has pressed one of the colorful buttons on [src] and the clown car spews out a cloud of laughing gas.</span>")
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent("superlaughter", 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new()
			smoke.set_up(R, 4)
			smoke.attach(src)
			smoke.start()
		if(5)
			visible_message("<span class='danger'>[user] has pressed one of the colorful buttons on [src] and the clown car starts dropping an oil trail.</span>")
			droppingoil = TRUE
			addtimer(CALLBACK(src, .proc/StopDroppingOil), 30)
		if(6)
			visible_message("<span class='danger'>[user] has pressed one of the colorful buttons on [src] and the clown car lets out a comedic toot.</span>")
			playsound(src, 'sound/toolbox/car/clowncar_fart.ogg', 100)
			for(var/mob/living/L in orange(loc, 6))
				L.emote("laughs")
			for(var/mob/living/L in occupants)
				L.emote("laughs")

/obj/vehicle/sealed/car/clowncar/proc/ResetIcon()
	icon = initial(icon)
	icon_state = initial(icon_state)

/obj/vehicle/sealed/car/clowncar/proc/StopDroppingOil()
	droppingoil = FALSE

/obj/vehicle/sealed/car/clowncar/attack_animal(mob/living/simple_animal/M)
	if((M.loc != src) || M.environment_smash & (ENVIRONMENT_SMASH_WALLS|ENVIRONMENT_SMASH_RWALLS))
		return ..()

/obj/vehicle/sealed/car/clowncar/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	var/list/drivers = return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)
	. = ..()
	if(.)
		var/isdriver = 0
		for(var/mob/living/L in drivers)
			if(M == L)
				isdriver = 1
				update_mouse_pointer(L)
		if(cannonmode && isdriver)
			ToggleCannon()

//entered changes
/obj/vehicle/sealed/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.transferItemToLoc(I, src))
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
			if(inserted_key)	//just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
		else
			to_chat(user, "<span class='notice'>[I] seems to be stuck to your hand!</span>")
		return
	return ..()

/obj/vehicle/sealed/proc/remove_key(mob/user)
	if(!inserted_key)
		to_chat(user, "<span class='notice'>There is no key in [src]!</span>")
		return
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, "<span class='notice'>You must be driving [src] to remove [src]'s key!</span>")
		return
	to_chat(user, "<span class='notice'>You remove [inserted_key] from [src].</span>")
	inserted_key.forceMove(drop_location())
	user.put_in_hands(inserted_key)
	inserted_key = null

/obj/vehicle/sealed/Destroy()
	DumpMobs()
	explosion(loc, 0, 1, 2, 3, 0)
	return ..()

/obj/vehicle/sealed/proc/DumpMobs(randomstep = TRUE)
	for(var/i in occupants)
		mob_exit(i, null, randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			mob_exit(Carbon, null, randomstep)
			Carbon.Knockdown(40)

/obj/vehicle/sealed/proc/DumpSpecificMobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if((occupants[i] & flag))
			mob_exit(i, null, randomstep)
			if(iscarbon(i))
				var/mob/living/carbon/C = i
				C.Knockdown(40)

/obj/vehicle/sealed/AllowDrop()
	return FALSE

//actions
/datum/action/vehicle/sealed/climb_out
	icon_icon = 'icons/oldschool/actions.dmi'
	button_icon_state = "car_eject"

/datum/action/vehicle/sealed/remove_key
	name = "Remove key"
	icon_icon = 'icons/oldschool/actions.dmi'
	desc = "Take your key out of the vehicle's ignition"
	button_icon_state = "car_removekey"

/datum/action/vehicle/sealed/remove_key/Trigger()
	vehicle_entered_target.remove_key(owner)

//CLOWN CAR ACTION DATUMS
/datum/action/vehicle/sealed/horn
	name = "Honk Horn"
	icon_icon = 'icons/oldschool/actions.dmi'
	desc = "Honk your classy horn."
	button_icon_state = "car_horn"
	var/hornsound = 'sound/items/carhorn.ogg'
	var/last_honk_time

/datum/action/vehicle/sealed/horn/Trigger()
	if(world.time - last_honk_time > 20)
		vehicle_entered_target.visible_message("<span class='danger'>[vehicle_entered_target] loudly honks</span>")
		to_chat(owner, "<span class='notice'>You press the vehicle's horn.</span>")
		playsound(vehicle_entered_target, hornsound, 75)
		last_honk_time = world.time

/datum/action/vehicle/sealed/horn/clowncar/Trigger()
	if(world.time - last_honk_time > 20)
		vehicle_entered_target.visible_message("<span class='danger'>[vehicle_entered_target] loudly honks</span>")
		to_chat(owner, "<span class='notice'>You press the vehicle's horn.</span>")
		last_honk_time = world.time
		if(vehicle_target.inserted_key)
			vehicle_target.inserted_key.attack_self(owner) //The key plays a sound
		else
			playsound(vehicle_entered_target, hornsound, 75)

/datum/action/vehicle/sealed/DumpKidnappedMobs
	name = "Dump kidnapped mobs"
	icon_icon = 'icons/oldschool/actions.dmi'
	desc = "Dump all objects and people in your car on the floor."
	button_icon_state = "car_dump"

/datum/action/vehicle/sealed/DumpKidnappedMobs/Trigger()
	vehicle_entered_target.visible_message("<span class='danger'>[vehicle_entered_target] starts dumping the people inside of it.</span>")
	vehicle_entered_target.DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)

/datum/action/vehicle/sealed/RollTheDice
	name = "Press a colorful button"
	icon_icon = 'icons/oldschool/actions.dmi'
	desc = "Press one of those colorful buttons on your display panel!."
	button_icon_state = "car_rtd"

/datum/action/vehicle/sealed/RollTheDice/Trigger()
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		C.RollTheDice(owner)

//cannon abilities
/obj/vehicle/sealed/car/clowncar/proc/ToggleCannon()
	cannonbusy = TRUE
	if(cannonmode)
		cannonmode = FALSE
		flick("clowncar_fromfire", src)
		icon_state = "clowncar"
		addtimer(CALLBACK(src, .proc/LeaveCannonMode), 20)
		playsound(src, 'sound/toolbox/car/clowncar_cannonmode2.ogg', 75)
		visible_message("<span class='danger'>The [src] starts going back into mobile mode.</span>")
	else
		canmove = FALSE
		flick("clowncar_tofire", src)
		icon_state = "clowncar_fire"
		visible_message("<span class='danger'>The [src] opens up and reveals a large cannon.</span>")
		addtimer(CALLBACK(src, .proc/EnterCannonMode), 20)
		playsound(src, 'sound/toolbox/car/clowncar_cannonmode1.ogg', 75)

/obj/vehicle/sealed/car/clowncar/proc/EnterCannonMode()
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	cannonmode = TRUE
	cannonbusy = FALSE
	for(var/mob/living/L in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		update_mouse_pointer(L)

/obj/vehicle/sealed/car/clowncar/proc/LeaveCannonMode()
	canmove = TRUE
	cannonbusy = FALSE
	mouse_pointer = null
	for(var/mob/living/L in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		update_mouse_pointer(L)

/obj/vehicle/sealed/car/clowncar/proc/FireCannon(mob/user, atom/A, params)
	if(cannonmode && return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED).len)
		dir = get_dir(src,A)
		var/mob/living/L = pick(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
		mob_exit(L, TRUE)
		flick("clowncar_recoil", src)
		playsound(src, pick('sound/toolbox/car/carcannon1.ogg', 'sound/toolbox/car/carcannon2.ogg', 'sound/toolbox/car/carcannon3.ogg'), 75)
		L.throw_at(A, 10, 2)

//cannon actions
/datum/action/vehicle/sealed/Cannon
	name = "Toggle siege mode"
	icon_icon = 'icons/oldschool/actions.dmi'
	desc = "Destroy them with their own fodder"
	button_icon_state = "car_cannon"

/datum/action/vehicle/sealed/Cannon/Trigger()
	if(istype(vehicle_entered_target, /obj/vehicle/sealed/car/clowncar))
		var/obj/vehicle/sealed/car/clowncar/C = vehicle_entered_target
		if(C.cannonbusy)
			to_chat(owner, "<span class='notice'>Please wait for the vehicle to finish its current action first.</span>")
		C.ToggleCannon()

//click action
/obj/vehicle/sealed/car/clowncar/click_action(atom/target,mob/user,params)
	if(cannonmode && return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED).len)
		. = TRUE
		FireCannon(user, target, params)