/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/clothing/head/head = null			//
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
//	var/alien_invis = 0
	var/caste = ""
	update_icon = 1


/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	health = 150
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alienh_s"

/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	health = 125
	storedPlasma = 100
	max_plasma = 250
	icon_state = "aliens_s"

/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	health = 100
	icon_state = "aliend_s"

/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	health = 250
	icon_state = "alienq_s"
	nopush = 1

/mob/living/carbon/alien/humanoid/rpbody
	update_icon = 0
	voice_message = "says"
	say_message = "says"