//in this file: Various events that directly aid the wizard. This is the "lets entice the wizard to use summon events!" file.

/datum/round_event_control/wizard/robelesscasting //EI NUDTH!
	name = "Robeless Casting"
	weight = 2
	typepath = /datum/round_event/wizard/robelesscasting
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/robelesscasting/start()

	for(var/i in GLOB.mob_living_list) //Hey if a corgi has magic missle he should get the same benifit as anyone
		var/mob/living/L = i
		if(L.mind && L.mind.spell_list.len != 0)
			var/spell_improved = FALSE
			for(var/obj/effect/proc_holder/spell/S in L.mind.spell_list)
				if(S.clothes_req)
					S.clothes_req = 0
					spell_improved = TRUE
			if(spell_improved)
				to_chat(L, "<span class='notice'>You suddenly feel like you never needed those garish robes in the first place...</span>")

//--//

/datum/round_event_control/wizard/improvedcasting //blink x5 disintergrate x5 here I come!
	name = "Improved Casting"
	weight = 3
	typepath = /datum/round_event/wizard/improvedcasting
	max_occurrences = 4 //because that'd be max level spells
	earliest_start = 0 MINUTES

/datum/round_event/wizard/improvedcasting/start()
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(L.mind && L.mind.spell_list.len != 0)
			for(var/obj/effect/proc_holder/spell/S in L.mind.spell_list)
				S.UpdateSpellLevel(S.spell_level + 1)
			to_chat(L, "<span class='notice'>You suddenly feel more competent with your casting!</span>")
	for(var/obj/item/book/granter/spell/B in GLOB.spellbooks)
		B.level_up_book(pick(1,2), TRUE)
