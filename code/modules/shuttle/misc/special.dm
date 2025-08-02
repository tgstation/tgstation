// Special objects for shuttle templates go here if nowhere else

// Wabbajack statue, a sleeping frog statue that shoots bolts of change if
// living carbons are put on its altar/tables

/obj/machinery/power/emitter/energycannon
	name = "Energy Cannon"
	desc = "A heavy duty industrial laser."
	icon = 'icons/obj/machines/engine/singularity.dmi'
	icon_state = "emitter_+a"
	base_icon_state = "emitter_+a"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	active = TRUE
	locked = TRUE
	welded = TRUE

/obj/machinery/power/emitter/energycannon/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/machinery/power/emitter/energycannon/magical
	name = "wabbajack statue"
	desc = "Who am I? What is my purpose in life? What do I mean by who am I?"
	projectile_type = /obj/projectile/magic/change
	icon = 'icons/obj/machines/magic_emitter.dmi'
	icon_state = "wabbajack_statue"
	icon_state_on = "wabbajack_statue_on"
	base_icon_state = "wabbajack_statue"
	active = FALSE
	allow_switch_interact = FALSE
	var/list/active_tables = list()
	var/tables_required = 2

/obj/machinery/power/emitter/energycannon/magical/Initialize(mapload)
	. = ..()
	if(prob(50))
		desc = "Oh no, not again."
	update_appearance()

/obj/machinery/power/emitter/energycannon/magical/update_icon_state()
	. = ..()
	icon_state = active ? icon_state_on : initial(icon_state)

/obj/machinery/power/emitter/energycannon/magical/process_early(seconds_per_tick)
	. = ..()
	if(active_tables.len >= tables_required)
		if(!active)
			visible_message("<span class='revenboldnotice'>\
				[src] opens its eyes.</span>")
		active = TRUE
	else
		if(active)
			visible_message("<span class='revenboldnotice'>\
				[src] closes its eyes.</span>")
		active = FALSE
	update_appearance()

/obj/machinery/power/emitter/energycannon/magical/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	return

/obj/machinery/power/emitter/energycannon/magical/ex_act(severity)
	return FALSE

/obj/machinery/power/emitter/energycannon/magical/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/structure/table/abductor/wabbajack
	name = "wabbajack altar"
	desc = "Whether you're sleeping or waking, it's going to be quite chaotic."
	max_integrity = 1000
	verb_say = "chants"
	var/obj/machinery/power/emitter/energycannon/magical/our_statue
	var/list/mob/living/sleepers = list()
	var/never_spoken = TRUE

/obj/structure/table/abductor/wabbajack/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/table/abductor/wabbajack/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/table/abductor/wabbajack/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/table/abductor/wabbajack/wrench_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/table/abductor/wabbajack/process()
	if(isnull(our_statue))
		our_statue = locate() in orange(4, src)

	if(isnull(our_statue))
		name = "inert [initial(name)]"
		return

	name = initial(name)

	var/turf/T = get_turf(src)
	var/list/found = list()
	for(var/mob/living/carbon/C in T)
		if(C.stat != DEAD)
			found += C

	// New sleepers
	for(var/i in found - sleepers)
		var/mob/living/L = i
		L.add_atom_colour(COLOR_PURPLE, TEMPORARY_COLOUR_PRIORITY)
		L.visible_message(span_revennotice("A strange purple glow wraps itself around [L] as [L.p_they()] suddenly fall[L.p_s()] unconscious."),
			span_revendanger("[desc]"))
		// Don't let them sit suround unconscious forever
		addtimer(CALLBACK(src, PROC_REF(sleeper_dreams), L), 10 SECONDS)

	// Existing sleepers
	for(var/i in found)
		var/mob/living/L = i
		L.SetSleeping(200)

	// Missing sleepers
	for(var/i in sleepers - found)
		var/mob/living/L = i
		L.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_PURPLE)
		L.visible_message("<span class='revennotice'>The glow from [L] fades \
			away.</span>")
		L.grab_ghost()

	sleepers = found

	if(sleepers.len)
		our_statue.active_tables |= src
		if(never_spoken || prob(5))
			say(desc)
			never_spoken = FALSE
	else
		our_statue.active_tables -= src

/obj/structure/table/abductor/wabbajack/proc/sleeper_dreams(mob/living/sleeper)
	if(sleeper in sleepers)
		to_chat(sleeper, span_revennotice("While you slumber, you have the strangest dream, like you can see yourself from the outside."))
		sleeper.ghostize(TRUE)

/obj/structure/table/abductor/wabbajack/left
	desc = "You sleep so it may wake."

/obj/structure/table/abductor/wabbajack/right
	desc = "It wakes so you may sleep."

/**
 * Bar staff, mobs with the TRAIT_GODMODE trait (as long as they stay in the shuttle)
 * that just want to make sure people have drinks and a good shuttle time.
 */
/mob/living/basic/drone/snowflake/bardrone
	name = "Bardrone"
	desc = "A barkeeping drone, a robot built to tend bars."
	hacked = TRUE
	shy = FALSE
	laws = "1. Serve drinks.\n\
		2. Talk to patrons.\n\
		3. Don't get messed up in their affairs."
	unique_name = FALSE // disables the (123) number suffix
	initial_language_holder = /datum/language_holder/universal
	default_storage = null

/mob/living/basic/drone/snowflake/bardrone/Initialize(mapload)
	. = ..()
	AddComponentFrom(ROUNDSTART_TRAIT, /datum/component/area_based_godmode, area_type = /area/shuttle/escape, allow_area_subtypes = TRUE)

// Bar table, a wooden table that kicks you in a direction if you're not
// barstaff (defined as someone who was a roundstart bartender or someone
// with CENTCOM_BARSTAFF)

/obj/structure/table/wood/shuttle_bar
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_integrity = 1000
	var/boot_dir = 1

/obj/structure/table/wood/shuttle_bar/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_climbed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/wood/shuttle_bar/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/table/wood/shuttle_bar/wrench_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/table/wood/shuttle_bar/proc/on_climbed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	var/mob/living/M = AM
	if(istype(M) && !M.incorporeal_move && !is_barstaff(M))
		// No climbing on the bar please
		var/throwtarget = get_edge_target_turf(src, boot_dir)
		M.Paralyze(40)
		M.throw_at(throwtarget, 5, 1)
		to_chat(M, span_notice("No climbing on the bar please."))

/obj/structure/table/wood/shuttle_bar/proc/is_barstaff(mob/living/user)
	. = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(is_bartender_job(human_user.mind?.assigned_role))
			return TRUE

	if(istype(user, /mob/living/basic/drone/snowflake/bardrone))
		return TRUE

	var/obj/item/card/id/ID = user.get_idcard(FALSE)
	if(ID && (ACCESS_CENT_BAR in ID.access))
		return TRUE

//Luxury Shuttle Blockers

/obj/machinery/scanner_gate/luxury_shuttle
	name = "luxury shuttle ticket field"
	density = FALSE //allows shuttle airlocks to close, nothing but an approved passenger gets past CanPass
	locked = TRUE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	speech_span = SPAN_ROBOT
	var/threshold = 500
	var/static/list/approved_passengers = list()
	var/static/list/check_times = list()
	var/list/payees = list()

/obj/machinery/scanner_gate/luxury_shuttle/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(mover in approved_passengers)
		set_scanline("scanning", 10)
		if(isvehicle(mover))
			var/obj/vehicle/vehicle = mover
			for(var/mob/living/rat in vehicle.occupants)
				if(!(rat in approved_passengers))
					say("Stowaway detected. Please exit the vehicle first.")
					return FALSE
		return TRUE
	if(isitem(mover))
		return TRUE
	if(isstructure(mover))
		var/obj/structure/struct = mover
		for(var/mob/living/rat in struct.contents)
			say("Stowaway detected. Please exit the structure first.")
			return FALSE
		return TRUE

	return FALSE

/obj/machinery/scanner_gate/luxury_shuttle/auto_scan(atom/movable/AM)
	return

/obj/machinery/scanner_gate/luxury_shuttle/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	return

/obj/machinery/scanner_gate/luxury_shuttle/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

#define LUXURY_MESSAGE_COOLDOWN 100
/obj/machinery/scanner_gate/luxury_shuttle/Bumped(atom/movable/AM)
	///If the atom entering the gate is a vehicle, we store it here to add to the approved list to enter/leave the scanner gate.
	var/obj/vehicle/vehicle
	///We store the driver of vehicles separately so that we can add them to the approved list once payment is fully processed.
	var/mob/living/driver_holdout
	if(!isliving(AM) && !isvehicle(AM))
		alarm_beep()
		return ..()

	var/datum/bank_account/account
	if(istype(AM.pulling, /obj/item/card/id))
		var/obj/item/card/id/I = AM.pulling
		if(I.registered_account)
			account = I.registered_account
		else if(!check_times[AM] || check_times[AM] < world.time) //Let's not spam the message
			to_chat(AM, span_notice("This ID card doesn't have an owner associated with it!"))
			check_times[AM] = world.time + LUXURY_MESSAGE_COOLDOWN
	else if(isliving(AM))
		var/mob/living/L = AM
		account = L.get_bank_account()

	else if(isvehicle(AM))
		vehicle = AM
		for(var/passenger in vehicle.occupants)
			if(!isliving(passenger))
				continue
			var/mob/living/rider = passenger
			if(vehicle.is_driver(rider))
				driver_holdout = rider
				var/obj/item/card/id/id = rider.get_idcard(TRUE)
				account = id?.registered_account
				break

	if(account)
		if(account.account_balance < threshold - payees[AM])
			account.adjust_money(-account.account_balance, "Scanner Gate: Entry Fee")
			payees[AM] += account.account_balance
		else
			var/money_owed = threshold - payees[AM]
			account.adjust_money(-money_owed, "Scanner Gate: Partial Entry Fee")
			payees[AM] += money_owed

	//Here is all the possible paygate payment methods.
	var/list/counted_money = list()
	for(var/obj/item/coin/C in AM.get_all_contents()) //Coins.
		if(payees[AM] >= threshold)
			break
		payees[AM] += C.value
		counted_money += C
	for(var/obj/item/stack/spacecash/S in AM.get_all_contents()) //Paper Cash
		if(payees[AM] >= threshold)
			break
		payees[AM] += S.value * S.amount
		counted_money += S
	for(var/obj/item/holochip/H in AM.get_all_contents()) //Holocredits
		if(payees[AM] >= threshold)
			break
		payees[AM] += H.credits
		counted_money += H

	if(payees[AM] < threshold && istype(AM.pulling, /obj/item/coin)) //Coins(Pulled).
		var/obj/item/coin/C = AM.pulling
		payees[AM] += C.value
		counted_money += C

	else if(payees[AM] < threshold && istype(AM.pulling, /obj/item/stack/spacecash)) //Cash(Pulled).
		var/obj/item/stack/spacecash/S = AM.pulling
		payees[AM] += S.value * S.amount
		counted_money += S

	else if(payees[AM] < threshold && istype(AM.pulling, /obj/item/holochip)) //Holocredits(pulled).
		var/obj/item/holochip/H = AM.pulling
		payees[AM] += H.credits
		counted_money += H

	if(payees[AM] < threshold) //Suggestions for those with no arms/simple animals.
		var/armless
		if(!ishuman(AM) && !isslime(AM))
			armless = TRUE
		else
			var/mob/living/carbon/human/H = AM
			if(!H.get_bodypart(BODY_ZONE_L_ARM) && !H.get_bodypart(BODY_ZONE_R_ARM))
				armless = TRUE

		if(armless)
			if(!AM.pulling || !iscash(AM.pulling) && !istype(AM.pulling, /obj/item/card/id))
				if(!check_times[AM] || check_times[AM] < world.time) //Let's not spam the message
					to_chat(AM, span_notice("Try pulling a valid ID, space cash, holochip or coin into \the [src]!"))
					check_times[AM] = world.time + LUXURY_MESSAGE_COOLDOWN

	if(payees[AM] >= threshold)
		for(var/obj/I in counted_money)
			qdel(I)
		payees[AM] -= threshold

		var/change = FALSE
		if(payees[AM] > 0)
			change = TRUE
			var/obj/item/holochip/holocred = new /obj/item/holochip(AM.loc, payees[AM]) //Change is made in holocredits exclusively.
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				if(!H.put_in_hands(holocred))
					AM.pulling = holocred
			else
				AM.pulling = holocred
			payees[AM] -= payees[AM]

		say("Welcome to first class, [driver_holdout ? "[driver_holdout]" : "[AM]" ]![change ? " Here is your change." : ""]")
		approved_passengers |= AM
		if(vehicle)
			approved_passengers |= vehicle
		if(driver_holdout)
			approved_passengers |= driver_holdout

		check_times -= AM
		return
	else if (payees[AM] > 0)
		for(var/obj/I in counted_money)
			qdel(I)
		if(!check_times[AM] || check_times[AM] < world.time) //Let's not spam the message
			to_chat(AM, span_notice("[payees[AM]] cr received. You need [threshold-payees[AM]] cr more."))
			check_times[AM] = world.time + LUXURY_MESSAGE_COOLDOWN
		alarm_beep()
		return ..()
	else
		alarm_beep()
		return ..()

/mob/living/basic/bear/fightpit
	name = "fight pit bear"
	desc = "This bear's trained through ancient Russian secrets to fear the walls of its glass prison."
	environment_smash = ENVIRONMENT_SMASH_NONE

/obj/effect/decal/hammerandsickle
	name = "hammer and sickle"
	desc = "Communism powerful force."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "communist"
	pixel_x = -32
	pixel_y = -32

/obj/effect/decal/hammerandsickle/shuttleRotate(rotation)
	setDir(angle2dir(rotation+dir2angle(dir))) // No parentcall, rest of the rotate code breaks the pixel offset.

#undef LUXURY_MESSAGE_COOLDOWN
