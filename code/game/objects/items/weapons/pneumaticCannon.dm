
#define PCANNON_FIREALL 1
#define PCANNON_FILO 2
#define PCANNON_FIFO 3
/obj/item/weapon/pneumatic_cannon
	name = "pneumatic cannon"
	desc = "A gas-powered cannon that can fire any object loaded into it."
	w_class = WEIGHT_CLASS_BULKY
	force = 8 //Very heavy
	attack_verb = list("bludgeoned", "smashed", "beaten")
	icon = 'icons/obj/pneumaticCannon.dmi'
	icon_state = "pneumaticCannon"
	item_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 60, acid = 50)
	var/maxWeightClass = 20 //The max weight of items that can fit into the cannon
	var/loadedWeightClass = 0 //The weight of items currently in the cannon
	var/obj/item/weapon/tank/internals/tank = null //The gas tank that is drawn from to fire things
	var/gasPerThrow = 3 //How much gas is drawn from a tank's pressure to fire
	var/list/loadedItems = list() //The items loaded into the cannon that will be fired out
	var/pressureSetting = 1 //How powerful the cannon is - higher pressure = more gas but more powerful throws
	var/checktank = TRUE
	var/range_multiplier = 1
	var/throw_amount = 20	//How many items to throw per fire
	var/fire_mode = PCANNON_FIREALL
	var/automatic = FALSE
	var/clumsyCheck = TRUE
	trigger_guard = TRIGGER_GUARD_NORMAL

/obj/item/weapon/pneumatic_cannon/CanItemAutoclick()
	return automatic

/obj/item/weapon/pneumatic_cannon/examine(mob/user)
	..()
	var/list/out = list()
	if(!in_range(user, src))
		out += "<span class='notice'>You'll need to get closer to see any more.</span>"
		return
	for(var/obj/item/I in loadedItems)
		out += "<span class='info'>[bicon(I)] It has \the [I] loaded.</span>"
		CHECK_TICK
	if(tank)
		out += "<span class='notice'>[bicon(tank)] It has \the [tank] mounted onto it.</span>"
	to_chat(user, out.Join("<br>"))

/obj/item/weapon/pneumatic_cannon/attackby(obj/item/weapon/W, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(istype(W, /obj/item/weapon/tank/internals))
		if(!tank)
			var/obj/item/weapon/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, "<span class='warning'>\The [IT] is too small for \the [src].</span>")
				return
			updateTank(W, 0, user)
	else if(W.type == type)
		to_chat(user, "<span class='warning'>You're fairly certain that putting a pneumatic cannon inside another pneumatic cannon would cause a spacetime disruption.</span>")
	else if(istype(W, /obj/item/weapon/wrench))
		switch(pressureSetting)
			if(1)
				pressureSetting = 2
			if(2)
				pressureSetting = 3
			if(3)
				pressureSetting = 1
		to_chat(user, "<span class='notice'>You tweak \the [src]'s pressure output to [pressureSetting].</span>")
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(tank)
			updateTank(tank, 1, user)
	else if(loadedWeightClass >= maxWeightClass)
		to_chat(user, "<span class='warning'>\The [src] can't hold any more items!</span>")
	else if(isitem(W))
		var/obj/item/IW = W
		load_item(IW, user)

/obj/item/weapon/pneumatic_cannon/proc/can_load_item(obj/item/I, mob/user)
	if((loadedWeightClass + I.w_class) > maxWeightClass)	//Only make messages if there's a user
		if(user)
			to_chat(user, "<span class='warning'>\The [I] won't fit into \the [src]!</span>")
		return FALSE
	if(I.w_class > w_class)
		if(user)
			to_chat(user, "<span class='warning'>\The [I] is too large to fit into \the [src]!</span>")
		return FALSE
	return TRUE

/obj/item/weapon/pneumatic_cannon/proc/load_item(obj/item/I, mob/user)
	if(!can_load_item(I, user))
		return FALSE
	if(user)		//Only use transfer proc if there's a user, otherwise just set loc.
		if(!user.transferItemToLoc(I, src))
			return FALSE
		to_chat(user, "<span class='notice'>You load \the [I] into \the [src].</span>")
	else
		I.forceMove(src)
	loadedItems += I
	loadedWeightClass += I.w_class
	return TRUE

/obj/item/weapon/pneumatic_cannon/afterattack(atom/target, mob/living/carbon/human/user, flag, params)
	if(flag && user.a_intent == INTENT_HARM) //melee attack
		return
	if(!istype(user))
		return
	Fire(user, target)

/obj/item/weapon/pneumatic_cannon/proc/Fire(mob/living/carbon/human/user, var/atom/target)
	if(!istype(user) && !target)
		return
	var/discharge = 0
	if(!can_trigger_gun(user))
		return
	if(!loadedItems || !loadedWeightClass)
		to_chat(user, "<span class='warning'>\The [src] has nothing loaded.</span>")
		return
	if(!tank && checktank)
		to_chat(user, "<span class='warning'>\The [src] can't fire without a source of gas.</span>")
		return
	if(tank && !tank.air_contents.remove(gasPerThrow * pressureSetting))
		to_chat(user, "<span class='warning'>\The [src] lets out a weak hiss and doesn't react!</span>")
		return
	if(user.disabilities & CLUMSY && prob(75) && clumsyCheck)
		user.visible_message("<span class='warning'>[user] loses their grip on [src], causing it to go off!</span>", "<span class='userdanger'>[src] slips out of your hands and goes off!</span>")
		user.drop_item()
		if(prob(10))
			target = get_turf(user)
		else
			var/list/possible_targets = range(3,src)
			target = pick(possible_targets)
		discharge = 1
	if(!discharge)
		user.visible_message("<span class='danger'>[user] fires \the [src]!</span>", \
				    		 "<span class='danger'>You fire \the [src]!</span>")
	add_logs(user, target, "fired at", src)
	var/turf/T = get_target(target, get_turf(src))
	playsound(src.loc, 'sound/weapons/sonic_jackhammer.ogg', 50, 1)
	fire_items(T, user)
	if(pressureSetting >= 3 && user)
		user.visible_message("<span class='warning'>[user] is thrown down by the force of the cannon!</span>", "<span class='userdanger'>[src] slams into your shoulder, knocking you down!")
		user.Knockdown(60)

/obj/item/weapon/pneumatic_cannon/proc/fire_items(turf/target, mob/user)
	if(fire_mode == PCANNON_FIREALL)
		for(var/obj/item/ITD in loadedItems) //Item To Discharge
			if(!throw_item(target, ITD, user))
				break
	else
		for(var/i in 1 to throw_amount)
			if(!loadedItems.len)
				break
			var/obj/item/I
			if(fire_mode == PCANNON_FILO)
				I = loadedItems[loadedItems.len]
			else
				I = loadedItems[1]
			if(!throw_item(target, I, user))
				break

/obj/item/weapon/pneumatic_cannon/proc/throw_item(turf/target, obj/item/I, mob/user)
	if(!istype(I))
		return FALSE
	loadedItems -= I
	loadedWeightClass -= I.w_class
	I.forceMove(get_turf(src))
	I.throw_at(target, pressureSetting * 10 * range_multiplier, pressureSetting * 2, user)
	return TRUE

/obj/item/weapon/pneumatic_cannon/proc/get_target(turf/target, turf/starting)
	if(range_multiplier == 1)
		return target
	var/x_o = (target.x - starting.x)
	var/y_o = (target.y - starting.y)
	var/new_x = Clamp((starting.x + (x_o * range_multiplier)), 0, world.maxx)
	var/new_y = Clamp((starting.y + (y_o * range_multiplier)), 0, world.maxy)
	var/turf/newtarget = locate(new_x, new_y, starting.z)
	return newtarget

/obj/item/weapon/pneumatic_cannon/ghetto //Obtainable by improvised methods; more gas per use, less capacity, but smaller
	name = "improvised pneumatic cannon"
	desc = "A gas-powered, object-firing cannon made out of common parts."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	maxWeightClass = 7
	gasPerThrow = 5

/obj/item/weapon/pneumatic_cannon/proc/updateTank(obj/item/weapon/tank/internals/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!src.tank)
			return
		to_chat(user, "<span class='notice'>You detach \the [thetank] from \the [src].</span>")
		src.tank.loc = get_turf(user)
		user.put_in_hands(tank)
		src.tank = null
	if(!removing)
		if(src.tank)
			to_chat(user, "<span class='warning'>\The [src] already has a tank.</span>")
			return
		if(!user.transferItemToLoc(thetank, src))
			return
		to_chat(user, "<span class='notice'>You hook \the [thetank] up to \the [src].</span>")
		src.tank = thetank
	src.update_icons()

/obj/item/weapon/pneumatic_cannon/proc/update_icons()
	src.cut_overlays()
	if(!tank)
		return
	add_overlay(tank.icon_state)
	src.update_icon()

/obj/item/weapon/pneumatic_cannon/proc/fill_with_type(type, amount)
	if(!ispath(type, /obj/item))
		return FALSE
	var/loaded = 0
	for(var/i in 1 to amount)
		var/obj/item/I = new type
		if(!load_item(I, null))
			qdel(I)
			return loaded
		loaded++
		CHECK_TICK

/obj/item/weapon/pneumatic_cannon/pie
	name = "pie cannon"
	desc = "Load cream pie for optimal results"
	force = 10
	icon_state = "piecannon"
	gasPerThrow = 0
	checktank = FALSE
	range_multiplier = 3
	fire_mode = PCANNON_FIFO
	throw_amount = 1
	maxWeightClass = 150	//50 pies. :^)
	clumsyCheck = FALSE

/obj/item/weapon/pneumatic_cannon/pie/can_load_item(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/pie))
		return ..()
	to_chat(user, "<span class='warning'>[src] only accepts pies!</span>")
	return FALSE

/obj/item/weapon/pneumatic_cannon/pie/selfcharge
	automatic = TRUE
	var/charge_amount = 1
	var/charge_ticks = 1
	var/charge_tick = 0
	maxWeightClass = 60	//20 pies.

/obj/item/weapon/pneumatic_cannon/pie/selfcharge/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/pneumatic_cannon/pie/selfcharge/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/pneumatic_cannon/pie/selfcharge/process()
	if(++charge_tick >= charge_ticks)
		fill_with_type(/obj/item/weapon/reagent_containers/food/snacks/pie/cream, charge_amount)
