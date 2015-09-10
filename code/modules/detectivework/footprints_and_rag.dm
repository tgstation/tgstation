
/mob
	var/bloody_hands = 0
	var/mob/living/carbon/human/bloody_hands_mob

/obj/item/clothing/gloves
	var/transfer_blood = 0
	var/mob/living/carbon/human/bloody_hands_mob


/obj/item/weapon/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = 1
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	spillable = 0

/obj/item/weapon/reagent_containers/glass/rag/afterattack(atom/A as obj|turf|area, mob/user,proximity)
	if(!proximity)
		return
	if(iscarbon(A) && A.reagents && reagents.total_volume)
		var/mob/living/carbon/C = A
		if(user.a_intent == "harm" && !C.is_mouth_covered())
			reagents.reaction(C, INGEST)
			reagents.trans_to(C, reagents.total_volume)
			C.visible_message("<span class='danger'>[user] has smothered \the [C] with \the [src]!</span>", "<span class='userdanger'>[user] has smothered you with \the [src]!</span>", "<span class='italics'>You hear some struggling and muffled cries of surprise.</span>")
			var/reagentlist = pretty_string_from_reagent_list(A.reagents)
			log_game("[key_name(user)] smothered [key_name(A)] with a damp rag containing [reagentlist]")
			log_attack("[key_name(user)] smothered [key_name(A)] with a damp rag containing [reagentlist]")
		else
			reagents.reaction(C, TOUCH)
			reagents.clear_reagents()
			C.visible_message("<span class='notice'>[user] has touched \the [C] with \the [src].</span>")

	else if(istype(A) && src in user)
		user.visible_message("[user] starts to wipe down [A] with [src]!", "<span class='notice'>You start to wipe down [A] with [src]...</span>")
		if(do_after(user,30, target = A))
			user.visible_message("[user] finishes wiping off the [A]!", "<span class='notice'>You finish wiping off the [A].</span>")
			A.clean_blood()
	return
