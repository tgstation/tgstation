/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI status"

	if(usr.stat == 2)
		usr <<"You cannot change your emotional status because you are dead!"
		return
	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/obj/machinery/ai_status_display/AISD in world) //change status
		spawn( 0 )
		AISD.emotion = emote
	return