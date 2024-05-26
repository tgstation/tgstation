PROCESSING_SUBSYSTEM_DEF(hacking)
	name = "Hacking"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_NPC
	stat_tag = "Hacking"


/atom
	/// Some atoms can be hacked so awesome
	var/datum/hacking/hacking = null

/atom/Destroy(force)
	. = ..()
	if(hacking)
		QDEL_NULL(hacking)

/// Attempts to open the hacking interface
/atom/proc/attempt_hacking_interaction(mob/user)
	if(!hacking)
		return WIRE_INTERACTION_FAIL
	if(!user.CanReach(src))
		return WIRE_INTERACTION_FAIL
	hacking.interact(user)
	return WIRE_INTERACTION_BLOCK

/datum/hacking
	/// The holder (atom that contains this hacking datum)
	var/atom/holder
	/// The hacker (mob currently hacking us)
	var/mob/living/hacker
	/// The hacking tool being used
	var/obj/item/hackingtool
	/// The holder's typepath (used for sanity checks to make sure the holder is the appropriate type for this hacking datum)
	var/holder_type = null
	/// The display name for the hacking type, might get shown somewhere at some point
	var/proper_name = "Unknown"

	/// Initial attack value for holder
	var/initial_holder_attack = 100
	/// Initial health value for holder
	var/initial_holder_health = 100
	/// Initial defense value for holder
	var/initial_holder_defense = 100

	/// Holder's current attack stat
	var/holder_attack
	/// Holder's current health stat
	var/holder_health
	/// Holder's current defense stat
	var/holder_defense
	/// Last attack the holder performed
	var/holder_last_attack

	/// Cooldown for the holder's actions
	COOLDOWN_DECLARE(holder_action_cooldown)

	/// Hacker's current attack stat
	var/hacker_attack
	/// Hacker's current health stat
	var/hacker_health
	/// Hacker's current defense stat
	var/hacker_defense
	/// Last attack the hacker performed
	var/hacker_last_attack

	/// Cooldown for the hacker's actions
	COOLDOWN_DECLARE(hacker_action_cooldown)

	/**
	 * What hacking actions can be done to this holder, and what proc it calls when successful
	 * Starts out as a key for the hacking actions list.
	*/
	var/list/hacking_actions = "generic"
	/// Current hacking action being done
	var/current_hacking_action
	/// Whether we have already been hacked or not
	var/hacked = FALSE

/datum/hacking/New(atom/new_holder)
	. = ..()
	if(!islist(hacking_actions))
		hacking_actions = get_hacking_actions()
	if(new_holder)
		set_holder(new_holder)

/datum/hacking/Destroy()
	. = ..()
	stop_hacking()
	if(hacker)
		unset_hacker(hacker)
	if(holder)
		unset_holder(holder)
	hacking_actions = null

/datum/hacking/ui_host()
	return holder

/datum/hacking/ui_status(mob/user)
	if(!interactable(user))
		return UI_CLOSE
	return ..()

/datum/hacking/ui_state(mob/user)
	return GLOB.physical_state

/datum/hacking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HackingMinigame", "[holder.name] Hacking")
		ui.open()

/datum/hacking/ui_data(mob/user)
	var/list/data = list()

	data["hacked"] = hacked
	data["hacking_name"] = proper_name
	data["holder_name"] = holder.name
	var/list/hacking_actions_flat = list()
	for(var/action in hacking_actions)
		hacking_actions_flat |= action
	data["hacking_actions"] = hacking_actions_flat
	data["current_hacking_action"] = current_hacking_action
	if(current_hacking_action)
		data["holder_attack"] = holder_attack
		data["holder_health"] = holder_health
		data["holder_defense"] = holder_defense
		data["holder_last_attack"] = holder_last_attack
		var/holder_percent = clamp(FLOOR((1 - (holder_action_cooldown - world.time)/(HACKING_ATTACK_COOLDOWN_DURATION)) * 100, 1), 0, 100)
		data["holder_cooldown"] = holder_percent

		data["hacker_attack"] = hacker_attack
		data["hacker_health"] = hacker_health
		data["hacker_defense"] = hacker_defense
		data["hacker_last_attack"] = hacker_last_attack
		var/hacker_percent = clamp(FLOOR((1 - (hacker_action_cooldown - world.time)/(HACKING_ATTACK_COOLDOWN_DURATION)) * 100, 1), 0, 100)
		data["hacker_cooldown"] = hacker_percent
	else
		data["holder_attack"] = initial_holder_attack
		data["holder_health"] = initial_holder_health
		data["holder_defense"] = initial_holder_defense

	return data

/datum/hacking/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/living/user = usr
	switch(action)
		if("start_hacking")
			if(current_hacking_action)
				return
			var/hacking_action = params["hacking_action"]
			set_hacker(user)
			start_hacking(hacking_action, user)
			playsound(holder, 'monkestation/code/modules/cybernetics/sounds/hacking/ddos_start.wav', 80, FALSE)
		if("do_attack")
			if((user != hacker) || !COOLDOWN_FINISHED(src, hacker_action_cooldown))
				return
			var/attack_type = params["hacking_attack"]
			hacker_attack(attack_type)
	return TRUE

/datum/hacking/process(delta_time)
	if(holder_health <= 0)
		hacker_win()
		stop_hacking()
		return
	if(hacker_health <= 0)
		hacker_loss()
		stop_hacking()
		return
	if(!COOLDOWN_FINISHED(src, holder_action_cooldown))
		return
	var/holder_attack_type = get_holder_attack()
	holder_attack(holder_attack_type)

/datum/hacking/proc/interact(mob/user)
	if(!interactable(user))
		return
	ui_interact(user)

/datum/hacking/proc/interactable(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(user, COMSIG_TRY_HACKING_INTERACT, holder) & COMPONENT_CANT_INTERACT_HACKING)
		return FALSE
	if(!user.is_holding_tool_quality(TOOL_HACKING))
		return FALSE
	return TRUE

/datum/hacking/proc/set_hacking_stats()
	SHOULD_CALL_PARENT(TRUE)
	holder_attack = initial_holder_attack
	holder_health = initial_holder_health
	holder_defense = initial_holder_defense

/datum/hacking/proc/start_hacking(hacking_action = "Destroy", mob/living/hackerman)
	if(hacked)
		playsound(holder, 'monkestation/code/modules/cybernetics/sounds/hacking/ddos_success.wav', 80, FALSE)
		return do_hacking_action(hacking_action, hackerman)
	set_hacking_stats()

	current_hacking_action = hacking_action
	hacker_attack = 5 * 7
	hacker_health = 5 * 10
	hacker_defense = 5 * 8

	var/obj/item/ddos = hackerman.get_active_held_item()
	if(ddos.tool_behaviour == TOOL_HACKING)
		hackingtool = ddos
		if(ishackingtool(hackingtool))
			hackingtool.cut_overlays()
			hackingtool.add_overlay("bluescreen")

	COOLDOWN_START(src, hacker_action_cooldown, 0)
	COOLDOWN_START(src, holder_action_cooldown, HACKING_ATTACK_COOLDOWN_DURATION)
	START_PROCESSING(SShacking, src)

/datum/hacking/proc/stop_hacking()
	current_hacking_action = null
	if(hacker)
		unset_hacker(hacker)
	if(hackingtool)
		UnregisterSignal(hackingtool, COMSIG_QDELETING)
		addtimer(CALLBACK(hackingtool, /atom/proc/cut_overlays), 2 SECONDS)
		hackingtool = null
	STOP_PROCESSING(SShacking, src)

/datum/hacking/proc/hacker_attack(attack_type = "Attack")
	COOLDOWN_START(src, hacker_action_cooldown, HACKING_ATTACK_COOLDOWN_DURATION)
	playsound(holder, "monkestation/code/modules/cybernetics/sounds/hacking/ddos[rand(1, 4)].wav", 80, FALSE)
	switch(attack_type)
		if("Attack")
			var/damage = max(0, hacker_attack - holder_defense)
			holder_health = max(0, holder_health - damage)
		if("Mask")
			holder_attack = max(0, holder_attack - 37)
		if("Scan")
			holder_defense = max(0, holder_defense - 35)
		if("Shield")
			hacker_defense = max(0, hacker_defense + 36)
		if("Overflow")
			hacker_attack = max(0, hacker_attack + 37)
			hacker_defense = max(0, hacker_defense - 22)
	hacker_last_attack = attack_type

/datum/hacking/proc/holder_attack(attack_type = "Attack")
	COOLDOWN_START(src, holder_action_cooldown, HACKING_ATTACK_COOLDOWN_DURATION)
	playsound(holder, "monkestation/code/modules/cybernetics/sounds/hacking/ddos[rand(1, 4)].wav", 80, FALSE)
	switch(attack_type)
		if("Attack")
			var/damage = max(0, holder_attack - hacker_defense)
			hacker_health = max(0, hacker_health - damage)
		if("Mask")
			hacker_attack = max(0, hacker_attack - 37)
		if("Scan")
			hacker_defense = max(0, hacker_defense - 35)
		if("Shield")
			holder_defense = max(0, holder_defense + 36)
		if("Overflow")
			holder_attack = max(0, holder_attack + 37)
			holder_defense = max(0, holder_defense - 22)
	holder_last_attack = attack_type

/datum/hacking/proc/get_holder_attack()
	var/final_attack = "Attack"
	if((hacker_defense >= holder_attack) && prob(75))
		final_attack = "Scan"
	if((holder_defense < 20) && prob(75))
		final_attack = "Shield"
	if((holder_attack < 20) && prob(75))
		final_attack = "Overflow"
	return final_attack

/datum/hacking/proc/hacker_win()
	hacked = TRUE
	playsound(holder, "monkestation/code/modules/cybernetics/sounds/hacking/ddos_success.wav", 80, FALSE)
	if(hackingtool)
		if(ishackingtool(hackingtool))
			hackingtool.cut_overlays()
			hackingtool.add_overlay("greenscreen")
		addtimer(CALLBACK(hackingtool, /atom/proc/cut_overlays), 1 SECONDS)
	return do_hacking_action(current_hacking_action, hacker)

/datum/hacking/proc/hacker_loss()
	playsound(holder, "monkestation/code/modules/cybernetics/sounds/hacking/ddos_failure.wav", 80, FALSE)
	if(hackingtool)
		if(ishackingtool(hackingtool))
			hackingtool.cut_overlays()
			hackingtool.add_overlay("redscreen")
		addtimer(CALLBACK(hackingtool, /atom/proc/cut_overlays), 1 SECONDS)

/datum/hacking/proc/do_hacking_action(action = "Destroy", mob/living/hackerman)
	return call(src, hacking_actions[action])(hackerman)

/datum/hacking/proc/destroy_holder(mob/living/hackerman)
	holder.atom_break(BOMB)

/datum/hacking/proc/get_hacking_actions()
	if(GLOB.hacking_actions_by_key[hacking_actions])
		return GLOB.hacking_actions_by_key[hacking_actions]
	return generate_hacking_actions()

/datum/hacking/proc/generate_hacking_actions()
	GLOB.hacking_actions_by_key[hacking_actions] = list(
		"Destroy" = .proc/destroy_holder,
	)
	return GLOB.hacking_actions_by_key[hacking_actions]

/datum/hacking/proc/set_holder(atom/new_holder)
	if(!istype(new_holder, holder_type))
		CRASH("Hacking holder is not of the expected type! ([new_holder.type], should be [holder_type])")
	holder = new_holder
	RegisterSignal(new_holder, COMSIG_QDELETING, .proc/on_holder_qdel)

/datum/hacking/proc/unset_holder(atom/previous_holder)
	holder = null
	UnregisterSignal(previous_holder, COMSIG_QDELETING)
	stop_hacking()

/datum/hacking/proc/set_hacker(atom/new_hacker)
	hacker = new_hacker
	RegisterSignal(new_hacker, COMSIG_QDELETING, .proc/on_hacker_qdel)

/datum/hacking/proc/unset_hacker(atom/previous_holder)
	hacker = null
	UnregisterSignal(previous_holder, COMSIG_QDELETING)
	stop_hacking()

/datum/hacking/proc/on_holder_qdel(atom/source, force)
	SIGNAL_HANDLER

	unset_holder(source)
	qdel(src)

/datum/hacking/proc/on_hacker_qdel(atom/source, force)
	SIGNAL_HANDLER

	unset_hacker(source)

/datum/hacking/proc/on_hackingtool_qdel(atom/source, force)
	SIGNAL_HANDLER

	UnregisterSignal(hackingtool, COMSIG_QDELETING)
	hackingtool = null


/obj/item/ddos
	name = "denial of service device"
	desc = "A compact, hastily thrown together circuitboard used to hack into a myriad of electronics."
	icon = 'monkestation/code/modules/cybernetics/icons/hacking.dmi'
	icon_state = "ddos"
	lefthand_file = 'monkestation/code/modules/cybernetics/icons/hacking_left.dmi'
	righthand_file = 'monkestation/code/modules/cybernetics/icons/hacking_right.dmi'
	tool_behaviour = TOOL_HACKING
	toolspeed = 1
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ddos/examine_more(mob/user)
	. = ..()
	var/botnets = rand(1, 100)
	. += span_info("[src] reports...")
	. += span_big(span_alert("[botnets] BOTNET[botnets == 1 ? "" : "S"] ONLINE"))
