// Various events that directly aid the wizard.
// This is the "lets entice the wizard to use summon events!" file.

/datum/round_event_control/wizard/robelesscasting //EI NUDTH!
	name = "Robeless Casting"
	weight = 2
	typepath = /datum/round_event/wizard/robelesscasting
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/robelesscasting/start()

	// Hey, if a corgi has magic missle, he should get the same benefit as anyone
	for(var/mob/living/caster as anything in GLOB.mob_living_list)
		if(!length(caster.actions))
			continue

		var/spell_improved = FALSE
		for(var/datum/action/cooldown/spell/spell in caster.actions)
			if(spell.spell_requirements & SPELL_REQUIRES_WIZARD_GARB)
				spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB
				spell_improved = TRUE

		if(spell_improved)
			to_chat(caster, span_notice("You suddenly feel like you never needed those garish robes in the first place..."))

//--//

/datum/round_event_control/wizard/improvedcasting //blink x5 disintergrate x5 here I come!
	name = "Improved Casting"
	weight = 3
	typepath = /datum/round_event/wizard/improvedcasting
	max_occurrences = 4 //because that'd be max level spells
	earliest_start = 0 MINUTES

/datum/round_event/wizard/improvedcasting/start()
	for(var/mob/living/caster as anything in GLOB.mob_living_list)
		if(!length(caster.actions))
			continue

		var/upgraded_a_spell = FALSE
		for(var/datum/action/cooldown/spell/spell in caster.actions)
			// If improved casting has already boosted this spell further beyond, go no further
			if(spell.spell_level >= spell.spell_max_level + 1)
				continue
			upgraded_a_spell = spell.level_spell(TRUE)

		if(upgraded_a_spell)
			to_chat(caster, span_notice("You suddenly feel more competent with your casting!"))
