/obj/machinery/vending/wallmed
	name = "\improper Emergency NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser, Meant to be used in medical emergencies."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	panel_type = "wallmed-panel"
	density = FALSE
	products = list(
		/obj/item/stack/medical/bandage = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/hypospray/medipen/ekit = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	contraband = list(
		/obj/item/storage/box/bandages = 1,
		/obj/item/storage/box/gum/happiness = 1,
	)
	premium = list(
		/obj/item/reagent_containers/applicator/patch/libital = 1,
		/obj/item/reagent_containers/applicator/patch/aiuri = 1,
	)
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = PAYCHECK_CREW * 0.3 // Cheap since crew should be able to affort it in emergency situations
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_MED
	tiltable = FALSE
	light_mask = "wallmed-light-mask"
	allow_custom = TRUE

/obj/machinery/vending/wallmed/directional
	allow_custom = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/vending/wallmed, 32)

/obj/item/vending_refill/wallmed
	machine_name = "Emergency NanoMed"
	icon_state = "refill_medical"
