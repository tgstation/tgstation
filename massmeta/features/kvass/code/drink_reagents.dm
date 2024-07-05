/datum/reagent/consumable/kvass
	name = "Kvass"
	description = "Kvaaaaaaass."
	color = "#351300" // rgb: 53, 19, 0
	quality = DRINK_VERYGOOD
	overdose_threshold = 50
	taste_description = "mmmmm kvass"
	ph = 6 // а точно ли 6?
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/soda_cans/kvass

/datum/reagent/consumable/kvass/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_dizzy(-1 SECONDS * REM * seconds_per_tick)
	affected_mob.adjust_drowsiness(-2 SECONDS * REM * seconds_per_tick)
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(-0.5, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.5 * REM * seconds_per_tick, required_organ_flag = ORGAN_ORGANIC)
	for(var/datum/reagent/toxin/R in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(R.type, 2.5 * REM * seconds_per_tick) // а не имба?
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/consumable/kvass/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(5 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(7.5, seconds_per_tick))
		var/list/phrase = world.file2list("massmeta/features/kvass/string/kvass.txt")
		affected_mob.say(pick(phrase), forced = /datum/reagent/consumable/kvass)
