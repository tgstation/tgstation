/*
* All vending machine related stuff goes here.
*/

/*
* Perc Chef
*/

/obj/machinery/vending/percchef
	name = "PercTech Automated Chef"
	desc = "A grumpy automated food processor machine courtesy of Perctech."
	icon_state = "percchef"
	icon = 'icons/oldschool/perseus.dmi'

	products = list(/obj/item/reagent_containers/food/snacks/enchiladas = 3, /obj/item/reagent_containers/food/snacks/loadedbakedpotato = 3,
	/obj/item/reagent_containers/food/snacks/fries = 3, /obj/item/reagent_containers/food/snacks/fishfingers = 3,
	/obj/item/reagent_containers/food/snacks/eggplantparm = 3, /obj/item/reagent_containers/food/snacks/cakeslice/carrot = 3,
	/obj/item/reagent_containers/food/snacks/omelette = 3, /obj/item/reagent_containers/food/snacks/soup/tomato = 3,
	/obj/item/reagent_containers/food/snacks/waffles = 3, /obj/item/reagent_containers/food/snacks/sandwich = 3,
	/obj/item/reagent_containers/food/snacks/meatballspaghetti = 3, /obj/item/reagent_containers/food/snacks/cubancarp = 3,
	/obj/item/reagent_containers/food/snacks/soup/stew =3, /obj/item/reagent_containers/food/snacks/burger/superbite = 1,
	/obj/item/reagent_containers/food/snacks/candiedapple = 3, /obj/item/reagent_containers/food/snacks/pie/applepie = 3,
	/obj/item/reagent_containers/food/snacks/pie/cherrypie = 3, /obj/item/reagent_containers/food/snacks/meat/slab/xeno = 3,
	/obj/item/reagent_containers/food/snacks/store/cake/chocolate = 3,/obj/item/kitchen/knife = 1)

	product_ads = "Eat me."
	contraband = list(/obj/item/reagent_containers/food/snacks/soup/wish = 1, /obj/item/reagent_containers/food/snacks/burger/superbite = 2)
	req_access_txt = "561"

	can_be_unfasten_wrench(mob/user, silent)
		return FAILED_UNFASTEN

/*
* Perseus Medical
*/

/obj/machinery/vending/percmed
	name = "PercMed Plus"
	desc = "Perseus Medical drug dispenser."
	icon_state = "percmed"
	icon_deny = "percmed-deny"
	icon = 'icons/oldschool/perseus.dmi'
	req_access_txt = "561"

	products = list(/obj/item/reagent_containers/glass/bottle/charcoal = 4, /obj/item/reagent_containers/glass/bottle/epinephrine = 4,
	/obj/item/reagent_containers/glass/bottle/morphine = 4,/obj/item/reagent_containers/glass/bottle/toxin = 4,
	/obj/item/reagent_containers/syringe/antiviral = 4,/obj/item/reagent_containers/syringe = 12, /obj/item/device/healthanalyzer = 5,
	/obj/item/reagent_containers/glass/beaker = 4,/obj/item/reagent_containers/dropper = 2, /obj/item/stack/medical/bruise_pack = 6,
	/obj/item/stack/medical/ointment = 6, /obj/item/stimpack/perseus = 10,/obj/item/stack/medical/gauze=5)

	contraband = list(/obj/item/reagent_containers/pill/tox = 3, /obj/item/reagent_containers/pill/morphine = 4, /obj/item/reagent_containers/pill/charcoal = 6, /obj/item/reagent_containers/glass/bottle/plasma = 2,/obj/item/storage/pill_bottle = 2)

	can_be_unfasten_wrench(mob/user, silent)
		return FAILED_UNFASTEN

/*
* PercTech Vendor
*/

/obj/machinery/vending/perctech
	name = "PercTech"
	desc = "A Perseus equipment vendor"
	icon_state = "perseus"
	icon_deny = "perseus-deny"
	icon = 'icons/oldschool/perseus.dmi'
	req_access_txt = "561"
	products = list(/obj/item/restraints/handcuffs = 10,/obj/item/grenade/flashbang = 2, /obj/item/device/assembly/flash/handheld = 5,
	/obj/item/tank/perseus = 8, /obj/item/tank/internals/oxygen = 4,/obj/item/storage/fancy/cigarettes/perc = 5,
	/obj/item/storage/box/matches = 5, /obj/item/c4_ex/breach = 5, /obj/item/clothing/mask/cigarette/cigar/victory = 6)

	contraband = list(/obj/item/tank/jetpack/oxygen/perctech = 2, /obj/item/storage/fancy/donut_box = 2, /obj/item/device/aicard = 1)

	can_be_unfasten_wrench(mob/user, silent)
		return FAILED_UNFASTEN

/*
* Perseus Booze-O-Mat
*/

/obj/machinery/vending/boozeomat/perc
	products = list(/obj/item/reagent_containers/food/drinks/bottle/gin = 5,/obj/item/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/reagent_containers/food/drinks/bottle/tequila = 5,/obj/item/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/reagent_containers/food/drinks/bottle/vermouth = 5,/obj/item/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/reagent_containers/food/drinks/bottle/wine = 5,/obj/item/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/reagent_containers/food/drinks/bottle/kahlua = 5,/obj/item/reagent_containers/food/drinks/beer = 6,
					/obj/item/reagent_containers/food/drinks/ale = 6,/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/tomatojuice = 4,/obj/item/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/reagent_containers/food/drinks/bottle/cream = 4,/obj/item/reagent_containers/food/drinks/soda_cans/tonic = 8,
					/obj/item/reagent_containers/food/drinks/soda_cans/cola = 8, /obj/item/reagent_containers/food/drinks/soda_cans/sodawater = 15,
					/obj/item/reagent_containers/food/drinks/drinkingglass = 30,/obj/item/reagent_containers/food/drinks/ice = 9)
	req_access_txt = "561"

	contraband = list(/obj/item/reagent_containers/food/drinks/xenoschlag = 6)

	can_be_unfasten_wrench(mob/user, silent)
		return FAILED_UNFASTEN
/*
*
*/

/obj/machinery/smartfridge/prisoner
	name = "\improper PercTech gear storage"
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "Percprisoner"
	layer = 2.9
	anchored = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	icon_on = "Percprisoner"
	icon_off = "Percprisoner"
	density = 0
	req_access = list(ACCESS_PERSEUS_ENFORCER)

	accept_check(var/obj/item/O as obj)
		if(istype(O, /obj/item))
			return 1
		return 0

	initial_contents = list(
		/obj/item/clothing/under/rank/prisoner = 5,
		/obj/item/clothing/shoes/sneakers/orange = 5,
		/obj/item/restraints/handcuffs = 5,
		/obj/item/clothing/mask/muzzle = 5,
		/obj/item/clothing/suit/straight_jacket = 5,
		/obj/item/clothing/glasses/sunglasses/blindfold = 5)

	can_be_unfasten_wrench(mob/user, silent)
		return FAILED_UNFASTEN

/obj/machinery/vending/percleisure
	name = "PercTech Leisure Vendor"
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "Percleisure"
	icon_deny = "Percleisure_rejection"
	density = 0
	product_slogans = "Get yourself a few toys to spice up that boring prisoner life!"
	products = list(/obj/item/toy/balloon = 4, /obj/item/toy/spinningtoy = 4, /obj/item/toy/gun = 4,
					/obj/item/toy/ammo/gun = 6, /*/obj/item/toy/crossbow = 4, /obj/item/toy/ammo/crossbow = 20,*/ /obj/item/toy/sword = 4,
					/obj/item/toy/katana = 4, /obj/item/toy/crayon = 4, /obj/item/toy/snappop = 15)

	contraband = list(/obj/item/toy/prize/ripley = 1, /obj/item/toy/prize/fireripley = 1, /obj/item/toy/prize/deathripley = 1,
					/obj/item/toy/prize/gygax = 1, /obj/item/toy/prize/durand = 1, /obj/item/toy/prize/honk = 1,
					/obj/item/toy/prize/marauder = 1, /obj/item/toy/prize/seraph = 1, /obj/item/toy/prize/mauler = 1,
					/obj/item/toy/prize/odysseus = 1, /obj/item/toy/prize/phazon = 1)
	req_access = list(ACCESS_PERSEUS_ENFORCER)

	can_be_unfasten_wrench(mob/user, silent)
		return FAILED_UNFASTEN

