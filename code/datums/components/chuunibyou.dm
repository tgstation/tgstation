
/// how much health healed from casting a chuuni spell
#define CHUUNIBYOU_HEAL_AMOUNT 5

/**
 * ## chuunibyou component!
 *
 * Component that makes casted spells always a shout invocation, a very dumb one. And their projectiles are dumb too.
 * Oh, but it does heal after each spell cast.
 */
/datum/component/chuunibyou
	/// amount healed per spell cast
	var/heal_amount = CHUUNIBYOU_HEAL_AMOUNT
	/// invocations per school the spell is from
	var/static/list/chuunibyou_invocations

/datum/component/chuunibyou/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(!chuunibyou_invocations)
		chuunibyou_invocations = list(
			SCHOOL_UNSET = "This is embarrassing... I can't remember the words... um... maybe if I just wave my hand like this... no, that's not wor- Ah! There it goes!",
			SCHOOL_HOLY = "By the grace of the holy one, I summon the light of salvation. Let my allies rejoice. O, Heaven! Bless them!",
			SCHOOL_PSYCHIC = "By the secret of the hidden one, I reveal the truth of creation. Let my mind expand. O, Mystery! Enlighten me!",
			SCHOOL_MIME = "O, Silence! Embrace my soul and amplify my gesture. Let me create the illusion and manipulate the perception!",
			SCHOOL_RESTORATION = "I invoke the name of the goddess of mercy, hear my plea and grant your blessing to this soul! Divine Grace!",

			SCHOOL_EVOCATION = "Behold, the ultimate power of the Dark Flame Master! I call upon the ancient forces of chaos and destruction to unleash their wrath upon my enemies!",
			SCHOOL_TRANSMUTATION = "I invoke the law of equivalent exchange, the balance of the cosmos. As I offer this sacrifice, I demand a new creation. Reveal, the mystery of transmutation!",
			SCHOOL_TRANSLOCATION = "By the power of the spatial rifts, I bend the fabric of reality and move across the dimensions! Let nothing stand in my way as I travel to my destination!",
			SCHOOL_CONJURATION = "With the eye of fate, I see through the threads of destiny. Nothing can hide from me. Witness me, witness the miracle of manifestation!",

			SCHOOL_NECROMANCY = "I am the Lord of the Dead, the Master of Bones, the Ruler of Shadows. I command the legions of the damned to rise from their graves and serve me!",
			SCHOOL_FORBIDDEN = "I renounce the laws of this world and embrace the chaos of the old gods! Let the forbidden power flow through me and destroy everything in its path!",
			SCHOOL_SANGUINE = "I cover my eye with an eyepatch to seal my true power, but now I will unleash it upon you. I feast on the life force of my prey and grow stronger with every drop!",
		)

/datum/component/chuunibyou/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_SPELL_PROJECTILE, PROC_REF(on_spell_projectile))
	RegisterSignal(parent, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(on_before_spell_cast))
	if(heal_amount)
		RegisterSignal(parent, COMSIG_MOB_AFTER_SPELL_CAST, PROC_REF(on_after_spell_cast))

/datum/component/chuunibyou/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOB_SPELL_PROJECTILE, COMSIG_MOB_BEFORE_SPELL_CAST))
	if(heal_amount)
		UnregisterSignal(parent, COMSIG_MOB_AFTER_SPELL_CAST)

///signal sent when the parent casts a spell that has a projectile
/datum/component/chuunibyou/proc/on_spell_projectile(mob/living/source, datum/action/cooldown/spell/spell, atom/cast_on, obj/projectile/to_fire)
	SIGNAL_HANDLER

	playsound(src,'sound/magic/staff_change.ogg', 75, TRUE)
	to_fire.color = "#f825f8"
	to_fire.name = "chuuni-[to_fire.name]"
	to_fire.set_light(2, 2, LIGHT_COLOR_PINK, TRUE)

///signal sent before parent casts a spell
/datum/component/chuunibyou/proc/on_before_spell_cast(mob/living/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER

	var/changed_spell = FALSE
	if(spell.invocation_type != INVOCATION_SHOUT)
		spell.invocation_type = INVOCATION_SHOUT
		changed_spell = TRUE
	if(spell.invocation == initial(spell.invocation))
		spell.invocation = chuunibyou_invocations[spell.school]
		if(!spell.invocation) // someone forgot to update the CHUUNI LIST to include a desc for the new school
			stack_trace("Chunnibyou invocations is missing a line for spell school \"[spell.school]\"")
			spell.invocation = chuunibyou_invocations[SCHOOL_UNSET]
	if(changed_spell)
		//they can't invoke it verbally, perhaps?
		if(!spell.can_cast_spell(feedback = TRUE))
			return SPELL_CANCEL_CAST

///signal sent after parent casts a spell
/datum/component/chuunibyou/proc/on_after_spell_cast(mob/living/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER

	source.heal_overall_damage(heal_amount)
	to_chat(source, span_danger("Your chuuni invocation slightly heals you."))

/datum/component/chuunibyou/no_healing
	heal_amount = 0

#undef CHUUNIBYOU_HEAL_AMOUNT


