
/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	var/unfoldedbag_path = /obj/structure/closet/body_bag
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bodybag/attack_self(mob/user)
	deploy_bodybag(user, user.loc)

/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	if(proximity)
		if(isopenturf(target))
			deploy_bodybag(user, target)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/R = new unfoldedbag_path(location)
	R.open(user)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	icon_state = "bodybags"

/obj/item/weapon/storage/box/bodybags/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)


// Bluespace bodybag

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "A folded bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "bluespace=4;materials=4;plasmatech=4"

