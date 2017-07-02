/obj/item/weapon/reagent_containers/syringe/stimulants/Initialize()
	. = ..()
	new /obj/item/weapon/reagent_containers/syringe/nanoboost(loc)
	if(!QDELETED(src))
		qdel(src)

/obj/item/weapon/reagent_containers/syringe/nanoboost
	name = "Nanobooster"
	desc = "Contains Nanomachines Son!."
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("syndicate_nanites" = 50)