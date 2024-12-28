/// The common cardboard box.
/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	/// What material do we get when we fold this box?
	var/foldable_result = /obj/item/stack/sheet/cardboard
	/// What drawing will we get on the face of the box?
	var/illustration = "writing"

/obj/item/storage/box/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	update_appearance()
	atom_storage.open_sound = 'sound/items/handling/cardboard_box/cardboard_box_open.ogg'
	atom_storage.rustle_sound = 'sound/items/handling/cardboard_box/cardboard_box_rustle.ogg'

/obj/item/storage/box/suicide_act(mob/living/carbon/user)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(myhead)
		user.visible_message(span_suicide("[user] puts [user.p_their()] head into \the [src] and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
		myhead.dismember()
		myhead.forceMove(src) //force your enemies to kill themselves with your head collection box!
		playsound(user, "desecration-01.ogg", 50, TRUE, -1)
		return BRUTELOSS
	user.visible_message(span_suicide("[user] is beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/box/update_overlays()
	. = ..()
	if(illustration)
		. += illustration

/obj/item/storage/box/attack_self(mob/user)
	..()

	if(!foldable_result || (flags_1 & HOLOGRAM_1))
		return
	if(contents.len)
		balloon_alert(user, "items inside!")
		return
	if(!ispath(foldable_result))
		return

	var/obj/item/result = new foldable_result(user.drop_location())
	balloon_alert(user, "folded")
	qdel(src)
	user.put_in_hands(result)
