/obj/structure/organ_creator
	name = "all in one organic medical fabricator"
	desc = "Capable of making all organs and bodyparts needed for practitioners to fix up bodies."


	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE

	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"



/obj/structure/organ_creator/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/list/all_internals = subtypesof(/obj/item/organ/internal) - typesof(/obj/item/organ/internal/zombie_infection) - typesof(/obj/item/organ/internal/alien) - typesof(/obj/item/organ/internal/body_egg) - typesof(/obj/item/organ/internal/heart/gland) - /obj/item/organ/internal/butt/atomic - typesof(/obj/item/organ/internal/alien) - /obj/item/organ/internal/borer_body - /obj/item/organ/internal/empowered_borer_egg // bit long aint it
	var/list/all_externals = subtypesof(/obj/item/organ/external)

	var/list/all_bodyparts = subtypesof(/obj/item/bodypart)

	var/choice = tgui_input_list(user, "What do you wish to fabricate?", "[src.name]", list("External Organs", "Internal Organs", "Bodyparts"))
	if(!choice)
		return
	var/list/choice_list
	switch(choice)
		if("External Organs")
			choice_list = all_externals
		if("Internal Organs")
			choice_list = all_internals
		else
			choice_list = all_bodyparts

	var/atom/second_choice = tgui_input_list(user, "Choose what to fabricate", "[choice]", choice_list)

	new second_choice(get_turf(src))
	say("Organic Matter Fabricated")
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)


/obj/structure/organ_creator/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/organ) || !istype(attacking_item, /obj/item/bodypart))
		return
	if(istype(attacking_item, /obj/item/organ/internal/brain))
		return
	qdel(attacking_item)
	say("Organic Matter Reclaimed")
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
