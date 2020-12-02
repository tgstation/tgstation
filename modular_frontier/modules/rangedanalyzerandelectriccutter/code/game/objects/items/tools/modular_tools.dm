// Electric Cutter

/obj/item/crowbar/electric
	name = "power cutter"
	desc = "A compact electric prying and cutting tool. It's fitted with a prying head."
	icon = 'modular_frontier/modules/rangedanalyzerandelectriccutter/icons/obj/tools.dmi'
	icon_state = "cutter_pry"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=100,/datum/material/titanium=5)
/obj/item/crowbar/power/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "jaws_pry")

/obj/item/wirecutters/electric
	name = "power cutter"
	desc = "A compact electric prying and cutting tool. It's fitted with a cutting head."
	icon = 'modular_frontier/modules/rangedanalyzerandelectriccutter/icons/obj/tools.dmi'
	icon_state = "cutter_cut"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	random_color = FALSE
	custom_materials = list(/datum/material/iron=100,/datum/material/titanium=5)
/obj/item/wirecutters/power/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "jaws_cutter")

///////////////// This is less intrusive than changing the try to pry proc in airlocks.dm /////////////////
/obj/item/crowbar/electric/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/wirecutters/electric/cutjaws = new /obj/item/wirecutters/electric(drop_location())
	cutjaws.name = name // Skyrat fix
	to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(cutjaws)

/obj/item/wirecutters/electric/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/crowbar/electric/pryjaws = new /obj/item/crowbar/electric(drop_location())
	pryjaws.name = name // Skyrat fix
	to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(pryjaws)

/obj/item/wirecutters/electric/attack(mob/living/carbon/C, mob/user)
	if(istype(C))
		if(C.handcuffed)
			user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
			qdel(C.handcuffed)
			return
	..()
///////////////// This is less intrusive than changing the try to pry proc in airlocks.dm /////////////////
