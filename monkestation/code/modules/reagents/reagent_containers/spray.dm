/obj/item/reagent_containers/spray/gamerspray
	name = "Baja Blast Spray"
	volume = 50
	desc = "A sprayer of advanced Gamer Fuel, designed for rapid deployment during gaming sessions."
	list_reagents = list(/datum/reagent/consumable/baja_blast = 50)

/obj/item/reagent_containers/spray/chemsprayer/magical
	name = "Magical Chem Sprayer"
	desc = "Simply hit the button on the side and this will instantly be filled with a new reagent!"
	icon_state = "chemsprayer_janitor"
	item_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	volume = 1000
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/spray/chemsprayer/magical/attack_self(mob/user)
	cycle_chems()
	to_chat(user, "<span class='notice'>You change the reagent to [english_list(reagents.reagent_list)].</span>")
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/proc/cycle_chems()
	reagents.clear_reagents()
	list_reagents = list(get_unrestricted_random_reagent_id() = volume)
	reagents.add_reagent_list(list_reagents)
	return
