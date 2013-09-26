/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	var/breakouttime = 300	//Deciseconds = 30s = 0.5 minute


/obj/item/weapon/legcuffs/beartrap
	name = "bear trap"
	desc = "A trap used to catch bears and other legged creatures."
	icon_state = "beartrap0"
	throw_speed = 2
	throw_range = 1
	var/armed = 0

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the [src.name] on \his head! It looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS)

/obj/item/weapon/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		user << "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>"

/obj/item/weapon/legcuffs/beartrap/HasEntered(atom/movable/AM)
	if(armed)
		if(ishuman(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/H = AM
				if(H.m_intent == "run")
					armed = 0
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed(0)
					H.visible_message("<span class='danger'>[H] steps on [src].</span>", "<span class='userdanger'>You step on [src]!</span>", "You hear a fleshy snap!")
					feedback_add_details("handcuffs","B")	//Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20
	..()