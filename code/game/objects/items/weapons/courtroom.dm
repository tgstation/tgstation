// Contains:
// Gavel Hammer
// Gavel Block

/obj/item/weapon/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelhammer"
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "battered", "judged", "whacked")
	resistance_flags = FLAMMABLE

/obj/item/weapon/gavelhammer/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] has sentenced [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
	return (BRUTELOSS)

// Objection Gavel: lawyer-specific traitor item

/obj/item/weapon/gavelhammer/objection
	name = "objection gavel"
	desc = "Order, order! I'm planting bombs in my courthouse!"
	var/duration = 250
	var/cooldown = 0

/obj/item/weapon/gavelhammer/objection/attack_self(mob/living/carbon/user)
	object(user)

/obj/item/weapon/gavelhammer/objection/after_attack(mob/living/carbon/user)
	object(user)

/obj/item/weapon/gavelhammer/objection/proc/object(mob/living/carbon/user)
	if(cooldown < world.time)
		cooldown = world.time + 3000 //5 minutes
		playsound(loc, 'sound/items/gavel.ogg', 100, 1)
		user.say("OBJECTION!!")
		add_fingerprint(user)
		var/obj/effect/timestop/T = new /obj/effect/timestop(user.loc)
		T.immune += user
		T.duration = duration
		T.timestop()
	else
		user << "<span class='warning'>The gavel is recharging!</span>"

/obj/item/weapon/gavelblock
	name = "gavel block"
	desc = "Smack it with a gavel hammer when the assistants get rowdy."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelblock"
	force = 2
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/weapon/gavelblock/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/gavelhammer/objection))
		var/obj/item/weapon/gavelhammer/objection/gavel = I
		gavel.object()
	else if(istype(I, /obj/item/weapon/gavelhammer))
		playsound(loc, 'sound/items/gavel.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] strikes [src] with [I].</span>")
		user.changeNext_move(CLICK_CD_MELEE)
	else
		return ..()