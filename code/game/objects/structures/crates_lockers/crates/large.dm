/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate."
	icon_state = "largecrate"
	density = TRUE
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	integrity_failure = 0 //Makes the crate break when integrity reaches 0, instead of opening and becoming an invisible sprite.

/obj/structure/closet/crate/large/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It's held together by a couple of <b>nails</b>.</span>")

/obj/structure/closet/crate/large/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, "<span class='warning'>You need a crowbar to pry this open!</span>")

/obj/structure/closet/crate/large/crowbar_act(mob/living/user, obj/item/I)
	if(manifest)
		tear_manifest(user)

	user.visible_message("[user] pries \the [src] open.", \
					 "<span class='notice'>You pry open \the [src].</span>", \
					 "<span class='italics'>You hear splitting wood.</span>")
	playsound(src.loc, 'sound/weapons/slashmiss.ogg', 75, 1)

	var/turf/T = get_turf(src)
	for(var/i in 1 to material_drop_amount)
		new material_drop(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)

	qdel(src)
	return TRUE
