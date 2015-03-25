/obj/item/weapon/melee
	needs_permit = 1

/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")
	hitsound = 'sound/weapons/slash.ogg' //pls replace

/obj/item/weapon/melee/chainofcommand/suicide_act(mob/user)
		user.visible_message("<span class='suicide'>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return (OXYLOSS)



/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_BELT
	force = 12 //9 hit crit
	w_class = 3
	var/cooldown = 0
	var/on = 1

/obj/item/weapon/melee/classic_baton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		add_fingerprint(user)
		if((CLUMSY in user.disabilities) && prob(50))
			user << "<span class ='danger'>You club yourself over the head.</span>"
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_organ_damage(2*force)
			return
		if(isrobot(target))
			..()
			return
		if(!isliving(target))
			return
		if (user.a_intent == "harm")
			if(!..()) return
			if(!isrobot(target)) return
		else
			if(cooldown <= 0)
				playsound(get_turf(src), 'sound/effects/woodhit.ogg', 75, 1, -1)
				target.Weaken(3)
				add_logs(user, target, "stunned", object="classic baton")
				src.add_fingerprint(user)
				target.visible_message("<span class ='danger'>[user] has knocked down [target] with \the [src]!</span>", \
					"<span class ='userdanger'>[user] has knocked down [target] with \the [src]!</span>")
				if(!iscarbon(user))
					target.LAssailant = null
				else
					target.LAssailant = user
				cooldown = 1
				spawn(40)
					cooldown = 0
		return
	else
		return ..()



/obj/item/weapon/melee/classic_baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_BELT
	w_class = 2
	needs_permit = 0
	force = 0
	on = 0

/obj/item/weapon/melee/classic_baton/telescopic/attack_self(mob/user as mob)
	on = !on
	if(on)
		user << "<span class ='warning'>You extend the baton.</span>"
		icon_state = "telebaton_1"
		item_state = "nullrod"
		w_class = 4 //doesnt fit in backpack when its on for balance
		force = 10 //stunbaton damage
		attack_verb = list("smacked", "struck", "cracked", "beaten")
	else
		user << "<span class ='notice'>You collapse the baton.</span>"
		icon_state = "telebaton_0"
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = 2
		force = 0 //not so robust now
		attack_verb = list("hit", "poked")

	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)



/obj/item/weapon/psycho
	name = "MEME KNIFE"
	desc = "The memes are loose! Alert the administration!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "knife"
	throwforce = 69
	w_class = 1
	throw_speed = 5
	throw_range = 8
	force = 10
	m_amt = 10
	g_amt = 10

/obj/item/weapon/psycho/knife
	name = "pocket knife"
	desc = "A small stainless-steel pocket knife. It's as sharp as the edge of a flatline."
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = 2
	force = 13
	throwforce = 15
	m_amt = 75
	g_amt = 0
	embed_chance = 100
	embedded_fall_chance = 25

/obj/item/weapon/psycho/bat
	name = "baseball bat"
	desc = "A heavy wooden baseball bat."
	icon_state = "bat"
	w_class = 4
	force = 17
	throwforce = 5
	throw_range = 3
	m_amt = 0
	g_amt = 0

/obj/item/weapon/psycho/pipe
	name = "lead pipe"
	desc = "A section of lead piping. It seems designed to transport hydrogen gas."
	icon_state = "paip"
	w_class = 3
	force = 12
	throwforce = 5
	throw_range = 4
	m_amt = 100
	g_amt = 0

/obj/item/weapon/twohanded/golf_club
	name = "golf club"
	desc = "A golf club. It's long, heavy, and worn down - probably because of all its use in Paris."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "golf0"
	w_class = 4
	force = 5
	force_unwielded = 5
	force_wielded = 17
	throwforce = 3
	throw_range = 1
	m_amt = 200
	g_amt = 0

/obj/item/weapon/twohanded/golf_club/update_icon()
	icon_state = "golf[wielded]"
	return

/obj/item/weapon/psycho/frying_pan
	name = "frying pan"
	desc = "A grease-free steel frying pan. Reminds you of silver lights."
	icon_state = "pan"
	hitsound = 'sound/items/trayhit2.ogg'
	w_class = 3
	force = 14
	throwforce = 4
	m_amt = 150
	g_amt = 0

/obj/item/weapon/twohanded/sledgehammer
	name = "sledgehammer"
	desc = "A massive sledgehammer. It's unwieldly and probably more effective in two hands."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sledge0"
	force = 7
	force_unwielded = 7
	force_wielded = 22
	throwforce = 10
	throw_range = 1
	w_class = 5
	m_amt = 75 //the hammer head

/obj/item/weapon/twohanded/sledgehammer/update_icon()
	icon_state = "sledge[wielded]"
	return

/obj/item/weapon/psycho/machete
	name = "machete"
	desc = "A utilitarian machete. Bring out your inner animal."
	icon_state = "machete"
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = 3
	force = 16
	throwforce = 14
	embed_chance = 33
	embedded_fall_chance = 50
	m_amt = 105
	g_amt = 0

/obj/item/weapon/psycho/hammer
	name = "hammer"
	desc = "A utility hammer, found in any good carpenter's toolbox. Used by assassins in deep cover."
	icon_state = "hammer"
	force = 9
	w_class = 2
	throwforce = 4
	m_amt = 25
