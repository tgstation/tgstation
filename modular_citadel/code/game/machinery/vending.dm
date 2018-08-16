/obj/machinery/vending/security
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2, /obj/item/storage/fancy/donut_box = 2, /obj/item/ssword_kit = 1)
	premium = list(/obj/item/coin/antagtoken = 1, /obj/item/ssword_kit = 1)

/obj/machinery/vending/medical
	products = list(/obj/item/reagent_containers/syringe = 12,
					/obj/item/reagent_containers/dropper = 3,
					/obj/item/healthanalyzer = 4,
					/obj/item/sensor_device = 2,
					/obj/item/pinpointer/crew = 2,
					/obj/item/reagent_containers/medspray/sterilizine = 1,
					/obj/item/stack/medical/gauze = 8,
					/obj/item/reagent_containers/pill/patch/styptic = 5,
					/obj/item/reagent_containers/medspray/styptic = 2,
					/obj/item/reagent_containers/pill/patch/silver_sulf = 5,
					/obj/item/reagent_containers/medspray/silver_sulf = 2,
					/obj/item/reagent_containers/pill/insulin = 10,
					/obj/item/reagent_containers/pill/salbutamol = 2,
					/obj/item/reagent_containers/glass/bottle/charcoal = 4,
					/obj/item/reagent_containers/glass/bottle/epinephrine = 4,
					/obj/item/reagent_containers/glass/bottle/salglu_solution = 3,
					/obj/item/reagent_containers/glass/bottle/morphine = 4,
					/obj/item/reagent_containers/glass/bottle/toxin = 3,
					/obj/item/reagent_containers/syringe/antiviral = 6,
					/obj/item/storage/hypospraykit/fire = 2,
					/obj/item/storage/hypospraykit/toxin = 2,
					/obj/item/storage/hypospraykit/o2 = 2,
					/obj/item/storage/hypospraykit/brute = 2,
					/obj/item/reagent_containers/glass/bottle/vial/small = 5)
					
/obj/machinery/vending/wardrobe/chap_wardrobe
	premium = list(/obj/item/toy/plush/plushvar = 1,
					/obj/item/toy/plush/narplush = 1)
	
#define STANDARD_CHARGE 1
#define CONTRABAND_CHARGE 2
#define COIN_CHARGE 3

/obj/machinery/vending/kink
	name = "KinkMate"
	desc = "A vending machine for all your unmentionable desires."
	icon = 'icons/obj/citvending.dmi'
	icon_state = "kink"
	circuit = /obj/item/circuitboard/machine/kinkmate
	product_slogans = "Kinky!;Sexy!;Check me out, big boy!"
	vend_reply = "Have fun, you shameless pervert!"
	products = list(
				/obj/item/clothing/under/maid = 5,
				/obj/item/clothing/under/stripper_pink = 5,
				/obj/item/clothing/under/stripper_green = 5,
				/obj/item/dildo/custom = 5
				)
	contraband = list(/obj/item/restraints/handcuffs/fake/kinky = 5,
				/obj/item/clothing/neck/petcollar = 5,
				/obj/item/clothing/under/mankini = 1,
				/obj/item/dildo/flared/huge = 1
					)
	premium = list(/obj/item/electropack/shockcollar = 3)
	refill_canister = /obj/item/vending_refill/kink
/*
/obj/machinery/vending/nazivend
	name = "Nazivend"
	desc = "A vending machine containing Nazi German supplies. A label reads: \"Remember the gorrilions lost.\""
	icon = 'icons/obj/citvending.dmi'
	icon_state = "nazi"
	vend_reply = "SIEG HEIL!"
	product_slogans = "Das Vierte Reich wird zuruckkehren!;ENTFERNEN JUDEN!;Billiger als die Juden jemals geben!;Rader auf dem adminbus geht rund und rund.;Warten Sie, warum wir wieder hassen Juden?- *BZZT*"
	products = list(
		/obj/item/clothing/head/stalhelm = 20,
		/obj/item/clothing/head/panzer = 20,
		/obj/item/clothing/suit/soldiercoat = 20,
	//	/obj/item/clothing/under/soldieruniform = 20,
		/obj/item/clothing/shoes/jackboots = 20
		)
	contraband = list(
		/obj/item/clothing/head/naziofficer = 10,
	//	/obj/item/clothing/suit/officercoat = 10,
	//	/obj/item/clothing/under/officeruniform = 10,
		/obj/item/clothing/suit/space/hardsuit/nazi = 3,
		/obj/item/gun/energy/plasma/MP40k = 4
		)
	premium = list()

	refill_canister = /obj/item/vending_refill/nazi
*/
/obj/machinery/vending/sovietvend
	name = "KomradeVendtink"
	desc = "Rodina-mat' zovyot!"
	icon = 'icons/obj/citvending.dmi'
	icon_state = "soviet"
	vend_reply = "The fascist and capitalist svin'ya shall fall, komrade!"
	product_slogans = "Quality worth waiting in line for!; Get Hammer and Sickled!; Sosvietsky soyuz above all!; With capitalist pigsky, you would have paid a fortunetink! ; Craftink in Motherland herself!"
	products = list(
		/obj/item/clothing/under/soviet = 20,
		/obj/item/clothing/head/ushanka = 20,
		/obj/item/clothing/shoes/jackboots = 20,
		/obj/item/clothing/head/squatter_hat = 20,
		/obj/item/clothing/under/squatter_outfit = 20,
		/obj/item/clothing/under/russobluecamooutfit = 20,
		/obj/item/clothing/head/russobluecamohat = 20
		)
	contraband = list(
		/obj/item/clothing/under/syndicate/tacticool = 4,
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/clothing/suit/russofurcoat = 4,
		/obj/item/clothing/head/russofurhat = 4,
		/obj/item/clothing/suit/space/hardsuit/soviet = 3,
		/obj/item/gun/energy/laser/LaserAK = 4
		)
	premium = list()

	refill_canister = /obj/item/vending_refill/soviet


#undef STANDARD_CHARGE
#undef CONTRABAND_CHARGE
#undef COIN_CHARGE


/obj/item/vending_refill/kink
	machine_name 	= "KinkMate"
	icon			= 'modular_citadel/icons/vending_restock.dmi'
	icon_state 		= "refill_kink"

/obj/item/vending_refill/nazi
	machine_name 	= "nazivend"
	icon_state 		= "refill_nazi"

/obj/item/vending_refill/soviet
	machine_name 	= "sovietvend"
	icon_state 		= "refill_soviet"
