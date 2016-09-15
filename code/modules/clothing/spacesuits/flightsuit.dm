
//So how this is planned to work is it is an item that allows you to fly with some interesting movement mechanics.
//You will still move instantly like usual, but when you move in a direction you gain "momentum" towards that direction
//Momentum will have a maximum value that it will be capped to, and will go down over time
//There is toggleable "stabilizers" that will make momentum go down FAST instead of its normal slow rate
//The suit is heavy and will slow you down on the ground but is a bit faster then usual in air
//The speed at which you drift is determined by your current momentum
//Also, I should probably add in some kind of limiting mechanic but I really don't like having to refill this all the time, expecially as it will be NODROP.
//They're children of syndicate hardsuits. I hope that doesn't cause issues.

/obj/item/weapon/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual miniature jet engines for flight in a pressurized environment, as well as a set of ion thrusters for operation in EVA. Contains an internal self-recharging high-current capacitor for short, powerful boosts."
	icon_state = ''
	item_state = ''
	var/icon_state_on = ''
	var/item_state_on = ''
	icon = 'icons/obj/clothing/flightsuit.dmi'
	w_class = 4
	slot_flags = SLOT_BACK
	burn_state = FIRE_PROOF
	var/deployed = 0
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit
	var/requires_suit = 0
	var/slowdown_ground = 1
	var/slowdown_air = -0.5
	var/boost_duration = 30	//Vroom vroom
	var/boost_speed = 3
	var/boost_cooldown = 200
	var/boost_charged = 1
	var/momentum_x = 0		//Realistic physics. No more "Instant stopping while barreling down a hallway at 80MPH.
	var/momentum_y = 0
	var/momentum_x_max = 100
	var/momentum_y_max = 100
	var/momentum_knockdown_threshold = 50
	var/momentum_crash_threshold = 75
	var/drift_speed = 0
	var/stabilizer = 0
	var/flight = 0
	var/flightflags
	var/mob/living/carbon/human/wearer
	var/gravity = 1
	var/gravity_decay_amount = 5
	var/stabilizer_decay_amount = 15
	var/pressure_decay_amount = 10
	var/pressure = 1


/obj/item/weapon/flightpack/New()
	slowdown = slowdown_ground
	..()

/obj/item/weapon/flightpack/Destroy()
	..()

/obj/item/weapon/flightpack/process()
	if(wearer)
		gravity = wearer.has_gravity()


/obj/item/weapon/flightpack/proc/adjust_momentum(amount)
	momentum_x = Clamp(momentum_x + amount, 0, momentum_max)
	momentum_y = Clamp(momentum_y + amount, 0, momentum_max)

/obj/item/weapon/flightpack/proc/momentum_decay()
	if(gravity)
		adjust_momentum(-gravity_decay_amount)
	if(stabilizer)
		adjust_momentum(-stabilizer_decay_amount)
	if(pressure)
		adjust_momentum(-pressure_decay_amount)


/*
/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the user flight via two high powered miniature jet engines on the sides. It can also be sealed for use in space, although the user must install a gas tank for propulsion. It is in EVA mode."
	alt_desc = "An advanced suit that allows the user flight via two high powered miniature jet engines on the sides. It can also be sealed for use in space, although the user must install a gas tank for propulsion. It is unsealed."
	icon_state = ''
	item_state = ''
	var/icon_state_on = ''
	var/item_state_on = ''
	item_color = "flight"
	strip_delay = 30
	var/locked_strip_delay = 60
	w_class = 4
	var/obj/item/weapon/flightpack/pack
	var/deployed = 0
	var/locked = 0
	burn_state = FIRE_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/flightsuit
	jetpack = null
	var/flightpack
	var/flight = 0
	allowed = list(/obj/item/weapon/tank/internals)


/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/New()
	flightpack = new /obj/item/weapon/flightpack(src)
	flightpack.requires_suit = 1
	flightpack.suit = src
	slowdown = jetpack.slowdown_ground
	..()

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/Destroy()
	flightpack.unEquip()
	qdel(pack)
	..()

/obj/item/weapon/flightpack/proc/toggle_lock(mob/user)
	if(!locked)
		user.visible_message("<span class='notice'>[user]'s flight suit locks around them, powered buckles and straps automatically adjusting to their body!</span>")
		playsound(
		flags & NODROP
		locked = 1
		return 1
	if(locked)
		user.visible_message("<span class='notice'>[user]'s flight suit
		playsound(
		flags ^= NODROP
		locked = 0
		return 1

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/attack_self(mob/user)
	if(!deployed)
		slowdown = initial(slowdown)
		flightpack.
		flightpack.
		deployed = 1
	else
		slowdown = pack.slowdown_ground
		flightpack.unEquip()
		flightpack.loc = src
		deployed = 0

/obj/item/clothing/suit/space/hardsuit/syndi/flightsuit/attackby(obj/item/I, mob/user, params)
	return

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
*/