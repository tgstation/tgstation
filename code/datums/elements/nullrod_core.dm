///Proxy element that attaches components, elements and traits that are common to more or less all nullrods.
/datum/element/nullrod_core

/**
 * Called when the element is added to a datum. If the 'chaplain_spawnable' arg is TRUE and unit testing is enabled,
 * we check that the target is actually in the nullrod_variants global list
 */
/datum/element/nullrod_core/Attach(obj/item/target, chaplain_spawnable = TRUE, rune_remove_line = "BEGONE FOUL MAGIKS!!")
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	target.AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	target.AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = rune_remove_line, \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed), target), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune, /obj/effect/cosmic_rune), \
	)
	target.AddElement(/datum/element/bane, mob_biotypes = MOB_SPIRIT, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)
	ADD_TRAIT(target, TRAIT_NULLROD_ITEM, ELEMENT_TRAIT(type))

	if(!PERFORM_ALL_TESTS(focus_only/nullrod_variants) || !chaplain_spawnable)
		return

	if(!GLOB.nullrod_variants[target.type])
		stack_trace("[target.type] is absent from the nullrod_variants global list. Please include it.")

/// Callback for effect remover, invoked when a cult rune is cleared
/datum/element/nullrod_core/proc/on_cult_rune_removed(obj/item/nullrod, obj/effect/target, mob/living/user)
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		user.log_message("erased [target_rune.cultist_name] rune using [nullrod]", LOG_GAME)
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE
