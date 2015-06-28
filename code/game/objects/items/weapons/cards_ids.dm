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

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if (t)
		src.name = "data disk- '[t]'"
	else
		src.name = "data disk"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/card/data/clown
	name = "\proper the coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/*
 * ID CARDS
 */
/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	flags = NOBLUDGEON

/obj/item/weapon/card/emag/attack()
	return

/obj/item/weapon/card/emag/afterattack(atom/target, mob/user, proximity)
	var/atom/A = target
	if(!proximity) return
	A.emag_act(user)

/obj/item/weapon/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	var/mining_points = 0 //For redeeming at mining equipment vendors
	var/list/access = list()
	var/registered_name = null // The name registered_name on the card
	var/credits = 0 //Amount of dosh stored on card
	var/pin = 1234 //The 4-digit PIN number used in ATMs
	var/datum/bankaccount/linked_account = null //The bank account the card is linked to
	slot_flags = SLOT_ID

	var/assignment = null
	var/dorm = 0		// determines if this ID has claimed a dorm already

/obj/item/weapon/card/id/New()
	..()
	pin = rand(0000,9999)
	if(!ishuman(src.loc))
		return
	var/mob/living/carbon/human/H = src.loc
	var/list/low_pay_boost_jobs = list("Cargo Technician", "Chief Medical Officer", "Chief Engineer", "Research Director", "Security Officer", "Warden")
	var/list/med_pay_boost_jobs = list("Head of Personnel", "Head of Security", "Quartermaster")
	var/list/high_pay_boost_jobs = list("Captain")
	if(H.job in low_pay_boost_jobs) //125 creds. roundstart
		credits += 125
		return
	else if(H.job in med_pay_boost_jobs) //150 creds. roundstart
		credits += 150
		return
	else if(H.job in high_pay_boost_jobs) //200 creds. roundstart
		credits += 200
		return
	else //All other jobs starts with 100 credits
		credits += 100
	spawn(20) //Delay before message, to allow it to show up after the rest of the roundstart stuff
		H << "<span class='info'>The randomized PIN for your identification card this shift is [pin]. This can be changed at any ATM.</span>"
		return

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	user.visible_message("<span class='notice'>[user] shows you: \icon[src] [src.name].</span>", \
					"<span class='notice'>You show \the [src.name].</span>")
	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/examine(mob/user)
	..()
	if(mining_points)
		user << "There's [mining_points] mining equipment redemption point\s loaded onto this card."

/obj/item/weapon/card/id/GetAccess()
	return access

/obj/item/weapon/card/id/GetID()
	return src

/*
Usage:
update_label()
	Sets the id name to whatever registered_name and assignment is

update_label("John Doe", "Clowny")
	Properly formats the name and occupation and sets the id name to the arguments
*/
/obj/item/weapon/card/id/proc/update_label(var/newname, var/newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/weapon/card/id/silver
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"
	credits = 150 //Heads start out with a few more credits

/obj/item/weapon/card/id/gold
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"
	credits = 200 //Captain starts with even more!

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels, access_syndicate)
	origin_tech = "syndicate=3"

/obj/item/weapon/card/id/syndicate/afterattack(var/obj/item/weapon/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		src.access |= I.access
		if(istype(user, /mob/living) && user.mind)
			if(user.mind.special_role)
				usr << "<span class='notice'>The card's microscanners activate as you pass it over the ID, copying its access and transferring its credits.</span>"
				src.credits += I.credits //Steal all their credits!
				I.credits = 0


/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var t = copytext(sanitize(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name)as text | null),1,26)
		if(!t || t == "Unknown" || t == "floor" || t == "wall" || t == "r-wall") //Same as mob/new_player/prefrences.dm
			if (t)
				alert("Invalid name.")
			return
		src.registered_name = t

		var u = copytext(sanitize(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")as text | null),1,MAX_MESSAGE_LEN)
		if(!u)
			src.registered_name = ""
			return
		src.assignment = u
		update_label()
		user << "<span class='notice'>You successfully forge the ID card.</span>"
	else
		..()

/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate)

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"
	New()
		var/datum/job/captain/J = new/datum/job/captain
		access = J.get_access()
		..()

/obj/item/weapon/card/id/centcom
	name = "\improper Centcom ID"
	desc = "An ID straight from Cent. Com."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"
	New()
		access = get_all_centcom_access()
		..()
/obj/item/weapon/card/id/ert
	name = "\improper Centcom ID"
	desc = "A ERT ID card"
	icon_state = "centcom"
	registered_name = "Emergency Response Team Commander"
	assignment = "Emergency Response Team Commander"
	New() access = get_all_accesses()+get_ert_access("commander")-access_change_ids

/obj/item/weapon/card/id/ert/Security
	registered_name = "Security Response Officer"
	assignment = "Security Response Officer"
	New() access = get_all_accesses()+get_ert_access("sec")-access_change_ids

/obj/item/weapon/card/id/ert/Engineer
	registered_name = "Engineer Response Officer"
	assignment = "Engineer Response Officer"
	New() access = get_all_accesses()+get_ert_access("eng")-access_change_ids

/obj/item/weapon/card/id/ert/Medical
	registered_name = "Medical Response Officer"
	assignment = "Medical Response Officer"
	New() access = get_all_accesses()+get_ert_access("med")-access_change_ids

/obj/item/weapon/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "orange"
	item_state = "orange-id"
	assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0

/obj/item/weapon/card/id/prisoner/attack_self(mob/user as mob)
	usr << "<span class='notice'>You have accumulated [points] out of the [goal] points you need for freedom.</span>"

/obj/item/weapon/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/weapon/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/weapon/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/weapon/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/weapon/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/weapon/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/weapon/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"
