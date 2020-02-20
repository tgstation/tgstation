///Holds a biological sample which can then be put into the growing vat
/obj/item/petri_dish
	name = "petri dish"
	desc = "This makes you feel well-cultured."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	///The sample stored on the dish
	var/datum/biological_sample/sample

/obj/item/petri_dish/deposit_sample(user, /datum/biological_sample/sample)
	src.sample = sample
	to_chat(user, "<span class='notice'>You deposit [sample] into [src].</span>")
	update_icon()
