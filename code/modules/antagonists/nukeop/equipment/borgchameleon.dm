/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/can_use = 1
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_appearance = null
	var/friendlyName
	var/savedName
	var/active = FALSE
	var/activationCost = 300
	var/activationUpkeep = 30
	var/disguise = "engineer"

/obj/item/borg_chameleon/Initialize()
	. = ..()
	friendlyName = pick(GLOB.ai_names)

/obj/item/borg_chameleon/dropped()
	..()
	disrupt()

/obj/item/borg_chameleon/equipped()
	..()
	disrupt()

/obj/item/borg_chameleon/attack_self(mob/user)
	if (isturf(user.loc))
		toggle(user)
	else
		to_chat(user, "<span class='warning'>You can't use [src] while inside something!</span>")

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/user)
	if(active)
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		to_chat(user, "<span class='notice'>You deactivate \the [src].</span>")
		user.name = savedName
		user.module.cyborg_base_icon = initial(user.module.cyborg_base_icon)
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		to_chat(user, "<span class='notice'>You activate \the [src].</span>")
		savedName = user.name
		user.name = friendlyName
		user.module.cyborg_base_icon = disguise
	active = !active
	user.update_icons()

/obj/item/borg_chameleon/proc/disrupt(delete_dummy = 1)
	if(active)
		for(var/mob/M in active_dummy)
			to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = 0
		spawn(50) can_use = 1
