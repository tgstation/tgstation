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

/obj/item/implant/spell/Initialize(mapload)
	. = ..()
	if(!spell_type)
		return

	spell_to_give = new spell_type(src)

	if(make_robeless && (spell_to_give.spell_requirements & SPELL_REQUIRES_WIZARD_GARB))
		spell_to_give.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

/obj/item/implant/spell/Destroy()
	QDEL_NULL(spell_to_give)
	return ..()

/obj/item/implant/spell/get_data()
	return "<b>Implant Specifications:</b><BR> \
		<b>Name:</b> Spell Implant<BR> \
		<b>Life:</b> 4 hours after death of host<BR> \
		<b>Implant Details:</b> <BR> \
		<b>Function:</b> [spell_to_give ? "Allows a non-wizard to cast [spell_to_give] as if they were a wizard." : "None."]"

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
