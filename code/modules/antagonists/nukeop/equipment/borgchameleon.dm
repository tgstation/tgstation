/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/friendlyName
	var/savedName
	var/active = FALSE
	var/activationCost = 300
	var/activationUpkeep = 50
	var/disguise = "engineer"
	var/datum/component/mobhook // need this to deal with unregistration properly
	var/mob/living/silicon/robot/user // needed for process()

/obj/item/borg_chameleon/Initialize()
	. = ..()
	friendlyName = pick(GLOB.ai_names)

/obj/item/borg_chameleon/Destroy()
	QDEL_NULL(mobhook)
	return ..()

/obj/item/borg_chameleon/dropped(mob/user)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/equipped(mob/user)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/attack_self(mob/living/silicon/robot/user)
	if (user && user.cell && user.cell.charge >  activationCost)
		if (isturf(user.loc))
			toggle(user)
		else
			to_chat(user, "<span class='warning'>You can't use [src] while inside something!</span>")
	else
		to_chat(user, "<span class='warning'>You need at least [activationCost] charge in your cell to use [src]!</span>")

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/user)
	if(active)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
		to_chat(user, "<span class='notice'>You deactivate \the [src].</span>")
		deactivate(user)
	else
		to_chat(user, "<span class='notice'>You activate \the [src].</span>")
		playsound(src, 'sound/effects/seedling_chargeup.ogg', 100, 1, -6)
		if (do_after(user, 50, target=user) && user.cell.use(activationCost))
			playsound(src, 'sound/effects/bamf.ogg', 100, 1, -6)
			to_chat(user, "<span class='notice'>You are now disguised as the Nanotrasen engineering borg \"[friendlyName]\".</span>")
			activate(user)
		else
			to_chat(user, "<span class='warning'>The chameleon field fizzles.</span>")
			do_sparks(3, FALSE, user)

/obj/item/borg_chameleon/process()
	if (user)
		if (!user.cell || !user.cell.use(activationUpkeep))
			disrupt(user)
	else
		return PROCESS_KILL

/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/user)
	START_PROCESSING(SSobj, src)
	src.user = user
	savedName = user.name
	user.name = friendlyName
	user.module.cyborg_base_icon = disguise
	active = TRUE
	if (mobhook && mobhook.parent != user)
		QDEL_NULL(mobhook)
	if (!mobhook)
		var/callback = CALLBACK(src, .proc/disrupt, user) // push user into the callback so that it's guaranteed to be the first arg
		mobhook = user.AddComponent(/datum/component/redirect, list( // list here all signals that should break the camouflage
			COMSIG_PARENT_ATTACKBY = callback,
			COMSIG_ATOM_ATTACK_HAND = callback,
			COMSIG_MOVABLE_IMPACT_ZONE = callback,
			COMSIG_ATOM_BULLET_ACT = callback,
			COMSIG_ATOM_EX_ACT = callback,
			COMSIG_ATOM_FIRE_ACT = callback,
			COMSIG_ATOM_EMP_ACT = callback,
			))
	user.update_icons()

/obj/item/borg_chameleon/proc/deactivate(mob/living/silicon/robot/user)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(mobhook)
	do_sparks(5, FALSE, user)
	user.name = savedName
	user.module.cyborg_base_icon = initial(user.module.cyborg_base_icon)
	active = FALSE
	user.update_icons()
	src.user = user

/obj/item/borg_chameleon/proc/disrupt(mob/living/silicon/robot/user)
	if(active)
		to_chat(user, "<span class='danger'>Your chameleon field deactivates.</span>")
		deactivate(user)
