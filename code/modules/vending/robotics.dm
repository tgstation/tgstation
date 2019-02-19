//This one's from bay12
/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access = list(ACCESS_ROBOTICS)
	products = list(/obj/item/clothing/suit/toggle/labcoat = 4,
		            /obj/item/clothing/under/rank/roboticist = 4,
		            /obj/item/stack/cable_coil = 4,
		            /obj/item/assembly/flash/handheld = 4,
					/obj/item/stock_parts/cell/high = 12,
					/obj/item/assembly/prox_sensor = 3,
					/obj/item/assembly/signaler = 3,
					/obj/item/healthanalyzer = 3,
					/obj/item/scalpel = 2,
					/obj/item/circular_saw = 2,
					/obj/item/tank/internals/anesthetic = 2,
					/obj/item/clothing/mask/breath/medical = 5,
					/obj/item/screwdriver = 5,
					/obj/item/crowbar = 5)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SCI
