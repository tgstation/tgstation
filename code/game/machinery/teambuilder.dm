/**
  * Simple admin tool that enables players to be assigned to a VERY SHITTY, very visually distinct team, quickly and affordably.
  */
/obj/machinery/teambuilder
	name = "Teambuilding Machine"
	desc = "A machine that, when passed, colors you based on the color of your team. Lead free!"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle"
	density = FALSE
	can_buckle = FALSE
	resistance_flags = INDESTRUCTIBLE // Just to be safe.
	///What color is your mob set to when crossed?
	var/team_color = COLOR_WHITE
	///What radio station is your radio set to when crossed (And human)?
	var/team_radio = FREQ_COMMON

/obj/machinery/teambuilder/examine_more(mob/user)
	. = ..()
	. += "<span class='notice'>You see a hastily written note on the side, it says '1215-1217, PICK A SIDE'.</span>"

/obj/machinery/teambuilder/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(AM.color)
		return
	if(isliving(AM) && team_color)
		AM.color = team_color
	if(ishuman(AM) && team_radio)
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
