/// Ratwood's graves (roguejobs/gravedigger/hole.dm, tools.dm). A hole in the dirt goes deeper with each scoop of a shovel
/// - a shallow hole, a deeper one (a weak digger fails a couple of times first), a pit big enough for a coffin - and
/// fills back with each clod thrown in. A clod thrown into a pit with something in it seals a grave over whoever lies
/// there, coffin and all; an empty pit only fills back to a hole. A scoop of an empty shovel opens a grave again: robbing
/// a marked grave curses the robber (-3 fortune for ten minutes) unless they know the trade (TRAIT_GRAVEROBBER), who can
/// also tear a pit out of the earth at once with a strong scoop (burial/digging.dm). A pit dug deeper breaks through to
/// the open ground below unless that place is guarded from above. Someone dragged onto a pit is laid in it; someone
/// buried alive claws their way out in 25 seconds. The old graves of the map (closed/loot) hold bones, and one in four a
/// restless skeleton, one in four a chest. The winding sheet unfolds to wrap a body and folds back up.
/// The holes are TG crates under the porter's rockhill crate base: their own open() and close() keep Ratwood's - no lock,
/// no sound, no density - and they are neither climbed, nor broken, nor taken apart for wood.
/// Not ported: Necra's burial rites at a grave (TRAIT_SOUL_EXAMINE, the luxthread - with the faiths), the raised mound a
/// closed grave puts its stander on (Ratwood climb_offset).

/area/rogue
	/// Nobody digs into this place from above (Ratwood ceiling_protected).
	var/rogue_ceiling_protected = FALSE

/area/rogue/under/cave/goblinfort
	rogue_ceiling_protected = TRUE

/area/rogue/under/dungeon
	rogue_ceiling_protected = TRUE

/obj/structure/closet/crate/wooden/rockhill/dirthole
	opened = TRUE
	anchored = TRUE
	anchorable = FALSE
	horizontal = FALSE
	allow_objects = FALSE
	allow_dense = TRUE
	dense_when_open = FALSE
	mob_storage_capacity = 3
	buckle_lying = 90
	elevation = 0
	elevation_open = 0
	resistance_flags = INDESTRUCTIBLE
	material_drop = null
	material_drop_amount = 0
	custom_materials = null
	cutting_tool = null
	delivery_icon = null
	can_weld_shut = FALSE
	can_install_electronics = FALSE
	enable_door_overlay = FALSE
	divable = FALSE
	/// How deep it is (Ratwood stage): ROGUE_HOLE_SHALLOW to ROGUE_HOLE_PIT, ROGUE_HOLE_GRAVE when filled over something.
	var/rogue_stage = ROGUE_HOLE_SHALLOW
	/// Scoops that came up with nothing (Ratwood faildirt): after dig_free_fails of them the hole deepens with every scoop.
	var/rogue_faildirt = 0

/obj/structure/closet/crate/wooden/rockhill/dirthole/grave
	rogue_stage = ROGUE_HOLE_PIT
	rogue_faildirt = 3

/obj/structure/closet/crate/wooden/rockhill/dirthole/closed
	opened = FALSE
	rogue_stage = ROGUE_HOLE_GRAVE
	rogue_faildirt = 3

/obj/structure/closet/crate/wooden/rockhill/dirthole/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	qdel(GetComponent(/datum/component/soapbox))
	rogue_turn_up_finds()
	rogue_update_look()

/// Ratwood dirthole Initialize(): digging turns things up - bait and clay out of mud, stones and clay out of dirt.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_turn_up_finds()
	var/turf/open/floor/rogue/dirt/ground = loc
	if(!istype(ground))
		return
	if(ground.rogue_muddy)
		if(prob(rogue_value("hole_bait_chance")))
			if(prob(rogue_value("hole_leech_chance")))
				if(prob(rogue_value("hole_grubs_chance")))
					new /obj/item/natural/worms/grubs(ground)
				else
					new /obj/item/natural/worms/leech(ground)
			else
				new /obj/item/natural/worms(ground)
		if(prob(rogue_value("hole_mud_clay_chance")))
			new /obj/item/natural/clay(ground)
		return
	if(prob(rogue_value("hole_stone_chance")))
		new /obj/item/natural/stone(ground)
	if(prob(rogue_value("hole_clay_chance")))
		new /obj/item/natural/clay(ground)

/// A covered grave (Ratwood stage 4), as the grave marker's recipe wants it.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_grave_covered()
	return rogue_stage == ROGUE_HOLE_GRAVE

/// Ratwood update_icon(): a pit takes the one who lies in it.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_update_look()
	can_buckle = rogue_stage == ROGUE_HOLE_PIT
	update_appearance()

/obj/structure/closet/crate/wooden/rockhill/dirthole/update_name(updates)
	. = ..()
	switch(rogue_stage)
		if(ROGUE_HOLE_PIT)
			name = "pit"
		if(ROGUE_HOLE_GRAVE)
			name = "grave"
		else
			name = "hole"

/obj/structure/closet/crate/wooden/rockhill/dirthole/update_icon_state()
	. = ..()
	switch(rogue_stage)
		if(ROGUE_HOLE_SHALLOW)
			icon_state = "hole1"
		if(ROGUE_HOLE_DEEP)
			icon_state = "hole2"
		if(ROGUE_HOLE_PIT)
			icon_state = "grave"
		else
			icon_state = "gravecovered"

/// The hole keeps its own layer, under what lies on it, open or closed.
/obj/structure/closet/crate/wooden/rockhill/dirthole/update_icon(updates = ALL)
	. = ..()
	layer = initial(layer)

/// Ratwood update_abovemob(): the edge of the pit over whoever lies in it. No lid, no lock.
/obj/structure/closet/crate/wooden/rockhill/dirthole/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(rogue_stage == ROGUE_HOLE_PIT && has_buckled_mobs())
		. += mutable_appearance(icon, "grave_above", ABOVE_MOB_LAYER)

/obj/structure/closet/crate/wooden/rockhill/dirthole/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/closet/crate/wooden/rockhill/dirthole/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood toggle(): a hole is not opened and closed by hand - only by the shovel.
/obj/structure/closet/crate/wooden/rockhill/dirthole/toggle(mob/living/user)
	return FALSE

/// Nothing walks out of a covered grave.
/obj/structure/closet/crate/wooden/rockhill/dirthole/Exit(atom/movable/leaving, direction)
	return opened

/// Ratwood closet relaymove(): one buried tries to walk and finds the earth all around; resisting claws out.
/obj/structure/closet/crate/wooden/rockhill/dirthole/relaymove(mob/living/user, direction)
	if(opened || message_cooldown > world.time)
		return
	message_cooldown = world.time + 5 SECONDS
	to_chat(user, span_warning("I'm trapped!"))

/// A knock opens locks, not the earth.
/obj/structure/closet/crate/wooden/rockhill/dirthole/on_magic_unlock(datum/source, datum/action/cooldown/spell/aoe/knock/spell, atom/caster)
	SIGNAL_HANDLER
	return

/// Ratwood dirthole open(): no lock, no sound - the earth just gives up what it held.
/obj/structure/closet/crate/wooden/rockhill/dirthole/open(mob/living/user, force = FALSE, special_effects = TRUE)
	if(opened)
		return FALSE
	opened = TRUE
	dump_contents()
	rogue_update_look()
	SEND_SIGNAL(src, COMSIG_CLOSET_POST_OPEN, user, force)
	return TRUE

/// Ratwood dirthole close(): the earth closes over what lies in the pit, coffins with it; who is not awake is buried.
/obj/structure/closet/crate/wooden/rockhill/dirthole/close(mob/living/user)
	if(!opened)
		return FALSE
	unbuckle_all_mobs(force = TRUE)
	take_contents()
	for(var/mob/living/carbon/human/sleeper in contents)
		if(sleeper.stat != STABLE || HAS_TRAIT(sleeper, TRAIT_KNOCKEDOUT))
			sleeper.rogue_buried = TRUE
	for(var/obj/structure/closet/crate/wooden/rockhill/crate/coffin/coffin in contents)
		for(var/mob/living/carbon/human/sleeper in coffin)
			sleeper.rogue_buried = TRUE
	for(var/mob/living/interred as anything in rogue_interred_mobs())
		if(user)
			log_combat(user, interred, "buried", src, "([interred.stat == DEAD ? "DEAD" : "ALIVE"])")
		else
			interred.log_message("was buried in [src] ([interred.stat == DEAD ? "DEAD" : "ALIVE"])", LOG_ATTACK)
	opened = FALSE
	rogue_update_look()
	SEND_SIGNAL(src, COMSIG_CLOSET_POST_CLOSE, user)
	return TRUE

/// Ratwood dirthole dump_contents(): who climbs out awake is no longer buried.
/obj/structure/closet/crate/wooden/rockhill/dirthole/dump_contents()
	for(var/mob/living/carbon/human/risen in contents)
		if(risen.stat == STABLE && !HAS_TRAIT(risen, TRAIT_KNOCKEDOUT))
			risen.rogue_buried = FALSE
	return ..()

/// Ratwood dirthole insertion_allowed(): a coffin or a winding sheet goes into the grave, though not beside a body nor
/// beside anything but a coffin; a body does not go in beside a coffin or a chest.
/obj/structure/closet/crate/wooden/rockhill/dirthole/insertion_allowed(atom/movable/AM)
	if(istype(AM, /obj/structure/closet/crate/wooden/rockhill/crate/coffin) || istype(AM, /obj/structure/closet/crate/wooden/rockhill/burial_shroud))
		if(locate(/mob/living) in contents)
			return FALSE
		var/obj/structure/closet/inside = locate(/obj/structure/closet) in contents
		return !inside || istype(inside, /obj/structure/closet/crate/wooden/rockhill/crate/coffin)
	if(isliving(AM) && (locate(/obj/structure/closet/crate/wooden/rockhill/crate) in contents))
		return FALSE
	return ..()

/// Ratwood get_interred_mobs(): everyone in the grave, in a coffin or a sheet too.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_interred_mobs()
	. = list()
	for(var/mob/living/interred in contents)
		. += interred
	for(var/obj/structure/closet/inner in contents)
		for(var/mob/living/interred in inner)
			. += interred

/// Ratwood get_interment_manifest(): who is in the grave, for the logs.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_interment_manifest()
	. = list()
	for(var/mob/living/interred as anything in rogue_interred_mobs())
		. += "[key_name(interred)] ([interred.stat == DEAD ? "DEAD" : "ALIVE"])"

/obj/structure/closet/crate/wooden/rockhill/dirthole/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/rogueweapon/shovel/shovel = tool
	if(!istype(shovel))
		return ..()
	if(!istype(user.rogue_active_intent(), /datum/intent/shovelscoop))
		return ITEM_INTERACT_BLOCKING
	var/datum/intent/scoop = user.rogue_active_intent()
	user.changeNext_move(scoop.clickcd)
	rogue_shovel(shovel, user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood dirthole attackby() with the shovel's scoop: a clod on the blade fills the hole (seals a pit with something in
/// it into a grave), an empty blade digs it deeper (opens a grave again) and comes up with a clod.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_shovel(obj/item/rogueweapon/shovel/shovel, mob/living/user)
	if(shovel.rogue_clod)
		playsound(loc, ROGUE_BURIAL_EMPTY_SOUND, 100, TRUE)
		shovel.rogue_lose_clod()
		if(rogue_stage == ROGUE_HOLE_PIT)
			rogue_stage = ROGUE_HOLE_GRAVE
			locked = TRUE
			close(user)
			if(!length(contents))
				rogue_stage = ROGUE_HOLE_DEEP
				locked = FALSE
				open()
			else
				user.log_message("sealed a grave with [shovel] (INTERRED: [english_list(rogue_interment_manifest(), "nobody")]) (CONTENTS: [english_list(contents)])", LOG_GAME)
		else if(rogue_stage < ROGUE_HOLE_GRAVE)
			rogue_stage--
			user.log_message("filled in [src] with [shovel] (STAGE: [rogue_stage])", LOG_GAME)
			if(rogue_stage <= 0)
				qdel(src)
				return
		rogue_update_look()
		return
	if(rogue_stage == ROGUE_HOLE_PIT)
		if(!rogue_dig_through(shovel, user))
			to_chat(user, span_warning("I can't dig myself any deeper."))
		return
	var/strength = user.rogue_stat(ROGUE_STAT_STRENGTH)
	user.adjust_stamina_loss(max(rogue_value("dig_fatigue") - strength * rogue_value("dig_fatigue_per_strength"), 1))
	if(rogue_stage < ROGUE_HOLE_PIT)
		if(rogue_faildirt < rogue_value("dig_free_fails"))
			if(prob(strength * rogue_value("dig_chance_per_strength")))
				rogue_stage++
			else
				rogue_faildirt++
		else
			rogue_stage++
	if(rogue_stage == ROGUE_HOLE_GRAVE)
		rogue_exhume(shovel, user)
	rogue_update_look()
	shovel.rogue_take_clod()
	playsound(loc, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)

/// Ratwood: an empty shovel opens a grave again; robbing a marked grave angers Necra.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_exhume(obj/item/shovel, mob/living/user)
	rogue_stage = ROGUE_HOLE_PIT
	locked = FALSE
	var/list/manifest = rogue_interment_manifest()
	open()
	user.log_message("exhumed a grave with [shovel] (INTERRED: [english_list(manifest, "nobody")])", LOG_GAME)
	for(var/obj/structure/gravemarker/marker in loc)
		user.log_message("robbed a marked grave (destroying [marker])", LOG_ATTACK)
		qdel(marker)
		if(!HAS_TRAIT(user, TRAIT_GRAVEROBBER))
			user.apply_status_effect(/datum/status_effect/rogue_grave_curse)

/// Ratwood: a pit dug deeper gives way to the open ground below, unless that place is guarded from above.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_dig_through(obj/item/rogueweapon/shovel/shovel, mob/living/user)
	var/turf/open/floor/rogue/dirt/ground = loc
	if(!istype(ground))
		return FALSE
	var/turf/below = GET_TURF_BELOW(ground)
	if(!isopenturf(below))
		return FALSE
	var/area/rogue/below_area = below.loc
	if(istype(below_area) && below_area.rogue_ceiling_protected)
		return FALSE
	shovel.rogue_take_clod()
	playsound(ground, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)
	user.log_message("dug [src] through the floor into the z-level below with [shovel]", LOG_GAME)
	qdel(src)
	ground.ChangeTurf(/turf/open/openspace/rockhill, flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/// Ratwood dirthole container_resist_act(): buried, one claws at the dirt; a covered grave lets nobody out otherwise.
/obj/structure/closet/crate/wooden/rockhill/dirthole/container_resist_act(mob/living/user, loc_required = TRUE)
	if(opened || rogue_stage != ROGUE_HOLE_GRAVE || DOING_INTERACTION_WITH_TARGET(user, src))
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_claw_out), user)

/// Ratwood: like that scene from Kill Bill - fifteen seconds to break the surface with a hand, ten more to climb out.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_claw_out(mob/living/user)
	if(!user.has_hand_for_held_index(user.active_hand_index))
		to_chat(user, span_warning("I can't dig out of here, I can't move my hand!"))
		return
	var/mob/living/carbon/stuck = user
	if(istype(stuck) && stuck.handcuffed)
		to_chat(user, span_warning("I can't dig out of here, I'm handcuffed!"))
		return
	to_chat(user, span_warning("I start clawing at the dirt for a way out!"))
	playsound(src, 'modular_redtard/burial/sound/climb.ogg', 100, TRUE)
	if(!do_after(user, rogue_value("grave_claw_time"), target = src) || !rogue_holds(user))
		return
	user.visible_message(span_alert("A hand bursts from [src]!"), span_alert("I've managed to penetrate the surface of [src] with my hand!"))
	playsound(src, 'modular_redtard/burial/sound/plantcross1.ogg', 100, TRUE)
	if(!do_after(user, rogue_value("grave_climb_time"), target = src) || !rogue_holds(user))
		return
	rogue_stage--
	open()
	playsound(src, 'modular_redtard/burial/sound/breaksound.ogg', 100, TRUE)
	playsound(src, 'modular_redtard/burial/sound/bodyfall.ogg', 90, TRUE)
	user.visible_message(span_warning("[user] emerges from [src]!"), span_alert("I emerge from [src]!"))
	user.log_message("clawed their way out of [src]", LOG_ATTACK)

/// Whether this covered grave still holds them.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_holds(mob/living/user)
	return !QDELETED(src) && !opened && rogue_stage == ROGUE_HOLE_GRAVE && user.loc == src

/// Ratwood dirthole MouseDrop_T(): a coffin dragged onto the hole goes onto it; someone dragged onto it is laid in the pit
/// (four seconds), a thing drops into it.
/obj/structure/closet/crate/wooden/rockhill/dirthole/mouse_drop_receive(atom/movable/dropped, mob/living/user, params)
	if(!istype(dropped) || !istype(user) || dropped == user || istype(dropped, /atom/movable/screen))
		return
	if(user.incapacitated || user.body_position == LYING_DOWN || !Adjacent(user) || !user.Adjacent(dropped))
		return
	if(dropped.anchored)
		return
	if(istype(dropped, /obj/structure/closet/crate/wooden/rockhill/crate/coffin))
		dropped.forceMove(loc)
		return
	if(!opened || !isturf(dropped.loc))
		return
	if(isliving(dropped))
		INVOKE_ASYNC(src, PROC_REF(rogue_lay_in), dropped, user)
		return
	if(isitem(dropped))
		dropped.forceMove(loc)

/// Ratwood: someone stuffed into a hole lies in it - in a pit, laid down in it.
/obj/structure/closet/crate/wooden/rockhill/dirthole/proc/rogue_lay_in(mob/living/stuffed, mob/living/user)
	add_fingerprint(user)
	user.visible_message(
		span_warning("[user] tries to stuff [stuffed] into [src]."),
		span_warning("I try to stuff [stuffed] into [src]."),
		span_hear("I hear clanging."),
	)
	if(!do_after(user, rogue_value("hole_stuff_time"), stuffed) || QDELETED(src) || !opened || !isturf(stuffed.loc))
		return
	user.visible_message(
		span_notice("[user] stuffs [stuffed] into [src]."),
		span_notice("I stuff [stuffed] into [src]."),
		span_hear("I hear a loud bang."),
	)
	log_combat(user, stuffed, "stuffed into [src]", addition = "(STAGE: [rogue_stage]) ([stuffed.stat == DEAD ? "DEAD" : "ALIVE"])")
	stuffed.forceMove(loc)
	user_buckle_mob(stuffed, user)

/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot
	/// What lies under the old grave besides bones (Ratwood lootroll): 1 a restless skeleton, 2 a chest.
	var/rogue_lootroll = 0
	/// Opened once already (Ratwood hole_looted).
	var/rogue_looted = FALSE

/// Ratwood lootroll = rand(1, 4): one old grave in four holds a skeleton, one a chest.
/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot/Initialize(mapload)
	. = ..()
	var/roll = rand(1, 100)
	if(roll <= rogue_value("grave_skeleton_chance"))
		rogue_lootroll = 1
	else if(roll <= rogue_value("grave_skeleton_chance") + rogue_value("grave_chest_chance"))
		rogue_lootroll = 2

/// Ratwood closed/loot open(): an old grave gives up its bones, and maybe a restless skeleton or a chest.
/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot/open(mob/living/user, force = FALSE, special_effects = TRUE)
	if(!opened && !rogue_looted)
		rogue_looted = TRUE
		new /obj/item/natural/bundle/bone/full(src)
		switch(rogue_lootroll)
			if(1)
				rogue_raise_sleeper()
			if(2)
				new /obj/structure/closet/crate/wooden/rockhill/crate/chest/lootbox(loc)
	return ..()

/// Ratwood's sleeper of the old grave rises: its skeleton, once the porter has brought it (it is no NPC before).
/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot/proc/rogue_raise_sleeper()
	var/mob/living/carbon/human/sleeper = /mob/living/carbon/human/species/skeleton/npc
	if(initial(sleeper.rogue_npc))
		new sleeper(loc)

/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot/examine(mob/user)
	. = ..()
	if(rogue_lootroll == 1 && HAS_TRAIT(user, TRAIT_SOUL_EXAMINE))
		. += span_warning("Better let this one sleep.")

/// Ratwood debuff/cursed: Necra's curse on who robs a marked grave.
/datum/status_effect/rogue_grave_curse
	id = "rogue_grave_curse"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/rogue_grave_curse

/datum/status_effect/rogue_grave_curse/on_creation(mob/living/new_owner, ...)
	duration = rogue_value("grave_curse_time")
	return ..()

/// Robbing another grave starts the curse over.
/datum/status_effect/rogue_grave_curse/refresh(effect, ...)
	duration = rogue_value("grave_curse_time")

/datum/status_effect/rogue_grave_curse/on_apply()
	owner.attributes?.set_variable_attribute_modifier(id, list(ROGUE_STAT_FORTUNE = -rogue_value("grave_curse_fortune")))
	return TRUE

/datum/status_effect/rogue_grave_curse/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	return ..()

/atom/movable/screen/alert/status_effect/rogue_grave_curse
	name = "Cursed"
	desc = "I feel... unlucky."
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "debuff"

// --- The winding sheet

/obj/item/burial_shroud
	/// What the sheet unfolds into (Ratwood unfoldedbag_path).
	var/unfoldedbag_path = /obj/structure/closet/crate/wooden/rockhill/burial_shroud

/// Ratwood burial_shroud attack_self(): unfolds where one stands.
/obj/item/burial_shroud/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !isturf(user.loc))
		return
	rogue_unfold(user, user.loc)
	return TRUE

/// Ratwood burial_shroud afterattack(): unfolds on the ground it is put to.
/obj/item/burial_shroud/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isopenturf(interacting_with))
		return ..()
	rogue_unfold(user, interacting_with)
	return ITEM_INTERACT_SUCCESS

/// Ratwood deploy_bodybag(): the sheet is spread open; the folded one waits out of the world to be folded back.
/obj/item/burial_shroud/proc/rogue_unfold(mob/user, atom/location)
	var/obj/structure/closet/crate/wooden/rockhill/burial_shroud/sheet = new unfoldedbag_path(location)
	sheet.open(user, force = TRUE, special_effects = FALSE)
	sheet.add_fingerprint(user)
	sheet.foldedbag_instance = src
	moveToNullspace()

/obj/structure/closet/crate/wooden/rockhill/burial_shroud
	mob_storage_capacity = 1
	anchorable = FALSE
	delivery_icon = null
	dense_when_open = FALSE
	elevation = 0
	elevation_open = 0
	material_drop = null
	material_drop_amount = 0
	custom_materials = null
	cutting_tool = null
	can_weld_shut = FALSE
	can_install_electronics = FALSE
	enable_door_overlay = FALSE
	divable = FALSE
	/// The folded sheet it came from, kept out of the world to fold back into (Ratwood foldedbag_instance).
	var/obj/item/burial_shroud/foldedbag_instance
	/// What it folds into when it came from none (Ratwood foldedbag_path).
	var/foldedbag_path = /obj/item/burial_shroud

/obj/structure/closet/crate/wooden/rockhill/burial_shroud/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/climbable, climb_time = crate_climb_time, climb_stun = 0)
	qdel(GetComponent(/datum/component/soapbox))

/obj/structure/closet/crate/wooden/rockhill/burial_shroud/Destroy()
	if(foldedbag_instance && !foldedbag_instance.loc)
		qdel(foldedbag_instance)
	foldedbag_instance = null
	return ..()

/// Ratwood: the sheet lies on the ground, open or wrapped ("shroud"); spread open it shows its folds ("shroud_open").
/obj/structure/closet/crate/wooden/rockhill/burial_shroud/update_icon_state()
	. = ..()
	icon_state = "shroud"

/obj/structure/closet/crate/wooden/rockhill/burial_shroud/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(opened)
		. += "shroud_open"

/// A sheet is no crate: opening it does not make it a step to climb.
/obj/structure/closet/crate/wooden/rockhill/burial_shroud/after_open(mob/living/user, force = FALSE)
	return

/// Ratwood burial_shroud close(): wrapped, the sheet still lies flat.
/obj/structure/closet/crate/wooden/rockhill/burial_shroud/after_close(mob/living/user)
	set_density(FALSE)

/// Ratwood burial_shroud MouseDrop(): dragged onto oneself, an empty sheet folds back up.
/obj/structure/closet/crate/wooden/rockhill/burial_shroud/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(over != user || !ishuman(user))
		return
	if(length(contents))
		to_chat(user, span_warning("There are too many things inside of [src] to fold it up!"))
		return
	visible_message(span_notice("[user] folds up [src]."))
	var/obj/item/burial_shroud/folded = foldedbag_instance || new foldedbag_path
	foldedbag_instance = null
	user.put_in_hands(folded)
	qdel(src)
