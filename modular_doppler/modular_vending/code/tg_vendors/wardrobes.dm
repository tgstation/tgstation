/obj/machinery/vending/wardrobe/medi_wardrobe
	products_doppler = list(
		/obj/item/radio/headset/headset_med = 3,
		/obj/item/clothing/gloves/latex/nitrile = 2,
		/obj/item/clothing/suit/toggle/labcoat/hospitalgown = 5,
		/obj/item/storage/belt/med_bandolier = 2,
		/obj/item/clothing/suit/jacket/doppler/departmental_jacket/med = 2,
		/obj/item/clothing/suit/toggle/labcoat/medical = 6,
		/obj/item/clothing/shoes/medical = 6,
		/obj/item/clothing/under/rank/medical/scrubs/skirt = 6,
		/obj/item/clothing/under/rank/medical/scrubs/skirt/green = 6,
		/obj/item/clothing/under/rank/medical/scrubs/skirt/purple = 6,
	)
	excluded_products = list(
		/obj/item/clothing/shoes/sneakers/blue = 4,
	)
	contraband_doppler = list(
		/obj/item/clothing/suit/toggle/labcoat/medical/unbuttoned = 6,
	)

/obj/machinery/vending/wardrobe/jani_wardrobe
	products_doppler = list(
		/obj/item/clothing/head/hats/janitor_doppler = 3,
		/obj/item/clothing/shoes/galoshes/doppler = 2,
		/obj/item/clothing/gloves/botanic_leather/janitor = 3,
		/obj/item/clothing/suit/apron/janitor_cloak = 3,
		/obj/item/clothing/under/rank/civilian/janitor/doppler = 3,
		/obj/item/clothing/under/rank/civilian/janitor/doppler_ct = 3,
	)

/obj/machinery/vending/wardrobe/engi_wardrobe
	products_doppler = list(
		/obj/item/clothing/under/misc/doppler_uniform/engineering = 5,
		/obj/item/radio/headset/headset_eng = 3,
		/obj/item/clothing/under/misc/overalls = 3,
		/obj/item/clothing/suit/jacket/doppler/departmental_jacket/engi = 3,
		/obj/item/clothing/head/utility/hardhat/orange = 2,
		/obj/item/clothing/head/utility/hardhat/welding/orange = 2,
		/obj/item/clothing/head/utility/hardhat/dblue = 2,
		/obj/item/clothing/head/utility/hardhat/welding/dblue = 2,
		/obj/item/clothing/head/utility/hardhat/red = 2,
	)

/obj/machinery/vending/wardrobe/atmos_wardrobe
	products_doppler = list(
		/obj/item/clothing/glasses/meson/engine = 2,
		/obj/item/clothing/head/beret/atmos = 4,
	)

/obj/machinery/vending/wardrobe/cargo_wardrobe
	products_doppler = list(
		/obj/item/clothing/suit/jacket/doppler/departmental_jacket/supply = 3,
		/obj/item/clothing/under/misc/doppler_uniform/cargo = 5,
	)

/obj/machinery/vending/wardrobe/robo_wardrobe
	products_doppler = list(
		/obj/item/clothing/head/beret/science/fancy/robo = 2,
		/obj/item/tank/internals/anesthetic = 2,
		/obj/item/clothing/mask/breath = 2,
		/obj/item/reagent_containers/cup/bottle/morphine = 2,
		/obj/item/reagent_containers/syringe = 2,
//		/obj/item/reagent_containers/spray/hercuri/chilled = 2,
//		/obj/item/reagent_containers/spray/dinitrogen_plasmide = 2,
		/obj/item/clothing/gloves/color/black = 2, // fire resistant, allows the robo to painlessly mold metal. also it's down here because it's a treatment item
		/obj/item/bonesetter = 2, // for dislocations
		/obj/item/stack/medical/gauze = 4, // for ALL wounds
		/obj/item/healthanalyzer/simple = 2,
		/obj/item/storage/backpack/custom = 2,
		/obj/item/storage/backpack/satchel/custom = 2,
		/obj/item/storage/backpack/duffelbag/custom = 2,
	)

/obj/machinery/vending/wardrobe/science_wardrobe
	products_doppler = list(
		/obj/item/clothing/under/misc/doppler_uniform/science = 5,
		/obj/item/clothing/suit/jacket/doppler/departmental_jacket/sci = 3,
	)

/obj/machinery/vending/wardrobe/sec_wardrobe
	products_doppler = list(
		/obj/item/clothing/under/misc/doppler_uniform/security = 5,
		/obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec = 3,
	)


/*/obj/machinery/vending/wardrobe/hydro_wardrobe
	products_doppler = list(
	)	*/

/*/obj/machinery/vending/wardrobe/bar_wardrobe
	products_doppler = list(
	)	*/

/obj/machinery/vending/wardrobe/chap_wardrobe
	products_doppler = list(
		/obj/item/clothing/suit/costume/nemes = 1,
		/obj/item/clothing/head/costume/nemes = 1,
		/obj/item/clothing/head/costume/pharaoh = 1,
	)

/obj/machinery/vending/wardrobe/chef_wardrobe
	products_doppler = list(
		/obj/item/clothing/under/misc/doppler_uniform/service = 5,
	)

/obj/machinery/vending/cart
	products_doppler = list(
		/obj/item/radio/headset/headset_srv = 3,
	)

/obj/machinery/vending/wardrobe/chem_wardrobe
	products_doppler = list(
		/obj/item/clothing/under/rank/medical/chemist/pharmacologist = 2,
		/obj/item/clothing/under/rank/medical/chemist/pharmacologist/skirt = 2,
		/obj/item/clothing/head/beret/medical/chemist = 2,
	)

/obj/machinery/vending/wardrobe/viro_wardrobe
	products_doppler = list(
		/obj/item/clothing/head/beret/medical/virologist = 2,
	)

/obj/machinery/vending/wardrobe/det_wardrobe
	products_doppler = list(
		/obj/item/clothing/head/fedora/beige = 2,
		/obj/item/clothing/head/fedora/white = 2,
	)

/*/obj/machinery/vending/wardrobe/law_wardrobe
	products_doppler = list(
	)	*/


/// Removes given list of products. Must be called before build_inventory() to actually prevent the records from being created.
/obj/machinery/vending/proc/remove_products(list/paths_to_remove)
	if(!length(paths_to_remove))
		return
	for(var/typepath as anything in products)
		for(var/to_remove as anything in paths_to_remove)
			if(ispath(typepath, to_remove))
				products.Remove(typepath)

/obj/machinery/vending/
	/// list of products to exclude when building the vending machine's inventory
	var/list/excluded_products

/obj/machinery/vending/Initialize(mapload)
	remove_products(excluded_products)
	return ..()
