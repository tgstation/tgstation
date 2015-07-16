/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "densecrate"
	density = 1
	var/obj/item/weapon/paper/manifest/manifest

/obj/structure/largecrate/New()
	..()
	update_icon()

/obj/structure/largecrate/update_icon()
	..()
	overlays.Cut()
	if(manifest)
		overlays += "manifest"

/obj/structure/largecrate/attack_hand(mob/user)
	if(manifest)
		user << "<span class='notice'>You tear the manifest off of the crate.</span>"
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.loc = loc
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	else
		user << "<span class='warning'>You need a crowbar to pry this open!</span>"
		return

/obj/structure/largecrate/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		if(manifest)
			manifest.loc = loc
			manifest = null
			update_icon()
		new /obj/item/stack/sheet/mineral/wood(src)
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.loc = T
		user.visible_message("[user] pries \the [src] open.", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='italics'>You hear splitting wood.</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 75, 1)
		qdel(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"

