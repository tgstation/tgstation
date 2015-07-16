//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 */

/*
 * Wrench
 */
/obj/item/weapon/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrench"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	w_class = 2
	materials = list(MAT_METAL=150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/wrench/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating \himself to death with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/*
 * Screwdriver
 */
/obj/item/weapon/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/items.dmi'
	icon_state = "screwdriver"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	w_class = 1
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=75)
	attack_verb = list("stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/screwdriver/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is stabbing the [src.name] into \his temple! It looks like \he's trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is stabbing the [src.name] into \his heart! It looks like \he's trying to commit suicide.</span>"))
	return(BRUTELOSS)

/obj/item/weapon/screwdriver/New(loc, var/param_color = null)
	if(!param_color)
		param_color = pick("red","blue","purple","brown","green","cyan","yellow")

	switch(param_color)
		if ("red")
			icon_state = "screwdriver2"
			item_state = "screwdriver"
		if ("blue")
			icon_state = "screwdriver"
			item_state = "screwdriver_blue"
		if ("purple")
			icon_state = "screwdriver3"
			item_state = "screwdriver_purple"
		if ("brown")
			icon_state = "screwdriver4"
			item_state = "screwdriver_brown"
		if ("green")
			icon_state = "screwdriver5"
			item_state = "screwdriver_green"
		if ("cyan")
			icon_state = "screwdriver6"
			item_state = "screwdriver_cyan"
		if ("yellow")
			icon_state = "screwdriver7"
			item_state = "screwdriver_yellow"

	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))	return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if(user.disabilities & CLUMSY && prob(50))
		M = user
	return eyestab(M,user)

/*
 * Wirecutters
 */
/obj/item/weapon/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/items.dmi'
	icon_state = "cutters"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 6.0
	throw_speed = 3
	throw_range = 7
	w_class = 2.0
	materials = list(MAT_METAL=80)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")
	hitsound = 'sound/items/Wirecutter.ogg'

/obj/item/weapon/wirecutters/New(loc, var/param_color = null)
	..()
	if((!param_color && prob(50)) || param_color == "yellow")
		icon_state = "cutters-y"
		item_state = "cutters_yellow"

/obj/item/weapon/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/weapon/restraints/handcuffs/cable))
		user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
		qdel(C.handcuffed)
		C.handcuffed = null
		if(C.buckled && C.buckled.buckle_requires_restraints)
			C.buckled.unbuckle_mob()
		C.update_inv_handcuffed(0)
		return
	else
		..()

/obj/item/weapon/wirecutters/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is cutting at \his arteries with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1, -1)
	return (BRUTELOSS)

/*
 * Welding Tool
 */
/obj/item/weapon/weldingtool
	name = "welding tool"
	desc = "A standard edition welder provided by NanoTrasen."
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
	item_state = "welder"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 3
	throwforce = 5
	hitsound = "swing_hit"
	throw_speed = 3
	throw_range = 5
	w_class = 2
	materials = list(MAT_METAL=70, MAT_GLASS=30)
	origin_tech = "engineering=1"
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/change_icons = 1
	var/can_off_process = 0

/obj/item/weapon/weldingtool/New()
	..()
	create_reagents(max_fuel)
	reagents.add_reagent("welding_fuel", max_fuel)
	update_icon()
	return

/obj/item/weapon/weldingtool/proc/update_torch()
	overlays.Cut()
	if(welding)
		overlays += "[initial(icon_state)]-on"
		item_state = "[initial(item_state)]1"
	else
		item_state = "[initial(item_state)]"

/obj/item/weapon/weldingtool/update_icon()
	if(change_icons)
		var/ratio = get_fuel() / max_fuel
		ratio = Ceiling(ratio*4) * 25
		if(ratio == 100)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)][ratio]"
	update_torch()
	return

/obj/item/weapon/weldingtool/examine(mob/user)
	..()
	user << "It contains [get_fuel()] unit\s of fuel out of [max_fuel]."


/obj/item/weapon/weldingtool/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		flamethrower_screwdriver(I, user)
	if(istype(I, /obj/item/stack/rods))
		flamethrower_rods(I, user)
	..()


/obj/item/weapon/weldingtool/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/organ/limb/affecting = H.get_organ(check_zone(user.zone_sel.selecting))

	if(affecting.status == ORGAN_ROBOTIC && user.a_intent != "harm")
		if(src.remove_fuel(1))
			playsound(loc, 'sound/items/Welder.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] starts to fix some of the dents on [H]'s [affecting.getDisplayName()].</span>", "<span class='notice'>You start fixing some of the dents on [H]'s [affecting.getDisplayName()].</span>")
			if(!do_mob(user, H, 50))	return
			item_heal_robotic(H, user, 5, 0)
			return
		else
			return
	else
		return ..()

/obj/item/weapon/weldingtool/process()
	switch(welding)
		if(0)
			force = 3
			damtype = "brute"
			update_icon()
			if(!can_off_process)
				SSobj.processing.Remove(src)
			return
	//Welders left on now use up fuel, but lets not have them run out quite that fast
		if(1)
			force = 15
			damtype = "fire"
			if(prob(5))
				remove_fuel(1)
			update_icon()

	//This is to start fires. process() is only called if the welder is on.
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(700, 5)


/obj/item/weapon/weldingtool/afterattack(atom/O, mob/user, proximity)
	if(!proximity) return
	if(istype(O, /obj/structure/reagent_dispensers/fueltank) && in_range(src, O))
		if(!welding)
			O.reagents.trans_to(src, max_fuel)
			user << "<span class='notice'>[src] refueled.</span>"
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			update_icon()
			return
		else
			message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			user << "<span class='warning'>That was stupid of you.</span>"
			O.ex_act()
			return

	if(welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		location.hotspot_expose(700, 50, 1)

		if(isliving(O))
			var/mob/living/L = O
			L.IgniteMob()

/obj/item/weapon/weldingtool/attack_self(mob/user)
	toggle(user)
	update_icon()

//Returns the amount of fuel in the welder
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("welding_fuel")


//Removes fuel from the welding tool. If a mob is passed, it will try to flash the mob's eyes. This should probably be renamed to use()
/obj/item/weapon/weldingtool/proc/remove_fuel(amount = 1, mob/living/M = null)
	if(!welding || !check_fuel())
		return 0
	if(get_fuel() >= amount)
		reagents.remove_reagent("welding_fuel", amount)
		check_fuel()
		if(M)
			M.flash_eyes(2)
		return 1
	else
		if(M)
			M << "<span class='warning'>You need more welding fuel to complete this task!</span>"
		return 0


//Returns whether or not the welding tool is currently on.
/obj/item/weapon/weldingtool/proc/isOn()
	return welding


//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weapon/weldingtool/proc/check_fuel(mob/user)
	if(get_fuel() <= 0 && welding)
		toggle(user, 1)
		update_icon()
		//mob icon update
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_r_hand(0)
			M.update_inv_l_hand(0)

		return 0
	return 1


//Toggles the welder off and on
/obj/item/weapon/weldingtool/proc/toggle(mob/user, message = 0)
	if(!status)
		user << "<span class='warning'>[src] can't be turned on while unsecured!</span>"
		return
	welding = !welding
	if(welding)
		if(get_fuel() >= 1)
			user << "<span class='notice'>You switch [src] on.</span>"
			force = 15
			damtype = "fire"
			hitsound = 'sound/items/welder.ogg'
			update_icon()
			SSobj.processing |= src
		else
			user << "<span class='warning'>You need more fuel!</span>"
			welding = 0
	else
		if(!message)
			user << "<span class='notice'>You switch [src] off.</span>"
		else
			user << "<span class='warning'>[src] shuts off!</span>"
		force = 3
		damtype = "brute"
		hitsound = "swing_hit"
		update_icon()

/obj/item/weapon/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		user << "<span class='warning'>Turn it off first!</span>"
		return
	status = !status
	if(status)
		user << "<span class='notice'>You resecure [src].</span>"
	else
		user << "<span class='notice'>[src] can now be attached and modified.</span>"
	add_fingerprint(user)

/obj/item/weapon/weldingtool/proc/flamethrower_rods(obj/item/I, mob/user)
	if(!status)
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/weapon/flamethrower/F = new /obj/item/weapon/flamethrower(user.loc)
			if(!remove_item_from_storage(F))
				user.unEquip(src)
				loc = F
			F.weldtool = src
			add_fingerprint(user)
			user << "<span class='notice'>You add a rod to a welder, starting to build a flamethrower.</span>"
			user.put_in_hands(F)
		else
			user << "<span class='warning'>You need one rod to start building a flamethrower!</span>"
			return

/obj/item/weapon/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	max_fuel = 40
	materials = list(MAT_GLASS=60)
	origin_tech = "engineering=2"

/obj/item/weapon/weldingtool/largetank/cyborg

/obj/item/weapon/weldingtool/largetank/flamethrower_screwdriver()
	return


/obj/item/weapon/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = 1
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	change_icons = 0

/obj/item/weapon/weldingtool/mini/flamethrower_screwdriver()
	return


/obj/item/weapon/weldingtool/hugetank
	name = "upgraded industrial welding tool"
	desc = "An upgraded welder based of the industrial welder."
	icon_state = "upindwelder"
	item_state = "upindwelder"
	max_fuel = 80
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "engineering=3"

/obj/item/weapon/weldingtool/experimental
	name = "experimental welding tool"
	desc = "An experimental welder capable of self-fuel generation."
	icon_state = "exwelder"
	item_state = "exwelder"
	max_fuel = 40
	materials = list(MAT_METAL=70, MAT_GLASS=120)
	origin_tech = "materials=4;engineering=4;bluespace=3;plasmatech=3"
	var/last_gen = 0
	change_icons = 0
	can_off_process = 1


//Proc to make the experimental welder generate fuel, optimized as fuck -Sieve
//i don't think this is actually used, yaaaaay -Pete
/obj/item/weapon/weldingtool/experimental/proc/fuel_gen()
	if(!welding && !last_gen)
		last_gen = 1
		reagents.add_reagent("welding_fuel",1)
		spawn(10)
			last_gen = 0

/obj/item/weapon/weldingtool/experimental/process()
	..()
	if(reagents.total_volume < max_fuel)
		fuel_gen()



/*
 * Crowbar
 */

/obj/item/weapon/crowbar
	name = "pocket crowbar"
	desc = "A small crowbar. This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/items.dmi'
	icon_state = "crowbar"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	item_state = "crowbar"
	w_class = 2
	materials = list(MAT_METAL=50)
	origin_tech = "engineering=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/crowbar/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating \himself to death with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/crowbar/red
	icon_state = "red_crowbar"
	item_state = "crowbar_red"
	force = 8

/obj/item/weapon/crowbar/large
	name = "crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because it's big."
	force = 12
	w_class = 3
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"
