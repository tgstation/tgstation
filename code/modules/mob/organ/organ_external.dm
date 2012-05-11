/datum/organ/external/chest
	name = "chest"
	icon_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	body_part = UPPER_TORSO

/datum/organ/external/groin
	name = "groin"
	icon_name = "diaper"
	max_damage = 115
	min_broken_damage = 70
	body_part = LOWER_TORSO

/datum/organ/external/head
	name = "head"
	icon_name = "head"
	max_damage = 75
	min_broken_damage = 40
	body_part = HEAD
	var/disfigured = 0

/datum/organ/external/l_arm
	name = "l_arm"
	display_name = "left arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_LEFT

/datum/organ/external/l_leg
	name = "l_leg"
	display_name = "left leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_LEFT

/datum/organ/external/r_arm
	name = "r_arm"
	display_name = "right arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 30
	body_part = ARM_RIGHT

/datum/organ/external/r_leg
	name = "r_leg"
	display_name = "right leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 30
	body_part = LEG_RIGHT

/datum/organ/external/l_foot
	name = "l_foot"
	display_name = "left foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_LEFT

/datum/organ/external/r_foot
	name = "r_foot"
	display_name = "right foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 15
	body_part = FOOT_RIGHT

/datum/organ/external/r_hand
	name = "r_hand"
	display_name = "right hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_RIGHT

/datum/organ/external/l_hand
	name = "l_hand"
	display_name = "left hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 15
	body_part = HAND_LEFT



obj/item/weapon/organ
	icon = 'human.dmi'

obj/item/weapon/organ/New(loc, mob/living/carbon/human/H)
	..(loc)
	if(!istype(H))
		return
	if(H.dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	var/icon/I = new /icon(icon, icon_state)

	if (H.s_tone >= 0)
		I.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
	else
		I.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)
	icon = I

obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_m_l"
	var/mob/living/carbon/brain/brainmob
	var/brain_op_stage = 0

obj/item/weapon/organ/head/New()
	..()
	spawn(5)
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

obj/item/weapon/organ/head/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src
	if (brainmob.client)
		spawn(10)
			if(brainmob.client)
				verbs += /mob/proc/ghost

obj/item/weapon/organ/head/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/scalpel))
		switch(brain_op_stage)
			if(0)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is beginning to have \his head cut open with [src] by [user].", 1)
				brainmob << "\red [user] begins to cut open your head with [src]!"
				user << "\red You cut [brainmob]'s head open with [src]!"

				brain_op_stage = 1

			if(2)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] is having \his connections to the brain delicately severed with [src] by [user].", 1)
				brainmob << "\red [user] begins to cut open your head with [src]!"
				user << "\red You cut [brainmob]'s head open with [src]!"

				brain_op_stage = 3.0
			else
				..()
	else if(istype(W,/obj/item/weapon/circular_saw))
		switch(brain_op_stage)
			if(1)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his skull sawed open with [src] by [user].", 1)
				brainmob << "\red [user] begins to saw open your head with [src]!"
				user << "\red You saw [brainmob]'s head open with [src]!"

				brain_op_stage = 2
			if(3)
				for(var/mob/O in (oviewers(brainmob) - user))
					O.show_message("\red [brainmob] has \his spine's connection to the brain severed with [src] by [user].", 1)
				brainmob << "\red [user] severs your brain's connection to the spine with [src]!"
				user << "\red You sever [brainmob]'s brain's connection to the spine with [src]!"

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [brainmob.name] ([brainmob.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				brainmob.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				log_admin("ATTACK: [brainmob] ([brainmob.ckey]) debrained [user] ([user.ckey]).")
				message_admins("ATTACK: [brainmob] ([brainmob.ckey]) debrained [user] ([user.ckey]).")

				var/obj/item/brain/B = new(loc)
				B.transfer_identity(brainmob)

				brain_op_stage = 4.0
			else
				..()
	else
		..()

obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = "l_arm_l"
obj/item/weapon/organ/l_foot
	name = "left foot"
	icon_state = "l_foot_l"
obj/item/weapon/organ/l_hand
	name = "left hand"
	icon_state = "l_hand_l"
obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "l_leg_l"
obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "r_arm_l"
obj/item/weapon/organ/r_foot
	name = "right foot"
	icon_state = "r_foot_l"
obj/item/weapon/organ/r_hand
	name = "right hand"
	icon_state = "r_hand_l"
obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "r_leg_l"
