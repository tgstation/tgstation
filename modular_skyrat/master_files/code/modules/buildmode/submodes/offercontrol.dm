/datum/buildmode_mode/offercontrol
	key = "offercontrol"

/datum/buildmode_mode/offercontrol/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************\n\
		Left Mouse Button on mob/living = Offer control to ghosts.\n\
		***********************************************************</span>")

/datum/buildmode_mode/offercontrol/handle_click(client/c, params, object)
	if(!ismob(object))
		return

	var/mob/living/mob_to_offer = object

	if(mob_to_offer.key)
		var/response = tgui_alert(c, "This mob already has a ckey attached, continue?", "Mob already posessed!", list("Continue", "Cancel"))
		if(response != "Continue")
			return

	offer_control(mob_to_offer)
