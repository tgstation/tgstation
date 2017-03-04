/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon = 'goon/icons/obj/goon_terminals.dmi'
	idle_power_usage = 100
	var/siphoning = FALSE
	var/last_warning = 0

/obj/machinery/computer/bank_machine/attackby(obj/item/I, mob/user)
	var/value = 0
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value * C.amount
	if(istype(I, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C  = I
		value = C.value
	if(value)
		SSshuttle.points += value
		user << "<span class='notice'>You deposit [I]. The station now has [SSshuttle.points] credits.</span>"
		qdel(I)
		return
	return ..()


/obj/machinery/computer/bank_machine/process()
	..()
	if(siphoning)
		if (stat & (BROKEN|NOPOWER))
			say("Insufficient power. Halting siphon.")
			siphoning =	FALSE
		if(SSshuttle.points < 200)
			say("Station funds depleted. Halting siphon.")
			siphoning = FALSE
		else
			var/obj/item/stack/spacecash/c200/on_turf = locate() in src.loc
			if(on_turf && on_turf.amount < on_turf.max_amount)
				on_turf.amount++
			else
				new /obj/item/stack/spacecash/c200(get_turf(src))
			playsound(src.loc, 'sound/items/poster_being_created.ogg', 100, 1)
			SSshuttle.points -= 200
			if(last_warning < world.time && prob(15))
				var/area/A = get_area(loc)
				minor_announce("Unauthorized credit withdrawal underway in [A.map_name]." , "Network Breach", TRUE)
				last_warning = world.time + 400


/obj/machinery/computer/bank_machine/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(usr)
	var/dat = "[world.name] secure vault. Authorized personnel only.<br>"
	dat += "Current Balance: [SSshuttle.points] credits.<br>"
	if(!siphoning)
		dat += "<A href='?src=\ref[src];siphon=1'>Siphon Credits</A><br>"
	else
		dat += "<A href='?src=\ref[src];halt=1'>Halt Credit Siphon</A><br>"

	dat += "<a href='?src=\ref[user];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", "Bank Vault", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/bank_machine/Topic(href, href_list)
	if(..())
		return
	if(href_list["siphon"])
		say("<span class='warning'>Siphon of station credits has begun!</span>")
		siphoning = TRUE
	if(href_list["halt"])
		say("<span class='warning'>Station credit withdrawal halted.</span>")
		siphoning = FALSE