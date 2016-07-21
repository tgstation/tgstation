/obj/mecha/combat
	force = 30
	internal_damage_threshold = 50
	damage_absorption = list("brute"=0.7,"fire"=1,"bullet"=0.7,"laser"=0.85,"energy"=1,"bomb"=0.8)

/obj/mecha/combat/CheckParts(atom/holder)
	..()
	var/obj/item/weapon/stock_parts/capacitor/C = locate() in holder
	var/obj/item/weapon/stock_parts/scanning_module/SM = locate() in holder
	step_energy_drain = 20 - (5 * SM.rating) //10 is normal, so on lowest part its worse, on second its ok and on higher its real good up to 0 on best
	var/DR = damage_absorption["energy"]
	damage_absorption["energy"] = DR - (C.rating / 10) //Each level of capacitor protects the mech against emp by 10%
	qdel(C)
	qdel(SM)

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0

/obj/mecha/combat/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	if(..())
		if(occupant.client)
			occupant.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return 1
	else
		return 0


/obj/mecha/combat/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	..()


