/obj/item/card_trimmer
	name = "card trimmer"
	desc = "A device that can replace the trim of Nanotrasen cards, changing its predefined access slots."
	icon = 'icons/obj/device.dmi'
	icon_state = "card_trimmer"
	w_class = WEIGHT_CLASS_SMALL

	var/selected_trim = NONE
	var/list/valid_trims = list(TRIM_SERVICE, TRIM_SECURITY, TRIM_MEDICAL, TRIM_SCIENCE, TRIM_ENGINEERING, TRIM_SUPPLY, TRIM_COMMAND)

/obj/item/card_trimmer/attack_self(mob/user)
	var/list/options = new/list()
		options["None"] = NONE // get_region_accesses_name returns "all" for NONE, which doesn't make sense in this context
	for(var/trim in valid_trims)
		options["[get_region_accesses_name(trim)]"] = trim // So they show up as the region name, not the define number.
	var/choice = input(user, "Select a Trim", "Card Trimmer", NONE) as null|anything in options
	selected_trim = options[choice]
	return

/obj/item/card_trimmer/attackby(obj/item/C, mob/user, params)
	if(istype(C, /obj/item/card/id))
		trim_card(C, user)
	return

/obj/item/card_trimmer/proc/trim_card(obj/item/card/id/C, mob/user)
	user.visible_message("<span class='notice'>[user] starts to trim the [C] using the card trimmer.</span>", "<span class='notice'>You trim the [C] using the card trimmer.</span>")
	playsound(user, 'sound/items/poster_being_created.ogg', 20, TRUE)
	if(do_after(user, 5 SECONDS, target=C))
		C.access -= get_region_accesses(C.trim) // so you can't exploit changing trim to give accesses.
		C.trim = selected_trim
		C.update_label()
	return

/obj/item/card_trimmer/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to trim [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS
