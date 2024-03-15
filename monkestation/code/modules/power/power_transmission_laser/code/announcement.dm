/// To be used for announcements about a milestone being broken
#define ANNOUNCEMENT_MILESTONE (1<<0)
/// To be used for rare history lessons that the PTL history team can make
#define ANNOUNCEMENT_HISTORY (1<<1)

/obj/machinery/power/transmission_laser/proc/send_ptl_announcement()
	/// The message we send
	var/major_title
	var/minor_title
	var/message
	var/announcement_reason
	var/flavor_text
	var/roll_for_history = rand(1, 10)
	switch(announcement_treshold)
		if(1 MW)
			message = "PTL account successfully made"
			flavor_text = "from now on you will receive regular updates on the power exported via the onboard PTL, goodluck [station_name()]"
			INVOKE_ASYNC(src, PROC_REF(send_regular_ptl_announcement)) // starts giving the station regular updates on the PTL since our station just got an account

		if(1 GW)
			message = "The onboard PTL has successfully exported 1 Gigawatt worth of power"
			flavor_text = "using the exported power we managed to save a station whose supermatter engine has dellamianted, good work."
			announcement_reason = ANNOUNCEMENT_MILESTONE

		if(1 TW)
			message = "The onboard PTL has successfully exported 1 Terawatt worth of power"
			flavor_text = "using the exported power a nearby plasma mining outpost has been established without an engine, we depend on you and keep doing good work"
			announcement_reason = ANNOUNCEMENT_MILESTONE

		if(1 PW)
			message = "The onboard PTL has successfully exported 1 Petawatt worth of power"
			if(roll_for_history > 1)
				flavor_text = "thanks to your exported power we quickly managed to discharge emergency power to our fleet in distress, securing victory against a nearby syndicate ship. Great work"
				announcement_reason = ANNOUNCEMENT_MILESTONE
			else
				flavor_text = "1.4 Petawatts is the estimated heat flux transported by the Gulf Stream back on the human's mother planet \"earth\""
				announcement_reason = ANNOUNCEMENT_HISTORY

		if(1 EW)
			message = "The onboard PTL has successfully exported 1 Exawatt worth of power"
			if(roll_for_history > 1)
				flavor_text = "We did not expect your station to export such a high amount of power, and due to that [rand(1, 3)] of our batteries over-charged and blew up [rand(1, 5)] stations... keep doing good work?"
				announcement_reason = ANNOUNCEMENT_MILESTONE
			else
				flavor_text = "In a keynote presentation, NIF & Photon Science Chief Technology Officer Chris Barty described the \"Nexawatt\" Laser, an exawatt (1,000-petawatt) laser concept based on NIF technologies, on April 13 at the SPIE Optics + Optoelectronics 2015 Conference in Prague. Barty also gave an invited talk on \"Laser-Based Nuclear Photonics\" at the SPIE meeting."
				announcement_reason = ANNOUNCEMENT_HISTORY

		else
			message = "The onboard PTL has successfully exported extremelly high amounts of power"
			flavor_text = "we are not sure anymore how much power your PTL has exported, but it sure is a lot. Keep doing great work"
			announcement_reason = ANNOUNCEMENT_MILESTONE

	minor_title = "Power Transmission Laser report"
	if(announcement_reason)
		switch(announcement_reason)
			if(ANNOUNCEMENT_MILESTONE)
				major_title = "[command_name()] energy unit"
				message = "New milestone reached!\n[message]"
			if(ANNOUNCEMENT_HISTORY)
				major_title = "[command_name()] energy unit"
				minor_title = "Power Transmission Laser report, history sub-division"
				message = "PTL history lesson\n[message]"

	priority_announce(
		sender_override = major_title,
		title = minor_title,
		text = "[message]\n[flavor_text]",
		color_override = "orange",
	)

	announcement_treshold *= 1000


/obj/machinery/power/transmission_laser/proc/send_regular_ptl_announcement()
	sleep(30 MINUTES) // simple loop, we are called once and then repeat ourselfes forever
	INVOKE_ASYNC(src, PROC_REF(send_regular_ptl_announcement))

	// the total_power variable converted into readable amounts of power, because 100.000.000.000.000 was for some reason hard to read
	var/readable_power

	switch(total_power)
		if(1 MW to (1 GW) - 1)
			readable_power = "[total_power / (1 MW)] Megawatts"

		if(1 GW to (1 TW) - 1)
			readable_power = "[total_power / (1 GW)] Gigawatts"

		if(1 TW to (1 PW) - 1)
			readable_power = "[total_power / (1 TW)] Terawatts"

		if(1 PW to (1 EW) - 1)
			readable_power = "[total_power / (1 PW)] Petawatts"

		if(1 EW to INFINITY)
			readable_power = "[total_power / (1 EW)] Exowatts"

	priority_announce(
		sender_override = "[command_name()] energy unit",
		title = "Regular Power Transmission Laser report",
		text = "Total power exported via the PTL: [readable_power]\n\
				Total earnings: [total_earnings] credits",
		color_override = "orange",
	)
