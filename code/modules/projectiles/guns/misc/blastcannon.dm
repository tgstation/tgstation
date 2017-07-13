/obj/item/weapon/gun/blastcannon
	name = "pipe gun"
	desc = "A pipe welded onto a gun stock, with a mechanical trigger. The pipe has an opening near the top, and there seems to be a spring loaded wheel in the hole."
	icon_state = "empty_blastcannon"
	var/icon_state_loaded = "loaded_blastcannon"
	item_state = "blastcannon_empty"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	fire_sound = 'sound/weapons/blastcannon.ogg'
	needs_permit = FALSE
	clumsy_check = FALSE
	randomspread = FALSE

	var/obj/item/device/transfer_valve/bomb
	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2

/obj/item/weapon/gun/blastcannon/New()
	if(!pin)
		pin = new
	. = ..()

/obj/item/weapon/gun/blastcannon/Destroy()
	if(bomb)
		qdel(bomb)
		bomb = null
	air1 = null
	air2 = null
	. = ..()

/obj/item/weapon/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message("<span class='warning'>[user] detaches the [bomb] from the [src]</span>")
		bomb = null
	update_icon()
	. = ..(user)

/obj/item/weapon/gun/blastcannon/update_icon()
	if(bomb)
		icon_state = icon_state_loaded
		name = "blast cannon"
		desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave."
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)
	. = ..()

/obj/item/weapon/gun/blastcannon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/device/transfer_valve))
		var/obj/item/device/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two)
			to_chat(user, "<span class='warning'>What good would an incomplete bomb do?</span>")
			return FALSE
		if(!user.drop_item(O))
			to_chat(user, "<span class='warning'>The [O] seems to be stuck to your hand!</span>")
			return FALSE
		user.visible_message("<span class='warning'>[user] attaches the [O] to the [src]!</span>")
		bomb = O
		O.loc = src
		update_icon()
		return TRUE
	. = ..()

/obj/item/weapon/gun/blastcannon/proc/calculate_bomb()
	if(!istype(bomb)||!istype(bomb.tank_one)||!istype(bomb.tank_two))
		return 0
	air1 = bomb.tank_one.air_contents
	air2 = bomb.tank_two.air_contents
	var/datum/gas_mixture/temp
	temp.volume = air1.volume + air2.volume
	temp.merge(air1)
	temp.merge(air2)
	for(var/i in 1 to 6)
		temp.react()
	var/pressure = temp.return_pressure()
	qdel(temp)
	if(pressure < TANK_FRAGMENT_PRESSURE)
		return 0
	return (pressure/TANK_FRAGMENT_SCALE)

/obj/item/weapon/gun/blastcannon/afterattack(atom/target, mob/user, flag, params)
	if((!bomb) || (target == user) || (target.loc == user) || (!target) || (target.loc == user.loc) || (target.loc in range(user, 2)) || (target in range(user, 2)))
		return ..()
	var/power = calculate_bomb()
	qdel(bomb)
	update_icon()
	var/heavy = power * 0.2
	var/medium = power * 0.5
	var/light = power
	user.visible_message("<span class='danger'>[user] opens \the [bomb] on \his [src.name] and fires a blast wave at \the [target]!</span>","<span class='danger'>You open \the [bomb] on your [src.name] and fire a blast wave at \the [target]!</span>")
	playsound(user, "explosion", 100, 1)
	var/turf/starting = get_turf(user)
	var/area/A = get_area(user)
	var/log_str = "Blast wave fired at [ADMIN_COORDJMP(starting)] ([A.name]) by [user.name]([user.ckey]) with power [heavy]/[medium]/[light]."
	message_admins(log_str)
	log_game(log_str)

/obj/item/projectile/blastwave
	name = "blast wave"
	icon_state = "blastwave"
	damage = 0
	nodamage = FALSE
	forcedodge = TRUE
	var/heavyr = 0
	var/mediumr = 0
	var/lightr = 0
	range = 150

/obj/item/projectile/blastwave/Range()
	..()
	if(heavyr)
		loc.ex_act(EXPLODE_DEVASTATE)
	else if(mediumr)
		loc.ex_act(EXPLODE_HEAVY)
	else if(lightr)
		loc.ex_act(EXPLODE_LIGHT)
	else
		qdel(src)
	heavyr--
	mediumr--
	lightr--

/obj/item/projectile/blastwave/ex_act()
	return
