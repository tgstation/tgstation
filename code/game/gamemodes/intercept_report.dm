//Intercept reports are sent to the station every round to warn the crew of possible threats. They consist of five possibilites, one of which is always correct.

/datum/intercept_text
	var/text

/datum/intercept_text/proc/build(mode_type)
	text = "<hr>"
	switch(mode_type)
		if("blob")
			text += "A CMP scientist by the name of [pick("Griff", "Pasteur", "Chamberland", "Buist", "Rivers", "Stanley")] boasted about his corporation's \"finest creation\" - a macrobiological \
			virus capable of self-reproduction and hellbent on consuming whatever it touches. He went on to query Cybersun for permission to utilize the virus in biochemical warfare, to which \
			CMP subsequently gained. Be vigilant for any large organisms rapidly spreading across the station, as they are classified as a level 5 biohazard and critically dangerous. Note that \
			this organism seems to be weak to extreme heat; concentrated fire (such as welding tools and lasers) will be effective against it."
		if("changeling")
			text += "The Gorlex Marauders have announced the successful raid and destruction of Central Command containment ship #S-[rand(1111, 9999)]. This ship housed only a single prisoner - \
			codenamed \"Thing\", and it was highly adaptive and extremely dangerous. We have reason to believe that the Thing has allied with the Syndicate, and you should note that likelihood \
			of the Thing being sent to a station in this sector is highly likely. It may be in the guise of any crew member. Trust nobody - suspect everybody. Do not announce this to the crew, \
			as paranoia may spread and inhibit workplace efficiency."
		if("clockwork cult")
			text += "We have lost contact with multiple stations in your sector. They have gone dark and do not respond to all transmissions, although they appear intact and the crew's life \
			signs remain uninterrupted. Those that have managed to send a transmission or have had some of their crew escape tell tales of a machine cult creating sapient automatons and seeking \
			to brainwash the crew to summon their god, Ratvar. If evidence of this cult is dicovered aboard your station, extreme caution and extreme vigilance must be taken going forward, and \
			all resources should be devoted to stopping this cult. Note that holy water seems to weaken and eventually return the minds of cultists that ingest it, and mindshield implants will \
			prevent conversion altogether."
		if("cult")
			text += "Some stations in your sector have reported evidence of blood sacrifice and strange magic. Ties to the Wizards' Federation have been proven not to exist, and many employees \
			have disappeared; even Central Command employees light-years away have felt strange presences and at times hysterical compulsions. Interrogations point towards this being the work of \
			the cult of Nar-Sie. If evidence of this cult is discovered aboard your station, extreme caution and extreme vigilance must be taken going forward, and all resources should be \
			devoted to stopping this cult. Note that holy water seems to weaken and eventually return the minds of cultists that ingest it, and mindshield implants will prevent conversion \
			altogether."
		if("secret extended")
			text += "The transmission mostly failed to mention your sector. It is possible that there is nothing in the Syndicate that could threaten your station during this shift."
		if("gang war")
			text += "Cybersun Industries representatives claimed that they, in joint research with the Tiger Cooperative, have made a major breakthrough in brainwashing technology, and have \
			made the nanobots that apply the \"conversion\" very small and capable of fitting into usually innocent objects - namely, pens. While they refused to outsource this technology for \
			months to come due to its flaws, they reported some as missing but passed it off to carelessness. At Central Command, we don't like mysteries, and we have reason to believe that this \
			technology was stolen for anti-Nanotrasen use. Be on the lookout for territory claims and unusually violent crew behavior, applying mindshield implants as necessary."
		if("nuclear emergency")
			text += "One of Central Command's trading routes was recently disrupted by a raid carried out by the Gorlex Marauders. They seemed to only be after one ship - a highly-sensitive \
			transport containing a nuclear fission explosive, although it is useless without the proper code and authorization disk. While the code was likely found in minutes, the only disk that \
			can activate this explosive is on your station. Ensure that it is protected at all times, and remain alert for possible intruders."
		if("revolution")
			text += "Employee unrest has spiked in recent weeks, with several attempted mutinies on heads of staff. Some crew have been observed using flashbulb devices to blind their colleagues, \
			who then follow their orders without question and work towards dethroning departmental leaders. Watch for behavior such as this with caution. If the crew attempts a mutiny, you and \
			your heads of staff are fully authorized to execute them using lethal weaponry - they will be later cloned and interrogated at Central Command."
		if("traitor")
			text += "Although more specific threats are commonplace, you should always remain vigilant for Syndicate agents aboard your station. Syndicate communications have implied that many \
			Nanotrasen employees are Syndicate agents with hidden memories that may be activated at a moment's notice, so it's possible that these agents might not even know their positions."
		if("wizard")
			text += "A dangerous Wizards' Federation individual by the name of [pick(GLOB.wizard_first)] [pick(GLOB.wizard_second)] has recently escaped confinement from an unlisted prison facility. This \
			man is a dangerous mutant with the ability to alter himself and the world around him by what he and his leaders believe to be magic. If this man attempts an attack on your station, \
			his execution is highly encouraged, as is the preservation of his body for later study."
		if("Internal Affairs")
			text += "Nanotrasen denies any accusations of placing internal affairs agents onboard your station to eliminate inconvenient employees.  Any further accusations against Centcom for such \
			actions will be met with a conversation with an official internal affairs agent."
		if("monkey")
			text += "Reports of an ancient [pick("retrovirus", "flesh eating bacteria", "disease", "magical curse blamed on viruses", "bananna blight")] outbreak that turn humans into monkies has been \
			reported in your quadrant.  Any such infections may be treated with bananna juice.  If an outbreak occurs, ensure the station is quarantined to prevent a largescale outbreak at Centcom."
		if("meteor")
			text += "[pick("Asteroids have", "Meteors have", "Large rocks have", "Stellar minerals have", "Space hail has", "Debris has")] been detected near your station, and a collision is possible, \
			though unlikely.  Be prepared for largescale impacts and destruction.  Please note that the debris will prevent the escape shuttle from arriving quickly."
		if("devil")
			text += "Infernal creatures have been seen nearby offering great boons in exchange for souls.  This is considered theft against Nanotrasen, as all employment contracts contain a lien on the \
			employee's soul.  If anyone sells their soul in error, contact an attorney to overrule the sale.  Be warned that if the devil purchases enough souls, a gateway to hell may open."
		if("Devil Agents")
			text += "Multiple soul merchants have been spotted in the quadrant, and appear to be competing over who can purchase the most souls.  Be advised that they are likely to manufacture \
			emergencies to encourage employees to sell their souls. If anyone sells their soul in error, contact an attorney to overrule the sale."
		if("abduction")
			text += "Nearby spaceships report crewmembers having been [pick("kidnapped", "abducted", "captured")] and [pick("tortured", "experimented on", "probed", "implanted")] by mysterious \
			grey humanoids, before being sent back.  Be advised that the kidnapped crewmembers behave strangely upon return to duties."
		if("traitor+changeling")
			text += "The Syndicate has started some experimental research regarding humanoid shapeshifting.  There are rumors that this technology will be field tested on a Nanotrasen station \
			for infiltration purposes.  Be advised that support personel may also be deployed to defend these shapeshifters. Trust nobody - suspect everybody. Do not announce this to the crew, \
			as paranoia may spread and inhibit workplace efficiency."
		else
			EXCEPTION("An intercept report tried to generate a report for an invalid gamemode, \"[mode_type]\"")
	return text
