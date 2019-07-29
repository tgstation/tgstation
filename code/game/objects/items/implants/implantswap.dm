/datum/swap

	/*!
	Swap is a datum that handles the swapping for the swapper pen/implant combo. This in general handles the actual swapping, while the objects themselves handle their own individual compoents.
	*/

	///This is the passive object that is swapped when the activator is triggered.
	var/obj/swap_reciever
	//This is the activator that initiates the swapping.
	var/obj/swap_activator

	var/implanted = FALSE

/*!
This triggers when the activator is activated, it grabs the mobs and then their turfs, then forces a move that swaps both locations
*/
/datum/swap/proc/activate(var/obj/R = swap_reciever, var/obj/A = swap_activator)
	///Grab the recievers mob
	var/mob/living/RL = R.loc
	///Grab the activators mob
	var/mob/living/AL = A.loc
	
	if(implanted && R && A)
		///Grab the recievers turf
		var/turf/RT = get_turf(RL.loc)
		///Grab the activators turf
		var/turf/AT = get_turf(A.loc)
		
		playsound(RL, 'sound/effects/sparks4.ogg')
		playsound(AL, 'sound/effects/sparks4.ogg')

		RL.visible_message("[RL] Suddenly vanishes, Leaving [AL] in their place!")
		AL.visible_message("[AL] Suddenly vanishes, leaving [RL] in their place!")
		to_chat(RL, "You suddenly find yourself in a new location.")
		to_chat(AL, "You press the button on the pen, and suddenly find yourself in a new location.")

		///Move the reciever to the activator
		RL.forceMove(AT)
		///Move the activator to the reciever
		AL.forceMove(RT)

		///Cleans up the objects after use.
		qdel(R)
		qdel(A)
		to_chat(AL, "The pen falls apart in your hands.")
	else
		to_chat(AL, "You press the button on the pen, but you have not yet implanted the anybody!")

/obj/item/pen/swap_activator
	var/datum/swap/swap

/obj/item/pen/swap_activator/attack_self()
	swap.activate()

/obj/item/implant/swapper
	var/datum/swap/swap

/obj/item/implant/swapper/implant(silent = TRUE, force = TRUE)
	swap.implanted = TRUE
	. = ..()

/obj/item/implanter/swapper
	imp_type = /obj/item/implant/swapper


