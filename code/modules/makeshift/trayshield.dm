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
	block_chance = 35
	var/break_chance = 5
	attack_verb = list("shoved", "bashed")

/obj/item/weapon/shield/riot/trayshield/IsShield()
	if(prob(break_chance))
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			visible_message("<span class='warning'>[H]'s shield breaks!</span>", "<span class='warning'>Your shield breaks!</span>")
			H.unEquip(src, 1)
		qdel(src)
		return 0
	else
		return 1

/obj/item/weapon/storage/bag/tray/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/M = W
		if(M.use(15))
			var/obj/item/weapon/shield/riot/trayshield/new_item = new(user.loc)
			user << "<span class='notice'>You use [W] to turn [src] into [new_item].</span>"
			qdel(src)
			user.put_in_hands(new_item)
		return
