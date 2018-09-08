
/mob
	var/bloody_hands = 0

/obj/item/clothing/gloves
	var/transfer_blood = 0


/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	item_flags = NOBLUDGEON
	container_type = OPENCONTAINER
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 5
	spillable = FALSE

/obj/item/reagent_containers/glass/rag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is smothering [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

/obj/item/reagent_containers/glass/rag/afterattack(atom/A as obj|turf|area, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(iscarbon(A) && A.reagents && reagents.total_volume)
		var/mob/living/carbon/C = A
		var/reagentlist = pretty_string_from_reagent_list(reagents)
		var/log_object = "a damp rag containing [reagentlist]"
		if(user.a_intent == INTENT_HARM && !C.is_mouth_covered())
			reagents.reaction(C, INGEST)
			reagents.trans_to(C, reagents.total_volume)
			C.visible_message("<span class='danger'>[user] has smothered \the [C] with \the [src]!</span>", "<span class='userdanger'>[user] has smothered you with \the [src]!</span>", "<span class='italics'>You hear some struggling and muffled cries of surprise.</span>")
			log_combat(user, C, "smothered", log_object)
		else
			reagents.reaction(C, TOUCH)
			reagents.clear_reagents()
			C.visible_message("<span class='notice'>[user] has touched \the [C] with \the [src].</span>")
			log_combat(user, C, "touched", log_object)

	else if(istype(A) && src in user)
		user.visible_message("[user] starts to wipe down [A] with [src]!", "<span class='notice'>You start to wipe down [A] with [src]...</span>")
		if(do_after(user,30, target = A))
			user.visible_message("[user] finishes wiping off [A]!", "<span class='notice'>You finish wiping off [A].</span>")
			SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_MEDIUM)
	return
