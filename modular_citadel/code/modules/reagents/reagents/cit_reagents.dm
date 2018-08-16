//body bluids
/datum/reagent/consumable/semen
	name = "Semen"
	id = "semen"
	description = "Sperm from some animal. Useless for anything but insemination, really."
	taste_description = "something salty"
	taste_mult = 2 //Not very overpowering flavor
	data = list("donor"=null,"viruses"=null,"donor_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null)
	reagent_state = LIQUID
	color = "#FFFFFF" // rgb: 255, 255, 255
	nutriment_factor = 0.5 * REAGENTS_METABOLISM

/datum/reagent/consumable/semen/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/semen/S = locate() in T
	if(!S)
		S = new(T)
	S.reagents.add_reagent("semen", reac_volume)
	if(data["blood_DNA"])
		S.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/obj/effect/decal/cleanable/semen
	name = "semen"
	desc = null
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'modular_citadel/icons/obj/genitals/effects.dmi'
	icon_state = "semen1"
	random_icon_states = list("semen1", "semen2", "semen3", "semen4")

/obj/effect/decal/cleanable/semen/New()
	..()
	dir = pick(1,2,4,8)

/datum/reagent/consumable/semen/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/semen(T)
		reagentdecal.reagents.add_reagent("semen", reac_volume)

/datum/reagent/consumable/femcum
	name = "Female Ejaculate"
	id = "femcum"
	description = "Vaginal lubricant found in most mammals and other animals of similar nature. Where you found this is your own business."
	taste_description = "something with a tang" // wew coders who haven't eaten out a girl.
	taste_mult = 2
	data = list("donor"=null,"viruses"=null,"donor_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null)
	reagent_state = LIQUID
	color = "#AAAAAA77"
	nutriment_factor = 0.5 * REAGENTS_METABOLISM

/obj/effect/decal/cleanable/femcum
	name = "female ejaculate"
	desc = null
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'modular_citadel/icons/obj/genitals/effects.dmi'
	icon_state = "fem1"
	random_icon_states = list("fem1", "fem2", "fem3", "fem4")
	blood_state = null
	bloodiness = null

/obj/effect/decal/cleanable/femcum/New()
	..()
	dir = pick(1,2,4,8)
	add_blood_DNA(list("Non-human DNA" = "A+"))

/obj/effect/decal/cleanable/femcum/replace_decal(obj/effect/decal/cleanable/femcum/F)
	F.add_blood_DNA(return_blood_DNA())
	..()

/datum/reagent/consumable/femcum/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/femcum/S = locate() in T
	if(!S)
		S = new(T)
	S.reagents.add_reagent("femcum", reac_volume)
	if(data["blood_DNA"])
		S.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

//aphrodisiac & anaphrodisiac

/datum/reagent/drug/aphrodisiac
	name = "Crocin"
	id = "aphro"
	description = "Naturally found in the crocus and gardenia flowers, this drug acts as a natural and safe aphrodisiac."
	taste_description = "strawberry roofies"
	taste_mult = 2 //Hide the roofies in stronger flavors
	color = "#FFADFF"//PINK, rgb(255, 173, 255)

/datum/reagent/drug/aphrodisiac/on_mob_life(mob/living/M)
	if(M && M.canbearoused)
		if(prob(33))
			M.adjustArousalLoss(2)
		if(prob(5))
			M.emote(pick("moan","blush"))
		if(prob(5))
			var/aroused_message = pick("You feel frisky.", "You're having trouble suppressing your urges.", "You feel in the mood.")
			to_chat(M, "<span class='love'>[aroused_message]</span>")
	..()

/datum/reagent/drug/aphrodisiacplus
	name = "Hexacrocin"
	id = "aphro+"
	description = "Chemically condensed form of basic crocin. This aphrodisiac is extremely powerful and addictive in most animals.\
					Addiction withdrawals can cause brain damage and shortness of breath. Overdosage can lead to brain damage and a\
					 permanent increase in libido (commonly referred to as 'bimbofication')."
	taste_description = "liquid desire"
	color = "#FF2BFF"//dark pink
	addiction_threshold = 20
	overdose_threshold = 20

/datum/reagent/drug/aphrodisiacplus/on_mob_life(mob/living/M)
	if(M && M.canbearoused)
		if(prob(33))
			M.adjustArousalLoss(6)//not quite six times as powerful, but still considerably more powerful.
		if(prob(5))
			if(M.getArousalLoss() > 75)
				M.say(pick("Hnnnnngghh...", "Ohh...", "Mmnnn..."))
			else
				M.emote(pick("moan","blush"))
		if(prob(5))
			var/aroused_message
			if(M.getArousalLoss() > 90)
				aroused_message = pick("You need to fuck someone!", "You're bursting with sexual tension!", "You can't get sex off your mind!")
			else
				aroused_message = pick("You feel a bit hot.", "You feel strong sexual urges.", "You feel in the mood.", "You're ready to go down on someone.")
			to_chat(M, "<span class='love'>[aroused_message]</span>")
	..()

/datum/reagent/drug/aphrodisiacplus/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M.adjustBrainLoss(2)
	..()
/datum/reagent/drug/aphrodisiacplus/addiction_act_stage3(mob/living/M)
	if(prob(30))
		M.adjustBrainLoss(3)

		..()
/datum/reagent/drug/aphrodisiacplus/addiction_act_stage4(mob/living/M)
	if(prob(30))
		M.adjustBrainLoss(4)
	..()

/datum/reagent/drug/aphrodisiacplus/overdose_process(mob/living/M)
	if(M && M.canbearoused && prob(33))
		if(M.getArousalLoss() >= 100 && ishuman(M) && M.has_dna())
			var/mob/living/carbon/human/H = M
			if(prob(50)) //Less spam
				to_chat(H, "<span class='love'>Your libido is going haywire!</span>")
				H.mob_climax(forced_climax=TRUE)
		if(M.min_arousal < 50)
			M.min_arousal += 1
		if(M.min_arousal < M.max_arousal)
			M.min_arousal += 1
		M.adjustArousalLoss(2)
	..()

/datum/reagent/drug/anaphrodisiac
	name = "Camphor"
	id = "anaphro"
	description = "Naturally found in some species of evergreen trees, camphor is a waxy substance. When injested by most animals, it acts as an anaphrodisiac\
					, reducing libido and calming them. Non-habit forming and not addictive."
	taste_description = "dull bitterness"
	taste_mult = 2
	color = "#D9D9D9"//rgb(217, 217, 217)
	reagent_state = SOLID

/datum/reagent/drug/anaphrodisiac/on_mob_life(mob/living/M)
	if(M && M.canbearoused && prob(33))
		M.adjustArousalLoss(-2)
	..()

/datum/reagent/drug/anaphrodisiacplus
	name = "Hexacamphor"
	id = "anaphro+"
	description = "Chemically condensed camphor. Causes an extreme reduction in libido and a permanent one if overdosed. Non-addictive."
	taste_description = "tranquil celibacy"
	color = "#D9D9D9"//rgb(217, 217, 217)
	reagent_state = SOLID
	overdose_threshold = 20

/datum/reagent/drug/anaphrodisiacplus/on_mob_life(mob/living/M)
	if(M && M.canbearoused && prob(33))
		M.adjustArousalLoss(-4)
	..()

/datum/reagent/drug/anaphrodisiacplus/overdose_process(mob/living/M)
	if(M && M.canbearoused && prob(33))
		if(M.min_arousal > 0)
			M.min_arousal -= 1
		if(M.min_arousal > 50)
			M.min_arousal -= 1
		M.adjustArousalLoss(-2)
	..()

//recipes
/datum/chemical_reaction/aphro
	name = "crocin"
	id = "aphro"
	results = list("aphro" = 6)
	required_reagents = list("carbon" = 2, "hydrogen" = 2, "oxygen" = 2, "water" = 1)
	required_temp = 400
	mix_message = "The mixture boils off a pink vapor..."//The water boils off, leaving the crocin

/datum/chemical_reaction/aphroplus
	name = "hexacrocin"
	id = "aphro+"
	results = list("aphro+" = 1)
	required_reagents = list("aphro" = 6, "phenol" = 1)
	required_temp = 400
	mix_message = "The mixture rapidly condenses and darkens in color..."

/datum/chemical_reaction/anaphro
	name = "camphor"
	id = "anaphro"
	results = list("anaphro" = 6)
	required_reagents = list("carbon" = 2, "hydrogen" = 2, "oxygen" = 2, "sulfur" = 1)
	required_temp = 400
	mix_message = "The mixture boils off a yellow, smelly vapor..."//Sulfur burns off, leaving the camphor

/datum/chemical_reaction/anaphroplus
	name = "pentacamphor"
	id = "anaphro+"
	results = list("anaphro+" = 1)
	required_reagents = list("anaphro" = 5, "acetone" = 1)
	required_temp = 300
	mix_message = "The mixture thickens and heats up slighty..."
