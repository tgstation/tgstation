/obj/item/stack/red_telecrystal
	name = "red telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
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
				to_chat(user, "<span class='notice'>You press [src] onto yourself and charge your hidden uplink.</span>")


/obj/item/stack/red_telecrystal/five
	amount = 5

/obj/item/stack/red_telecrystal/twenty
	amount = 20
