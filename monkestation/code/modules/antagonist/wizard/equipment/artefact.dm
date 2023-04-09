
//magical chem sprayer
/obj/item/reagent_containers/spray/chemsprayer/magical
	name = "Magical Chem Sprayer"
	desc = "Simply hit the button on the side and this will instantly be filled with a new reagent! Warning: User not immune to effects."
	icon_state = "chemsprayer_janitor"
	inhand_icon_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	volume = 1200
	possible_transfer_amounts = list() //we dont want this to change transfer amounts

/obj/item/reagent_containers/spray/chemsprayer/magical/attack_self(mob/user)
	cycle_chems() //does this even need to be a proc
	. = ..()
	balloon_alert(user, "You change the reagent to [english_list(reagents.reagent_list)].")
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/examine()
	. = ..()
	. += "It currently holds [english_list(reagents.reagent_list)]."
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/proc/cycle_chems()
	reagents.clear_reagents()
	list_reagents = list(get_random_reagent_id_unrestricted() = volume)
	reagents.add_reagent_list(list_reagents)
	return
