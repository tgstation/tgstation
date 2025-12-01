/// Machine that you put someone in to scan them for the experimental cloner
/obj/machinery/experimental_cloner_scanner
	name = "experimental cloning scanner"
	desc = "An old prototype DNA scanner, compatible with an experimental cloning setup."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "scanner"
	base_icon_state = "scanner"
	density = TRUE
	obj_flags = BLOCKS_CONSTRUCTION
	interaction_flags_mouse_drop = NEED_DEXTERITY
	occupant_typecache = list(/mob/living, /obj/item/bodypart/head, /obj/item/organ/brain)
	circuit = /obj/item/circuitboard/machine/experimental_cloner_scanner
	use_power = NO_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY
	/// No exit while it's running
	var/locked = FALSE
	/// Are we trying to scan someone?
	var/scanning = FALSE
	/// How long does scanning take?
	var/scan_time = 10 SECONDS
	/// How long does breaking out take?
	var/breakout_time = 3 SECONDS
	/// Sound to play while scanning
	var/datum/looping_sound/microwave/soundloop
	/// Timer storing our scanning progress
	var/scan_timer
	/// Time to wait between telling people they can't get out
	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/experimental_cloner_scanner/Initialize(mapload)
	. = ..()
	soundloop = new (src)

/// Scan the occupant, eventually producing a [/datum/experimental_cloning_record]. Returns FALSE if unsuccessful.
/obj/machinery/experimental_cloner_scanner/proc/start_scan()
	if (machine_stat & BROKEN || machine_stat & NOPOWER || isnull(occupant))
		playsound(src, 'sound/machines/scanner/scanbuzz.ogg', vol = 100)
		return FALSE

	SSradiation.irradiate(occupant)
	scanning = TRUE
	locked = TRUE
	update_use_power(ACTIVE_POWER_USE)
	playsound(src, 'sound/machines/closet/closet_unlock.ogg', vol = 100)
	soundloop.start()
	scan_timer = addtimer(CALLBACK(src, PROC_REF(complete_scan)), scan_time, TIMER_STOPPABLE | TIMER_DELETE_ME)

/// Successfully produce a scan record
/obj/machinery/experimental_cloner_scanner/proc/complete_scan()
	if (isnull(occupant))
		fail_scan()
		return
	var/datum/experimental_cloning_record/new_record = new()
	new_record.create_profile(occupant)
	SEND_SIGNAL(src, COMSIG_CLONER_SCAN_SUCCESSFUL, new_record)

	on_scan_stopped()

/// There's nobody in the tank, so nothing to scan
/obj/machinery/experimental_cloner_scanner/proc/fail_scan()
	playsound(src, 'sound/machines/scanner/scanbuzz.ogg', vol = 100)
	on_scan_stopped()

/// Generic stuff to do when we're done scanning
/obj/machinery/experimental_cloner_scanner/proc/on_scan_stopped()
	update_use_power(NO_POWER_USE)
	scanning = FALSE
	if (locked)
		playsound(src, 'sound/machines/closet/closet_unlock.ogg', vol = 100)
	locked = FALSE
	soundloop.stop()
	deltimer(scan_timer)

/obj/machinery/experimental_cloner_scanner/power_change()
	. = ..()
	if (machine_stat & NOPOWER && scanning)
		fail_scan()

/obj/machinery/experimental_cloner_scanner/open_machine(drop, density_to_set)
	. = ..()
	if (scanning)
		fail_scan()

/obj/machinery/experimental_cloner_scanner/update_icon_state()
	//no power or maintenance
	if (machine_stat & (NOPOWER|BROKEN))
		icon_state = "[base_icon_state][state_open ? "_open" : null]_unpowered"
		return ..()

	//running and someone in there
	if (occupant)
		icon_state = "[base_icon_state]_occupied"
		return ..()

	//running
	icon_state = "[base_icon_state][state_open ? "_open" : null]"
	return ..()

/obj/machinery/experimental_cloner_scanner/container_resist_act(mob/living/user)
	if (!locked)
		open_machine()
		return

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the door of [src]!"), \
		span_notice("You lean on the back of [src] and start pushing the door open..."), \
		span_hear("You hear a metallic creaking from [src]."))

	balloon_alert(user, "breaking out...")
	if (!do_after(user,(breakout_time), target = src))
		return
	if (!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
		return

	locked = FALSE
	user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
		span_notice("You successfully break out of [src]!"))
	open_machine()

/obj/machinery/experimental_cloner_scanner/relaymove(mob/living/user, direction)
	if (user.stat || locked)
		if (COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, breakout_time)
			balloon_alert(user, "door locked!")
			container_resist_act(user)
		return
	open_machine()

/obj/machinery/experimental_cloner_scanner/interact(mob/user)
	toggle_open(user)

/obj/machinery/experimental_cloner_scanner/mouse_drop_receive(atom/target, mob/user, params)
	if (!iscarbon(target))
		return
	close_machine(target)

/// Try opening the machine if it's not locked
/obj/machinery/experimental_cloner_scanner/proc/toggle_open(mob/user)
	if (state_open)
		close_machine()
		return

	if (locked)
		balloon_alert(user, "it's locked!")
		return

	open_machine()

/obj/machinery/experimental_cloner_scanner/welder_act(mob/living/user, obj/item/tool)
	if (user.combat_mode)
		return NONE

	if (!tool.tool_start_check(user, amount = 5))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You start slicing \the [src] apart."))
	if(!tool.use_tool(src, user, 6 SECONDS, amount = 5, volume = 50))
		return ITEM_INTERACT_BLOCKING
	deconstruct(disassembled = TRUE)
	to_chat(user, span_notice("You slice \the [src] apart."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/experimental_cloner_scanner/multitool_act(mob/living/user, obj/item/multitool/tool)
	tool.set_buffer(src)
	balloon_alert(user, "frequency stored")
	return ITEM_INTERACT_SUCCESS
