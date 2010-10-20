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

/obj/item/weapon/storage/bible/attack(mob/M as mob, mob/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	if(!chaplain)
		usr << "\red The book sizzles in your hands."
		usr.fireloss += 10
		return

	if ((usr.mutations & 16) && prob(50))
		usr << "\red The [src] slips out of your hand and hits your head."
		usr.bruteloss += 10
		usr.paralysis += 20
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if (ticker.mode.name == "cult" && prob(10))
			ticker.mode:remove_cultist(M.mind)
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] heals [] with the power of Christ!</B>", user, M), 1)
			M << "\red May the power of Christ compel you to be healed!"
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

/obj/item/weapon/storage/bible/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (src.contents.len >= 7)
		return
	if (W.w_class > 3)
		return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O.w_class
		//Foreach goto(46)
	t += W.w_class
	if (t > 5)

		user << "You cannot fit the item inside. (Remove larger classed items)"
		return
	playsound(src.loc, "rustle", 50, 1, -5)
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	return

