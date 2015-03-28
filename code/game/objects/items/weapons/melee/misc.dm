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

/obj/item/weapon/melee/pocket_knife
	name = "pocket knife"
	desc = "A small, stainless-steel pocket knife with an imitation leather handle."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pocket_knife"
	slot_flags = SLOT_BELT
	w_class = 2
	force = 10
	throwforce = 8
	throw_range = 8
	attack_verb = list("cut", "stabbed", "sliced")
	embed_chance = 80
	embedded_fall_chance = 33
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/melee/baseball_bat
	name = "baseball bat"
	desc = "A hefty, sturdy wooden baseball bat. Ideally, hits baseballs."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "ball_bat"
	w_class = 4
	force = 18
	throwforce = 7
	throw_range = 2
	attack_verb = list("slammed", "smashed", "beaten")

/obj/item/weapon/melee/lead_pipe
	name = "lead pipe"
	desc = "A section of lead piping. What's it doing up here, where it can't possibly be utilized?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "lead_pipe"
	slot_flags = SLOT_BELT
	w_class = 3
	force = 12
	throwforce = 9
	throw_range = 5
	m_amt = 75

/obj/item/weapon/melee/golf_club
	name = "golf club"
	desc = "You don't even know anymore. Why would someone bring a nine-iron onto a space station?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "golf_club"
	w_class = 4
	force = 16
	throwforce = 7
	throw_range = 3
	m_amt = 125

/obj/item/weapon/melee/frying_pan
	name = "frying pan"
	desc = "A cast-iron frying pan designed for cooking food."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "frying_pan"
	w_class = 3
	force = 12
	throwforce = 10
	throw_range = 5
	m_amt = 75
	attack_verb = list("panned", "goldrushed")
	hitsound = 'sound/items/trayhit2.ogg'

/obj/item/weapon/melee/sledgehammer
	name = "sledgehammer"
	desc = "A massive sledgehammer for breaking things and sticking them in place."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sledgehammer"
	w_class = 5
	force = 22 //It's a fuckin' SLEDGEHAMMER.
	throwforce = 20
	throw_range = 1
	m_amt = 25 //Hammer's head

/obj/item/weapon/melee/machete
	name = "machete"
	desc = "A machete, ideal for cutting through thick vegetation."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "machete"
	slot_flags = SLOT_BELT
	w_class = 3
	force = 15
	throwforce = 17
	throw_range = 8
	embed_chance = 25
	embedded_fall_chance = 50
	m_amt = 100
	attack_verb = list("slashed", "sliced", "cut", "stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/melee/hammer
	name = "carpentry hammer"
	desc = "A handy-dandy hammer found in any good architect's toolbox."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "carpenter_hammer"
	slot_flags = SLOT_BELT
	w_class = 2
	force = 9
	throwforce = 5
	throw_range = 8 //Hammers are fairly light
	m_amt = 10
