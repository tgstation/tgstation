//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"



/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You just don't care as much as other people. That's nice to have in a place like this, I guess."
	value = 1
	mood_quirk = TRUE

/datum/quirk/apathetic/add()
	GET_COMPONENT_FROM(mood, /datum/component/mood, quirk_holder)
	if(mood)
		mood.mood_modifier = 0.8

/datum/quirk/apathetic/remove()
	GET_COMPONENT_FROM(mood, /datum/component/mood, quirk_holder)
	if(mood)
		mood.mood_modifier = 1 //Change this once/if species get their own mood modifiers.



/datum/quirk/cold_res
	name = "Cold-Defying"
	desc = "You're used to cold environments. You take less damage from intense cold, but slightly more damage from heat"
	value = 1
	gain_text = "<span class='notice'>You feel at ease in the cold.</span>"
	lose_text = "<span class='notice'>You no longer feel at ease in the cold.</span>"

/datum/quirk/cold_res/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.coldmod = species.coldmod - 0.2
	species.heatmod = species.heatmod + 0.1



/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"



/datum/quirk/heat_res
	name = "Heat-Defying"
	desc = "You're used to hot environments. You take less damage from intense heat, but slightly more damage from cold"
	value = 1
	gain_text = "<span class='notice'>You feel at ease in the heat.</span>"
	lose_text = "<span class='notice'>You no longer feel at ease in the heat.</span>"

/datum/quirk/heat_res/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.heatmod = species.heatmod - 0.2
	species.coldmod = species.coldmod - 0.1



/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	value = 1
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE



/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step, making stepping on sharp objects quieter and less painful."
	value = 1
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>You walk with a little more litheness.</span>"
	lose_text = "<span class='danger'>You start tromping around like a barbarian.</span>"



/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	value = 1
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>The shadows seem a little less dark.</span>"
	lose_text = "<span class='danger'>Everything seems a little darker.</span>"

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/eyes/eyes = H.getorgan(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	eyes.Insert(H) //refresh their eyesight and vision



/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	value = 2
	mob_trait = TRAIT_SELF_AWARE



/datum/quirk/skittish
	name = "Skittish"
	desc = "You can conceal yourself in danger. Ctrl-shift-click a closed locker to jump into it, as long as you have access."
	value = 2
	mob_trait = TRAIT_SKITTISH



/datum/quirk/spiritual
	name = "Spiritual"
	desc = "You're in tune with the gods, and your prayers may be more likely to be heard. Or not."
	value = 1
	mob_trait = TRAIT_SPIRITUAL
	gain_text = "<span class='notice'>You feel a little more faithful to the gods today.</span>"
	lose_text = "<span class='danger'>You feel less faithful in the gods.</span>"




/datum/quirk/unarmed_boxer
	name = "Unarmed Style: Boxer"
	desc = "A balanced style. Your punches are stronger and more precise. (NOTE: Only take one unarmed style)"
	value = 2
	gain_text = "<span class='notice'>You have the eye of the tiger.</span>"
	lose_text = "<span class='notice'>You forget your boxing training.</span>"

/datum/quirk/unarmed_boxer/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.punchdamagelow = initial(species.punchdamagelow) + 3
	species.punchdamagehigh =  initial(species.punchdamagehigh) + 3
	species.punchstunthreshold = initial(species.punchstunthreshold) + 3
	species.attack_verb = "cross punch"



/datum/quirk/unarmed_martialart
	name = "Unarmed Style: Martial Artist"
	desc = "All about control and discipline. Your punches do average but consistent damage and are more likely to stun opponents. (NOTE: Only take one unarmed style)"
	value = 2
	gain_text = "<span class='notice'>You focus all your might in your fists.</span>"
	lose_text = "<span class='notice'>You forget your martial arts training.</span>"

/datum/quirk/unarmed_martialart/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.punchdamagelow = initial(species.punchdamagelow) +4
	species.punchdamagehigh =  initial(species.punchdamagehigh) // Overrides this value to default in case another unarmed style is also picked
	species.punchstunthreshold = initial(species.punchstunthreshold) // see above
	species.attack_verb = "karate chopp"// not a typo, attack msg adds -ed



/datum/quirk/unarmed_slugger
	name = "Unarmed Style: Slugger"
	desc = "What you lack in finesse you make up with raw power. Your punches rarely stun but do greatly increased damage... sometimes.(NOTE: Only take one unarmed style)"
	value = 2
	gain_text = "<span class='notice'>You're itching for a fight.</span>"
	lose_text = "<span class='notice'>You forget your brawling experience.</span>"

/datum/quirk/unarmed_slugger/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	species.punchdamagelow = initial(species.punchdamagelow) // Overrides this value to default in case another unarmed style is also picked
	species.punchdamagehigh = initial(species.punchdamagehigh) + 6
	species.punchstunthreshold = initial(species.punchstunthreshold) + 6
	species.attack_verb = "clobber"



/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat twice as fast as everyone else!"
	value = 1
	mob_trait = TRAIT_VORACIOUS
	gain_text = "<span class='notice'>You feel HONGRY.</span>"
	lose_text = "<span class='danger'>You no longer feel HONGRY.</span>"
