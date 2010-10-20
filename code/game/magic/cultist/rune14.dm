/obj/rune/proc/communicate()
	if(istype(src,/obj/rune))
		usr.say("O bidai nabora se'sma!")
	else
		usr.whisper("O bidai nabora se'sma!")
	var/input = input(usr, "Please choose a message to tell to the other acolytes.", "hssss", "")
	if(!input)
		return fizzle()
	if(istype(src,/obj/rune))
		usr.say("[input]")
	else
		usr.whisper("[input]")
	for(var/mob/living/carbon/human/H in cultists)
		H << "\red \b [input]"
	return