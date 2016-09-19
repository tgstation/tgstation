
//So how this is planned to work is it is an item that allows you to fly with some interesting movement mechanics.
//You will still move instantly like usual, but when you move in a direction you gain "momentum" towards that direction
//Momentum will have a maximum value that it will be capped to, and will go down over time
//There is toggleable "stabilizers" that will make momentum go down FAST instead of its normal slow rate
//The suit is heavy and will slow you down on the ground but is a bit faster then usual in air
//The speed at which you drift is determined by your current momentum
//Also, I should probably add in some kind of limiting mechanic but I really don't like having to refill this all the time, expecially as it will be NODROP.
//Apparently due to code limitations you have to detect mob movement with.. shoes.

//Note to Admins: DO NOT SPAWN THE FLIGHT PACK BY ITSELF. IT RELIES ON THE SHOES AND SUIT BECAUSE MOVEMENT DETECTION AND ETC ETC.
//The object that handles the flying itself - FLIGHT PACK --------------------------------------------------------------------------------------
/obj/item/weapon/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual miniature jet engines for flight in a pressurized environment, as well as a set of ion thrusters for operation in EVA. Contains an internal self-recharging high-current capacitor for short, powerful boosts."

	icon_state = "flightpack"
	item_state = "flightpack_mob"
	var/icon_state_on = "flightpack_on"
	var/item_state_on = "flightpack_on_mob"
	var/icon_state_boost = "flightpack_boost"
	var/item_state_boost = "flightpack_boost_mob"
	icon = 'icons/obj/clothing/flightsuit.dmi'

	w_class = 4
	slot_flags = SLOT_BACK
	burn_state = FIRE_PROOF
	acid_state = ACID_PROOF

	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/wearer = null
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

	var/resync = 0	//Used to resync the flight-suit every 30 seconds or so.

//Start/Stop processing the item to use momentum and flight mechanics.
/obj/item/weapon/flightpack/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/item/weapon/flightpack/Destroy()
	if(suit)
		suit.pack = null
	if(shoes)
		shoes.pack = null
	STOP_PROCESSING(SSfastprocess, src)
	..()

//Proc to change amount of momentum the user has, or dampen all momentum by a certain amount.
/obj/item/weapon/flightpack/proc/adjust_momentum(amountx, amounty, reduce_amount_total = 0)
	if(reduce_amount_total < 0||reduce_amount_total > 0)
		if(momentum_x > 0)
		momentum_x = Clamp(momentum_x - reduce_amount_total, 0, momentum_max)
		else if(momentum_x < 0)
		momentum_x = Clamp(momentum_x + reduce_amount_total, -momentum_max, 0)
		if(momentum_y > 0)
		momentum_y = Clamp(momentum_y - reduce_amount_total, 0, momentum_max)
		else if(momentum_y < 0)
		momentum_y = Clamp(momentum_y + reduce_amount_total, -momentum_max, 0)
	momentum_x = Clamp(momentum_x + amountx, -momentum_max, momentum_max)
	momentum_y = Clamp(momentum_y + amounty, -momentum_max, momentum_max)
	calculate_momentum_speed()

//Called by the pair of shoes the user is required to wear to detect movement.
/obj/item/weapon/flightpack/proc/user_movement(dir)
	var/momentum_increment = momentum_gain
	if(boost)
		momentum_increment = boost_power
	switch(dir)
		if(NORTH)
			adjust_momentum(0, momentum_increment)
		if(SOUTH)
			adjust_momentum(0, -momentum_increment)
		if(EAST)
			adjust_momentum(momentum_increment, 0)
		if(WEST)
			adjust_momentum(-momentum_increment, 0)

//The user has momentum left. Move them and take some away, while negating the momentum that moving the user would gain. Or force the user to lose control if they are incapacitated.
/obj/item/weapon/flightpack/proc/momentum_drift()
	var/momentum_increment = momentum_gain
	if(boost)
		momentum_increment = boost_power
	if(suit)
		if(suit.user)
			if(suit.user.canmove)
				if(momentum_x > 0)
					step(suit.user, EAST)
					adjust_momentum(-momentum_increment, 0)
				if(momentum_x < 0)
					step(suit.user, WEST)
					adjust_momentum(momentum_increment, 0)
				if(momentum_y > 0)
					step(suit.user, NORTH)
					adjust_momentum(0, -momentum_increment)
				if(momentum_y < 0)
					step(suit.user, SOUTH)
					adjust_momentum(0, momentum_increment)
			else
				losecontrol()
			momentum_decay()

//Make the user lose some momentum.
/obj/item/weapon/flightpack/proc/momentum_decay()
	if(gravity)
		adjust_momentum(0, 0, gravity_decay_amount)
	if(stabilizer)
		adjust_momentum(0, 0, stabilizer_decay_amount)
	if(pressure)
		adjust_momentum(0, 0, pressure_decay_amount)
	adjust_momentum(0, 0, momentum_passive_loss)

//Check for gravity, air pressure, and whether this is still linked to a suit. Also, resync the flightpack/flight suit every minute.
/obj/item/weapon/flightpack/proc/check_conditions()
	if(!resync)
		addtimer(src, "resync", 600)
		resync = 1
	if(!suit)
		toggle_flight(0)
		user << "<span class='userdanger'>Your flight pack shuts off. Somehow your flight suit was unlinked from the control mechanisms!</span>"
	if(!shoes)
		toggle_flight(0)
		user << "<span class='userdanger'>Your flight pack shuts off. Somehow your flight shoes were unlinked from the control mechanisms!</span>"
	if(!user)
		toggle_flight(0)
	//Add check for user wearing the shoes and suit here
	if(suit)
		if(suit.user)
			if(suit.user.has_gravity())
				gravity = 1
			else
				gravity = 0
			var/turf/T = get_turf(suit.user)
			var/datum/gas_mixture/gas = T.return_air()
			if(environment.return_pressure() >= pressure_threshold)
				pressure = 1
			else
				pressure = 0

//Resync the suit
/obj/item/weapon/flightpack/proc/resync()
	resync = 1
	suit.resync()

//How fast should the user be?
/obj/item/weapon/flightpack/proc/update_slowdown()
	if(flight)
		if(boost)
			suit.slowdown = -boost_speed
		else
			suit.slowdown = slowdown_air
	else
		suit.slowdown = slowdown_ground

/obj/item/weapon/flightpack/process()
	if(!flight)
		return
	check_conditions()
	handle_flight()
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
		toggle_flight(0)

/obj/item/weapon/flightpack/ui_action_click(owner, action)

/obj/item/weapon/flightpack/proc/toggle_flight(toggle, forced = 0)
	if(toggle)

		icon_state = icon_state_active
		item_state = item_state_active
		suit.wearer.flags |= flight_mobflags
		suit.wearer.visible_message("<font color='blue' size='2'>[wearer]'s flight engines activate as they lift into the air!</font>")
		playsound(
		override_float = 1
		flight = 1
	if(!toggle)
		if(momentum < 40 || forced)
			momentum_x = 0
			momentum_y = 0
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			suit.wearer.visible_message("<font color='blue' size='2'>[wearer] drops to the ground as their flight engines cut out!</font>")
			playsound(
			suit.wearer.flags &= ~flight_mobflags
			override_float = 0
			flight = 0
		else
			lose_control()
	update_icon()

/obj/item/weapon/flightpack/dropped(mob/user)
	..()
	if(suit)
		suit.deploy_flightpack(0, 1)

/obj/item/weapon/flightpack/item_action_slot_check(slot)
	if(slot == slot_back)
		return 1

/obj/item/weapon/flightpack/equipped(mob/user, slot)
	..()
	if(slot != slot_back)
		if(suit)
			suit.deploy_flightpack(0, 1)
		else
			qdel(src)






/obj/item/weapon/flightpack/proc/calculate_momentum_speed()
	if(momentum_x >= 0.75*momentum_max)
		momentum_speed = 1
	if(momentum_x >= 0.3*momentum_max)
		momentum_speed = 3
	if(momentum_x > 0)
		momentum_speed = 7
	else
		momentum_speed = -1


//FLIGHT SHOES FOR MOVEMENT DETECTION------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/shoes/flightshoes
	name = "flight shoes"
	desc = "A pair of specialized boots that contain stabilizers and sensors nessacary for flight gear to work" //Apparently you need these to detect mob movement.
	icon_state = "flightshoes"
	item_state = "flightshoes_mob"
	icon = 'icons/obj/clothing/flightsuit.dmi'
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/weapon/flightpack/pack = null
	var/mob/living/carbon/human/wearer = null
	var/active = 0
	burn_state = FIRE_PROOF
	acid_state = ACID_PROOF

/obj/item/clothing/shoes/flightshoes/Destroy()
	if(suit)
		suit.shoes = null
	if(pack)
		pack.shoes = null

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
	if(pack)
		if(wearer)
			pack.detect_step(wearer.dir)

/obj/item/clothing/shoes/flightshoes/negates_gravity()
	return flags & NOSLIP

/obj/item/clothing/shoes/flightshoes/dropped(mob/user)
	..()
	if(suit)
		suit.deploy_flightshoes(0, 1)

/obj/item/clothing/shoes/flightshoes/item_action_slot_check(slot)
	if(slot == slot_feet)
		return 1

/obj/item/clothing/shoes/flightshoes/equipped(mob/user, slot)
	..()
	if(slot != slot_feet)
		if(suit)
			suit.deploy_flightshoes(0, 1)
		else
			qdel(src)

//FLIGHT SUIT------------------------------------------------------------------------------------------------------------------------------------------------------
//Flight pack and flight shoes/helmet are stored in here. This has to be locked to someone to use either. For both balance reasons and practical codewise reasons.

/obj/item/clothing/suit/space/hardsuit/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the user flight via two high powered miniature jet engines on a deployable back-mounted unit."
	icon_state = "flightsuit"
	item_state = "flightsuit_mob"
	icon = 'icons/obj/clothing/flightsuit'
	strip_delay = 30
	var/locked_strip_delay = 80
	w_class = 4
	var/obj/item/weapon/flightpack/pack = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/wearer = null
	var/deployedpack = 0
	var/deployedshoes = 0
	var/locked = 0
	burn_state = FIRE_PROOF
	acid_state = ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	jetpack = null
	var/flightpack
	var/flight = 0
	allowed = list(/obj/item/weapon/tank/internals)
	actions_types = list(/datum/action/item_action/toggle_helmet,/datum/action/item_action/toggle_boots,/datum/action/item_action/toggle_flightpack,/datum/action/item_action/lock_suit) //TODO: Toggle boots, toggle jetpack, lock suit :^)

/obj/item/clothing/suit/space/hardsuit/flightsuit/New()
	shoes = new /obj/item/clothing/shoes/flightshoes(src)
	shoes.suit = src
	pack = new /obj/item/weapon/flightpack(src)
	pack.suit = src
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/Destroy()
	dropped()
	if(pack)
		pack.shoes = null
		pack.suit = null
		qdel(pack)
	if(shoes)
		shoes.pack = null
		shoes.suit = null
		qdel(shoes)
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/resync()
	pack.wearer = wearer
	shoes.wearer = wearer
	shoes.pack = pack
	pack.shoes = shoes
	suit.suit = src
	shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/ui_action_click(owner, action)
	if(ishuman(owner))
		wearer = owner
	if(istype(action, /datum/action/item_action/flightsuit/lock_suit))
		toggle_lock(owner)
	if(istype(action, /datum/action/item_action/flightsuit/toggle_flightpack))
		deploy_flightpack()
	if(istype(action, /datum/action/item_action/flightsuit/toggle_boots))
		deploy_flightshoes()

/obj/item/clothing/suit/space/hardsuit/flightsuit/dropped()
	pack.toggle_flight(0, 1)
	deploy_flightpack(0, 1)

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/toggle_lock(mob/user, locking = -1)
	if(locking = -1)
		locking = !locked
	if(locking)
		user.visible_message("<span class='notice'>[user]'s flight suit locks around them, powered buckles and straps automatically adjusting to their body!</span>")
		playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
		wearer = user
		resync()
		strip_delay = locked_strip_delay
		locked = 1
		return 1
	if(!locking)
		if(pack.flight)
			user << "<span class='warning'>You must shut off the flight-pack before unlocking your suit!</span>"
			return 0
		user.visible_message("<span class='notice'>[user]'s flight suit detaches from their body, becoming nothing more then a bulky metal skeleton.</span>")
		playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
		wearer = null
		resync()
		strip_delay = initial(strip_delay)
		locked = 0
		return 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/deploy_flightpack(deploying = -1, forced = 0)
	if(deploying = -1)
		deploying = !deployedpack
	if(deploying)
		pack.on_pickup()
		pack.
		pack.flags |= NODROP
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		deployedpack = 1
	if(!deploying)
		if(pack.flight && !forced)
			wearer << "<span class='warning'>You must disable the engines before retracting the flightpack!</span>"
			return 0
		if(pack.flight && forced)
			pack.toggle_flight(0, 1)
		pack.flags &= ~NODROP
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		pack.dropped()
		pack.loc = src
		deployedpack = 0

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/deploy_flightshoes(deploying = -1, forced = 0)
	if(deploying = -1)
		deploying = !deployedshoes
	if(deploying)
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		shoes.flags |= NODROP
		deployedshoes = 1
	if(!deploying)
		if(pack.flight && !forced
			wearer << "<span class='warning'>You can not take off your flight shoes without shutting off the engines first!</span>"
			return 0
		if(pack.flight && forced)
			pack.toggle_flight(0, 1)

		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		shoes.flags &= ~NODROP
		deployedshoes = 0

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makepack()
	if(!pack)
		pack = new /obj/item/weapon/flightpack(src)
		pack.suit = src
		pack.shoes = shoes

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makeshoes()
	if(!shoes)
		shoes = new /obj/item/clothing/shoes/flightshoes(src)
		shoes.pack = pack
		shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		if(user = wearer)
			wearer.Equip(src, slot_wear_suit)
			return 0
		deploy_flightpack(0, 1)
		deploy_flightshoes(0, 1)
	..()

/*
/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	if(!helmet)
		return
	suittoggled = 0
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		H.unEquip(helmet, 1)
		H.update_inv_wear_suit()
		H << "<span class='notice'>The helmet on the hardsuit disengages.</span>"
	helmet.loc = src

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				H << "<span class='warning'>You must be wearing [src] to engage the helmet!</span>"
				return
			if(H.head)
				H << "<span class='warning'>You're already wearing something on your head!</span>"
				return
			else if(H.equip_to_slot_if_possible(helmet,slot_head,0,0,1))
				H << "<span class='notice'>You engage the helmet on the hardsuit.</span>"
				H.update_inv_wear_suit()
	else
		RemoveHelmet()
*/
/obj/item/clothing/suit/space/hardsuit/flightsuit/attackby(obj/item/I, mob/user, params)
	return


//FLIGHT HELMET----------------------------------------------------------------------------------------------------------------------------------------------------
/obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	name = "flight helmet"
	desc = "A sealed helmet attached to a flight suit for EVA usage scenerios."
	icon_state = ""
	item_state = ""
	icon = 'icons/obj/clothing/flightsuit.dmi
	burn_state = FIRE_PROOF
	acid_state = ACID_PROOF
	brightness_on = 7
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75)
	obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/linkedsuit = null

//ITEM ACTIONS------------------------------------------------------------------------------------------------------------------------------------------------------
/datum/action/item_action/flightsuit/toggle_boots
	name = "Toggle Boots"

/datum/action/item_action/flightsuit/toggle_flightpack
	name = "Toggle Flightpack"

/datum/action/item_action/flightsuit/lock_suit
	name = "Lock Suit"

/datum/action/item_action/flightpack/toggle_flight
	name = "Toggle Flight"

/datum/action/item_action/flightpack/engage_boosters
	name = "Activate Boosters"

/datum/action/item_action/flightpack/toggle_stabilizers
	name = "Toggle Stabilizers"

/datum/action/item_action/flightpack/change_power
	name = "Flight Power Setting"

