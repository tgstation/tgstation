/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon = 'goon/icons/obj/goon_terminals.dmi'
	idle_power_usage = 100
	var/siphoning = FALSE
	var/next_warning = 0
	var/obj/item/device/radio/radio
	var/radio_channel = "Common"
	var/minimum_time_between_warnings = 400
	var/datum/techweb/linked_techweb

/obj/machinery/computer/bank_machine/Initialize()
	. = ..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	linked_techweb = SSresearch.science_tech

/obj/machinery/computer/bank_machine/Destroy()
	QDEL_NULL(radio)
	. = ..()

/obj/machinery/computer/bank_machine/attackby(obj/item/I, mob/user)
	var/value = 0
	if(istype(I, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/C = I
		value = C.value * C.amount
	if(value)
		SSshuttle.points += value
		to_chat(user, "<span class='notice'>You deposit [I]. The station now has [SSshuttle.points] credits.</span>")
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
			new /obj/item/stack/spacecash/c200(drop_location()) // will autostack
			playsound(src.loc, 'sound/items/poster_being_created.ogg', 100, 1)
			SSshuttle.points -= 200
			if(next_warning < world.time && prob(15))
				var/area/A = get_area(loc)
				var/message = "Unauthorized credit withdrawal underway in [A.map_name]!!"
				radio.talk_into(src, message, radio_channel, get_spans())
				next_warning = world.time + minimum_time_between_warnings

/obj/machinery/computer/bank_machine/get_spans()
	. = ..() | SPAN_ROBOT

/obj/machinery/computer/bank_machine/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(usr)
	var/dat = "[world.name] secure vault. Authorized personnel only.<br>"
	dat += "Current Credit Balance: [SSshuttle.points] credits.<br>"

	if(istype(linked_techweb))
		dat += "Current Research Point Balance: [linked_techweb.research_points] research points.<br>"
		dat += "<A href='?src=[REF(src)];credstobitcoin=1'>Exchange Credits for Research Points</A><br>"

	if(!siphoning)
		dat += "<A href='?src=[REF(src)];siphon=1'>Siphon Credits</A><br>"
	else
		dat += "<A href='?src=[REF(src)];halt=1'>Halt Credit Siphon</A><br>"

	dat += "<a href='?src=[REF(user)];mach_close=computer'>Close</a>"

	popup.set_content("<center>[dat]</center>")
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/bank_machine/Topic(href, href_list)
	if(..())
		return
	if(href_list["credstobitcoin"])
		var/credstoconv = input(usr, "Please enter the number of credits you want to convert to research points. The current conversion rate is [CONFIG_GET(number/cargo_credits_per_research_point)] credits to 1 research point", "Credits to Research Points") as null|num
		if(!in_range(src, usr) && src.loc != usr && (!isAI(usr) && !IsAdminGhost(usr)))
			return
		if(credstoconv)
			var/bitcoinsreceived = credstoconv/CONFIG_GET(number/cargo_credits_per_research_point)
			linked_techweb.research_points += bitcoinsreceived
			SSshuttle.points += -credstoconv
			say("Thank you for your transaction. You have successfully converted [credstoconv] to [bitcoinsreceived] research points.")
	if(href_list["siphon"])
		say("Siphon of station credits has begun!")
		siphoning = TRUE
	if(href_list["halt"])
		say("Station credit withdrawal halted.")
		siphoning = FALSE

	interact(usr)
