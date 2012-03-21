/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS


/obj/item/clothing/suit/storage/wcoat
	name = "waistcoat"
	desc = "The height of class."
	icon_state = "vest"
	item_state = "wcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


/obj/item/clothing/suit/storage/apron
	name = "apron"
	desc = "A basic blue apron. It has a large pocket you can store things in."
	icon_state = "apron"
	item_state = "apron"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/weapon/plantbgone,/obj/item/device/analyzer/plant_analyzer,/obj/item/seeds,/obj/item/nutrient,/obj/item/weapon/minihoe)


/obj/item/clothing/suit/storage/chef
	name = "Chef's apron"
	desc = "An apron used by a high class chef. Has a few pockets for nic-naks."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	heat_transfer_coefficient = 0.50
	protective_temperature = 1000
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/weapon/kitchenknife,/obj/item/weapon/butch)


/obj/item/clothing/suit/storage/chef/classic
	name = "A classic chef's apron."
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO


/obj/item/clothing/suit/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"


/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'belts.dmi'
	icon_state = "suspenders"


/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A plastic replica of a famous space suit. This is a toy, not for use in space!"
	w_class = 3
	flags = FPRINT | TABLEPASS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy)


/obj/item/clothing/suit/storage/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS


/obj/item/clothing/suit/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS

/obj/item/clothing/suit/monk
	name = "monk's robe"
	desc = "A humble robe."
	icon_state = "monk"
	item_state = "monk"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/suit/storage/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS


/obj/item/clothing/suit/hastur
	name = "Hastur's Robes"
	desc = "Robes not meant to be worn by man"
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS


/obj/item/clothing/suit/imperium_monk
	name = "Imperium monk"
	desc = "A set of strange robes."
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS


/obj/item/clothing/suit/chickensuit
	name = "Chicken Suit"
	desc = "Bwak!"
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET|HEAD


/obj/item/clothing/suit/monkeysuit
	name = "Monkey Suit"
	desc = "A suit that looks like a primate"
	icon_state = "monkeysuit"
	item_state = "monkeysuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET|HANDS


/obj/item/clothing/suit/holidaypriest
	name = "Holiday Priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS


