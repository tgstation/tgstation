obj/machinery/gas_chromatography
	name = "Gas Chromatography Spectrometer"

obj/machinery/gas_chromatography/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	updateDialog()

obj/machinery/gas_chromatography/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>Gas Chromatography Spectrometer</B><BR>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")

obj/machinery/accelerator
	name = "Accelerator Spectrometer"

obj/machinery/accelerator/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	updateDialog()

obj/machinery/accelerator/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>Accelerator Spectrometer</B><BR>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")

obj/machinery/fourier_transform
	name = "Fourier Transform Spectroscope "

obj/machinery/fourier_transform/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	updateDialog()

obj/machinery/fourier_transform/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>Fourier Transform Spectroscope</B><BR>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")

obj/machinery/radiometric
	name = "Radiometric Exposure Spectrometer"

obj/machinery/radiometric/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	updateDialog()

obj/machinery/radiometric/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>Radiometric Exposure Spectrometer</B><BR>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")

obj/machinery/ion_mobility
	name = "Ion Mobility Spectrometer "

obj/machinery/ion_mobility/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	updateDialog()

obj/machinery/ion_mobility/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>Ion Mobility Spectrometer</B><BR>"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh<BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")
