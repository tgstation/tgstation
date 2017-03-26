
/obj/machinery/power/PTL/Topic()

/obj/machinery/power/PTL/interact(mob/user)	//Remind me to learn TGUI and give this a proper interface.
	var/dat = list()
	dat += "<b><font size='5'>Laser Controls</font></b><BR>"
	dat += "<b><font size='3'>Capacitor</font</b><BR>"
	dat += "<div>"
	dat += "<b><font size='3'><span class='linkOn'>[charging? "Charging":"Not Charging"]</span></font></b><BR>"
	dat += "<b><a href='?src=\ref[src];toggle_charging=1'>Toggle</a><BR>"
	dat += "<b>Capacitor charge: [(internal_charge/internal_buffer)*100]%</b>"
	dat += "<b><a href='?src=\ref[src];change_charging_rate=1'>Change charging rate</a><BR>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "ptl", name)
	popup.set_content(dat)
	popup.open()
