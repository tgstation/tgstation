/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

	var/icon/stand_icon = null
	var/icon/lying_icon = null
	var/icon/resting_icon = null
	var/icon/running_icon = null

	var/last_b_state = 1.0

	var/image/face_standing = null
	var/image/face_lying = null

	var/image/damageicon_standing = null
	var/image/damageicon_lying = null

/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"

	health = 150
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"

	health = 125
	storedPlasma = 100
	max_plasma = 250
	icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"

	health = 100
	icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"

	health = 250
	icon_state = "queen_s"
	nopush = 1
/mob/living/carbon/alien/humanoid/rpbody
	update_icon = 0

	voice_message = "says"
	say_message = "says"