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
	if(opened)
		icon_state = "[icon_crate]open"
	else
		icon_state = icon_crate

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
	desc = "A crate for the storage of the RCD."
	name = "\improper RCD crate"

/obj/structure/closet/crate/rcd/New()
	..()
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
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
	if(!gas)	return null
	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.oxygen = gas.oxygen
	newgas.carbon_dioxide = gas.carbon_dioxide
	newgas.nitrogen = gas.nitrogen
	newgas.toxins = gas.toxins
	newgas.volume = gas.volume
	newgas.temperature = gas.temperature
	if(newgas.temperature <= target_temp)	return

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
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
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
	new /obj/item/weapon/minihoe(src)

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "secure crate"
	icon_crate = "securecrate"
	icon_state = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	locked = 1
	health = 1000

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_crate = "weaponcrate"
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_crate = "plasmacrate"
	icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_crate = "secgearcrate"
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_crate = "hydrosecurecrate"
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/New()
	..()
	overlays.Cut()
	if(locked)
		overlays += redlight
	else
		overlays += greenlight

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

/obj/structure/closet/crate/insert(var/atom/movable/AM, var/include_mobs = 0)

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

	if(istype(AM, /obj/structure/stool/bed)) //This is only necessary because of rollerbeds and swivel chairs.
		var/obj/structure/stool/bed/B = AM
		if(B.buckled_mob)
			return 0

	AM.loc = src
	return 1

/obj/structure/closet/crate/proc/tear_manifest(mob/user as mob)
	user << "<span class='notice'>You tear the manifest off of the crate.</span>"
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
	manifest.loc = loc
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_icon()
	
/obj/structure/closet/crate/attack_hand(mob/user as mob)
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
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, src)
					s.start()
					return
		open()
	return

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	if(manifest)
		tear_manifest(user)
		return
	if(locked && !broken)
		if (allowed(user))
			user << "<span class='notice'>You unlock [src].</span>"
			src.locked = 0
			overlays.Cut()
			overlays += greenlight
			add_fingerprint(user)
			return
		else
			user << "<span class='notice'>[src] is locked.</span>"
			return
	else
		..()

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/card) && src.allowed(user) && !locked && !opened && !broken)
		user << "<span class='notice'>You lock \the [src].</span>"
		src.locked = 1
		overlays.Cut()
		overlays += redlight
		add_fingerprint(user)
		return

	return ..()

/obj/structure/closet/crate/secure/emag_act(mob/user as mob)
	if(locked && !broken)
		overlays.Cut()
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		user << "<span class='notice'>You unlock \the [src].</span>"
		add_fingerprint(user)

/obj/structure/closet/crate/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/closet/crate/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
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
			user  << "<span class='notice'>You attach [W] to [src].</span>"
			user.drop_item()
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

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			overlays.Cut()
			overlays += redlight
		else
			overlays.Cut()
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()

