/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'


/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 0

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"


/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"