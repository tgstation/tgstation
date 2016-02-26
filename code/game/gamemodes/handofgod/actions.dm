


/datum/action/innate/godspeak
	name = "Godspeak"
	button_icon_state = "godspeak"
	check_flags = AB_CHECK_CONSCIOUS
	var/mob/camera/god/god = null

/datum/action/innate/godspeak/IsAvailable()
	if(..())
		if(god)
			return 1
		return 0

/datum/action/innate/godspeak/Activate()
	var/msg = input(owner,"Speak to your god","Godspeak","") as null|text
	if(!msg)
		return
	god << "<span class='notice'><B>[owner]:</B> [msg]</span>"
	owner << "You say: [msg]"

/datum/action/innate/godspeak/Destroy()
	god = null
	return ..()