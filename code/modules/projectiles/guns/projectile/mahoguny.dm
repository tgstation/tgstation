/obj/item/weapon/gun/mahoguny
	name = "mahoguny"
	desc = "A rare example of diona ingenuity."
	icon = 'icons/obj/gun.dmi'
	icon_state = "mahoguny"
	item_state = "mahoguny"
	origin_tech = "combat=5;biotech=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	recoil = 1
	slot_flags = SLOT_BELT
	flags = FPRINT
	w_class = 3
	fire_delay = 0
	fire_sound = null
	var/max_ammo = 10
	var/current_ammo = 10

/obj/item/weapon/gun/mahoguny/isHandgun()
	return 0

/obj/item/weapon/gun/mahoguny/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [current_ammo] round\s remaining.</span>")

/obj/item/weapon/gun/mahoguny/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(!current_ammo)
		return click_empty(user)
	if(in_chamber)
		qdel(in_chamber)
		in_chamber = null
	in_chamber = new/obj/item/projectile/bullet/mahoganut(src)
	if(Fire(A,user,params, "struggle" = struggle))
		current_ammo--

/obj/item/weapon/gun/mahoguny/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	. = ..()
	if(.)
		var/list/turf/possible_turfs = list()
		for(var/turf/T in orange(target,1))
			possible_turfs += T
		spawn()
			for(var/i = 1; i <= 3; i++)
				var/newturf = pick(possible_turfs)
				in_chamber = new/obj/item/projectile/bullet/leaf(src)
				..(newturf,user,params,reflex,struggle)

/obj/item/weapon/gun/mahoguny/process_chambered()
	if(in_chamber) return 1
	return 0

/obj/item/weapon/gun/mahoguny/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/stack/sheet/wood))
		if(current_ammo >= max_ammo)
			return
		var/obj/item/stack/sheet/wood/S = W
		current_ammo++
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
		S.use(1)