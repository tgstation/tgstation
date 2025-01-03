/proc/get_threat_level_string(shown_threat, fake_greenshift)
	var/advisory_string = ""
	switch(round(shown_threat))
		if(0 to 19)
			var/show_core_territory = (GLOB.current_living_antags.len > 0)
			if (prob(fake_greenshift))
				show_core_territory = !show_core_territory

			if (show_core_territory)
				advisory_string += "Advisory Level: <b>Blue Star</b></center><BR>"
				advisory_string += "Your sector's advisory level is Blue Star. At this threat advisory, the risk of attacks on Nanotrasen assets within the sector is minor but cannot be ruled out entirely. Remain vigilant."
			else
				advisory_string += "Advisory Level: <b>Green Star</b></center><BR>"
				advisory_string += "Your sector's advisory level is Green Star. Surveillance information shows no credible threats to Nanotrasen assets within the Spinward Sector at this time. As always, the Department of Intelligence advises maintaining vigilance against potential threats, regardless of a lack of known threats."
		if(20 to 39)
			advisory_string += "Advisory Level: <b>Yellow Star</b></center><BR>"
			advisory_string += "Your sector's advisory level is Yellow Star. Surveillance shows a credible risk of enemy attack against our assets in the Spinward Sector. We advise a heightened level of security alongside maintaining vigilance against potential threats."
		if(40 to 65)
			advisory_string += "Advisory Level: <b>Orange Star</b></center><BR>"
			advisory_string += "Your sector's advisory level is Orange Star. Upon reviewing your sector's intelligence, the Department has determined that the risk of enemy activity is moderate to severe. At this advisory, we recommend maintaining a higher degree of security and reviewing red alert protocols with command and the crew."
		if(66 to 79)
			advisory_string += "Advisory Level: <b>Red Star</b></center><BR>"
			advisory_string += "Your sector's advisory level is Red Star. The Department of Intelligence has decrypted Cybersun communications suggesting a high likelihood of attacks on Nanotrasen assets within the Spinward Sector. Stations in the region are advised to remain highly vigilant for signs of enemy activity and to be on high alert."
		if(80 to 99)
			advisory_string += "Advisory Level: <b>Black Orbit</b></center><BR>"
			advisory_string += "Your sector's advisory level is Black Orbit. Your sector's local communications network is currently undergoing a blackout, and we are therefore unable to accurately judge enemy movements within the region. However, information passed to us by GDI suggests a high amount of enemy activity in the sector, indicative of an impending attack. Remain on high alert and vigilant against any other potential threats."
		if(100)
			advisory_string += "Advisory Level: <b>Midnight Sun</b></center><BR>"
			advisory_string += "Your sector's advisory level is Midnight Sun. Credible information passed to us by GDI suggests that the Syndicate is preparing to mount a major concerted offensive on Nanotrasen assets in the Spinward Sector to cripple our foothold there. All stations should remain on high alert and prepared to defend themselves."
	return advisory_string

/proc/the_real_threat_level(threat)
	var/admin_threat_string = ""
	switch(round(threat))
		if(0 to 19)
			admin_threat_string += ">Green Star"
		if(20 to 39)
			admin_threat_string += "Yellow Star"
		if(40 to 65)
			admin_threat_string += "Orange Star"
		if(66 to 79)
			admin_threat_string += "Red Star"
		if(80 to 99)
			admin_threat_string += "Black Orbit"
		if(100)
			admin_threat_string += "Midnight Sun"
	return admin_threat_string
