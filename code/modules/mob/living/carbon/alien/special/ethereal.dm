/mob/living/carbon/alien/humanoid/special/etheral
	name = "Etheral"
	desc = "The apparently weak physical abilities of this creature are sustained by its mental powers. We do not understand how these telekinetic powers work, since they seem to defy the laws of physics as we know them. "
	xcom_state = "ethereal"
	has_fine_manipulation = 0

	New()
		..()
		var/obj/item/weapon/tank/jetpack/jetpack = new(src)
		jetpack.on = !(jetpack.on)
		back = jetpack

		mutations |= 1

		spawn(2)
			name = "Etheral"
			real_name = "Etheral"
		return

	movement_delay()
		return 2

/mob/living/carbon/alien/humanoid/special/etheral/verb/demoralise()
	set name = "Psionic Demoralisation"
	set desc = "Confuses and disorients all humanoids in a small radius."
	set category = "Etheral"

	if(stat)
		return

	visible_message("<b>[src]</b> appears to emit strange throbbing waves.")

	for(var/mob/living/carbon/M in view(3, src))
		if(M == src)
			continue
		if(M.confused <= 10)
			M.confused = 10
		if(M.eye_blurry <= 10)
			M.eye_blurry = 10
		M.drop_item()
		M << "\red <b>SCREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE</b>"
		M << "You clutch your head in agony as your vision blurs and you succumb to disorientation."

	verbs -= /mob/living/carbon/alien/humanoid/special/etheral/verb/demoralise
	spawn(300)
		verbs += /mob/living/carbon/alien/humanoid/special/etheral/verb/demoralise

	return

/atom/attack_alien(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/humanoid/special/etheral))
		attack_ai(user)
		return
	..()