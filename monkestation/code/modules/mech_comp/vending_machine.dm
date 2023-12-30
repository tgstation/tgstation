/// Standard mechcomp component supply.
#define STANDARD_COMPONENT_SUPPLY 30
/// Components that place a higher than usual load on the server by their use.
#define LOW_COMPONENT_SUPPLY 15
/obj/machinery/vending/mechcomp
	name = "\improper ThinkTronic MechComp Dispenser"
	desc = "A rather plain vendor for ThinkTronic's line of field-assemblable components."
	product_ads = "At least it's not Circuits!;95% GPL Compatible!;Source Exists, Somewhere!;Semi-Standards Compliant!;IETF Cleared!"

	default_price = 0
	extra_price = 0

	products = list(
		/obj/item/mcobject/signal_output = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/flusher = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/button_panel = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/payment = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/thermal_printer = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/paper_scanner = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/and = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/button = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/delay = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/dispatch = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/hand_scanner = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/microphone = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/or = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/pressure_sensor = STANDARD_COMPONENT_SUPPLY,
//		/obj/item/mcobject/messaging/regfind = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/regreplace = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/relay = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/signal_builder = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/signal_check = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/toggle = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/wifi_split = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/led = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/synthcomp = LOW_COMPONENT_SUPPLY,
		/obj/item/mcobject/graviton_accelerator = LOW_COMPONENT_SUPPLY,
		/obj/item/mcobject/teleporter = LOW_COMPONENT_SUPPLY,
		/obj/item/mcobject/interactor = LOW_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/storage = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/type_sensor = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/clock = STANDARD_COMPONENT_SUPPLY,
		/obj/item/mcobject/messaging/repeater = LOW_COMPONENT_SUPPLY
	)


/obj/item/vending_refill/mechcomp
	machine_name = "ThinkTronic MechComp Dispenser"
	icon_state = "refill_engi"

#undef STANDARD_COMPONENT_SUPPLY
#undef LOW_COMPONENT_SUPPLY
