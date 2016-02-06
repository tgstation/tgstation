//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	var/icon_crate = "crate"
	icon_state = "crate"
	req_access = null
	var/rigged = 0
	var/sound_effect_open = 'sound/machines/click.ogg'
	var/sound_effect_close = 'sound/machines/click.ogg'
	var/obj/item/weapon/paper/manifest/manifest

/obj/structure/closet/crate/New()
	..()
	update_icon()


/obj/structure/closet/crate/update_icon()
	overlays.Cut()
	if(opened)
		icon_state = "[icon_crate]open"
	else
		icon_state = icon_crate
	if(manifest)
		overlays += "manifest"

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "internals crate"
	icon_crate = "o2crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_crate = "trashcart"
	icon_state = "trashcart"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_crate = "medicalcrate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"

/obj/structure/closet/crate/rcd/New()
	..()
	for(var/i in 1 to 4)
		new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_crate = "freezer"
	icon_state = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/return_air()
	var/datum/gas_mixture/gas = (..())
	if(!gas)
		return null

	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.copy_from(gas)

	if(newgas.temperature <= target_temp)
		return

	if((newgas.temperature - cooling_power) > target_temp)
		newgas.temperature -= cooling_power
	else
		newgas.temperature = target_temp
	return newgas


/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radioactive gear crate"
	icon_crate = "radiation"
	icon_state = "radiation"

/obj/structure/closet/crate/radiation/New()
	..()
	for(var/i in 1 to 4)
		new /obj/item/clothing/suit/radiation(src)
		new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_crate = "hydrocrate"
	icon_state = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned

/obj/structure/closet/crate/hydroponics/prespawned/New()
	..()
	new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
	new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
	new /obj/item/weapon/cultivator(src)

/obj/structure/closet/crate/open()
	playsound(src.loc, sound_effect_open, 15, 1, -3)
	dump_contents()
	src.opened = 1
	update_icon()
	return 1

/obj/structure/closet/crate/close()
	playsound(src.loc, sound_effect_close, 15, 1, -3)
	take_contents()
	src.opened = 0
	update_icon()
	return 1

/obj/structure/closet/crate/insert(atom/movable/AM, include_mobs = 0)

	if(contents.len >= storage_capacity)
		return -1
	if(include_mobs && isliving(AM))
		var/mob/living/L = AM
		if(L.buckled)
			return 0
	else if(isobj(AM))
		if(AM.density || AM.anchored || istype(AM,/obj/structure/closet))
			return 0
	else
		return 0

	if(istype(AM, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
		var/obj/structure/bed/B = AM
		if(B.buckled_mob)
			return 0

	AM.loc = src
	return 1

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	user << "<span class='notice'>You tear the manifest off of the crate.</span>"
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
	manifest.loc = loc
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	overlays-="manifest"

/obj/structure/closet/crate/attack_hand(mob/user)
	if(manifest)
		tear_manifest(user)
		return
	if(opened)
		close()
	else
		if(rigged && locate(/obj/item/device/electropack) in src)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, src))
					var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
					s.set_up(5, 1, src)
					s.start()
					return
		open()
	return

/obj/structure/closet/crate/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/crate/attackby(obj/item/weapon/W, mob/user, params)
	if(opened)
		if(isrobot(user))
			return
		if(!user.drop_item()) //couldn't drop the item
			user << "<span class='warning'>\The [W] is stuck to your hand, you cannot put it in \the [src]!</span>"
			return
		if(W)
			W.loc = src.loc
	else if(istype(W, /obj/item/stack/packageWrap))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(rigged)
			user << "<span class='warning'>[src] is already rigged!</span>"
			return
		var/obj/item/stack/cable_coil/C = W
		if (C.use(5))
			user << "<span class='notice'>You rig [src].</span>"
			rigged = 1
		else
			user << "<span class='warning'>You need 5 lengths of cable to rig [src]!</span>"
		return
	else if(istype(W, /obj/item/device/electropack))
		if(rigged)
			if(!user.drop_item())
				return
			user  << "<span class='notice'>You attach [W] to [src].</span>"
			W.loc = src
			return
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(rigged)
			user  << "<span class='notice'>You cut away the wiring.</span>"
			playsound(loc, 'sound/items/Wirecutter.ogg', 100, 1)
			rigged = 0
			return
	else if(!place(user, W))
		return attack_hand(user)

