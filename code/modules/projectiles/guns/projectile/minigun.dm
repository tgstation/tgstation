/obj/item/weapon/gun/gatling
	name = "gatling gun"
	desc = "Ya-ta-ta-ta-ta-ta-ta-ta ya-ta-ta-ta-ta-ta-ta-ta do-de-da-va-da-da-dada! Kaboom-Kaboom!"
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "minigun"
	item_state = "minigun0"
	origin_tech = "materials=4;combat=6"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	slot_flags = null
	flags = FPRINT | TWOHANDABLE
	w_class = 5.0//we be fuckin huge maaan
	fire_delay = 0
	fire_sound = 'sound/weapons/gatling_fire.ogg'
	var/max_shells = 200
	var/current_shells = 200

/obj/item/weapon/gun/gatling/isHandgun()
	return 0

/obj/item/weapon/gun/gatling/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [current_shells] round\s remaining.</span>")

/obj/item/weapon/gun/gatling/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.

		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		to_chat(user, "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>")

/obj/item/weapon/gun/gatling/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	..()
	var/list/turf/possible_turfs = list()
	for(var/turf/T in orange(target,1))
		possible_turfs += T
	spawn()
		for(var/i = 1; i <= 3; i++)
			sleep(1)
			var/newturf = pick(possible_turfs)
			..(newturf,user,params,reflex,struggle)

/obj/item/weapon/gun/gatling/update_wield(mob/user)
	item_state = "minigun[wielded ? 1 : 0]"
	if(wielded)
		slowdown = 10
	else
		slowdown = 0

/obj/item/weapon/gun/gatling/process_chambered()
	if(in_chamber) return 1
	if(current_shells)
		current_shells--
		update_icon()
		in_chamber = new/obj/item/projectile/bullet/gatling()//We create bullets as we are about to fire them. No other way to remove them from the gatling.
		new/obj/item/ammo_casing_gatling(get_turf(src))
		return 1
	return 0

/obj/item/weapon/gun/gatling/update_icon()
	switch(current_shells)
		if(150 to INFINITY)
			icon_state = "minigun100"
		if(100 to 149)
			icon_state = "minigun75"
		if(50 to 99)
			icon_state = "minigun50"
		if(1 to 49)
			icon_state = "minigun25"
		else
			icon_state = "minigun0"

/obj/item/weapon/gun/gatling/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/ammo_casing_gatling
	name = "large bullet casing"
	desc = "An oversized bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "gatling-casing"
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 1
	w_class = 1.0
	w_type = RECYK_METAL

/obj/item/ammo_casing_gatling/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(cardinal)

/obj/item/weapon/gun/gatling/beegun
	name = "bee gun"
	desc = "The apocalypse hasn't even begun!"//I'm not even sorry
	icon_state = "beegun"
	item_state = "beegun0"
	origin_tech = "materials=4;combat=6;biotech=5"
	recoil = 0

/obj/item/weapon/gun/gatling/beegun/update_wield(mob/user)
	item_state = "beegun[wielded ? 1 : 0]"
	if(wielded)
		slowdown = 10
	else
		slowdown = 0

/obj/item/weapon/gun/gatling/beegun/process_chambered()
	if(in_chamber) return 1
	if(current_shells)
		current_shells--
		update_icon()
		in_chamber = new/obj/item/projectile/bullet/beegun()
		return 1
	return 0

/obj/item/weapon/gun/gatling/beegun/update_icon()
	switch(current_shells)
		if(150 to INFINITY)
			icon_state = "beegun100"
		if(100 to 149)
			icon_state = "beegun75"
		if(50 to 99)
			icon_state = "beegun50"
		if(1 to 49)
			icon_state = "beegun25"
		else
			icon_state = "beegun0"
