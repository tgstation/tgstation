/obj/item/clothing/under/rank/rnd
	icon = 'icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd.dmi'

/obj/item/clothing/under/rank/rnd/research_director
	desc = "It's a suit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	name = "research director's vest suit"
	icon_state = "director"
	inhand_icon_state = "lb_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 10, RAD = 0, FIRE = 0, ACID = 35)
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/research_director/skirt
	name = "research director's vest suitskirt"
	desc = "It's a suitskirt worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/rnd/research_director/alt
	desc = "Maybe you'll engineer your own half-man, half-pig creature some day. Its fabric provides minor protection from biological contaminants."
	name = "research director's tan suit"
	icon_state = "rdwhimsy"
	inhand_icon_state = "rdwhimsy"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/alt/skirt
	name = "research director's tan suitskirt"
	desc = "Maybe you'll engineer your own half-man, half-pig creature some day. Its fabric provides minor protection from biological contaminants."
	icon_state = "rdwhimsy_skirt"
	inhand_icon_state = "rdwhimsy"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	desc = "A dark purple turtleneck and tan khakis, for a director with a superior sense of style."
	name = "research director's turtleneck"
	icon_state = "rdturtle"
	inhand_icon_state = "p_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	name = "research director's turtleneck skirt"
	desc = "A dark purple turtleneck and tan khaki skirt, for a director with a superior sense of style."
	icon_state = "rdturtle_skirt"
	inhand_icon_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/rnd/scientist
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	name = "scientist's jumpsuit"
	icon_state = "toxins"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	icon_state = "toxinswhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/rnd/roboticist
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	inhand_icon_state = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black with reinforced seams; great for industrial work."
	icon_state = "robotics_skirt"
	inhand_icon_state = "robotics"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/rnd/geneticist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	name = "geneticist's jumpsuit"
	icon_state = "genetics"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/rnd/geneticist/skirt
	name = "geneticist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	icon_state = "geneticswhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP
