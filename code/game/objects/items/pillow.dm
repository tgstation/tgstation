
/obj/item/pillow 
	name = "pillow"
	desc = "A soft and fluffy pillow. You can smack someone with this!"
	icon = 'icons/obj/pillow.dmi'
	icon_state = "pillow_with_tag"
	inhand_icon_state = "pillow"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	damtype = STAMINA
	force = 10
	var/fluffy_dammage = 10
	var/pillow_trophy = new /obj/item/trash/pillow_tag()

/obj/item/pillow/attack(mob/living/carbon/target_mob, mob/living/user, params)
	. = ..()
	if(!iscarbon(target_mob))
		return
	playsound(user, 'sound/items/pillow_hit.ogg', 80) //the basic 50 vol is barely audible

/obj/item/pillow/examine_more(mob/user)
	. = ..()
	. += span_notice("Alt-click to remove the tag!")

/obj/item/pillow/AltClick(mob/user)
	. = ..()
	if(!pillow_trophy)
		balloon_alert(user, span_notice("no tag!"))
		return
	balloon_alert(user, span_notice("removing tag..."))
	if(!do_after(user, 2 SECONDS, src))
		return
	user.put_in_hands(pillow_trophy)
	balloon_alert(user, span_notice("tag removed"))
	pillow_trophy = null
	playsound(user,'sound/items/poster_ripped.ogg', 50)
	icon_state = "pillow_no_tag"
	desc = "A soft and fluffy pillow. This one seems to have its tag removed"
	