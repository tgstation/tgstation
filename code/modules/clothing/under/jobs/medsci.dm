/*
 * Science
 */
/obj/item/clothing/under/rank/research_director
	desc = "It's a suit worn by those with the know-how to achieve the position of \"Research Director\"."
	name = "research director's vest suit"
	icon_state = "director"
	item_state = "g_suit"
	item_color = "director"
	can_adjust = 0

/obj/item/clothing/under/rank/research_director/alt
	desc = "Maybe you'll engineer your own half-man, half-pig creature some day."
	name = "research director's tan suit"
	icon_state = "rdwhimsy"
	item_state = "rdwhimsy"
	item_color = "rdwhimsy"
	can_adjust = 1

/obj/item/clothing/under/rank/research_director/turtleneck
	desc = "A dark purple turtleneck and tan khakis, for a director with a superior sense of style."
	name = "research director's turtleneck"
	icon_state = "rdturtle"
	item_state = "p_suit"
	item_color = "rdturtle"
	can_adjust = 1

/obj/item/clothing/under/rank/scientist
	desc = "A white and purple jumpsuit for scientists."
	name = "scientist's jumpsuit"
	icon_state = "toxins"
	item_state = "w_suit"
	item_color = "toxinswhite"
	permeability_coefficient = 0.50


/obj/item/clothing/under/rank/chemist
	desc = "A white and orange jumpsuit for chemists."
	name = "chemist's jumpsuit"
	icon_state = "chemistry"
	item_state = "w_suit"
	item_color = "chemistrywhite"
	permeability_coefficient = 0.50

/*
 * Medical
 */
/obj/item/clothing/under/rank/chief_medical_officer
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\"."
	name = "chief medical officer's jumpsuit"
	icon_state = "cmo"
	item_state = "w_suit"
	item_color = "cmo"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/geneticist
	desc = "A white and blue jumpsuit for geneticists."
	name = "geneticist's jumpsuit"
	icon_state = "genetics"
	item_state = "w_suit"
	item_color = "geneticswhite"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/virologist
	desc = "A white and green jumpsuit for virologists."
	name = "virologist's jumpsuit"
	icon_state = "virology"
	item_state = "w_suit"
	item_color = "virologywhite"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/nursesuit
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	name = "nurse's suit"
	icon_state = "nursesuit"
	item_state = "w_suit"
	item_color = "nursesuit"
	permeability_coefficient = 0.50
	fitted = 0
	can_adjust = 0

/obj/item/clothing/under/rank/medical
	desc = "A white jumpsuit with the token blue cross of medical doctors."
	name = "medical doctor's jumpsuit"
	icon_state = "medical"
	item_state = "w_suit"
	item_color = "medical"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/blue
	name = "medical scrubs"
	desc = "A short sleeve blue jumpsuit for medical doctors and first responders alike."
	icon_state = "scrubsblue"
	item_color = "scrubsblue"
	can_adjust = 0

/obj/item/clothing/under/rank/medical/green
	name = "medical scrubs"
	desc = "A short sleeve green jumpsuit for medical doctors and first responders alike."
	icon_state = "scrubsgreen"
	item_color = "scrubsgreen"
	can_adjust = 0

/obj/item/clothing/under/rank/medical/purple
	name = "medical scrubs"
	desc = "A short sleeve purple jumpsuit for medical doctors and first responders alike."
	icon_state = "scrubspurple"
	item_color = "scrubspurple"
	can_adjust = 0



/*
 * Medsci, unused (i think) stuff
 */
/obj/item/clothing/under/rank/geneticist_new
	desc = "It's made of a special fiber that provides minor protection against biohazards."
	name = "geneticist's jumpsuit"
	icon_state = "genetics_new"
	item_state = "w_suit"
	item_color = "genetics_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	can_adjust = 0

/obj/item/clothing/under/rank/chemist_new
	desc = "It's made of a special fiber that provides minor protection against biohazards."
	name = "chemist's jumpsuit"
	icon_state = "chemist_new"
	item_state = "w_suit"
	item_color = "chemist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	can_adjust = 0

/obj/item/clothing/under/rank/scientist_new
	desc = "Made of a special fiber that gives special protection against biohazards and small explosions."
	name = "scientist's jumpsuit"
	icon_state = "scientist_new"
	item_state = "w_suit"
	item_color = "scientist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)
	can_adjust = 0

/obj/item/clothing/under/rank/virologist_new
	desc = "Made of a special fiber that gives increased protection against biohazards."
	name = "virologist's jumpsuit"
	icon_state = "virologist_new"
	item_state = "w_suit"
	item_color = "virologist_new"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	can_adjust = 0