/obj/mecha/combat
	force = 30
	internal_damage_threshold = 50
	armor = list(melee = 30, bullet = 30, laser = 15, energy = 20, bomb = 20, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/mecha/combat/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/stock_parts/capacitor/C = locate() in contents
	var/obj/item/weapon/stock_parts/scanning_module/SM = locate() in contents
	step_energy_drain = 20 - (5 * SM.rating) //10 is normal, so on lowest part its worse, on second its ok and on higher its real good up to 0 on best
	armor["energy"] += (C.rating * 10) //Each level of capacitor protects the mech against emp by 10%
	qdel(C)
	qdel(SM)

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.client && H.client.mouse_pointer_icon == initial(H.client.mouse_pointer_icon))
			H.client.mouse_pointer_icon = 'icons/mecha/mecha_mouse.dmi'
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	if(..())
		if(occupant.client && occupant.client.mouse_pointer_icon == initial(occupant.client.mouse_pointer_icon))
			occupant.client.mouse_pointer_icon = 'icons/mecha/mecha_mouse.dmi'
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(occupant && occupant.client && occupant.client.mouse_pointer_icon == 'icons/mecha/mecha_mouse.dmi')
		occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)
	..()


