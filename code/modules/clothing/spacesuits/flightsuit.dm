
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
/obj/item/device/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual ion engines powerful enough to grant a humanoid flight. Contains an internal self-recharging high-current capacitor for short, powerful boosts."
	icon_state = "flightpack_off"
	item_state = "flightpack_off"
	var/icon_state_active = "flightpack_on"
	var/item_state_active = "flightpack_on"
	var/icon_state_boost = "flightpack_boost"
	var/item_state_boost = "flightpack_boost"
	actions_types = list(/datum/action/item_action/flightpack/toggle_flight, /datum/action/item_action/flightpack/engage_boosters, /datum/action/item_action/flightpack/toggle_stabilizers, /datum/action/item_action/flightpack/change_power)
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 50, acid = 100)

	w_class = 4
	slot_flags = SLOT_BACK
	resistance_flags = FIRE_PROOF

	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/wearer = null
	var/slowdown_ground = 1
	var/slowdown_air = 0
	var/flight = 0
	var/flight_mobflags = FLYING
	var/flight_passflags = PASSTABLE
	var/flight_shoeflags = NOSLIP
	var/powersetting = 2
	var/list/powersettings = list(10,20,30)

	var/boost = 0
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
	var/momentum_speed = 0	//How fast we are drifting around
	var/momentum_drift_tick = 0 //Cooldowns
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
/obj/item/device/flightpack/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/item/device/flightpack/Destroy()
	if(suit)
		suit.pack = null
	if(shoes)
		shoes.pack = null
	STOP_PROCESSING(SSfastprocess, src)
	..()

//Proc to change amount of momentum the wearer has, or dampen all momentum by a certain amount.
/obj/item/device/flightpack/proc/adjust_momentum(amountx, amounty, reduce_amount_total = 0)
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

//Called by the pair of shoes the wearer is required to wear to detect movement.
/obj/item/device/flightpack/proc/wearer_movement(dir)
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

//The wearer has momentum left. Move them and take some away, while negating the momentum that moving the wearer would gain. Or force the wearer to lose control if they are incapacitated.
/obj/item/device/flightpack/proc/momentum_drift()
	var/momentum_increment = momentum_gain
	if(boost)
		momentum_increment = boost_power
	if(suit)
		if(suit.user)
			if(suit.user.canmove)
				if(momentum_speed < 3||boost)
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
				else if(momentum_speed < 6)
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
	momentum_drift_tick = 0

//Make the wearer lose some momentum.
/obj/item/device/flightpack/proc/momentum_decay()
	if(gravity)
		adjust_momentum(0, 0, gravity_decay_amount)
	if(stabilizer)
		adjust_momentum(0, 0, stabilizer_decay_amount)
	if(pressure)
		adjust_momentum(0, 0, pressure_decay_amount)
	adjust_momentum(0, 0, momentum_passive_loss)

//Check for gravity, air pressure, and whether this is still linked to a suit. Also, resync the flightpack/flight suit every minute.
/obj/item/device/flightpack/proc/check_conditions()
	if(!resync)
		addtimer(src, "resync", 600)
		resync = 1
	if(!suit)
		toggle_flight(0)
		wearer << "<span class='wearerdanger'>Your flight pack shuts off. Somehow your flight suit was unlinked from the control mechanisms!</span>"
	if(!shoes)
		toggle_flight(0)
		wearer << "<span class='wearerdanger'>Your flight pack shuts off. Somehow your flight shoes were unlinked from the control mechanisms!</span>"
	if(!wearer)
		toggle_flight(0)
	//Add check for wearer wearing the shoes and suit here
	if(suit)
		if(suit.user)
			if(suit.user.has_gravity())
				gravity = 1
			else
				gravity = 0
			var/turf/T = get_turf(suit.user)
			var/datum/gas_mixture/gas = T.return_air()
			var/envpressure =	gas.return_pressure()
			if(envpressure >= pressure_threshold)
				pressure = 1
			else
				pressure = 0

//Resync the suit
/obj/item/device/flightpack/proc/resync()
	resync = 1
	suit.resync()

//How fast should the wearer be?
/obj/item/device/flightpack/proc/update_slowdown()
	if(flight)
		if(boost)
			suit.slowdown = -boost_speed
		else
			suit.slowdown = slowdown_air
	else
		suit.slowdown = slowdown_ground

/obj/item/device/flightpack/process()
	if(!flight)
		return
	check_conditions()
	handle_flight()
	update_slowdown()
	calculate_momentum_speed()
	momentum_drift_tick++
	if(momentum_speed >= 0)
		if(momentum_drift_tick >= momentum_speed)
			momentum_drift()
	update_icon()

/obj/item/device/flightpack/proc/handle_flight()
	wearer.float(1)

/obj/item/device/flightpack/proc/adjust_power()
	var/settings = powersettings.len
	if(powersetting < settings)
		momentum_gain = powersettings[powersetting+1]
	else
		momentum_gain = powersettings[0]
	if(suit)
		if(suit.user)
			wearer << "<span class='notice'>FLIGHTPACK: Engines set to force [momentum_gain].</span>"


/obj/item/device/flightpack/proc/losecontrol()
	wearer.visible_message("<span class='warning'>[wearer]'s flight suit careens wildly as they lose control of it!</span>")
	if(wearer)
		while(momentum_x != 0 || momentum_y != 0)
			spawn(2)
			step(wearer, pick(cardinal))
			momentum_decay()
			adjust_momentum(-10)
		suit.user.visible_message("<span class='warning'>[wearer]'s flight suit crashes into the ground and shuts off!</span>")
	if(flight)
		toggle_flight(0)

/obj/item/device/flightpack/ui_action_click(owner, action)

/obj/item/device/flightpack/proc/toggle_flight(toggle, forced = 0)
	if(toggle)
		shoes.active = 1
		icon_state = icon_state_active
		item_state = item_state_active
		suit.user.flags |= flight_mobflags
		suit.user.pass_flags |= flight_passflags
		suit.user.visible_message("<font color='blue' size='2'>[wearer]'s flight engines activate as they lift into the air!</font>")
		//I DONT HAVE SOUND EFFECTS YET playsound(
		flight = 1
	if(!toggle)
		if(momentum_x != 0 || momentum_y != 0 || forced)
			momentum_x = 0
			momentum_y = 0
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			suit.user.visible_message("<font color='blue' size='2'>[wearer] drops to the ground as their flight engines cut out!</font>")
			//NO SOUND YET	playsound(
			suit.user.flags &= ~flight_mobflags
			suit.user.pass_flags &= ~flight_passflags
			flight = 0
			shoes.active = 0
		else
			losecontrol()
	update_icon()

/obj/item/device/flightpack/dropped(mob/wearer)
	..()

/obj/item/device/flightpack/item_action_slot_check(slot)
	if(slot == SLOT_BACK)
		return 1

/obj/item/device/flightpack/equipped(mob/wearer, slot)
	..()

/obj/item/device/flightpack/proc/calculate_momentum_speed()
	if(momentum_x >= 0.75*momentum_max)
		momentum_speed = 1
	if(momentum_x >= 0.3*momentum_max)
		momentum_speed = 3
	if(momentum_x > 0)
		momentum_speed = 7
	else
		momentum_speed = -1

/obj/item/clothing/shoes/flightshoes/item_action_slot_check(slot)
	if(slot == slot_back)
		return 1

//FLIGHT SHOES FOR MOVEMENT DETECTION------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/shoes/flightshoes
	name = "flight shoes"
	desc = "A pair of specialized boots that contain stabilizers and sensors nessacary for flight gear to work" //Apparently you need these to detect mob movement.
	icon_state = "flightshoes"
	item_state = "flightshoes_mob"
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/device/flightpack/pack = null
	var/mob/living/carbon/human/wearer = null
	var/active = 0
	resistance_flags = FIRE_PROOF

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
		if(!active)
			src.flags &= ~NOSLIP

/obj/item/clothing/shoes/flightshoes/step_action()
	if(!active)
		return
	if(pack)
		if(wearer)
			pack.wearer_movement(wearer.dir)

/obj/item/clothing/shoes/flightshoes/negates_gravity()
	return flags & NOSLIP

/obj/item/clothing/shoes/flightshoes/dropped(mob/wearer)
	..()

/obj/item/clothing/shoes/flightshoes/item_action_slot_check(slot)
	if(slot == slot_shoes)
		return 1

/obj/item/clothing/shoes/flightshoes/equipped(mob/wearer, slot)
	..()


//FLIGHT SUIT------------------------------------------------------------------------------------------------------------------------------------------------------
//Flight pack and flight shoes/helmet are stored in here. This has to be locked to someone to use either. For both balance reasons and practical codewise reasons.

/obj/item/clothing/suit/space/hardsuit/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the wearer flight via two high powered miniature jet engines on a deployable back-mounted unit."
	icon_state = "flightsuit"
	item_state = "flightsuit"
	strip_delay = 30
	var/locked_strip_delay = 80
	w_class = 4
	var/obj/item/device/flightpack/pack = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/user = null
	var/deployedpack = 0
	var/deployedshoes = 0
	var/locked = 0
	resistance_flags = FIRE_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	jetpack = null
	var/flightpack
	var/flight = 0
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/gun,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	actions_types = list(/datum/action/item_action/flightsuit/toggle_helmet,/datum/action/item_action/flightsuit/toggle_boots,/datum/action/item_action/flightsuit/toggle_flightpack,/datum/action/item_action/flightsuit/lock_suit)
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 50, acid = 100)

/obj/item/clothing/suit/space/hardsuit/flightsuit/New()
	..()
	makepack()
	makeshoes()
	resync()

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
	if(user)
		pack.wearer = user
		shoes.wearer = user
	shoes.pack = pack
	pack.shoes = shoes
	pack.suit = src
	shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/ui_action_click(owner, action)
	if(action == /datum/action/item_action/flightsuit/lock_suit)
		if(!locked)
			lock_suit(owner)
		else
			unlock_suit(owner)
	if(action == /datum/action/item_action/flightsuit/toggle_flightpack)
		if(!deployedpack)
			extend_flightpack()
		else
			retract_flightpack()
	if(action == /datum/action/item_action/flightsuit/toggle_boots)
		if(!deployedshoes)
			extend_flightshoes()
		else
			retract_flightshoes()
	if(action == /datum/action/item_action/flightsuit/toggle_helmet)
		ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/flightsuit/dropped()
	if(deployedpack)
		retract_flightpack(1)
	if(deployedshoes)
		retract_flightshoes(1)
	if(locked)
		unlock_suit(user)
	if(user)
		user = null
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/lock_suit(mob/wearer)
	user = src.loc
	user = wearer
	user.visible_message("<span class='notice'>[wearer]'s flight suit locks around them, powered buckles and straps automatically adjusting to their body!</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	resync()
	strip_delay = locked_strip_delay
	locked = 1
	return 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/unlock_suit(mob/wearer)
	if(pack.flight)
		user << "<span class='warning'>You must shut off the flight-pack before unlocking your suit!</span>"
		return 0
	if(deployedpack)
		if(!retract_flightpack())
			user << "<span class='warning'>Your flightpack must be fully retracted first!</span>"
	if(deployedshoes)
		if(!retract_flightshoes())
			user << "<span class='warning'>Your flight shoes must be fully retracted first!</span>"
	user.visible_message("<span class='notice'>[wearer]'s flight suit detaches from their body, becoming nothing more then a bulky metal skeleton.</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	user = null
	resync()
	strip_delay = initial(strip_delay)
	locked = 0
	return 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightpack(forced = 0)
	if(deployedpack)
		retract_flightpack()
	if(!locked)
		user << "<span class='warning'>You must lock your flight suit first before deploying anything!</span>"
		return 0
	if(!pack)
		makepack()
	if(ishuman(user))
		if(user.back)
			user << "<span class='warning'>You're already wearing something on your back!</span>"
			return 0
		user.equip_to_slot_if_possible(pack,slot_back,0,0,1)
		pack.flags |= NODROP
		user.visible_message("<span class='notice'>A [pack.name] extends from [user]'s [src.name] and clamps to their back!</span>")
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightpack(forced = 0)
	if(ishuman(user))
		if(pack.flight && !forced)
			user << "<span class='warning'>You must disable the engines before retracting the flightpack!</span>"
			return 0
		if(pack.flight && forced)
			pack.toggle_flight(0, 1)
		pack.flags &= ~NODROP
		user.unEquip(pack, 1)
		user.update_inv_wear_suit()
		user.visible_message("<span class='notice>[user]'s [pack.name] detaches from their back and retracts into their [src]!</span>")
	else
		world << "DEBUG: USER NOT HUMAN"
	pack.loc = src
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = 0

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightshoes(forced = 0)
	if(deployedshoes)
		retract_flightshoes()
	if(!locked)
		user << "<span class='warning'>You must lock your flight suit first before deploying anything!</span>"
		return 0
	if(!shoes)
		makeshoes()
	if(ishuman(user))
		if(user.shoes)
			user << "<span class='warning'>You're already wearing something on your feet!</span>"
			return 0
		user.equip_to_slot_if_possible(shoes,slot_shoes,0,0,1)
		shoes.flags |= NODROP
		user.visible_message("<span class='notice'>[user]'s [src.name] extends a pair of [shoes.name] over their feet!</span>")
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedshoes = 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightshoes(forced = 0)
	if(pack.flight && !forced)
		user << "<span class='warning'>You can not take off your flight shoes without shutting off the engines first!</span>"
		return 0
	if(pack.flight && forced)
		pack.toggle_flight(0, 1)
	shoes.flags &= ~NODROP
	user.unEquip(shoes, 1)
	shoes.loc = src
	user.visible_message("<span class='notice'>[user]'s [shoes.name] retracts back into their [src.name]!</span>")
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedshoes = 0
	user.update_inv_wear_suit()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makepack()
	if(!pack)
		pack = new /obj/item/device/flightpack(src)
		pack.suit = src
		pack.shoes = shoes

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makeshoes()
	if(!shoes)
		shoes = new /obj/item/clothing/shoes/flightshoes(src)
		shoes.pack = pack
		shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/equipped(mob/M, slot)
	if(ishuman(M))
		user = M
	if(slot != slot_wear_suit)
		if(deployedpack)
			retract_flightpack(1)
		if(deployedshoes)
			retract_flightshoes(1)
		if(locked)
			unlock_suit(user)
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
/obj/item/clothing/suit/space/hardsuit/flightsuit/attackby(obj/item/I, mob/wearer, params)
	return


//FLIGHT HELMET----------------------------------------------------------------------------------------------------------------------------------------------------
/obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	name = "flight helmet"
	desc = "A sealed helmet attached to a flight suit for EVA usage scenerios."
	icon_state = "flighthelmet"
	item_state = "flighthelmet"
	item_color = "flight"
	resistance_flags = FIRE_PROOF
	brightness_on = 7
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 50, acid = 100)

//ITEM ACTIONS------------------------------------------------------------------------------------------------------------------------------------------------------
/datum/action/item_action/flightsuit/toggle_boots
	name = "Toggle Boots"
	button_icon_state = "flightsuit_shoes"

/datum/action/item_action/flightsuit/toggle_helmet
	name = "Toggle Helmet"
	button_icon_state = "flightsuit_helmet"

/datum/action/item_action/flightsuit/toggle_flightpack
	name = "Toggle Flightpack"
	button_icon_state = "flightsuit_pack"

/datum/action/item_action/flightsuit/lock_suit
	name = "Lock Suit"
	button_icon_state = "flightsuit_lock"

/datum/action/item_action/flightpack/toggle_flight
	name = "Toggle Flight"

/datum/action/item_action/flightpack/engage_boosters
	name = "Activate Boosters"

/datum/action/item_action/flightpack/toggle_stabilizers
	name = "Toggle Stabilizers"

/datum/action/item_action/flightpack/change_power
	name = "Flight Power Setting"
