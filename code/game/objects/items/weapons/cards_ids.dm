/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the teleporter
 */
/obj/item/weapon/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = 1.0
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		src.name = text("Data Disk- '[]'", t)
	else
		src.name = "Data Disk"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/card/data/clown
	name = "Coordinates to Clown Planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Planet"

/*
 * ID CARDS
 */
/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

	/**
	 * Number of uses left.  -1 = infinite
	 * (Note: Some devices can use more than 1 use, so this is just called "energy")
	 * @since 10-28-2014
	 */
	var/energy = -1

	/**
	 * Max energy per emag.  -1 = infinite
	 * @since 10-28-2014
	 */
	var/max_energy = -1

	/**
	 * Every X ticks, add [recharge_rate] energy.
	 * @since 10-28-2014
	 */
	var/recharge_ticks = 0

	/**
	 * Every [recharge_ticks] ticks, add X energy.
	 * @since 10-28-2014
	 */
	var/recharge_rate = 0

	var/nticks=0

/obj/item/weapon/card/emag/New(var/loc, var/disable_tuning=0)
	..(loc)

	// For standardized subtypes, once they're established.
	if(disable_tuning)
		return

	// Tuning tools.
	//////////////////
	if(config.emag_energy != -1)
		max_energy = config.emag_energy

		if(config.emag_starts_charged)
			energy = max_energy

	if(config.emag_recharge_rate != 0)
		recharge_rate = config.emag_recharge_rate

	if(config.emag_recharge_ticks > 0)
		recharge_ticks = config.emag_recharge_ticks

/obj/item/weapon/card/emag/process()
	if(energy < max_energy)
		// Specified number of ticks has passed?  Add charge.
		if(nticks >= recharge_ticks)
			nticks = 0
			energy = min(energy + recharge_rate, max_energy)
		nticks ++
	else
		nticks = 0
		processing_objects.Remove(src)

/obj/item/weapon/card/emag/proc/canUse(var/mob/user, var/obj/machinery/M)
	// We've already checked for emaggability.  All we do here is check cost.

	// Infinite uses?  Just return true.
	if(energy < 0)
		return 1

	var/cost=M.getEmagCost(user,src)

	// Free to emag?  Return true every time.
	if(cost == 0)
		return 1

	if(energy >= cost)
		energy -= cost

		// Start recharging, if we're supposed to.
		if(energy < max_energy && recharge_rate && recharge_ticks)
			if(!(src in processing_objects))
				processing_objects.Add(src)

		return 1

	return 0

/obj/item/weapon/card/emag/examine()
	..()
	if(energy==-1)
		usr << "<span class=\"info\">\The [name] has a tiny fusion generator for power.</span>"
	else
		var/class="info"
		if(energy/max_energy < 0.1 /* 10% energy left */)
			class="warning"
		usr << "<span class=\"[class]\">This [name] has [energy]MJ left in its capacitor ([max_energy]MJ capacity).</span>"
	if(recharge_rate && recharge_ticks)
		usr << "<span class=\"info\">A small label on a thermocouple notes that it recharges at a rate of [recharge_rate]MJ for every [recharge_ticks<=1?"":"[recharge_ticks] "]oscillator tick[recharge_ticks>1?"s":""].</span>"

/obj/item/weapon/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_ID

	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"
	var/bans = null
	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0		// determines if this ID has claimed a dorm already

/obj/item/weapon/card/id/New()
	..()
	spawn(30)
	if(istype(loc, /mob/living/carbon/human))
		blood_type = loc:dna:b_type
		dna_hash = loc:dna:unique_enzymes
		fingerprint_hash = md5(loc:dna:uni_identity)

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] []: assignment: []", user, src, src.name, src.assignment), 1)
	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/GetAccess()
	return access

/obj/item/weapon/card/id/GetID()
	return src

/obj/item/weapon/card/id/proc/GetBalance(var/format=0)
	var/amt = 0
	var/datum/money_account/acct = get_card_account(src)
	if(acct)
		amt = acct.money
	if(format)
		amt = "$[num2septext(amt)]"
	return amt

/obj/item/weapon/card/id/GetJobName()
	var/jobName = src.assignment //what the card's job is called
	var/alt_jobName = src.rank   //what the card's job ACTUALLY IS: determines access, etc.

	if(jobName in get_all_job_icons()) //Check if the job name has a hud icon
		return jobName
	if(alt_jobName in get_all_job_icons()) //Check if the base job has a hud icon
		return alt_jobName
	if(jobName in get_all_centcom_jobs() || alt_jobName in get_all_centcom_jobs()) //Return with the NT logo if it is a Centcom job
		return "Centcom"
	return "Unknown" //Return unknown if none of the above apply

// vgedit: We have different wallets.
/*
/obj/item/weapon/card/id/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W,/obj/item/weapon/id_wallet))
		user << "You slip [src] into [W]."
		src.name = "[src.registered_name]'s [W.name] ([src.assignment])"
		src.desc = W.desc
		src.icon = W.icon
		src.icon_state = W.icon_state
		del(W)
		return
*/
/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	usr << text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment)
	usr << "The blood type on the card is [blood_type]."
	usr << "The DNA hash on the card is [dna_hash]."
	usr << "The fingerprint hash on the card is [fingerprint_hash]."
	return


/obj/item/weapon/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels, access_syndicate, access_external_airlocks)
	origin_tech = "syndicate=3"
	var/registered_user=null

/obj/item/weapon/card/id/syndicate/New(mob/user as mob)
	..()
	if(!isnull(user)) // Runtime prevention on laggy starts or where users log out because of lag at round start.
		registered_name = ishuman(user) ? user.real_name : user.name
	else
		registered_name = "Agent Card"
	assignment = "Agent"
	name = "[registered_name]'s ID Card ([assignment])"

/obj/item/weapon/card/id/syndicate/afterattack(var/obj/item/weapon/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		src.access |= I.access
		if(istype(user, /mob/living) && user.mind)
			if(user.mind.special_role)
				usr << "\blue The card's microscanners activate as you pass it over the ID, copying its access."

/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var t = reject_bad_name(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name))
		if(!t) //Same as mob/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = t

		var u = copytext(sanitize(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Agent")),1,MAX_MESSAGE_LEN)
		if(!u)
			alert("Invalid assignment.")
			src.registered_name = ""
			return
		src.assignment = u
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		user << "\blue You successfully forge the ID card."
		registered_user = user
	else if(!registered_user || registered_user == user)

		if(!registered_user) registered_user = user  //

		switch(alert("Would you like to display the ID, or retitle it?","Choose.","Rename","Show"))
			if("Rename")
				var t = copytext(sanitize(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)),1,26)
				if(!t || t == "Unknown" || t == "floor" || t == "wall" || t == "r-wall") //Same as mob/new_player/prefrences.dm
					alert("Invalid name.")
					return
				src.registered_name = t

				var u = copytext(sanitize(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")),1,MAX_MESSAGE_LEN)
				if(!u)
					alert("Invalid assignment.")
					return
				src.assignment = u
				src.name = "[src.registered_name]'s ID Card ([src.assignment])"
				user << "\blue You successfully forge the ID card."
				return
			if("Show")
				..()
	else
		..()

/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	icon_state = "syndie"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate, access_external_airlocks)

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/weapon/card/id/captains_spare/New()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	..()

/obj/item/weapon/card/id/admin
	name = "Admin ID"
	icon_state = "admin"
	item_state = "gold_id"
	registered_name = "Admin"
	assignment = "Testing Shit"

/obj/item/weapon/card/id/admin/New()
	access = get_absolutely_all_accesses()
	..()

/obj/item/weapon/card/id/centcom
	name = "\improper CentCom. ID"
	desc = "An ID awarded only to the best brown nosers."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"

/obj/item/weapon/card/id/centcom/New()
	access = get_all_centcom_access()
	..()

/obj/item/weapon/card/id/salvage_captain
	name = "Captain's ID"
	registered_name = "Captain"
	icon_state = "centcom"
	desc = "Finders, keepers."
	access = list(access_salvage_captain)

/obj/item/weapon/card/id/medical
	name = "Medical ID"
	registered_name = "Medic"
	icon_state = "medical"
	desc = "A card covered in the blood stains of the wild ride."
	access = list(access_medical, access_genetics, access_morgue, access_chemistry, access_paramedic, access_virology, access_surgery, access_cmo)

/obj/item/weapon/card/id/security
	name = "Security ID"
	registered_name = "Officer"
	icon_state = "security"
	desc = "Some say these cards are drowned in the tears of assistants, forged in the burning bodies of clowns."
	access = list(access_sec_doors, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)

/obj/item/weapon/card/id/research
	name = "Research ID"
	registered_name = "Scientist"
	icon_state = "research"
	desc = "Pinnacle of name technology."
	access = list(access_research, access_tox, access_tox_storage, access_robotics, access_xenobiology, access_rd)

/obj/item/weapon/card/id/supply
	name = "Supply ID"
	registered_name = "Cargonian"
	icon_state = "cargo"
	desc = "ROH ROH! HEIL THE QUARTERMASTER!"
	access = list(access_mailsorting, access_mining, access_mining_station, access_cargo, access_qm, access_taxi)

/obj/item/weapon/card/id/engineering
	name = "Engineering ID"
	registered_name = "Engineer"
	icon_state = "engineering"
	desc = "Shame it's going to be lost in the void of a black hole."
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva, access_construction)

/obj/item/weapon/card/id/hos
	name = "Head of Security ID"
	registered_name = "HoS"
	icon_state = "HoS"
	desc = "An ID awarded to only the most robust shits in the buisness."
	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers, access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting, access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)

/obj/item/weapon/card/id/cmo
	name = "Chief Medical Officer ID"
	registered_name = "CMO"
	icon_state = "CMO"
	desc = "It gives off the faint smell of chloral, mixed with a backdraft of shittery."
	access = list(access_medical, access_morgue, access_genetics, access_heads, access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce, access_keycard_auth, access_sec_doors, access_paramedic)

/obj/item/weapon/card/id/rd
	name = "Research Director ID"
	registered_name = "RD"
	icon_state = "RD"
	desc = "If you put your ear to the card, you can faintly hear screaming, glomping, and mechs. What the fuck."
	access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue, access_tox_storage, access_teleporter, access_sec_doors, access_research, access_robotics, access_xenobiology, access_ai_upload, access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway)

/obj/item/weapon/card/id/ce
	name = "Chief Engineer ID"
	registered_name = "CE"
	icon_state = "CE"
	desc = "The card has a faint aroma of autism."
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva, access_heads, access_construction, access_sec_doors, access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_ai_upload)

/obj/item/weapon/card/id/clown
	name = "Pink ID"
	registered_name = "HONK!"
	icon_state = "clown"
	desc = "Even looking at the card strikes you with deep fear."
	access = list(access_clown, access_theatre, access_maint_tunnels)

/obj/item/weapon/card/id/mime
	name = "Black and White ID"
	registered_name = "..."
	icon_state = "mime"
	desc = "..."
	access = list(access_clown, access_theatre, access_maint_tunnels)

/obj/item/weapon/card/id/thunderdome/red
	name = "Thunderdome Red ID"
	registered_name = "Red Team Fighter"
	assignment = "Red Team Fighter"
	icon_state = "TDred"
	desc = "This ID card is given to those who fought inside the thunderdome for the Red Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/weapon/card/id/thunderdome/green
	name = "Thunderdome Green ID"
	registered_name = "Green Team Fighter"
	assignment = "Green Team Fighter"
	icon_state = "TDgreen"
	desc = "This ID card is given to those who fought inside the thunderdome for the Green Team. Not many have lived to see one of those, even fewer lived to keep it."
