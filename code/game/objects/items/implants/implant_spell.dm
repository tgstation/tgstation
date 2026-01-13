/obj/item/implant/spell
	name = "spell implant"
	desc = "Allows you to cast a spell as if you were a wizard."
	actions_types = null

	/// Whether to make the spell robeless
	var/make_robeless = TRUE
	/// The typepath of the spell we give to people. Instantiated in Initialize
	var/datum/action/cooldown/spell/spell_type
	/// The actual spell we give to the person on implant
	var/datum/action/cooldown/spell/spell_to_give

	implant_info = "Automatically activates upon implantation. If not inert, theoretically provides spellcasting ability. \
		Unfortunately, is inert."

	implant_lore = "The Thaumic Accumulation/Instruction Matrix is an exotic thaumic accumulator designed for \
		subdermal implantation, and meant to provide an interface between magic spells \
		like those used by the Wizard's Federation, which have notoriously been uncooperative with technology, \
		and mundane users who lack innate magical aptitude. Very little is known about how it works, especially \
		because thaumic matrices, especially those designed for cross-disciplinary interaction, are hard to recover \
		intact."

/obj/item/implant/spell/Initialize(mapload)
	. = ..()
	if(!spell_type)
		return

	spell_to_give = new spell_type(src)

	if(make_robeless && (spell_to_give.spell_requirements & SPELL_REQUIRES_WIZARD_GARB))
		spell_to_give.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

	implant_info = "Automatically activates upon implantation. Allows an implantee to cast [spell_to_give], \
		[make_robeless ? ", without needing appropriate wizard garb" : " if dressed in appropriate garb"]."

/obj/item/implant/spell/Destroy()
	QDEL_NULL(spell_to_give)
	return ..()

/obj/item/implant/spell/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if (!.)
		return

	if (!spell_to_give)
		return FALSE

	spell_to_give.Grant(target)
	return TRUE

/obj/item/implant/spell/removed(mob/living/source, silent = FALSE, special = 0)
	. = ..()
	if (!.)
		return FALSE

	if(spell_to_give)
		spell_to_give.Remove(source)
		if(source.stat != DEAD && !silent)
			to_chat(source, span_boldnotice("The knowledge of how to cast [spell_to_give] slips out from your mind."))
	return TRUE

/obj/item/implanter/spell
	name = "implanter (spell)"
	imp_type = /obj/item/implant/spell

/obj/item/implantcase/spell
	name = "implant case - 'Wizardry'"
	desc = "A glass case containing an implant that can teach the user the arts of Wizardry."
	imp_type = /obj/item/implant/spell
