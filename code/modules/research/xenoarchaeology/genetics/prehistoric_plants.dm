/obj/item/weapon/reagent_containers/food/snacks/grown/telriis_clump
	name = "telriis grass"
	desc = "A clump of telriis grass, not recommended for consumption by sentients."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "telriisclump"
	New(var/loc, var/potency)
		..()
		reagents.add_reagent("pwine", potency * 5)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/thaadrabloom
	name = "thaa'dra bloom"
	desc = "Looks chewy, might be good to eat."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "thaadrabloom"
	New(var/loc, var/potency)
		..()
		reagents.add_reagent("frostoil", potency * 1.5 + 5)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/jurlmah
	name = "jurl'mah pod"
	desc = "Bulbous and veiny, it appears to pulse slightly as you look at it."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "jurlmahpod"
	New(var/loc, var/potency)
		..()
		reagents.add_reagent("serotrotium", potency)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/amauri
	name = "amauri fruit"
	desc = "It is small, round and hard. Its skin is a thick dark purple."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "amaurifruit"
	New(var/loc, var/potency)
		..()
		reagents.add_reagent("zombiepowder", potency * 10)
		reagents.add_reagent("condensedcapsaicin", potency * 5)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/gelthi
	name = "gelthi berries"
	desc = "They feel fluffy and slightly warm to the touch."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "gelthiberries"
	New(var/loc, var/potency)
		..()
		//this may prove a little strong
		reagents.add_reagent("stoxin", (potency * potency) / 5)
		reagents.add_reagent("capsaicin", (potency * potency) / 5)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/vale
	name = "vale leaves"
	desc = "Small, curly leaves covered in a soft pale fur."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "valeleaves"
	New(var/loc, var/potency)
		..()
		reagents.add_reagent("paracetamol", potency * 5)
		reagents.add_reagent("dexalin", potency * 2)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/surik
	name = "surik fruit"
	desc = "Multiple layers of blue skin peeling away to reveal a spongey core, vaguely resembling an ear."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "surikfruit"
	New(var/loc, var/potency)
		..()
		reagents.add_reagent("impedrezene", potency * 3)
		reagents.add_reagent("synaptizine", potency * 2)
		reagents.add_reagent("nutriment", potency)
		bitesize = 1+round(reagents.total_volume / 2, 1)