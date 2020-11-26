/obj/item/clothing/under/rank/medical
	icon = 'icons/obj/clothing/under/medical.dmi'
	worn_icon = 'icons/mob/clothing/under/medical.dmi'

/obj/item/clothing/under/rank/medical/chief_medical_officer
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's jumpsuit"
	icon_state = "cmo"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	name = "chief medical officer's jumpskirt"
	desc = "It's a jumpskirt worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	icon_state = "cmo_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/medical/virologist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	name = "virologist's jumpsuit"
	icon_state = "virology"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "virologist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	icon_state = "virologywhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/medical/doctor/nurse
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	name = "nurse's suit"
	icon_state = "nursesuit"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "medical doctor's jumpsuit"
	icon_state = "medical"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/doctor/blue
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/green
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/purple
	name = "medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "medical doctor's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	icon_state = "medical_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/medical/chemist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	name = "chemist's jumpsuit"
	icon_state = "chemistry"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 50, ACID = 65)

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "chemist's jumpskirt"
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	icon_state = "chemistrywhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/medical/paramedic
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a dark blue cross on the chest denoting that the wearer is a trained paramedic."
	name = "paramedic jumpsuit"
	icon_state = "paramedic"
	inhand_icon_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "paramedic jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a dark blue cross on the chest denoting that the wearer is a trained paramedic."
	icon_state = "paramedic_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP
