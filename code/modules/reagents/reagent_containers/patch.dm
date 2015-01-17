/obj/item/weapon/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 50
	apply_type = TOUCH
	apply_method = "apply"

/obj/item/weapon/reagent_containers/pill/patch/New()
	..()
	icon_state = "bandaid" // thanks inheritance

/obj/item/weapon/reagent_containers/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again

/obj/item/weapon/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!eater.SpeciesCanConsume())
		return 0
	return 1 // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/weapon/reagent_containers/pill/patch/styptic
	name = "styptic powder patch"
	desc = "Helps with brute injuries."

/obj/item/weapon/reagent_containers/pill/patch/styptic/New()
	..()
	reagents.add_reagent("styptic_powder", 25)

/obj/item/weapon/reagent_containers/pill/patch/silver_sulf
	name = "silver sulfadiazine patch"
	desc = "Helps with burn injuries."

/obj/item/weapon/reagent_containers/pill/patch/silver_sulf/New()
	..()
	reagents.add_reagent("silver_sulfadiazine", 25)