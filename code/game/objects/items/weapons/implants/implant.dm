/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	origin_tech = "materials=2;biotech=3;programming=2"
	actions_types = list(/datum/action/item_action/hands_free/activate)
	var/activated = 1 //1 for implant types that can be activated, 0 for ones that are "always on" like mindshield implants
	var/mob/living/imp_in = null
	item_color = "b"
	var/allow_multiple = FALSE
	var/uses = -1
	flags = DROPDEL


/obj/item/weapon/implant/proc/trigger(emote, mob/living/carbon/source)
	return

/obj/item/weapon/implant/proc/activate()
	return

/obj/item/weapon/implant/ui_action_click()
	activate("action_button")

/obj/item/weapon/implant/proc/can_be_implanted_in(mob/living/target) // for human-only and other special requirements
	return TRUE

/mob/living/proc/can_be_implanted()
	return TRUE

/mob/living/silicon/can_be_implanted()
	return FALSE

/mob/living/simple_animal/can_be_implanted()
	return healable //Applies to robots and most non-organics, exceptions can override.



//What does the implant do upon injection?
//return 1 if the implant injects
//return -1 if the implant fails to inject
//return 0 if there is no room for implant
/obj/item/weapon/implant/proc/implant(mob/living/target, mob/user, silent = 0)
	LAZYINITLIST(target.implants)
	if(!target.can_be_implanted() || !can_be_implanted_in(target))
		return -1
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/weapon/implant/imp_e = X
			if(!allow_multiple)
				if(imp_e.uses < initial(imp_e.uses)*2)
					if(uses == -1)
						imp_e.uses = -1
					else
						imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
					qdel(src)
					return 1
				else
					return 0

	src.loc = target
	imp_in = target
	target.implants += src
	if(activated)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_implants()

	if(user)
		add_logs(user, target, "implanted", object="[name]")

	return 1

/obj/item/weapon/implant/proc/removed(mob/living/source, silent = 0, special = 0)
	src.loc = null
	imp_in = null
	source.implants -= src
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(source)
	if(ishuman(source))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	return 1

/obj/item/weapon/implant/Destroy()
	if(imp_in)
		removed(imp_in)
	return ..()

/obj/item/weapon/implant/proc/get_data()
	return "No information available"

/obj/item/weapon/implant/dropped(mob/user)
	. = 1
	..()
