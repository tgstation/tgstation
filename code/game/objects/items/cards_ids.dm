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
/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/data/verb/label(t as text)
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

/*
 * ID CARDS
 */
/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	origin_tech = "magnets=2;syndicate=2"
	flags_1 = NOBLUDGEON_1
	var/prox_check = TRUE //If the emag requires you to be in range

/obj/item/card/emag/bluespace
	name = "bluespace cryptographic sequencer"
	desc = "It's a blue card with a magnetic strip attached to some circuitry. It appears to have some sort of transmitter attached to it."
	color = rgb(40, 130, 255)
	origin_tech = "bluespace=4;magnets=4;syndicate=5"
	prox_check = FALSE

/obj/item/card/emag/attack()
	return

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	var/atom/A = target
	if(!proximity && prox_check)
		return
	A.emag_act(user)

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = SLOT_ID
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/mining_points = 0 //For redeeming at mining equipment vendors
	var/list/access = list()
	var/registered_name = null // The name registered_name on the card
	var/assignment = null
	var/access_txt // mapping aid



/obj/item/card/id/Initialize(mapload)
	. = ..()
	if(mapload && access_txt)
		access = text2access(access_txt)

/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if("assignment","registered_name")
				update_label()

/obj/item/card/id/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] shows you: [icon2html(src, viewers(user))] [src.name].</span>", \
					"<span class='notice'>You show \the [src.name].</span>")
	src.add_fingerprint(user)
	return

/obj/item/card/id/examine(mob/user)
	..()
	if(mining_points)
		to_chat(user, "There's [mining_points] mining equipment redemption point\s loaded onto this card.")

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetID()
	return src

/*
Usage:
update_label()
	Sets the id name to whatever registered_name and assignment is

update_label("John Doe", "Clowny")
	Properly formats the name and occupation and sets the id name to the arguments
*/
/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/card/id/silver
	name = "silver identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/id/gold
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/id/syndicate
	name = "agent card"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE)
	origin_tech = "syndicate=1"
	var/anyone = FALSE //Can anyone forge the ID or just syndicate?

/obj/item/card/id/syndicate/Initialize()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/card/id
	chameleon_action.chameleon_name = "ID Card"
	chameleon_action.initialize_disguises()

/obj/item/card/id/syndicate/afterattack(obj/item/O, mob/user, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/I = O
		src.access |= I.access
		if(isliving(user) && user.mind)
			if(user.mind.special_role)
				to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over the ID, copying its access.</span>")

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(isliving(user) && user.mind)
		if(user.mind.special_role || anyone)
			if(alert(user, "Action", "Agent ID", "Show", "Forge") == "Forge")
				var t = copytext(sanitize(input(user, "What name would you like to put on this card?", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name))as text | null),1,26)
				if(!t || t == "Unknown" || t == "floor" || t == "wall" || t == "r-wall") //Same as mob/dead/new_player/prefrences.dm
					if (t)
						alert("Invalid name.")
					return
				registered_name = t

				var u = copytext(sanitize(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")as text | null),1,MAX_MESSAGE_LEN)
				if(!u)
					registered_name = ""
					return
				assignment = u
				update_label()
				to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
				return
	..()

/obj/item/card/id/syndicate/anyone
	anyone = TRUE

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(ACCESS_SYNDICATE)

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	item_state = "gold_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/card/id/captains_spare/Initialize()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	..()

/obj/item/card/id/centcom
	name = "\improper CentCom ID"
	desc = "An ID straight from Cent. Com."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"

/obj/item/card/id/centcom/Initialize()
	access = get_all_centcom_access()
	..()

/obj/item/card/id/ert
	name = "\improper CentCom ID"
	desc = "A ERT ID card"
	icon_state = "centcom"
	registered_name = "Emergency Response Team Commander"
	assignment = "Emergency Response Team Commander"

/obj/item/card/id/ert/Initialize()
	access = get_all_accesses()+get_ert_access("commander")-ACCESS_CHANGE_IDS
	..()

/obj/item/card/id/ert/Security
	registered_name = "Security Response Officer"
	assignment = "Security Response Officer"

/obj/item/card/id/ert/Security/Initialize()
	access = get_all_accesses()+get_ert_access("sec")-ACCESS_CHANGE_IDS
	..()

/obj/item/card/id/ert/Engineer
	registered_name = "Engineer Response Officer"
	assignment = "Engineer Response Officer"

/obj/item/card/id/ert/Engineer/Initialize()
	access = get_all_accesses()+get_ert_access("eng")-ACCESS_CHANGE_IDS
	..()

/obj/item/card/id/ert/Medical
	registered_name = "Medical Response Officer"
	assignment = "Medical Response Officer"

/obj/item/card/id/ert/Medical/Initialize()
	access = get_all_accesses()+get_ert_access("med")-ACCESS_CHANGE_IDS
	..()

/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "orange"
	item_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0

/obj/item/card/id/prisoner/attack_self(mob/user)
	to_chat(usr, "<span class='notice'>You have accumulated [points] out of the [goal] points you need for freedom.</span>")

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"

/obj/item/card/id/mining
	name = "mining ID"
	access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/away
	name = "a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away/hotel
	name = "Staff ID"
	desc = "A staff ID used to access the hotel's doors."
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/obj/item/card/id/away/hotel/securty
	name = "Officer ID"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/obj/item/card/id/away/old
	name = "a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	access = list(ACCESS_AWAY_GENERAL)

/obj/item/card/id/away/old/sec
	name = "Security Officer ID"
	desc = "Security officers ID card."
	icon_state = "centcom"

/obj/item/card/id/away/old/sci
	name = "Scientist ID"
	desc = "Scientists ID card."
	icon_state = "centcom"

/obj/item/card/id/away/old/eng
	name = "Engineer ID"
	desc = "Engineers ID card."
	icon_state = "centcom"

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "Special ID card to allow access to APCs"
	icon_state = "centcom"
	access = list(ACCESS_ENGINE_EQUIP)