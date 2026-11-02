/// Ratwood's structures have no armor: a door basher's blow goes through all of it (PENETRATE_ARMOUR() of 100).
#define ROCKHILL_DOOR_BASH_PENETRATION 100

/mob/living/carbon/human
	var/received_resident_key = FALSE

/obj/structure/mineral_door/rockhill
	name = "door"
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/doors.dmi'
	icon_state = "woodhandle"
	max_integrity = 1000
	integrity_failure = 0.5
	sheetType = /obj/item/stack/sheet/mineral/wood
	sheetAmount = 5
	openSound = 'modular_redtard/rockhill/sound/doors/creak.ogg'
	closeSound = 'modular_redtard/rockhill/sound/doors/shut.ogg'
	var/locksound = 'modular_redtard/rockhill/sound/doors/woodlock.ogg'
	var/unlocksound = 'modular_redtard/rockhill/sound/doors/woodlock.ogg'
	var/rattlesound = 'modular_redtard/rockhill/sound/doors/lockrattle.ogg'
	var/base_state
	var/over_state
	var/windowed = FALSE
	var/keylock = FALSE
	var/locked = FALSE
	var/lockid
	var/lockdifficulty = 1
	var/lock_strength = 100
	var/masterkey = TRUE
	var/swing_closed = TRUE
	var/kickthresh = 15
	var/repairable = FALSE
	var/repair_cost_first
	var/repair_cost_second
	/// Ratwood repair_skill: the craft whose rank speeds up mending the door - carpentry for wood, masonry for stone, smithing
	/// for iron bars. One with no rank in it cannot mend the door.
	var/repair_skill
	var/repair_state = 0
	var/grant_resident_key = FALSE
	var/resident_key_amount = 1
	var/resident_key_type = /obj/item/roguekey
	var/resident_role
	var/list/resident_advclass
	var/relock = FALSE
	var/last_bump = 0
	/// Whether a door basher smashes through the door (Ratwood TRAIT_BASHDOORS); a secret door is a wall to them.
	var/bashable = TRUE

/obj/structure/mineral_door/rockhill/Initialize(mapload)
	. = ..()
	if(!base_state)
		base_state = icon_state
	if(grant_resident_key && !lockid)
		lockid = "resident_[REF(src)]"
	if(keylock && !lockhash)
		lockhash = rockhill_lock_hash(lockid)
	if(over_state)
		add_overlay(mutable_appearance(icon, over_state, ABOVE_MOB_LAYER))
	if(door_opened)
		set_density(FALSE)
		set_opacity(FALSE)
		layer = OPEN_DOOR_LAYER
	else
		set_opacity(closed_opacity())
	update_appearance()

/obj/structure/mineral_door/rockhill/update_icon_state()
	. = ..()
	icon_state = broken ? "[base_state]br" : "[base_state][door_opened ? "open" : ""]"

/obj/structure/mineral_door/rockhill/examine(mob/user)
	. = ..()
	if(repairable && repair_cost_first && (broken || atom_integrity < max_integrity))
		var/obj/item/material = (broken && repair_state) ? repair_cost_second : repair_cost_first
		. += span_notice("[initial(material.name)] can be used to repair it.")

/obj/structure/mineral_door/rockhill/proc/closed_opacity()
	return !windowed

/obj/structure/mineral_door/rockhill/Open()
	isSwitchingStates = TRUE
	playsound(src, openSound, 100, TRUE)
	set_opacity(FALSE)
	flick("[base_state]opening", src)
	sleep(0.2 SECONDS)
	set_density(FALSE)
	door_opened = TRUE
	layer = OPEN_DOOR_LAYER
	air_update_turf(TRUE, FALSE)
	update_appearance()
	isSwitchingStates = FALSE
	if(close_delay != -1)
		addtimer(CALLBACK(src, PROC_REF(Close)), close_delay)

/obj/structure/mineral_door/rockhill/Close()
	if(isSwitchingStates || !door_opened)
		return
	for(var/mob/living/blocker in get_turf(src))
		return
	isSwitchingStates = TRUE
	playsound(src, closeSound, 100, TRUE)
	flick("[base_state]closing", src)
	sleep(0.2 SECONDS)
	set_density(TRUE)
	set_opacity(closed_opacity())
	door_opened = FALSE
	layer = initial(layer)
	air_update_turf(TRUE, TRUE)
	update_appearance()
	isSwitchingStates = FALSE
	if(relock)
		relock = FALSE
		locked = TRUE
		playsound(src, locksound, 100)

/obj/structure/mineral_door/rockhill/Bumped(atom/movable/bumper)
	if(door_opened || broken || !ismob(bumper) || world.time < last_bump + 2 SECONDS)
		return
	last_bump = world.time
	var/mob/user = bumper
	if(bashable && HAS_TRAIT(user, TRAIT_BASHDOORS))
		bash(user)
		return
	if(locked)
		var/obj/item/held = user.get_active_held_item()
		if(!held || !rockhill_key_turns(held, lockhash, masterkey))
			rattle()
			return
		toggle_lock(user)
		relock = TRUE
	. = ..()
	if(swing_closed && door_opened)
		addtimer(CALLBACK(src, PROC_REF(Close)), 2.5 SECONDS)

/// Ratwood CanAStarPass(): a door basher plans its way straight through a shut door.
/obj/structure/mineral_door/rockhill/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	. = ..()
	if(. || !bashable)
		return
	var/mob/living/requester = pass_info.requester_ref?.resolve()
	return istype(requester) && HAS_TRAIT(requester, TRAIT_BASHDOORS)

/// Ratwood Bumped() of a door basher (TRAIT_BASHDOORS: the minotaurs here; Ratwood's werewolves, gnolls, zombies, primordials
/// and ifrits once they come): walking into a door smashes it open, a locked one takes a heavy blow instead. Throwing one's
/// weight through a door is no quiet act.
/obj/structure/mineral_door/rockhill/proc/bash(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/basher = user
		basher.rogue_reveal_sneak()
	if(locked)
		user.visible_message(span_warning("[user] bashes into [src]!"))
		user.log_message("bashed into the locked door [src] at [AREACOORD(src)].", LOG_ATTACK)
		take_damage(rogue_value("door_bash_damage"), BRUTE, MELEE, TRUE, get_dir(src, user), ROCKHILL_DOOR_BASH_PENETRATION)
		return
	playsound(src, 'modular_redtard/rockhill/sound/doors/woodimpact.ogg', 100)
	user.visible_message(span_warning("[user] smashes through [src]!"))
	INVOKE_ASYNC(src, PROC_REF(Open))

/// Ratwood attack_hand() on a locked door: one sneaking checks the lock quietly, anyone else knocks.
/obj/structure/mineral_door/rockhill/attack_hand(mob/living/user, list/modifiers)
	if(broken || isSwitchingStates)
		return TRUE
	if(can_claim(user))
		INVOKE_ASYNC(src, PROC_REF(claim_home), user)
		return TRUE
	if(locked)
		var/mob/living/carbon/human/sneaker = user
		if(istype(sneaker) && sneaker.rogue_sneaking)
			to_chat(user, span_warning("This door is locked."))
		else
			knock(user)
		return TRUE
	return ..()

/obj/structure/mineral_door/rockhill/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(isliving(user))
		var/mob/living/living_user = user
		if(living_user.combat_mode)
			kick(living_user)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	secondary_use(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/mineral_door/rockhill/proc/secondary_use(mob/user)
	var/obj/item/key = rockhill_find_lock_key(user, lockhash, masterkey)
	if(key)
		use_key(user, key)
	else if(keylock)
		to_chat(user, span_warning("I don't have the right key for this door."))

/obj/structure/mineral_door/rockhill/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		use_key(user, tool)
		return ITEM_INTERACT_SUCCESS
	if(tool.picklvl)
		INVOKE_ASYNC(src, PROC_REF(pick_lock), user, tool)
		return ITEM_INTERACT_SUCCESS
	if(repairable && (istype(tool, repair_cost_first) || istype(tool, repair_cost_second)))
		INVOKE_ASYNC(src, PROC_REF(repair), user, tool)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/mineral_door/rockhill/pickaxe_door(mob/living/user, obj/item/tool)
	return FALSE

/obj/structure/mineral_door/rockhill/atom_break(damage_flag)
	. = ..()
	if(broken)
		return
	broken = TRUE
	set_density(FALSE)
	set_opacity(FALSE)
	update_appearance()

/obj/structure/mineral_door/rockhill/proc/use_key(mob/user, obj/item/key)
	if(door_opened || isSwitchingStates)
		return
	if(!keylock)
		to_chat(user, span_warning("[src] has no lock."))
		return
	if(!rockhill_key_turns(key, lockhash, masterkey))
		to_chat(user, span_warning("This is not the key to [src]."))
		rattle()
		return
	toggle_lock(user)

/obj/structure/mineral_door/rockhill/proc/toggle_lock(mob/user)
	if(isSwitchingStates || door_opened)
		return
	locked = !locked
	playsound(src, locked ? locksound : unlocksound, 100)
	user?.visible_message(span_warning("[user] [locked ? "locks" : "unlocks"] [src]."), span_notice("I [locked ? "lock" : "unlock"] [src]."))

/obj/structure/mineral_door/rockhill/proc/rattle()
	playsound(src, rattlesound, 100)
	var/start_x = pixel_x
	animate(src, pixel_x = start_x + 1, time = 0.5)
	animate(pixel_x = start_x - 1, time = 0.5)
	animate(pixel_x = start_x, time = 0.5)

/obj/structure/mineral_door/rockhill/proc/knock(mob/user)
	if(world.time < last_bump + 2 SECONDS)
		return
	last_bump = world.time
	playsound(src, 'modular_redtard/rockhill/sound/doors/knocking.ogg', 100)
	user.visible_message(span_warning("[user] knocks on [src]."), span_notice("I knock on [src]."))

/// Ratwood onkick(): a kick slams an open door shut and kicks a shut one open; a locked one opens only when its lock breaks.
/obj/structure/mineral_door/rockhill/proc/kick(mob/living/user)
	if(broken || isSwitchingStates)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src, 'modular_redtard/rockhill/sound/doors/woodimpact.ogg', 100)
	if(door_opened)
		user.visible_message(span_warning("[user] kicks [src] shut!"), span_notice("I kick [src] shut!"))
		INVOKE_ASYNC(src, PROC_REF(Close))
		return
	if(locked && !kick_lock(user))
		user.visible_message(span_warning("[user] kicks [src]!"), span_notice("I kick [src]!"))
		rattle()
		return
	user.visible_message(span_warning("[user] kicks open [src]!"), span_notice("I kick open [src]!"))
	INVOKE_ASYNC(src, PROC_REF(Open))

/// Ratwood onkick() on a locked door: only one at least as strong as the door's kick threshold (15) can break its lock. Each
/// of their kicks wears the lock down; it breaks at a chance of half a percent a point of strength, or once worn through.
/obj/structure/mineral_door/rockhill/proc/kick_lock(mob/living/user)
	var/strength = user.rogue_stat(ROGUE_STAT_STRENGTH)
	if(strength < initial(kickthresh))
		user.log_message("kicked the locked door [src] at [AREACOORD(src)].", LOG_ATTACK)
		return FALSE
	kickthresh--
	if(kickthresh > 0 && !prob(strength * rogue_value("door_kick_chance_per_strength")))
		user.log_message("kicked the locked door [src] at [AREACOORD(src)].", LOG_ATTACK)
		return FALSE
	locked = FALSE
	relock = FALSE
	user.log_message("kicked open the locked door [src] at [AREACOORD(src)].", LOG_ATTACK)
	return TRUE

/// Ratwood repairdoor(): 30 seconds divided by the rank of the door's repair craft; null for one with no rank in it.
/obj/structure/mineral_door/rockhill/proc/repair_time(mob/living/user)
	var/rank = repair_skill ? user.rogue_skill_rank(repair_skill) : 0
	return rank ? rogue_value("door_repair_time") / rank : null

/// What mends the door next: its first material, or its second to finish a broken door half mended.
/obj/structure/mineral_door/rockhill/proc/repair_material()
	return (broken && repair_state) ? repair_cost_second : repair_cost_first

/obj/structure/mineral_door/rockhill/proc/repair(mob/living/user, obj/item/material)
	var/needed = repair_material()
	if(!istype(material, needed))
		var/obj/item/wanted = needed
		to_chat(user, span_warning("I need [initial(wanted.name)] for this."))
		return
	if(!broken && atom_integrity >= max_integrity)
		return
	var/work_time = repair_time(user)
	if(!work_time)
		to_chat(user, span_warning("I don't know how to repair [src]."))
		return
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	user.visible_message(span_notice("[user] starts repairing [src]."), span_notice("I start repairing [src]."))
	playsound(src, 'modular_redtard/rockhill/sound/doors/woodsaw.ogg', 100, TRUE)
	if(!do_after(user, work_time, src) || QDELETED(material) || !user.is_holding(material) || !istype(material, repair_material()))
		return
	if(!broken && atom_integrity >= max_integrity)
		return
	qdel(material)
	playsound(src, 'modular_redtard/rockhill/sound/doors/woodsaw.ogg', 100, TRUE)
	if(!broken)
		repair_damage(max_integrity / 2)
		user.visible_message(span_notice("[user] repairs [src]."), span_notice("I repair [src]."))
		return
	if(!repair_state)
		repair_state = 1
		var/obj/item/second = repair_cost_second
		to_chat(user, span_notice("An additional [initial(second.name)] is needed to finish the job."))
		return
	fix_door()
	user.visible_message(span_notice("[user] repairs [src]."), span_notice("I repair [src]."))

/// A broken door mended whole: shut, unbroken, at full integrity.
/obj/structure/mineral_door/rockhill/proc/fix_door()
	repair_state = 0
	broken = FALSE
	door_opened = FALSE
	layer = initial(layer)
	repair_damage(max_integrity)
	set_density(TRUE)
	set_opacity(closed_opacity())
	update_appearance()

/obj/structure/mineral_door/rockhill/proc/pick_lock(mob/living/user, obj/item/lockpick)
	if(!keylock || broken)
		return
	if(door_opened || isSwitchingStates)
		to_chat(user, span_warning("This cannot be picked while it is open."))
		return
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	if(rockhill_try_pick(user, lockpick, src, lockdifficulty, lock_strength) && !QDELETED(src))
		toggle_lock(user)

/obj/structure/mineral_door/rockhill/proc/can_claim(mob/living/carbon/human/user)
	if(!grant_resident_key || !lockid || !ishuman(user) || user.received_resident_key)
		return FALSE
	var/datum/job/roguetown/job = SSjob.name_occupations[user.job]
	if(resident_role && job?.type != resident_role)
		return FALSE
	if(resident_advclass && !(istype(job) && (job.rockhill_advclass in resident_advclass)))
		return FALSE
	return TRUE

/obj/structure/mineral_door/rockhill/proc/claim_home(mob/living/carbon/human/user)
	if(tgui_alert(user, "Is this my home?", "Home", list("Yes", "No")) != "Yes" || !can_claim(user))
		return
	var/amount = tgui_alert(user, "Have I got a spare key?", "Home", list("Yes", "No")) == "Yes" ? 2 : resident_key_amount
	if(!can_claim(user))
		return
	for(var/i in 1 to amount)
		var/obj/item/roguekey/key = new resident_key_type(get_turf(user))
		key.rockhill_set_lock(lockid, lockhash)
		user.put_in_hands(key)
	user.received_resident_key = TRUE
	grant_resident_key = FALSE
	name = "[user.real_name] the [user.job]'s house"
	to_chat(user, span_notice((amount > 1 ? "They're just where I left them..." : "It's just where I left it...")))

/obj/structure/mineral_door/rockhill/wood
	repair_skill = /datum/attribute/skill/craft/carpentry

/obj/structure/mineral_door/rockhill/wood/Initialize(mapload)
	if(icon_state == "woodhandle" && !base_state)
		if(prob(10))
			icon_state = "wcg"
		else if(prob(10))
			icon_state = "wcr"
	return ..()

/obj/structure/mineral_door/rockhill/swing_door
	repair_skill = /datum/attribute/skill/craft/carpentry

/obj/structure/mineral_door/rockhill/wood/deadbolt
	openSound = 'modular_redtard/rockhill/sound/doors/shittyopen.ogg'
	closeSound = 'modular_redtard/rockhill/sound/doors/shittyclose.ogg'
	var/lockdir

/obj/structure/mineral_door/rockhill/wood/deadbolt/Initialize(mapload)
	. = ..()
	lockdir = dir

/obj/structure/mineral_door/rockhill/wood/deadbolt/secondary_use(mob/user)
	if(keylock)
		return ..()
	if(get_dir(src, user) != lockdir)
		to_chat(user, span_warning("The deadbolt doesn't toggle from this side."))
	else if(!broken)
		toggle_lock(user)

/obj/structure/mineral_door/rockhill/wood/donjon
	locksound = 'modular_redtard/rockhill/sound/doors/lockmetal.ogg'
	unlocksound = 'modular_redtard/rockhill/sound/doors/lockmetal.ogg'
	rattlesound = 'modular_redtard/rockhill/sound/doors/lockrattlemetal.ogg'
	var/has_viewport = TRUE
	var/viewport_open = FALSE

/obj/structure/mineral_door/rockhill/wood/donjon/closed_opacity()
	return ..() && !viewport_open

/obj/structure/mineral_door/rockhill/wood/donjon/click_alt(mob/user)
	if(!has_viewport || door_opened || isSwitchingStates || broken)
		return NONE
	if(get_dir(src, user) != dir)
		to_chat(user, span_warning("The viewport doesn't toggle from this side."))
		return CLICK_ACTION_BLOCKING
	viewport_open = !viewport_open
	set_opacity(closed_opacity())
	playsound(src, 'modular_redtard/rockhill/sound/doors/windowup.ogg', 100, FALSE)
	to_chat(user, span_info("I slide the viewport [viewport_open ? "open" : "closed"]."))
	return CLICK_ACTION_SUCCESS

/obj/structure/mineral_door/rockhill/wood/donjon/stone
	has_viewport = FALSE
	repair_skill = /datum/attribute/skill/craft/masonry

/obj/structure/mineral_door/rockhill/bars
	over_state = "barsopen"
	sheetType = /obj/item/stack/sheet/iron
	openSound = 'modular_redtard/rockhill/sound/doors/ironopen.ogg'
	closeSound = 'modular_redtard/rockhill/sound/doors/ironclose.ogg'
	locksound = 'modular_redtard/rockhill/sound/doors/lock.ogg'
	unlocksound = 'modular_redtard/rockhill/sound/doors/unlock.ogg'
	rattlesound = 'modular_redtard/rockhill/sound/doors/lockrattlemetal.ogg'
	repair_skill = /datum/attribute/skill/craft/blacksmithing

/obj/structure/mineral_door/rockhill/bars/kick(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message(span_warning("[user] kicks [src]!"), span_notice("I kick [src]!"))

// --- Winches and levers (gates.dm, redstone.dm)

/// Ratwood winch attack_hand(): the stronger the hand on the crank, the sooner the gate moves - 105 deciseconds less 10 a point
/// of strength, at once from strength 11 up.
/obj/structure/rockhill/winch/proc/crank_time(mob/living/user)
	return max(rogue_value("winch_time") - user.rogue_stat(ROGUE_STAT_STRENGTH) * rogue_value("winch_time_per_strength"), 0)

/// Ratwood lever attack_hand(): a lever takes 100 deciseconds less 10 a point of strength to pull, the strong pull it at once.
/obj/structure/lever/proc/pull_time(mob/living/user)
	return max(rogue_value("lever_time") - user.rogue_stat(ROGUE_STAT_STRENGTH) * rogue_value("lever_time_per_strength"), 0)

// --- Door bashers

/// A secret door (rockhill/map_helpers.dm) is stone to a door basher: its Bumped() does nothing.
/obj/structure/mineral_door/rockhill/secret
	bashable = FALSE

/// Azure Peak's minotaurs (modular_azurepeak creacher/minotaur.dm, in Ratwood's build) smash through the doors in their way.
/mob/living/simple_animal/hostile/retaliate/rogue/minotaur/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_BASHDOORS, INNATE_TRAIT)

#undef ROCKHILL_DOOR_BASH_PENETRATION
