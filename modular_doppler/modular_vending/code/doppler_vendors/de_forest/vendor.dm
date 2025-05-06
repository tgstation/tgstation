/obj/machinery/vending/deforest_medvend
	name = "\improper DeForest Med-Vend"
	desc = "A vending machine providing a selection of medical supplies."
	icon = 'modular_doppler/modular_vending/icons/de_forest_vendors.dmi'
	icon_state = "medvend"
	panel_type = "panel15"
	light_mask = "medvend-light-mask"
	light_color = LIGHT_COLOR_LIGHT_CYAN
	product_slogans = "Medical care at regulation-mandated reasonable prices!;DeForest is not liable for accidents due to supply misuse!"
	product_categories = list(
		list(
			"name" = "First Aid",
			"icon" = "notes-medical",
			"products" = list(
				/obj/item/stack/medical/ointment/red_sun = 4,
				/obj/item/stack/medical/ointment = 4,
				/obj/item/stack/medical/bruise_pack = 4,
				/obj/item/stack/medical/gauze/sterilized = 4,
				/obj/item/stack/medical/suture/coagulant = 4,
				/obj/item/stack/medical/suture = 4,
				/obj/item/stack/medical/suture/bloody = 2,
				/obj/item/stack/medical/mesh = 4,
				/obj/item/stack/medical/mesh/bloody = 2,
				/obj/item/stack/medical/bandage = 4,
				/obj/item/reagent_containers/applicator/patch/robotic_patch/synth_repair = 4,
				/obj/item/stack/medical/gauze/alu_splint = 2,
				/obj/item/storage/pill_bottle/painkiller = 4,
				/obj/item/storage/medkit/civil_defense/stocked = 2,
			),
		),
		list(
			"name" = "Autoinjectors",
			"icon" = "syringe",
			"products" = list(
				/obj/item/reagent_containers/hypospray/medipen/deforest/occuisate = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/adrenaline = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/morpital = 4,
				/obj/item/reagent_containers/hypospray/medipen/deforest/lipital = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/meridine = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/calopine = 4,
				/obj/item/reagent_containers/hypospray/medipen/deforest/coagulants = 4,
				/obj/item/reagent_containers/hypospray/medipen/deforest/lepoturi = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/psifinil = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/halobinin = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/robot_system_cleaner = 3,
				/obj/item/reagent_containers/hypospray/medipen/deforest/robot_liquid_solder = 3,
			),
		),
	)

	contraband = list(
		/obj/item/reagent_containers/hypospray/medipen/deforest/pentibinin = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synephrine = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/krotozine = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/aranepaine = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/synalvipitol = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/twitch = 2,
		/obj/item/reagent_containers/hypospray/medipen/deforest/demoneye = 2,
	)

	refill_canister = /obj/item/vending_refill/medical_deforest
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 4
	payment_department = NO_FREEBIES
	onstation_override = 1 // No freebies if this spawns on the interlink

/obj/item/vending_refill/medical_deforest
	machine_name = "DeForest Med-Vend"
	icon_state = "refill_medical"
