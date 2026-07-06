/datum/action/cooldown/spell/ghostliness
	name = "Forsake Body"
	desc = "A spell that severs your soul from your body, loosely binding it to the material plane."
	button_icon = 'icons/mob/simple/mob.dmi'
	button_icon_state = "ghost"

	school = SCHOOL_NECROMANCY
	cooldown_time = 1 SECONDS

	invocation = "GHO'AN GHO'AST!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_STATION|SPELL_REQUIRES_MIND
	spell_max_level = 1

/datum/action/cooldown/spell/ghostliness/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	if(!is_valid_target(owner))
		if(feedback)
			owner.balloon_alert(owner, "no soul!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/ghostliness/is_valid_target(atom/cast_on)
	return ishuman(cast_on) && !HAS_TRAIT(owner, TRAIT_NO_SOUL)

/datum/action/cooldown/spell/ghostliness/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(isspirit(cast_on))
		to_chat(cast_on, span_green("You begin to focus on loosening the bonds holding you to the material plane."))
	else
		to_chat(cast_on, span_green("You begin to focus on your very being, drawing it out of its corporeal vessel..."))
	if(!do_after(cast_on, 5 SECONDS))
		if(isspirit(cast_on))
			to_chat(cast_on, span_warning("Your focus is broken, and you feel your material bindings snap tight once more."))
		else
			to_chat(cast_on, span_warning("Your focus is broken, and your soul snaps back into place."))
		return
	if(isspirit(cast_on))
		to_chat(cast_on, span_green("You successfully loosen your bonds to the material plane, and can now slip partially out of it."))
	else
		to_chat(cast_on, span_danger("As the last trailing filament of your essence ceases intersection with your body, \
		your perspective abruptly snaps to your new, ghostly figure! Your former vessel falls to the ground, vacant and devoid of volition!"))
		var/mob/living/carbon/human/soulless_husk = new(cast_on.drop_location())
		soulless_husk.setDir(cast_on.dir)
		cast_on.dna.copy_dna(soulless_husk.dna, ALL)
		soulless_husk.real_name = cast_on.real_name
		soulless_husk.updateappearance(icon_update = TRUE, mutcolor_update = TRUE, mutations_overlay_update = TRUE)
		soulless_husk.domutcheck()
		ADD_TRAIT(soulless_husk, TRAIT_NO_SOUL, MAGIC_TRAIT)
		ADD_TRAIT(soulless_husk, TRAIT_FLOORED, MAGIC_TRAIT)
	cast_on.set_species(/datum/species/spirit/ghost)
	qdel(src)
