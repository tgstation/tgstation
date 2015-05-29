/obj/item/weapon/shield/riot/trayshield
	name = "tray shield"
	desc = "A makeshift shield that won't last for long."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "trayshield"
	slot_flags = null //SLOT_BACK
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = 4
	origin_tech = "materials=2"
	attack_verb = list("shoved", "bashed")

/obj/item/weapon/shield/riot/trayshield/IsShield()
	if(prob(30))
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			visible_message("<span class='warning'>[H]'s shield breaks!</span>", "<span class='warning'>Your shield breaks!</span>")
			H.unEquip(src, 1)
		qdel(src)
		return 0
	else
		return 1

/obj/item/weapon/storage/bag/tray/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ducttape))
		return
	..()