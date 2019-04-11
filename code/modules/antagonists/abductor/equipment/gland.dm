/obj/item/organ/heart/gland
	name = "fleshy mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	status = ORGAN_ROBOTIC
	beating = TRUE
	var/true_name = "baseline placebo referencer"
	var/cooldown_low = 300
	var/cooldown_high = 300
	var/next_activation = 0
	var/uses // -1 For infinite
	var/human_only = FALSE
	var/active = FALSE

	var/mind_control_uses = 1
	var/mind_control_duration = 1800
	var/active_mind_control = FALSE

/obj/item/organ/heart/gland/Initialize()
	. = ..()
	icon_state = pick(list("health", "spider", "slime", "emp", "species", "egg", "vent", "mindshock", "viral"))

/obj/item/organ/heart/gland/examine(mob/user)
	. = ..()
	if(user.has_trait(TRAIT_ABDUCTOR_SCIENTIST_TRAINING) || isobserver(user))
		to_chat(user, "<span class='notice'>It is \a [true_name].</span>")

/obj/item/organ/heart/gland/proc/ownerCheck()
	if(ishuman(owner))
		return TRUE
	if(!human_only && iscarbon(owner))
		return TRUE
	return FALSE

/obj/item/organ/heart/gland/proc/Start()
	active = 1
	next_activation = world.time + rand(cooldown_low,cooldown_high)

/obj/item/organ/heart/gland/proc/update_gland_hud()
	if(!owner)
		return
	var/image/holder = owner.hud_list[GLAND_HUD]
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(active_mind_control)
		holder.icon_state = "hudgland_active"
	else if(mind_control_uses)
		holder.icon_state = "hudgland_ready"
	else
		holder.icon_state = "hudgland_spent"

/obj/item/organ/heart/gland/proc/mind_control(command, mob/living/user)
	if(!ownerCheck() || !mind_control_uses || active_mind_control)
		return
	mind_control_uses--
	to_chat(owner, "<span class='userdanger'>You suddenly feel an irresistible compulsion to follow an order...</span>")
	to_chat(owner, "<span class='mind_control'>[command]</span>")
	active_mind_control = TRUE
	log_admin("[key_name(user)] sent an abductor mind control message to [key_name(owner)]: [command]")
	update_gland_hud()

	addtimer(CALLBACK(src, .proc/clear_mind_control), mind_control_duration)

/obj/item/organ/heart/gland/proc/clear_mind_control()
	if(!ownerCheck() || !active_mind_control)
		return
	to_chat(owner, "<span class='userdanger'>You feel the compulsion fade, and you completely forget about your previous orders.</span>")
	active_mind_control = FALSE

/obj/item/organ/heart/gland/Remove(mob/living/carbon/M, special = 0)
	active = 0
	if(initial(uses) == 1)
		uses = initial(uses)
	var/datum/atom_hud/abductor/hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	hud.remove_from_hud(owner)
	clear_mind_control()
	..()

/obj/item/organ/heart/gland/Insert(mob/living/carbon/M, special = 0)
	..()
	if(special != 2 && uses) // Special 2 means abductor surgery
		Start()
	var/datum/atom_hud/abductor/hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	hud.add_to_hud(owner)
	update_gland_hud()

/obj/item/organ/heart/gland/on_life()
	if(!beating)
		// alien glands are immune to stopping.
		beating = TRUE
	if(!active)
		return
	if(!ownerCheck())
		active = 0
		return
	if(next_activation <= world.time)
		activate()
		uses--
		next_activation  = world.time + rand(cooldown_low,cooldown_high)
	if(!uses)
		active = 0

/obj/item/organ/heart/gland/proc/activate()
	return

/obj/item/organ/heart/gland/heals
	true_name = "coherency harmonizer"
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 3000

/obj/item/organ/heart/gland/heals/activate()
	to_chat(owner, "<span class='notice'>You feel curiously revitalized.</span>")
	owner.adjustToxLoss(-20, FALSE, TRUE)
	owner.heal_bodypart_damage(20, 20, 0, TRUE)
	owner.adjustOxyLoss(-20)

/obj/item/organ/heart/gland/slime
	true_name = "gastric animation galvanizer"
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 2400

/obj/item/organ/heart/gland/slime/Insert(mob/living/carbon/M, special = 0)
	..()
	owner.faction |= "slime"
	owner.grant_language(/datum/language/slime)

/obj/item/organ/heart/gland/slime/activate()
	to_chat(owner, "<span class='warning'>You feel nauseated!</span>")
	owner.vomit(20)

	var/mob/living/simple_animal/slime/Slime = new(get_turf(owner), "grey")
	Slime.Friends = list(owner)
	Slime.Leader = owner

/obj/item/organ/heart/gland/mindshock
	true_name = "neural crosstalk uninhibitor"
	cooldown_low = 400
	cooldown_high = 700
	uses = -1
	icon_state = "mindshock"
	mind_control_uses = 1
	mind_control_duration = 6000

/obj/item/organ/heart/gland/mindshock/activate()
	to_chat(owner, "<span class='notice'>You get a headache.</span>")

	var/turf/T = get_turf(owner)
	for(var/mob/living/carbon/H in orange(4,T))
		if(H == owner)
			continue
		switch(pick(1,3))
			if(1)
				to_chat(H, "<span class='userdanger'>You hear a loud buzz in your head, silencing your thoughts!</span>")
				H.Stun(50)
			if(2)
				to_chat(H, "<span class='warning'>You hear an annoying buzz in your head.</span>")
				H.confused += 15
				H.adjustBrainLoss(10, 160)
			if(3)
				H.hallucination += 60

/obj/item/organ/heart/gland/pop
	true_name = "anthropmorphic translocator"
	cooldown_low = 900
	cooldown_high = 1800
	uses = -1
	human_only = TRUE
	icon_state = "species"
	mind_control_uses = 5
	mind_control_duration = 300

/obj/item/organ/heart/gland/pop/activate()
	to_chat(owner, "<span class='notice'>You feel unlike yourself.</span>")
	randomize_human(owner)
	var/species = pick(list(/datum/species/human, /datum/species/lizard, /datum/species/moth, /datum/species/fly))
	owner.set_species(species)

/obj/item/organ/heart/gland/ventcrawling
	true_name = "pliant cartilage enabler"
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 1800

/obj/item/organ/heart/gland/ventcrawling/activate()
	to_chat(owner, "<span class='notice'>You feel very stretchy.</span>")
	owner.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/organ/heart/gland/viral
	true_name = "contamination incubator"
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"
	mind_control_uses = 1
	mind_control_duration = 1800

/obj/item/organ/heart/gland/viral/activate()
	to_chat(owner, "<span class='warning'>You feel sick.</span>")
	var/datum/disease/advance/A = random_virus(pick(2,6),6)
	A.carrier = TRUE
	owner.ForceContractDisease(A, FALSE, TRUE)

/obj/item/organ/heart/gland/viral/proc/random_virus(max_symptoms, max_level)
	if(max_symptoms > VIRUS_SYMPTOM_LIMIT)
		max_symptoms = VIRUS_SYMPTOM_LIMIT
	var/datum/disease/advance/A = new /datum/disease/advance()
	var/list/datum/symptom/possible_symptoms = list()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = symptom
		if(initial(S.level) > max_level)
			continue
		if(initial(S.level) <= 0) //unobtainable symptoms
			continue
		possible_symptoms += S
	for(var/i in 1 to max_symptoms)
		var/datum/symptom/chosen_symptom = pick_n_take(possible_symptoms)
		if(chosen_symptom)
			var/datum/symptom/S = new chosen_symptom
			A.symptoms += S
	A.Refresh() //just in case someone already made and named the same disease
	return A

/obj/item/organ/heart/gland/trauma
	true_name = "white matter randomiser"
	cooldown_low = 800
	cooldown_high = 1200
	uses = 5
	icon_state = "emp"
	mind_control_uses = 3
	mind_control_duration = 1800

/obj/item/organ/heart/gland/trauma/activate()
	to_chat(owner, "<span class='warning'>You feel a spike of pain in your head.</span>")
	if(prob(33))
		owner.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, rand(TRAUMA_RESILIENCE_BASIC, TRAUMA_RESILIENCE_LOBOTOMY))
	else
		if(prob(20))
			owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, rand(TRAUMA_RESILIENCE_BASIC, TRAUMA_RESILIENCE_LOBOTOMY))
		else
			owner.gain_trauma_type(BRAIN_TRAUMA_MILD, rand(TRAUMA_RESILIENCE_BASIC, TRAUMA_RESILIENCE_LOBOTOMY))

/obj/item/organ/heart/gland/spiderman
	true_name = "araneae cloister accelerator"
	cooldown_low = 450
	cooldown_high = 900
	uses = -1
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 2400

/obj/item/organ/heart/gland/spiderman/activate()
	to_chat(owner, "<span class='warning'>You feel something crawling in your skin.</span>")
	owner.faction |= "spiders"
	var/obj/structure/spider/spiderling/S = new(owner.drop_location())
	S.directive = "Protect your nest inside [owner.real_name]."

/obj/item/organ/heart/gland/egg
	true_name = "roe/enzymatic synthesizer"
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	icon_state = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	mind_control_uses = 2
	mind_control_duration = 1800

/obj/item/organ/heart/gland/egg/activate()
	owner.visible_message("<span class='alertalien'>[owner] [pick(EGG_LAYING_MESSAGES)]</span>")
	var/turf/T = owner.drop_location()
	new /obj/item/reagent_containers/food/snacks/egg/gland(T)

/obj/item/organ/heart/gland/electric
	true_name = "electron accumulator/discharger"
	cooldown_low = 800
	cooldown_high = 1200
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/heart/gland/electric/Insert(mob/living/carbon/M, special = 0)
	..()
	owner.add_trait(TRAIT_SHOCKIMMUNE, ORGAN_TRAIT)

/obj/item/organ/heart/gland/electric/Remove(mob/living/carbon/M, special = 0)
	owner.remove_trait(TRAIT_SHOCKIMMUNE, ORGAN_TRAIT)
	..()

/obj/item/organ/heart/gland/electric/activate()
	owner.visible_message("<span class='danger'>[owner]'s skin starts emitting electric arcs!</span>",\
	"<span class='warning'>You feel electric energy building up inside you!</span>")
	playsound(get_turf(owner), "sparks", 100, 1, -1)
	addtimer(CALLBACK(src, .proc/zap), rand(30, 100))

/obj/item/organ/heart/gland/electric/proc/zap()
	tesla_zap(owner, 4, 8000, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN)
	playsound(get_turf(owner), 'sound/magic/lightningshock.ogg', 50, 1)

/obj/item/organ/heart/gland/chem
	true_name = "intrinsic pharma-provider"
	cooldown_low = 50
	cooldown_high = 50
	uses = -1
	mind_control_uses = 3
	mind_control_duration = 1200
	var/list/possible_reagents = list()

/obj/item/organ/heart/gland/chem/Initialize()
	. = ..()
	for(var/X in subtypesof(/datum/reagent/drug))
		var/datum/reagent/R = X
		possible_reagents += initial(R.id)
	for(var/X in subtypesof(/datum/reagent/medicine))
		var/datum/reagent/R = X
		possible_reagents += initial(R.id)
	for(var/X in typesof(/datum/reagent/toxin))
		var/datum/reagent/R = X
		possible_reagents += initial(R.id)

/obj/item/organ/heart/gland/chem/activate()
	var/chem_to_add = pick(possible_reagents)
	owner.reagents.add_reagent(chem_to_add, 2)
	owner.adjustToxLoss(-2, TRUE, TRUE)
	..()

/obj/item/organ/heart/gland/plasma
	true_name = "effluvium sanguine-synonym emitter"
	cooldown_low = 1200
	cooldown_high = 1800
	uses = -1
	mind_control_uses = 1
	mind_control_duration = 800

/obj/item/organ/heart/gland/plasma/activate()
	to_chat(owner, "<span class='warning'>You feel bloated.</span>")
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, owner, "<span class='userdanger'>A massive stomachache overcomes you.</span>"), 150)
	addtimer(CALLBACK(src, .proc/vomit_plasma), 200)

/obj/item/organ/heart/gland/plasma/proc/vomit_plasma()
	if(!owner)
		return
	owner.visible_message("<span class='danger'>[owner] vomits a cloud of plasma!</span>")
	var/turf/open/T = get_turf(owner)
	if(istype(T))
		T.atmos_spawn_air("plasma=50;TEMP=[T20C]")
	owner.vomit()
