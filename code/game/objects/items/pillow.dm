
/obj/item/pillow 
	name = "pillow"
	desc = "A soft and fluffy pillow, you can smack people with this!"
	icon = 'icons/obj/pillow.dmi'
	icon_state = "pillow_with_tag"
	inhand_icon_state = "pillow"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/fluffy_dammage = 10
	var/pillow_trophy = new /obj/item/trash/pillow_tag()

/obj/item/pillow/attack(mob/living/carbon/target_mob, mob/living/user, params)
	. = ..()
	if(!iscarbon(target_mob))
		return
	target_mob.adjustStaminaLoss(fluffy_dammage) //gotta take down your opponent somehow
	playsound(user, 'sound/items/pillow_hit.ogg', 80) //the basic 50 vol is barely audible


/obj/item/pillow/AltClick(mob/user)
	. = ..()
	if(!pillow_trophy)
		balloon_alert(user, span_notice("there is no tag to remove."))
		return
	balloon_alert(user, span_notice("you attempt to remove the tag..."))
	if(!do_after(user, 2 SECONDS))
		return
	user.put_in_hands(pillow_trophy)
	pillow_trophy = null
	playsound(user,'sound/items/poster_ripped.ogg', 50)
	icon_state = "pillow_no_tag"
	desc = "A soft and fluffy pillow, this one seems to have its tag removed"
	