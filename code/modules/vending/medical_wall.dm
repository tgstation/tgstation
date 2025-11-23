/obj/machinery/vending/wallmed
	name = "\improper Emergency NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser, Meant to be used in medical emergencies."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	panel_type = "wallmed-panel"
	density = FALSE
	products = list(
		/obj/item/stack/medical/bandage = 4,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/reagent_containers/applicator/pill/multiver = 2,
		/obj/item/stack/medical/gauze = 4,
		/obj/item/reagent_containers/hypospray/medipen/ekit = 2,
		/obj/item/healthanalyzer/simple = 2,
	)
	contraband = list(
		/obj/item/storage/box/bandages = 1,
		/obj/item/storage/box/gum/happiness = 1,
	)
	premium = list(
		/obj/item/reagent_containers/applicator/patch/libital = 2,
		/obj/item/reagent_containers/applicator/patch/aiuri = 2,
	)
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = PAYCHECK_CREW * 0.3 // Cheap since crew should be able to affort it in emergency situations
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_MED
	tiltable = FALSE
	light_mask = "wallmed-light-mask"

/obj/machinery/vending/wallmed/directional
	allow_custom = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/vending/wallmed, 32)

/obj/item/vending_refill/wallmed
	machine_name = "Emergency NanoMed"
	icon_state = "refill_medical"
