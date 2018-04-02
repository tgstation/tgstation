/* Hippie Neutral Traits */
/datum/trait/monochromatic
	name = "Monochromacy"
	desc = "You suffer from full colorblindness, and perceive nearly the entire world in blacks and whites."
	value = 0
	medical_record_text = "Patient is afflicted with almost complete color blindness."

/datum/trait/monochromatic/add()
	trait_holder.add_client_colour(/datum/client_colour/monochrome)

/datum/trait/monochromatic/post_add()
	if(trait_holder.mind.assigned_role == "Detective")
		to_chat(trait_holder, "<span class='boldannounce'>Mmm. Nothing's ever clear on this station. It's all shades of gray...</span>")
		trait_holder.playsound_local(trait_holder, 'sound/ambience/ambidet1.ogg', 50, FALSE)

/datum/trait/monochromatic/remove()
	trait_holder.remove_client_colour(/datum/client_colour/monochrome)

/datum/trait/greyscale_visionff
	name = "Old School Vision"
	desc = "Did you get stuck in an old video recorder? You can only see in black and white!</span>"
	value = 0
	gain_text = "<span class='notice'>...Huh? You can't see colour anymore!</span>"
	lose_text = "<span class='notice'>You can see colour again!</span>"

/datum/trait/greyscale_vision/add()
	trait_holder.add_client_colour(/datum/client_colour/greyscale)

/datum/trait/greyscale_vision/remove()
	trait_holder.remove_client_colour(/datum/client_colour/greyscale)

/datum/trait/inverted_vision
	name = "Inverted Colour Vision"
	desc = "You see red and blue colours as reversed."
	value = 0
	gain_text = "<span class='notice'>You feel like you're seeing colours differently.</span>"
	lose_text = "<span class='notice'>You feel like you're seeing colours normally again.</span>"

/datum/trait/inverted_vision/add()
	trait_holder.add_client_colour(/datum/client_colour/inverted)

/datum/trait/inverted_vision/remove()
	trait_holder.remove_client_colour(/datum/client_colour/inverted)

//I'm going to leave this code in here just in case we figure out how to do it properly, but for now leave this disabled - it doesn't work
/*
/datum/trait/vibrancy
	name = "Vibrancy"
	desc = "You must have taken some of the good stuff, because everything looks way brighter and far more vibrant!"
	value = 0
	lose_text = "<span class='notice'>It seems like everything is not so vibrant anymore...</span>"

/datum/trait/vibrancy/add()
	if (locate(/datum/client_colour/monochrome) in trait_holder.client_colours)
		to_chat(trait_holder, "<span class='warning'>You feel your vibrant vision having no effect because of your monochromacy!</span>")
		sleep(20) //Don't want the two messages to pop up instantly, muh immershun
		remove()
	else
		trait_holder.add_client_colour(/datum/client_colour/vibrant)
		to_chat(trait_holder, "<span class='notice'>You feel like everything has gotten brighter and more colourful.</span>")

		//The vibrancy trait won't get removed if you have monochromacy because when traits get added at roundstart, it doesn't currently call the add proc, so there's probably no use for all of this

/datum/trait/vibrancy/remove()
	trait_holder.remove_client_colour(/datum/client_colour/vibrant)
*/

/datum/trait/super_lungs
	name = "Super Lungs"
	desc = "Your extra powerful lungs allow you to scream much louder than normal, at the cost of losing more oxygen whenever you scream."
	value = 0
	gain_text = "<span class='notice'>You feel like you can scream louder than normal.</span>"
	lose_text = "<span class='notice'>You feel your ability to scream returning to normal.</span>"

/datum/trait/super_lungs/add()
	var/mob/living/carbon/human/H = trait_holder
	H.scream_vol = 100
	H.scream_oxyloss = 10

/datum/trait/super_lungs/remove()
	var/mob/living/carbon/human/H = trait_holder
	H.scream_vol = initial(H.scream_vol)
	H.scream_oxyloss = initial(H.scream_oxyloss)
