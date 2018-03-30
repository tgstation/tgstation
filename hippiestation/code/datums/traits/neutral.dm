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