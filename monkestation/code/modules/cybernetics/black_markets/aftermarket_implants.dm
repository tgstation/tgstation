/datum/market/auction/aftermarket_parts
	name = "Aftermarket Implants"

/datum/market_item/auction/shoddy_implant
	markets = list(/datum/market/auction/aftermarket_parts)
	stock_max = 1
	availability_prob = 100
	category = "Arm Augment"
	auction_weight = 5

/datum/market_item/auction/shoddy_implant/chest
	category = "Chest Augments"

/datum/market_item/auction/shoddy_implant/chest/sandevistan
	name = "Refurbished Sandevistan"
	desc = "A refurbished Sandevistan, has some issues but with how hard these are to get is worth it."
	item = /obj/item/organ/internal/cyberimp/chest/sandevistan/refurbished
	auction_weight = 1

	price_min = CARGO_CRATE_VALUE * 4
	price_max = CARGO_CRATE_VALUE * 6

/datum/market_item/auction/shoddy_implant/chest/knockout
	name = "Knockout Implant"
	desc = "A crazy clown made this to prank the crew really really hard."
	item = /obj/item/organ/internal/cyberimp/chest/knockout
	auction_weight = 7

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/auction/shoddy_implant/chest/rage
	name = "R.A.G.E. chemical system"
	desc = "Extremely dangerous system that fills the user with a mix of potent drugs."
	item = /obj/item/organ/internal/cyberimp/chest/chemvat
	auction_weight = 2

	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 7

/datum/market_item/auction/shoddy_implant/arm
	category = "Arm Implants"

/datum/market_item/auction/shoddy_implant/arm/ammo_counter
	name = "S.M.A.R.T. ammo logistics system"
	desc = "Special inhand implant that allows transmits the current ammo and energy data straight to the user's visual cortex."

	item = /obj/item/organ/internal/cyberimp/arm/ammo_counter
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/auction/shoddy_implant/arm/heater
	name = "sub-dermal heater implant"
	desc = "Special inhand implant that heats you up if overcooled."

	item = /obj/item/organ/internal/cyberimp/arm/heater
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/auction/shoddy_implant/arm/cooler
	name = "sub-dermal cooling implant"
	desc = "Special inhand implant that cools you down if overheated."

	item = /obj/item/organ/internal/cyberimp/arm/cooler
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3

/datum/market_item/auction/shoddy_implant/arm/strong
	name = "Strong-Arm empowered musculature implant"
	desc = "When implanted, this cybernetic implant will enhance the muscles of the arm to deliver more power-per-action."

	item = /obj/item/organ/internal/cyberimp/arm/muscle
	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 6
	auction_weight = 3

/datum/market_item/auction/shoddy_implant/arm/razorwire
	name = "razorwire spool implant"
	desc = "An integrated spool of razorwire, capable of being used as a weapon when whipped at your foes. \
		Built into the back of your hand, try your best to not get it tangled."

	item = /obj/item/organ/internal/cyberimp/arm/item_set/razorwire
	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 9
	auction_weight = 1

/datum/market_item/auction/shoddy_implant/leg
	category = "Leg Implants"

/datum/market_item/auction/shoddy_implant/leg/glider
	name = "table-glider implant"
	desc = "Implant that allows you quickly glide tables. You need to implant this in both of your legs to make it work."

	item = /obj/item/organ/internal/cyberimp/leg/table_glider
	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 4

/datum/market_item/auction/shoddy_implant/leg/shove_resist
	name = "BU-TAM resistor implant"
	desc = "Implant that allows you to resist shoves, instead shoves deal pure stamina damage. You need to implant this in both of your legs to make it work."

	item = /obj/item/organ/internal/cyberimp/leg/shove_resist
	price_min = CARGO_CRATE_VALUE * 3
	price_max = CARGO_CRATE_VALUE * 5
	auction_weight = 4

/datum/market_item/auction/shoddy_implant/leg/accelerator
	name = "P.R.Y.Z.H.O.K. accelerator system"
	desc = "Russian implant that allows you to tackle people. You need to implant this in both of your legs to make it work."

	item = /obj/item/organ/internal/cyberimp/leg/accelerator
	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 7
	auction_weight = 2

/datum/market_item/auction/shoddy_implant/leg/drugs
	name = "deep-vein emergency morale rejuvenator"
	desc = "Dangerous implant used by the syndicate to reinforce their assault forces that go on suicide missions."

	item = /obj/item/organ/internal/cyberimp/leg/chemplant/drugs
	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 7
	auction_weight = 4


/datum/market_item/auction/shoddy_implant/leg/emergency
	name = "deep emergency chemical infuser"
	desc = "Dangerous implant used by the syndicate to reinforce their assault forces that go on suicide missions."

	item = /obj/item/organ/internal/cyberimp/leg/chemplant/emergency
	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 7
	auction_weight = 2
