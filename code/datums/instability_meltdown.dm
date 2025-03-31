/// A possible genetic meltdown that occurs when someone exceeds 100 genetic instability
/datum/instability_meltdown
	/// How likely a meltdown is to be picked
	var/meltdown_weight = 1
	/// If this meltdown is considered "fatal" or not
	var/fatal = FALSE
	/// Used to ensure that abstract subtypes do not get picked
	var/abstract_type = /datum/instability_meltdown

/// Code that runs when this meltdown is picked
/datum/instability_meltdown/proc/meltdown(mob/living/carbon/human/victim)
	return

// Nonfatal meltdowns

/// Turns you into a monkey
/datum/instability_meltdown/monkey

/datum/instability_meltdown/monkey/meltdown(mob/living/carbon/human/victim)
	victim.monkeyize()

/// Gives you brain trauma that makes your legs disfunctional and gifts you a wheelchair
/datum/instability_meltdown/paraplegic

/datum/instability_meltdown/paraplegic/meltdown(mob/living/carbon/human/victim)
	victim.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic)
	new /obj/vehicle/ridden/wheelchair(get_turf(victim))
	to_chat(victim, span_warning("My flesh turned into a wheelchair and I can't feel my legs."))

/// Turns you into a corgi
/datum/instability_meltdown/corgi

/datum/instability_meltdown/corgi/meltdown(mob/living/carbon/human/victim)
	victim.corgize()

/// Does nothing
/datum/instability_meltdown/alright

/datum/instability_meltdown/alright/meltdown(mob/living/carbon/human/victim)
	to_chat(victim, span_notice("Oh, I actually feel quite alright!"))

/// Gives you the same text as above but now when you're hit you take 200 times more damage
/datum/instability_meltdown/not_alright

/datum/instability_meltdown/not_alright/meltdown(mob/living/carbon/human/victim)
	to_chat(victim, span_notice("Oh, I actually feel quite alright!"))
	victim.physiology.damage_resistance -= 20000 //you thought
	victim.log_message("has received x200 damage multiplier from [type] genetic meltdown")

/// Turns you into a slime
/datum/instability_meltdown/slime

/datum/instability_meltdown/slime/meltdown(mob/living/carbon/human/victim)
	to_chat(victim, span_notice("Oh, I actually feel quite alright!"))
	victim.reagents.add_reagent(/datum/reagent/aslimetoxin, 10)

/// Makes you phase through walls into a random direction
/datum/instability_meltdown/yeet

/datum/instability_meltdown/yeet/meltdown(mob/living/carbon/human/victim)
	victim.apply_status_effect(/datum/status_effect/go_away)

/// Makes you take cell damage and gibs you after some time
/datum/instability_meltdown/decloning

/datum/instability_meltdown/decloning/meltdown(mob/living/carbon/human/victim)
	to_chat(src, span_notice("Oh, I actually feel quite alright!"))
	victim.ForceContractDisease(new /datum/disease/decloning) // slow acting, non-viral GBS

/// Makes you vomit up a random organ
/datum/instability_meltdown/organ_vomit

/datum/instability_meltdown/organ_vomit/meltdown(mob/living/carbon/human/victim)
	var/list/elligible_organs = list()
	for(var/obj/item/organ/organ as anything in victim.organs) //make sure we dont get an implant or cavity item
		if(!(organ.organ_flags & ORGAN_EXTERNAL))
			elligible_organs += organ
	victim.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 10)
	if(!elligible_organs.len)
		return
	var/obj/item/organ/picked_organ = pick(elligible_organs)
	picked_organ.Remove(src)
	victim.visible_message(span_danger("[victim] vomits up [p_their()] [picked_organ.name]!"), span_danger("You vomit up your [picked_organ.name]")) //no "vomit up your heart"
	picked_organ.forceMove(victim.drop_location())
	if(prob(20))
		picked_organ.animate_atom_living()

/// Turns you into a snail
/datum/instability_meltdown/snail
	meltdown_weight = 2

/datum/instability_meltdown/snail/meltdown(mob/living/carbon/human/victim)
	to_chat(victim, span_notice("Oh, I actually feel quite alright!"))
	victim.ForceContractDisease(new/datum/disease/gastrolosis())

/// Turns you into the ultimate lifeform
/datum/instability_meltdown/crab

/datum/instability_meltdown/crab/meltdown(mob/living/carbon/human/victim)
	to_chat(victim, span_notice("Your DNA mutates into the ultimate biological form!"))
	victim.crabize()

// Fatal meltdowns

/datum/instability_meltdown/fatal
	fatal = TRUE
	abstract_type = /datum/instability_meltdown/fatal

/// Instantly gibs you
/datum/instability_meltdown/fatal/gib

/datum/instability_meltdown/fatal/gib/meltdown(mob/living/carbon/human/victim)
	victim.investigate_log("has been gibbed by DNA instability.", INVESTIGATE_DEATHS)
	victim.gib(DROP_ALL_REMAINS)

/// Dusts you
/datum/instability_meltdown/fatal/dust

/datum/instability_meltdown/fatal/dust/meltdown(mob/living/carbon/human/victim)
	victim.investigate_log("has been dusted by DNA instability.", INVESTIGATE_DEATHS)
	victim.dust()

/// Turns you into a statue
/datum/instability_meltdown/fatal/petrify

/datum/instability_meltdown/fatal/petrify/meltdown(mob/living/carbon/human/victim)
	victim.investigate_log("has been transformed into a statue by DNA instability.", INVESTIGATE_DEATHS)
	victim.death()
	victim.petrify(statue_timer = INFINITY, save_brain = FALSE)
	victim.ghostize(FALSE)

/// Either dismembers you, or if unable to, gibs you
/datum/instability_meltdown/fatal/dismember

/datum/instability_meltdown/fatal/dismember/meltdown(mob/living/carbon/human/victim)
	var/obj/item/bodypart/part = victim.get_bodypart(pick(BODY_ZONE_CHEST,BODY_ZONE_HEAD))
	if(part)
		part.dismember()
		return
	victim.investigate_log("has been gibbed by DNA instability.", INVESTIGATE_DEATHS)
	victim.gib(DROP_ALL_REMAINS)

/// Turns you into a skeleton, with a high chance of killing you soon after
/datum/instability_meltdown/fatal/skeletonize

/datum/instability_meltdown/fatal/skeletonize/meltdown(mob/living/carbon/human/victim)
	victim.visible_message(span_warning("[victim]'s skin melts off!"), span_boldwarning("Your skin melts off!"))
	victim.spawn_gibs()
	victim.set_species(/datum/species/skeleton)
	if(prob(90))
		addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob/living, death)), 3 SECONDS)

/// Makes you look up and melts out your eyes
/datum/instability_meltdown/fatal/ceiling

/datum/instability_meltdown/fatal/ceiling/meltdown(mob/living/carbon/human/victim)
	to_chat(victim, span_phobia("LOOK UP!"))
	addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob/living/carbon/human, something_horrible_mindmelt)), 3 SECONDS)

/// Slowly turns you into a psyker
/datum/instability_meltdown/fatal/psyker

/datum/instability_meltdown/fatal/psyker/meltdown(mob/living/carbon/human/victim)
	victim.slow_psykerize()
