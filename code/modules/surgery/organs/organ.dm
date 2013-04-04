/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'


/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"


/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 1

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"

/obj/item/organ/aclaws
	name = "alien claws"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	origin_tech = "biotech=6"

/obj/item/organ/avein
	name = "alien tail vein"
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"
	origin_tech = "biotech=6"

/obj/item/organ/achitin
	name = "alien chitin"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	origin_tech = "biotech=6"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm