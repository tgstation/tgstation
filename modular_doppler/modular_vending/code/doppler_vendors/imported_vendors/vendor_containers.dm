/obj/item/storage/box/foodpack
	name = "wrapped meal container"
	desc = "A generic brown paper food package, you aren't quite sure where this comes from."
	icon = 'modular_doppler/modular_vending/icons/imported_quick_foods.dmi'
	icon_state = "foodpack_generic_big"
	illustration = null
	custom_price = PAYCHECK_CREW * 1.8
	///What the main course of this package is
	var/main_course = /obj/item/trash/empty_food_tray
	///What the side of this package should be
	var/side_item = /obj/item/food/vendor_snacks
	///What kind of condiment pack should we give the package
	var/condiment_pack = /obj/item/reagent_containers/condiment/pack/ketchup

/obj/item/storage/box/foodpack/PopulateContents()
	. = ..()
	new main_course(src)
	new side_item(src)
	new condiment_pack(src)

/obj/item/storage/box/foodpack/nt
	name = "\improper NT-Combo Meal - Salisbury Steak"
	desc = "A relatively bland package made of reflective metal foil, it has a blue sprite and the letters 'NT' printed on the top."
	icon_state = "foodpack_nt_big"
	main_course = /obj/item/food/vendor_tray_meal
	side_item = /obj/effect/spawner/random/vendor_meal_sides/nt
	condiment_pack = /obj/item/reagent_containers/condiment/pack/ketchup

/obj/item/storage/box/foodpack/nt/burger
	name = "\improper NT-Combo Meal - Cheeseburger"
	main_course = /obj/item/food/vendor_tray_meal/burger

/obj/item/storage/box/foodpack/nt/chicken_sammy
	name = "\improper NT-Combo Meal - Spicy Chicken Sandwich"
	main_course = /obj/item/food/vendor_tray_meal/chicken_sandwich

/obj/item/storage/box/foodpack/moth
	name = "\improper Ration Type M - Pesto Pizza"
	desc = "A cardboard-colored paper package with the symbol of the nomad fleet stamped upon it."
	icon_state = "foodpack_moth_big"
	main_course = /obj/item/food/vendor_tray_meal/pesto_pizza
	side_item = /obj/effect/spawner/random/vendor_meal_sides/moth
	condiment_pack = /obj/item/reagent_containers/condiment/pack/astrotame

/obj/item/storage/box/foodpack/moth/baked_rice
	name = "\improper Ration Type M - Baked Rice and Grilled Cheese"
	main_course = /obj/item/food/vendor_tray_meal/baked_rice

/obj/item/storage/box/foodpack/moth/fuel_jack
	name = "\improper Ration Type M - Fueljack's Feast"
	main_course = /obj/item/food/vendor_tray_meal/fueljack

/obj/item/storage/box/foodpack/tizira
	name = "\improper Tizira Imports Pack - Moonfish Nizaya"
	desc = "A dull, metal foil package with the colors of the Tiziran flag striped across it, as well as a stamp of legitimate origin from the Tiziran exports office."
	icon_state = "foodpack_tizira_big"
	main_course = /obj/item/food/vendor_tray_meal/moonfish_nizaya
	side_item = /obj/effect/spawner/random/vendor_meal_sides/tizira
	condiment_pack = /obj/item/reagent_containers/condiment/pack/bbqsauce
	custom_price = PAYCHECK_CREW * 2 //Tiziran imports are a bit more expensive

/obj/item/storage/box/foodpack/tizira/examine_more(mob/user)
	. = ..()
	. += span_notice("<b>Now that you look at it, the origin stamp appears to be a poor imitation of the real thing!</b>")
	return .

/obj/item/storage/box/foodpack/tizira/roll
	name = "\improper Tizira Imports Pack - Emperor Roll"
	main_course = /obj/item/food/vendor_tray_meal/emperor_roll

/obj/item/storage/box/foodpack/tizira/stir_fry
	name = "\improper Tizira Imports Pack - Mushroom Stirfry"
	main_course = /obj/item/food/vendor_tray_meal/mushroom_fry

/obj/item/storage/box/foodpack/marsian
	name = "\improper Marsian MEGA-Meal: Mi Goreng Shanjing"
	desc = "Orange metallicized plastic is emblazoned with the blue heraldry of the Marsian flag."
	icon_state = "foodpack_marsian_big"
	main_course = /obj/item/food/vendor_tray_meal/mi_goreng
	side_item = /obj/effect/spawner/random/vendor_meal_sides/marsian
	condiment_pack = /obj/item/reagent_containers/condiment/pack/chili

/obj/item/storage/box/foodpack/marsian/burger_blind_bag
	name = "\improper Marsian MEGA-Meal: Big Blue Burger Blind Bag"
	desc = "The top selling burger chain on Mars, now in ready-to-eat format. One mystery burger inside, certified mothroach-free after a costly lawsuit!"
	main_course = /obj/effect/spawner/random/vendor_tray_meal/burger_blind_bag
	condiment_pack = /obj/item/reagent_containers/condiment/pack/bbqsauce

/obj/item/storage/box/foodpack/marsian/duck_crepe
	name = "\improper Marsian MEGA-Meal: Peking duck crepes a l'orange"
	main_course = /obj/item/food/vendor_tray_meal/duck_crepe
	condiment_pack = /obj/item/reagent_containers/condiment/pack/soysauce

/obj/item/storage/box/foodpack/marsian/sushi
	name = "\improper Marsian MEGA-Meal: Carp Sushi Rolls"
	main_course = /obj/item/food/vendor_tray_meal/sushi
	condiment_pack = /obj/item/reagent_containers/condiment/pack/soysauce

/obj/item/storage/box/foodpack/marsian/beef_rice
	name = "\improper Marsian MEGA-Meal: Beef and Rice"
	main_course = /obj/item/food/vendor_tray_meal/beef_rice
	condiment_pack = /obj/item/reagent_containers/condiment/pack/hotsauce
