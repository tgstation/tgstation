/obj/item/reagent_containers/crack
	name = "crack"
	desc = "Порция курительного кокаина, также известного как крэк."
	icon = 'modular_bandastation/objects/icons/obj/items/drugs.dmi'
	icon_state = "crack"
	volume = 10
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 10)

/obj/item/reagent_containers/crackbrick
	name = "crack brick"
	desc = "Брикет крэка. Похоже, тебе понадобится что-то острое, чтобы разрезать его..."
	icon = 'modular_bandastation/objects/icons/obj/items/drugs.dmi'
	icon_state = "crackbrick"
	volume = 40
	list_reagents = list(/datum/reagent/drug/cocaine/freebase_cocaine = 40)

/obj/item/reagent_containers/crackbrick/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		user.show_message(span_notice("Вы разрезали [src] на несколько кусков."), MSG_VISUAL)
		for(var/i in 1 to 4)
			new /obj/item/reagent_containers/crack(user.loc)
		qdel(src)

/datum/crafting_recipe/crackbrick
	name = "Crack brick"
	result = /obj/item/reagent_containers/crackbrick
	reqs = list(/obj/item/reagent_containers/crack = 4)
	parts = list(/obj/item/reagent_containers/crack = 4)
	time = 2 SECONDS
	category = CAT_CHEMISTRY

/obj/item/reagent_containers/cocaine
	name = "cocaine"
	desc = "Всеми печально известный белый порошок"
	icon = 'modular_bandastation/objects/icons/obj/items/drugs.dmi'
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
		to_chat(user, span_warning("Сначала вам нужно снять [covered]!"))
		return

	user.visible_message(span_notice("'[user] начинает внюхивать [src]."), span_notice("Вы начинаете внюхивать [src]..."))
	if(!do_after(user, 3 SECONDS))
		return

	to_chat(user, span_notice("Ты закончил внюхивать [src]."))
	if(reagents.total_volume)
		reagents.trans_to(user, reagents.total_volume, transferred_by = user, methods = INGEST)
	playsound(src,'modular_bandastation/objects/code/items/chems/sound/drugs_sniff.ogg',15,TRUE)
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

/obj/item/reagent_containers/cocaine/attack_self(mob/user)
	user.visible_message(span_notice("[user] начинает делить [src]."), span_notice("Ты начинаешь делить [src]..."))
	if(!do_after(user, 1 SECONDS))
		return
	to_chat(user, span_notice("Ты закончил делить [src]."))
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/cocaine_small(user.loc)
	qdel(src)

/datum/crafting_recipe/cocaine
	name = "Cocaine road"
	result = /obj/item/reagent_containers/cocaine
	reqs = list(/obj/item/reagent_containers/cocaine_small = 5)
	parts = list(/obj/item/reagent_containers/cocaine_small = 5)
	time = 2 SECONDS
	category = CAT_CHEMISTRY

/obj/item/reagent_containers/cocaine_small
	name = "cocaine road"
	desc = "Небольшая порция кокаина в виде дорожки."
	icon = 'modular_bandastation/objects/icons/obj/items/drugs.dmi'
	icon_state = "coca_road"
	volume = 1
	list_reagents = list(/datum/reagent/drug/cocaine = 1)
//копипаст кода занюха, ибо наследственная дорожка позволяет делать дюп
/obj/item/reagent_containers/cocaine_small/proc/snort(mob/living/user)
	if(!iscarbon(user))
		return

	var/covered = ""
	if(user.is_mouth_covered(ITEM_SLOT_HEAD))
		covered = "headgear"
	else if(user.is_mouth_covered(ITEM_SLOT_MASK))
		covered = "mask"
	if(covered)
		to_chat(user, span_warning("Сначала вам нужно снять [covered]!"))
		return

	user.visible_message(span_notice("'[user] начинает внюхивать [src]."), span_notice("Вы начинаете внюхивать [src]..."))
	if(!do_after(user, 3 SECONDS))
		return

	to_chat(user, span_notice("Ты закончил внюхивать [src]."))
	if(reagents.total_volume)
		reagents.trans_to(user, reagents.total_volume, transferred_by = user, methods = INGEST)
	playsound(src,'modular_bandastation/objects/code/items/chems/sound/drugs_sniff.ogg',15,TRUE)
	qdel(src)

/obj/item/reagent_containers/cocaine_small/attack(mob/target, mob/user)
	if(target == user)
		snort(user)

/obj/item/reagent_containers/cocaine_small/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!in_range(user, src) || user.get_active_held_item())
		return

	snort(user)

/obj/item/reagent_containers/cocainebrick
	name = "cocaine brick"
	desc = "Брикет кокаина. Удобен для транспортировки! Он вероятней всего развалился бы у вас в руках, если бы вы хорошенько постарались."
	icon = 'modular_bandastation/objects/icons/obj/items/drugs.dmi'
	icon_state = "cocainebrick"
	volume = 25
	list_reagents = list(/datum/reagent/drug/cocaine = 25)

/obj/item/reagent_containers/cocainebrick/attack_self(mob/user)
	user.visible_message(span_notice("[user] начинает ломать [src]."), span_notice("Ты начинаешь ломать [src]..."))
	if(!do_after(user, 1 SECONDS))
		return
	to_chat(user, span_notice("Ты закончил ломать [src]."))
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/cocaine(user.loc)
	qdel(src)

/datum/crafting_recipe/cocainebrick
	name = "Cocaine brick"
	result = /obj/item/reagent_containers/cocainebrick
	reqs = list(/obj/item/reagent_containers/cocaine = 5)
	parts = list(/obj/item/reagent_containers/cocaine = 5)
	time = 2 SECONDS
	category = CAT_CHEMISTRY

/obj/item/seeds/cocaleaf
	name = "pack of coca leaf seeds"
	desc = "Из этих семян вырастают кусты коки. При одном взгляде на них вы чувствуете прилив сил..."
	icon = 'modular_bandastation/objects/icons/obj/items/drugs.dmi'
	growing_icon = 'modular_bandastation/objects/icons/obj/hydroponics/growing.dmi'
	icon_state = "seed-cocaleaf"
	species = "cocaleaf"
	plantname = "Coca Leaves"
	icon_grow = "cocaleaf-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "cocaleaf-dead" // Same for the dead icon
	maturation = 8
	potency = 20
	growthstages = 1
	product = /obj/item/food/grown/cocaleaf
	mutatelist = list()
	reagents_add = list(/datum/reagent/drug/cocaine = 0.3, /datum/reagent/consumable/nutriment = 0.15)

/obj/item/food/grown/cocaleaf
	seed = /obj/item/seeds/cocaleaf
	name = "coca leaf"
	desc = "Лист куста коки, который содержит мощный психоактивный алкалоид, известный как 'кокаин'."
	icon = 'modular_bandastation/objects/icons/obj/hydroponics/harvest.dmi'
	icon_state = "cocaleaf"
	foodtypes = FRUIT
	tastes = list("leaves" = 1)
