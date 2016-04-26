/obj/item/weapon/gun/projectile/hivehand
	name = "\improper Hivehand"
	desc = "A living weapon, it can generate and fire mildly toxic stingers. Additionally, it possesses three sharp chitinous growths on the end that can serve as bayonets."
	icon = 'icons/obj/gun.dmi'
	icon_state = "hivehand"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = 4.0
	force = 20
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = 'sound/weapons/hivehand.ogg'
	empty_sound = 'sound/weapons/hivehand_empty.ogg'
	cant_drop = 1
	sharpness = 1
	hitsound = "sound/weapons/bloodyslice.ogg"
	attack_verb = list("claws", "rends", "slashes")
	conventional_firearm = 0
	var/shots_remaining = 0
	var/has_shot = 0

/obj/item/weapon/gun/projectile/hivehand/pickup(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>\The [src] latches tightly onto your arm!</span>")
	user.update_inv_r_hand()
	user.update_inv_l_hand()
	processing_objects.Add(src)

/obj/item/weapon/gun/projectile/hivehand/dropped(mob/user as mob)
	..()
	processing_objects.Remove(src)

/obj/item/weapon/gun/projectile/hivehand/update_icon()
	overlays.len = 0

	var/image/shotsack = null
	if(shots_remaining)
		if(shots_remaining >=2 && shots_remaining < 4)
			shotsack = image('icons/obj/weaponsmithing.dmi', src, "hivehand_overlay_2")
		else if(shots_remaining >=4 && shots_remaining < 6)
			shotsack = image('icons/obj/weaponsmithing.dmi', src, "hivehand_overlay_4")
		else if(shots_remaining >=6 && shots_remaining < 8)
			shotsack = image('icons/obj/weaponsmithing.dmi', src, "hivehand_overlay_6")
		else if(shots_remaining >=8 && shots_remaining < 10)
			shotsack = image('icons/obj/weaponsmithing.dmi', src, "hivehand_overlay_8")
		else if(shots_remaining >=10)
			shotsack = image('icons/obj/weaponsmithing.dmi', src, "hivehand_overlay_10")
	if(shotsack)
		overlays += shotsack

/obj/item/weapon/gun/projectile/hivehand/attackby(obj/item/weapon/W, mob/user)
	if(W.sharpness)
		to_chat(user, "\The [W] fails to pierce the hard carapace of \the [src].")
		return

/obj/item/weapon/gun/projectile/hivehand/examine(mob/user)
	..()
	if(!shots_remaining)
		to_chat(user, "<span class='info'>\The [src] seems to be completely spent at the moment.</span>")
	else
		to_chat(user, "<span class='info'>\The [src]'s size suggests it has [shots_remaining] shots stored.</span>")

/obj/item/weapon/gun/projectile/hivehand/process()
	set waitfor = 0
	if(shots_remaining >= 10)
		return
	if(has_shot)
		has_shot = 0
		sleep(10)
		return
	shots_remaining += 1
	update_icon()
	sleep(30)

/obj/item/weapon/gun/projectile/hivehand/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (A.loc == user.loc)
		return

	else if (A.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	if(!shots_remaining)
		click_empty(user)
		return

	if(flag)	return //we're placing gun on a table or in backpack

	var/obj/item/projectile/bullet/stinger/S = new(null)
	in_chamber = S
	if(Fire(A,user,params, "struggle" = struggle))
		shots_remaining -= 1
		has_shot = 1
	else
		qdel(S)
		in_chamber = null

	update_icon()