/obj/item/nullrod/rosary
	icon = 'modular_citadel/icons/obj/items_and_weapons.dmi'
	icon_state = "rosary"
	item_state = null
	name = "prayer beads"
	desc = "A set of prayer beads used by many of the more traditional religions in space"
	force = 0
	throwforce = 0
	var/praying = FALSE
	var/deity_name = "Coderbus" //This is the default, hopefully won't actually appear if the religion subsystem is running properly

/obj/item/nullrod/rosary/Initialize()
	.=..()
	if(SSreligion.religion)
		deity_name = SSreligion.deity

/obj/item/nullrod/rosary/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(!user.mind || user.mind.assigned_role != "Chaplain")
		to_chat(user, "<span class='notice'>You are not close enough with [deity_name] to use [src].</span>")
		return

	if(praying)
		to_chat(user, "<span class='notice'>You are already using [src].</span>")
		return

	user.visible_message("<span class='info'>[user] kneels[M == user ? null : " next to [M]"] and begins to utter a prayer to [deity_name].</span>", \
		"<span class='info'>You kneel[M == user ? null : " next to [M]"] and begin a prayer to [deity_name].</span>")

	praying = TRUE
	if(do_after(user, 100, target = M))
		if(istype(M, /mob/living/carbon/human)) // This probably should not work on catpeople. They're unholy abominations.
			var/mob/living/carbon/human/target = M

			if(iscultist(M) || is_servant_of_ratvar(M)) //ripped from holywater code.
				if(iscultist(M))
					SSticker.mode.remove_cultist(M.mind, FALSE, TRUE)
				else if(is_servant_of_ratvar(M))
					remove_servant_of_ratvar(M)

			to_chat(target, "<span class='notice'>[user]'s prayer to [deity_name] has eased your pain!</span>")
			target.adjustToxLoss(-5, TRUE, TRUE)
			target.adjustOxyLoss(-5)
			target.adjustBruteLoss(-5)
			target.adjustFireLoss(-5)

			praying = FALSE

	else
		to_chat(user, "<span class='notice'>Your prayer to [deity_name] was interrupted.</span>")
		praying = FALSE
