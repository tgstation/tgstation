/////////////
//BUBBLEGUM//
/////////////
/obj/item/clothing/mask/bubblegum
	name = "bubblegum"
	desc = "Self-inflating bubblegum. Very sweet."
	icon_state = "bubblegum"
	throw_speed = 0.5
	w_class = 1
	body_parts_covered = null
	flags = MASKCOVERSMOUTH
	flags_inv = HIDEMASK

/obj/item/clothing/mask/bubblegum/attack(mob/M, mob/user, def_zone) //try to be like a snack
	if(M==user)
		if(!mob_can_equip(M, slot_wear_mask, 1))
			if(iscarbon(M))
				var/mob/living/carbon/H=M
				H<<"<span class='notice'>Remove your [H.wear_mask.name] first!</span>"
			else
				M<<"<span class='notice'>You are unable to chew the bubblegum right now.</span>"
			return
		M.equip_to_slot_if_possible(src, slot_wear_mask, 0, 1, 1)
	else
		M.visible_message("<span class='danger'>[user] attempts to feed [M] [src].</span>", \
						"<span class='userdanger'>[user] attempts to feed [M] [src].</span>")
		if(do_mob(user, M))
			if(mob_can_equip(M, slot_wear_mask))
				user.u_equip(src)
				M.equip_to_slot(src, slot_wear_mask)
				M.visible_message("<span class='danger'>[user] forces [M] to eat [src].</span>", \
						"<span class='userdanger'>[user] forces [M] to eat [src].</span>")
			else
				user<<"<span class='notice'>You are unable to feed the bubblegum to [M].</span>"


/obj/item/clothing/mask/bubblegum/equipped(mob/user, slot)
	if(slot==slot_wear_mask)
		user << "<span class='notice'>You start chewing on [src].</span>"
		desc="Bubblegum that someone has been chewing on. Fairly disgusting."


/////////////////////
//WRAPPED BUBBLEGUM//
/////////////////////
/obj/item/weapon/reagent_containers/food/snacks/bubblegum
	name = "chewpack - a chewing gum"
	desc = "Self-inflating bubblegum. Very sweet."
	icon_state = "bubblegum"
	trash = /obj/item/clothing/mask/bubblegum
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/bubblegum/New()
	..()
	reagents.add_reagent("sugar", 4)

/obj/item/weapon/reagent_containers/food/snacks/bubblegum/attack_self(mob/user)
	user<<"<span class='notice'>You rip the foil off the bubblegum.</span>"
	reagents.total_volume=null
	On_Consume()

