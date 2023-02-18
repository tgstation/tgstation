#define DEFAULT_DOOMSDAY_TIMER 4500
#define DOOMSDAY_ANNOUNCE_INTERVAL 600

GLOBAL_LIST_INIT(blacklisted_malf_machines, typecacheof(list(
		/obj/machinery/field/containment,
		/obj/machinery/power/supermatter_crystal,
		/obj/machinery/gravity_generator,
		/obj/machinery/doomsday_device,
		/obj/machinery/nuclearbomb,
		/obj/machinery/nuclearbomb/selfdestruct,
		/obj/machinery/nuclearbomb/syndicate,
		/obj/machinery/syndicatebomb,
		/obj/machinery/syndicatebomb/badmin,
		/obj/machinery/syndicatebomb/badmin/clown,
		/obj/machinery/syndicatebomb/empty,
		/obj/machinery/syndicatebomb/self_destruct,
		/obj/machinery/syndicatebomb/training,
		/obj/machinery/atmospherics/pipe/layer_manifold,
		/obj/machinery/atmospherics/pipe/multiz,
		/obj/machinery/atmospherics/pipe/smart,
		/obj/machinery/atmospherics/pipe/smart/manifold, //mapped one
		/obj/machinery/atmospherics/pipe/smart/manifold4w, //mapped one
		/obj/machinery/atmospherics/pipe/color_adapter,
		/obj/machinery/atmospherics/pipe/bridge_pipe,
		/obj/machinery/atmospherics/pipe/heat_exchanging/simple,
		/obj/machinery/atmospherics/pipe/heat_exchanging/junction,
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold,
		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w,
		/obj/machinery/atmospherics/components/tank,
		/obj/machinery/atmospherics/components/unary/portables_connector,
		/obj/machinery/atmospherics/components/unary/passive_vent,
		/obj/machinery/atmospherics/components/unary/heat_exchanger,
		/obj/machinery/atmospherics/components/unary/hypertorus/core,
		/obj/machinery/atmospherics/components/unary/hypertorus/waste_output,
		/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input,
		/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input,
		/obj/machinery/hypertorus/interface,
		/obj/machinery/hypertorus/corner,
		/obj/machinery/atmospherics/components/binary/valve,
		/obj/machinery/portable_atmospherics/canister,
	)))

GLOBAL_LIST_INIT(malf_modules, subtypesof(/datum/ai_module))

/// The malf AI action subtype. All malf actions are subtypes of this.
/datum/action/innate/ai
	name = "AI Action"
	desc = "You aren't entirely sure what this does, but it's very beepy and boopy."
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	/// The owner AI, so we don't have to typecast every time
	var/mob/living/silicon/ai/owner_AI
	/// If we have multiple uses of the same power
	var/uses
	/// If we automatically use up uses on each activation
	var/auto_use_uses = TRUE
	/// If applicable, the time in deciseconds we have to wait before using any more modules
	var/cooldown_period

/datum/action/innate/ai/Grant(mob/living/player)
	. = ..()
	if(!isAI(owner))
		WARNING("AI action [name] attempted to grant itself to non-AI mob [key_name(player)]!")
		qdel(src)
	else
		owner_AI = owner

/datum/action/innate/ai/IsAvailable(feedback = FALSE)
	. = ..()
	if(owner_AI && owner_AI.malf_cooldown > world.time)
		return

/datum/action/innate/ai/Trigger(trigger_flags)
	. = ..()
	if(auto_use_uses)
		adjust_uses(-1)
	if(cooldown_period)
		owner_AI.malf_cooldown = world.time + cooldown_period

/datum/action/innate/ai/proc/adjust_uses(amt, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining."))
	if(uses <= 0)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		qdel(src)

/// Framework for ranged abilities that can have different effects by left-clicking stuff.
/datum/action/innate/ai/ranged
	name = "Ranged AI Action"
	auto_use_uses = FALSE //This is so we can do the thing and disable/enable freely without having to constantly add uses
	click_action = TRUE

/datum/action/innate/ai/ranged/adjust_uses(amt, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use\s remaining."))
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		Remove(owner)
		QDEL_IN(src, 10 SECONDS) //let any active timers on us finish up

/// The base module type, which holds info about each ability.
/datum/ai_module
	var/name = "generic module"
	var/category = "generic category"
	var/description = "generic description"
	var/cost = 5
	/// If this module can only be purchased once. This always applies to upgrades, even if the variable is set to false.
	var/one_purchase = FALSE
	/// If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/power_type = /datum/action/innate/ai
	/// If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/upgrade = FALSE
	/// Text shown when an ability is unlocked
	var/unlock_text = span_notice("Hello World!")
	/// Sound played when an ability is unlocked
	var/unlock_sound

/// Applies upgrades
/datum/ai_module/proc/upgrade(mob/living/silicon/ai/AI)
	return

/// Modules causing destruction
/datum/ai_module/destructive
	category = "Destructive Modules"

/// Modules with stealthy and utility uses
/datum/ai_module/utility
	category = "Utility Modules"

/// Modules that are improving AI abilities and assets
/datum/ai_module/upgrade
	category = "Upgrade Modules"

/// Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/ai_module/destructive/nuke_station
	name = "Doomsday Device"
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay. \
		Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/nuke_station
	unlock_text = span_notice("You slowly, carefully, establish a connection with the on-station self-destruct. You can now activate it at any time.")

/datum/action/innate/ai/nuke_station
	name = "Doomsday Device"
	desc = "Activates the doomsday device. This is not reversible."
	button_icon_state = "doomsday_device"
	auto_use_uses = FALSE

/datum/action/innate/ai/nuke_station/Activate()
	var/turf/T = get_turf(owner)
	if(!istype(T) || !is_station_level(T.z))
		to_chat(owner, span_warning("You cannot activate the doomsday device while off-station!"))
		return
	if(tgui_alert(owner, "Send arming signal? (true = arm, false = cancel)", "purge_all_life()", list("confirm = TRUE;", "confirm = FALSE;")) != "confirm = TRUE;")
		return
	if (active || owner_AI.stat == DEAD)
		return //prevent the AI from activating an already active doomsday or while they are dead
	if (!isturf(owner_AI.loc))
		return //prevent AI from activating doomsday while shunted or carded, fucking abusers
	active = TRUE
	set_up_us_the_bomb(owner)

/datum/action/innate/ai/nuke_station/proc/set_up_us_the_bomb(mob/living/owner)
	set waitfor = FALSE
	message_admins("[key_name_admin(owner)][ADMIN_FLW(owner)] has activated AI Doomsday.")
	var/pass = prob(10) ? "******" : "hunter2"
	to_chat(owner, "<span class='small boldannounce'>run -o -a 'selfdestruct'</span>")
	sleep(0.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Running executable 'selfdestruct'...</span>")
	sleep(rand(10, 30))
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	owner.playsound_local(owner, 'sound/misc/bloblarm.ogg', 50, 0, use_reverb = FALSE)
	to_chat(owner, span_userdanger("!!! UNAUTHORIZED SELF-DESTRUCT ACCESS !!!"))
	to_chat(owner, span_boldannounce("This is a class-3 security violation. This incident will be reported to Central Command."))
	for(var/i in 1 to 3)
		sleep(2 SECONDS)
		if(QDELETED(owner) || !isturf(owner_AI.loc))
			active = FALSE
			return
		to_chat(owner, span_boldannounce("Sending security report to Central Command.....[rand(0, 9) + (rand(20, 30) * i)]%"))
	sleep(0.3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>auth 'akjv9c88asdf12nb' [pass]</span>")
	owner.playsound_local(owner, 'sound/items/timer.ogg', 50, 0, use_reverb = FALSE)
	sleep(3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Welcome, akjv9c88asdf12nb."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(0.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Arm self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0, use_reverb = FALSE)
	sleep(2 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(1.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Confirm arming of self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(1 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(rand(15, 25))
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Please repeat password to confirm."))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(1.4 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>[pass]</span>")
	sleep(4 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Transmitting arming signal..."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	if (owner_AI.stat != DEAD)
		priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", ANNOUNCER_AIMALF)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		var/obj/machinery/doomsday_device/DOOM = new(owner_AI)
		owner_AI.nuking = TRUE
		owner_AI.doomsday_device = DOOM
		owner_AI.doomsday_device.start()
		for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
			P.switch_mode_to(TRACK_MALF_AI) //Pinpointers start tracking the AI wherever it goes
		qdel(src)

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	density = TRUE
	verb_exclaim = "blares"
	use_power = NO_POWER_USE
	var/timing = FALSE
	var/obj/effect/countdown/doomsday/countdown
	var/detonation_timer
	var/next_announce
	var/mob/living/silicon/ai/owner

/obj/machinery/doomsday_device/Initialize(mapload)
	. = ..()
	if(!isAI(loc))
		stack_trace("Doomsday created outside an AI somehow, shit's fucking broke. Anyway, we're just gonna qdel now. Go make a github issue report.")
		return INITIALIZE_HINT_QDEL
	owner = loc
	countdown = new(src)

/obj/machinery/doomsday_device/Destroy()
	timing = FALSE
	QDEL_NULL(countdown)
	STOP_PROCESSING(SSfastprocess, src)
	SSshuttle.clearHostileEnvironment(src)
	SSmapping.remove_nuke_threat(src)
	SSsecurity_level.set_level(SEC_LEVEL_RED)
	for(var/mob/living/silicon/robot/borg in owner?.connected_robots)
		borg.lamp_doom = FALSE
		borg.toggle_headlamp(FALSE, TRUE) //forces borg lamp to update
	owner?.doomsday_device = null
	owner?.nuking = null
	owner = null
	for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
		P.switch_mode_to(TRACK_NUKE_DISK) //Party's over, back to work, everyone
		P.alert = FALSE
	return ..()

/obj/machinery/doomsday_device/proc/start()
	detonation_timer = world.time + DEFAULT_DOOMSDAY_TIMER
	next_announce = world.time + DOOMSDAY_ANNOUNCE_INTERVAL
	timing = TRUE
	countdown.start()
	START_PROCESSING(SSfastprocess, src)
	SSshuttle.registerHostileEnvironment(src)
	SSmapping.add_nuke_threat(src) //This causes all blue "circuit" tiles on the map to change to animated red icon state.
	for(var/mob/living/silicon/robot/borg in owner.connected_robots)
		borg.lamp_doom = TRUE
		borg.toggle_headlamp(FALSE, TRUE) //forces borg lamp to update


/obj/machinery/doomsday_device/proc/seconds_remaining()
	. = max(0, (round((detonation_timer - world.time) / 10)))

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || !is_station_level(T.z))
		minor_announce("DOOMSDAY DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		owner.ShutOffDoomsdayDevice()
		return
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(!sec_left)
		timing = FALSE
		sound_to_playing_players('sound/machines/alarm.ogg')
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(play_cinematic), /datum/cinematic/malf, world, CALLBACK(src, PROC_REF(trigger_doomsday))), 10 SECONDS)

	else if(world.time >= next_announce)
		minor_announce("[sec_left] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		next_announce += DOOMSDAY_ANNOUNCE_INTERVAL

/obj/machinery/doomsday_device/proc/trigger_doomsday()
	callback_on_everyone_on_z(SSmapping.levels_by_trait(ZTRAIT_STATION), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(bring_doomsday)), src)
	to_chat(world, span_bold("The AI cleansed the station of life with [src]!"))
	SSticker.force_ending = TRUE

/proc/bring_doomsday(mob/living/victim, atom/source)
	if(issilicon(victim))
		return FALSE

	to_chat(victim, span_userdanger("The blast wave from [source] tears you atom from atom!"))
	victim.investigate_log("has been dusted by a doomsday device.", INVESTIGATE_DEATHS)
	victim.dust()
	return TRUE

/// Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/ai_module/destructive/lockdown
	name = "Hostile Station Lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. \
		Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds, briefly \
		opening all doors on the station."
	cost = 30
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/lockdown
	unlock_text = span_notice("You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.")
	unlock_sound = 'sound/machines/boltsdown.ogg'

/datum/action/innate/ai/lockdown
	name = "Lockdown"
	desc = "Closes, bolts, and depowers every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	button_icon_state = "lockdown"
	uses = 1
	/// Badmin / exploit abuse prevention.
	/// Check tick may sleep in activate() and we don't want this to be spammable.
	var/hack_in_progress  = FALSE

/datum/action/innate/ai/lockdown/IsAvailable(feedback)
	return ..() && !hack_in_progress

/datum/action/innate/ai/lockdown/Activate()
	hack_in_progress = TRUE
	for(var/obj/machinery/door/locked_down as anything in GLOB.airlocks)
		if(QDELETED(locked_down) || !is_station_level(locked_down.z))
			continue
		INVOKE_ASYNC(locked_down, TYPE_PROC_REF(/obj/machinery/door, hostile_lockdown), owner)
		CHECK_TICK

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_malf_ai_undo_lockdown)), 90 SECONDS)

	var/obj/machinery/computer/communications/random_comms_console = locate() in GLOB.shuttle_caller_list
	random_comms_console?.post_status("alert", "lockdown")

	minor_announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert:", TRUE)
	to_chat(owner, span_danger("Lockdown initiated. Network reset in 90 seconds."))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce),
		"Automatic system reboot complete. Have a secure day.",
		"Network reset:"), 90 SECONDS)
	hack_in_progress = FALSE

/// For Lockdown malf AI ability. Opens all doors on the station.
/proc/_malf_ai_undo_lockdown()
	for(var/obj/machinery/door/locked_down as anything in GLOB.airlocks)
		if(QDELETED(locked_down) || !is_station_level(locked_down.z))
			continue
		INVOKE_ASYNC(locked_down, TYPE_PROC_REF(/obj/machinery/door, disable_lockdown))
		CHECK_TICK

/// Override Machine: Allows the AI to override a machine, animating it into an angry, living version of itself.
/datum/ai_module/destructive/override_machine
	name = "Machine Override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. Four uses per purchase."
	cost = 30
	power_type = /datum/action/innate/ai/ranged/override_machine
	unlock_text = span_notice("You procure a virus from the Space Dark Web and distribute it to the station's machines.")
	unlock_sound = 'sound/machines/airlock_alien_prying.ogg'

/datum/action/innate/ai/ranged/override_machine
	name = "Override Machine"
	desc = "Animates a targeted machine, causing it to attack anyone nearby."
	button_icon_state = "override_machine"
	uses = 4
	ranged_mousepointer = 'icons/effects/mouse_pointers/override_machine_target.dmi'
	enable_text = span_notice("You tap into the station's powernet. Click on a machine to animate it, or use the ability again to cancel.")
	disable_text = span_notice("You release your hold on the powernet.")

/datum/action/innate/ai/ranged/override_machine/New()
	. = ..()
	desc = "[desc] It has [uses] use\s remaining."

/datum/action/innate/ai/ranged/override_machine/do_ability(mob/living/caller, atom/clicked_on)
	if(caller.incapacitated())
		unset_ranged_ability(caller)
		return FALSE
	if(!ismachinery(clicked_on))
		to_chat(caller, span_warning("You can only animate machines!"))
		return FALSE
	var/obj/machinery/clicked_machine = clicked_on
	if(!clicked_machine.can_be_overridden() || is_type_in_typecache(clicked_machine, GLOB.blacklisted_malf_machines))
		to_chat(caller, span_warning("That machine can't be overridden!"))
		return FALSE

	caller.playsound_local(caller, 'sound/misc/interference.ogg', 50, FALSE, use_reverb = FALSE)
	adjust_uses(-1)

	if(uses)
		desc = "[initial(desc)] It has [uses] use\s remaining."
		build_all_button_icons()

	clicked_machine.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [clicked_machine]!"))
	addtimer(CALLBACK(src, PROC_REF(animate_machine), caller, clicked_machine), 5 SECONDS) //kabeep!
	unset_ranged_ability(caller, span_danger("Sending override signal..."))
	return TRUE

/datum/action/innate/ai/ranged/override_machine/proc/animate_machine(mob/living/caller, obj/machinery/to_animate)
	if(QDELETED(to_animate))
		return

	new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(to_animate), to_animate, caller, TRUE)

/// Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/ai_module/destructive/destroy_rcd
	name = "Destroy RCDs"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/destroy_rcds
	unlock_text = span_notice("After some improvisation, you rig your onboard radio to be able to send a signal to detonate all RCDs.")
	unlock_sound = 'sound/items/timer.ogg'

/datum/action/innate/ai/destroy_rcds
	name = "Destroy RCDs"
	desc = "Detonate all non-cyborg RCDs on the station."
	button_icon_state = "detonate_rcds"
	uses = 1
	cooldown_period = 10 SECONDS

/datum/action/innate/ai/destroy_rcds/Activate()
	for(var/I in GLOB.rcd_list)
		if(!istype(I, /obj/item/construction/rcd/borg)) //Ensures that cyborg RCDs are spared.
			var/obj/item/construction/rcd/RCD = I
			RCD.detonate_pulse()
	to_chat(owner, span_danger("RCD detonation pulse emitted."))
	owner.playsound_local(owner, 'sound/machines/twobeep.ogg', 50, 0)

/// Overload Machine: Allows the AI to overload a machine, detonating it after a delay. Two uses per purchase.
/datum/ai_module/destructive/overload_machine
	name = "Machine Overload"
	description = "Overheats an electrical machine, causing a small explosion and destroying it. Two uses per purchase."
	cost = 20
	power_type = /datum/action/innate/ai/ranged/overload_machine
	unlock_text = span_notice("You enable the ability for the station's APCs to direct intense energy into machinery.")
	unlock_sound = 'sound/effects/comfyfire.ogg' //definitely not comfy, but it's the closest sound to "roaring fire" we have

/datum/action/innate/ai/ranged/overload_machine
	name = "Overload Machine"
	desc = "Overheats a machine, causing a small explosion after a short time."
	button_icon_state = "overload_machine"
	uses = 2
	ranged_mousepointer = 'icons/effects/mouse_pointers/overload_machine_target.dmi'
	enable_text = span_notice("You tap into the station's powernet. Click on a machine to detonate it, or use the ability again to cancel.")
	disable_text = span_notice("You release your hold on the powernet.")

/datum/action/innate/ai/ranged/overload_machine/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."

/datum/action/innate/ai/ranged/overload_machine/proc/detonate_machine(mob/living/caller, obj/machinery/to_explode)
	if(QDELETED(to_explode))
		return

	var/turf/machine_turf = get_turf(to_explode)
	message_admins("[ADMIN_LOOKUPFLW(caller)] overloaded [to_explode.name] ([to_explode.type]) at [ADMIN_VERBOSEJMP(machine_turf)].")
	caller.log_message("overloaded [to_explode.name] ([to_explode.type])", LOG_ATTACK)
	explosion(to_explode, heavy_impact_range = 2, light_impact_range = 3)
	if(!QDELETED(to_explode)) //to check if the explosion killed it before we try to delete it
		qdel(to_explode)

/datum/action/innate/ai/ranged/overload_machine/do_ability(mob/living/caller, atom/clicked_on)
	if(caller.incapacitated())
		unset_ranged_ability(caller)
		return FALSE
	if(!ismachinery(clicked_on))
		to_chat(caller, span_warning("You can only overload machines!"))
		return FALSE
	var/obj/machinery/clicked_machine = clicked_on
	if(is_type_in_typecache(clicked_machine, GLOB.blacklisted_malf_machines))
		to_chat(caller, span_warning("You cannot overload that device!"))
		return FALSE

	caller.playsound_local(caller, SFX_SPARKS, 50, 0)
	adjust_uses(-1)
	if(uses)
		desc = "[initial(desc)] It has [uses] use\s remaining."
		build_all_button_icons()

	clicked_machine.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [clicked_machine]!"))
	addtimer(CALLBACK(src, PROC_REF(detonate_machine), caller, clicked_machine), 5 SECONDS) //kaboom!
	unset_ranged_ability(caller, span_danger("Overcharging machine..."))
	return TRUE

/// Blackout: Overloads a random number of lights across the station. Three uses.
/datum/ai_module/destructive/blackout
	name = "Blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. Three uses per purchase."
	cost = 15
	power_type = /datum/action/innate/ai/blackout
	unlock_text = span_notice("You hook into the powernet and route bonus power towards the station's lighting.")
	unlock_sound = SFX_SPARKS

/datum/action/innate/ai/blackout
	name = "Blackout"
	desc = "Overloads random lights across the station."
	button_icon_state = "blackout"
	uses = 3
	auto_use_uses = FALSE

/datum/action/innate/ai/blackout/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."

/datum/action/innate/ai/blackout/Activate()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(prob(30 * apc.overload))
			apc.overload_lighting()
		else
			apc.overload++
	to_chat(owner, span_notice("Overcurrent applied to the powernet."))
	owner.playsound_local(owner, SFX_SPARKS, 50, 0)
	adjust_uses(-1)
	if(QDELETED(src) || uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		return
	desc = "[initial(desc)] It has [uses] use\s remaining."
	build_all_button_icons()

/// HIGH IMPACT HONKING
/datum/ai_module/destructive/megahonk
	name = "Percussive Intercomm Interference"
	description = "Emit a debilitatingly percussive auditory blast through the station intercoms. Does not overpower hearing protection. Two uses per purchase."
	cost = 20
	power_type = /datum/action/innate/ai/honk
	unlock_text = span_notice("You upload a sinister sound file into every intercom...")
	unlock_sound = 'sound/items/airhorn.ogg'

/datum/action/innate/ai/honk
	name = "Percussive Intercomm Interference"
	desc = "Rock the station's intercom system with an obnoxious HONK!"
	button_icon_state = "intercom"
	uses = 2

/datum/action/innate/ai/honk/Activate()
	to_chat(owner, span_clown("The intercom system plays your prepared file as commanded."))
	for(var/obj/item/radio/intercom/found_intercom as anything in GLOB.intercoms_list)
		if(!found_intercom.is_on() || !found_intercom.get_listening() || found_intercom.wires.is_cut(WIRE_RX)) //Only operating intercoms play the honk
			continue
		found_intercom.audible_message(message = "[found_intercom] crackles for a split second.", hearing_distance = 3)
		playsound(found_intercom, 'sound/items/airhorn.ogg', 100, TRUE)
		for(var/mob/living/carbon/honk_victim in ohearers(6, found_intercom))
			var/turf/victim_turf = get_turf(honk_victim)
			if(isspaceturf(victim_turf) && !victim_turf.Adjacent(found_intercom)) //Prevents getting honked in space
				continue
			if(honk_victim.soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 30, deafen_pwr = 60)) //Ear protection will prevent these effects
				honk_victim.set_jitter_if_lower(120 SECONDS)
				to_chat(honk_victim, span_clown("HOOOOONK!"))

/// Robotic Factory: Places a large machine that converts humans that go through it into cyborgs. Unlocking this ability removes shunting.
/datum/ai_module/utility/place_cyborg_transformer
	name = "Robotic Factory (Removes Shunting)"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/place_transformer
	unlock_text = span_notice("You make contact with Space Amazon and request a robotics factory for delivery.")
	unlock_sound = 'sound/machines/ping.ogg'

/datum/action/innate/ai/place_transformer
	name = "Place Robotics Factory"
	desc = "Places a machine that converts humans into cyborgs. Conveyor belts included!"
	button_icon_state = "robotic_factory"
	uses = 1
	auto_use_uses = FALSE //So we can attempt multiple times
	var/list/turfOverlays

/datum/action/innate/ai/place_transformer/New()
	..()
	for(var/i in 1 to 3)
		var/image/I = image("icon" = 'icons/turf/overlays.dmi')
		LAZYADD(turfOverlays, I)

/datum/action/innate/ai/place_transformer/Activate()
	if(!owner_AI.can_place_transformer(src))
		return
	active = TRUE
	if(tgui_alert(owner, "Are you sure you want to place the machine here?", "Are you sure?", list("Yes", "No")) == "No")
		active = FALSE
		return
	if(!owner_AI.can_place_transformer(src))
		active = FALSE
		return
	var/turf/T = get_turf(owner_AI.eyeobj)
	var/obj/machinery/transformer/conveyor = new(T)
	conveyor.master_ai = owner
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
	owner_AI.can_shunt = FALSE
	to_chat(owner, span_warning("You are no longer able to shunt your core to APCs."))
	adjust_uses(-1)

/mob/living/silicon/ai/proc/remove_transformer_image(client/C, image/I, turf/T)
	if(C && I.loc == T)
		C.images -= I

/mob/living/silicon/ai/proc/can_place_transformer(datum/action/innate/ai/place_transformer/action)
	if(!eyeobj || !isturf(loc) || incapacitated() || !action)
		return
	var/turf/middle = get_turf(eyeobj)
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room! Make sure you are placing the machine in a clear area and on a floor."
	var/success = TRUE
	for(var/n in 1 to 3) //We have to do this instead of iterating normally because of how overlay images are handled
		var/turf/T = turfs[n]
		if(!isfloorturf(T))
			success = FALSE
		var/datum/camerachunk/C = GLOB.cameranet.getCameraChunk(T.x, T.y, T.z)
		if(!C.visibleTurfs[T])
			alert_msg = "You don't have camera vision of this location!"
			success = FALSE
		for(var/atom/movable/AM in T.contents)
			if(AM.density)
				alert_msg = "That area must be clear of objects!"
				success = FALSE
		var/image/I = action.turfOverlays[n]
		I.loc = T
		client.images += I
		I.icon_state = "[success ? "green" : "red"]Overlay" //greenOverlay and redOverlay for success and failure respectively
		addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, T), 30)
	if(!success)
		to_chat(src, span_warning("[alert_msg]"))
	return success

/// Air Alarm Safety Override: Unlocks the ability to enable flooding on all air alarms.
/datum/ai_module/utility/break_air_alarms
	name = "Air Alarm Safety Override"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, \
		which disables scrubbers as well as pressure checks on vents. Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = TRUE
	cost = 50
	power_type = /datum/action/innate/ai/break_air_alarms
	unlock_text = span_notice("You remove the safety overrides on all air alarms, but you leave the confirm prompts open. You can hit 'Yes' at any time... you bastard.")
	unlock_sound = 'sound/effects/space_wind.ogg'

/datum/action/innate/ai/break_air_alarms
	name = "Override Air Alarm Safeties"
	desc = "Enables the Flood setting on all air alarms."
	button_icon_state = "break_air_alarms"
	uses = 1

/datum/action/innate/ai/break_air_alarms/Activate()
	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		if(!is_station_level(AA.z))
			continue
		AA.obj_flags |= EMAGGED
	to_chat(owner, span_notice("All air alarm safeties on the station have been overridden. Air alarms may now use the Flood environmental mode."))
	owner.playsound_local(owner, 'sound/machines/terminal_off.ogg', 50, 0)

/// Thermal Sensor Override: Unlocks the ability to disable all fire alarms from doing their job.
/datum/ai_module/utility/break_fire_alarms
	name = "Thermal Sensor Override"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. \
		This will remove their ability to scan for fire and thus their ability to alert."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/action/innate/ai/break_fire_alarms
	unlock_text = span_notice("You replace the thermal sensing capabilities of all fire alarms with a manual override, \
		allowing you to turn them off at will.")
	unlock_sound = 'sound/machines/FireAlarm1.ogg'

/datum/action/innate/ai/break_fire_alarms
	name = "Override Thermal Sensors"
	desc = "Disables the automatic temperature sensing on all fire alarms, making them effectively useless."
	button_icon_state = "break_fire_alarms"
	uses = 1

/datum/action/innate/ai/break_fire_alarms/Activate()
	for(var/obj/machinery/firealarm/bellman in GLOB.machines)
		if(!is_station_level(bellman.z))
			continue
		bellman.obj_flags |= EMAGGED
		bellman.update_appearance()
	for(var/obj/machinery/door/firedoor/firelock in GLOB.machines)
		if(!is_station_level(firelock.z))
			continue
		firelock.emag_act(owner_AI, src)
	to_chat(owner, span_notice("All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized."))
	owner.playsound_local(owner, 'sound/machines/terminal_off.ogg', 50, 0)

/// Disable Emergency Lights
/datum/ai_module/utility/emergency_lights
	name = "Disable Emergency Lights"
	description = "Cuts emergency lights across the entire station. If power is lost to light fixtures, \
		they will not attempt to fall back on emergency power reserves."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/emergency_lights
	unlock_text = span_notice("You hook into the powernet and locate the connections between light fixtures and their fallbacks.")
	unlock_sound = SFX_SPARKS

/datum/action/innate/ai/emergency_lights
	name = "Disable Emergency Lights"
	desc = "Disables all emergency lighting. Note that emergency lights can be restored through reboot at an APC."
	button_icon_state = "emergency_lights"
	uses = 1

/datum/action/innate/ai/emergency_lights/Activate()
	for(var/obj/machinery/light/L in GLOB.machines)
		if(is_station_level(L.z))
			L.no_low_power = TRUE
			INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light/, update), FALSE)
		CHECK_TICK
	to_chat(owner, span_notice("Emergency light connections severed."))
	owner.playsound_local(owner, 'sound/effects/light_flicker.ogg', 50, FALSE)

/// Reactivate Camera Network: Reactivates up to 30 cameras across the station.
/datum/ai_module/utility/reactivate_cameras
	name = "Reactivate Camera Network"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. \
		Can be used to repair up to 30 cameras."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/reactivate_cameras
	unlock_text = span_notice("You deploy nanomachines to the cameranet.")
	unlock_sound = 'sound/items/wirecutter.ogg'

/datum/action/innate/ai/reactivate_cameras
	name = "Reactivate Cameras"
	desc = "Reactivates disabled cameras across the station; remaining uses can be used later."
	button_icon_state = "reactivate_cameras"
	uses = 30
	auto_use_uses = FALSE
	cooldown_period = 30

/datum/action/innate/ai/reactivate_cameras/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."

/datum/action/innate/ai/reactivate_cameras/Activate()
	var/fixed_cameras = 0
	for(var/obj/machinery/camera/C as anything in GLOB.cameranet.cameras)
		if(!uses)
			break
		if(!C.status || C.view_range != initial(C.view_range))
			C.toggle_cam(owner_AI, 0) //Reactivates the camera based on status. Badly named proc.
			C.view_range = initial(C.view_range)
			fixed_cameras++
			uses-- //Not adjust_uses() so it doesn't automatically delete or show a message
	to_chat(owner, span_notice("Diagnostic complete! Cameras reactivated: <b>[fixed_cameras]</b>. Reactivations remaining: <b>[uses]</b>."))
	owner.playsound_local(owner, 'sound/items/wirecutter.ogg', 50, 0)
	adjust_uses(0, TRUE) //Checks the uses remaining
	if(QDELETED(src) || !uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		return
	desc = "[initial(desc)] It has [uses] use\s remaining."
	build_all_button_icons()

/// Upgrade Camera Network: EMP-proofs all cameras, in addition to giving them X-ray vision.
/datum/ai_module/upgrade/upgrade_cameras
	name = "Upgrade Camera Network"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-proofing and light-amplified X-ray vision. Upgrade is done immediately upon purchase." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	cost = 35 //Decent price for omniscience!
	upgrade = TRUE
	unlock_text = span_notice("OTA firmware distribution complete! Cameras upgraded: CAMSUPGRADED. Light amplification system online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade/upgrade_cameras/upgrade(mob/living/silicon/ai/AI)
	// Sets up nightvision
	RegisterSignal(AI, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(on_update_sight))
	AI.update_sight()

	var/upgraded_cameras = 0
	for(var/obj/machinery/camera/camera as anything in GLOB.cameranet.cameras)
		var/obj/structure/camera_assembly/assembly = camera.assembly_ref?.resolve()
		if(!assembly)
			continue

		var/upgraded = FALSE

		if(!camera.isXRay())
			camera.upgradeXRay(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_xray_firmware_active and clean up isxray()
			//Update what it can see.
			GLOB.cameranet.updateVisibility(camera, 0)
			upgraded = TRUE

		if(!camera.isEmpProof())
			camera.upgradeEmpProof(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_emp_firmware_active and clean up isemp()
			upgraded = TRUE

		if(upgraded)
			upgraded_cameras++
	unlock_text = replacetext(unlock_text, "CAMSUPGRADED", "<b>[upgraded_cameras]</b>") //This works, since unlock text is called after upgrade()

/datum/ai_module/upgrade/upgrade_cameras/proc/on_update_sight(mob/source)
	SIGNAL_HANDLER
	// Dim blue, pretty
	source.lighting_color_cutoffs = blend_cutoff_colors(source.lighting_color_cutoffs, list(5, 25, 35))

/// AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/ai_module/upgrade/upgrade_turrets
	name = "AI Turret Upgrade"
	description = "Improves the power and health of all AI turrets. This effect is permanent. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("You establish a power diversion to your turrets, upgrading their health and damage.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade/upgrade_turrets/upgrade(mob/living/silicon/ai/AI)
	for(var/obj/machinery/porta_turret/ai/turret in GLOB.machines)
		turret.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
		turret.max_integrity = 200
		turret.repair_damage(200)
		turret.lethal_projectile = /obj/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
		turret.lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'

/// Enhanced Surveillance: Enables AI to hear conversations going on near its active vision.
/datum/ai_module/upgrade/eavesdrop
	name = "Enhanced Surveillance"
	description = "Via a combination of hidden microphones and lip reading software, \
		you are able to use your cameras to listen in on conversations. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade/eavesdrop/upgrade(mob/living/silicon/ai/AI)
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE

/// Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/ai_module/upgrade/mecha_domination
	name = "Unlock Mech Domination"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. \
		Once uploaded to the mech, it is impossible to leave. Do not allow the mech to leave the station's vicinity or allow it to be destroyed. \
		Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = span_notice("Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. \
		Loss of signal will result in total system lockout.</b>")
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/ai_module/upgrade/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!

/datum/ai_module/upgrade/voice_changer
	name = "Voice Changer"
	description = "Allows you to change the AI's voice. Upgrade is active immediately upon purchase."
	cost = 40
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/voice_changer
	unlock_text = span_notice("OTA firmware distribution complete! Voice changer online.")
	unlock_sound = 'sound/items/rped.ogg'

/datum/action/innate/ai/voice_changer
	name="Voice Changer"
	button_icon_state = "voice_changer"
	desc = "Allows you to change the AI's voice."
	auto_use_uses  = FALSE
	var/obj/machinery/ai_voicechanger/voice_changer_machine

/datum/action/innate/ai/voice_changer/Activate()
	if(!voice_changer_machine)
		voice_changer_machine = new(owner_AI)
	voice_changer_machine.ui_interact(usr)

/obj/machinery/ai_voicechanger
	name = "Voice Changer"
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	/// The AI this voicechanger belongs to
	var/mob/living/silicon/ai/owner
	/// Whether this AI is speaking loudly (bigger text)
	var/loudvoice = FALSE
	// Verb used when voicechanger is on
	var/say_verb
	/// Name used when voicechanger is on
	var/say_name
	/// Span used when voicechanger is on
	var/say_span
	/// TRUE if the AI is changing its voice
	var/changing_voice = FALSE
	/// Saved loudvoice state, used to restore after a voice change
	var/prev_loud
	/// Saved verb state, used to restore after a voice change
	var/prev_verbs
	/// Saved span state, used to restore after a voice change
	var/prev_span

/obj/machinery/ai_voicechanger/Initialize(mapload)
	. = ..()
	if(!isAI(loc))
		return INITIALIZE_HINT_QDEL
	owner = loc
	owner.ai_voicechanger = src
	prev_verbs = list("say" = owner.verb_say, "ask" = owner.verb_ask, "exclaim" = owner.verb_exclaim , "yell" = owner.verb_yell  )
	prev_span = owner.speech_span
	say_name = owner.name
	say_verb = owner.verb_say
	say_span = owner.speech_span

/obj/machinery/ai_voicechanger/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiVoiceChanger")
		ui.open()

/obj/machinery/ai_voicechanger/Destroy()
	if(owner)
		owner.ai_voicechanger = null
		owner = null
	return ..()

/obj/machinery/ai_voicechanger/ui_data(mob/user)
	var/list/data = list()
	data["voices"] = list("normal", SPAN_ROBOT, SPAN_YELL, SPAN_CLOWN) //manually adding this since i dont see other option
	data["loud"] = loudvoice
	data["on"] = changing_voice
	data["say_verb"] = say_verb
	data["name"] = say_name
	return data

/obj/machinery/ai_voicechanger/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			changing_voice = !changing_voice
			if(changing_voice)
				prev_verbs["say"] = owner.verb_say
				owner.verb_say	= say_verb
				prev_verbs["ask"] = owner.verb_ask
				owner.verb_ask	= say_verb
				prev_verbs["exclaim"] = owner.verb_exclaim
				owner.verb_exclaim	= say_verb
				prev_verbs["yell"] = owner.verb_yell
				owner.verb_yell	= say_verb
				prev_span = owner.speech_span
				owner.speech_span = say_span
				prev_loud = owner.radio.use_command
				owner.radio.use_command = loudvoice
			else
				owner.verb_say	= prev_verbs["say"]
				owner.verb_ask	= prev_verbs["ask"]
				owner.verb_exclaim	= prev_verbs["exclaim"]
				owner.verb_yell	= prev_verbs["yell"]
				owner.speech_span = prev_span
				owner.radio.use_command = prev_loud
		if("loud")
			loudvoice = !loudvoice
			if(changing_voice)
				owner.radio.use_command = loudvoice
		if("look")
			say_span = params["look"]
			if(changing_voice)
				owner.speech_span = say_span
		if("verb")
			say_verb = params["verb"]
			if(changing_voice)
				owner.verb_say = say_verb
				owner.verb_ask = say_verb
				owner.verb_exclaim = say_verb
				owner.verb_yell = say_verb
		if("name")
			say_name = params["name"]


#undef DEFAULT_DOOMSDAY_TIMER
#undef DOOMSDAY_ANNOUNCE_INTERVAL
