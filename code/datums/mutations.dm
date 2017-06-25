GLOBAL_LIST_EMPTY(mutations_list)

/datum/mutation

	var/name

/datum/mutation/New()
	GLOB.mutations_list[name] = src

/datum/mutation/human

	var/dna_block
	var/quality
	var/get_chance = 100
	var/lowest_value = 256 * 8
	var/text_gain_indication = ""
	var/text_lose_indication = ""
	var/list/mutable_appearance/visual_indicators = list()
	var/layer_used = MUTATIONS_LAYER //which mutation layer to use
	var/list/species_allowed = list() //to restrict mutation to only certain species
	var/health_req //minimum health required to acquire the mutation
	var/limb_req //required limbs to acquire this mutation
	var/time_coeff = 1 //coefficient for timed mutations

/datum/mutation/human/proc/force_give(mob/living/carbon/human/owner)
	set_block(owner)
	. = on_acquiring(owner)

/datum/mutation/human/proc/force_lose(mob/living/carbon/human/owner)
	set_block(owner, 0)
	. = on_losing(owner)

/datum/mutation/human/proc/set_se(se_string, on = 1)
	if(!se_string || lentext(se_string) < DNA_STRUC_ENZYMES_BLOCKS * DNA_BLOCK_SIZE)
		return
	var/before = copytext(se_string, 1, ((dna_block - 1) * DNA_BLOCK_SIZE) + 1)
	var/injection = num2hex(on ? rand(lowest_value, (256 * 16) - 1) : rand(0, lowest_value - 1), DNA_BLOCK_SIZE)
	var/after = copytext(se_string, (dna_block * DNA_BLOCK_SIZE) + 1, 0)
	return before + injection + after

/datum/mutation/human/proc/set_block(mob/living/carbon/owner, on = 1)
	if(owner && owner.has_dna())
		owner.dna.struc_enzymes = set_se(owner.dna.struc_enzymes, on)

/datum/mutation/human/proc/check_block_string(se_string)
	if(!se_string || lentext(se_string) < DNA_STRUC_ENZYMES_BLOCKS * DNA_BLOCK_SIZE)
		return 0
	if(hex2num(getblock(se_string, dna_block)) >= lowest_value)
		return 1

/datum/mutation/human/proc/check_block(mob/living/carbon/human/owner, force_powers=0)
	if(check_block_string(owner.dna.struc_enzymes))
		if(prob(get_chance)||force_powers)
			. = on_acquiring(owner)
	else
		. = on_losing(owner)

/datum/mutation/human/proc/on_acquiring(mob/living/carbon/human/owner)
	if(!owner || !istype(owner) || owner.stat == DEAD || (src in owner.dna.mutations))
		return 1
	if(species_allowed.len && !species_allowed.Find(owner.dna.species.id))
		return 1
	if(health_req && owner.health < health_req)
		return 1
	if(limb_req && !owner.get_bodypart(limb_req))
		return 1
	owner.dna.mutations.Add(src)
	if(text_gain_indication)
		to_chat(owner, text_gain_indication)
	if(visual_indicators.len)
		var/list/mut_overlay = list(get_visual_indicator(owner))
		if(owner.overlays_standing[layer_used])
			mut_overlay = owner.overlays_standing[layer_used]
			mut_overlay |= get_visual_indicator(owner)
		owner.remove_overlay(layer_used)
		owner.overlays_standing[layer_used] = mut_overlay
		owner.apply_overlay(layer_used)

/datum/mutation/human/proc/get_visual_indicator(mob/living/carbon/human/owner)
	return

/datum/mutation/human/proc/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	return

/datum/mutation/human/proc/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	return

/datum/mutation/human/proc/on_move(mob/living/carbon/human/owner, new_loc)
	return

/datum/mutation/human/proc/on_life(mob/living/carbon/human/owner)
	return

/datum/mutation/human/proc/on_losing(mob/living/carbon/human/owner)
	if(owner && istype(owner) && (owner.dna.mutations.Remove(src)))
		if(text_lose_indication && owner.stat != DEAD)
			to_chat(owner, text_lose_indication)
		if(visual_indicators.len)
			var/list/mut_overlay = list()
			if(owner.overlays_standing[layer_used])
				mut_overlay = owner.overlays_standing[layer_used]
			owner.remove_overlay(layer_used)
			mut_overlay.Remove(get_visual_indicator(owner))
			owner.overlays_standing[layer_used] = mut_overlay
			owner.apply_overlay(layer_used)
		return 0
	return 1

/datum/mutation/human/proc/say_mod(message)
	if(message)
		return message

/datum/mutation/human/proc/get_spans()
	return list()

/datum/mutation/human/hulk

	name = "Hulk"
	quality = POSITIVE
	get_chance = 15
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>Your muscles hurt!</span>"
	species_allowed = list("human") //no skeleton/lizard hulk
	health_req = 25

/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	var/status = CANSTUN | CANKNOCKDOWN | CANUNCONSCIOUS | CANPUSH
	owner.status_flags &= ~status
	owner.update_body_parts()

/datum/mutation/human/hulk/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	if(proximity) //no telekinetic hulk attack
		return target.attack_hulk(owner)

/datum/mutation/human/hulk/on_life(mob/living/carbon/human/owner)
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.status_flags |= CANSTUN | CANKNOCKDOWN | CANUNCONSCIOUS | CANPUSH
	owner.update_body_parts()

/datum/mutation/human/hulk/say_mod(message)
	if(message)
		message = "[uppertext(replacetext(message, ".", "!"))]!!"
	return message

/datum/mutation/human/telekinesis

	name = "Telekinesis"
	quality = POSITIVE
	get_chance = 20
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>You feel smarter!</span>"
	limb_req = "head"

/datum/mutation/human/telekinesis/New()
	..()
	visual_indicators |= mutable_appearance('icons/effects/genetics.dmi', "telekinesishead", -MUTATIONS_LAYER)

/datum/mutation/human/telekinesis/get_visual_indicator(mob/living/carbon/human/owner)
	return visual_indicators[1]

/datum/mutation/human/telekinesis/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	target.attack_tk(owner)

/datum/mutation/human/cold_resistance

	name = "Cold Resistance"
	quality = POSITIVE
	get_chance = 25
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	time_coeff = 5

/datum/mutation/human/cold_resistance/New()
	..()
	visual_indicators |= mutable_appearance('icons/effects/genetics.dmi', "fire", -MUTATIONS_LAYER)

/datum/mutation/human/cold_resistance/get_visual_indicator(mob/living/carbon/human/owner)
	return visual_indicators[1]

/datum/mutation/human/cold_resistance/on_life(mob/living/carbon/human/owner)
	if(owner.getFireLoss())
		if(prob(1))
			owner.heal_bodypart_damage(0,1)   //Is this really needed?

/datum/mutation/human/x_ray

	name = "X Ray Vision"
	quality = POSITIVE
	get_chance = 25
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>The walls suddenly disappear!</span>"
	time_coeff = 2

/datum/mutation/human/x_ray/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return

	owner.update_sight()

/datum/mutation/human/x_ray/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.update_sight()

/datum/mutation/human/nearsight

	name = "Near Sightness"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You can't see very well.</span>"

/datum/mutation/human/nearsight/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.become_nearsighted()

/datum/mutation/human/nearsight/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_nearsighted()

/datum/mutation/human/epilepsy

	name = "Epilepsy"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You get a headache.</span>"

/datum/mutation/human/epilepsy/on_life(mob/living/carbon/human/owner)
	if(prob(1) && owner.stat == CONSCIOUS)
		owner.visible_message("<span class='danger'>[owner] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
		owner.Unconscious(200)
		owner.Jitter(1000)
		addtimer(CALLBACK(src, .proc/jitter_less, owner), 90)

/datum/mutation/human/epilepsy/proc/jitter_less(mob/living/carbon/human/owner)
	if(owner)
		owner.jitteriness = 10

/datum/mutation/human/bad_dna
	name = "Unstable DNA"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel strange.</span>"

/datum/mutation/human/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		if(prob(50))
			new_mob = owner.randmutb()
		else
			new_mob = owner.randmuti()
	else
		new_mob = owner.randmutg()
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)

/datum/mutation/human/cough
	name = "Cough"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You start coughing.</span>"

/datum/mutation/human/cough/on_life(mob/living/carbon/human/owner)
	if(prob(5) && owner.stat == CONSCIOUS)
		owner.drop_item()
		owner.emote("cough")

/datum/mutation/human/dwarfism
	name = "Dwarfism"
	quality = POSITIVE
	get_chance = 15
	lowest_value = 256 * 12

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

/datum/mutation/human/clumsy

	name = "Clumsiness"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You feel lightheaded.</span>"

/datum/mutation/human/clumsy/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.disabilities |= CLUMSY

/datum/mutation/human/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.disabilities &= ~CLUMSY

/datum/mutation/human/tourettes
	name = "Tourettes Syndrome"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You twitch.</span>"

/datum/mutation/human/tourettes/on_life(mob/living/carbon/human/owner)
	if(prob(10) && owner.stat == CONSCIOUS)
		owner.Stun(200)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)

/datum/mutation/human/nervousness
	name = "Nervousness"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You feel nervous.</span>"

/datum/mutation/human/nervousness/on_life(mob/living/carbon/human/owner)
	if(prob(10))
		owner.stuttering = max(10, owner.stuttering)

/datum/mutation/human/deaf
	name = "Deafness"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to hear anything.</span>"

/datum/mutation/human/deaf/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.disabilities |= DEAF

/datum/mutation/human/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.disabilities &= ~DEAF

/datum/mutation/human/blind
	name = "Blindness"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to see anything.</span>"

/datum/mutation/human/blind/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.become_blind()

/datum/mutation/human/blind/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.cure_blind()


/datum/mutation/human/race
	name = "Monkified"
	quality = NEGATIVE
	time_coeff = 2

/datum/mutation/human/race/on_acquiring(mob/living/carbon/human/owner)
	if(owner.has_brain_worms())
		to_chat(owner, "<span class='warning'>You feel something strongly clinging to your humanity!</span>")
		return
	if(..())
		return
	. = owner.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)

/datum/mutation/human/race/on_losing(mob/living/carbon/monkey/owner)
	if(owner && istype(owner) && owner.stat != DEAD && (owner.dna.mutations.Remove(src)))
		. = owner.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)

/datum/mutation/human/chameleon
	name = "Chameleon"
	quality = POSITIVE
	get_chance = 20
	lowest_value = 256 * 12
	text_gain_indication = "<span class='notice'>You feel one with your surroundings.</span>"
	text_lose_indication = "<span class='notice'>You feel oddly exposed.</span>"
	time_coeff = 5

/datum/mutation/human/chameleon/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/on_life(mob/living/carbon/human/owner)
	owner.alpha = max(0, owner.alpha - 25)

/datum/mutation/human/chameleon/on_move(mob/living/carbon/human/owner)
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/on_attack_hand(mob/living/carbon/human/owner, atom/target, proximity)
	if(proximity) //stops tk from breaking chameleon
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
		return

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = 255

/datum/mutation/human/wacky
	name = "Wacky"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='sans'>You feel an off sensation in your voicebox.</span>"
	text_lose_indication = "<span class='notice'>The off sensation passes.</span>"

/datum/mutation/human/wacky/get_spans()
	return list(SPAN_SANS)

/datum/mutation/human/mute
	name = "Mute"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel unable to express yourself at all.</span>"
	text_lose_indication = "<span class='danger'>You feel able to speak freely again.</span>"

/datum/mutation/human/mute/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.disabilities |= MUTE

/datum/mutation/human/mute/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.disabilities &= ~MUTE

/datum/mutation/human/smile
	name = "Smile"
	quality = MINOR_NEGATIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='notice'>You feel so happy. Nothing can be wrong with anything. :)</span>"
	text_lose_indication = "<span class='notice'>Everything is terrible again. :(</span>"

/datum/mutation/human/smile/say_mod(message)
	if(message)
		message = " [message] "
		//Time for a friendly game of SS13
		message = replacetext(message," stupid "," smart ")
		message = replacetext(message," retard "," genius ")
		message = replacetext(message," unrobust "," robust ")
		message = replacetext(message," dumb "," smart ")
		message = replacetext(message," awful "," great ")
		message = replacetext(message," gay ",pick(" nice "," ok "," alright "))
		message = replacetext(message," horrible "," fun ")
		message = replacetext(message," terrible "," terribly fun ")
		message = replacetext(message," terrifying "," wonderful ")
		message = replacetext(message," gross "," cool ")
		message = replacetext(message," disgusting "," amazing ")
		message = replacetext(message," loser "," winner ")
		message = replacetext(message," useless "," useful ")
		message = replacetext(message," oh god "," cheese and crackers ")
		message = replacetext(message," jesus "," gee wiz ")
		message = replacetext(message," weak "," strong ")
		message = replacetext(message," kill "," hug ")
		message = replacetext(message," murder "," tease ")
		message = replacetext(message," ugly "," beautiful ")
		message = replacetext(message," douchbag "," nice guy ")
		message = replacetext(message," whore "," lady ")
		message = replacetext(message," nerd "," smart guy ")
		message = replacetext(message," moron "," fun person ")
		message = replacetext(message," IT'S LOOSE "," EVERYTHING IS FINE ")
		message = replacetext(message," sex "," hug fight ")
		message = replacetext(message," idiot "," genius ")
		message = replacetext(message," fat "," thin ")
		message = replacetext(message," beer "," water with ice ")
		message = replacetext(message," drink "," water ")
		message = replacetext(message," feminist "," empowered woman ")
		message = replacetext(message," i hate you "," you're mean ")
		message = replacetext(message," nigger "," african american ")
		message = replacetext(message," jew "," jewish ")
		message = replacetext(message," shit "," shiz ")
		message = replacetext(message," crap "," poo ")
		message = replacetext(message," slut "," tease ")
		message = replacetext(message," ass "," butt ")
		message = replacetext(message," damn "," dang ")
		message = replacetext(message," fuck ","  ")
		message = replacetext(message," penis "," privates ")
		message = replacetext(message," cunt "," privates ")
		message = replacetext(message," dick "," jerk ")
		message = replacetext(message," vagina "," privates ")
	return trim(message)

/datum/mutation/human/unintelligable
	name = "Unintelligable"
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to form any coherent thoughts!</span>"
	text_lose_indication = "<span class='danger'>Your mind feels more clear.</span>"

/datum/mutation/human/unintelligable/say_mod(message)
	if(message)
		var/prefix=copytext(message,1,2)
		if(prefix == ";")
			message = copytext(message,2)
		else if(prefix in list(":","#"))
			prefix += copytext(message,2,3)
			message = copytext(message,3)
		else
			prefix=""

		var/list/words = splittext(message," ")
		var/list/rearranged = list()
		for(var/i=1;i<=words.len;i++)
			var/cword = pick(words)
			words.Remove(cword)
			var/suffix = copytext(cword,length(cword)-1,length(cword))
			while(length(cword)>0 && suffix in list(".",",",";","!",":","?"))
				cword  = copytext(cword,1              ,length(cword)-1)
				suffix = copytext(cword,length(cword)-1,length(cword)  )
			if(length(cword))
				rearranged += cword
		message = "[prefix][uppertext(jointext(rearranged," "))]!!"
	return message

/datum/mutation/human/swedish
	name = "Swedish"
	quality = MINOR_NEGATIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='notice'>You feel Swedish, however that works.</span>"
	text_lose_indication = "<span class='notice'>The feeling of Swedishness passes.</span>"

/datum/mutation/human/swedish/say_mod(message)
	if(message)
		message = replacetext(message,"w","v")
		message = replacetext(message,"j","y")
		message = replacetext(message,"a",pick("�","�","�","a"))
		message = replacetext(message,"bo","bjo")
		message = replacetext(message,"o",pick("�","�","o"))
		if(prob(30))
			message += " Bork[pick("",", bork",", bork, bork")]!"
	return message

/datum/mutation/human/chav
	name = "Chav"
	quality = MINOR_NEGATIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='notice'>Ye feel like a reet prat like, innit?</span>"
	text_lose_indication = "<span class='notice'>You no longer feel like being rude and sassy.</span>"

/datum/mutation/human/chav/say_mod(message)
	if(message)
		message = " [message] "
		message = replacetext(message," looking at  ","  gawpin' at ")
		message = replacetext(message," great "," bangin' ")
		message = replacetext(message," man "," mate ")
		message = replacetext(message," friend ",pick(" mate "," bruv "," bledrin "))
		message = replacetext(message," what "," wot ")
		message = replacetext(message," drink "," wet ")
		message = replacetext(message," get "," giz ")
		message = replacetext(message," what "," wot ")
		message = replacetext(message," no thanks "," wuddent fukken do one ")
		message = replacetext(message," i don't know "," wot mate ")
		message = replacetext(message," no "," naw ")
		message = replacetext(message," robust "," chin ")
		message = replacetext(message,"  hi  "," how what how ")
		message = replacetext(message," hello "," sup bruv ")
		message = replacetext(message," kill "," bang ")
		message = replacetext(message," murder "," bang ")
		message = replacetext(message," windows "," windies ")
		message = replacetext(message," window "," windy ")
		message = replacetext(message," break "," do ")
		message = replacetext(message," your "," yer ")
		message = replacetext(message," security "," coppers ")
	return trim(message)

/datum/mutation/human/elvis
	name = "Elvis"
	quality = MINOR_NEGATIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='notice'>You feel pretty good, honeydoll.</span>"
	text_lose_indication = "<span class='notice'>You feel a little less conversation would be great.</span>"

/datum/mutation/human/elvis/on_life(mob/living/carbon/human/owner)
	switch(pick(1,2))
		if(1)
			if(prob(15))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> busts out some [dancemoves] moves!")
		if(2)
			if(prob(15))
				owner.visible_message("<b>[owner]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]!")

/datum/mutation/human/elvis/say_mod(message)
	if(message)
		message = " [message] "
		message = replacetext(message," i'm not "," I aint ")
		message = replacetext(message," girl ",pick(" honey "," baby "," baby doll "))
		message = replacetext(message," man ",pick(" son "," buddy "," brother"," pal "," friendo "))
		message = replacetext(message," out of "," outta ")
		message = replacetext(message," thank you "," thank you, thank you very much ")
		message = replacetext(message," what are you "," whatcha ")
		message = replacetext(message," yes ",pick(" sure", "yea "))
		message = replacetext(message," faggot "," square ")
		message = replacetext(message," muh valids "," getting my kicks ")
	return trim(message)

/datum/mutation/human/stoner
	name = "Stoner"
	quality = NEGATIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='notice'>You feel...totally chill, man!</span>"
	text_lose_indication = "<span class='notice'>You feel like you have a better sense of time.</span>"

/datum/mutation/human/stoner/on_acquiring(mob/living/carbon/human/owner)
	..()
	owner.grant_language(/datum/language/beachbum)
	owner.remove_language(/datum/language/common)

/datum/mutation/human/stoner/on_losing(mob/living/carbon/human/owner)
	..()
	owner.grant_language(/datum/language/common)
	owner.remove_language(/datum/language/beachbum)

/datum/mutation/human/laser_eyes
	name = "Laser Eyes"
	quality = POSITIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='notice'>You feel pressure building up behind your eyes.</span>"
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = "head"

/datum/mutation/human/laser_eyes/New()
	..()
	visual_indicators |= mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER)

/datum/mutation/human/laser_eyes/get_visual_indicator(mob/living/carbon/human/owner)
	return visual_indicators[1]

/datum/mutation/human/laser_eyes/on_ranged_attack(mob/living/carbon/human/owner, atom/target)
	if(owner.a_intent == INTENT_HARM)
		owner.LaserEyes(target)


/mob/living/carbon/proc/update_mutations_overlay()
	return

/mob/living/carbon/human/update_mutations_overlay()
	for(var/datum/mutation/human/CM in dna.mutations)
		if(CM.species_allowed.len && !CM.species_allowed.Find(dna.species.id))
			CM.force_lose(src) //shouldn't have that mutation at all
			continue
		if(CM.visual_indicators.len)
			var/list/mut_overlay = list()
			if(overlays_standing[CM.layer_used])
				mut_overlay = overlays_standing[CM.layer_used]
			var/mutable_appearance/V = CM.get_visual_indicator(src)
			if(!mut_overlay.Find(V)) //either we lack the visual indicator or we have the wrong one
				remove_overlay(CM.layer_used)
				for(var/mutable_appearance/MA in CM.visual_indicators)
					mut_overlay.Remove(MA)
				mut_overlay |= V
				overlays_standing[CM.layer_used] = mut_overlay
				apply_overlay(CM.layer_used)
