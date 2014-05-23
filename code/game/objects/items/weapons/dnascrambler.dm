/obj/item/weapon/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "b10"
	var/used = null

	update_icon()
		if(used)
			icon_state = "b0"
		else
			icon_state = "b10"

	attack(mob/M as mob, mob/user as mob)
		if(!M || !user)
			return

		if(!ishuman(M) || !ishuman(user))
			return

		if(src.used)
			return

		if(M == user)
			user.visible_message("\red <b>[user.name] injects \himself with [src]!</b>")
			src.injected(user,user)
		else
			user.visible_message("\red <b>[user.name] is trying to inject [M.name] with [src]!</b>")
			if (do_mob(user,M,30))
				user.visible_message("\red <b>[user.name] injects [M.name] with [src].</b>")
				src.injected(M, user)
			else
				user << "\red You failed to inject [M.name]."

	proc/injected(var/mob/living/carbon/target, var/mob/living/carbon/user)
		target.generate_name()
		target.real_name = target.name

		scramble(1, target, 100)

		log_attack("[key_name(user)] injected [key_name(target)] with the [name]")
		log_game("[key_name_admin(user)] injected [key_name_admin(target)] with the [name]")

		src.used = 1
		src.update_icon()
		src.name = "used " + src.name