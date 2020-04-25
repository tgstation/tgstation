/obj/item/pushbroom
	name = "push broom"
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

/obj/item/pushbroom/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/pushbroom/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=12, icon_wielded="broom1")

/obj/item/pushbroom/update_icon_state()
	icon_state = "broom0"

/// triggered on wield of two handed item
/obj/item/pushbroom/proc/on_wield(obj/item/source, mob/user)
	to_chat(user, "<span class='notice'>You brace the [src] against the ground in a firm sweeping stance.</span>")
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/sweep)

/// triggered on unwield of two handed item
/obj/item/pushbroom/proc/on_unwield(obj/item/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/pushbroom/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	sweep(user, A, FALSE)

/obj/item/pushbroom/proc/sweep(mob/user, atom/A, moving = TRUE)
	var/turf/target
	if (!moving)
		if (isturf(A))
			target = A
		else
			target = A.loc
	else
		target = user.loc
	if (!isturf(target))
		return
	if (locate(/obj/structure/table) in target.contents)
		return
	var/i = 0
	var/turf/target_turf = get_step(target, user.dir)
	var/obj/machinery/disposal/bin/target_bin = locate(/obj/machinery/disposal/bin) in target_turf.contents
	for(var/obj/item/garbage in target.contents)
		if(!garbage.anchored)
			if (target_bin)
				garbage.forceMove(target_bin)
			else
				garbage.Move(target_turf, user.dir)
			i++
		if(i > 19)
			break
	if(i > 0)
		if (target_bin)
			target_bin.update_icon()
			to_chat(user, "<span class='notice'>You sweep the pile of garbage into [target_bin].</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 30, TRUE, -1)

/obj/item/pushbroom/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J) //bless you whoever fixes this copypasta
	J.put_in_cart(src, user)
	J.mybroom=src
	J.update_icon()
