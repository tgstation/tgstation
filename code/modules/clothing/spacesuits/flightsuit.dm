
//So how this is planned to work is it is an item that allows you to fly with some interesting movement mechanics.
//You will still move instantly like usual, but when you move in a direction you gain "momentum" towards that direction
//Momentum will have a maximum value that it will be capped to, and will go down over time
//There is toggleable "stabilizers" that will make momentum go down FAST instead of its normal slow rate
//The suit is heavy and will slow you down on the ground but is a bit faster then usual in air
//The speed at which you drift is determined by your current momentum
//Also, I should probably add in some kind of limiting mechanic but I really don't like having to refill this all the time, expecially as it will be NODROP.
//They're children of syndicate hardsuits. I hope that doesn't cause issues.
//Apparently due to code limitations you have to detect mob movement with.. shoes.


//The object that handles the flying itself - FLIGHT PACK --------------------------------------------------------------------------------------
/obj/item/weapon/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual miniature jet engines for flight in a pressurized environment, as well as a set of ion thrusters for operation in EVA. Contains an internal self-recharging high-current capacitor for short, powerful boosts."

	icon_state = ''
	item_state = ''
	var/icon_state_on = ''
	var/item_state_on = ''
	var/icon_state_boosting = ''
	var/item_state_boosting = ''
	icon = 'icons/obj/clothing/flightsuit.dmi'

	w_class = 4
	slot_flags = SLOT_BACK
	burn_state = FIRE_PROOF

	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit
	var/slowdown_ground = 1
	var/slowdown_air = 0
	var/flight = 0
	var/flight_mobflags = PASSTABLE|FLYING
	var/flight_shoeflags = NOSLIP
	var/powersetting = 2
	var/list/powersettings = list(10,20,30)

	var/boost_duration = 30	//Vroom! If you hit someone while boosting they'll likely be knocked flying. Fun.
	var/boost_speed = 2
	var/boost_power = 50
	var/boost_cooldown = 200
	var/boost_charged = 1

	var/momentum_x = 0		//Realistic physics. No more "Instant stopping while barreling down a hallway at Mach 1".
	var/momentum_y = 0
	var/momentum_max = 150
	var/momentum_impact_threshold =	80	//At this speed you'll start coliding with people resulting in momentum loss and them being knocked back, but no injuries or knockdowns
	var/momentum_impact_loss = 50
	var/momentum_crash_threshold = 130	//At this speed if you hit a dense object, you will careen out of control, while that object will be knocked flying.
	var/momentum_speed = 0
	var/momentum_passive_loss = 2
	var/momentum_gain = 20

	var/stabilizer = 0
	var/stabilizer_decay_amount = 30
	var/gravity = 1
	var/gravity_decay_amount = 4
	var/pressure = 1
	var/pressure_decay_amount = 4
	var/pressure_threshold = 30

/obj/item/weapon/flightpack/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/item/weapon/flightpack/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/obj/item/weapon/flightpack/process()
	if(!flight)
		return
	handle_flight()
	check_conditions()
	update_slowdown()
	calculate_momentum_speed()
	if(momentum_speed >= 0)
		spawn(momentum_speed)
		momentum_drift()
	update_icon()

/obj/item/weapon/flightpack/proc/handle_flight()


/obj/item/weapon/flightpack/proc/adjust_power()
	var/settings = powersettings.len()
	if(powersetting < settings)
		var/momentum_gain = powersettings[powersetting+1]
	else
		var/momentum_gain = powersettings[0]
	if(suit)
		if(suit.user)
			user << "<span class='notice'>FLIGHTPACK: Engines set to force [momentum_gain].</span>"

/obj/item/weapon/flightpack/proc/momentum_drift()
	if(suit)
		if(suit.user)
			if(suit.user.canmove)
				if(momentum_x > 0)
					step(user, EAST)
				if(momentum_x < 0)
					step(user, WEST)
				if(momentum_y > 0)
					step(user, NORTH)
				if(momentum_y < 0)
					step(user, SOUTH)
			else
				losecontrol()
			momentum_decay()

/obj/item/weapon/flightpack/proc/lose_control()
	M.visible_message("<span class='warning'>[user]'s flight suit careens wildly as they lose control of it!</span>")
	if(suit.user)
		while(momentum > 0)
			spawn(2)
			step(user, pick(cardinal))
			momentum_decay()
			adjust_momentum(-10)
		suit.user.visible_message("<span class='warning'>[user]'s flight suit crashes into the ground and shuts off!</span>")
	if(flight)
		toggle_flight()


/obj/item/weapon/flightpack/proc/toggle_flight()
	if(!flight)

		icon_state = icon_state_active
		item_state = item_state_active
		suit.user.flags |= flight_mobflags
		suit.user.visible_message(
		playsound(
		override_float = 0
		flight = 1
	if(flight)
		if(momentum < 40)
			momentum_x = 0
			momentum_y = 0
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			suit.user.visible_message(
			playsound(
			suit.user.flags &= ~flight_mobflags
			override_float = 0
			flight = 0
		else
			lose_control()
	update_icon()

/obj/item/weapon/flightpack/proc/check_conditions()
	if(suit)
		if(suit.user)
			gravity = suit.user.has_gravity()
			var/turf/T = get_turf(suit.user)
			var/datum/gas_mixture/gas = T.return_air()
			if(environment.return_pressure() >= pressure_threshold)
				pressure = 1
			else
				pressure = 0

/obj/item/weapon/flightpack/proc/update_slowdown()
	if(flight)
		if(boost)
			suit.slowdown = -boost_speed
		else
			suit.slowdown = slowdown_air
	else
		suit.slowdown = slowdown_ground


/obj/item/weapon/flightpack/proc/adjust_momentum(amount)
	momentum_x = Clamp(momentum_x + amount, -momentum_max, momentum_max)
	momentum_y = Clamp(momentum_y + amount, -momentum_max, momentum_max)
	calculate_momentum_speed()

/obj/item/weapon/flightpack/proc/calculate_momentum_speed()
	if(momentum_x >= 0.75*momentum_max)
		momentum_speed = 1
	if(momentum_x >= 0.3*momentum_max)
		momentum_speed = 3
	if(momentum_x > 0)
		momentum_speed = 7
	else
		momentum_speed = -1

/obj/item/weapon/flightpack/proc/momentum_decay()
	if(gravity)
		adjust_momentum(-gravity_decay_amount)
	if(stabilizer)
		adjust_momentum(-stabilizer_decay_amount)
	if(pressure)
		adjust_momentum(-pressure_decay_amount)
	adjust_momentum(-momentum_passive_loss)

/obj/item/weapon/flightpack/proc/user_movement(dir)
	var/momentum_increment = momentum_gain
	if(boost)
		momentum_increment = boost_power
	switch(dir)
		if(NORTH)
			momentum_y += momentum_increment
		if(SOUTH)
			momentum_y -= momentum_increment
		if(EAST)
			momentum_x += momentum_increment
		if(WEST)
			momentum_x -= momentum_increment

//FLIGHT SHOES FOR MOVEMENT DETECTION------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/shoes/flightshoes
	name = "flight shoes"
	desc = "A pair of specialized boots that contain stabilizers and sensors nessacary for flight gear to work" //Apparently you need these to detect mob movement.
	icon_state = ''
	item_state = ''
	var/item_state_actve = ''
	var/icon_state_active = ''
	var/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/suit = null
	var/active = 0

/obj/item/clothing/shoes/flightshoes/proc/switch_shoes(toggle)
	if(suit)
		active = toggle
		if(active)
			src.flags |= NOSLIP
			icon_state = icon_state_active
			item_state = item_state_active
		if(!active)
			src.flags &= ~NOSLIP
			icon_state = initial(icon_state)
			item_state = initial(item_state)

/obj/item/clothing/shoes/flightshoes/step_action()
	if(!active)
		return
	if(suit)
		if(suit.user)
			suit.detect_step(user.dir)

/obj/item/clothing/shoes/flightshoes/negates_gravity()
	return flags & NOSLIP

//FLIGHT SUIT------------------------------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the user flight via two high powered miniature jet engines on a deployable back-mounted unit. It can also be sealed for use in space, although the user must install a gas tank for propulsion. It is in EVA mode."
	alt_desc = "An advanced suit that allows the user flight via two high powered miniature jet engines on the sides. It can also be sealed for use in space, although the user must install a gas tank for propulsion. It is unsealed."
	icon_state = ''
	item_state = ''
	var/icon_state_on = ''
	var/item_state_on = ''
	item_color = "flight"
	strip_delay = 30
	var/locked_strip_delay = 80
	w_class = 4
	var/obj/item/weapon/flightpack/pack = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/user = null
	var/deployed = 0
	var/locked = 0
	burn_state = FIRE_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/flightsuit
	jetpack = null
	var/flightpack
	var/flight = 0
	allowed = list(/obj/item/weapon/tank/internals)


/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/New()
	pack = new /obj/item/weapon/flightpack(src)
	pack.suit = src
	..()

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/Destroy()
	flightpack.unEquip()
	qdel(pack)
	..()

/obj/item/weapon/flightpack/proc/toggle_lock(mob/user)
	if(!locked)
		user.visible_message("<span class='notice'>[user]'s flight suit locks around them, powered buckles and straps automatically adjusting to their body!</span>")
		playsound(
		strip_delay = locked_strip_delay
		locked = 1
		return 1
	if(locked)
		user.visible_message("<span class='notice'>[user]'s flight suit detaches from their body, becoming nothing more then a bulky metal skeleton.</span>")
		playsound(
		strip_delay = initial(strip_delay)
		locked = 0
		return 1

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/toggle_deploy(mob/user)
	if(!deployed)
		flightpack.on_pickup()
		flightpack.
		deployed = 1
	else
		flightpack.Dropped()
		flightpack.loc = src
		deployed = 0

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/attackby(obj/item/I, mob/user, params)
	return

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/proc/detect_step(dir)
	if(pack)
		pack.user_movement(dir)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/flightsuit
	name = "flight helmet"
	desc = "A sealable helmet attached to a flight suit for EVA usage scenerios. It is in EVA mode."
	alt_desc = "A sealable helmet attached to a flight suit for EVA usage scenerios. It is unsealed."
	icon_state = ""
	item_state = ""
	item_color = "flight"
	burn_state = FIRE_PROOF
	brightness_on = 7
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75)
	obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/linkedsuit = null
