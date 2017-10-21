/obj/item/reagent_containers/food/drinks/drinkingglass/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	if(reagents && reagents.has_reagent("lean"))
		H.visible_message("<span class='suicide'>[H] is overdosing on that purple stuff!</span>")
		H.say("Aww hol up mane.. dat too much drank..")
		H.vomit(80)
		return(TOXLOSS)
	else 
		..()
