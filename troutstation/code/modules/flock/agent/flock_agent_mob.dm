#define FLOCK_AGENT_TCOMMS_HEAL_RANGE 5
#define FLOCK_AGENT_TCOMMS_HEAL_ALERT_CATEGORY "flock_tcomms_heal"
#define FLOCK_AGENT_TCOMMS_HEAL_RATE 5
#define FLOCK_AGENT_REVIVAL_COST 400
#define FLOCK_AGENT_REVIVAL_TIME 20 SECONDS

/mob/living/basic/flock/agent
	name = "odd avian construct"
	desc = "Light flickers through traced lines in its smooth, glassy body."
	icon_state = "agent"
	icon_living = "agent"
	icon_dead = "agent_dead"
	maxHealth = 150
	health = 150
	speed = 0.4
	unique_name = FALSE // we get a REAL name in init
	hud_type = /datum/hud/flock_agent
	death_message = "hits the ground and cracks, its desperate caws fading as its lights dim."
	basic_mob_flags = FLAMMABLE_MOB // how else are we going to show off our fire extinguisher
	fire_stack_decay_rate = -0.05
	max_stamina = 100
	stamina_crit_threshold = 100
	max_stamina_slowdown = 3

	// not very good punching technology, but metal's in there
	// still a very bad idea
	attack_sound = 'troutstation/sound/effects/flock/flock_peck.ogg'
	melee_damage_lower = 5
	melee_damage_upper = 10

	/// Headwear slot
	var/obj/item/head
	/// Internal slot
	var/obj/item/internal_storage

	/// Are we currently trying to consume whatever's in our internal slot?
	var/eat_mode = FALSE
	/// How much longer will it be until our thing is eaten?
	var/eat_time_remaining = 0
	/// Cache of the initial eat time for this item for integrity updates
	var/total_eat_time = 0
	/// Are we currently making something?
	var/is_creating = FALSE
	/// Our current resources
	var/resources = 0

	/// Intrinsic radiodive ability
	var/datum/action/cooldown/spell/jaunt/radiodive/radiodive
	/// Intrinsic squawk ability
	var/datum/action/cooldown/mob_cooldown/flock_squawk/squawk
	/// Intrinsic narrowbeam ability
	var/datum/action/cooldown/mob_cooldown/flock_narrowbeam/narrowbeam
	/// Have we started our self-extinguishing process?
	var/extinguishing = FALSE
	/// Are we healing from tcomms presence?
	var/telecomms_healing = FALSE

	// Visuals
	/// All our managed overlays
	var/list/agent_overlays[FLOCK_AGENT_TOTAL_LAYERS]
	/// Hat offsets (different for each direction)
	var/static/alist/hat_offsets = alist(
		SOUTH = list(0, -4),
		NORTH = list(0, -4),
		EAST = list(3, -4),
		WEST = list(-3, -4),
	)
	/// Held item offsets for left hand
	var/static/alist/left_hand_offsets = alist(
		SOUTH = list(2, -1),
		NORTH = list(-2, -1),
		EAST = list(6, -1),
		WEST = list(-7, -1),
	)
	/// Held item offsets for right hand
	var/static/alist/right_hand_offsets = alist(
		SOUTH = list(-2, -1),
		NORTH = list(2, -1),
		EAST = list(7, -1),
		WEST = list(-6, -1),
	)
	/// Offsets of all our gear (head, hands, god knows what else)
	var/list/gear_offsets = list(
		"hat" = list(0, -4), // use the SOUTH offset by default
		"left_hand" = list(3, -1),
		"right_hand" = list(-3, -1)
	)

/mob/living/basic/flock/agent/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dextrous, hud_type = hud_type, can_throw = TRUE)
	AddComponent(/datum/component/personal_crafting, screen_loc_override = ui_flock_crafting)
	AddComponentFrom(SPECIES_TRAIT, /datum/component/radio_source_vision)
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_CAN_STRIP), SPECIES_TRAIT)
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(src, COMSIG_LIVING_IGNITED, PROC_REF(on_ignited))
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))

	// as creatures of radio they should be allowed to hear all the radios
	var/obj/item/implant/radio/flock/internal_radio = new(src)
	internal_radio.implant(src, null, TRUE, TRUE)

	radiodive = new(src)
	radiodive.Grant(src)
	squawk = new(src)
	squawk.Grant(src)
	narrowbeam = new(src)
	narrowbeam.Grant(src)

	fully_replace_character_name(null, generate_flock_name("CV.CV.CV"))

/mob/living/basic/flock/agent/can_use_guns(obj/item/gun)
	if(HAS_TRAIT(gun, TRAIT_FLOCKISH_ITEM))
		return TRUE
	else
		if(gun.trigger_guard != TRIGGER_GUARD_ALLOW_ALL)
			to_chat(src, span_warning("Your manipulators barely work with the <b>grip</b>, you <b>definitely</b> can't get them into the trigger guard!"))
			return FALSE

/mob/living/basic/flock/agent/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(istype(user, /mob/living/basic/flock/agent) && stat == DEAD)
		if(tgui_alert(user, "Do you want to try reviving this agent? It'll take time, make sure they're in a safe place first.", "Flock Agent Salvation", list("Yes", "No")) == "Yes")
			var/mob/living/basic/flock/agent/saviour = user
			saviour.revive_agent(src)

/mob/living/basic/flock/agent/proc/revive_agent(mob/living/basic/flock/agent/target)
	if(!target || target.stat > DEAD)
		return
	var/revival_cost = FLOCK_AGENT_REVIVAL_COST
	var/revival_time = FLOCK_AGENT_REVIVAL_TIME
	if(resources < revival_cost)
		to_chat(src, span_warning("You don't have enough raw substrate to revive [target.p_them()], you need [revival_cost] units."))
		return
	resources -= revival_cost
	SEND_SIGNAL(src, COMSIG_FLOCK_RESOURCES_CHANGED, resources, -revival_cost)
	visible_message(span_notice("[src] leans over [target] and places [src.p_their()] manipulators on [target]'s lifeless head and body as glassy fluid flows from one to the other."),
		span_notice("You lean over [target] and place your manipulators in the best places for substrate transfer. <b>This will take about [DisplayTimeText(revival_time)], and will cost you resources if you are disrupted.</b>"),
		span_notice("You hear a soft clasp of metal and glass."))
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_repair_TEMP.ogg', 50, TRUE)
	if(!do_after(src, revival_time, target = target))
		to_chat(src, span_boldwarning("You were interrupted! Your resources have been only partially refunded."))
		resources += revival_cost/2
		SEND_SIGNAL(src, COMSIG_FLOCK_RESOURCES_CHANGED, resources, revival_cost/2)
		return
	target.maxHealth = initial(target.maxHealth)
	target.revive(HEAL_ALL)
	target.flock_talk("restored", system = TRUE)
	target.emote("scream", forced=TRUE)
	target.visible_message(span_notice("[src] staggers up, fully restored! The last of the glassy fluid sinks into [src.p_their()] body."),
		span_notice("You stagger up, cracks mended, light and warmth flooding into your circuits and vessels. <b>[src] has returned you to function!!</b>"),
		span_notice("You hear a glassy creature stagger about, unsteady in gait."))


/mob/living/basic/flock/agent/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(isnull(new_dir))
		return
	gear_offsets["hat"] = hat_offsets[new_dir]
	gear_offsets["left_hand"] = left_hand_offsets[new_dir]
	gear_offsets["right_hand"] = right_hand_offsets[new_dir]
	update_worn_head()
	update_held_items()

/mob/living/basic/flock/agent/proc/on_ignited(datum/source)
	SIGNAL_HANDLER
	// do automatic extinguish process
	var/datum/status_effect/fire_handler/fire_stacks/fire_status = has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
	// don't check if we're conscious, this is an autonomous process
	if(fire_status && !extinguishing)
		extinguishing = TRUE
		to_chat(src, span_boldwarning("Fire detected in multiple systems. Integrated extinguishing systems are engaging."))
		playsound(get_turf(src), 'sound/effects/bubbles/bubbles2.ogg', 50, TRUE, -3)
		addtimer(CALLBACK(src, PROC_REF(do_self_extinguish)), 5 SECONDS)

// doing this as a signal handler to mesh up with dextrous component's examine stuff
/mob/living/basic/flock/agent/proc/on_examined(mob/living/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(head)
		examine_list += span_info("[examined.p_They()] [examined.p_are()] wearing [head.examine_title(user)] \
			on [examined.p_their()] head.")
	if(internal_storage)
		examine_list += span_info("[examined.p_They()] [examined.p_are()] holding something inside \
			[examined.p_their()] body, but you can't tell what.")
	if(eat_mode)
		examine_list += span_info("[examined.p_They()] [examined.p_are()] glowing faintly from within. \
			[internal_storage ? "Whatever's in [examined.p_their()] body appears to be violently shaking." : ""]")
	if(stat)
		return
	// todo: add crit/repair process messages
	if(health != maxHealth)
		if(health > maxHealth * 0.5)
			examine_list += span_warning("[examined.p_They()] [examined.p_are()] a bit dented and cracked in places.")
		else
			examine_list += span_boldwarning("[examined.p_They()] [examined.p_are()] severely cracked and leaking glowing fluid!")
	if(!client && stat != DEAD)
		examine_list += "[examined.p_They()] [examined.p_are()] staring vacantly off into the distance."
	if(isflock(examined) && stat == DEAD)
		examine_list += span_boldnotice("You could revive them by clicking on them if you have enough resources.")

/mob/living/basic/flock/agent/proc/on_take_damage(datum/source, damage, damagetype, def_zone, ...)
	SIGNAL_HANDLER
	update_damage_overlays()

/mob/living/basic/flock/agent/proc/do_self_extinguish()
	var/turf/our_turf = get_turf(src)
	to_chat(src, span_boldnotice("Extinguisher online."))
	visible_message(span_warning("[src] abruptly and violently foams up!"),
		span_notice("You feel firefoam bubbling up with force from your seams. [prob(20) ? "It tickles a bit." : ""]"),
		span_notice("You hear a vigorous and forceful frothing."))
	playsound(our_turf, 'sound/effects/extinguish.ogg', 75, TRUE, -3)
	new /obj/effect/particle_effect/fluid/foam/firefighting(our_turf)
	src.extinguish_mob()
	extinguishing = FALSE

/mob/living/basic/flock/agent/getarmor(def_zone, type)
	var/armorval = 0

	if(head) // should have worn a helmet
		armorval = head.get_armor_rating(type)
	return armorval

/mob/living/basic/flock/agent/Life(seconds_per_tick)
	. = ..()

	// todo: componentize this?
	// healed by nearby presence to telecomms equipment
	var/near_telecomms = FALSE
	for(var/obj/machinery/telecomms/tcomms in GLOB.telecomm_machines)
		if(!tcomms.on)
			continue
		if(!isturf(tcomms.loc) || !(is_station_level(tcomms.z) || is_mining_level(tcomms.z) || tcomms.z == src.z))
			continue
		if(!IN_GIVEN_RANGE(src, tcomms, FLOCK_AGENT_TCOMMS_HEAL_RANGE))
			continue
		// do we have line of sight to this machine?
		if(can_see(tcomms, src, FLOCK_AGENT_TCOMMS_HEAL_RANGE)) // yes, that's if the machine can see us, we're checking for its radio waves
			near_telecomms = TRUE
			break

	if(!telecomms_healing && near_telecomms)
		// start healing
		telecomms_healing = TRUE
		throw_alert(FLOCK_AGENT_TCOMMS_HEAL_ALERT_CATEGORY, /atom/movable/screen/alert/flock_tcomm_healing)
	if(telecomms_healing)
		if(!near_telecomms)
			// end healing
			telecomms_healing = FALSE
			clear_alert(FLOCK_AGENT_TCOMMS_HEAL_ALERT_CATEGORY)
		else
			adjust_brute_loss(-FLOCK_AGENT_TCOMMS_HEAL_RATE * seconds_per_tick, updating_health = FALSE)
			adjust_fire_loss(-FLOCK_AGENT_TCOMMS_HEAL_RATE * seconds_per_tick, updating_health = FALSE)
			updatehealth()
			update_damage_overlays()

	// eat items
	if(eat_mode && internal_storage)
		internal_storage.SpinAnimation(speed = eat_time_remaining, parallel = FALSE)
		eat_time_remaining -= seconds_per_tick
		internal_storage.update_integrity(floor(internal_storage.max_integrity * (eat_time_remaining/total_eat_time)))
		if(eat_time_remaining <= 0)
			var/new_resources = get_flock_item_resources(internal_storage)
			resources += new_resources
			SEND_SIGNAL(src, COMSIG_FLOCK_ITEM_CONSUMED, internal_storage, resources)
			SEND_SIGNAL(src, COMSIG_FLOCK_RESOURCES_CHANGED, resources, new_resources)
			playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_absorb.ogg', 40, TRUE, -5)
			to_chat(src, span_good("You finish absorbing [internal_storage], and gain [new_resources] resource units. (Current total: [resources])"))
			qdel(internal_storage)

/mob/living/basic/flock/agent/death(gibbed)
	if(head)
		dropItemToGround(head)
	if(internal_storage)
		dropItemToGround(internal_storage)
	if(is_jaunting(src))
		playsound(get_turf(src), 'troutstation/sound/mobs/non-humanoids/flock/flock_critter_attenuate_death.ogg', 100, TRUE)
		icon_dead = "agent_dead_attenuated"
		death_message = "abruptly forms from the air, a husk that clatters to the ground amid ethereal caws."
		desc = "Odd lights fizz from a cracked, slowly melting shell. In a few days, there'll be no trace left."
		flock_talk("mortally attenuated", system = TRUE)
	else
		playsound(get_turf(src), 'troutstation/sound/mobs/non-humanoids/flock/flock_critter_death.ogg', 100, TRUE)
	if(gibbed)
		flock_talk("irrecoverably destroyed", system = TRUE)
	else
		flock_talk("mortally wounded", system = TRUE)
	update_damage_overlays()
	return ..(gibbed)

#undef FLOCK_AGENT_TCOMMS_HEAL_RANGE
#undef FLOCK_AGENT_TCOMMS_HEAL_ALERT_CATEGORY
#undef FLOCK_AGENT_TCOMMS_HEAL_RATE
#undef FLOCK_AGENT_REVIVAL_COST
#undef FLOCK_AGENT_REVIVAL_TIME
