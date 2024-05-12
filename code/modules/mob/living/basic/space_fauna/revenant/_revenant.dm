/// Source for a trait we get when we're stunned
#define REVENANT_STUNNED_TRAIT "revenant_got_stunned"

/// Revenants: "Ghosts" that are invisible and move like ghosts, cannot take damage while invisible
/// Can hear deadchat, but are NOT normal ghosts and do NOT have x-ray vision
/// Admin-spawn or random event
/mob/living/basic/revenant
	name = "revenant"
	desc = "A malevolent spirit."
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "revenant_idle"
	mob_biotypes = MOB_SPIRIT
	incorporeal_move = INCORPOREAL_MOVE_JAUNT
	invisibility = INVISIBILITY_REVENANT
	health = INFINITY //Revenants don't use health, they use essence instead
	maxHealth = INFINITY
	plane = GHOST_PLANE
	sight = SEE_SELF
	throwforce = 0

	// Going for faint purple spoopy ghost
	lighting_cutoff_red = 20
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35

	friendly_verb_continuous = "touches"
	friendly_verb_simple = "touch"
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "swings through"
	response_disarm_simple = "swing through"
	response_harm_continuous = "punches through"
	response_harm_simple = "punch through"
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0) //I don't know how you'd apply those, but revenants no-sell them anyway.
	habitable_atmos = null
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY

	status_flags = NONE
	density = FALSE
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	unique_name = TRUE
	hud_possible = list(ANTAG_HUD)
	hud_type = /datum/hud/revenant

	/// The icon we use while just floating around.
	var/icon_idle = "revenant_idle"
	/// The icon we use while in a revealed state.
	var/icon_reveal = "revenant_revealed"
	/// The icon we use when stunned (temporarily frozen)
	var/icon_stun = "revenant_stun"
	/// The icon we use while draining someone.
	var/icon_drain = "revenant_draining"

	/// Are we currently dormant (ectoplasm'd)?
	var/dormant = FALSE
	/// Are we currently draining someone?
	var/draining = FALSE
	/// Have we already given this revenant abilities?
	var/generated_objectives_and_spells = FALSE

	/// Lazylist of drained mobs to ensure that we don't steal a soul from someone twice
	var/list/drained_mobs = null
	/// List of action ability datums to grant on Initialize. Keep in mind that anything with the `/aoe/revenant` subtype starts locked by default.
	var/static/list/datum/action/abilities = list(
		/datum/action/cooldown/spell/aoe/revenant/blight,
		/datum/action/cooldown/spell/aoe/revenant/defile,
		/datum/action/cooldown/spell/aoe/revenant/haunt_object,
		/datum/action/cooldown/spell/aoe/revenant/malfunction,
		/datum/action/cooldown/spell/aoe/revenant/overload,
		/datum/action/cooldown/spell/list_target/telepathy/revenant,
	)

	/// The resource, and health, of revenants.
	var/essence = 75
	/// The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/max_essence = 75
	/// If the revenant regenerates essence or not
	var/essence_regenerating = TRUE
	/// How much essence regenerates per second
	var/essence_regen_amount = 2.5
	/// How much essence the revenant has stolen
	var/essence_accumulated = 0
	/// How much stolen essence is available for unlocks
	var/essence_excess = 0
	/// How long the revenant is revealed for, is about 2 seconds times this var.
	var/unreveal_time = 0
	/// How many perfect, regen-cap increasing souls the revenant has. //TODO, add objective for getting a perfect soul(s?)
	var/perfectsouls = 0

/mob/living/basic/revenant/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	add_traits(list(TRAIT_SPACEWALK, TRAIT_SIXTHSENSE, TRAIT_FREE_HYPERSPACE_MOVEMENT), INNATE_TRAIT)

	grant_actions_by_list(abilities)

	RegisterSignal(src, COMSIG_LIVING_BANED, PROC_REF(on_baned))
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move))
	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	name = generate_random_mob_name()

	GLOB.revenant_relay_mobs |= src

/mob/living/basic/revenant/Destroy()
	GLOB.revenant_relay_mobs -= src
	return ..()

/mob/living/basic/revenant/Login()
	. = ..()
	if(!. || isnull(client))
		return FALSE

	var/static/cached_string = null
	if(isnull(cached_string))
		cached_string = examine_block(jointext(create_login_string(), "\n"))

	to_chat(src, cached_string, type = MESSAGE_TYPE_INFO)

	if(generated_objectives_and_spells)
		return TRUE

	generated_objectives_and_spells = TRUE
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/revenant))
	mind.special_role = ROLE_REVENANT
	SEND_SOUND(src, sound('sound/effects/ghost.ogg'))
	mind.add_antag_datum(/datum/antagonist/revenant)
	return TRUE

/// Signal Handler Injection to handle Life() stuff for revenants
/mob/living/basic/revenant/proc/on_life(seconds_per_tick = SSMOBS_DT, times_fired)
	SIGNAL_HANDLER

	if(dormant)
		return COMPONENT_LIVING_CANCEL_LIFE_PROCESSING

	if(HAS_TRAIT(src, TRAIT_REVENANT_REVEALED) && essence <= 0)
		death()
		return COMPONENT_LIVING_CANCEL_LIFE_PROCESSING

	if(essence_regenerating && !HAS_TRAIT(src, TRAIT_REVENANT_INHIBITED) && essence < max_essence) //While inhibited, essence will not regenerate
		var/change_in_time = DELTA_WORLD_TIME(SSmobs)
		essence = min(essence + (essence_regen_amount * change_in_time), max_essence)
		update_mob_action_buttons() //because we update something required by our spells in life, we need to update our buttons

	update_appearance(UPDATE_ICON)
	update_health_hud()

/mob/living/basic/revenant/get_status_tab_items()
	. = ..()
	. += "Current Essence: [essence >= max_essence ? essence : "[essence] / [max_essence]"] E"
	. += "Total Essence Stolen: [essence_accumulated] SE"
	. += "Unused Stolen Essence: [essence_excess] SE"
	. += "Perfect Souls Stolen: [perfectsouls]"

/mob/living/basic/revenant/update_health_hud()
	if(isnull(hud_used))
		return

	var/essencecolor = "#8F48C6"
	if(essence > max_essence)
		essencecolor = "#9A5ACB" //oh boy you've got a lot of essence
	else if(essence <= 0)
		essencecolor = "#1D2953" //oh jeez you're dying
	hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[essencecolor]'>[essence]E</font></div>")

/mob/living/basic/revenant/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	if(!message)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_boldwarning("You cannot send IC messages (muted)."))
			return
		if (!(ignore_spam || forced) && client.handle_spam_prevention(message, MUTE_IC))
			return

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	log_talk(message, LOG_SAY)
	var/rendered = span_deadsay("<b>UNDEAD: [src]</b> says, \"[message]\"")
	relay_to_list_and_observers(rendered, GLOB.revenant_relay_mobs, src)

/mob/living/basic/revenant/ClickOn(atom/A, params) //revenants can't interact with the world directly, so we gotta do some wacky override stuff
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		base_click_alt(A)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		ranged_secondary_attack(A, modifiers)
		return

	if(ishuman(A) && in_range(src, A))
		attempt_harvest(A)
		return

	// This is probably the most cringe place I could put this but whatever -
	// Revenants can click on spirit boards for seances like ghosts
	if(istype(A, /obj/structure/spirit_board) \
		&& !HAS_TRAIT(src, TRAIT_REVENANT_REVEALED) \
		&& !HAS_TRAIT(src, TRAIT_NO_TRANSFORM) \
		&& !HAS_TRAIT(src, TRAIT_REVENANT_INHIBITED))

		var/obj/structure/spirit_board/board = A
		board.spirit_board_pick_letter(src)
		return

/mob/living/basic/revenant/ranged_secondary_attack(atom/target, modifiers)
	if(HAS_TRAIT(src, TRAIT_REVENANT_INHIBITED) || HAS_TRAIT(src, TRAIT_REVENANT_REVEALED) || HAS_TRAIT(src, TRAIT_NO_TRANSFORM) || !Adjacent(target) || !incorporeal_move_check(target))
		return

	var/list/icon_dimensions = get_icon_dimensions(target.icon)
	var/orbitsize = (icon_dimensions["width"] + icon_dimensions["height"]) * 0.5
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)
	orbit(target, orbitsize)

/mob/living/basic/revenant/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && !HAS_TRAIT(src, TRAIT_REVENANT_REVEALED))
		return 0

	. = amount

	essence = max(0, essence - amount)
	if(updating_health)
		update_health_hud()
	if(essence == 0)
		death()

	return .

/mob/living/basic/revenant/orbit(atom/target)
	setDir(SOUTH) // reset dir so the right directional sprites show up
	return ..()

/mob/living/basic/revenant/update_icon_state()
	. = ..()

	if(HAS_TRAIT(src, TRAIT_REVENANT_REVEALED))
		icon_state = icon_reveal
		return

	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		if(draining)
			icon_state = icon_drain
		else
			icon_state = icon_stun

		return

	icon_state = icon_idle

/mob/living/basic/revenant/med_hud_set_health()
	return //we use no hud

/mob/living/basic/revenant/med_hud_set_status()
	return //we use no hud

/mob/living/basic/revenant/dust(just_ash, drop_items, force)
	death()

/mob/living/basic/revenant/gib()
	death()

/mob/living/basic/revenant/can_perform_action(atom/movable/target, action_bitflags)
	return FALSE

/mob/living/basic/revenant/ex_act(severity, target)
	return FALSE //Immune to the effects of explosions.

/mob/living/basic/revenant/blob_act(obj/structure/blob/attacking_blob)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/basic/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/basic/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/basic/revenant/bullet_act()
	if(!HAS_TRAIT(src, TRAIT_REVENANT_REVEALED) || dormant)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/mob/living/basic/revenant/death()
	if(!HAS_TRAIT(src, TRAIT_REVENANT_REVEALED) || dormant) //Revenants cannot die if they aren't revealed //or are already dead
		return
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, REVENANT_STUNNED_TRAIT)
	dormant = TRUE

	visible_message(
		span_warning("[src] lets out a waning screech as violet mist swirls around its dissolving body!"),
		span_revendanger("NO! No... it's too late, you can feel your essence [pick("breaking apart", "drifting away")]..."),
	)

	SetInvisibility(INVISIBILITY_NONE, id=type)
	icon_state = "revenant_draining"
	playsound(src, 'sound/effects/screech.ogg', 100, TRUE)

	animate(src, alpha = 0, time = 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(move_to_ectoplasm)), 3 SECONDS)

/// Forces the mob, once dormant, to move inside ectoplasm until it can regenerate.
/mob/living/basic/revenant/proc/move_to_ectoplasm()
	if(QDELETED(src) || !dormant) // something fucky happened, abort. we MUST be dormant to go inside the ectoplasm.
		return

	visible_message(span_danger("[src]'s body breaks apart into a fine pile of blue dust."))

	var/obj/item/ectoplasm/revenant/goop = new(get_turf(src)) // the ectoplasm will handle moving us out of dormancy
	goop.old_ckey = client.ckey
	goop.revenant = src
	forceMove(goop)

/mob/living/basic/revenant/proc/on_move(datum/source, atom/entering_loc)
	SIGNAL_HANDLER
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM)) // just in case it occurs, need to provide some feedback
		balloon_alert(src, "can't move!")
		return

	if(isnull(orbiting) || incorporeal_move_check(entering_loc))
		return

	// we're about to go somewhere we aren't meant to, end the orbit and block the move. feedback will be given in `incorporeal_move_check()`
	orbiting.end_orbit(src)
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Generates the information the player needs to know how to play their role, and returns it as a list.
/mob/living/basic/revenant/proc/create_login_string()
	RETURN_TYPE(/list)
	var/list/returnable_list = list()
	returnable_list += span_deadsay(span_boldbig("You are a revenant."))
	returnable_list += span_bold("Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.")
	returnable_list += span_bold("You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.")
	returnable_list += span_bold("You are invincible and invisible to everyone but other ghosts. Most abilities will reveal you, rendering you vulnerable.")
	returnable_list += span_bold("To function, you are to drain the life essence from humans. This essence is a resource, as well as your health, and will power all of your abilities.")
	returnable_list += span_bold("<i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i>")
	returnable_list += span_bold("Be sure to read <a href=\"https://tgstation13.org/wiki/Revenant\">the wiki page</a> to learn more.")
	return returnable_list

/mob/living/basic/revenant/generate_random_mob_name()
	var/list/built_name_strings = list()
	built_name_strings += pick(strings(REVENANT_NAME_FILE, "spirit_type"))
	built_name_strings += " of "
	built_name_strings += pick(strings(REVENANT_NAME_FILE, "adverb"))
	built_name_strings += pick(strings(REVENANT_NAME_FILE, "theme"))
	return built_name_strings.Join("")

/mob/living/basic/revenant/proc/on_baned(obj/item/weapon, mob/living/user)
	SIGNAL_HANDLER
	visible_message(
		span_warning("[src] violently flinches!"),
		span_revendanger("As [weapon] passes through you, you feel your essence draining away!"),
	)
	apply_status_effect(/datum/status_effect/revenant/inhibited, 3 SECONDS)

/// Incorporeal move check: blocked by holy-watered tiles and salt piles.
/mob/living/basic/revenant/proc/incorporeal_move_check(atom/destination)
	var/turf/open/floor/step_turf = get_turf(destination)
	if(isnull(step_turf))
		return TRUE // what? whatever let it happen

	if(step_turf.turf_flags & NOJAUNT)
		to_chat(src, span_warning("Some strange aura is blocking the way."))
		return FALSE

	if(locate(/obj/effect/decal/cleanable/food/salt) in step_turf)
		balloon_alert(src, "blocked by salt!")
		apply_status_effect(/datum/status_effect/revenant/revealed, 2 SECONDS)
		apply_status_effect(/datum/status_effect/incapacitating/paralyzed/revenant, 2 SECONDS)
		return FALSE

	if(locate(/obj/effect/blessing) in step_turf)
		to_chat(src, span_warning("Holy energies block your path!"))
		return FALSE

	return TRUE

/mob/living/basic/revenant/proc/cast_check(essence_cost)
	if(QDELETED(src))
		return

	var/turf/current = get_turf(src)

	if(isclosedturf(current))
		to_chat(src, span_revenwarning("You cannot use abilities from inside of a wall."))
		return FALSE

	for(var/obj/thing in current)
		if(!thing.density || thing.CanPass(src, get_dir(current, src)))
			continue
		to_chat(src, span_revenwarning("You cannot use abilities inside of a dense object."))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_REVENANT_INHIBITED))
		to_chat(src, span_revenwarning("Your powers have been suppressed by a nullifying energy!"))
		return FALSE

	if(!change_essence_amount(essence_cost, TRUE))
		to_chat(src, span_revenwarning("You lack the essence to use that ability."))
		return FALSE

	return TRUE

/mob/living/basic/revenant/proc/unlock(essence_cost)
	if(essence_excess < essence_cost)
		return FALSE
	essence_excess -= essence_cost
	update_mob_action_buttons()
	return TRUE

/mob/living/basic/revenant/proc/death_reset()
	REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, REVENANT_STUNNED_TRAIT)
	forceMove(get_turf(src))
	// clean slate, so no more debilitating effects
	remove_status_effect(/datum/status_effect/revenant/revealed)
	remove_status_effect(/datum/status_effect/incapacitating/paralyzed/revenant)
	remove_status_effect(/datum/status_effect/revenant/inhibited)
	draining = FALSE
	dormant = FALSE
	incorporeal_move = INCORPOREAL_MOVE_JAUNT
	RemoveInvisibility(type)
	alpha = 255

/mob/living/basic/revenant/proc/change_essence_amount(essence_to_change_by, silent = FALSE, source = null)
	if(QDELETED(src))
		return FALSE

	if((essence + essence_to_change_by) < 0)
		return FALSE

	essence = max(0, essence + essence_to_change_by)
	update_health_hud()

	if(essence_to_change_by > 0)
		essence_accumulated = max(0, essence_accumulated + essence_to_change_by)
		essence_excess = max(0, essence_excess + essence_to_change_by)

	update_mob_action_buttons()
	if(!silent)
		if(essence_to_change_by > 0)
			to_chat(src, span_revennotice("Gained [essence_to_change_by]E [source ? "from [source]":""]."))
		else
			to_chat(src, span_revenminor("Lost [essence_to_change_by]E [source ? "from [source]":""]."))
	return TRUE

#undef REVENANT_STUNNED_TRAIT
