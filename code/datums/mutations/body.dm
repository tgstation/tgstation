//These mutations change your overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/human/epilepsy
	name = "Epilepsy"
	desc = "A genetic defect that sporadically causes seizures."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You get a headache.</span>"

/datum/mutation/human/epilepsy/on_life()
	if(prob(1) && owner.stat == CONSCIOUS)
		owner.visible_message("<span class='danger'>[owner] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		owner.Unconscious(200)
		owner.Jitter(1000)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "epilepsy", /datum/mood_event/epilepsy)
		addtimer(CALLBACK(src, .proc/jitter_less), 90)

/datum/mutation/human/epilepsy/proc/jitter_less()
	if(owner)
		owner.jitteriness = 10


//Unstable DNA induces random mutations!
/datum/mutation/human/bad_dna
	name = "Unstable DNA"
	desc = "Strange mutation that causes the holder to randomly mutate."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel strange.</span>"
	locked = TRUE

/datum/mutation/human/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		if(prob(50))
			new_mob = owner.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		else
			new_mob = owner.randmuti()
	else
		new_mob = owner.easy_randmut(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/human/cough
	name = "Cough"
	desc = "A chronic cough."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You start coughing.</span>"

/datum/mutation/human/cough/on_life()
	if(prob(5) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")


//Dwarfism shrinks your body and lets you pass tables.
/datum/mutation/human/dwarfism
	name = "Dwarfism"
	desc = "A mutation believed to be the cause of dwarfism."
	quality = POSITIVE
	difficulty = 16
	instability = 5
	locked = TRUE    // Default intert species for now, so locked from regular pool.

/datum/mutation/human/dwarfism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.resize = 0.8
	owner.update_transform()
	owner.pass_flags |= PASSTABLE
	owner.visible_message("<span class='danger'>[owner] suddenly shrinks!</span>", "<span class='notice'>Everything around you seems to grow..</span>")

/datum/mutation/human/dwarfism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.resize = 1.25
	owner.update_transform()
	owner.pass_flags &= ~PASSTABLE
	owner.visible_message("<span class='danger'>[owner] suddenly grows!</span>", "<span class='notice'>Everything around you seems to shrink..</span>")


//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/human/clumsy
	name = "Clumsiness"
	desc = "A genome that inhibits certain brain functions, causing the holder to appear clumsy. Honk"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You feel lightheaded.</span>"

/datum/mutation/human/clumsy/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_trait(TRAIT_CLUMSY, GENETIC_MUTATION)

/datum/mutation/human/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_trait(TRAIT_CLUMSY, GENETIC_MUTATION)


//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/human/tourettes
	name = "Tourette's Syndrome"
	desc = "A chronic twitch that forces the user to scream bad words." //definitely needs rewriting
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You twitch.</span>"

/datum/mutation/human/tourettes/on_life(mob/living/carbon/human/owner)
	if(prob(10) && owner.stat == CONSCIOUS && !owner.IsStun())
		owner.Stun(200)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]", forced="tourette's syndrome")
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)


//Deafness makes you deaf.
/datum/mutation/human/deaf
	name = "Deafness"
	desc = "The holder of this genome is completely deaf."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to hear anything.</span>"

/datum/mutation/human/deaf/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_trait(TRAIT_DEAF, GENETIC_MUTATION)

/datum/mutation/human/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_trait(TRAIT_DEAF, GENETIC_MUTATION)


//Monified turns you into a monkey.
/datum/mutation/human/race
	name = "Monkified"
	desc = "A strange genome, believing to be what differentiates monkeys from humans."
	quality = NEGATIVE
	time_coeff = 2
	locked = TRUE //Species specific, keep out of actual gene pool

/datum/mutation/human/race/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	. = owner.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)

/datum/mutation/human/race/on_losing(mob/living/carbon/monkey/owner)
	if(owner && istype(owner) && owner.stat != DEAD && (owner.dna.mutations.Remove(src)))
		. = owner.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)

/datum/mutation/human/glow
	name = "Glowy"
	desc = "You permanently emit a light with a random color and intensity."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your skin begins to glow softly.</span>"
	instability = 5
	var/obj/effect/dummy/luminescent_glow/glowth //shamelessly copied from luminescents
	var/glow = 1.5

/datum/mutation/human/glow/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	glowth = new(owner)
	glowth.set_light(glow, glow, dna.features["mcolor"])

/datum/mutation/human/glow/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	qdel(glowth)

/datum/mutation/human/strong
	name = "Strength"
	desc = "The user's muscles slightly expand."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel strong.</span>"
	difficulty = 16

/datum/mutation/human/fire
	name = "Fiery Sweat"
	desc = "The user's skin will randomly combust, but is generally alot more resilient to burning."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>You feel hot.</span>"
	text_lose_indication = "<span class'notice'>You feel a lot cooler.</span>"
	difficulty = 14

/datum/mutation/human/fire/on_life()
	if(prob(1+(100-dna.stability)/10))
		owner.adjust_fire_stacks(2)
		owner.IgniteMob()

/datum/mutation/human/fire/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 0.5

/datum/mutation/human/fire/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 2




