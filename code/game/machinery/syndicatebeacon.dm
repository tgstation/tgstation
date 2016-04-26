//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//  Beacon randomly spawns in space
//	When a non-traitor (no special role in /mind) uses it, he is given the choice to become a traitor
//	If he accepts there is a random chance he will be accepted, rejected, or rejected and killed
//	Bringing certain items can help improve the chance to become a traitor


/obj/machinery/syndicate_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1

	var/temptext = ""
	var/selfdestructing = 0
	var/charges = 1

	attack_hand(var/mob/user as mob)
		usr.set_machine(src)
		var/dat = "<font color=#005500><i>Scanning [pick("retina pattern", "voice print", "fingerprints", "dna sequence")]...<br>Identity confirmed,<br></i></font>"
		if(istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
			if(is_special_character(user))
				dat += "<font color=#07700><i>Operative record found. Greetings, Agent [user.name].</i></font><br>"
			else if(charges < 1)
				dat += "<TT>Connection severed.</TT><BR>"
			else
				var/honorific = "Mr."
				if(user.gender == FEMALE)
					honorific = "Ms."
				dat += "<font color=red><i>Identity not found in operative database. What can the Syndicate do for you today, [honorific] [user.name]?</i></font><br>"
				if(!selfdestructing)
					dat += "<br><br><A href='?src=\ref[src];betraitor=1;traitormob=\ref[user]'>\"[pick("I want to switch teams.", "I want to work for you.", "Let me join you.", "I can be of use to you.", "You want me working for you, and here's why...", "Give me an objective.", "How's the 401k over at the Syndicate?")]\"</A><BR>"
		dat += temptext
		user << browse(dat, "window=syndbeacon")
		onclose(user, "syndbeacon")

	Topic(href, href_list)
		if(..()) return 1
		if(href_list["betraitor"])
			if(charges < 1)
				src.updateUsrDialog()
				return
			var/mob/M = locate(href_list["traitormob"])
			if(M.mind.special_role)
				temptext = "<i>We have no need for you at this time. Have a pleasant day.</i><br>"
				src.updateUsrDialog()
				return
			charges -= 1
			switch(rand(1,2))
				if(1)
					temptext = "<font color=red><i><b>Double-crosser. You planned to betray us from the start. Allow us to repay the favor in kind.</b></i></font>"
					src.updateUsrDialog()
					spawn(rand(50,200)) selfdestruct()
					return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/N = M
				ticker.mode.equip_traitor(N)
				ticker.mode.traitors += N.mind
				N.mind.special_role = "traitor"
				var/objective = "Free Objective"
				switch(rand(1,100))
					if(1 to 50)
						objective = "Steal [pick("a hand teleporter", "the Captain's antique laser gun", "a jetpack", "the Captain's ID", "the Captain's jumpsuit")]."
					if(51 to 60)
						objective = "Destroy 70% or more of the station's plasma tanks."
					if(61 to 70)
						objective = "Cut power to 80% or more of the station's tiles."
					if(71 to 80)
						objective = "Destroy the AI."
					if(81 to 90)
						objective = "Kill all monkeys aboard the station."
					else
						objective = "Make certain at least 80% of the station evacuates on the shuttle."
				var/datum/objective/custom_objective = new(objective)
				custom_objective.owner = N.mind
				N.mind.objectives += custom_objective

				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = N.mind
				N.mind.objectives += escape_objective


				to_chat(M, "<B>You have joined the ranks of the Syndicate and become a traitor to the station!</B>")

				message_admins("[N]/([N.ckey]) has accepted a traitor objective from a syndicate beacon.")

				var/obj_count = 1
				for(var/datum/objective/OBJ in M.mind.objectives)
					to_chat(M, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
					obj_count++

		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return


	proc/selfdestruct()
		selfdestructing = 1
		spawn() explosion(src.loc, 1, rand(1,3), rand(3,8), 10)

//Not the best place for it but it's a hack job anyway -- Urist
/obj/machinery/singularity_beacon
	name = "singularity beacon"
	desc = "A suspicious-looking beacon. It looks like one of those snazzy state-of-the-art bluespace devices."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon"
	anchored = 0
	density = 1
	machine_flags = WRENCHMOVE | FIXED2WORK
	layer = MOB_LAYER

	light_color = LIGHT_COLOR_RED
	light_range_on = 2
	light_power_on = 2

	var/obj/item/weapon/cell/cell
	var/power_load = 1000 //A bit ugly. How much power this machine needs per tick. Equivalent to one minute on 30k W battery, two second ticks
	var/power_draw = 0 //If there's spare power on the grid, cannibalize it to charge the beacon's battery
	var/active = 0 //It doesn't use APCs, so use_power wouldn't really suit it
	var/icontype = "beacon"
	var/obj/structure/cable/attached = null

/obj/machinery/singularity_beacon/New()

	..()

	cell = new /obj/item/weapon/cell/hyper(src) //Singularity beacons are wasteful as fuck, that state-of-the-art cell will last a single minute

/obj/machinery/singularity_beacon/examine(mob/user)

	..()

	if(anchored)
		to_chat(user, "<span class='info'>It appears firmly secured to the floor. Nothing a wrench can't undo.</span>")
	to_chat(user, "<span class='info'>It features a power port. [attached ? "A power cable is running through it":"It looks like a power cable can be ran straight through it to power it"].</span>")
	if(active)
		to_chat(user, "<span class='info'>It is slowly pulsing red and emitting a deep humming sound.</span>")

/obj/machinery/singularity_beacon/proc/activate(mob/user = null)
	if(!anchored) //Sanity
		return
	if(!check_power())
		if(user)
			user.visible_message("<span class='warning'>[user] tries to start \the [src], but it shuts down halfway.</span>", \
			"<span class='warning'>You try to start \the [src], but it shuts down halfway. Looks like a power issue.</span>")
		else
			visible_message("<span class='warning'>\The [src] suddenly springs to life, only to shut down halfway through startup.</span>")
		return
	for(var/obj/machinery/singularity/singulo in power_machines)
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	set_light(light_range_on, light_power_on, light_color)
	if(user)
		user.visible_message("<span class='warning'>[user] starts up \the [src].</span>", \
		"<span class='notice'>You start up \the [src].</span>")
	else
		visible_message("<span class='warning'>\The [src] suddenly springs to life.</span>")

/obj/machinery/singularity_beacon/proc/deactivate(mob/user = null)
	for(var/obj/machinery/singularity/singulo in power_machines)
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	set_light(0)
	if(user)
		user.visible_message("<span class='warning'>[user] shuts down \the [src].</span>", \
		"<span class='notice'>You shut down \the [src].</span>")
	else
		visible_message("<span class='warning'>\The [src] suddenly shuts down.</span>")

/obj/machinery/singularity_beacon/attack_ai(mob/user as mob)
	to_chat(user, "<span class='warning'>You try to interface with \the [src], but it throws a strange encrypted error message.</span>")
	return

/obj/machinery/singularity_beacon/attack_hand(var/mob/user as mob)
	user.delayNextAttack(10) //Prevent spam toggling, otherwise you can brick the cell very quickly
	if(anchored)
		if(!attached)
			var/turf/T = get_turf(src)
			if(isturf(T) && !T.intact)
				attached = locate() in T
			if(attached)
				user.visible_message("<span class='notice'>[user] reaches for the exposed cabling and carefully runs it through \the [src]'s power port.</span>", \
				"<span class='notice'>You reach for the exposed cabling and carefully run it through \the [src]'s power port.</span>")
				return //Need to attack again to actually start
		return active ? deactivate(user) : activate(user)
	else
		to_chat(user, "<span class='warning'>\The [src] doesn't work on the fly, wrench it down first.</span>")
		return

/obj/machinery/singularity_beacon/wrenchAnchor(mob/user)

	if(active)
		to_chat(user, "<span class='warning'>Turn off \the [src] first.</span>")
		return
	..()
	if(attached)
		attached = null //Reset attached cable

/obj/machinery/singularity_beacon/Destroy()
	if(active)
		deactivate()
	if(cell)
		qdel(cell)
		cell = null
	..()

/*
* Added for a simple way to check power. Verifies that the beacon
* is connected to a wire, the wire is part of a powernet (that part's
* sort of redundant, since all wires either join or create one when placed)
* and that the powernet has at least 1500 power units available for use.
* Doesn't use them, though, just makes sure they're there.
* - QualityVan, Aug 11 2012
*/

//Simplified check for power. If we can charge straight out of the grid, do it
/obj/machinery/singularity_beacon/proc/check_wire_power()
	if(!attached) //No wire, move straight to battery power
		return 0
	var/datum/powernet/PN = attached.get_powernet()
	if(!PN) //Powernet is dead
		return 0
	if(PN.avail < power_load) //Cannot drain enough power, needs 1500 per tick, move to battery
		return 0
	else
		PN.load += power_load
		if(cell && cell.charge < cell.maxcharge && cell.charge > 0 && PN.netexcess)
			power_draw = min(cell.maxcharge - cell.charge, PN.netexcess) //Draw power directly from excess power
			PN.load += power_draw
			cell.give(power_draw) //We drew power from the grid, charge the cell
		return 1

//Use up the battery if powernet check fails
/obj/machinery/singularity_beacon/proc/check_battery_power()

	if(cell && cell.charge > power_load)
		cell.use(power_load)
		return 1
	else //Nothing here either
		return 0

//Composite of the two, called at every process
/obj/machinery/singularity_beacon/proc/check_power()

	return check_wire_power() || check_battery_power()

/obj/machinery/singularity_beacon/process()
	if(!active)
		return
	if(!anchored) //If it got unanchored "inexplicably"
		deactivate()
	else
		if(!check_power()) //No power
			deactivate()

/obj/machinery/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"
