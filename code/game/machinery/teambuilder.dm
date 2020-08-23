/obj/machinery/teambuilder
	name = "Teambuilding Machine"
	desc = "A machine that, when passed, colors you based on the color of your team. Lead free!"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle"
	density = FALSE
	can_buckle = FALSE
	var/team_color = "#ffffff"

/obj/machinery/teambuilder/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && !AM.color)
		AM.color = team_color
