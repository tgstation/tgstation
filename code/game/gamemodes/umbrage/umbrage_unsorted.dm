//The umbrage mutant species. They have no blood, don't need to breathe, are immune to radiation and viruses, and, most importantly, cannot wield guns. They also have night vision.
/datum/species/umbrage
	name = "Umbrage"
	id = "umbrage"
	say_mod = "chirps"
	species_traits = list(NOBREATH, NOBLOOD, RADIMMUNE, VIRUSIMMUNE, NOGUNS)

/datum/species/umbrage/spec_life(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	var/lumcount = T.get_lumcount()
	if(H.loc == T)
		if(lumcount >= 0.2) //If it's light, we die very quickly
			H << "<span class='userdanger'>The light burns you!</span>"
			H << sound('sound/weapons/sear.ogg', volume = 75) //Spam text and a sound to aggressively say "hey, you're dying"
			H.adjustFireLoss(UMBRAGE_LIGHT_BURN)
		else if(lumcount < 0.2) //But if it's dark, we heal, albeit slowly
			H.adjustBruteLoss(UMBRAGE_DARK_HEAL)
			H.adjustFireLoss(UMBRAGE_DARK_HEAL)
			H.adjustToxLoss(UMBRAGE_DARK_HEAL)
			H.adjustOxyLoss(UMBRAGE_DARK_HEAL)
			H.adjustCloneLoss(UMBRAGE_DARK_HEAL)



//Mindlink communication proc.
/mob/living/proc/umbrage_say(message)
	var/processed_message
	if(is_umbrage(mind))
		src << "<span class='velvet bold'>saa'teo</span>"
		if(!is_umbrage_progenitor(usr.mind))
			processed_message = "<span class='velvet'><b>\[Mindlink\] Umbrage [real_name]:</b> \"[message]\"</span>"
		else
			processed_message = "<span class='velvet big'><b>\[Mindlink\] Progenitor [real_name]:</b> \"[message]\"</span>" //Progenitors get big spooky text
	else if(is_veil(mind))
		processed_message = "<span class='velvet'><b>\[Mindlink\] [real_name]:</b> \"[message]\"</span>"
	else
		processed_message = "<span class='velvet'><b>\[Mindlink\] [real_name]'s Listening Bug:</b> \"[message]\"</span>"
	listclearnulls(ticker.mode.umbrages_and_veils)
	for(var/V in ticker.mode.umbrages_and_veils)
		var/datum/mind/M = V
		if(M.current.z != z || M.current.stat)
			if(prob(10))
				M.current << "<span class='warning'>Your mindlink trembles with words, but you can't make them out...</span>"
			continue
		else
			M.current << processed_message
	for(var/mob/M in dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		M << "[link] [processed_message]"
