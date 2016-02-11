/obj/item/weapon/gun/projectile/revialver
	name = "revialver"
	desc = "A makeshift single-action revolver, this weapon utilizes liquid pressure from the spray bottle to launch glass vials."
	icon = 'icons/obj/gun.dmi'
	icon_state = "revialver0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = 3
	force = 5
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = "materials=1;medical=1;combat=1;engineering=1"
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = 'sound/weapons/dartgun.ogg'
	conventional_firearm = 0
	var/cylinder = null

/obj/item/weapon/gun/projectile/revialver/Destroy()
	if(cylinder)
		qdel(cylinder)
		cylinder = null
	..()

/obj/item/weapon/gun/projectile/revialver/attack_self(mob/user as mob)
	if(!cylinder)
		return

	var/obj/item/weapon/cylinder/C = cylinder
	C.cycle()
	to_chat(user, "You cycle \the [src]'s [C] to the next chamber.")
	playsound(user, 'sound/weapons/switchblade.ogg', 50, 1)

/obj/item/weapon/gun/projectile/revialver/proc/spin()
	if(!cylinder)
		return

	var/obj/item/weapon/cylinder/C = cylinder
	C.current_chamber = rand(1,6)

/obj/item/weapon/gun/projectile/revialver/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cylinder))
		if(cylinder)
			to_chat(user, "There is already a cylinder loaded into \the [src].")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		to_chat(user, "You load \the [W] into \the [src].")
		cylinder = W
		icon_state = "revialver1"
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	update_verbs()

/obj/item/weapon/gun/projectile/revialver/proc/update_verbs()
	if(cylinder)
		verbs += /obj/item/weapon/gun/projectile/revialver/verb/remove_cylinder
		verbs += /obj/item/weapon/gun/projectile/revialver/verb/spin_cylinder
	else
		verbs -= /obj/item/weapon/gun/projectile/revialver/verb/remove_cylinder
		verbs -= /obj/item/weapon/gun/projectile/revialver/verb/spin_cylinder

/obj/item/weapon/gun/projectile/revialver/verb/remove_cylinder()
	set name = "Remove cylinder"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!cylinder)
		return

	var/obj/item/weapon/cylinder/C = cylinder
	C.forceMove(usr.loc)
	usr.put_in_hands(C)
	cylinder = null
	to_chat(usr, "You remove \the [C] from \the [src].")
	icon_state = "revialver0"
	usr.update_inv_r_hand()
	usr.update_inv_l_hand()

	update_verbs()

/obj/item/weapon/gun/projectile/revialver/verb/spin_cylinder()
	set name = "Spin cylinder"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!cylinder)
		return

	to_chat(usr, "You spin \the [src]'s cylinder.")
	spin()
	playsound(usr, 'sound/weapons/revolver_spin.ogg', 50, 1)

	update_verbs()

/obj/item/weapon/gun/projectile/revialver/examine(mob/user)
	..()
	if(cylinder)
		var/obj/item/weapon/cylinder/C = cylinder
		var/chambercount = 0
		for(var/i = 1; i<=6; i++)
			if(C.chambers[i])
				chambercount += 1
		if(chambercount)
			to_chat(user, "<span class='info'>There [chambercount > 1 ? "are" : "is"] [chambercount] vial[chambercount > 1 ? "s loaded" : " loaded"] into \the [src]'s cylinder.</span>")
	else
		to_chat(user, "<span class='info'>There doesn't appear to be a cylinder loaded into \the [src].</span>")

/obj/item/weapon/gun/projectile/revialver/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (A.loc == user.loc)
		return

	else if (A.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	var/obj/item/weapon/cylinder/C = cylinder
	if(!(C.chambers[C.current_chamber]))
		click_empty(user)
		return

	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		to_chat(user, "<span class='warning'>A label sticks the trigger to the trigger guard!</span>")//Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return

	var/obj/item/projectile/bullet/vial/V = new(null)
	var/obj/item/weapon/reagent_containers/glass/beaker/vial/I
	I = C.chambers[C.current_chamber]
	I.forceMove(V)
	V.vial = I
	C.chambers[C.current_chamber] = null
	V.user = user
	in_chamber = V
	if(Fire(A,user,params, "struggle" = struggle))
		return
	else
		V.vial = null
		I.forceMove(C)
		C.chambers[C.current_chamber] = I
		qdel(V)
		in_chamber = null