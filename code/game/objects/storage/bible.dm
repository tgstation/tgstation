/obj/item/weapon/storage/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)
	new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/proc/bless(mob/living/carbon/M as mob)
	var/mob/living/carbon/human/H = M
	var/heal_amt = 10
	for(var/A in H.organs)
		var/datum/organ/external/affecting = null
		if(!H.organs[A])	continue
		affecting = H.organs[A]
		if(!istype(affecting, /datum/organ/external))	continue
		if(affecting.heal_damage(heal_amt, heal_amt))
			H.UpdateDamageIcon()
		else
			H.UpdateDamage()
	return

/obj/item/weapon/storage/bible/attack(mob/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	if(!chaplain)
		user << "\red The book sizzles in your hands."
		user.take_organ_damage(0,10)
		return

	if ((user.mutations & CLOWN) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.paralysis += 20
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if((M.mind in ticker.mode.cult) && (prob(20)))
			M << "\red The power of [src.deity_name] clears your mind of heresy!"
			user << "\red You see how [M]'s eyes become clear, the cult no longer holds control over him!"
			ticker.mode.remove_cultist(M.mind)
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] heals [] with the power of [src.deity_name]!</B>", user, M), 1)
			M << "\red May the power of [src.deity_name] compel you to be healed!"
			playsound(src.loc, "punch", 25, 1, -1)
		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.brainloss += 10
				M << "\red You feel dumber."
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] beats [] over the head with []!</B>", user, M, src), 1)
			playsound(src.loc, "punch", 25, 1, -1)
	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] smacks []'s lifeless corpse with [].</B>", user, M, src), 1)
		playsound(src.loc, "punch", 25, 1, -1)
	return

/obj/item/weapon/storage/bible/afterattack(atom/A, mob/user as mob)
	if (istype(A, /turf/simulated/floor))
		user << "\blue You hit the floor with the bible."
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/rune/proc/revealrunes)(src)

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)
	playsound(src.loc, "rustle", 50, 1, -5)
	..()
