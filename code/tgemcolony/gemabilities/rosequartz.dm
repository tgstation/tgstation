/datum/action/innate/gem/healingtears
	name = "Healing Tears"
	desc = "Fully revive someone nearby. Does not work on self."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "healingtears"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/healingtears/Activate()
	var/list/nearby = list()
	for(var/atom/A in view(owner,1))
		if(istype(A,/mob/living) || istype(A,/obj/structure/gem))
			if(A != owner) //no self healing.
				nearby.Add(A)
	var/atom/target = input("Who do you want to heal?") as null|anything in nearby
	if(target != null)
		var/isinrange = FALSE
		for(var/atom/A in view(owner,1))
			if(A == target)
				isinrange = TRUE
		if(isinrange == TRUE)
			if(istype(target,/mob/living) && target != owner) //what did i just say?
				var/mob/living/mobheal = target
				mobheal.revive(full_heal = TRUE, admin_revive = TRUE)
				mobheal.grab_ghost()
				owner.visible_message("<span class='warning'>[owner] heals [target] with their tears!</span>")
			if(istype(target,/obj/structure/gem))
				var/obj/structure/gem/gemheal = target
				gemheal.revive()
				owner.visible_message("<span class='warning'>[owner] heals [target] with their tears!</span>")
		else
			to_chat(usr, "<span class='warning'>You have to be in range.</span>")