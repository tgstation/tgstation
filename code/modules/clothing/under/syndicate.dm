/obj/item/clothing/under/syndicate
	name = "space-proof henchmen jumpsuit"
	desc = "A very gaudy jumpsuit for a proper Henchmen. Guild regulations, you understand."
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	has_sensor = NO_SENSORS
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 40)
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags_1 = STOPSPRESSUREDMAGE_1 | THICKMATERIAL_1
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
	allowed = list(/obj/item/device/flashlight, /obj/item/tank/internals)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEEARS|HIDEEYES|HIDEHAIR
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/under/syndicate/henchmen_leader
	name = "space-proof henchmen leader jumpsuit"
	desc = "A very gaudy jumpsuit for a proper Henchmen Leader. This suit gives you the power to arch Nanotrasen."
	icon_state = "henchmen_leader"
	item_state = "henchmen_leader"
	item_color = "henchmen_leader"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEEARS|HIDEHAIR

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_state = "bl_suit"
	item_color = "tactifool"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 40)

/obj/item/clothing/under/syndicate/sniper
	name = "Tactical turtleneck suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"

/obj/item/clothing/under/syndicate/camo
	name = "camouflage fatigues"
	desc = "A green military camouflage uniform."
	icon_state = "camogreen"
	item_state = "g_suit"
	item_color = "camogreen"

/obj/item/clothing/under/syndicate/soviet
	name = "Ratnik 5 tracksuit"
	desc = "Badly translated labels tell you to clean this in Vodka. Great for squatting in."
	icon_state = "trackpants"
	item_color = "trackpants"
	can_adjust = FALSE
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	resistance_flags = NONE

/obj/item/clothing/under/syndicate/combat
	name = "combat uniform"
	desc = "With a suit lined with this many pockets, you are ready to operate."
	icon_state = "syndicate_combat"
	item_color = "syndicate_combat"
	can_adjust = FALSE
