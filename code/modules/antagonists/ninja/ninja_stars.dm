/obj/item/throwing_star/stamina/ninja
	name = "energy throwing star"
	desc = "An evolution of the traditional steel shuriken, commonly used by Spider Clan initiates. \
		When thrown or embedded, its internal energy emitter releases an electromagnetic pulse."
	icon_state = "eshuriken"
	force = 8
	throwforce = 12
	armour_penetration = 75
	item_flags = DROPDEL
	embed_type = /datum/embedding/throwing_star/stamina/energy
	custom_materials = null
	resistance_flags = FIRE_PROOF | ACID_PROOF | UNACIDABLE

/obj/item/throwing_star/stamina/ninja/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_UNCATCHABLE, INNATE_TRAIT)

/obj/item/throwing_star/stamina/ninja/on_thrown(mob/living/carbon/user, atom/target)
	item_flags &= ~DROPDEL // Throwing = dropping = dropdel, not ideal. Remove it before that happens
	return ..()

/obj/item/throwing_star/stamina/ninja/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	item_flags |= DROPDEL // Just in case, re-apply drop del now
	hit_atom.emp_act(EMP_HEAVY)
	new /obj/effect/temp_visual/emp/pulse(get_turf(src))
	new /obj/effect/temp_visual/emp(get_turf(hit_atom))
	playsound(src, 'sound/effects/empulse.ogg', 60, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	visible_message("[src] emits an electromagnetic pulse upon impact!")
	if(isturf(loc)) // if we didn't embed in anything, go away
		qdel(src)

/datum/embedding/throwing_star/stamina/energy
	COOLDOWN_DECLARE(emp_cd)

/datum/embedding/throwing_star/stamina/energy/on_successful_embed(mob/living/carbon/victim, obj/item/bodypart/target_limb)
	COOLDOWN_START(src, emp_cd, 6 SECONDS)
	parent.item_flags |= DROPDEL // Just in case again, re-apply drop del now

/datum/embedding/throwing_star/stamina/energy/process_effect(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, emp_cd))
		return

	owner.emp_act(EMP_LIGHT)
	COOLDOWN_START(src, emp_cd, 6 SECONDS)
	playsound(owner, 'sound/effects/empulse.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	owner.show_message("[parent] flares brightly, releasing an electromagnetic pulse!", MSG_VISUAL)
	new /obj/effect/temp_visual/emp(get_turf(owner))
