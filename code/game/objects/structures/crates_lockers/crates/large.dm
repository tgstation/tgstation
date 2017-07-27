/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate."
	icon_state = "largecrate"
	density = TRUE
	material_drop = /obj/item/stack/sheet/mineral/wood
	delivery_icon = "deliverybox"

/obj/structure/closet/crate/large/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, "<span class='warning'>You need a crowbar to pry this open!</span>")

/obj/structure/closet/crate/large/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/crowbar))
		var/turf/T = get_turf(src)
		if(manifest)
			tear_manifest(user)

		user.visible_message("[user] pries \the [src] open.", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='italics'>You hear splitting wood.</span>")
		playsound(src.loc, 'sound/weapons/slashmiss.ogg', 75, 1)

		for(var/i in 1 to rand(2, 5))
			new material_drop(src)
		for(var/atom/movable/AM in contents)
			AM.forceMove(T)

		qdel(src)
	else
		return ..()
