/obj/item/weapon/pneumatic_cannon
	name = "pneumatic cannon"
	desc = "A gas-powered cannon that can fire any object loaded into it."
	w_class = 4
	force = 8 //Very heavy
	attack_verb = list("bludgeoned", "smashed", "beaten")
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "chemsprayer"
	var/maxWeightClass = 20 //The max weight of items that can fit into the cannon
	var/loadedWeightClass = 0 //The weight of items currently in the cannon
	var/obj/item/weapon/tank/internals/tank = null //The gas tank that is drawn from to fire things
	var/gasPerThrow = 50 //How much gas is drawn from a tank's pressure to fire
	var/list/loadedItems = list() //The items loaded into the cannon that will be fired out
	var/pressureSetting = 1 //How powerful the cannon is - higher pressure = more gas but more powerful throws


/obj/item/weapon/pneumatic_cannon/examine(mob/user)
	..()
	if(!in_range(user, src))
		user << "<span class='notice'>You'll need to get closer to see any more.</span>"
		return
	for(var/obj/item/I in loadedItems)
		spawn(0)
			user << "<span class='info'>It has \the [I] loaded.</span>"
	if(tank)
		user << "<span class='notice'>It has \the [tank] mounted onto it.</span>"


/obj/item/weapon/pneumatic_cannon/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/tank/internals/) && !tank)
		user << "<span class='notice'>You connect \the [W] to \the [src].</span>"
		tank = W
		user.drop_item()
		W.loc = src
		return
	if(istype(W, /obj/item/weapon/wrench))
		switch(pressureSetting)
			if(1)
				pressureSetting = 2
			if(2)
				pressureSetting = 3
			if(3)
				pressureSetting = 1
		user << "<span class='notice'>You tweak \the [src]'s pressure output to [pressureSetting].</span>"
		return
	if(istype(W, /obj/item/weapon/screwdriver) && tank))
		user << "<span class='notice'>You disconnect \the [tank] from \the [src].</span>"
		tank.loc = get_turf(user)
		tank = null
	if(loadedWeightClass >= maxWeightClass)
		user << "<span class='warning'>\The [src] can't fit any more items.</span>"
		return
	if(istype(W, /obj/item))
		var/obj/item/IW = W
		if((loadedWeightClass + IW.w_class) > maxWeightClass)
			user << "<span class='warning'>\The [IW] won't fit into \the [src].</span>"
			return
		if(IW.w_class > src.w_class)
			user << "<span class='warning'>\The [IW] is too large to fit into \the [src].</span>"
			return
		user << "<span class='notice'>You load \the [IW] into \the [src].</span>"
		user.drop_item()
		loadedItems.Add(IW)
		loadedWeightClass += IW.w_class
		IW.loc = src
		return


/obj/item/weapon/pneumatic_cannon/afterattack(atom/target as mob|obj|turf, mob/living/carbon/human/user as mob|obj, flag, params)
	if(user.a_intent == "harm" || !ishuman(user))
		return ..()
	if(!loadedItems || !loadedWeightClass)
		user << "<span class='warning'>\The [src] has nothing loaded.</span>"
		return
	if(!tank)
		user << "<span class='warning'>\The [src] can't fire without a source of gas.</span>"
		return
	if(tank && !tank.air_contents.remove(gasPerThrow & pressureSetting))
		user << "<span class='warning'>\The [src] lets out a weak hiss and doesn't react!</span>"
		return
	user.visible_message("<span class='danger'>[user] fires \the [src]!</span>", \
			     "<span class='warning'>You fire \the [src]!</span>")
	playsound(src.loc, 'sound/weapons/sonic_jackhammer.ogg', (50 * pressureSetting), 1)
	for(var/obj/item/ITD in loadedItems) //Item To Discharge
		spawn(0)
			loadedItems.Remove(ITD)
			loadedWeightClass -= ITD.w_class
			ITD.throw_speed = pressureSetting * 2
			ITD.loc = get_turf(src)
			ITD.throw_at(target, pressureSetting * 5, pressureSetting * 2)
	if(pressureSetting >= 3)
		user << "<span class='boldannounce'>\The [src]'s recoil knocks you down!</span>"
		user.Weaken(2)


/obj/item/weapon/pneumatic_cannon/ghetto //Obtainable by improvised methods; more gas per use, less capacity, but smaller
	name = "improvised pneumatic cannon"
	desc = "A gas-powered, object-firing cannon made out of common parts."
	force = 5
	w_class = 3
	maxWeightClass = 10
	gasPerThrow = 77

/datum/table_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but
	name = "Pneumatic Cannon"
	result = /obj/item/weapon/pneumatic_cannon/ghetto
	tools = list(/obj/item/weapon/weldingtool,
				 /obj/item/weapon/wrench)
	reqs = list(/obj/item/stack/rods = 4, //Forming the barrel
				/obj/item/stack/sheet/metal = 4, //Forming the body and internal piston
				/obj/item/stack/sheet/rglass = 3, //Forming the gas reservoir
				/obj/item/stack/packageWrap = 8, //Padding the stock
				/obj/item/pipe = 2, //Forming the gas transfer
				/obj/item/stack/sheet/glass = 2) //And finally, forming the hatch into the reservoir
	time = 300
