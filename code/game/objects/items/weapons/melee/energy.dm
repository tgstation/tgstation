/obj/item/weapon/melee/energy
	var/active = 0
	sharpness = 1.5 //very very sharp
	heat_production = 3500

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
						"<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/is_hot()
	if(active)
		return heat_production
	return 0

/obj/item/weapon/melee/energy/is_sharp()
	if(active)
		return sharpness
	return 0

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "combat=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")


	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</span>")
		return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/sword
	color
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	var/base_state = "sword"
	var/active_state = ""
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/New()
	..()
	_color = pick("red","blue","green","purple")
	if(!active_state)
		active_state = base_state + _color
	update_icon()

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50) && active) //only an on blade can cut
		to_chat(user, "<span class='danger'> You accidentally cut yourself with [src].</span>")
		user.take_organ_damage(5,5)
		return
	toggleActive(user)
	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/sword/proc/toggleActive(mob/user, var/togglestate = "") //you can use togglestate to manually set the sword on or off
	switch(togglestate)
		if("on")
			active = 1
		if("off")
			active = 0
		else
			active = !active
	if (active)
		force = 30
		w_class = 4
		hitsound = "sound/weapons/blade1.ogg"
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'> [src] is now active.</span>")
	else
		force = 3
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		hitsound = "sound/weapons/empty.ogg"
		to_chat(user, "<span class='notice'> [src] can now be concealed.</span>")
	update_icon()

/obj/item/weapon/melee/energy/sword/update_icon()
	if(active && _color)
		icon_state = active_state
	else
		icon_state = "[base_state][active]"

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/sword))
		if(W == src)
			to_chat(user, "<span class='notice'>You try to attach the end of the energy sword to... itself. You're not very smart, are you?</span>")
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>")
			new /obj/item/weapon/dualsaber(user.loc)
			del(W)
			del(src)

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	base_state = "cutlass"

/obj/item/weapon/melee/energy/sword/pirate/New()
	..()
	_color = null
	update_icon()
