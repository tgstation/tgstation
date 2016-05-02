
// modified crusher
// only does 120 brute damage and won't eat the victims items


/obj/machinery/recycler/birdstation/eat(mob/living/L)

	L.loc = src.loc

	if(istype(L,/mob/living/silicon))
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)

	var/gib = 1
	if(istype(L,/mob/living/carbon))
		gib = 0
		add_blood(L)

	if(!blood && !istype(L,/mob/living/silicon))
		blood = 1
		update_icon()
	L.Paralyse(5)
	if(gib || emagged == 2)
		L.gib()
	else if(emagged == 1)
		L.adjustBruteLoss(120)

// we don't want anyone to dismantle or disable the crusher easily

/obj/machinery/recycler/birdstation/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/wrench) || istype(I, /obj/item/weapon/screwdriver))
		return


//special birdstation survival boxes

/obj/item/weapon/storage/box/birdsurv/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	new /obj/item/device/radio/off(src)
	return

/obj/item/weapon/storage/box/birdeng/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	new /obj/item/device/radio/off(src)
	return

/obj/item/weapon/storage/box/birdsec/New()
	..()
	contents = list()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/weapon/tank/internals/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/medipen(src)
	new /obj/item/device/radio/off(src)
	return
