/obj/item/weapon/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	origin_tech = "materials=2;biotech=3;programming=2"
	actions_types = list(/datum/action/item_action/hands_free/activate)
	var/activated = 1 //1 for implant types that can be activated, 0 for ones that are "always on" like loyalty implants
	var/implanted = null
	var/mob/living/imp_in = null
	item_color = "b"
	var/allow_multiple = 0
	var/uses = -1


/obj/item/weapon/implant/proc/trigger(emote, mob/source)
	return

/obj/item/weapon/implant/proc/activate()
	return

/obj/item/weapon/implant/ui_action_click()
	activate("action_button")


//What does the implant do upon injection?
//return 1 if the implant injects
//return -1 if the implant fails to inject
//return 0 if there is no room for implant
/obj/item/weapon/implant/proc/implant(var/mob/source, var/mob/user)
	var/obj/item/weapon/implant/imp_e = locate(src.type) in source
	if(!allow_multiple && imp_e && imp_e != src)
		if(imp_e.uses < initial(imp_e.uses)*2)
			if(uses == -1)
				imp_e.uses = -1
			else
				imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
			qdel(src)
			return 1
		else
			return 0

	src.loc = source
	imp_in = source
	implanted = 1
	if(activated)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(source)
	if(istype(source, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = source
		H.sec_hud_set_implants()

	if(user)
		add_logs(user, source, "implanted", object="[name]")

	return 1

/obj/item/weapon/implant/proc/removed(var/mob/source)
	src.loc = null
	imp_in = null
	implanted = 0
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(source)
	if(istype(source, /mob/living/carbon/human))
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
	..()
	. = 1
	qdel(src)

