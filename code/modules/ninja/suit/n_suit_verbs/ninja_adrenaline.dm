//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()

	if(!ninjacost(0,N_ADRENALINE))
		var/mob/living/carbon/human/H = affecting
		H.SetUnconscious(0)
		H.SetStun(0)
		H.SetKnockdown(0)
		H.say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"))
		spawn(70)
			H.reagents.add_reagent("radium", a_transfer)
			to_chat(H, "<span class='danger'>You are beginning to feel the after-effect of the injection.</span>")
		a_boost--
		to_chat(H, "<span class='notice'>There are <B>[a_boost]</B> adrenaline boosts remaining.</span>")
		s_coold = 3
