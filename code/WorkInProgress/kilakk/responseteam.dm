// emergency response teams
// work in progress

var/const/members_possible = 5
var/sent_emergency_team = 0

/client/proc/response_team()
	set name = "Dispatch Emergency Response Team"
	set category = "Special Verbs"
	set desc = "Send an emergency response team to the station"

	if(!holder)
		usr << "\red Only administrators may use this command."
		return
	if(!ticker)
		usr << "\red The game hasn't started yet!"
		return
	if(ticker.current_state == GAME_STATE_PREGAME)
		usr << "\red The round hasn't started yet!"
		return
	if(sent_emergency_team == 1)
		usr << "\red Central Command has already dispatched an emergency response team!"
		return
	if(alert("Do you want to dispatch an Emergency Response Team?",,"Yes","No") != "Yes")
		return
	if(get_security_level() != "red") // Allow admins to reconsider if the alert level isn't Red
		switch(alert("The station has not entered code red recently. Do you still want to dispatch a response team?",,"Yes","No"))
			if("No")
				return

	var/situation = null
	while(!situation)
		situation = copytext(sanitize(input(src, "Please specify the mission the emergency response team will undertake.", "Specify Mission", "")),1,MAX_MESSAGE_LEN)
		if(!situation)
			if(alert("You haven't specified a mission. Exit the setup process?",,"No","Yes")=="Yes")
				return

	if(sent_emergency_team)
		usr << "\red Looks like somebody beat you to it!"
		return

	sent_emergency_team = 1
	message_admins("[key_name_admin(usr)] is dispatching an Emergency Response Team.", 1)
	log_admin("[key_name(usr)] used Dispatch Response Team.")

	var/member_number = members_possible
	var/leader_selected = 0

	// Shamelessly stolen nuke code
	var/nuke_code
	var/temp_code
	for(var/obj/machinery/nuclearbomb/N in world)
		temp_code = text2num(N.r_code)
		if(temp_code)
			nuke_code = N.r_code
			break

/*	var/list/candidates = list() // ghosts who can be picked
	var/list/members = list() // ghosts who have been picked
	for(var/mob/dead/observer/G in player_list)
		if(!G.client.holder && !G.client.is_afk())
			if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
				candidates += G.key
	for(var/i=members_possible,(i>0&&candidates.len), i--)
		var/candidate = input("Choose characters to spawn as response team members. This will go on until there are no more ghosts to pick from or until all slots are full.", "Active Players") as null|anything in candidates */

	// I tried doing this differently. Ghosts get a pop-up box similar to pAIs and one-click-antag
	// Biggest diff here is in how the candidates list is updated
	alert(usr, "Active ghosts will be given a chance to choose whether or not they want to be considered for the emergency reponse team. This will take about 30 seconds.") // There's probably a better way to do this, with a fancy count-down timer or something

	var/list/candidates = list()
	var/list/members = list()
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "Syndicate") && !jobban_isbanned(G, "Emergency Response Team") && !jobban_isbanned(G, "Security Officer"))
			spawn(0)
				switch(alert(G, "Do you want to be considered for the Emergency Response Team? Please answer in 30 seconds!",,"Yes","No"))
					if("Yes")
						if((world.time-time_passed)>300)
							return
						candidates += G.key
					if("No")
						return
					else
						return

	sleep(300)

	for(var/i=members_possible,(i>0&&candidates.len), i--) // The rest of the choosing process is just an input with a list of candidates on it
		var/chosen = input("Time's up! Choose characters to spawn as reponse team members. This will go on until there are no more ghosts to pick from or until all slots are full.", "Considered Players") as null|anything in candidates
		candidates -= chosen
		members += chosen

	command_alert("Sensors indicate that [station_name()] has entered Code Red and is in need of assistance. We will prepare and dispatch an emergency response team to deal with the situation.", "NMV Icarus Command")

	for(var/obj/effect/landmark/L in world)
		if(L.name == "Response Team")
			leader_selected = member_number == 1?1:0 // The last person selected will be the leader

			var/mob/living/carbon/human/new_member = create_response_team(L, leader_selected)

			new_member.age = !leader_selected ? rand(23,35) : rand(35,45)

			if(members.len)
				new_member.key = pick(members)
				members -= new_member.key

			if(!new_member.key) // It works ok? sort of
				del(new_member)
				break

			spawn(0)
				switch(alert(new_member, "You are an Emergency Response Team member! Are you a boy or a girl?",,"Male","Female"))
					if("Male")
						new_member.gender = MALE
					if("Female")
						new_member.gender = FEMALE

				var/new_name = input(new_member, "...Erm, what was your name again?", "Choose your name") as text

				if(!new_name)
					new_member.real_name = "Agent [pick("Red","Yellow","Orange","Silver","Gold", "Pink", "Purple", "Rainbow")]" // Choose a "random" agent name
					new_member.name = usr.real_name
				else
					new_member.real_name = new_name
					new_member.name = new_name

				// -- CHANGE APPEARANCE --
				var/new_tone = input(new_member, "Please select your new skin tone: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation") as num

				if(new_tone)
					new_member.s_tone = max(min(round(text2num(new_tone)), 220), 1)
					new_member.s_tone =  -new_member.s_tone + 35

				var/new_hair = input(new_member, "Please select your new hair color.","Character Generation") as color

				if(new_hair)
					new_member.r_hair = hex2num(copytext(new_hair, 2, 4))
					new_member.g_hair = hex2num(copytext(new_hair, 4, 6))
					new_member.b_hair = hex2num(copytext(new_hair, 6, 8))

				var/new_facial = input(new_member, "Please select your new facial hair color.","Character Generation") as color

				if(new_facial)
					new_member.r_facial = hex2num(copytext(new_facial, 2, 4))
					new_member.g_facial = hex2num(copytext(new_facial, 4, 6))
					new_member.b_facial = hex2num(copytext(new_facial, 6, 8))

				var/new_eyes = input(new_member, "Please select eye color.", "Character Generation") as color

				if(new_eyes)
					new_member.r_eyes = hex2num(copytext(new_eyes, 2, 4))
					new_member.g_eyes = hex2num(copytext(new_eyes, 4, 6))
					new_member.b_eyes = hex2num(copytext(new_eyes, 6, 8))

				var/new_hstyle = input(new_member, "Please select your new hair style!", "Grooming") as null|anything in hair_styles_list

				if(new_hstyle)
					new_member.h_style = new_hstyle

				var/new_fstyle = input(new_member, "Please select your new facial hair style!", "Grooming") as null|anything in facial_hair_styles_list

				if(new_fstyle)
					new_member.f_style = new_fstyle

				// -- END --

				new_member.dna.ready_dna(new_member)
				new_member.update_body(1)
				new_member.update_hair(1)

				new_member.mind_initialize()
				new_member.mind.assigned_role = "Emergency Response Team"
				new_member.mind.special_role = "Emergency Response Team"
				ticker.mode.traitors += new_member.mind // ERTs will show up at the end of the round on the "traitor" list

				new_member << "\blue You are the <b>Emergency Response Team[!leader_selected?"!</b>":" Leader!</b>"] \nAs a response team [!leader_selected?"member":"<b>leader</b>"] you answer directly to [!leader_selected?"your team leader.":"Central Command."] \nYou have been deployed by NanoTrasen Central Command in Tau Ceti to resolve a Code Red alert aboard [station_name()], and have been provided with the following instructions and information regarding your mission: \red [situation]"
				new_member.mind.store_memory("<b>Mission Parameters:</b> \red [situation].")

				if(leader_selected)
					new_member << "\red The Nuclear Authentication Code is: <b> [nuke_code]</b>. You are instructed not to detonate the nuclear device aboard [station_name()] unless <u>absolutely necessary</u>."
					new_member.mind.store_memory("<b>Nuclear Authentication Code:</b> \red [nuke_code]")

				new_member.equip_response_team(leader_selected) // Start equipping them

			member_number--
	return 1

// Mob creation
/client/proc/create_response_team(obj/spawn_location, leader_selected = 0)
	var/mob/living/carbon/human/new_member = new(spawn_location.loc)

	return new_member

// Equip mob
/mob/living/carbon/human/proc/equip_response_team(leader_selected = 0)

	// Headset
	equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(src), slot_ears)

	// Uniform
	equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(src), slot_belt)

	// Glasses
	equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(src), slot_glasses)

	// Backpack
	equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(src), slot_back)

	// Put stuff into their backpacks
	equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid(src), slot_in_backpack) // Not sure about this

	// Loyalty implants
	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(src)
	L.imp_in = src
	L.implanted = 1

	// ID cards
	var/obj/item/weapon/card/id/E = new(src)
	E.name = "[real_name]'s ID Card (Emergency Response Team)"
	E.icon_state = "centcom"
	E.access = get_all_accesses() // ERTs can go everywhere on the station
	if(leader_selected)
		E.name = "[real_name]'s ID Card (Emergency Response Team Leader)"
		E.access += get_all_centcom_access()
		E.assignment = "Emergency Response Team Leader"
	else
		E.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		E.assignment = "Emergency Response Team"
	E.registered_name = real_name
	equip_to_slot_or_del(E, slot_wear_id)

	return 1

