/obj/item/device/chameleon/bomb
	name = "chameleon bomb"
	desc = "Hit the bomb on any object to disguise it as that object. Use the bomb in hand to arm/disarm it. The bomb will explode when anyone tries to pick up the armed bomb."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "cham_bomb"
	var/dev_range = 0
	var/lar_range = 0
	var/med_range = 4
	var/low_range = 6
	var/burn_range = 4
	var/armed = FALSE

/obj/item/device/chameleon/bomb/examine(mob/user)
	. = ..()
	if((IS_TRAITOR(user) || !IS_NUKE_OP(user)) && armed) //helpful to other syndicates
		. += "This is a bomb in disguise!"

/obj/item/device/chameleon/bomb/dropped()
	..()
	if(!armed)
		armed = TRUE
		playsound(src, 'sound/effects/c4beep.ogg', 20, 1)

/obj/item/device/chameleon/bomb/pickup()
	..()
	if(armed)
		explosion(src, dev_range, lar_range, med_range, low_range, flame_range = burn_range)
		qdel(src)
	else
		return

/obj/item/device/chameleon/bomb/afterattack(atom/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(isturf(target))
		return
	if(ismob(target))
		return
	if(istype(target, /obj/structure/falsewall))
		return
	if(target.alpha != 255)
		return
	if(target.invisibility != 0)
		return
	if(iseffect(target))
		if(!(istype(target, /obj/effect/decal))) //be a footprint
			return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, TRUE, -6)
	to_chat(user, span_notice("Copied [target]'s appearance."))
	name = target.name
	desc = target.desc
	icon = target.icon
	icon_state = target.icon_state
