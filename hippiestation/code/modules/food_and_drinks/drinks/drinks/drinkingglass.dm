/obj/item/reagent_containers/food/drinks/drinkingglass/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	if(reagents && reagents.has_reagent("lean"))
		user.visible_message("<span class='suicide'>[user] is overdosing on that purple stuff!</span>")
		user.say("Aww hol up mane.. dat too much drank..")
		H.vomit(80)
		return(TOXLOSS)
	else 
		..()
