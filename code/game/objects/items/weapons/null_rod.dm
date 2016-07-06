/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	flags = FPRINT
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = W_CLASS_TINY

/obj/item/weapon/nullrod/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is impaling \himself with \the [src]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/attack(mob/M as mob, mob/living/user as mob) //Paste from old-code to decult with a null rod.

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if(!ishuman(user) && !isbadmonkey(user)) //Fucks sakes
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if((M_CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='warning'>\The [src] slips out of [user]'s hands and hits \his head.</span>",
		"<span class='warning'>\The [src] slips out of your hands and hits your head.</span>")
		user.apply_damage(10, BRUTE, LIMB_HEAD)
		user.Stun(5)
		return

	if(ishuman(M)) //Typecasting, only humans can be vampires
		var/mob/living/carbon/human/H = M

		if(isvampire(H) && user.mind && (user.mind.assigned_role == "Chaplain")) //Fuck up vampires by smithing the shit out of them. Shock and Awe!
			if(!(VAMP_MATURE in H.mind.vampire.powers))
				to_chat(H, "<span class='warning'>\The [src]'s power violently interferes with your own!</span>")
				if(H.mind.vampire.nullified < 5) //Don't actually reduce their debuff if it's over 5
					H.mind.vampire.nullified = max(5, H.mind.vampire.nullified + 2)
				H.mind.vampire.smitecounter += 30 //Smithe the shit out of him. Four strikes and he's out

	//A 25% chance to de-cult per hit that bypasses all protections? Is this some kind of joke? The last thing cult needs right now is that kind of nerfs. Jesus dylan.
	/*
	if(iscult(M) && user.mind && (user.mind.assigned_role == "Chaplain")) //Much higher chance of deconverting cultists per hit if Chaplain
		if(prob(25))
			to_chat(M, "<span class='notice'>\The [src]'s intense field suddenly clears your mind of heresy. Your allegiance to Nar'Sie wanes!</span>")
			to_chat(user, "<span class='notice'>You see [M]'s eyes become clear. Nar'Sie no longer controls his mind, \the [src] saved him!</span>")
			ticker.mode.remove_cultist(M.mind)
		else //We aren't deconverting him this time, give the Cultist a fair warning
			to_chat(M, "<span class='warning'>\The [src]'s intense field is overwhelming you. Your mind feverishly questions Nar'Sie's teachings!</span>")
	*/

	..() //Whack their shit regardless. It's an obsidian rod, it breaks skulls

/obj/item/weapon/nullrod/afterattack(atom/A, mob/user as mob, prox_flag, params)
	if(!prox_flag)
		return
	user.delayNextAttack(8)
	if(istype(A, /turf/simulated/floor))
		to_chat(user, "<span class='notice'>You hit the floor with the [src].</span>")
		call(/obj/effect/rune/proc/revealrunes)(src)

/obj/item/weapon/nullrod/pickup(mob/living/user as mob)
	if(user.mind)
		if(user.mind.assigned_role == "Chaplain")
			to_chat(user, "<span class='notice'>The obsidian rod is teeming with divine power. You feel like you could pulverize a horde of undead with this.</span>")
		if(ishuman(user)) //Typecasting, only humans can be vampires
			var/mob/living/carbon/human/H = user
			if(isvampire(H) && !(VAMP_UNDYING in H.mind.vampire.powers))
				H.mind.vampire.smitecounter += 60
				to_chat(H, "<span class='danger'>You feel an unwanted presence as you pick up the rod. Your body feels like it is burning from the inside!</span>")
