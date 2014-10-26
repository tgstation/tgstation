/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/cultify()
	if(icon_state != "ghost-narsie")
		icon = 'icons/mob/mob.dmi'
		icon_state = "ghost-narsie"
		overlays = 0
		if(istype(mind.current, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = mind.current
			overlays += H.overlays_standing[6]//ID
			overlays += H.overlays_standing[9]//Ears
			overlays += H.overlays_standing[10]//Suit
			overlays += H.overlays_standing[11]//Glasses
			overlays += H.overlays_standing[12]//Belt
			overlays += H.overlays_standing[14]//Back
			overlays += H.overlays_standing[18]//Head
			overlays += H.overlays_standing[19]//Handcuffs
		invisibility = 0
		src << "<span class='sinister'>Even as a non-corporal being, you can feel Nar-Sie's presence altering you. You are now visible to everyone.</span>"
