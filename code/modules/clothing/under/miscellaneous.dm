/obj/item/clothing/under/misc
	icon = 'icons/obj/clothing/under/misc.dmi'
	worn_icon = 'icons/mob/clothing/under/misc.dmi'

/obj/item/clothing/under/misc/pj
	name = "\improper PJs"
	desc = "A comfy set of sleepwear, for taking naps or being lazy instead of working."
	can_adjust = FALSE
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/misc/pj/red
	icon_state = "red_pyjamas"

/obj/item/clothing/under/misc/pj/blue
	icon_state = "blue_pyjamas"

/obj/item/clothing/under/misc/patriotsuit
	name = "Patriotic Suit"
	desc = "Motorcycle not included."
	icon_state = "ek"
	inhand_icon_state = "ek"
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/misc/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/misc/vice_officer
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/adminsuit
	name = "administrative cybernetic jumpsuit"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	desc = "A cybernetically enhanced jumpsuit used for administrative duties."
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 100, BULLET = 100, LASER = 100,ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	inhand_icon_state = "burial"
	can_adjust = FALSE
	has_sensor = NO_SENSORS

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE
	custom_price = PAYCHECK_EASY

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	inhand_icon_state = "durathread"
	can_adjust = FALSE
	armor = list(MELEE = 10, LASER = 10, FIRE = 40, ACID = 10, BOMB = 5)

/obj/item/clothing/under/misc/bouncer
	name = "bouncer uniform"
	desc = "A uniform made from a little bit more resistant fibers, makes you seem like a cool guy."
	icon_state = "bouncer"
	inhand_icon_state = "bouncer"
	can_adjust = FALSE
	armor = list(MELEE = 5, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/under/misc/coordinator
	name = "coordinator jumpsuit"
	desc = "A jumpsuit made by party people, from party people, for party people."
	icon = 'icons/obj/clothing/under/captain.dmi'
	worn_icon = 'icons/mob/clothing/under/captain.dmi'
	icon_state = "captain_parade"
	inhand_icon_state = "by_suit"
	can_adjust = FALSE
