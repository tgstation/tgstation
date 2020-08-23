/**
  *
  */
/obj/machinery/teambuilder
	name = "Teambuilding Machine"
	desc = "A machine that, when passed, colors you based on the color of your team. Lead free!"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle"
	density = FALSE
	can_buckle = FALSE
	var/team_color = "#ffffff"
	var/team_radio = FREQ_COMMON

/obj/machinery/teambuilder/examine_more(mob/user)
	. = ..()
	var/list/msg = list("<span class='notice'><i>You see a hastily written note on the side, it says '1215-1217, PICK A SIDE'.</i></span>")
	return msg

/obj/machinery/teambuilder/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && !AM.color)
		AM.color = team_color
	if(ishuman(AM))
		var/mob/living/carbon/human/human = AM
		var/obj/item/radio/Radio = human.ears
		if(!Radio)
			return
		Radio.set_frequency(team_radio)

/obj/machinery/teambuilder/red
	name = "Teambuilding Machine (Red)"
	desc = "A machine that, when passed, colors you based on the color of your team. Go red team!"
	color = "#ff0000"
	team_color = "#ff0000"
	team_radio = FREQ_CTF_RED

/obj/machinery/teambuilder/blue
	name = "Teambuilding Machine (Blue)"
	desc = "A machine that, when passed, colors you based on the color of your team. Go blue team!"
	color = "#0000ff"
	team_color = "#0000ff"
	team_radio = FREQ_CTF_BLUE
