/**
 * A mob which acts as a guardian angel to another mob, sharing health but protecting them using special powers.
 * Usually either obtained in magical form by a wizard, or technological form by a traitor. Sometimes found by miners.
 */
/mob/living/basic/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	icon = 'icons/mob/nonhuman-player/guardian.dmi'
	icon_state = "magicbase"
	icon_living = "magicbase"
	icon_dead = "magicbase"
	gender = NEUTER
	basic_mob_flags = DEL_ON_DEATH
	mob_biotypes = MOB_SPECIAL
	sentience_type = SENTIENCE_HUMANOID
	hud_type = /datum/hud/guardian
	faction = list()
	speed = 0
	maxHealth = INFINITY // The spirit itself is invincible and passes damage to its host
	health = INFINITY
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	speak_emote = list("hisses")
	bubble_icon = "guardian"
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	attack_sound = 'sound/items/weapons/punch1.ogg'
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	combat_mode = TRUE
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_attack_cooldown = CLICK_CD_MELEE
	light_system = OVERLAY_LIGHT
	light_range = 3
	light_on = FALSE

	/// The summoner of the guardian, we share health with them and can't move too far away (usually)
	var/mob/living/summoner
	/// How far from the summoner the guardian can be.
	var/range = 10

	/// The guardian's colour, used for their sprite, chat, and some effects.
	var/guardian_colour
	/// Coloured overlay we apply
	var/mutable_appearance/overlay

	/// Which toggle button the HUD uses.
	var/toggle_button_type = /atom/movable/screen/guardian/toggle_mode/inactive
	/// Name used by the guardian creator.
	var/creator_name = "Error"
	/// Description used by the guardian creator.
	var/creator_desc = "This shouldn't be here! Report it on GitHub!"
	/// Icon used by the guardian creator.
	var/creator_icon = "fuck"

	/// What type of guardian are we?
	var/guardian_type = null
	/// How are we themed?
	var/datum/guardian_fluff/theme
	/// A string explaining to the guardian what they can do.
	var/playstyle_string = span_boldholoparasite("You are a Guardian without any type. You shouldn't exist and are an affront to god!")

	/// Are we forced to not be able to manifest/recall?
	var/locked = FALSE
	/// Cooldown between manifests/recalls.
	COOLDOWN_DECLARE(manifest_cooldown)
	/// Cooldown between the summoner resetting the guardian's client.
	COOLDOWN_DECLARE(resetting_cooldown)

	/// List of actions we give to our summoner
	var/static/list/control_actions = list(
		/datum/action/cooldown/mob_cooldown/guardian_comms,
		/datum/action/cooldown/mob_cooldown/recall_guardian,
		/datum/action/cooldown/mob_cooldown/replace_guardian,
	)

/mob/living/basic/guardian/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	GLOB.parasites += src
	src.theme = theme
	theme?.apply(src)
	var/list/death_loot = string_list(list(/obj/item/stack/sheet/mineral/wood))
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/basic_inhands)
	// life link
	update_appearance(UPDATE_ICON)
	manifest_effects()

/mob/living/basic/guardian/Destroy()
	GLOB.parasites -= src
	if (is_deployed())
		recall_effects()
	cut_summoner(different_person = TRUE)
	return ..()

/mob/living/basic/guardian/update_overlays()
	. = ..()
	. += overlay

/mob/living/basic/guardian/Login() //if we have a mind, set its name to ours when it logs in
	. = ..()
	if (!. || isnull(client))
		return FALSE
	if (isnull(summoner))
		to_chat(src, span_boldholoparasite("For some reason, somehow, you have no summoner. Please report this bug immediately."))
		stack_trace("Guardian created with client but no summoner.")
	else
		to_chat(src, span_holoparasite("You are a <b>[theme.name]</b>, bound to serve [summoner.real_name]."))
		to_chat(src, span_holoparasite("You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with [summoner.p_them()] privately there."))
		to_chat(src, span_holoparasite("While personally invincible, you will die if [summoner.real_name] does, and any damage dealt to you will have a portion passed on to [summoner.p_them()] as you feed upon [summoner.p_them()] to sustain yourself."))
	to_chat(src, playstyle_string)
	if (!isnull(guardian_colour))
		return // Already set up so we don't need to do it again
	locked = TRUE
	guardian_rename()
	guardian_recolour()
	locked = FALSE

/mob/living/basic/guardian/mind_initialize()
	. = ..()
	if (isnull(summoner))
		to_chat(src, span_boldholoparasite("For some reason, somehow, you have no summoner. Please report this bug immediately."))
		return
	mind.enslave_mind_to_creator(summoner) // Once our mind is created, we become enslaved to our summoner. cant be done in the first run of set_summoner, because by then we dont have a mind yet.

/// Pick a new colour for our guardian
/mob/living/basic/guardian/proc/guardian_recolour()
	if (isnull(client))
		return
	var/chosen_guardian_colour = input(src, "What would you like your colour to be?", "Choose Your Colour", "#ffffff") as color|null
	if (isnull(chosen_guardian_colour)) //redo proc until we get a color
		to_chat(src, span_warning("Invalid colour, please try again."))
		return guardian_recolour()
	set_guardian_colour(chosen_guardian_colour)

/// Apply a new colour to our guardian
/mob/living/basic/guardian/proc/set_guardian_colour(colour)
	guardian_colour = colour
	set_light_color(guardian_colour)
	overlay?.color = guardian_colour
	update_appearance(UPDATE_ICON)

/mob/living/basic/guardian/proc/guardian_rename()
	if (isnull(client))
		return

	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "What would you like your name to be?", "Choose Your Name", generate_random_name(), MAX_NAME_LEN)))
	if (!new_name) //redo proc until we get a good name
		to_chat(src, span_warning("Invalid name, please try again."))
		return guardian_rename()
	to_chat(src, span_notice("Your new name [span_name(new_name)] anchors itself in your mind."))
	fully_replace_character_name(null, new_name)

/// Picks a random name as a suggestion
/mob/living/basic/guardian/proc/generate_random_name()
	var/list/surname_options = list("Guardian") // Fallback in case you define a guardian with no theme
	switch(theme?.fluff_type)
		if (GUARDIAN_MAGIC)
			surname_options = GLOB.guardian_fantasy_surnames
		if (GUARDIAN_TECH)
			surname_options = GLOB.guardian_tech_surnames

	return "[pick(GLOB.guardian_first_names)] [pick(surname_options)]"

/mob/living/basic/guardian/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if (!is_deployed())
		balloon_alert(src, "not tangible!")
		return FALSE
	return ..()

/mob/living/basic/guardian/death(gibbed)
	if (!QDELETED(summoner))
		to_chat(summoner, span_bolddanger("Your [name] died somehow!"))
		summoner.dust()
	return ..()

/mob/living/basic/guardian/ex_act(severity, target)
	switch(severity)
		if (EXPLODE_DEVASTATE)
			investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
			gib()
			return TRUE
		if (EXPLODE_HEAVY)
			adjustBruteLoss(60)
		if (EXPLODE_LIGHT)
			adjustBruteLoss(30)

	return TRUE

/mob/living/basic/guardian/gib()
	death(TRUE)

/mob/living/basic/guardian/dust(just_ash, drop_items, force)
	death(TRUE)

/// Link up with a summoner mob.
/mob/living/basic/guardian/proc/set_summoner(mob/living/to_who, different_person = FALSE)
	if (QDELETED(src))
		return // Just in case
	if (QDELETED(to_who))
		ghostize(FALSE)
		qdel(src) // No life of free invulnerability for you.
		return
	cut_summoner(different_person)
	AddComponent(/datum/component/life_link, to_who, CALLBACK(src, PROC_REF(on_harm)), CALLBACK(src, PROC_REF(on_summoner_death)))
	summoner = to_who

	for (var/action_type in control_actions)
		if (locate(action_type) in summoner.actions)
			continue
		var/datum/action/new_action = new action_type(summoner)
		new_action.Grant(summoner)

	if (different_person)
		if (mind)
			mind.enslave_mind_to_creator(to_who)
		else //mindless guardian, manually give them factions
			faction += summoner.faction
			summoner.faction += "[REF(src)]"
	remove_all_languages(LANGUAGE_MASTER)
	copy_languages(to_who, LANGUAGE_MASTER) // make sure holoparasites speak same language as master
	RegisterSignal(to_who, COMSIG_QDELETING, PROC_REF(on_summoner_deletion))
	RegisterSignal(to_who, COMSIG_LIVING_ON_WABBAJACKED, PROC_REF(on_summoner_wabbajacked))
	RegisterSignal(to_who, COMSIG_LIVING_SHAPESHIFTED, PROC_REF(on_summoner_shapeshifted))
	RegisterSignal(to_who, COMSIG_LIVING_UNSHAPESHIFTED, PROC_REF(on_summoner_unshapeshifted))
	recall(forced = TRUE)
	leash_to(src, summoner)
	if (to_who.stat == DEAD)
		on_summoner_death(src, to_who)
	summoner.updatehealth()

/// Remove all references to our summoner
/mob/living/basic/guardian/proc/cut_summoner(different_person = FALSE)
	if (isnull(summoner))
		return
	if (is_deployed())
		recall_effects()
	var/summoner_turf = get_turf(summoner)
	if (!isnull(summoner_turf))
		forceMove(summoner_turf)
	unleash()
	UnregisterSignal(summoner, list(COMSIG_QDELETING, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_SHAPESHIFTED, COMSIG_LIVING_UNSHAPESHIFTED))
	if (different_person)
		summoner.faction -= "[REF(src)]"
		faction -= summoner.faction
		mind?.remove_all_antag_datums()
	if (!length(summoner.get_all_linked_holoparasites() - src))
		for (var/action_type in control_actions)
			var/datum/action/remove_action = locate(action_type) in summoner.actions
			if (isnull(remove_action))
				continue
			remove_action.Remove(summoner)
	summoner = null

/// Connects these two mobs by a leash
/mob/living/basic/guardian/proc/leash_to(atom/movable/leashed, atom/movable/leashed_to)
	leashed.AddComponent(\
		/datum/component/leash,\
		owner = leashed_to,\
		distance = range,\
		force_teleport_out_effect = /obj/effect/temp_visual/guardian/phase/out,\
		force_teleport_in_effect = /obj/effect/temp_visual/guardian/phase,\
	)

/// Removes the leash from this guardian
/mob/living/basic/guardian/proc/unleash()
	qdel(GetComponent(/datum/component/leash))

/// Called when our owner dies. We fucked up, so now neither of us get to exist.
/mob/living/basic/guardian/proc/on_summoner_death(mob/living/source, mob/living/former_owner)
	cut_summoner()
	if (!isnull(former_owner.loc))
		forceMove(former_owner.loc)
	to_chat(src, span_danger("Your summoner has died!"))
	visible_message(span_bolddanger("\The [src] dies along with its user!"))
	former_owner.visible_message(span_bolddanger("[former_owner]'s body is completely consumed by the strain of sustaining [src]!"))
	former_owner.dust(drop_items = TRUE)

/// Called when our health changes, inform our owner of why they are getting hurt (if they are)
/mob/living/basic/guardian/proc/on_harm(mob/living/source, mob/living/summoner, amount)
	if (QDELETED(src) || QDELETED(summoner) || amount <= 2)
		return
	to_chat(summoner, span_bolddanger("[name] is under attack! You take damage!"))
	summoner.visible_message(span_bolddanger("Blood sprays from [summoner] as [src] takes damage!"))
	if(summoner.stat == UNCONSCIOUS || summoner.stat == HARD_CRIT)
		to_chat(summoner, span_bolddanger("Your head pounds, you can't take the strain of sustaining [src] in this condition!"))
		summoner.adjustOrganLoss(ORGAN_SLOT_BRAIN, amount * 0.5)

/// When our owner is deleted, we go too.
/mob/living/basic/guardian/proc/on_summoner_deletion(mob/living/source)
	SIGNAL_HANDLER
	cut_summoner()
	to_chat(src, span_danger("Your summoner is gone, you feel yourself fading!"))
	ghostize(FALSE)
	qdel(src)

/// Signal proc for [COMSIG_LIVING_ON_WABBAJACKED], when our summoner is wabbajacked we should be alerted.
/mob/living/basic/guardian/proc/on_summoner_wabbajacked(mob/living/source, mob/living/new_mob)
	SIGNAL_HANDLER
	set_summoner(new_mob)
	to_chat(src, span_holoparasite("Your summoner has changed form!"))

/// Signal proc for [COMSIG_LIVING_SHAPESHIFTED], when our summoner is shapeshifted we should change to the new mob
/mob/living/basic/guardian/proc/on_summoner_shapeshifted(mob/living/source, mob/living/new_shape)
	SIGNAL_HANDLER
	set_summoner(new_shape)
	to_chat(src, span_holoparasite("Your summoner has shapeshifted into that of a [new_shape]!"))

/// Signal proc for [COMSIG_LIVING_UNSHAPESHIFTED], when our summoner unshapeshifts go back to that mob
/mob/living/basic/guardian/proc/on_summoner_unshapeshifted(mob/living/source, mob/living/old_summoner)
	SIGNAL_HANDLER
	set_summoner(old_summoner)
	to_chat(src, span_holoparasite("Your summoner has shapeshifted back into their normal form!"))

/mob/living/basic/guardian/wabbajack(what_to_randomize, change_flags = WABBAJACK)
	visible_message(span_warning("[src] resists the polymorph!")) // Ha, no

/mob/living/basic/guardian/can_suicide()
	return FALSE // You gotta persuade your boss to end it instead, sorry

/// Returns true if you are out and about
/mob/living/basic/guardian/proc/is_deployed()
	return isnull(summoner) || loc != summoner
