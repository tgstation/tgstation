/obj/structure/holosign/barrier/medical
	icon = 'monkestation/code/modules/virology/icons/biohazard.dmi'
	icon_state = "biohazard"
	alpha = 125

/obj/item/holosign_creator/medical/proc/try_alert(atom/movable/AM, area/host_area)
	if(!isliving(AM))
		return

	var/mob/living/living = AM
	var/say_text = "VIRUS DETECTED AT: [host_area]. SOURCE: [living]. "

	if(length(living.diseases) > 1)
		say_text += "SUBJECT HAS MULTIPLE VIRUSES."
	else
		var/line = " DISEASE IS IN DATABASE:"
		for(var/datum/disease/advanced/disease as anything in living.diseases)
			if("[disease.uniqueID]-[disease.subID]" in  GLOB.virusDB)
				var/datum/data/record/target = GLOB.virusDB["[disease.uniqueID]-[disease.subID]"]
				line += " [target.name]"
		say_text += line
	say(say_text)
	playsound(src, 'sound/machines/defib_success.ogg', 50, FALSE)
