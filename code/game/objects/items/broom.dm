/obj/item/broom
	name = "broom"
	desc = "This is my BROOMSTICK! It can be used manually or braced with two hands to sweep items as you move. It has a telescopic handle for compact storage."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("swept", "brushed off", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE

/obj/item/broom/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=12, icon_update_callback=CALLBACK(src, .proc/icon_update_callback))

/obj/item/broom/proc/icon_update_callback(wielded)
	icon_state = "broom[wielded]"

/obj/item/broom/equipped(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/sweep)

/obj/item/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/broom/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	sweep(user, A, FALSE)

/obj/item/broom/proc/sweep(mob/user, atom/A, moving = TRUE)
	if(!SEND_SIGNAL(src, COMSIG_IS_TWOHANDED_WIELDED))
		return
	var/turf/target
	if (!moving)
		if (isturf(A))
			target = A
		else
			target = A.loc
	else
		target = user.loc
	if (locate(/obj/structure/table) in target.contents)
		return
	var/i = 0
	for(var/obj/item/garbage in target.contents)
		if(!garbage.anchored)
			garbage.Move(get_step(target, user.dir), user.dir)
		i++
		if(i >= 20)
			break
	if(i >= 1)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 30, TRUE, -1)

/obj/item/broom/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J) //bless you whoever fixes this copypasta
	J.put_in_cart(src, user)
	J.mybroom=src
	J.update_icon()
