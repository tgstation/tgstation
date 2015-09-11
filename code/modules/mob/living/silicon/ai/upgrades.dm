//spec for the new AI upgrades system
// AI has new tab, Upgrades
// AI starts off gimped
// AI constantly generates research / can research abilties
// AI can disable features to research faster


/*Generic upgrade, example of use
	ai.upgrade("telecomms override",300)
*/

/mob/living/silicon/ai/proc/upgrade_access()
	var/browseinput = "<b>Please select an upgrade to begin researching:</b><br><br>"
	for (var/index = 1, index <= src.researches.len, index++)
		browseinput += "<A href ='byond://?src=\ref[src];upgrade=[researches[index]]'>Research <b>[researches[index]]</b> </A>  <br>" //add HREFs later

	var/datum/browser/popup = new(src, "aiupgrade", "Available Upgrades")
	popup.set_content(browseinput)
	popup.open()

/mob/living/silicon/ai/proc/disablemodules(var/moduletoresearch)
	var/popinput = "<b>Select subsystems to disable</b> <br> Subsystems can be disabled to greatly speed up research. <br>"

	for (var/index = 1, index <= src.subsystems.len, index++)
		if(subsystems[subsystems[index]] == 1)
			popinput += "<A href='byond://?src=\ref[src];togglesub=[subsystems[index]]'><b>[subsystems[index]]</A><br>"

	popinput += "<br> <A href='byond://?src=\ref[src];beginresearch=[moduletoresearch]'><b>Begin Research</b></A>"

	var/datum/browser/dismodpopup = new(src, "subsys-dis", "Disable Subsystems")
	dismodpopup.set_content(popinput)
	dismodpopup.open()


/mob/living/silicon/ai/proc/upgrade(var/upgrade = "generic upgrade",var/defaulttime = 100)

	if(stat || aiRestorePowerRoutine || researching)
		return
	researchtime = defaulttime/researchrate
	var/researchdisplay = researchtime/10
	researching = 1
	src << "Researching the [upgrade] subsystem. ETC: [researchdisplay]s "
	if(!do_after(src, researchtime, target = src))
		src << "Systems upgrade failure."
		researching = 0
		return 0 //need to make this give the upgrade back

	researching = 0
	subsystems |= upgrade
	subsystems[upgrade] = 1
	researches -= upgrade //needs to check upgrade is /in/ researches first
	src << "Systems upgraded. The [upgrade] subsystem is now active."

/mob/living/silicon/ai/proc/handleresearchrate(var/syntax = 0)
	if(syntax)
		researchrate += 1
		return
	else
		researchrate -= 1



//procs to tinker with ai's encryption keys

/mob/living/silicon/ai/proc/addchannel(chann = "Security") //Adds a channel to the AI's key permanently.
	radio.keyslot.channels |= "[chann]"
	enablechannel(chann)

/mob/living/silicon/ai/proc/disablechannel(chann = "Security")
	radio.keyslot.channels[chann] = 0
	src << "debug: removing [chann] channel from radio"
	src.radio.recalculateChannels()

/mob/living/silicon/ai/proc/enablechannel(chann = "Security")
	src.radio.keyslot.channels[chann] = 1
	src.radio.recalculateChannels()