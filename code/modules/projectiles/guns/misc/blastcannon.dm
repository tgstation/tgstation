/obj/item/gun/blastcannon
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

/obj/item/gun/blastcannon/New()
	if(!pin)
		pin = new
	return ..()

/obj/item/gun/blastcannon/Destroy()
	if(bomb)
		qdel(bomb)
		bomb = null
	return ..()

/obj/item/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message("<span class='warning'>[user] detaches [bomb] from [src].</span>")
		bomb = null
	update_icon()
	return ..()

/obj/item/gun/blastcannon/update_icon()
	if(bomb)
		icon_state = icon_state_loaded
		name = "blast cannon"
		desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave."
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)

/obj/item/gun/blastcannon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/device/transfer_valve))
		var/obj/item/device/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two)
			to_chat(user, "<span class='warning'>What good would an incomplete bomb do?</span>")
			return FALSE
		if(!user.transferItemToLoc(O, src))
			to_chat(user, "<span class='warning'>[O] seems to be stuck to your hand!</span>")
			return FALSE
		user.visible_message("<span class='warning'>[user] attaches [O] to [src]!</span>")
		bomb = O
		update_icon()
		return TRUE
	return ..()

/obj/item/gun/blastcannon/proc/calculate_bomb()
	if(!istype(bomb)||!istype(bomb.tank_one)||!istype(bomb.tank_two))
		return 0
	var/datum/gas_mixture/temp = new(60)	//directional buff.
	temp.merge(bomb.tank_one.air_contents.remove_ratio(1))
	temp.merge(bomb.tank_two.air_contents.remove_ratio(2))
	for(var/i in 1 to 6)
		temp.react()
	var/pressure = temp.return_pressure()
	qdel(temp)
	if(pressure < TANK_FRAGMENT_PRESSURE)
		return 0
	return (pressure/TANK_FRAGMENT_SCALE)

/obj/item/gun/blastcannon/afterattack(atom/target, mob/user, flag, params)
	if((!bomb) || (!target) || (get_dist(get_turf(target), get_turf(user)) <= 2))
		return ..()
	var/power = calculate_bomb()
	qdel(bomb)
	update_icon()
	var/heavy = power * 0.2
	var/medium = power * 0.5
	var/light = power
	user.visible_message("<span class='danger'>[user] opens \the [bomb] on \his [name] and fires a blast wave at \the [target]!</span>","<span class='danger'>You open \the [bomb] on your [name] and fire a blast wave at \the [target]!</span>")
	playsound(user, "explosion", 100, 1)
	var/turf/starting = get_turf(user)
	var/turf/targturf = get_turf(target)
	var/area/A = get_area(user)
	var/log_str = "Blast wave fired from [ADMIN_COORDJMP(starting)] ([A.name]) at [ADMIN_COORDJMP(targturf)] ([target.name]) by [user.name]([user.ckey]) with power [heavy]/[medium]/[light]."
	message_admins(log_str)
	log_game(log_str)
	var/obj/item/projectile/blastwave/BW = new(loc, heavy, medium, light)
	BW.preparePixelProjectile(target, get_turf(target), user, params, 0)
	BW.fire()

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

/obj/item/projectile/blastwave/Initialize(mapload, _h, _m, _l)
	heavyr = _h
	mediumr = _m
	lightr = _l
	return ..()

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
