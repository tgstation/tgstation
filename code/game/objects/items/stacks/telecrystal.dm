/obj/item/stack/red_telecrystal
	name = "red telecrystal"
	desc = "A beautiful, rare crystal used to make illicit purchases. Its red glint gives you a feeling of guile and subterfuge."
	singular_name = "red telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "red telecrystal"
	dye_color = DYE_SYNDICATE
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/red_telecrystal

/obj/item/stack/red_telecrystal/attack(mob/target, mob/user)
	if(target != user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		return ..()
	for(var/obj/item/implant/uplink/I in target)
		if(I?.imp_in)
			var/datum/component/uplink/hidden_uplink = I.GetComponent(/datum/component/uplink)
			if(hidden_uplink)
				hidden_uplink.red_telecrystals += amount
				use(amount)
				to_chat(user, span_notice("You press [src] onto yourself and charge your hidden uplink."))


/obj/item/stack/red_telecrystal/five
	amount = 5

/obj/item/stack/red_telecrystal/twenty
	amount = 20

/obj/item/stack/black_telecrystal
	name = "black telecrystal"
	desc = "A beautiful, rare crystal used to make illicit purchases. Its black gleam gives you a feeling of malevolence."
	singular_name = "black telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "red telecrystal"
	dye_color = DYE_SYNDICATE
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/black_telecrystal

/obj/item/stack/black_telecrystal/attack(mob/target, mob/user)
	if(target != user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		return ..()
	for(var/obj/item/implant/uplink/implant in target)
		if(implant?.imp_in)
			var/datum/component/uplink/hidden_uplink = implant.GetComponent(/datum/component/uplink)
			if(hidden_uplink)
				hidden_uplink.black_telecrystals += amount
				use(amount)
				to_chat(user, span_notice("You press [src] onto yourself and charge your hidden uplink."))

/obj/item/stack/black_telecrystal/five
	amount = 5

/obj/item/stack/black_telecrystal/twenty
	amount = 20
