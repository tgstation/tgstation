/obj/item/weapon/paper/demotion_key
	name = "Human Resources: Demotion Fax Key"
	info = "<center><B>Fax Machine Demotion Key</B></center><BR><BR>This document is intended for use in the station fax machines.<br><ol><li>Insert into fax with your Internal Affairs ID.</li><li>Select NANOTRASEN HR to send to; Requires official Agent authorization.</li><li>Use the printed chip to carefully set a name.</li></ol> Remember to probably capitolize the employee name. Acquire Heads of Staff stamps to bar respective access, and once you have completed gathering authorizations you can apply the chip to the intended ID card.<br><br>In case of a mistake, acquire a new ID card as Identification Computers cannot bypass the chip."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	stamps = "<br><br><i>This document has an intricate Nanontrasen logo in magnetic ink. It looks impossible to forge.</i>"

/obj/item/weapon/paper/commendation_key
	name = "Human Resources: Commendation Fax Key"
	info = "<center><B>Fax Machine Commendation Key</B></center><BR><BR>This document is intended for use in the station fax machines.<br><ol><li>Insert into fax with your Internal Affairs ID.</li><li>Select NANOTRASEN HR to send to; Requires official Agent authorization.</li><li>Take the printed sticker and give cordially to valued employee.</li></ol> Commendations should only be given to outstanding crew members and those who exhibit positive, productive qualities."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	stamps = "<br><br><i>This document has an intricate Nanontrasen logo in magnetic ink. It looks impossible to forge.</i>"


/obj/item/demote_chip //messy variables but I hate lists in byond
	name = "unprogrammed demotion microchip"
	desc = "A microchip that removes certain access when applied to ID cards."
	icon = 'icons/obj/card.dmi'
	icon_state = "demote_chip"
	w_class = 1.0
	var/target_name = null
	var/cap = 0
	var/hos = 0
	var/cmo = 0
	var/ce = 0
	var/hop = 0
	var/rd = 0
	var/clown = 0


/obj/item/demote_chip/New()
	..()

/obj/item/demote_chip/attack_self(mob/user as mob)
	if(target_name != null) //Used hand-labeler as example
		user << "<span class='notice'>The target name cannot be reset!</span>"
		return
	else
		var/str = copytext(reject_bad_text(input(user,"Enter the properly capitolized name for demotion","Set name","")),1,MAX_NAME_LEN)
		if(!str)
			alert("Invalid name.")
			target_name = null
			return
		target_name = str
		name = "[target_name]'s demotion microchip"
		desc = desc + " Stamped by:"
		user << "\blue The demotion microchip for [src.target_name] is now ready to be stamped."

/obj/item/demote_chip/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/stamp))
		var/obj/item/weapon/stamp/S = I
		if(target_name != null)//Stamper must be able to see who he is banning
			if(istype(S, /obj/item/weapon/stamp/captain))
				if(cap == 0)
					desc = desc + "/Captain"
				cap = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
			if(istype(S, /obj/item/weapon/stamp/hop))
				if(hop == 0)
					desc = desc + "/HoP"
				hop = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
			if(istype(S, /obj/item/weapon/stamp/hos))
				if(hos == 0)
					desc = desc + "/HoS"
				hos = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
			if(istype(S, /obj/item/weapon/stamp/ce))
				if(ce == 0)
					desc = desc + "/CE"
				ce = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
			if(istype(S, /obj/item/weapon/stamp/rd))
				if(rd == 0)
					desc = desc + "/RD"
				rd = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
			if(istype(S, /obj/item/weapon/stamp/cmo))
				if(cmo == 0)
					desc = desc + "/CMO"
				cmo = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
			if(istype(S, /obj/item/weapon/stamp/clown))
				if(clown == 0)
					desc = desc + "/HONK"
				clown = 1
				user << "\blue You stamp the demotion microchip of [target_name]."
		else
			user << "\blue The chip has not been initialized."
	else
		return ..()

/obj/item/weapon/card/id/syndicate/attackby(var/obj/item/I as obj, mob/user as mob)
	//placebo, does not affect access on syndie agent card
	if(istype(I, /obj/item/demote_chip/))
		var/obj/item/demote_chip/DE = I
		if(registered_name != DE.target_name)
			user << "\blue Failed to apply, names do not match."
		else if(bans != null)
			user << "\blue This card already has a microchip applied"
		else
			icon_state = "centcom_old"
			bans = "9" //if get_region_accesses ever uses 9 we're fucked
			del(DE)
	else
		return ..()

/obj/item/weapon/card/id/attackby(var/obj/item/I as obj, mob/user as mob)
	//Check for if names match, card already has a chip, and its not a captains ID.
	if(istype(I, /obj/item/demote_chip))
		var/obj/item/demote_chip/D = I
		if(registered_name != D.target_name)
			user << "\blue Failed to apply, names do not match."
		else if(bans != null)
			user << "\blue This card already has a microchip applied"
		else if(icon_state == "gold")
			user << "\blue This microchip cannot apply to this card type."
		else

			if(D.cap == 1)
				access -= get_region_accesses(5)
				bans = bans + "5"
			if(D.hop == 1)
				access -= get_region_accesses(6)
				access -= get_region_accesses(7)
				bans = bans + "67"
			if(D.hos == 1)
				access -= get_region_accesses(1)
				bans = bans + "1"
			if(D.ce == 1)
				access -= get_region_accesses(4)
				bans = bans + "4"
			if(D.rd == 1)
				access -= get_region_accesses(3)
				bans = bans + "3"
			if(D.cmo == 1)
				access -= get_region_accesses(2)
				bans = bans + "2"
			if(bans == null)
				user << "\blue You require at least one stamp."
				return
			icon_state = "centcom_old"
			del(D)
	else
		return ..()
