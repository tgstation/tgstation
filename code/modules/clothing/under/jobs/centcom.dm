/obj/item/clothing/under/rank/centcom
	icon = 'icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom.dmi'

/obj/item/clothing/under/rank/centcom/officer
	name = "\improper CentCom officer's jumpsuit"
	desc = "It's a jumpsuit worn by CentCom Officers."
	icon_state = "officer"
	inhand_icon_state = "g_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom/commander
	name = "\improper CentCom officer's jumpsuit"
	desc = "It's a jumpsuit worn by CentCom's highest-tier Commanders."
	icon_state = "centcom"
	inhand_icon_state = "dg_suit"

/obj/item/clothing/under/rank/centcom/intern
	name = "\improper CentCom intern's jumpsuit"
	desc = "It's a jumpsuit worn by those interning for CentCom. The top is styled after a polo shirt for easy identification."
	icon_state = "intern"
	inhand_icon_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/centcom/administrator
	name = "\improper CentCom Administrator Uniform"
	desc = "Your uniform! Though you refuse to wear the actual uniform. The colors fit you nicely atleast!"
	icon_state = "administrator"
	inhand_icon_state = "administrator"
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 10, RAD = 0, FIRE = 0, ACID = 35)
