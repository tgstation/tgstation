/obj/structure/reagent_dispensers/water_cooler/gay
    name = "gay water cooler"
    desc = "A machine that dispenses gay liquid to drink."
    icon = 'troutstation/icons/obj/machines/vending.dmi'
    icon_state = "gaywater_cooler"
    anchored = FALSE
    reagent_id = /datum/reagent/consumable/gaywater

/obj/structure/reagent_dispensers/water_cooler/gay/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	playsound(get_turf(user), 'troutstation/sound/misc/spare.ogg', 100, TRUE)
