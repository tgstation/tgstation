/*
CONTAINS:
MEDICAL


*/

/obj/item/weapon/medical/examine()
	set src in view(1)

	if (src.amount <= 0)
		del(src)
		return

	..()

	usr << "\icon[src] \blue There [src.amount == 1 ? "is" : "are"] [src.amount] [src.name]\s left on the stack!"

/obj/item/weapon/medical/attack_hand(mob/user as mob)
	if (user.r_hand == src || user.l_hand == src)
		src.add_fingerprint(user)
		var/obj/item/weapon/medical/split = new src.type(user)
		split.amount = 1
		src.amount--

		if (user.hand)
			user.l_hand = split
		else
			user.r_hand = split

		split.layer = 20
		split.add_fingerprint(user)

		if (src.amount < 1)
			del(src)
			return
	else
		..()

/obj/item/weapon/medical/attackby(obj/item/weapon/medical/W as obj, mob/user as mob)
	..()
	if (!istype(W, src.type))
		return

	if (W.amount == 5)
		return

	if (W.amount + src.amount > 5)
		src.amount = (W.amount + src.amount) - 5
		W.amount = 5
	else
		W.amount += src.amount
		del(src)

/obj/item/weapon/medical/attack(mob/M as mob, mob/user as mob)
	if (M.health < 0)
		return

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return

	if (user)
		if (M != user)
			for (var/mob/O in viewers(M, null))
				O.show_message("\red [M] has been applied with [src] by [user]", 1)
		else
			var/t_himself = "itself"
			if (user.gender == MALE)
				t_himself = "himself"
			else if (user.gender == FEMALE)
				t_himself = "herself"

			for (var/mob/O in viewers(M, null))
				O.show_message("\red [M] applied [src] on [t_himself]", 1)

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.organs["chest"]

		if (istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/user2 = user
			var/t = user2.zone_sel.selecting

			if (t in list("eyes", "mouth"))
				t = "head"

			if (H.organs[t])
				affecting = H.organs[t]
		else
			if (!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
				affecting = H.organs["head"]
				if (!istype(affecting, /datum/organ/external) || affecting:burn_dam <= 0)
					affecting = H.organs["groin"]

		if (affecting.heal_damage(src.heal_brute, src.heal_burn))
			H.UpdateDamageIcon()
		else
			H.UpdateDamage()
	else
		M.bruteloss = max(0, M.bruteloss - (src.heal_brute/2))
		M.fireloss = max(0, M.fireloss - (src.heal_burn/2))

	M.updatehealth()

	src.amount--
	if (src.amount <= 0)
		del(src)
