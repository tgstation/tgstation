
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
	var/last_fighter
	var/obj/item/trash/pillow_tag/pillow_trophy


/obj/item/pillow/Initialize(mapload)
	. = ..()
	if(!pillow_trophy)
		pillow_trophy = new(src)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 10, \
		force_wielded = 20, \
	)

/obj/item/pillow/Destroy(force)
	. = ..()
	pillow_trophy = null

/obj/item/pillow/attack(mob/living/carbon/target_mob, mob/living/user, params)
	. = ..()
	if(!iscarbon(target_mob))
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		user.apply_damage(10, STAMINA) // when hitting with such force we should prolly be getting tired too
	last_fighter = user
	playsound(user, 'sound/items/pillow_hit.ogg', 80) //the basic 50 vol is barely audible

/obj/item/pillow/examine(mob/user)
	. = ..()
	. += span_notice("<i>There's more information below, you can look again to take a closer look...</i>")

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
	if(last_fighter)
		pillow_trophy.desc = "a pillow tag taken from [last_fighter] after a gruesome pillow fight."
	user.put_in_hands(pillow_trophy)
	balloon_alert(user, span_notice("tag removed"))
	pillow_trophy = null
	playsound(user,'sound/items/poster_ripped.ogg', 50)
	icon_state = "pillow_no_tag"
	desc = "A soft and fluffy pillow. This one seems to have its tag removed"
	
