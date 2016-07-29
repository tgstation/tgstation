<<<<<<< HEAD

/mob
	var/bloody_hands = 0

/obj/item/clothing/gloves
	var/transfer_blood = 0


/obj/item/weapon/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = 1
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	flags = OPENCONTAINER | NOBLUDGEON
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 5
	spillable = 0

/obj/item/weapon/reagent_containers/glass/rag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] ties the [src.name] around their head and groans! It looks like--</span>")
	user.say("MY BRAIN HURTS!!")
	return (OXYLOSS)

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
			A.wash_cream()
	return
=======
/mob
	var/bloody_hands = 0
	var/mob/living/carbon/human/bloody_hands_mob
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/feet_blood_color
	var/track_blood_type

/obj/item/clothing/gloves
	var/transfer_blood = 0
	var/mob/living/carbon/human/bloody_hands_mob

/obj/item/clothing/shoes/
	var/track_blood = 0

/obj/item/weapon/reagent_containers/glass/rag
	name = "rag" //changed to "rag" from "damp rag" - Hinaichigo
	desc = "For cleaning up messes, you suppose."
	w_class = W_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5)
	volume = 5
	can_be_placed_into = null

/obj/item/weapon/reagent_containers/glass/rag/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/glass/rag/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/rag/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(user.zone_sel.selecting == "mouth")
		if(ismob(M) && M.reagents && reagents.total_volume)
			user.visible_message("<span class='warning'>\The [M] has been smothered with \the [src] by \the [user]!</span>", "<span class='warning'>You smother \the [M] with \the [src]!</span>", "You hear some struggling and muffled cries of surprise")
			src.reagents.reaction(M, TOUCH)
			spawn(5) src.reagents.clear_reagents()
			return 1
	else
		..()

/obj/item/weapon/reagent_containers/glass/rag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag) return 0 // Not adjacent

	if(reagents.total_volume < 1)
		to_chat(user, "<span class='notice'>Your rag is dry!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins to wipe down \the [target].</span>", "<span class='notice'>You begin to wipe down \the [target].</span>")
	if(do_after(user,target, 50))
		if(target)
			target.clean_blood()
			if(isturf(target))
				for(var/obj/effect/O in target)
					if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
						qdel(O)
			reagents.remove_any(1)
			user.visible_message("<span class='notice'>[user] finishes wiping down \the [target].</span>", "<span class='notice'>You have finished wiping down \the [target]!</span>")
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
