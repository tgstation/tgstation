/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access = list(access_armory)
	icon = 'icons/obj/guncabinet.dmi'
	icon_state = "base"
	icon_off ="base"
	icon_broken ="base"
	icon_locked ="base"
	icon_closed ="base"
	icon_opened = "base"

/obj/structure/closet/secure_closet/guncabinet/New()
	..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/toggle()
	..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/update_icon()
	overlays.Cut()
	if(opened)
		overlays += icon(icon,"door_open")
	else
		var/lazors = 0
		var/shottas = 0
		for (var/obj/item/weapon/gun/G in contents)
			if (istype(G, /obj/item/weapon/gun/energy))
				lazors++
			if (istype(G, /obj/item/weapon/gun/projectile/))
				shottas++
		if (lazors || shottas)
			for (var/i = 0 to 2)
				var/image/gun = image(icon(src.icon))

				if (lazors > 0 && (shottas <= 0 || prob(50)))
					lazors--
					gun.icon_state = "laser"
				else if (shottas > 0)
					shottas--
					gun.icon_state = "projectile"

				gun.pixel_x = i*4
				overlays += gun

		overlays += icon(src.icon,"door")

		if(broken)
			overlays += icon(src.icon,"broken")
		else if (locked)
			overlays += icon(src.icon,"locked")
		else
			overlays += icon(src.icon,"open")