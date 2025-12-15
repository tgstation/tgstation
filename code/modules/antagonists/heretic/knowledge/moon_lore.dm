/datum/heretic_knowledge_tree_column/moon
	route = PATH_MOON
	ui_bgr = "node_moon"
	complexity = "Hard"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "moon_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Moon revolves around sanity, sowing confusion and discord, and skirting the conventional rules of combat.",
		"Play this path if you are already experienced with Heretic and want to try something highly unconventional, or simply if you desire to play a pacifist Heretic (Yes, really!)."
	)
	pros = list(
		"High amount of tools to confound foes.",
		"Sows chaos through the station via lunatics.",
		"Practically immune to disabling effects while wearing the Resplendent Regalia."
	)
	cons = list(
		"No mobility.",
		"Mo direct tools to damage your opponents.",
		"Reliant on misdirection and confusion.",
		"Lunatics can become liabilities.",
		"Fairly fragile despite their unique protection mechanics.",
		"Death while wearing the Resplendent Regalia results in a gorey end.",
	)
	tips = list(
		"Your Mansus Grasp will make your victim briefly hallucinate and apply a mark that, when triggered by your moon blade, will apply confusion and pacify them (the latter will get removed if the victim receives too much damage at once).",
		"Your moon blade is special compared to the other heretic blades. It can be used even if you are pacified.",
		"Your passive makes you completely impervious to brain traumas and slowly regenerates your brain health. Makes sure to upgrade it to bolster the regeneration effect.",
		"Your Resplendent Regalia utterly changes the rules of combat for you and your opponents; You become fully immune to disabling effect, and all damage received (lethal or non lethal) will be converted into brain damage. However. the robes themselves have no armor, and prevent you from using guns as well as pacifying you (you can still use your moon blade).",
		"Your moon amulette allows you to channel its effects through your moon blade. When toggled on, your Moon blade will no longer do lethal damage, but do sanity damage and become unblockable, this also allows you to use it while wearing your robes!",
		"Your moon amulette is a vital part of your kit, as it allows your passive to regenerate double the brain health while worn.",
		"If the sanity of your opponents goes below  a certain threshold, they'll become a lunatic. Lunatics are prompted to start attacking everyone (including you). Should you want to sacrifice them (or to get them to leave you be), hit them again with your moon blade to put them to sleep.",
		"Ringleader's Rise summons an army of clones. They do barely any damage, but should they be attacked by non-heretics, they will explode and cause sanity and brain damage to those around them.",
		"Your ascension will grant you an aura that converts nearby people to loyal lunatics. However, if they have a mindshield implant, their heads will instead detonate after a time.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_moon
	knowledge_tier1 = /datum/heretic_knowledge/spell/mind_gate
	guaranteed_side_tier1 = /datum/heretic_knowledge/phylactery
	knowledge_tier2 = /datum/heretic_knowledge/moon_amulet
	guaranteed_side_tier2 = /datum/heretic_knowledge/codex_morbus
	robes = /datum/heretic_knowledge/armor/moon
	knowledge_tier3 = /datum/heretic_knowledge/spell/moon_parade
	guaranteed_side_tier3 = /datum/heretic_knowledge/unfathomable_curio
	blade = /datum/heretic_knowledge/blade_upgrade/moon
	knowledge_tier4 = /datum/heretic_knowledge/spell/moon_ringleader
	ascension = /datum/heretic_knowledge/ultimate/moon_final

/datum/heretic_knowledge/limited_amount/starting/base_moon
	name = "Moonlight Troupe"
	desc = "Opens up the Path of Moon to you. \
		Allows you to transmute 2 sheets of glass and a knife into an Lunar Blade. \
		You can only create two at a time."
	gain_text = "Under the light of the moon the laughter echoes."
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/glass = 2,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/moon)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "moon_blade"
	mark_type = /datum/status_effect/eldritch/moon
	eldritch_passive = /datum/status_effect/heretic_passive/moon

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	user.AddComponentFrom(REF(src), /datum/component/empathy, seen_it = TRUE, visible_info = ALL, self_empath = FALSE, sense_dead = FALSE, sense_whisper = TRUE, smite_target = FALSE)

/datum/heretic_knowledge/limited_amount/starting/base_moon/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		to_chat(target, span_danger("You hear echoing laughter from above..but it is dull and distant."))
		return

	source.apply_status_effect(/datum/status_effect/moon_grasp_hide)

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	to_chat(carbon_target, span_danger("You hear echoing laughter from above"))
	carbon_target.cause_hallucination(/datum/hallucination/delusion/preset/moon, "delusion/preset/moon hallucination caused by mansus grasp")
	carbon_target.mob_mood.adjust_sanity(-30)

/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Grants you Mind Gate, a spell which mutes,deafens, blinds, inflicts hallucinations, \
		confusion, oxygen loss and brain damage to its target over 10 seconds.\
		The caster takes 20 brain damage per use."
	gain_text = "My mind swings open like a gate, and its insight will let me perceive the truth."

	action_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 2

/datum/heretic_knowledge/moon_amulet
	name = "Moonlight Amulet"
	desc = "Allows you to transmute 2 sheets of glass, a heart and a tie to create a Moonlight Amulet. \
			If the item is used on someone with low sanity they go berserk attacking everyone, \
			if their sanity isn't low enough it decreases their mood. \
			Wearing this will grant you the ability to see heathens through walls and make your blades harmless, they will instead directly attack their mind. \
			Provides thermal vision and doubles the brain regen of a moon heretic while worn."
	gain_text = "At the head of the parade he stood, the moon condensed into one mass, a reflection of the soul."

	required_atoms = list(
		/obj/item/organ/heart = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/clothing/neck/tie = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulet)
	cost = 2

	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "moon_amulette"
	research_tree_icon_frame = 9

/datum/heretic_knowledge/armor/moon
	desc = "Allows you to transmute a table (or a suit), a mask and two sheets of glass to create a Resplendant Regalia, this robe will render the user   fully immune to disabling effects and convert all forms of damage into brain damage, while also pacifying the user and render him unable to use ranged weapons (Moon blade will bypass pacifism). \
			Acts as a focus while hooded."
	gain_text = "Trails of light and mirth flowed from every arm of this magnificent attire. \
				The troupe twirled in irridescent cascades, dazzling onlookers with the truth they sought. \
				I observed, basking in the light, to find my self."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon)
	research_tree_icon_state = "moon_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/datum/heretic_knowledge/spell/moon_parade
	name = "Lunar Parade"
	desc = "Grants you Lunar Parade, a spell that - after a short charge - sends a carnival forward \
		when hitting someone they are forced to join the parade and suffer hallucinations."
	gain_text = "The music like a reflection of the soul compelled them, like moths to a flame they followed"
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/moon_parade
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/blade_upgrade/moon
	name = "Moonlight Blade"
	desc = "Your blade now deals brain damage, causes  random hallucinations and does sanity damage. \
			Deals more brain damage if your victim is insane or unconscious."
	gain_text = "His wit was sharp as a blade, cutting through the lie to bring us joy."

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_moon"

/datum/heretic_knowledge/blade_upgrade/moon/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE_MOON))
		return

	target.cause_hallucination( \
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"upgraded path of moon blades", \
		)
	target.emote(pick("giggle", "laugh"))
	target.mob_mood?.adjust_sanity(-10)
	if(target.stat == CONSCIOUS && target.mob_mood?.sanity >= SANITY_NEUTRAL)
		target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 10)
		return
	target.adjust_organ_loss(ORGAN_SLOT_BRAIN, 25)

/datum/heretic_knowledge/spell/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Grants you Ringleaders Rise, an AoE spell that deals more brain damage the lower the sanity of everyone in the AoE \
			and causes hallucinations, with those who have less sanity getting more. \
			If their sanity is low enough this turns them insane, the spell then halves their sanity."
	gain_text = "I grabbed his hand and we rose, those who saw the truth rose with us. \
		The ringleader pointed up and the dim light of truth illuminated us further."

	action_to_add = /datum/action/cooldown/spell/aoe/moon_ringleader
	cost = 2

	research_tree_icon_frame = 5
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/moon_final
	name = "The Last Act"
	desc = "The ascension ritual of the Path of Moon. \
		Bring 3 corpses with more than 50 brain damage to a transmutation rune to complete the ritual. \
		When completed, you become a harbinger of madness gaining and aura of passive sanity decrease, \
		crewmembers with low enough sanity will be converted into acolytes. \
		1/5th of the crew will turn into acolytes and follow your command, they will all receive moonlight amulets."
	gain_text = "We dived down towards the crowd, his soul splitting off in search of greater venture \
		for where the Ringleader had started the parade, I shall continue it unto the suns demise \
		WITNESS MY ASCENSION, THE MOON SMILES ONCE MORE AND FOREVER MORE IT SHALL!"

	ascension_achievement = /datum/award/achievement/misc/moon_ascension
	announcement_text = "%SPOOKY% Laugh, for the ringleader %NAME% has ascended! \
						The truth shall finally devour the lie! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_moon.ogg'

/datum/heretic_knowledge/ultimate/moon_final/is_valid_sacrifice(mob/living/sacrifice)

	var/brain_damage = sacrifice.get_organ_loss(ORGAN_SLOT_BRAIN)
	// Checks if our target has enough brain damage
	if(brain_damage < 50)
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/moon_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	ADD_TRAIT(user, TRAIT_MADNESS_IMMUNE, type)
	user.mind.add_antag_datum(/datum/antagonist/lunatic/master)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	var/amount_of_lunatics = 0
	var/list/lunatic_candidates = list()
	for(var/mob/living/carbon/human/crewmate as anything in shuffle(GLOB.human_list))
		if(QDELETED(crewmate) || isnull(crewmate.client) || isnull(crewmate.mind) || crewmate.stat != CONSCIOUS || crewmate.can_block_magic(MAGIC_RESISTANCE_MIND))
			continue
		var/turf/crewmate_turf = get_turf(crewmate)
		var/crewmate_z = crewmate_turf?.z
		if(!is_station_level(crewmate_z))
			continue
		lunatic_candidates += crewmate

	// Roughly 1/5th of the station will rise up as lunatics to the heretic.
	// We use either the (locked) manifest for the maximum, or the amount of candidates, whichever is larger.
	// If there's more eligible humans than crew, more power to them I guess.
	var/max_lunatics = ceil(max(length(GLOB.manifest.locked), length(lunatic_candidates)) * 0.2)

	for(var/mob/living/carbon/human/crewmate as anything in lunatic_candidates)
		if(amount_of_lunatics > max_lunatics)
			to_chat(crewmate, span_boldwarning("You feel uneasy, as if for a brief moment something was gazing at you."))
			continue
		if(attempt_conversion(crewmate, user))
			amount_of_lunatics++

/datum/heretic_knowledge/ultimate/moon_final/proc/attempt_conversion(mob/living/carbon/convertee, mob/user)
	// Heretics, lunatics and monsters shouldn't become lunatics because they either have a master or have a mansus grasp
	if(IS_HERETIC_OR_MONSTER(convertee))
		to_chat(convertee, span_boldwarning("[user]'s rise is influencing those who are weak willed. Their minds shall rend." ))
		return FALSE
	// Mindshielded and anti-magic folks are immune against this effect because this is a magical mind effect
	if(HAS_MIND_TRAIT(convertee, TRAIT_UNCONVERTABLE) || convertee.can_block_magic(MAGIC_RESISTANCE))
		to_chat(convertee, span_boldwarning("You feel shielded from something." ))
		return FALSE

	if(!convertee.mind)
		return FALSE

	var/datum/antagonist/lunatic/lunatic = convertee.mind.add_antag_datum(/datum/antagonist/lunatic)
	lunatic.set_master(user.mind, user)
	var/obj/item/clothing/neck/heretic_focus/moon_amulet/amulet = new(convertee.drop_location())
	var/static/list/slots = list(
		LOCATION_NECK,
		LOCATION_HANDS,
		LOCATION_RPOCKET,
		LOCATION_LPOCKET,
		LOCATION_BACKPACK,
	)
	convertee.equip_in_one_of_slots(amulet, slots, qdel_on_fail = FALSE)
	INVOKE_ASYNC(convertee, TYPE_PROC_REF(/mob, emote), "laugh")
	return TRUE

/datum/heretic_knowledge/ultimate/moon_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	visible_hallucination_pulse(
		center = get_turf(source),
		radius = 7,
		hallucination_duration = 60 SECONDS
	)

	for(var/mob/living/carbon/carbon_view in range(7, source))
		var/carbon_sanity = carbon_view.mob_mood.sanity
		if(carbon_view.stat != CONSCIOUS)
			continue
		if(IS_HERETIC_OR_MONSTER(carbon_view))
			continue
		if(carbon_view.can_block_magic(MAGIC_RESISTANCE_MOON)) //Somehow a shitty piece of tinfoil is STILL able to hold out against the power of an ascended heretic.
			continue
		new /obj/effect/temp_visual/moon_ringleader(get_turf(carbon_view))
		if(carbon_view.has_status_effect(/datum/status_effect/confusion))
			to_chat(carbon_view, span_big(span_hypnophrase("YOUR HEAD RATTLES WITH A THOUSAND VOICES JOINED IN A MADDENING CACOPHONY OF SOUND AND MUSIC. EVERY FIBER OF YOUR BEING SAYS 'RUN'.")))
		carbon_view.adjust_confusion(2 SECONDS)
		carbon_view.mob_mood.adjust_sanity(-20)

		if(carbon_sanity >= 10)
			return
		// So our sanity is dead, time to fuck em up
		if(SPT_PROB(20, seconds_per_tick))
			to_chat(carbon_view, span_warning("it echoes through you!"))
		visible_hallucination_pulse(
			center = get_turf(carbon_view),
			radius = 7,
			hallucination_duration = 50 SECONDS
		)
		carbon_view.adjust_temp_blindness(5 SECONDS)
		if(should_mind_explode(carbon_view))
			to_chat(carbon_view, span_boldbig(span_red(\
				"YOUR SENSES REEL AS YOUR MIND IS ENVELOPED BY AN OTHERWORLDLY FORCE ATTEMPTING TO REWRITE YOUR VERY BEING. \
				YOU CANNOT EVEN BEGIN TO SCREAM BEFORE YOUR IMPLANT ACTIVATES ITS PSIONIC FAIL-SAFE PROTOCOL, TAKING YOUR HEAD WITH IT.")))
			var/obj/item/bodypart/head/head = locate() in carbon_view.bodyparts
			if(head)
				head.dismember()
			else
				carbon_view.gib(DROP_ALL_REMAINS)
			var/datum/effect_system/reagents_explosion/explosion = new()
			explosion.set_up(1, get_turf(carbon_view), TRUE, 0)
			explosion.start(src)
		else
			attempt_conversion(carbon_view, source)


/datum/heretic_knowledge/ultimate/moon_final/proc/should_mind_explode(mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		return TRUE
	if(IS_CULTIST_OR_CULTIST_MOB(target))
		return TRUE
	return FALSE
