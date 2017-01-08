//The umbrage mutant species. They have no blood, don't need to breathe, are immune to radiation and viruses, and, most importantly, cannot wield guns. They also have night vision.
/datum/species/umbrage
	name = "Umbrage"
	id = "umbrage"
	darksight = 8
	invis_sight = SEE_INVISIBLE_MINIMUM
	sexes = 0
	blacklisted = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBREATH, NOBLOOD, RADIMMUNE, VIRUSIMMUNE, NOGUNS)
	dangerous_existence = 1
	var/datum/action/innate/shadow/darkvision/vision_toggle

/datum/species/umbrage/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	vision_toggle = new
	vision_toggle.Grant(C)

/datum/species/umbrage/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(vision_toggle)
		vision_toggle.Remove(C)

/datum/species/umbrage/spec_life(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	var/lumcount = T.get_lumcount()
	if(lumcount > 3) //If it's light, we die very quickly
		H << "<span class='userdanger'>The light burns you!</span>"
		H << sound('sound/weapons/sear.ogg', volume = 75) //Spam text and a sound to aggressively say "hey, you're dying"
		H.adjustFireLoss(UMBRAGE_LIGHT_BURN)
	if(lumcount < 4) //But if it's dark, we heal, albeit slowly
		H.adjustBruteLoss(UMBRAGE_DARK_HEAL)
		H.adjustFireLoss(UMBRAGE_DARK_HEAL)
		H.adjustToxLoss(UMBRAGE_DARK_HEAL)
		H.adjustOxyLoss(UMBRAGE_DARK_HEAL)
		H.adjustCloneLoss(UMBRAGE_DARK_HEAL)



//Mindlink communication proc.
/mob/living/proc/umbrage_say(message)
	var/processed_message
	if(is_umbrage(mind))
		if(!is_umbrage_progenitor(usr.mind))
			processed_message = "<span class='velvet'><b>\[Mindlink\] Umbrage [real_name]:</b> \"[message]\"</span>"
		else
			processed_message = "<span class='velvet_large'><b>\[Mindlink\] Progenitor [real_name]:</b> \"[message]\"</span>" //Progenitors get big spooky text
	else if(is_veil(mind))
		processed_message = "<span class='velvet'><b>\[Mindlink\] [real_name]:</b> \"[message]\""
	else
		return 0 //How are you doing this in the first place?
	src << "<span class='velvet_bold'>saa'teo</span>"
	for(var/V in ticker.mode.umbrages_and_veils)
		var/datum/mind/M = V
		if(M.current.z != z)
			if(prob(10))
				M.current << "<span class='warning'>Your mindlink trembles with words, but you're too far away to make it out...</span>"
			continue
		else
			M.current << processed_message
	for(var/mob/M in dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		M << "[link] [processed_message]"
