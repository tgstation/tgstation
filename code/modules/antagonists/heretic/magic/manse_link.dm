/datum/action/cooldown/spell/pointed/manse_link
	name = "Связь Мансуса"
	desc = "Это заклинание позволяет вам пронзать реальность и соединять разумы друг с другом с помощью \
		связи Мансуса. Все разумы, подключённые к вашей связи Мансуса, смогут незаметно общаться на больших расстояниях."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

/datum/action/cooldown/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/cooldown/spell/pointed/manse_link/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/manse_link/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST

/**
 * The actual process of linking [linkee] to our network.
 */
/datum/action/cooldown/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = target
	if(linkee.stat == DEAD)
		to_chat(owner, span_warning("Они мертвы!"))
		return FALSE

	to_chat(owner, span_notice("Вы начинаете соединять сознание [linkee.declent_ru(GENITIVE)] со своим..."))
	to_chat(linkee, span_warning("Вы чувствуете, что ваш разум куда-то тянут... соединяют... переплетают с самой тканью реальности..."))

	if(!do_after(owner, link_time, linkee, hidden = TRUE))
		to_chat(owner, span_warning("Вам не удается связать себя с разумом [linkee.declent_ru(GENITIVE)]."))
		to_chat(linkee, span_warning("Чужое присутствие покидает ваш разум."))
		return FALSE

	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE

	if(!linker.link_mob(linkee))
		to_chat(owner, span_warning("Вы не можете связать себя с разумом [linkee.declent_ru(GENITIVE)]."))
		to_chat(linkee, span_warning("Чужое присутствие покидает ваш разум."))
		return FALSE

	return TRUE
