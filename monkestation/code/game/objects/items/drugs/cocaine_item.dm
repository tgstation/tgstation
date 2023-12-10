/obj/item/reagent_containers/crack
	name = "crack"
	desc = "A rock of freebase cocaine, otherwise known as crack."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	icon_state = "crack"
	volume = 10
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 10)

/obj/item/reagent_containers/crackbrick
	name = "crack brick"
	desc = "A brick of crack cocaine. Looks like you'd need something sharp to cut it..."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	icon_state = "crackbrick"
	volume = 40
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 40)
	possible_transfer_amounts = list()

/obj/item/reagent_containers/crackbrick/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		user.show_message(span_notice("You cut [src] into some rocks."), MSG_VISUAL)
		for(var/i in 1 to 4)
			new /obj/item/reagent_containers/crack(user.loc)
		qdel(src)

/datum/crafting_recipe/crackbrick
	name = "Crack brick"
	result = /obj/item/reagent_containers/crackbrick
	reqs = list(/obj/item/reagent_containers/crack = 4)
	parts = list(/obj/item/reagent_containers/crack = 4)
	time = 2 SECONDS
	category = CAT_CHEMISTRY //i might just make a crafting category for drugs at some point

// Should probably give this the edible component at some point
/obj/item/reagent_containers/cocaine
	name = "cocaine"
	desc = "Reenact your favorite scenes from Scarface!"
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	icon_state = "cocaine"
	volume = 5
	list_reagents = list(/datum/reagent/drug/cocaine = 5)

/obj/item/reagent_containers/cocaine/proc/snort(mob/living/user)
	if(!iscarbon(user))
		return

	var/covered = ""
	if(user.is_mouth_covered(ITEM_SLOT_HEAD))
		covered = "headgear"
	else if(user.is_mouth_covered(ITEM_SLOT_MASK))
		covered = "mask"
	if(covered)
		to_chat(user, span_warning("You have to remove your [covered] first!"))
		return

	user.visible_message(span_notice("'[user] starts snorting [src]."), span_notice("You start snorting [src]..."))
	if(!do_after(user, 3 SECONDS))
		return

	to_chat(user, span_notice("You finish snorting [src]."))
	if(reagents.total_volume)
		reagents.trans_to(user, reagents.total_volume, transfered_by = user, methods = INGEST)
	qdel(src)

/obj/item/reagent_containers/cocaine/attack(mob/target, mob/user)
	if(target == user)
		snort(user)

/obj/item/reagent_containers/cocaine/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!in_range(user, src) || user.get_active_held_item())
		return

	snort(user)

/obj/item/reagent_containers/cocainebrick
	name = "cocaine brick"
	desc = "A brick of cocaine. Good for transport! It'd probably break apart in your hands if you tried hard enough."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	icon_state = "cocainebrick"
	volume = 25
	list_reagents = list(/datum/reagent/drug/cocaine = 25)
	possible_transfer_amounts = list()


/obj/item/reagent_containers/cocainebrick/attack_self(mob/user)
	user.visible_message(span_notice("[user] starts breaking up [src]."), span_notice("You begin breaking up [src]..."))
	if(!do_after(user, 1 SECONDS))
		return
	to_chat(user, span_notice("You finish breaking up [src]."))
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/cocaine(user.loc)
	qdel(src)

/datum/crafting_recipe/cocainebrick
	name = "Cocaine brick"
	result = /obj/item/reagent_containers/cocainebrick
	reqs = list(/obj/item/reagent_containers/cocaine = 5)
	parts = list(/obj/item/reagent_containers/cocaine = 5)
	time = 2 SECONDS
	category = CAT_CHEMISTRY //i might just make a crafting category for drugs at some point

//if you want money, convert it into crackbricks
/datum/export/crack
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "crack"
	export_types = list(/obj/item/reagent_containers/crack)
	include_subtypes = FALSE

/datum/export/crack/crackbrick
	cost = CARGO_CRATE_VALUE * 2.5
	unit_name = "crack brick"
	export_types = list(/obj/item/reagent_containers/crackbrick)
	include_subtypes = FALSE

/datum/export/cocaine
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "cocaine"
	export_types = list(/obj/item/reagent_containers/cocaine)
	include_subtypes = FALSE

/datum/export/cocainebrick
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "cocaine brick"
	export_types = list(/obj/item/reagent_containers/cocainebrick)
	include_subtypes = FALSE

/obj/item/seeds/cocaleaf
	name = "pack of coca leaf seeds"
	desc = "These seeds grow into coca shrubs. They make you feel energized just looking at them..."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	growing_icon = 'monkestation/icons/obj/hydroponics/growing.dmi'
	icon_state = "seed-cocaleaf"
	species = "cocaleaf"
	plantname = "Coca Leaves"
	icon_grow = "cocaleaf-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "cocaleaf-dead" // Same for the dead icon
	maturation = 8
	potency = 20
	growthstages = 1
	product = /obj/item/food/grown/cocaleaf
	possible_mutations = list()
	reagents_add = list(/datum/reagent/drug/cocaine = 0.3, /datum/reagent/consumable/nutriment = 0.15)

/obj/item/food/grown/cocaleaf
	seed = /obj/item/seeds/cocaleaf
	name = "coca leaf"
	desc = "A leaf of the coca shrub, which contains a potent psychoactive alkaloid known as 'cocaine'."
	icon = 'monkestation/icons/obj/hydroponics/harvest.dmi'
	icon_state = "cocaleaf"
	foodtypes = FRUIT //i guess? i mean it grows on trees...
	tastes = list("leaves" = 1)
