/// list of weakrefs to mobs OR minds that have been sacrificed
GLOBAL_LIST(sacrificed)
/// List of all teleport runes
GLOBAL_LIST(teleport_runes)
/// Assoc list of every rune that can be drawn by ritual daggers. [rune_name] = [typepath]
GLOBAL_LIST_INIT(rune_types, generate_cult_rune_types())

/// Returns an associated list of rune types. [rune.cultist_name] = [typepath]
/proc/generate_cult_rune_types()
	RETURN_TYPE(/list)

	var/list/runes = list()
	for(var/obj/effect/rune/rune as anything in subtypesof(/obj/effect/rune))
		if(!initial(rune.can_be_scribed))
			continue
		runes[initial(rune.cultist_name)] = rune // Uses the cultist name for displaying purposes

	return runes

/*

This file contains runes.
Runes are used by the cult to cause many different effects and are paramount to their success.
They are drawn with a ritual dagger in blood, and are distinguishable to cultists and normal crew by examining.
Fake runes can be drawn in crayon to fool people.
Runes can either be invoked by one's self or with many different cultists. Each rune has a specific incantation that the cultists will say when invoking it.


*/

/obj/effect/rune
	name = "rune"
	desc = "An odd collection of symbols drawn in what seems to be blood."
	anchored = TRUE
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	color = RUNE_COLOR_RED

	/// The name of the rune to cultists
	var/cultist_name = "basic rune"
	/// The description of the rune shown to cultists who examine it
	var/cultist_desc = "a basic rune with no function."
	/// This is said by cultists when the rune is invoked.
	var/invocation = "Aiy ele-mayo!"
	/// The amount of cultists required around the rune to invoke it.
	var/req_cultists = 1
	/// If we have a description override for required cultists to invoke
	var/req_cultists_text
	/// Used for some runes, this is for when you want a rune to not be usable when in use.
	var/rune_in_use = FALSE
	/// Used when you want to keep track of who erased the rune
	var/log_when_erased = FALSE
	/// Whether this rune can be scribed or if it's admin only / special spawned / whatever
	var/can_be_scribed = TRUE
	/// How long the rune takes to erase
	var/erase_time = 1.5 SECONDS
	/// How long the rune takes to create
	var/scribe_delay = 4 SECONDS
	/// If a rune cannot be speed boosted while scribing on certain turfs
	var/no_scribe_boost = FALSE
	/// Hhow much damage you take doing it
	var/scribe_damage = 0.1
	/// How much damage invokers take when invoking it
	var/invoke_damage = 0
	/// If constructs can invoke it
	var/construct_invoke = TRUE
	/// If the rune requires a keyword when scribed
	var/req_keyword = FALSE
	/// The actual keyword for the rune
	var/keyword

/obj/effect/rune/Initialize(mapload, set_keyword)
	. = ..()
	if(set_keyword)
		keyword = set_keyword
	var/image/I = image(icon = 'icons/effects/blood.dmi', icon_state = null, loc = src)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		. += "<b>Name:</b> [cultist_name]\n"+\
		"<b>Effects:</b> [capitalize(cultist_desc)]\n"+\
		"<b>Required Acolytes:</b> [req_cultists_text ? "[req_cultists_text]":"[req_cultists]"]"
		if(req_keyword && keyword)
			. += "<b>Keyword:</b> [keyword]"

/obj/effect/rune/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("You aren't able to understand the words of [src]."))
		return
	var/list/invokers = can_invoke(user)
	if(length(invokers) >= req_cultists)
		invoke(invokers)
	else
		to_chat(user, span_danger("You need [req_cultists - length(invokers)] more adjacent cultists to use this rune in such a manner."))
		fail_invoke()

/obj/effect/rune/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(isshade(user) || isconstruct(user))
		if(istype(user, /mob/living/simple_animal/hostile/construct/wraith/angelic) || istype(user, /mob/living/simple_animal/hostile/construct/juggernaut/angelic) || istype(user, /mob/living/simple_animal/hostile/construct/artificer/angelic))
			to_chat(user, span_warning("You purge the rune!"))
			qdel(src)
		else if(construct_invoke || !IS_CULTIST(user)) //if you're not a cult construct we want the normal fail message
			attack_hand(user)
		else
			to_chat(user, span_warning("You are unable to invoke the rune!"))

/*

There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.

*/

/obj/effect/rune/proc/can_invoke(mob/living/user=null)
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	var/list/invokers = list() //people eligible to invoke the rune
	if(user)
		invokers += user
	if(req_cultists > 1 || istype(src, /obj/effect/rune/convert))
		var/list/things_in_range = range(1, src)
		for(var/mob/living/L in things_in_range)
			if(IS_CULTIST(L))
				if(L == user)
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if((HAS_TRAIT(H, TRAIT_MUTE)) || H.silent)
						continue
				if(L.stat)
					continue
				invokers += L
	return invokers

/obj/effect/rune/proc/invoke(list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	for(var/M in invokers)
		if(isliving(M))
			var/mob/living/L = M
			if(invocation)
				L.say(invocation, language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")
			if(invoke_damage)
				L.apply_damage(invoke_damage, BRUTE)
				to_chat(L, "<span class='cult italic'>[src] saps your strength!</span>")
		else if(istype(M, /obj/item/toy/plush/narplush))
			var/obj/item/toy/plush/narplush/P = M
			P.visible_message("<span class='cult italic'>[P] squeaks loudly!</span>")
	do_invoke_glow()

/obj/effect/rune/proc/do_invoke_glow()
	set waitfor = FALSE
	animate(src, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
	sleep(5)
	animate(src, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)

/obj/effect/rune/proc/fail_invoke()
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message(span_warning("The markings pulse with a small flash of red light, then fall dark."))
	var/oldcolor = color
	color = rgb(255, 0, 0)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 5)

//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "malformed rune"
	cultist_desc = "a senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"
	invoke_damage = 30
	can_be_scribed = FALSE

/obj/effect/rune/malformed/Initialize(mapload, set_keyword)
	. = ..()
	icon_state = "[rand(1,7)]"
	color = rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/effect/rune/malformed/invoke(list/invokers)
	..()
	qdel(src)

//Rite of Conversion: Converts or sacrifices a target.
/obj/effect/rune/convert
	cultist_name = "Conversion"
	cultist_desc = "Allows you to offer a noncultist above it to Nar'Sie, either converting them or sacrificing them."
	req_cultists_text = "2 for conversion, 3 for living sacrifices and sacrifice targets."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = RUNE_COLOR_OFFER
	req_cultists = 1
	rune_in_use = FALSE

/obj/effect/rune/convert/do_invoke_glow()
	return

/obj/effect/rune/convert/invoke(list/invokers)
	if(rune_in_use)
		return
	var/list/myriad_targets = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(!IS_CULTIST(M))
			myriad_targets |= M
	if(!length(myriad_targets))
		fail_invoke()
		log_game("Offer rune failed - no eligible targets.")
		return
	rune_in_use = TRUE
	visible_message(span_warning("[src] pulses blood red!"))
	var/oldcolor = color
	color = RUNE_COLOR_DARKRED
	var/mob/living/L = pick(myriad_targets)

	var/mob/living/F = invokers[1]
	var/datum/antagonist/cult/C = F.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	var/datum/team/cult/Cult_team = C.cult_team
	var/is_convertable = is_convertable_to_cult(L,C.cult_team)
	if(L.stat && is_convertable)
		invocation = "Mah'weyh pleggh at e'ntrath!"
		..()
		if(is_convertable)
			do_convert(L, invokers)
	else
		invocation = "Barhah hra zar'garis!"
		..()
		do_sacrifice(L, invokers)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 5)
	Cult_team.check_size() // Triggers the eye glow or aura effects if the cult has grown large enough relative to the crew
	rune_in_use = FALSE

/obj/effect/rune/convert/proc/do_convert(mob/living/convertee, list/invokers)
	if(length(invokers) < 2)
		for(var/M in invokers)
			to_chat(M, span_warning("You need at least two invokers to convert [convertee]!"))
		log_game("Offer rune with [convertee] on it failed - tried conversion with one invoker.")
		return FALSE
	if(convertee.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY, charge_cost = 0)) //No charge_cost because it can be spammed
		for(var/M in invokers)
			to_chat(M, span_warning("Something is shielding [convertee]'s mind!"))
		log_game("Offer rune with [convertee] on it failed - convertee had anti-magic.")
		return FALSE
	convertee.revive(full_heal = TRUE, admin_revive = TRUE)
	convertee.mind?.add_antag_datum(/datum/antagonist/cult)
	convertee.Unconscious(100)
	new /obj/item/melee/cultblade/dagger(get_turf(src))
	convertee.mind.special_role = ROLE_CULTIST
	to_chat(convertee, "<span class='cult italic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
	and something evil takes root.</b></span>")
	to_chat(convertee, "<span class='cult italic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve the Geometer above all else. Bring it back.\
	</b></span>")
	if(ishuman(convertee))
		var/mob/living/carbon/human/H = convertee
		H.uncuff()
		H.remove_status_effect(/datum/status_effect/speech/slurring/cult)
		H.remove_status_effect(/datum/status_effect/speech/stutter)

		if(prob(1) || SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
			H.say("You son of a bitch! I'm in.", forced = "That son of a bitch! They're in.")
	if(isshade(convertee))
		convertee.icon_state = "shade_cult"
		convertee.name = convertee.real_name
	return TRUE

/obj/effect/rune/convert/proc/do_sacrifice(mob/living/sacrificial, list/invokers)
	var/mob/living/first_invoker = invokers[1]
	if(!first_invoker)
		return FALSE
	var/datum/antagonist/cult/C = first_invoker.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C)
		return FALSE

	var/signal_result = SEND_SIGNAL(sacrificial, COMSIG_LIVING_CULT_SACRIFICED, invokers)
	if(signal_result & STOP_SACRIFICE)
		return FALSE

	var/big_sac = FALSE
	if((((ishuman(sacrificial) || iscyborg(sacrificial)) && sacrificial.stat != DEAD) || C.cult_team.is_sacrifice_target(sacrificial.mind)) && length(invokers) < 3)
		for(var/M in invokers)
			to_chat(M, span_cultitalic("[sacrificial] is too greatly linked to the world! You need three acolytes!"))
		log_game("Offer rune with [sacrificial] on it failed - not enough acolytes and target is living or sac target")
		return FALSE

	if(sacrificial.mind)
		LAZYADD(GLOB.sacrificed, WEAKREF(sacrificial.mind))
		for(var/datum/objective/sacrifice/sac_objective in C.cult_team.objectives)
			if(sac_objective.target == sacrificial.mind)
				sac_objective.sacced = TRUE
				sac_objective.clear_sacrifice()
				sac_objective.update_explanation_text()
				big_sac = TRUE
	else
		LAZYADD(GLOB.sacrificed, WEAKREF(sacrificial))

	new /obj/effect/temp_visual/cult/sac(get_turf(src))

	if(!(signal_result & SILENCE_SACRIFICE_MESSAGE))
		for(var/invoker in invokers)
			if(big_sac)
				to_chat(invoker, span_cultlarge("\"Yes! This is the one I desire! You have done well.\""))
				continue
			if(ishuman(sacrificial) || iscyborg(sacrificial))
				to_chat(invoker, span_cultlarge("\"I accept this sacrifice.\""))
			else
				to_chat(invoker, span_cultlarge("\"I accept this meager sacrifice.\""))

	if(iscyborg(sacrificial))
		var/construct_class = show_radial_menu(first_invoker, sacrificial, GLOB.construct_radial_images, require_near = TRUE, tooltips = TRUE)
		if(QDELETED(sacrificial) || !construct_class)
			return FALSE
		sacrificial.grab_ghost()
		make_new_construct_from_class(construct_class, THEME_CULT, sacrificial, first_invoker, TRUE, get_turf(src))
		var/mob/living/silicon/robot/sacriborg = sacrificial
		sacrificial.log_message("was sacrificed as a cyborg.", LOG_GAME)
		sacriborg.mmi = null
		qdel(sacrificial)
		return TRUE
	var/obj/item/soulstone/stone = new /obj/item/soulstone(get_turf(src))
	if(sacrificial.mind && !sacrificial.suiciding)
		stone.capture_soul(sacrificial, first_invoker, TRUE)

	if(sacrificial)
		playsound(sacrificial, 'sound/magic/disintegrate.ogg', 100, TRUE)
		sacrificial.gib()
	return TRUE

//Ritual of Dimensional Rending: Calls forth the avatar of Nar'Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Nar'Sie"
	cultist_desc = "tears apart dimensional barriers, calling forth the Geometer. Requires 9 invokers."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_DARKRED
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	scribe_delay = 50 SECONDS //how long the rune takes to create
	scribe_damage = 40.1 //how much damage you take doing it
	log_when_erased = TRUE
	no_scribe_boost = TRUE
	erase_time = 5 SECONDS
	///Has the rune been used already?
	var/used = FALSE

/obj/effect/rune/narsie/Initialize(mapload, set_keyword)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)

/obj/effect/rune/narsie/invoke(list/invokers)
	if(used)
		return
	if(!is_station_level(z))
		return
	var/mob/living/user = invokers[1]
	var/datum/antagonist/cult/user_antag = user.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
	var/datum/objective/eldergod/summon_objective = locate() in user_antag.cult_team.objectives
	var/area/place = get_area(src)
	if(!(place in summon_objective.summon_spots))
		to_chat(user, span_cultlarge("The Geometer can only be summoned where the veil is weak - in [english_list(summon_objective.summon_spots)]!"))
		return
	if(locate(/obj/narsie) in SSpoints_of_interest.narsies)
		for(var/invoker in invokers)
			to_chat(invoker, span_warning("Nar'Sie is already on this plane!"))
		log_game("Nar'Sie rune activated by [user] at [COORD(src)] failed - already summoned.")
		return

	//BEGIN THE SUMMONING
	used = TRUE
	var/datum/team/cult/cult_team = user_antag.cult_team
	if (cult_team.narsie_summoned)
		for (var/datum/mind/cultist_mind in cult_team.members)
			var/mob/living/cultist_mob = cultist_mind.current
			cultist_mob.client?.give_award(/datum/award/achievement/misc/narsupreme, cultist_mob)

	cult_team.narsie_summoned = TRUE
	..()
	sound_to_playing_players('sound/effects/dimensional_rend.ogg')
	var/turf/rune_turf = get_turf(src)
	sleep(4 SECONDS)
	if(src)
		color = RUNE_COLOR_RED
	new /obj/narsie(rune_turf) //Causes Nar'Sie to spawn even if the rune has been removed

/obj/effect/rune/empower
	cultist_name = "Prepare Spell"
	cultist_desc = "allows cultists to prepare up to 2 advanced spells."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "3"
	color = RUNE_COLOR_TALISMAN
	construct_invoke = FALSE
	var/channeling = FALSE

/obj/effect/rune/empower/invoke(list/invokers)
	. = ..()
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/spells = list()
	var/limit = MAX_BLOODCHARGE
	if(length(spells) >= limit)
		to_chat(user, span_cultitalic("You cannot store more than [MAX_BLOODCHARGE] spells. <b>Pick a spell to remove.</b>"))
		var/nullify_spell = tgui_input_list(user, "Spell to remove", "Current Spells", spells)
		if(isnull(nullify_spell))
			return
		qdel(nullify_spell)
	var/list/possible_spells = list()
	for(var/I in subtypesof(/datum/action/innate/cult/blood_spell))
		var/datum/action/innate/cult/blood_spell/J = I
		var/cult_name = initial(J.name)
		possible_spells[cult_name] = J
	possible_spells += "(REMOVE SPELL)"
	var/entered_spell_name = tgui_input_list(user, "Blood spell to prepare", "Spell Choices", possible_spells)
	if(isnull(entered_spell_name))
		return
	if(entered_spell_name == "(REMOVE SPELL)")
		var/nullify_spell = tgui_input_list(user, "Spell to remove", "Current Spells", spells)
		if(isnull(nullify_spell))
			return
		qdel(nullify_spell)
	var/datum/action/innate/cult/blood_spell/BS = possible_spells[entered_spell_name]
	if(user.incapacitated() || !BS || !(src in range(1, user)) || (length(spells) >= limit))
		return
	to_chat(user,span_warning("You begin to carve unnatural symbols into your flesh!"))
	SEND_SOUND(user, sound('sound/weapons/slice.ogg',0,1,10))
	if(!channeling)
		channeling = TRUE
	else
		to_chat(user, span_cultitalic("You are already invoking blood magic!"))
		return
	if(do_after(user, 100 - rune*60, target = user))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.bleed(40 - rune*32)
		var/datum/action/innate/cult/blood_spell/new_spell = new BS(user)
		new_spell.Grant(user, src)
		spells += new_spell
		Positioning()
		to_chat(user, span_warning("Your wounds glow with power, you have prepared a [new_spell.name] invocation!"))
	channeling = FALSE

/*
/datum/action/innate/cult/blood_magic/IsAvailable()
	if(!IS_CULTIST(user))
		return FALSE
	return ..()
*/ /// Checks if a cultist can take a spell, but only a cultist is supposed to be able to use the rune.

/datum/action/innate/cult/blood_magic/proc/Positioning()
	for(var/datum/hud/hud as anything in viewers)
		var/our_view = hud.mymob?.client?.view || "15x15"
		var/atom/movable/screen/movable/action_button/button = viewers[hud]
		var/position = screen_loc_to_offset(button.screen_loc)
		var/spells_iterated = 0
		for(var/datum/action/innate/cult/blood_spell/blood_spell in spells)
			spells_iterated += 1
			if(blood_spell.positioned)
				continue
			var/atom/movable/screen/movable/action_button/moving_button = blood_spell.viewers[hud]
			if(!moving_button)
				continue
			var/our_x = position[1] + spells_iterated * world.icon_size // Offset any new buttons into our list
			hud.position_action(moving_button, offset_to_screen_loc(our_x, position[2], our_view))
			blood_spell.positioned = TRUE




//Rite of Resurrection: Requires a dead or inactive cultist. When reviving the dead, you can only perform one revival for every three sacrifices your cult has carried out.
/obj/effect/rune/raise_dead
	cultist_name = "Revive"
	cultist_desc = "requires a dead, mindless, or inactive cultist placed upon the rune. For each three bodies sacrificed to the dark patron, one body will be mended and their mind awoken"
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!" //Depends on the name of the user - see below
	icon_state = "1"
	color = RUNE_COLOR_MEDIUMRED
	var/static/sacrifices_used = -SOULS_TO_REVIVE // Cultists get one "free" revive

/obj/effect/rune/raise_dead/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || user.stat == DEAD)
		. += "<b>Sacrifices unrewarded:</b> [LAZYLEN(GLOB.sacrificed) - sacrifices_used]"

/obj/effect/rune/raise_dead/invoke(list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_revive
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	rune_in_use = TRUE
	for(var/mob/living/M in T.contents)
		if(IS_CULTIST(M) && (M.stat == DEAD || !M.client || M.client.is_afk()))
			potential_revive_mobs |= M
	if(!length(potential_revive_mobs))
		to_chat(user, "<span class='cult italic'>There are no dead cultists on the rune!</span>")
		log_game("Raise Dead rune activated by [user] at [COORD(src)] failed - no cultists to revive.")
		fail_invoke()
		return
	if(length(potential_revive_mobs) > 1)
		mob_to_revive = tgui_input_list(user, "Cultist to revive", "Revive Cultist", potential_revive_mobs)
		if(isnull(mob_to_revive))
			return
	else
		mob_to_revive = potential_revive_mobs[1]
	if(QDELETED(src) || !validness_checks(mob_to_revive, user))
		fail_invoke()
		return
	if(user.name == "Herbert West")
		invocation = "To life, to life, I bring them!"
	else
		invocation = initial(invocation)
	..()
	if(mob_to_revive.stat == DEAD)
		var/diff = LAZYLEN(GLOB.sacrificed) - SOULS_TO_REVIVE - sacrifices_used
		if(diff < 0)
			to_chat(user, span_warning("Your cult must carry out [abs(diff)] more sacrifice\s before it can revive another cultist!"))
			fail_invoke()
			return
		sacrifices_used += SOULS_TO_REVIVE
		mob_to_revive.revive(full_heal = TRUE, admin_revive = TRUE) //This does remove traits and such, but the rune might actually see some use because of it!
		mob_to_revive.grab_ghost()
	if(!mob_to_revive.client || mob_to_revive.client.is_afk())
		set waitfor = FALSE
		var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as a [mob_to_revive.real_name], an inactive blood cultist?", ROLE_CULTIST, ROLE_CULTIST, 5 SECONDS, mob_to_revive)
		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			to_chat(mob_to_revive.mind, "Your physical form has been taken over by another soul due to your inactivity! Ahelp if you wish to regain your form.")
			message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(mob_to_revive)]) to replace an AFK player.")
			mob_to_revive.ghostize(0)
			mob_to_revive.key = C.key
		else
			fail_invoke()
			return
	SEND_SOUND(mob_to_revive, 'sound/ambience/antag/bloodcult.ogg')
	to_chat(mob_to_revive, span_cultlarge("\"PASNAR SAVRAE YAM'TOTH. Arise.\""))
	mob_to_revive.visible_message(span_warning("[mob_to_revive] draws in a huge breath, red light shining from [mob_to_revive.p_their()] eyes."), \
								  span_cultlarge("You awaken suddenly from the void. You're alive!"))
	rune_in_use = FALSE

/obj/effect/rune/raise_dead/proc/validness_checks(mob/living/target_mob, mob/living/user)
	var/turf/T = get_turf(src)
	if(QDELETED(user))
		return FALSE
	if(!Adjacent(user) || user.incapacitated())
		return FALSE
	if(QDELETED(target_mob))
		return FALSE
	if(!(target_mob in T.contents))
		to_chat(user, "<span class='cult italic'>The cultist to revive has been moved!</span>")
		log_game("Raise Dead rune activated by [user] at [COORD(src)] failed - revival target moved.")
		return FALSE
	return TRUE

/obj/effect/rune/raise_dead/fail_invoke()
	..()
	rune_in_use = FALSE
	for(var/mob/living/M in range(1,src))
		if(IS_CULTIST(M) && M.stat == DEAD)
			M.visible_message(span_warning("[M] twitches."))
