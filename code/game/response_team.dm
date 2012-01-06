//STRIKE TEAMS

var/list/response_team_members = list()
var/send_emergency_team = 0

client/verb/JoinResponseTeam()
	set category = "IC"

	if(istype(usr,/mob/dead/observer) || istype(usr,/mob/new_player))
		if(!send_emergency_team)
			usr << "No emergency response team is currently being sent."
			return

		if(response_team_members.len > 5) usr << "The emergency response team is already full!"

		var/leader_selected = (response_team_members.len == 0)

		for (var/obj/effect/landmark/L in world) if (L.name == "Commando")

			var/new_name = input(usr, "Pick a name","Name") as null|text
			if(!new_name) return
			var/gender = alert(usr, "Pick a gender","Gender","Male","Female")

			var/mob/living/carbon/human/new_commando = create_response_team(L, leader_selected, new_name, gender)

			new_commando.mind.key = usr.key
			new_commando.key = usr.key

			new_commando << "\blue You are [!leader_selected?"member":"<B>LEADER</B>"] of an armed response team in CentComm's service. Something went down on [station_name()] and they're now on code red. Go in there and fix the problem."
			new_commando << "<b>You should first gear up and discuss a plan with your team. More members may be joining, don't move out before you're ready."

	else
		usr << "You need to be an observer or new player to use this."

proc/trigger_armed_response_team()
	if(send_emergency_team)
		return

	command_alert("According to our sensors, [station_name()] has entered code red. We will prepare and dispatch an emergency response team to deal with the situation.", "Command Report")

	send_emergency_team = 1

/client/proc/create_response_team(obj/spawn_location, leader_selected = 0, commando_name, gender)

	var/mob/living/carbon/human/new_commando = new(spawn_location.loc)
	new_commando.gender = ((gender == "Male") ? MALE : FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the commando.
	A.randomize_appearance_for(new_commando)

	new_commando.real_name = commando_name
	new_commando.age = !leader_selected ? rand(23,35) : rand(35,45)

	new_commando.dna.ready_dna(new_commando)//Creates DNA.

	//Creates mind stuff.
	new_commando.mind = new
	new_commando.mind.current = new_commando
	new_commando.mind.original = new_commando
	new_commando.mind.assigned_role = "MODE"
	new_commando.mind.special_role = "Death Commando"
	if(!(new_commando.mind in ticker.minds))
		ticker.minds += new_commando.mind//Adds them to regular mind list.
	new_commando.equip_strike_team(leader_selected)
	del(spawn_location)
	return new_commando

/mob/living/carbon/human/proc/equip_strike_team(leader_selected = 0)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(src)
	R.set_frequency(1441)
	equip_if_possible(R, slot_ears)
	equip_if_possible(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_if_possible(new /obj/item/clothing/shoes/swat(src), slot_shoes)
	equip_if_possible(new /obj/item/clothing/suit/armor/swat(src), slot_wear_suit)
	equip_if_possible(new /obj/item/clothing/gloves/swat(src), slot_gloves)
	equip_if_possible(new /obj/item/clothing/head/helmet/space/deathsquad(src), slot_head)
	equip_if_possible(new /obj/item/clothing/mask/gas/swat(src), slot_wear_mask)

	equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)
	equip_if_possible(new /obj/item/weapon/storage/box(src), slot_in_backpack)

	equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_in_backpack)
	equip_if_possible(new /obj/item/device/flashlight(src), slot_in_backpack)

	equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(src), slot_s_store)

	var/obj/item/weapon/card/id/W = new(src)
	W.name = "[real_name]'s ID Card"
	W.icon_state = "centcom"
	W.access = get_access("Head of Personnel")
	W.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)//Let's add their alloted CentCom access.
	W.assignment = "Emergency Response Team"
	W.registered = real_name
	equip_if_possible(W, slot_wear_id)

	return 1