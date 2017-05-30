
//After notransform is checked!
/mob/living/carbon/human/proc/OnHippieLifeAfterNoTransform()
	if(jobban_isbanned(src, CATBAN) && src.dna.species.name != "Catbeast") //Jobban checks here
		set_species(/datum/species/tarajan, icon_update=1)
	if(jobban_isbanned(src, CLUWNEBAN) && !dna.check_mutation(CLUWNEMUT))
		dna.add_mutation(CLUWNEMUT)
	if(client && hud_used) //HUD updates
		if(hud_used.staminas)
			hud_used.staminas.icon_state = staminahudamount()
		if(mind && hud_used.combo_object && hud_used.combo_object.cooldown < world.time)
			hud_used.combo_object.update_icon()
			mind.martial_art.streak = ""