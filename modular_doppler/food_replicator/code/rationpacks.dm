/obj/item/food/colonial_course
	name = "undefined colonial course"
	desc = "Something you shouldn't see. But it's edible."
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	icon_state = "borgir"
	base_icon_state = "borgir"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20)
	tastes = list("crayon powder" = 1)
	foodtypes = VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	preserved_food = TRUE

/obj/item/food/colonial_course/attack_self(mob/user, modifiers)
	if(preserved_food)
		preserved_food = FALSE
		icon_state = "[base_icon_state]_unwrapped"
		to_chat(user, span_notice("You unpackage \the [src]."))
		playsound(user.loc, 'sound/items/foodcanopen.ogg', 50)

/obj/item/food/colonial_course/attack(mob/living/target, mob/user, def_zone)
	if(preserved_food)
		to_chat(user, span_warning("[src] is still packaged!"))
		return FALSE

	return ..()

/obj/item/food/colonial_course/pljeskavica
	name = "pljeskavica"
	desc = "Freshly-printed steaming hot burger consisting of a biogenerator-produced handcraft-imitating buns, with a minced meat patty inbetween, among various vegetables and sauces.\
		<br> Looks good <i>enough</i> for something as replicated as this. Its packaging is covered in copious amounts of information on its nutritional facts, contents and the expiry date. Sadly, it's all written in Pan-Slavic."
	trash_type = /obj/item/trash/pljeskavica
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("bun" = 2, "spiced meat" = 10, "death of veganism" = 3)
	foodtypes = VEGETABLES | GRAIN | MEAT

/obj/item/food/colonial_course/nachos
	name = "plain nachos tray"
	desc = "A vacuum-sealed package with what seems to be a generous serving of triangular corn chips, with three sections reserved for a salsa, cheese and guacamole sauces.\
		<br> Probably the best-looking food you can find in these rations, perhaps due to its simplicity."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	trash_type = /obj/item/trash/nachos
	icon_state = "nacho"
	base_icon_state = "nacho"
	tastes = list("corn chips" = 5, "'artificial' organic sauces" = 5)
	foodtypes = GRAIN | FRIED | DAIRY

/obj/item/food/colonial_course/blins
	name = "condensed milk crepes"
	desc = "A vacuum-sealed four-pack of stuffed crepes with a minimal amount of markings. There is nothing else to it, to be frank.\
		<br> Surprisingly tasty for its looks, as long as you're not lactose intolerant, on diet, or vegan. The back of the packaging is covered in a mass of information detailing the product."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/caramel = 3,
		/datum/reagent/consumable/milk = 4,
	)
	trash_type = /obj/item/trash/blins
	icon_state = "blin"
	base_icon_state = "blin"
	tastes = list("insane amount of sweetness" = 10, "crepes" = 3)
	foodtypes = SUGAR | GRAIN | DAIRY | BREAKFAST

/obj/item/reagent_containers/cup/glass/coffee/colonial
	name = "colonial thermocup"
	desc = "Technically, used to drink hot beverages. But since it's the only cup design that was available, you gotta make do. It has an instruction written on its side. \
	<br> This particular one comes prefilled with a single serving of coffee powder."
	special_desc = "A small instruction on the side reads: <i>\"For use in food replicators; mix water and powdered solutions in one-to-one proportions. \
	<br> For cocoa, mix milk and powdered solution in one-to-one proportion.\"</i>"
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	list_reagents = list(/datum/reagent/consumable/powdered_coffee = 25)

/obj/item/reagent_containers/cup/glass/coffee/colonial/empty
	desc = "Technically, used to drink hot beverages. But since it's the only cup design that was available, you gotta make do. It has an instruction written on its side."
	list_reagents = null

/obj/item/trash/pljeskavica
	name = "pljeskavica wrapping paper"
	desc = "Covered in sauce smearings and smaller pieces of the dish on the inside, crumpled into a ball. It's probably best to dispose of it."
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	icon_state = "borgir_trash"

/obj/item/trash/nachos
	name = "empty nachos tray"
	desc = "Covered in sauce smearings and smaller pieces of the dish on the inside, a plastic food tray with not much use anymore. It's probably best to dispose of it or recycle it."
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	custom_materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)
	icon_state = "nacho_trash"

/obj/item/trash/blins
	name = "empty crepes wrapper"
	desc = "Empty torn wrapper that used to hold something ridiculously sweet. It's probably best to recycle it."
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	custom_materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT * 0.5,
	)
	icon_state = "blin_trash"

/obj/item/storage/box/gum/colonial
	name = "mixed bubblegum packet"
	desc = "The packaging is entirely written in Pan-Slavic, with a small blurb of Sol Common. You would need to take a better look to read it, though, as it is written quite small."
	special_desc = "Examining the small text reveals the following: <i>\"Foreign colonization ration, model J: mixed origin, adult. Bubblegum package, medicinal, recreational. <br>\
		Do not overconsume. Certain strips contain nicotine.\"</i>"
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	icon_state = "bubblegum"

/obj/item/storage/box/gum/colonial/PopulateContents()
	new /obj/item/food/bubblegum(src)
	new /obj/item/food/bubblegum(src)
	new /obj/item/food/bubblegum/nicotine(src)
	new /obj/item/food/bubblegum/nicotine(src)

/obj/item/storage/box/utensils
	name = "utensils package"
	desc = "A small package containing various utensils required for <i>human</i> consumption of various foods. \
	In a normal situation contains a plastic fork, a plastic spoon, and two serviettes."
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	icon_state = "utensil_box"
	w_class = WEIGHT_CLASS_TINY
	illustration = null
	foldable_result = null

/obj/item/storage/box/utensils/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
		/obj/item/kitchen/spoon/plastic,
		/obj/item/kitchen/fork/plastic,
		/obj/item/serviette,
	))
	atom_storage.max_slots = 4

/obj/item/storage/box/utensils/PopulateContents()
	new /obj/item/kitchen/spoon/plastic(src)
	new /obj/item/kitchen/fork/plastic(src)
	new /obj/item/serviette(src)
	new /obj/item/serviette(src)

/obj/item/serviette
	name = "serviette"
	desc = "To clean all the mess. Comes with a custom <i>combined</i> design of red and blue."
	icon_state = "napkin_unused"
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	/// How much time it takes to clean something using it
	var/cleanspeed = 5 SECONDS
	/// Which item spawns after it's used
	var/used_serviette = /obj/item/serviette_used
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON

/obj/item/serviette_used
	name = "dirty napkin"
	desc = "No longer useful, super dirty, or soaked, or otherwise unrecognisable."
	icon_state = "napkin_used"
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'

/obj/item/storage/box/colonial_rations
	name = "foreign colonization ration"
	desc = "A freshly printed civilian MRE, or more specifically a lunchtime food package, for use in the early colonization times by the first settlers of what is now known as the NRI. <br>\
		The lack of any imprinted dates, as well as its origin, <i>the food replicator</i>, should probably give you a good enough hint at its short, if reasonable, expiry time."
	icon = 'modular_doppler/food_replicator/icons/rationpack.dmi'
	icon_state = "mre_package"
	foldable_result = null
	illustration = null

/obj/item/storage/box/colonial_rations/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6
	atom_storage.locked = TRUE

/obj/item/storage/box/colonial_rations/attack_self(mob/user, modifiers)
	if(user)
		if(atom_storage.locked == TRUE)
			atom_storage.locked = FALSE
			icon_state = "mre_package_open"
			balloon_alert(user, "unsealed!")
			return ..()
		else
			atom_storage.locked = TRUE
			atom_storage.close_all()
			icon_state = "mre_package"
			balloon_alert(user, "resealed!")
			return

/obj/item/storage/box/colonial_rations/PopulateContents()
	new /obj/item/food/colonial_course/pljeskavica(src)
	new /obj/item/food/colonial_course/nachos(src)
	new /obj/item/food/colonial_course/blins(src)
	new /obj/item/reagent_containers/cup/glass/coffee/colonial(src)
	new /obj/item/storage/box/gum/colonial(src)
	new /obj/item/storage/box/utensils(src)
