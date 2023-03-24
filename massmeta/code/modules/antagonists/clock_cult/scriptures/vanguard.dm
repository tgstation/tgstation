/datum/clockcult/scripture/slab/vanguard
	name = "Авангард"
	use_time = 300
	slab_overlay = "vanguard"
	desc = "Предоставляет пользователю 30-секундную невосприимчивость к оглушению, однако другие заклинания не могут быть задействованы, пока он активен."
	tip = "Получите временную невосприимчивость к дубинкам и тазерам."
	invokation_time = 10
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 150
	var/last_recorded_stam_dam = 0
	var/total_stamina_damage = 0

/datum/clockcult/scripture/slab/vanguard/InterceptClickOn(mob/living/caller, params, atom/target)
	return FALSE

/datum/clockcult/scripture/slab/vanguard/invoke_success()
	ADD_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	ADD_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	to_chat(invoker, span_sevtug("Ничто нас не остановит!"))

/datum/clockcult/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 50)
		to_chat(invoker, span_sevtug("Начинаю уставать."))

/datum/clockcult/scripture/slab/vanguard/end_invoke()
	REMOVE_TRAIT(invoker, TRAIT_STUNIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_PUSHIMMUNE, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_IGNOREDAMAGESLOWDOWN, VANGUARD_TRAIT)
	REMOVE_TRAIT(invoker, TRAIT_NOLIMBDISABLE, VANGUARD_TRAIT)
	..()
