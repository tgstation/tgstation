/obj/machinery/pinpointer_dispenser
	name = "wayfinding pinpointer synthesizer"
	icon = 'icons/obj/machines/wayfinding.dmi'
	icon_state = "pinpointersynth"
	desc = "A machine given the thankless job of trying to sell these pinpointers. They point to common locations."
	density = FALSE
	layer = HIGH_OBJ_LAYER
	///List of user-specific cooldowns to prevent pinpointer spam.
	var/list/user_spawn_cooldowns = list()
	///List of user-specific cooldowns to prevent message spam.
	var/list/user_interact_cooldowns = list()
	///Time per person to spawn another pinpointer.
	var/spawn_cooldown = 2 MINUTES
	///Time per person for subsequent interactions.
	var/interact_cooldown = 4 SECONDS
	///How many credits the dispenser account starts with to cover wayfinder refunds.
	var/start_bal = 200
	///How many credits recycling a pinpointer rewards you.
	var/refund_amt = 40
	var/datum/bank_account/synth_acc = new /datum/bank_account/remote
	var/ppt_cost = 0 //Jan 9 '21: 2560 had its difficulties for NT as well
	var/expression_timer
	///Avoid being Reddit.
	var/funnyprob = 5

/obj/machinery/pinpointer_dispenser/Initialize(mapload)
	. = ..()
	var/datum/bank_account/civ_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	if(civ_acc)
		synth_acc.transfer_money(civ_acc, start_bal) //float has to come from somewhere, right?

	synth_acc.account_holder = name

	desc += " [ppt_cost ? "Only [ppt_cost] credits! " : ""]It also synthesises costumes for some reason."

	set_expression("happy") //actual first law of robotics it needs to be friendly in a mindless way

/obj/machinery/pinpointer_dispenser/attack_hand(mob/living/user)
	if(world.time < user_interact_cooldowns[user.real_name])
		to_chat(user, "<span class='notice'>It just grins at you. Maybe you should give it a few seconds?</span>")
		set_expression("veryhappy", 2 SECONDS)
		return

	user_interact_cooldowns[user.real_name] = world.time + interact_cooldown

	for(var/obj/item/pinpointer/wayfinding/WP in user.GetAllContents())
		set_expression("veryhappy", 2 SECONDS)
		say("<span class='robot'>You already have a pinpointer!</span>")
		return

	var/msg
	var/dispense = TRUE
	var/obj/item/pinpointer/wayfinding/pointat
	for(var/obj/item/pinpointer/wayfinding/WP in range(7, user))
		set_expression("veryhappy", 2 SECONDS)
		say("<span class='robot'>[WP.owner == user.real_name ? "Your" : "A"] pinpointer is there!</span>")
		pointat(WP)
		return

	if(world.time < user_spawn_cooldowns[user.real_name])
		var/secsleft = (user_spawn_cooldowns[user.real_name] - world.time) / 10
		msg += "to wait another [secsleft/60 > 1 ? "[round(secsleft/60,1)] minute\s" : "[round(secsleft)] second\s"] before I can dispense a pinpointer"
		dispense = FALSE

	var/datum/bank_account/cust_acc = user.get_bank_account()

	if(cust_acc)
		if(!cust_acc.has_money(ppt_cost))
			msg += "[!msg ? "to find [ppt_cost-cust_acc.account_balance] more credit\s" : " and find [ppt_cost-cust_acc.account_balance] more credit\s"]"
			dispense = FALSE

	if(!dispense)
		set_expression("sad", 2 SECONDS)
		if(pointat)
			msg += ". Get [pointat.owner == user.real_name ? "your" : "that"] pinpointer over there instead"
			pointat(pointat)
		say("<span class='robot'>Sorry, [user.first_name()]. You need [msg]!</span>")
		return

	if(synth_acc.transfer_money(cust_acc, ppt_cost))
		set_expression("veryhappy", 2 SECONDS)
		say("<span class='robot'>Here's your pinpointer!</span>")
		var/obj/item/pinpointer/wayfinding/P = new /obj/item/pinpointer/wayfinding(get_turf(src))
		user_spawn_cooldowns[user.real_name] = world.time + spawn_cooldown
		user.put_in_hands(P)
		P.owner = user.real_name

/obj/machinery/pinpointer_dispenser/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pinpointer/wayfinding))
		var/obj/item/pinpointer/wayfinding/WP = I
		to_chat(user, "<span class='notice'>You put \the [WP] in the return slot.</span>")
		var/refundiscredits = TRUE
		if(synth_acc.has_money(refund_amt) && !WP.roundstart && WP.owner != user.real_name) //exploiters bring a friend
			synth_acc._adjust_money(-refund_amt)
			var/obj/item/holochip/HC = new /obj/item/holochip(loc)
			HC.credits = refund_amt
			HC.name = "[HC.credits] credit holochip"
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				H.put_in_hands(HC)
		else
			refundiscredits = FALSE
			var/costume = pick(subtypesof(/obj/effect/spawner/bundle/costume))
			new costume(user.loc)
		qdel(WP)
		set_expression("veryhappy", 2 SECONDS)
		var/refund = "some credits."
		var/whatyoudid = "recycling"
		if(!refundiscredits)
			refund = "freshly synthesised costume!"
			if(prob(funnyprob))
				refund = "pulse rifle! Just kidding it's a costume."
			else if(prob(funnyprob))
				whatyoudid = "feeding me"
		say("<span class='robot'>Thank you for [whatyoudid], [user.first_name()]! Here is a [refund]</span>")

/obj/machinery/pinpointer_dispenser/proc/set_expression(type, duration)
	cut_overlays()
	deltimer(expression_timer)
	add_overlay(type)
	if(duration)
		expression_timer = addtimer(CALLBACK(src, .proc/set_expression, "happy"), duration, TIMER_STOPPABLE)

/obj/machinery/pinpointer_dispenser/pointat(A)
	. = ..()
	visible_message("<span class='name'>[src]</span> points at [A].")

//Pinpointer itself
/obj/item/pinpointer/wayfinding //Help players new to a station find their way around
	name = "wayfinding pinpointer"
	desc = "A handheld tracking device that points to useful places."
	icon_state = "pinpointer_way"
	var/owner = null
	var/list/beacons = list()
	var/roundstart = FALSE

/obj/item/pinpointer/wayfinding/attack_self(mob/living/user)
	if(active)
		toggle_on()
		to_chat(user, "<span class='notice'>You deactivate your pinpointer.</span>")
		return

	if (!owner)
		owner = user.real_name

	if(beacons.len)
		beacons.Cut()
	for(var/obj/machinery/navbeacon/B in GLOB.wayfindingbeacons)
		beacons[B.codes["wayfinding"]] = B

	if(!beacons.len)
		to_chat(user, "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "", "Pinpoint") as null|anything in sortList(beacons)
	if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
		return

	target = beacons[A]
	toggle_on()
	to_chat(user, "<span class='notice'>You activate your pinpointer.</span>")

/obj/item/pinpointer/wayfinding/examine(mob/user)
	. = ..()
	var/msg = "Its tracking indicator reads "
	if(target)
		var/obj/machinery/navbeacon/wayfinding/B  = target
		msg += "\"[B.codes["wayfinding"]]\"."
	else
		msg = "Its tracking indicator is blank."
	if(owner)
		msg += " It belongs to [owner]."
	. += msg

/obj/item/pinpointer/wayfinding/scan_for_target()
	if(!target) //target can be set to null from above code, or elsewhere
		active = FALSE

//Navbeacon that initialises with wayfinding codes
/obj/machinery/navbeacon/wayfinding
	wayfinding = TRUE

/* Defining these here instead of relying on map edits because it makes it easier to place them */

//Command
/obj/machinery/navbeacon/wayfinding/bridge
	location = "Bridge"

/obj/machinery/navbeacon/wayfinding/hop
	location = "Head of Personnel's Office"

/obj/machinery/navbeacon/wayfinding/vault
	location = "Vault"

/obj/machinery/navbeacon/wayfinding/teleporter
	location = "Teleporter"

/obj/machinery/navbeacon/wayfinding/gateway
	location = "Gateway"

/obj/machinery/navbeacon/wayfinding/eva
	location = "EVA Storage"

/obj/machinery/navbeacon/wayfinding/aiupload
	location = "AI Upload"

/obj/machinery/navbeacon/wayfinding/minisat_access_ai
	location = "AI MiniSat Access"

/obj/machinery/navbeacon/wayfinding/minisat_access_tcomms
	location = "Telecomms MiniSat Access"

/obj/machinery/navbeacon/wayfinding/minisat_access_tcomms_ai
	location = "AI and Telecomms MiniSat Access"

/obj/machinery/navbeacon/wayfinding/tcomms
	location = "Telecommunications"

//Departments
/obj/machinery/navbeacon/wayfinding/sec
	location = "Security"

/obj/machinery/navbeacon/wayfinding/det
	location = "Detective's Office"

/obj/machinery/navbeacon/wayfinding/research
	location = "Research"

/obj/machinery/navbeacon/wayfinding/engineering
	location = "Engineering"

/obj/machinery/navbeacon/wayfinding/techstorage
	location = "Technical Storage"

/obj/machinery/navbeacon/wayfinding/atmos
	location = "Atmospherics"

/obj/machinery/navbeacon/wayfinding/med
	location = "Medical"

/obj/machinery/navbeacon/wayfinding/chemfactory
	location = "Chemistry Factory"

/obj/machinery/navbeacon/wayfinding/cargo
	location = "Cargo"

//Common areas
/obj/machinery/navbeacon/wayfinding/bar
	location = "Bar"

/obj/machinery/navbeacon/wayfinding/dorms
	location = "Dormitories"

/obj/machinery/navbeacon/wayfinding/court
	location = "Courtroom"

/obj/machinery/navbeacon/wayfinding/tools
	location = "Tool Storage"

/obj/machinery/navbeacon/wayfinding/library
	location = "Library"

/obj/machinery/navbeacon/wayfinding/chapel
	location = "Chapel"

/obj/machinery/navbeacon/wayfinding/minisat_access_chapel_library
	location = "Chapel and Library MiniSat Access"

//Service
/obj/machinery/navbeacon/wayfinding/kitchen
	location = "Kitchen"

/obj/machinery/navbeacon/wayfinding/hydro
	location = "Hydroponics"

/obj/machinery/navbeacon/wayfinding/janitor
	location = "Janitor's Closet"

/obj/machinery/navbeacon/wayfinding/lawyer
	location = "Lawyer's Office"

//Shuttle docks
/obj/machinery/navbeacon/wayfinding/dockarrival
	location = "Arrival Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/dockesc
	location = "Escape Shuttle Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod
	location = "Escape Pod Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod1
	location = "Escape Pod 1 Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod2
	location = "Escape Pod 2 Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod3
	location = "Escape Pod 3 Dock"

/obj/machinery/navbeacon/wayfinding/dockescpod4
	location = "Escape Pod 4 Dock"

/obj/machinery/navbeacon/wayfinding/dockaux
	location = "Auxiliary Dock"

//Maint
/obj/machinery/navbeacon/wayfinding/incinerator
	location = "Incinerator"

/obj/machinery/navbeacon/wayfinding/disposals
	location = "Disposals"
