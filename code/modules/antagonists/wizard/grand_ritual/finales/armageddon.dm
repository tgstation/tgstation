#define DOOM_SINGULARITY "singularity"
#define DOOM_TESLA "tesla"
#define DOOM_METEORS "meteors"

/// Kill yourself and probably a bunch of other people
/datum/grand_finale/armageddon
	name = "Annihilation"
	desc = "This crew have offended you beyond the realm of pranks. Make the ultimate sacrifice to teach them a lesson your elders can really respect. \
		YOU WILL NOT SURVIVE THIS."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	minimum_time = 90 MINUTES // This will probably immediately end the round if it gets finished.
	ritual_invoke_time = 60 SECONDS // Really give the crew some time to interfere with this one.
	dire_warning = TRUE
	glow_colour = "#be000048"
	/// Things to yell before you die
	var/static/list/possible_last_words = list(
		"Flames and ruin!",
		"Dooooooooom!!",
		"HAHAHAHAHAHA!! AHAHAHAHAHAHAHAHAA!!",
		"Hee hee hee!! Hoo hoo hoo!! Ha ha haaa!!",
		"Ohohohohohoho!!",
		"Cower in fear, puny mortals!",
		"Tremble before my glory!",
		"Pick a god and pray!",
		"It's no use!",
		"If the gods wanted you to live, they would not have created me!",
		"God stays in heaven out of fear of what I have created!",
		"Ruination is come!",
		"All of creation, bend to my will!",
	)

/datum/grand_finale/armageddon/trigger(mob/living/carbon/human/invoker)
	priority_announce(pick(possible_last_words), null, 'sound/magic/voidblink.ogg', sender_override = "[invoker.real_name]")
	var/turf/current_location = get_turf(invoker)
	invoker.gib()

	var/static/list/doom_options = list()
	if (!length(doom_options))
		doom_options = list(DOOM_SINGULARITY, DOOM_TESLA)
		if (!SSmapping.config.planetary)
			doom_options += DOOM_METEORS

	switch(pick(doom_options))
		if (DOOM_SINGULARITY)
			var/obj/singularity/singulo = new(current_location)
			singulo.energy = 300
		if (DOOM_TESLA)
			var/obj/energy_ball/tesla = new (current_location)
			tesla.energy = 200
		if (DOOM_METEORS)
			var/datum/dynamic_ruleset/roundstart/meteor/meteors = new()
			meteors.meteordelay = 0
			var/datum/game_mode/dynamic/mode = SSticker.mode
			mode.execute_roundstart_rule(meteors) // Meteors will continue until morale is crushed.
			priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS)

/**
 * Gives the wizard a defensive/mood buff and a Wabbajack, a juiced up chaos staff that will surely break something.
 * Everyone but the wizard goes crazy, suffers major brain damage, and is given a vendetta against the wizard.
 * Already insane people are instead cured of their madness, ignoring any other effects as the station around them loses its marbles.
 */
/datum/grand_finale/cheese
	// we don't set name, desc and others, thus we won't appear in the radial choice of a normal finale rune
	dire_warning = TRUE
	minimum_time = 45 MINUTES //i'd imagine speedrunning this would be crummy, but the wizard's average lifespan is barely reaching this point

/datum/grand_finale/cheese/trigger(mob/living/invoker)
	message_admins("[key_name(invoker)] has summoned forth The Wabbajack and cursed the crew with madness!")
	priority_announce("Danger: Extremely potent reality altering object has been summoned on station. Immediate evacuation advised. Brace for impact.", "Central Command Higher Dimensional Affairs", 'sound/effects/glassbr1.ogg')

	for (var/mob/living/carbon/human/crewmate as anything in GLOB.human_list)
		if (isnull(crewmate.mind))
			continue
		if (crewmate == invoker) //everyone but the wizard is royally fucked, no matter who they are
			continue
		if (crewmate.has_trauma_type(/datum/brain_trauma/mild/hallucinations)) //for an already insane person, this is retribution
			to_chat(crewmate, span_boldwarning("Your surroundings suddenly fill with a cacophony of manic laughter and psychobabble..."))
			to_chat(crewmate, span_nicegreen("...but as the moment passes, you realise that whatever eldritch power behind the event happened to affect you \
				has resonated within the ruins of your already shattered mind, creating a singularity of mental instability! \
				As it collapses unto itself, you feel... at peace, finally."))
			if(crewmate.has_quirk(/datum/quirk/insanity))
				crewmate.remove_quirk(/datum/quirk/insanity)
			else
				crewmate.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		else
			//everyone else gets to relish in madness
			//yes killing their mood will also trigger mood hallucinations
			create_vendetta(crewmate.mind, invoker.mind)
			to_chat(crewmate, span_boldwarning("Your surroundings suddenly fill with a cacophony of manic laughter and psychobabble. \n\
				You feel your inner psyche shatter into a myriad pieces of jagged glass of colors unknown to the universe, \
				infinitely reflecting a blinding, maddening light coming from the innermost sanctums of your destroyed mind. \n\
				After a brief pause which felt like a millenia, one phrase rebounds ceaselessly in your head, imbued with the false hope of absolution... \n\
				<b>[invoker] must die.</b>"))
			var/datum/brain_trauma/mild/hallucinations/added_trauma = new()
			added_trauma.resilience = TRAUMA_RESILIENCE_ABSOLUTE
			crewmate.adjustOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH - 25, BRAIN_DAMAGE_DEATH - 25) //you'd better hope chap didn't pick a hypertool
			crewmate.gain_trauma(added_trauma)
			crewmate.add_mood_event("wizard_ritual_finale", /datum/mood_event/madness_despair)

	//drip our wizard out
	invoker.apply_status_effect(/datum/status_effect/blessing_of_insanity)
	invoker.add_mood_event("wizard_ritual_finale", /datum/mood_event/madness_elation)
	var/obj/item/gun/magic/staff/chaos/true_wabbajack/the_wabbajack = new
	invoker.put_in_active_hand(the_wabbajack)
	to_chat(invoker, span_mind_control("Your every single instinct and rational thought is screaming at you as [the_wabbajack] appears in your firm grip..."))

#undef DOOM_SINGULARITY
#undef DOOM_TESLA
#undef DOOM_METEORS
