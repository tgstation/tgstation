GLOBAL_LIST_EMPTY(mutant_infection_list) // A list of all mutant_infection organs, for any mass "animation"

#define CURE_TIME 10 SECONDS
#define REVIVE_TIME_LOWER 2 MINUTES
#define REVIVE_TIME_UPPER 3 MINUTES
#define IMMUNITY_LOWER 2 MINUTES
#define IMMUNITY_UPPER 4 MINUTES
#define RNA_REFRESH_TIME 2 MINUTES //How soon can we extract more RNA?

/datum/component/mutant_infection
	var/mob/living/carbon/human/host
	var/datum/species/old_species = /datum/species/human
	var/list/mutant_species = list(/datum/species/mutant/infectious/fast, /datum/species/mutant/infectious/slow)
	var/datum/species/selected_type
	/// The stage of infection
	var/list/insanity_phrases = list("You feel too hot! Something isn't right!", "You can't think straight, please end the suffering!", "AAAAAAAAAAAAAAAGHHHHHHHH!")
	var/timer_id
	var/rna_extracted = FALSE
	var/tox_loss_mod = 0.5

/datum/component/mutant_infection/Initialize()
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	host = parent

	GLOB.mutant_infection_list += src

	if(host.stat == DEAD)
		var/revive_time = rand(REVIVE_TIME_LOWER, REVIVE_TIME_UPPER)
		timer_id = addtimer(CALLBACK(src, .proc/transform_host), revive_time, TIMER_STOPPABLE)
		to_chat(host, "<span class='userdanger'>You feel your veins throb as your body begins twitching...</span>")

	RegisterSignal(parent, COMSIG_MUTANT_CURED, .proc/cure_host)

	START_PROCESSING(SSobj, src)

/datum/component/mutant_infection/Destroy(force, silent)
	GLOB.mutant_infection_list -= src
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, list(COMSIG_MUTANT_CURED, COMSIG_LIVING_DEATH))
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	if(host)
		if(ismutant(host) && old_species)
			host.set_species(old_species)
		host.grab_ghost()
		host.revive(TRUE, TRUE)
		to_chat(host, "<span class='greentext'>You feel like you're free of that foul disease!</span>")
		ADD_TRAIT(host, TRAIT_MUTANT_IMMUNE, "mutant_virus")
		var/cure_time = rand(IMMUNITY_LOWER, IMMUNITY_UPPER)
		addtimer(CALLBACK(host, /mob/living/carbon/human/proc/remove_mutant_immunity), cure_time, TIMER_STOPPABLE)
		host = null
	return ..()

/datum/component/mutant_infection/proc/extract_rna()
	if(rna_extracted)
		return FALSE
	to_chat(host, "<span class='userdanger'>You feel your genes being altered!</span>")
	rna_extracted = TRUE
	addtimer(CALLBACK(src, .proc/refresh_rna), RNA_REFRESH_TIME, TIMER_STOPPABLE)
	return TRUE

/datum/component/mutant_infection/proc/refresh_rna()
	rna_extracted = FALSE

/mob/living/carbon/human/proc/remove_mutant_immunity()
	REMOVE_TRAIT(src, TRAIT_MUTANT_IMMUNE, "mutant_virus")

/datum/component/mutant_infection/process(delta_time)
	if(!ismutant(host) && host.stat != DEAD)
		var/toxloss = host.getToxLoss()
		if(toxloss < 50)
			host.adjustToxLoss(tox_loss_mod * delta_time)
			if(DT_PROB(5, delta_time))
				to_chat(host, span_userdanger("You feel your motor controls seize up for a moment!"))
				host.Paralyze(10)
		else
			host.adjustToxLoss((tox_loss_mod * 2) * delta_time)
			if(DT_PROB(10, delta_time))
				var/obj/item/bodypart/wound_area = host.get_bodypart(BODY_ZONE_CHEST)
				if(wound_area)
					var/datum/wound/slash/moderate/rotting_wound = new
					rotting_wound.apply_wound(wound_area)
				host.emote(pick(list("cough", "sneeze", "scream")))
	if(timer_id)
		return
	if(host.stat != DEAD)
		return
	if(!ismutant(host))
		to_chat(host, "<span class='cultlarge'>You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!</span>")
	var/revive_time = rand(REVIVE_TIME_LOWER, REVIVE_TIME_UPPER)
	to_chat(host, "<span class='redtext'>You will transform in approximately [revive_time/10] seconds.</span>")
	timer_id = addtimer(CALLBACK(src, .proc/transform_host), revive_time, TIMER_STOPPABLE)

/datum/component/mutant_infection/proc/cure_host()
	SIGNAL_HANDLER
	if(!host.stat == DEAD)
		to_chat(host, "<span class='notice'>You start to feel refreshed and invigorated!</span>")
	STOP_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, .proc/Destroy), CURE_TIME)

/datum/component/mutant_infection/proc/transform_host()
	timer_id = null

	selected_type = pick(mutant_species)

	if(!ismutant(host))
		old_species = host.dna.species
		host.set_species(selected_type)

	var/stand_up = (host.stat == DEAD) || (host.stat == UNCONSCIOUS)

	//Fully heal the mutant's damage the first time they rise

	regenerate()

	host.do_jitter_animation(30)
	host.visible_message("<span class='danger'>[host] suddenly convulses, as [host.p_they()][stand_up ? " stagger to [host.p_their()] feet and" : ""] gain a ravenous hunger in [host.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(host.loc, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	if(is_species(host, /datum/species/mutant/infectious/fast))
		to_chat(host, "<span class='redtext'>You are a FAST zombie. You run fast and hit more quickly, beware however, you are much weaker and susceptible to damage.")
	else
		to_chat(host, "<span class='redtext'>You are a SLOW zombie. You walk slowly and hit more slowly and harder. However, you are far more resilient to most damage types.")
	to_chat(host, "<span class='alertalien'>You are now a mutant! Do not seek to be cured, do not help any non-mutants in any way, do not harm your mutant brethren. You retain some higher functions and can reason to an extent.</span>")
	RegisterSignal(parent, COMSIG_LIVING_DEATH, .proc/mutant_death)

/datum/component/mutant_infection/proc/mutant_death()
	SIGNAL_HANDLER
	var/revive_time = rand(REVIVE_TIME_LOWER, REVIVE_TIME_UPPER)
	to_chat(host, "<span class='cultlarge'>You can feel your heart stopping, but something isn't right... you will rise again!</span>")
	timer_id = addtimer(CALLBACK(src, .proc/regenerate), revive_time, TIMER_STOPPABLE)

/datum/component/mutant_infection/proc/regenerate()
	if(!host.mind)
		var/list/candidates = poll_candidates_for_mob("Do you want to play as a mutant([host.name])?", target_mob = host)
		if(!candidates.len)
			return
		var/client/C = pick_n_take(candidates)
		host.key = C.key
	else
		host.grab_ghost()
	to_chat(host, "<span class='notice'>You feel an itching, both inside and \
		outside as your tissues knit and reknit.</span>")
	playsound(host, 'sound/magic/demon_consume.ogg', 50, TRUE)
	host.revive(TRUE, TRUE)
