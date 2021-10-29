/obj/effect/proc_holder/spell/self/chameleon_skin_activate
	name = "Activate Chameleon Skin"
	desc = "The chromatophores in your skin adjust to your surroundings, as long as you stay still."
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak" //SKYRAT EDIT END

/obj/effect/proc_holder/spell/self/chameleon_skin_activate/cast(list/targets, mob/user = usr)
	. = ..()

	if(HAS_TRAIT(user,TRAIT_CHAMELEON_SKIN))
		chameleon_skin_deactivate(user)
		return

	ADD_TRAIT(user, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	to_chat(user, "The pigmentation of your skin shifts and starts to take on the colors of your surroundings.")

/obj/effect/proc_holder/spell/self/chameleon_skin_activate/proc/chameleon_skin_deactivate(mob/user = usr)
	if(!HAS_TRAIT_FROM(user,TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(user, TRAIT_CHAMELEON_SKIN, GENETIC_MUTATION)
	user.alpha = 255
	to_chat(user, text("Your skin shifts as it shimmers back into its original colors."))
