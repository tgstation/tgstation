

/mob/living/carbon/alien/adult/nova/drone
	name = "alien drone"
	desc = "As plain looking as you could call an alien with armored black chitin and large claws."
	caste = "drone"
	maxHealth = 200
	health = 200
	icon_state = "aliendrone"
	melee_damage_lower = 15
	melee_damage_upper = 20
	next_evolution = /mob/living/carbon/alien/adult/nova/praetorian

/mob/living/carbon/alien/adult/nova/drone/Initialize(mapload)
	. = ..()
	GRANT_ACTION(/datum/action/cooldown/alien/nova/heal_aura)

/mob/living/carbon/alien/adult/nova/drone/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel
	organs += new /obj/item/organ/internal/alien/resinspinner
	..()

/datum/action/cooldown/alien/nova/heal_aura
	name = "Healing Aura"
	desc = "Friendly xenomorphs in a short range around yourself will receive passive healing."
	button_icon_state = "healaura"
	plasma_cost = 100
	cooldown_time = 90 SECONDS
	/// Is the healing aura currently active or not
	var/aura_active = FALSE
	/// How long the healing aura should last
	var/aura_duration = 30 SECONDS
	/// How far away the healing aura should reach
	var/aura_range = 5
	/// How much brute/burn individually the healing aura should heal each time it fires
	var/aura_healing_amount = 5
	/// What color should the + particles caused by the healing aura be
	var/aura_healing_color = COLOR_BLUE_LIGHT
	/// The healing aura component itself that the ability uses
	var/datum/component/aura_healing/aura_healing_component

/datum/action/cooldown/alien/nova/heal_aura/Activate()
	. = ..()
	if(aura_active)
		owner.balloon_alert(owner, "already healing")
		return FALSE
	owner.balloon_alert(owner, "healing aura started")
	to_chat(owner, span_danger("We emit pheromones that encourage sisters near us to heal themselves for the next [aura_duration / 10] seconds."))
	addtimer(CALLBACK(src, PROC_REF(aura_deactivate)), aura_duration)
	aura_active = TRUE
	aura_healing_component = owner.AddComponent(/datum/component/aura_healing, range = aura_range, requires_visibility = TRUE, brute_heal = aura_healing_amount, burn_heal = aura_healing_amount, limit_to_trait = TRAIT_XENO_HEAL_AURA, healing_color = aura_healing_color)
	return TRUE

/datum/action/cooldown/alien/nova/heal_aura/proc/aura_deactivate()
	if(!aura_active)
		return
	aura_active = FALSE
	QDEL_NULL(aura_healing_component)
	owner.balloon_alert(owner, "healing aura ended")


