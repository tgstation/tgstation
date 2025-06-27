/obj/item/throwing_star/stamina/ninja
	name = "energy throwing star"
	throwforce = 10
	var/datum/status_effect/energy_star/effect
	embed_type = /datum/embedding/throwing_star/stamina/ninja

/datum/embedding/throwing_star/stamina/ninja
	var/effect

/obj/item/throwing_star/stamina/ninja/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_UNCATCHABLE, TRAIT_GENERIC)

/datum/status_effect/energy_star
	id = "energystar_embed"
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = 5 SECONDS

/datum/status_effect/energy_star/tick(seconds_between_ticks)
	owner.emp_act(EMP_HEAVY)

/datum/embedding/throwing_star/stamina/ninja/on_successful_embed(mob/living/carbon/victim, obj/item/bodypart/target_limb)
	effect = victim.apply_status_effect(/datum/status_effect/energy_star)

/datum/embedding/throwing_star/stamina/ninja/stop_embedding()
	if(effect)
		QDEL_NULL(effect)

