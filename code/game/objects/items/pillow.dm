
/obj/item/pillow 
	name = "pillow"
	desc = "A soft and fluffy pillow. You can smack someone with this!"
	icon = 'icons/obj/pillow.dmi'
	icon_state = "pillow_with_tag"
	inhand_icon_state = "pillow"
	lefthand_file = 'icons/mob/inhands/items/pillow_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/pillow_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	damtype = STAMINA
	var/last_fighter
	var/obj/item/trash/pillow_tag/pillow_trophy


/obj/item/pillow/Initialize(mapload)
	. = ..()
	if(!pillow_trophy)
		pillow_trophy = new(src)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 5, \
		force_wielded = 10, \
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
	
/obj/item/clothing/suit/pillow_suit
	name = "pillow suit"
	desc = "Part man, part pillow. All CARNAGE!"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	cold_protection = CHEST|GROIN|ARMS|LEGS //a pillow suit must be hella warm
	allowed = list(/obj/item/pillow) //moar pillow carnage 
	icon = 'icons/obj/pillow.dmi'
	worn_icon = 'icons/mob/clothing/suits/pillow.dmi'
	icon_state = "pillow_suit"
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 75) //fluffy amor


/obj/item/clothing/head/pillow_hood
	name = "pillow hood"
	desc = "The final piece of the pillow juggernaut"
	body_parts_covered = HEAD
	icon = 'icons/obj/pillow.dmi'
	worn_icon = 'icons/mob/clothing/suits/pillow.dmi'
	icon_state = "pillowcase_hat"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 75) //fluffy amor
