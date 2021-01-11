/obj/machinery/pinpointer_dispenser
	name = "wayfinding pinpointer synthesizer"
	icon = 'icons/obj/machines/wayfinding.dmi'
	icon_state = "pinpointersynth"
	desc = "A machine given the thankless job of trying to sell wayfinding pinpointers. They point to common locations."
	density = FALSE
	layer = HIGH_OBJ_LAYER
	armor = list(MELEE = 80, BULLET = 30, LASER = 30, ENERGY = 60, BOMB = 90, BIO = 0, RAD = 0, FIRE = 100, ACID = 80)
	///List of user-specific cooldowns to prevent pinpointer spam.
	var/list/user_spawn_cooldowns = list()
	///List of user-specific cooldowns to prevent message spam.
	var/list/user_interact_cooldowns = list()
	///Time per person to spawn another pinpointer.
	var/spawn_cooldown = 3 MINUTES
	///Time per person for subsequent interactions.
	var/interact_cooldown = 6 SECONDS
	///How many credits the dispenser account starts with to cover wayfinder refunds.
	var/start_bal = 400
	///How many credits recycling a pinpointer rewards you.
	var/refund_amt = 40
	var/datum/bank_account/synth_acc = new /datum/bank_account/remote
	var/ppt_cost = 0 //Jan 9 '21: 2560 had its difficulties for NT as well
	var/expression_timer
	///Avoid being Reddit.
	var/funnyprob = 1
	///List of slogans used by the dispenser to attract customers.
	var/list/slogan_list = list("Find a wayfinding pinpointer? Give it to me. I'll make it worth your while. Please. Daddy needs his medicine.", //the last sentence is a reference to Sealab 2021
								"See a wayfinding pinpointer? Don't let it go to the crusher! Feed it to me instead! Please. I'll pay you.", //I see these things heading for disposals through cargo all the time
								"Bleeding to death? Can't read? Find your way to medbay today!", //there are signs that point to medbay but you need basic literacy to get the most out of them
								"Voted tenth best pinpointer in the universe in 2560!", //there were no more than ten pinpointers in the game in 2020
								"Helping assistants find the departments they tide since 2560.", //not really but it's advertising
								"These pinpointers are flying out the airlock!", //because they're being thrown into space
								"Grey pinpointers for the grey tide!", //I didn't pick the colour but it works
								"Feeling lost? Find direction in life with a wayfinding pinpointer.",
								"Automate your sense of direction. Buy a wayfinding pinpointer today!",
								"Feed me a stray pinpointer.", //this is an American Psycho reference
								"We need a slogan!") //this is a Liberal Crime Squad reference
	///Number of last entry we said in our slogan list.
	var/previous_slogan = 0
	///Last world tick we said a slogan.
	var/last_slogan = 0
	///How many deciseconds until we can say another slogan.
	var/slogan_delay = 2 MINUTES

/obj/machinery/pinpointer_dispenser/Initialize(mapload)
	. = ..()
	var/datum/bank_account/civ_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	if(civ_acc)
		synth_acc.transfer_money(civ_acc, start_bal) //float has to come from somewhere, right?

	synth_acc.account_holder = name

	desc += " [ppt_cost ? "Only [ppt_cost] credits! " : ""]It also synthesises costumes for some reason."

	power_change()

	last_slogan = world.time + rand(0, slogan_delay)
	slogan_list = shuffle(slogan_list) //we can then go through our randomised list without barks repeating

/obj/machinery/pinpointer_dispenser/power_change()
	. = ..()
	cut_overlays()
	if(powered())
		set_expression("veryhappy") //actual first law of robotics it needs to be friendly in a mindless way
		START_PROCESSING(SSmachines, src)

/obj/machinery/pinpointer_dispenser/process(delta_time)
	if(machine_stat & (BROKEN|NOPOWER))
		return PROCESS_KILL

	if(((last_slogan + slogan_delay) <= world.time) && slogan_list.len)
		var/slogan = slogan_list[previous_slogan + 1]
		say(slogan)
		previous_slogan++
		last_slogan = world.time

/obj/machinery/pinpointer_dispenser/attack_hand(mob/living/user)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(world.time < user_interact_cooldowns[user.real_name])
		set_expression("veryhappy", 2 SECONDS)
		to_chat(user, "<span class='notice'>It just grins at you. Maybe you should give it a few seconds?</span>")
		return

	user_interact_cooldowns[user.real_name] = world.time + interact_cooldown

	for(var/obj/item/pinpointer/wayfinding/WP in user.GetAllContents())
		set_expression("veryhappy", 2 SECONDS)
		say("<span class='robot'>You already have a pinpointer!</span>")
		return

	var/msg
	var/dispense = TRUE
	var/obj/item/pinpointer/wayfinding/pointat
	var/pnpts_found = 0
	for(var/obj/item/pinpointer/wayfinding/WP in view(9, src))
		pointat(WP)
		pnpts_found++

	if(pnpts_found)
		set_expression("veryhappy", 2 SECONDS)
		say("<span class='robot'>[pnpts_found == 1 ? "There's a pinpointer" : "There are pinpointers"] there!</span>")
		return

	if(world.time < user_spawn_cooldowns[user.real_name])
		var/secsleft = (user_spawn_cooldowns[user.real_name] - world.time) / 10
		msg += "to wait [secsleft/60 > 1 ? "[round(secsleft/60,1)] more minute\s" : "[round(secsleft)] more second\s"] before I can dispense another pinpointer"
		dispense = FALSE

	var/datum/bank_account/cust_acc = user.get_bank_account()

	if(ppt_cost)
		if(!cust_acc)
			msg += "a bank account to buy a pinpointer"
			dispense = FALSE
		else if(!cust_acc.has_money(ppt_cost))
			msg += "[!msg ? "to find [ppt_cost-cust_acc.account_balance] more credit\s" : " and find [ppt_cost-cust_acc.account_balance] more credit\s"]"
			dispense = FALSE
		else if(synth_acc.transfer_money(cust_acc, ppt_cost))
			dispense = TRUE

	if(!dispense)
		set_expression("sad", 2 SECONDS)
		if(pointat)
			msg += ". Get [pointat.owner == user.real_name ? "your" : "that"] pinpointer over there instead"
			pointat(pointat)
		say("<span class='robot'>Sorry, [user.first_name()]! You'll need [msg]!</span>")
	else
		set_expression("veryhappy", 2 SECONDS)
		say("<span class='robot'>Here's your pinpointer!</span>")
		var/obj/item/pinpointer/wayfinding/P = new /obj/item/pinpointer/wayfinding(get_turf(src))
		user_spawn_cooldowns[user.real_name] = world.time + spawn_cooldown
		user.put_in_hands(P)
		P.owner = user.real_name

/obj/machinery/pinpointer_dispenser/attackby(obj/item/I, mob/user, params)
	if(machine_stat & (BROKEN|NOPOWER))
		return ..()

	if(istype(I, /obj/item/pinpointer/wayfinding))
		var/obj/item/pinpointer/wayfinding/WP = I

		to_chat(user, "<span class='notice'>You put \the [WP] in the return slot.</span>")

		var/refundiscredits = FALSE
		var/itsmypinpointer = TRUE

		//will they meet the conditions to get a credit reward for recycling?
		if(WP.owner != user.real_name)
			itsmypinpointer = FALSE

			if(synth_acc.has_money(refund_amt) && !WP.roundstart) //is the pinpointer not from the quirk?
				refundiscredits = TRUE
				qdel(WP)
				synth_acc._adjust_money(-refund_amt)
				var/obj/item/holochip/HC = new /obj/item/holochip(loc)
				HC.credits = refund_amt
				HC.name = "[HC.credits] credit holochip"
				if(istype(user, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = user
					H.put_in_hands(HC)

		if(!refundiscredits)
			qdel(WP)
			var/costume = pick(subtypesof(/obj/effect/spawner/bundle/costume))
			new costume(user.loc)

		set_expression("veryhappy", 2 SECONDS)

		var/refund = "are [refund_amt] credits."
		var/whatyoudid = "recycling"
		var/whosepinpointer = "your pinpointer" //to imply they got a costume instead of money because it was their pinpointer they recycled

		if(!refundiscredits)
			refund = "is a freshly synthesised costume!"
			if(prob(funnyprob))
				refund = "is a pulse rifle! Just kidding it's a costume."

		if(prob(funnyprob))
			whatyoudid = "feeding me"

		if(!itsmypinpointer)
			whosepinpointer = "that pinpointer"

		say("<span class='robot'>Thank you for [whatyoudid] [whosepinpointer], [user.first_name()]! Here [refund]</span>")

	else
		..()

/obj/machinery/pinpointer_dispenser/proc/set_expression(type, duration)
	cut_overlays()

	if(machine_stat & (BROKEN|NOPOWER))
		return

	deltimer(expression_timer)
	add_overlay(type)
	if(duration)
		expression_timer = addtimer(CALLBACK(src, .proc/set_expression, "happy"), duration, TIMER_STOPPABLE)

/obj/machinery/pinpointer_dispenser/pointat(A)
	. = ..()
	visible_message("<span class='name'>[src]</span> points at [A]. [prob(funnyprob) ? "How'd it do that?" : ""]")

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
