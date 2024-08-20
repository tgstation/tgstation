/datum/symptom/spaceadapt
	name = "Space Adaptation Effect"
	desc = "Causes the infected to secrete a thin thermally insulating and spaceproof barrier from their skin."
	stage = 4
	max_count = 1
	badness = EFFECT_DANGER_HELPFUL
	chance = 10
	max_chance = 25

/datum/symptom/spaceadapt/activate(mob/living/mob)
	mob.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), type)

/datum/symptom/spaceadapt/deactivate(mob/living/carbon/mob)
	mob.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE), type)

/datum/symptom/minttoxin
	name = "Creosote Syndrome"
	desc = "Causes the infected to synthesize a wafer thin mint."
	stage = 4
	badness = EFFECT_DANGER_HARMFUL

/datum/symptom/minttoxin/activate(mob/living/carbon/mob)
	if(istype(mob) && mob.reagents?.get_reagent_amount(/datum/reagent/consumable/mintextract) < 5)
		to_chat(mob, span_notice("You feel a minty freshness"))
		mob.reagents.add_reagent(/datum/reagent/consumable/mintextract, 5)

/datum/symptom/deaf
	name = "Dead Ear Syndrome"
	desc = "Kills the infected's aural senses."
	stage = 4
	max_multiplier = 5
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/deaf/activate(mob/living/carbon/mob)
	var/obj/item/organ/internal/ears/ears = mob.get_organ_slot(ORGAN_SLOT_EARS)
	if(!ears)
		return //cutting off your ears to cure the deafness: the ultimate own
	to_chat(mob, span_userdanger("Your ears pop and begin ringing loudly!"))
	ears.deaf = min(20, ears.deaf + 15)

	if(prob(multiplier * 5))
		if(ears.damage < ears.maxHealth)
			to_chat(mob, span_userdanger("Your ears pop painfully and start bleeding!"))
			// Just absolutely murder me man
			ears.apply_organ_damage(ears.maxHealth)
			mob.emote("scream")
			ADD_TRAIT(mob, TRAIT_DEAF, type)

/datum/symptom/deaf/deactivate(mob/living/carbon/mob)
	REMOVE_TRAIT(mob, TRAIT_DEAF, type)

/datum/symptom/killertoxins
	name = "Toxification Syndrome"
	desc = "A more advanced version of Hyperacidity, causing the infected to rapidly generate toxins."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	multiplier = 3
	max_multiplier = 5

/datum/symptom/killertoxins/activate(mob/living/carbon/mob)
	mob.adjustToxLoss(5 * multiplier)

/datum/symptom/dna
	name = "Reverse Pattern Syndrome"
	desc = "Attacks the infected's DNA, causing rapid spontaneous mutation, and inhibits the ability for the infected to be affected by cryogenics."
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/symptom/dna/activate(mob/living/carbon/mob)
	mob.bodytemperature = max(mob.bodytemperature, 350)
	scramble_dna(mob, TRUE, TRUE, TRUE, rand(15, 45))
	if(mob.cloneloss <= 50)
		mob.adjustCloneLoss(10)

/datum/symptom/immortal
	name = "Longevity Syndrome"
	desc = "Grants functional immortality to the infected so long as the symptom is active. Heals broken bones and healing external damage. Creates a backlash if cured."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL
	var/total_healed = 0

/datum/symptom/immortal/activate(mob/living/carbon/mob)
	if(ishuman(mob))
		for(var/datum/wound/wound as anything in mob.all_wounds)
			to_chat(mob, span_notice("You feel the [wound] heal itself."))
			wound.remove_wound()
			break

	var/heal_amt = 5 * multiplier
	var/current_health = mob.getBruteLoss()
	if(current_health >= heal_amt)
		total_healed += heal_amt * 0.2
	else
		total_healed += (heal_amt - current_health) * 0.2
	mob.heal_overall_damage(brute = heal_amt, burn = heal_amt, updating_health = FALSE)
	mob.adjustCloneLoss(-heal_amt, updating_health = TRUE)

/datum/symptom/immortal/deactivate(mob/living/carbon/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/person = mob
		to_chat(person, span_warning("You suddenly feel hurt and old..."))
		person.age += 4 * multiplier * total_healed
	if(total_healed > 0)
		mob.take_overall_damage(brute = (total_healed / 2), burn = (total_healed / 2))

/datum/symptom/bones
	name = "Fragile Person Syndrome"
	desc = "Attacks the infected's body structure, making it more fragile."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/bones/activate(mob/living/carbon/human/victim)
	if(!ishuman(victim))
		return
	for(var/obj/item/bodypart/part in victim.bodyparts)
		part.wound_resistance -= 10

/datum/symptom/bones/deactivate(mob/living/carbon/human/victim)
	if(!ishuman(victim))
		return
	for(var/obj/item/bodypart/part in victim.bodyparts)
		part.wound_resistance += 10

/datum/symptom/fizzle
	name = "Fizzle Effect"
	desc = "Causes an ill, though harmless, sensation in the infected's throat."
	stage = 4
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/fizzle/activate(mob/living/carbon/mob)
	mob.emote("me", 1, pick("sniffles...", "clears their throat..."))

/datum/symptom/delightful
	name = "Delightful Effect"
	desc = "A more powerful version of Full Glass. Makes the infected feel delightful."
	stage = 4
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/delightful/activate(mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You feel delightful!</span>")
	if (mob.reagents?.get_reagent_amount(/datum/reagent/drug/happiness) < 5)
		mob.reagents.add_reagent(/datum/reagent/drug/happiness, 10)

/datum/symptom/spawn
	name = "Arachnogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the arachnid variety."
	stage = 4
	max_multiplier = 7
	badness = EFFECT_DANGER_HARMFUL
	var/spawn_type= /mob/living/basic/spider/growing/spiderling/guard
	var/spawn_name="spiderling"

/datum/symptom/spawn/activate(mob/living/carbon/mob)
	playsound(mob.loc, 'sound/effects/splat.ogg', vol = 50, vary = TRUE)
	var/mob/living/spawned_mob = new spawn_type(get_turf(mob))
	mob.emote("me", 1, "vomits up a live [spawn_name]!")
	if(multiplier < 4)
		addtimer(CALLBACK(src, PROC_REF(kill_mob), spawned_mob), 1 MINUTES)

/datum/symptom/spawn/proc/kill_mob(mob/living/basic/mob)
	mob.visible_message(span_warning("The [mob] falls apart!"), span_warning("You fall apart"))
	mob.death()

/datum/symptom/spawn/roach
	name = "Blattogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the blattid variety."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	spawn_type = /mob/living/basic/cockroach
	spawn_name = "cockroach"

/datum/symptom/gregarious
	name = "Gregarious Impetus"
	desc = "Infests the social structures of the infected's brain, causing them to feel better in crowds of other potential victims, and punishing them for being alone."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	max_chance = 25
	max_multiplier = 4

/datum/symptom/gregarious/activate(mob/living/carbon/mob)
	var/others_count = 0
	for(var/mob/living/carbon/m in oview(5, mob))
		others_count += 1

	if (others_count >= multiplier)
		to_chat(mob, span_notice("A friendly sensation is satisfied with how many are near you - for now."))
		mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -multiplier)
		mob.reagents.add_reagent(/datum/reagent/drug/happiness, multiplier) // ADDICTED TO HAVING FRIENDS
		if (multiplier < max_multiplier)
			multiplier += 0.15 // The virus gets greedier
	else
		to_chat(mob, span_warning("A hostile sensation in your brain stings you... it wants more of the living near you."))
		mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, multiplier / 2)
		mob.AdjustParalyzed(multiplier) // This practically permaparalyzes you at higher multipliers but
		mob.AdjustKnockdown(multiplier) // that's your fucking fault for not being near enough people
		mob.AdjustStun(multiplier)   // You'll have to wait until the multiplier gets low enough
		if (multiplier > 1)
			multiplier -= 0.3 // The virus tempers expectations

/datum/symptom/magnitis
	name = "Magnitis"
	desc = "This disease disrupts the magnetic field of the body, making it act as if a powerful magnet."
	stage = 4
	badness = EFFECT_DANGER_DEADLY
	chance = 5
	max_chance = 20

/datum/symptom/magnitis/activate(mob/living/carbon/mob)
	if(mob.reagents.has_reagent(/datum/reagent/iron))
		return

	var/intensity = 1 + (count > 10) + (count > 20)
	if (prob(20))
		to_chat(mob, span_warning("You feel a [intensity < 3 ? "slight" : "powerful"] shock course through your body."))
	for(var/obj/thingy in orange(3 * intensity, mob))
		if(!thingy.anchored || thingy.move_resist > MOVE_FORCE_STRONG)
			continue
		var/iter = rand(1, intensity)
		for(var/i in 0 to iter)
			step_towards(thingy, mob)
	for(var/mob/living/silicon/robutt in orange(3 * intensity,mob))
		if(isAI(robutt))
			continue
		var/iter = rand(1, intensity)
		for(var/i in 0 to iter)
			step_towards(robutt, mob)

/*/datum/symptom/dnaspread //commented out due to causing enough problems to turn random people into monkies apon curing.
	name = "Retrotransposis"
	desc = "This symptom transplants the genetic code of the intial vector into new hosts."
	badness = EFFECT_DANGER_HARMFUL
	stage = 4
	var/datum/dna/saved_dna
	var/original_name
	var/activated = 0
	///old info
	var/datum/dna/old_dna
	var/old_name

/datum/symptom/dnaspread/activate(mob/living/carbon/mob)
	if(!activated)
		to_chat(mob, span_warning("You don't feel like yourself.."))
		old_dna = new
		C.dna.copy_dna(old_dna)
		old_name = C.real_name

	if(!iscarbon(mob))
		return
	var/mob/living/carbon/C = mob
	if(!saved_dna)
		saved_dna = new
		original_name = C.real_name
		C.dna.copy_dna(saved_dna)
	C.regenerate_icons()
	saved_dna.copy_dna(C.dna)
	C.real_name = original_name
	activated = TRUE

/datum/symptom/dnaspread/deactivate(mob/living/carbon/mob)
	activated = FALSE
	if(!old_dna)
		return
	old_dna.copy_dna(C.dna)
	C.real_name = old_name

/datum/symptom/dnaspread/Copy(datum/disease/advanced/disease)
	var/datum/symptom/dnaspread/new_e = ..(disease)
	new_e.original_name = original_name
	new_e.saved_dna = saved_dna
	return new_e

/datum/symptom/species
	name = "Lizarditis"
	desc = "Turns you into a Lizard."
	badness = EFFECT_DANGER_HARMFUL
	stage = 4
	var/datum/species/old_species
	var/datum/species/new_species = /datum/species/lizard
	max_count = 1
	max_chance = 24

/datum/symptom/species/activate(mob/living/carbon/mob)
	var/mob/living/carbon/human/victim = mob
	if(!ishuman(victim))
		return
	old_species = mob.dna.species
	if(!old_species)
		return
	victim.set_species(new_species)

/datum/symptom/species/deactivate(mob/living/carbon/mob)
	var/mob/living/carbon/human/victim = mob
	if(!ishuman(victim))
		return
	if(!old_species)
		return
	victim.set_species(old_species)

/datum/symptom/species/moth
	name = "Mothification"
	desc = "Turns you into a Moth."
	new_species = /datum/species/moth
*/
/datum/symptom/retrovirus
	name = "Retrovirus"
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	max_multiplier = 4
	stage = 4
	badness = EFFECT_DANGER_HARMFUL

/datum/symptom/retrovirus/activate(mob/living/carbon/affected_mob)
	if(!iscarbon(affected_mob))
		return
	switch(multiplier)
		if(1)
			if(prob(4))
				to_chat(affected_mob, span_danger("Your head hurts."))
			if(prob(4.5))
				to_chat(affected_mob, span_danger("You feel a tingling sensation in your chest."))
			if(prob(4.5))
				to_chat(affected_mob, span_danger("You feel angry."))
		if(2)
			if(prob(4))
				to_chat(affected_mob, span_danger("Your skin feels loose."))
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel very strange."))
			if(prob(2))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head!"))
				affected_mob.Unconscious(40)
			if(prob(2))
				to_chat(affected_mob, span_danger("Your stomach churns."))
		if(3)
			if(prob(5))
				to_chat(affected_mob, span_danger("Your entire body vibrates."))
			if(prob(19))
				switch(rand(1,3))
					if(1)
						scramble_dna(affected_mob, 1, 0, 0, rand(15,45))
					if(2)
						scramble_dna(affected_mob, 0, 1, 0, rand(15,45))
					if(3)
						scramble_dna(affected_mob, 0, 0, 1, rand(15,45))
		if(4)
			if(prob(37))
				switch(rand(1,3))
					if(1)
						scramble_dna(affected_mob, 1, 0, 0, rand(50,75))
					if(2)
						scramble_dna(affected_mob, 0, 1, 0, rand(50,75))
					if(3)
						scramble_dna(affected_mob, 0, 0, 1, rand(50,75))

/datum/symptom/rhumba_beat
	name = "The Rhumba Beat"
	desc = "Chick Chicky Boom!"
	max_multiplier = 5
	stage = 4
	badness = EFFECT_DANGER_DEADLY

/datum/symptom/rhumba_beat/activate(mob/living/carbon/affected_mob)
	if(ismouse(affected_mob))
		affected_mob.gib()
		return
	multiplier += 0.1

	switch(round(multiplier))
		if(2)
			if(prob(26))
				affected_mob.take_overall_damage(burn = 5)
			if(prob(0.5))
				to_chat(affected_mob, span_danger("You feel strange..."))
		if(3)
			if(prob(2.5))
				to_chat(affected_mob, span_danger("You feel the urge to dance..."))
			else if(prob(2.5))
				affected_mob.emote("gasp")
			else if(prob(5))
				to_chat(affected_mob, span_danger("You feel the need to chick chicky boom..."))
		if(4)
			if(prob(10))
				if(prob(50))
					affected_mob.adjust_fire_stacks(2)
					affected_mob.ignite_mob()
				else
					affected_mob.emote("gasp")
					to_chat(affected_mob, span_danger("You feel a burning beat inside..."))
		if(5)
			to_chat(affected_mob, span_danger("Your body is unable to contain the Rhumba Beat..."))
			if(prob(29))
				explosion(affected_mob, devastation_range = -1, light_impact_range = 2, flame_range = 2, flash_range = 3, adminlog = FALSE, explosion_cause = src) // This is equivalent to a lvl 1 fireball
				multiplier -= 3


/datum/symptom/adaptation
	name = "Inorganic Biology"
	desc = "The virus can survive and replicate even in an inorganic environment, increasing its resistance and infection rate."
	max_count = 1
	stage = 4
	badness = EFFECT_DANGER_FLAVOR
	var/biotypes = MOB_MINERAL | MOB_ROBOTIC

/datum/symptom/adaptation/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	disease.infectable_biotypes |= biotypes

/datum/symptom/adaptation/deactivate(mob/living/carbon/mob, datum/disease/advanced/disease)
	disease.infectable_biotypes &= ~(biotypes)

/datum/symptom/adaptation/undead
	name = "Necrotic Metabolism"
	desc = "The virus is able to thrive and act even within dead hosts."
	biotypes = MOB_UNDEAD

/datum/symptom/adaptation/undead/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	.=..()
	disease.process_dead = TRUE

/datum/symptom/adaptation/undead/deactivate(mob/living/carbon/mob, datum/disease/advanced/disease)
	.=..()
	disease.process_dead = FALSE

/datum/symptom/oxygen
	name = "Self-Respiration"
	desc = "The virus synthesizes oxygen, which can remove the need for breathing at high symptom strength."
	stage = 4
	max_multiplier = 5
	badness = EFFECT_DANGER_HELPFUL
	var/breathing = TRUE

/datum/symptom/oxygen/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	mob.losebreath = max(0, mob.losebreath - multiplier)
	mob.adjustOxyLoss(-2 * multiplier)
	if(multiplier >= 4)
		to_chat(mob, span_notice("[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]"))
		if(breathing)
			breathing = FALSE
			ADD_TRAIT(mob, TRAIT_NOBREATH, type)

/datum/symptom/oxygen/deactivate(mob/living/carbon/mob, datum/disease/advanced/disease)
	if(!breathing)
		breathing = TRUE
		REMOVE_TRAIT(mob, TRAIT_NOBREATH, type)
		mob.emote("gasp")
		to_chat(mob, span_notice("You feel the need to breathe again."))
