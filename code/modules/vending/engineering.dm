//This one's from bay12
/obj/machinery/vending/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	panel_type = "panel10"
	products = list(
		/obj/item/clothing/under/rank/engineering/chief_engineer = 4,
		/obj/item/clothing/under/rank/engineering/engineer = 4,
		/obj/item/clothing/shoes/sneakers/orange = 4,
		/obj/item/clothing/head/utility/hardhat = 4,
		/obj/item/storage/belt/utility = 4,
		/obj/item/clothing/glasses/meson/engine = 4,
		/obj/item/clothing/gloves/color/yellow = 4,
		/obj/item/screwdriver = 12,
		/obj/item/crowbar = 12,
		/obj/item/wirecutters = 12,
		/obj/item/multitool = 12,
		/obj/item/wrench = 12,
		/obj/item/t_scanner = 12,
		/obj/item/stock_parts/power_store/cell = 8,
		/obj/item/stock_parts/power_store/battery = 8,
		/obj/item/weldingtool = 8,
		/obj/item/clothing/head/utility/welding = 8,
		/obj/item/light/tube = 10,
		/obj/item/clothing/suit/utility/fire = 4,
		/obj/item/stock_parts/scanning_module = 5,
		/obj/item/stock_parts/micro_laser = 5,
		/obj/item/stock_parts/matter_bin = 5,
		/obj/item/stock_parts/servo = 5,
		)
	refill_canister = /obj/item/vending_refill/engineering
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 1.5
	payment_department = ACCOUNT_ENG
	light_mask = "engi-light-mask"

/obj/item/vending_refill/engineering
	machine_name = "Robco Tool Maker"
	icon_state = "refill_roroco"
