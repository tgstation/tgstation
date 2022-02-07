#define DEFAULT_DOOMSDAY_TIMER 4500
#define DOOMSDAY_ANNOUNCE_INTERVAL 600

GLOBAL_LIST_INIT(blacklisted_malf_machines, typecacheof(list(
		/obj/machinery/field/containment,
		/obj/machinery/power/supermatter_crystal,
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
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	/// The owner AI, so we don't have to typecast every time
	var/mob/living/silicon/ai/owner_AI
	/// If we have multiple uses of the same power
	var/uses
	/// If we automatically use up uses on each activation
	var/auto_use_uses = TRUE
	/// If applicable, the time in deciseconds we have to wait before using any more modules
	var/cooldown_period

/datum/action/innate/ai/Grant(mob/living/L)
	. = ..()
	if(!isAI(owner))
		WARNING("AI action [name] attempted to grant itself to non-AI mob [L.real_name] ([L.key])!")
		qdel(src)
	else
		owner_AI = owner

/datum/action/innate/ai/IsAvailable()
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
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		qdel(src)

/// Framework for ranged abilities that can have different effects by left-clicking stuff.
/datum/action/innate/ai/ranged
	name = "Ranged AI Action"
	auto_use_uses = FALSE //This is so we can do the thing and disable/enable freely without having to constantly add uses
	/// The linked proc holder that contains the actual ability code
	var/obj/effect/proc_holder/ranged_ai/linked_ability
	/// The path of our linked ability
	var/linked_ability_type

/datum/action/innate/ai/ranged/New()
	if(!linked_ability_type)
		WARNING("Ranged AI action [name] attempted to spawn without a linked ability!")
		qdel(src) //uh oh!
		return
	linked_ability = new linked_ability_type()
	linked_ability.attached_action = src
	..()

/datum/action/innate/ai/ranged/adjust_uses(amt, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, span_notice("[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining."))
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, span_warning("[name] has run out of uses!"))
		Remove(owner)
		QDEL_IN(src, 100) //let any active timers on us finish up

/datum/action/innate/ai/ranged/Destroy()
	QDEL_NULL(linked_ability)
	return ..()

/datum/action/innate/ai/ranged/Activate()
	linked_ability.toggle(owner)
	return TRUE

/// The actual ranged proc holder.
/obj/effect/proc_holder/ranged_ai
	/// Appears when the user activates the ability
	var/enable_text = "<span class='notice'>Hello World!</span>"
	/// Appears when the user deactivates the ability
	var/disable_text = "<span class='danger'>Goodbye Cruel World!</span>"
	var/datum/action/innate/ai/ranged/attached_action

/obj/effect/proc_holder/ranged_ai/Destroy()
	attached_action = null
	return ..()

/obj/effect/proc_holder/ranged_ai/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability(disable_text)
	else
		add_ranged_ability(user, enable_text)

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
	var/unlock_text = "<span class='notice'>Hello World!</span>"
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
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay. Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/nuke_station
	unlock_text = "<span class='notice'>You slowly, carefully, establish a connection with the on-station self-destruct. You can now activate it at any time.</span>"

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
	sleep(5)
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
		sleep(20)
		if(QDELETED(owner) || !isturf(owner_AI.loc))
			active = FALSE
			return
		to_chat(owner, span_boldannounce("Sending security report to Central Command.....[rand(0, 9) + (rand(20, 30) * i)]%"))
	sleep(3)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>auth 'akjv9c88asdf12nb' [pass]</span>")
	owner.playsound_local(owner, 'sound/items/timer.ogg', 50, 0, use_reverb = FALSE)
	sleep(30)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Welcome, akjv9c88asdf12nb."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(5)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Arm self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0, use_reverb = FALSE)
	sleep(20)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(15)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Confirm arming of self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(10)
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
	sleep(14)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>[pass]</span>")
	sleep(40)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Transmitting arming signal..."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(30)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	if (owner_AI.stat != DEAD)
		priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", ANNOUNCER_AIMALF)
		set_security_level("delta")
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
	set_security_level("red")
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
		detonate()
	else if(world.time >= next_announce)
		minor_announce("[sec_left] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		next_announce += DOOMSDAY_ANNOUNCE_INTERVAL

/obj/machinery/doomsday_device/proc/detonate()
	sound_to_playing_players('sound/machines/alarm.ogg')
	sleep(100)
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/turf/T = get_turf(L)
		if(!T || !is_station_level(T.z))
			continue
		if(issilicon(L))
			continue
		to_chat(L, span_userdanger("The blast wave from [src] tears you atom from atom!"))
		L.dust()
	to_chat(world, "<B>The AI cleansed the station of life with the doomsday device!</B>")
	SSticker.force_ending = 1

/// Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/ai_module/destructive/lockdown
	name = "Hostile Station Lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds, briefly \
	opening all doors on the station."
	cost = 30
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/lockdown
	unlock_text = "<span class='notice'>You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.</span>"
	unlock_sound = 'sound/machines/boltsdown.ogg'

/datum/action/innate/ai/lockdown
	name = "Lockdown"
	desc = "Closes, bolts, and depowers every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	button_icon_state = "lockdown"
	uses = 1

/datum/action/innate/ai/lockdown/Activate()
	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, /obj/machinery/door.proc/hostile_lockdown, owner)
		addtimer(CALLBACK(D, /obj/machinery/door.proc/disable_lockdown), 900)

	var/obj/machinery/computer/communications/C = locate() in GLOB.machines
	if(C)
		C.post_status("alert", "lockdown")

	minor_announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.","Network Alert:", TRUE)
	to_chat(owner, span_danger("Lockdown initiated. Network reset in 90 seconds."))
	addtimer(CALLBACK(GLOBAL_PROC, .proc/minor_announce,
		"Automatic system reboot complete. Have a secure day.",
		"Network reset:"), 900)

/// Override Machine: Allows the AI to override a machine, animating it into an angry, living version of itself.
/datum/ai_module/destructive/override_machine
	name = "Machine Override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. Four uses per purchase."
	cost = 30
	power_type = /datum/action/innate/ai/ranged/override_machine
	unlock_text = "<span class='notice'>You procure a virus from the Space Dark Web and distribute it to the station's machines.</span>"
	unlock_sound = 'sound/machines/airlock_alien_prying.ogg'

/datum/action/innate/ai/ranged/override_machine
	name = "Override Machine"
	desc = "Animates a targeted machine, causing it to attack anyone nearby."
	button_icon_state = "override_machine"
	uses = 4
	linked_ability_type = /obj/effect/proc_holder/ranged_ai/override_machine

/datum/action/innate/ai/ranged/override_machine/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/ranged/override_machine/proc/animate_machine(obj/machinery/M)
	if(M && !QDELETED(M))
		new/mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, owner, 1)

/obj/effect/proc_holder/ranged_ai/override_machine
	active = FALSE
	ranged_mousepointer = 'icons/effects/mouse_pointers/override_machine_target.dmi'
	enable_text = "<span class='notice'>You tap into the station's powernet. Click on a machine to animate it, or use the ability again to cancel.</span>"
	disable_text = "<span class='notice'>You release your hold on the powernet.</span>"

/obj/effect/proc_holder/ranged_ai/override_machine/InterceptClickOn(mob/living/caller, params, obj/machinery/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	if(!istype(target))
		to_chat(ranged_ability_user, span_warning("You can only animate machines!"))
		return
	if(!target.can_be_overridden() || is_type_in_typecache(target, GLOB.blacklisted_malf_machines))
		to_chat(ranged_ability_user, span_warning("That machine can't be overridden!"))
		return
	ranged_ability_user.playsound_local(ranged_ability_user, 'sound/misc/interference.ogg', 50, 0, use_reverb = FALSE)
	attached_action.adjust_uses(-1)
	if(attached_action?.uses)
		attached_action.desc = "[initial(attached_action.desc)] It has [attached_action.uses] use\s remaining."
		attached_action.UpdateButtonIcon()
	target.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [target]!"))
	addtimer(CALLBACK(attached_action, /datum/action/innate/ai/ranged/override_machine.proc/animate_machine, target), 50) //kabeep!
	remove_ranged_ability(span_danger("Sending override signal..."))
	return TRUE

/// Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/ai_module/destructive/destroy_rcd
	name = "Destroy RCDs"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/destroy_rcds
	unlock_text = "<span class='notice'>After some improvisation, you rig your onboard radio to be able to send a signal to detonate all RCDs.</span>"
	unlock_sound = 'sound/items/timer.ogg'

/datum/action/innate/ai/destroy_rcds
	name = "Destroy RCDs"
	desc = "Detonate all non-cyborg RCDs on the station."
	button_icon_state = "detonate_rcds"
	uses = 1
	cooldown_period = 100

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
	unlock_text = "<span class='notice'>You enable the ability for the station's APCs to direct intense energy into machinery.</span>"
	unlock_sound = 'sound/effects/comfyfire.ogg' //definitely not comfy, but it's the closest sound to "roaring fire" we have

/datum/action/innate/ai/ranged/overload_machine
	name = "Overload Machine"
	desc = "Overheats a machine, causing a small explosion after a short time."
	button_icon_state = "overload_machine"
	uses = 2
	linked_ability_type = /obj/effect/proc_holder/ranged_ai/overload_machine

/datum/action/innate/ai/ranged/overload_machine/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/ranged/overload_machine/proc/detonate_machine(obj/machinery/M)
	if(M && !QDELETED(M))
		var/turf/T = get_turf(M)
		message_admins("[ADMIN_LOOKUPFLW(usr)] overloaded [M.name] ([M.type]) at [ADMIN_VERBOSEJMP(T)].")
		log_game("[key_name(usr)] overloaded [M.name] ([M.type]) at [AREACOORD(T)].")
		explosion(M, heavy_impact_range = 2, light_impact_range = 3)
		if(M) //to check if the explosion killed it before we try to delete it
			qdel(M)

/obj/effect/proc_holder/ranged_ai/overload_machine
	active = FALSE
	ranged_mousepointer = 'icons/effects/mouse_pointers/overload_machine_target.dmi'
	enable_text = "<span class='notice'>You tap into the station's powernet. Click on a machine to detonate it, or use the ability again to cancel.</span>"
	disable_text = "<span class='notice'>You release your hold on the powernet.</span>"

/obj/effect/proc_holder/ranged_ai/overload_machine/InterceptClickOn(mob/living/caller, params, obj/machinery/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	if(!istype(target))
		to_chat(ranged_ability_user, span_warning("You can only overload machines!"))
		return
	if(is_type_in_typecache(target, GLOB.blacklisted_malf_machines))
		to_chat(ranged_ability_user, span_warning("You cannot overload that device!"))
		return
	ranged_ability_user.playsound_local(ranged_ability_user, "sparks", 50, 0)
	attached_action.adjust_uses(-1)
	if(attached_action?.uses)
		attached_action.desc = "[initial(attached_action.desc)] It has [attached_action.uses] use\s remaining."
		attached_action.UpdateButtonIcon()
	target.audible_message(span_userdanger("You hear a loud electrical buzzing sound coming from [target]!"))
	addtimer(CALLBACK(attached_action, /datum/action/innate/ai/ranged/overload_machine.proc/detonate_machine, target), 50) //kaboom!
	remove_ranged_ability(span_danger("Overcharging machine..."))
	return TRUE

/// Blackout: Overloads a random number of lights across the station. Three uses.
/datum/ai_module/destructive/blackout
	name = "Blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. Three uses per purchase."
	cost = 15
	power_type = /datum/action/innate/ai/blackout
	unlock_text = "<span class='notice'>You hook into the powernet and route bonus power towards the station's lighting.</span>"
	unlock_sound = "sparks"

/datum/action/innate/ai/blackout
	name = "Blackout"
	desc = "Overloads random lights across the station."
	button_icon_state = "blackout"
	uses = 3
	auto_use_uses = FALSE

/datum/action/innate/ai/blackout/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/blackout/Activate()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(prob(30 * apc.overload))
			apc.overload_lighting()
		else
			apc.overload++
	to_chat(owner, span_notice("Overcurrent applied to the powernet."))
	owner.playsound_local(owner, "sparks", 50, 0)
	adjust_uses(-1)
	if(src && uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		desc = "[initial(desc)] It has [uses] use\s remaining."
		UpdateButtonIcon()

/// Robotic Factory: Places a large machine that converts humans that go through it into cyborgs. Unlocking this ability removes shunting.
/datum/ai_module/utility/place_cyborg_transformer
	name = "Robotic Factory (Removes Shunting)"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/place_transformer
	unlock_text = "<span class='notice'>You make contact with Space Amazon and request a robotics factory for delivery.</span>"
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
		var/image/I = image("icon"='icons/turf/overlays.dmi')
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
	conveyor.masterAI = owner
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
		addtimer(CALLBACK(src, .proc/remove_transformer_image, client, I, T), 30)
	if(!success)
		to_chat(src, span_warning("[alert_msg]"))
	return success

/// Air Alarm Safety Override: Unlocks the ability to enable flooding on all air alarms.
/datum/ai_module/utility/break_air_alarms
	name = "Air Alarm Safety Override"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, which disables scrubbers as well as pressure checks on vents. \
	Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = TRUE
	cost = 50
	power_type = /datum/action/innate/ai/break_air_alarms
	unlock_text = "<span class='notice'>You remove the safety overrides on all air alarms, but you leave the confirm prompts open. You can hit 'Yes' at any time... you bastard.</span>"
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
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/action/innate/ai/break_fire_alarms
	unlock_text = "<span class='notice'>You replace the thermal sensing capabilities of all fire alarms with a manual override, allowing you to turn them off at will.</span>"
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
	description = "Cuts emergency lights across the entire station. If power is lost to light fixtures, they will not attempt to fall back on emergency power reserves."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/emergency_lights
	unlock_text = "<span class='notice'>You hook into the powernet and locate the connections between light fixtures and their fallbacks.</span>"
	unlock_sound = "sparks"

/datum/action/innate/ai/emergency_lights
	name = "Disable Emergency Lights"
	desc = "Disables all emergency lighting. Note that emergency lights can be restored through reboot at an APC."
	button_icon_state = "emergency_lights"
	uses = 1

/datum/action/innate/ai/emergency_lights/Activate()
	for(var/obj/machinery/light/L in GLOB.machines)
		if(is_station_level(L.z))
			L.no_emergency = TRUE
			INVOKE_ASYNC(L, /obj/machinery/light/.proc/update, FALSE)
		CHECK_TICK
	to_chat(owner, span_notice("Emergency light connections severed."))
	owner.playsound_local(owner, 'sound/effects/light_flicker.ogg', 50, FALSE)

/// Reactivate Camera Network: Reactivates up to 30 cameras across the station.
/datum/ai_module/utility/reactivate_cameras
	name = "Reactivate Camera Network"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. Can be used to repair up to 30 cameras."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/reactivate_cameras
	unlock_text = "<span class='notice'>You deploy nanomachines to the cameranet.</span>"
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
	button.desc = desc

/datum/action/innate/ai/reactivate_cameras/Activate()
	var/fixed_cameras = 0
	for(var/V in GLOB.cameranet.cameras)
		if(!uses)
			break
		var/obj/machinery/camera/C = V
		if(!C.status || C.view_range != initial(C.view_range))
			C.toggle_cam(owner_AI, 0) //Reactivates the camera based on status. Badly named proc.
			C.view_range = initial(C.view_range)
			fixed_cameras++
			uses-- //Not adjust_uses() so it doesn't automatically delete or show a message
	to_chat(owner, span_notice("Diagnostic complete! Cameras reactivated: <b>[fixed_cameras]</b>. Reactivations remaining: <b>[uses]</b>."))
	owner.playsound_local(owner, 'sound/items/wirecutter.ogg', 50, 0)
	adjust_uses(0, TRUE) //Checks the uses remaining
	if(src && uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		desc = "[initial(desc)] It has [uses] use\s remaining."
		UpdateButtonIcon()

/// Upgrade Camera Network: EMP-proofs all cameras, in addition to giving them X-ray vision.
/datum/ai_module/upgrade/upgrade_cameras
	name = "Upgrade Camera Network"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-proofing and light-amplified X-ray vision. Upgrade is done immediately upon purchase." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	cost = 35 //Decent price for omniscience!
	upgrade = TRUE
	unlock_text = "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: CAMSUPGRADED. Light amplification system online.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade/upgrade_cameras/upgrade(mob/living/silicon/ai/AI)
	AI.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE //Night-vision, without which X-ray would be very limited in power.
	AI.update_sight()

	var/upgraded_cameras = 0
	for(var/V in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = V
		var/obj/structure/camera_assembly/assembly = C.assembly_ref?.resolve()
		if(assembly)
			var/upgraded = FALSE

			if(!C.isXRay())
				C.upgradeXRay(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_xray_firmware_active and clean up isxray()
				//Update what it can see.
				GLOB.cameranet.updateVisibility(C, 0)
				upgraded = TRUE

			if(!C.isEmpProof())
				C.upgradeEmpProof(TRUE) //if this is removed you can get rid of camera_assembly/var/malf_emp_firmware_active and clean up isemp()
				upgraded = TRUE

			if(upgraded)
				upgraded_cameras++
	unlock_text = replacetext(unlock_text, "CAMSUPGRADED", "<b>[upgraded_cameras]</b>") //This works, since unlock text is called after upgrade()

/// AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/ai_module/upgrade/upgrade_turrets
	name = "AI Turret Upgrade"
	description = "Improves the power and health of all AI turrets. This effect is permanent. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>You establish a power diversion to your turrets, upgrading their health and damage.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade/upgrade_turrets/upgrade(mob/living/silicon/ai/AI)
	for(var/obj/machinery/porta_turret/ai/turret in GLOB.machines)
		turret.repair_damage(30)
		turret.lethal_projectile = /obj/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
		turret.lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'

/// Enhanced Surveillance: Enables AI to hear conversations going on near its active vision.
/datum/ai_module/upgrade/eavesdrop
	name = "Enhanced Surveillance"
	description = "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade/eavesdrop/upgrade(mob/living/silicon/ai/AI)
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE

/// Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/ai_module/upgrade/mecha_domination
	name = "Unlock Mech Domination"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed. Upgrade is done immediately upon purchase."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b></span>"
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/ai_module/upgrade/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!

#undef DEFAULT_DOOMSDAY_TIMER
#undef DOOMSDAY_ANNOUNCE_INTERVAL
