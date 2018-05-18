/obj/item/nanite_analyzer
	name = "nanite analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_analyzer"
	desc = "A hand-held body scanner able to detect nanites."
	flags_1 = CONDUCT_1 | NOBLUDGEON_1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=200)
	var/advanced = TRUE

/obj/item/nanite_analyzer/attack(mob/living/M, mob/living/carbon/human/user)
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s nanites.</span>")

	nanitescan(user, M, advanced)

	add_fingerprint(user)

/proc/nanitescan(mob/living/user, mob/living/M, deep = FALSE)
	if(!istype(M))
		return
	if(!M.reagents)
		return
	if(M.reagents.reagent_list.len)
		to_chat(user, "<span class='notice'>Subject contains the following nanites:</span>")
		for(var/datum/reagent/nanites/N in M.reagents.reagent_list)
			if(istype(N, /datum/reagent/nanites/programmed))
				var/datum/reagent/nanites/programmed/P = N
				to_chat(user, "<span class='notice'><b>\[[P.data["activated"] ? "Active" : "Inactive"]\]</b> [P.volume] units of [P.name].</span>")
				if(deep)
					if(P.data["activation_code"])
						to_chat(user, "   Activation Delay: [P.data["activation_delay"] * 2] seconds")
					if(P.data["timer"])
						to_chat(user, "   Timer: [P.data["timer"] * 2] seconds")
						if(P.data["timer_type"])
							to_chat(user, "   Timer Type: [P.get_timer_type_text()]")
					if(P.data["activation_code"])
						to_chat(user, "   Activation Code: [P.data["activation_code"]]")
					if(P.data["deactivation_code"])
						to_chat(user, "   Deactivation Code: [P.data["deactivation_code"]]")
					if(P.data["kill_code"])
						to_chat(user, "   Kill Code: [P.data["kill_code"]]")
					if(P.data["trigger_code"])
						to_chat(user, "   Trigger Code: [P.data["trigger_code"]]")
					if(P.data["relay_code"])
						to_chat(user, "   Relay Code: [P.data["relay_code"]]")
			else
				to_chat(user, "<span class='notice'>[N.volume] units of [N.name].</span>")