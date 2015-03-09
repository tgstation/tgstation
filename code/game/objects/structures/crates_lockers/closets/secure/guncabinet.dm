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

	var/icon/cabinet_door

/obj/structure/closet/secure_closet/guncabinet/New()
	..()
	cabinet_door = icon(icon, "door_locked")
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/toggle()
	var/old_open = opened
	. = ..()
	update_icon(old_open != opened)

/obj/structure/closet/secure_closet/guncabinet/togglelock()
	. = ..()
	update_icon()

/obj/structure/closet/secure_closet/guncabinet/update_icon(contents_change = 0)
	overlays -= cabinet_door
	overlays.Remove("welded")
	if(opened)
		cabinet_door = icon(icon, "door_open")
	else
		if(broken)
			cabinet_door = icon(icon, "door_broken")
		else if (locked)
			cabinet_door = icon(icon, "door_locked")
		else
			cabinet_door = icon(icon, "door")

	if(contents_change)
		overlays.len = 0
		var/lazors = 0
		var/shottas = 0
		for (var/obj/item/weapon/gun/G in contents)
			if (istype(G, /obj/item/weapon/gun/energy))
				lazors++
			if (istype(G, /obj/item/weapon/gun/projectile/))
				shottas++
		if (lazors || shottas)
			var/overlay_num = min(lazors + shottas, 7)
			for (var/i = 1 to overlay_num)
				var/gun_state = ""
				if (lazors > 0 && (shottas <= 0 || prob(50)))
					lazors--
					gun_state = "laser"
				else if (shottas > 0)
					shottas--
					gun_state = "projectile"

				var/image/gun = image(icon(src.icon, gun_state))

				gun.pixel_x = (i-2)*2
				overlays += gun


	overlays += cabinet_door
	if(welded)
		overlays += "welded"
