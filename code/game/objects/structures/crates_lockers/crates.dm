//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"
	req_access = null
	opened = 0
	flags = FPRINT
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0
	var/sound_effect_open = 'sound/machines/click.ogg'
	var/sound_effect_close = 'sound/machines/click.ogg'

/obj/structure/closet/pcrate
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "plasticcrate"
	density = 1
	icon_opened = "plasticcrateopen"
	icon_closed = "plasticcrate"
	req_access = null
	opened = 0
	flags = FPRINT
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	var/rigged = 0
	var/sound_effect_open = 'sound/machines/click.ogg'
	var/sound_effect_close = 'sound/machines/click.ogg'

	starting_materials = list(MAT_PLASTIC = 10*CC_PER_SHEET_METAL) // Recipe calls for 10 sheets.

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "Internals crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "o2crate"
	density = 1
	icon_opened = "o2crateopen"
	icon_closed = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "Trash Cart"
	icon = 'icons/obj/storage.dmi'
	icon_state = "trashcart"
	density = 1
	icon_opened = "trashcartopen"
	icon_closed = "trashcart"

/obj/structure/closet/crate/chest
	desc = "A heavy wooden chest. Probably filled with gold and treasure!"
	name = "chest"
	icon = 'icons/obj/storage.dmi'
	icon_state = "chest"
	density = 1
	icon_opened = "chestopen"
	icon_closed = "chest"

/*these aren't needed anymore
/obj/structure/closet/crate/hat
	desc = "A crate filled with Valuable Collector's Hats!."
	name = "Hat Crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/contraband
	name = "Poster crate"
	desc = "A random assortment of posters manufactured by providers NOT listed under Nanotrasen's whitelist."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"
*/

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "Medical crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "medicalcrate"
	density = 1
	icon_opened = "medicalcrateopen"
	icon_closed = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	density = 1
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon = 'icons/obj/storage.dmi'
	icon_state = "freezer"
	density = 1
	icon_opened = "freezeropen"
	icon_closed = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

	return_air()
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


/obj/structure/closet/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebin"
	density = 1
	icon_opened = "largebinopen"
	icon_closed = "largebin"

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "Radioactive gear crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "radiation"
	density = 1
	icon_opened = "radiationopen"
	icon_closed = "radiation"

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "Weapons crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "weaponcrate"
	density = 1
	icon_opened = "weaponcrateopen"
	icon_closed = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "Plasma crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "plasmacrate"
	density = 1
	icon_opened = "plasmacrateopen"
	icon_closed = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "Gear crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secgearcrate"
	density = 1
	icon_opened = "secgearcrateopen"
	icon_closed = "secgearcrate"

/obj/structure/closet/crate/secure/hydrosec
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "hydrosecurecrate"
	density = 1
	icon_opened = "hydrosecurecrateopen"
	icon_closed = "hydrosecurecrate"

/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	icon_opened = "largebinsopen"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"

/obj/structure/closet/crate/secure/large/close()
	//we can hold up to one large item
	var/found = 0
	for(var/obj/structure/S in src.loc)
		if(S == src)
			continue
		if(!S.anchored)
			found = 1
			S.loc = src
			break
	if(!found)
		for(var/obj/machinery/M in src.loc)
			if(!M.anchored)
				M.loc = src
				break
	..()

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	broken = 0
	locked = 1
	health = 1000

/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"

/obj/structure/closet/crate/large/close()
	//we can hold up to one large item
	var/found = 0
	for(var/obj/structure/S in src.loc)
		if(S == src)
			continue
		if(!S.anchored)
			found = 1
			S.loc = src
			break
	if(!found)
		for(var/obj/machinery/M in src.loc)
			if(!M.anchored)
				M.loc = src
				break
	..()

/obj/structure/closet/crate/hydroponics
	name = "Hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon = 'icons/obj/storage.dmi'
	icon_state = "hydrocrate"
	icon_opened = "hydrocrateopen"
	icon_closed = "hydrocrate"
	density = 1

/obj/structure/closet/crate/sci
	desc = "A science crate."
	name = "science crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "scicrate"
	density = 1
	icon_opened = "scicrateopen"
	icon_closed = "scicrate"

/obj/structure/closet/crate/secure/scisec
	desc = "A secure science crate."
	name = "secure science crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "scisecurecrate"
	density = 1
	icon_opened = "scisecurecrateopen"
	icon_closed = "scisecurecrate"

/obj/structure/closet/crate/engi
	desc = "An engineering crate."
	name = "engineering crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "engicrate"
	density = 1
	icon_opened = "engicrateopen"
	icon_closed = "engicrate"

/obj/structure/closet/crate/secure/engisec
	desc = "A secure engineering crate."
	name = "secure engineering crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "engisecurecrate"
	density = 1
	icon_opened = "engisecurecrateopen"
	icon_closed = "engisecurecrate"

/obj/structure/closet/crate/secure/plasma/prefilled
	var/count=10
/obj/structure/closet/crate/secure/plasma/prefilled/New()
	for(var/i=0;i<count;i++)
		new /obj/item/weapon/tank/plasma(src)

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.
	New()
		..()
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new /obj/item/weapon/minihoe(src)


/obj/structure/closet/crate/secure/New()
	..()
	if(locked)
		overlays.len = 0
		overlays += redlight
	else
		overlays.len = 0
		overlays += greenlight

/obj/structure/closet/crate/rcd/New()
	..()
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/device/rcd/matter/engineering(src)

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

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0 || wall_mounted)) return 1
	if(istype(mover, /obj/structure/closet/crate)) return 0
	return (!density)

/obj/structure/closet/crate/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0
	playsound(get_turf(src), sound_effect_open, 15, 1, -3)

	dump_contents()

	icon_state = icon_opened
	src.opened = 1
	src.density = 0
	return 1

/obj/structure/closet/crate/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0
	playsound(get_turf(src), sound_effect_close, 15, 1, -3)

	take_contents()

	icon_state = icon_closed
	src.opened = 0
	src.density = 1
	return 1

/obj/structure/closet/crate/insert(var/atom/movable/AM, var/include_mobs = 0)

	if(contents.len >= storage_capacity)
		return -1

	if(include_mobs && isliving(AM))
		var/mob/living/L = AM
		if(L.locked_to)
			return 0
	else if(isobj(AM))
		if(AM.density || AM.anchored || istype(AM,/obj/structure/closet))
			return 0
	else
		return 0

	if(istype(AM, /obj/structure/bed)) //This is only necessary because of rollerbeds and swivel chairs.
		var/obj/structure/bed/B = AM
		if(B.locked_atoms.len)
			return 0

	AM.forceMove(src)
	return 1

/obj/structure/closet/crate/attack_hand(mob/user as mob)
	if(!Adjacent(user))
		return
	if(opened)
		close()
	else
		if(rigged && locate(/obj/item/device/radio/electropack) in src)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, src))
					//var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					//s.set_up(5, 1, src)
					//s.start()
					return
		open()
	return

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	if(!Adjacent(user))
		return
	if(locked && !broken)
		if (allowed(user))
			to_chat(user, "<span class='notice'>You unlock [src].</span>")
			src.locked = 0
			overlays.len = 0
			overlays += greenlight
			return
		else
			to_chat(user, "<span class='notice'>[src] is locked.</span>")
			return
	else
		..()

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card) && src.allowed(user) && !locked && !opened && !broken)
		to_chat(user, "<span class='notice'>You lock \the [src].</span>")
		src.locked = 1
		overlays.len = 0
		overlays += redlight
		return
	else if ( istype(W, /obj/item/weapon/card/emag) && locked &&!broken)
		overlays.len = 0
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(get_turf(src), "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
		return
	return ..()

/obj/structure/closet/crate/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/closet/crate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opened)
		return ..()
	else if(istype(W, /obj/item/stack/package_wrap))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(rigged)
			to_chat(user, "<span class='notice'>[src] is already rigged!</span>")
			return
		to_chat(user, "<span class='notice'>You rig [src].</span>")
		user.drop_item(W)
		del(W)
		rigged = 1
		return
	else if(istype(W, /obj/item/device/radio/electropack))
		if(rigged)
			to_chat(user, "<span class='notice'>You attach [W] to [src].</span>")
			user.drop_item(W, src.loc)
			return
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(rigged)
			to_chat(user, "<span class='notice'>You cut away the wiring.</span>")
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
			overlays.len = 0
			overlays += redlight
		else
			overlays.len = 0
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()


/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/O in src.contents)
				qdel(O)
			qdel(src)
			return
		if(2.0)
			for(var/obj/O in src.contents)
				if(prob(50))
					qdel(O)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				qdel(src)
			return
		else
	return

/obj/structure/closet/crate/secure/weapon/experimental
	name = "Experimental Weapons Crate"
	var/chosen_set = null

/obj/structure/closet/crate/secure/weapon/experimental/New()
	..()
	if(!chosen_set)
		chosen_set = pick("ricochet","bison","spur","gatling","stickybomb","nikita","osipr","hecate","gravitywell")

	switch(chosen_set)
		if("ricochet")
			new/obj/item/clothing/suit/armor/laserproof(src)
			new/obj/item/weapon/gun/energy/ricochet(src)
			new/obj/item/weapon/gun/energy/ricochet(src)
		if("bison")
			new/obj/item/clothing/shoes/jackboots(src)
			new/obj/item/clothing/suit/hgpirate(src)
			new/obj/item/clothing/head/hgpiratecap(src)
			new/obj/item/clothing/glasses/eyepatch(src)
			new/obj/item/weapon/gun/energy/bison(src)
		if("spur")
			new/obj/item/clothing/suit/cardborg(src)
			new/obj/item/clothing/head/cardborg(src)
			new/obj/item/device/modkit/spur_parts(src)
			new/obj/item/weapon/gun/energy/polarstar(src)
		if("gatling")
			new/obj/item/clothing/suit/armor/riot(src)
			new/obj/item/clothing/head/helmet/riot(src)
			new/obj/item/clothing/shoes/swat(src)
			new/obj/item/clothing/gloves/swat(src)
			new/obj/item/weapon/gun/gatling(src)
		if("stickybomb")
			new/obj/item/clothing/suit/bomb_suit/security(src)
			new/obj/item/clothing/head/bomb_hood/security(src)
			new/obj/item/weapon/gun/stickybomb(src)
			new/obj/item/weapon/storage/box/stickybombs(src)
		if("nikita")
			for(var/i=1;i<=5;i++)
				new/obj/item/ammo_casing/rocket_rpg/nikita(src)
			new/obj/item/weapon/gun/projectile/rocketlauncher/nikita(src)
		if("osipr")
			new/obj/item/clothing/suit/space/syndicate/black(src)
			new/obj/item/clothing/head/helmet/space/syndicate/black(src)
			new/obj/item/weapon/gun/osipr(src)
		if("hecate")
			new/obj/item/weapon/gun/projectile/hecate(src)
			new/obj/item/ammo_storage/box/BMG50(src)
			new/obj/item/device/radio/headset/headset_earmuffs(src)
			new/obj/item/clothing/glasses/thermal(src)
		if("gravitywell")
			new/obj/item/clothing/suit/radiation(src)
			new/obj/item/clothing/head/radiation(src)
			new/obj/item/clothing/shoes/magboots(src)
			new/obj/item/weapon/gun/gravitywell(src)

/obj/structure/closet/crate/secure/weapon/experimental/ricochet
	chosen_set = "ricochet"

/obj/structure/closet/crate/secure/weapon/experimental/bison
	chosen_set = "bison"

/obj/structure/closet/crate/secure/weapon/experimental/spur
	chosen_set = "spur"

/obj/structure/closet/crate/secure/weapon/experimental/gatling
	chosen_set = "gatling"

/obj/structure/closet/crate/secure/weapon/experimental/stickybomb
	chosen_set = "stickybomb"

/obj/structure/closet/crate/secure/weapon/experimental/nikita
	chosen_set = "nikita"

/obj/structure/closet/crate/secure/weapon/experimental/osipr
	chosen_set = "osipr"

/obj/structure/closet/crate/secure/weapon/experimental/hecate
	chosen_set = "hecate"

/obj/structure/closet/crate/secure/weapon/experimental/gravitywell
	chosen_set = "gravitywell"
