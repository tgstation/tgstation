/datum/mutation/human/radiantburst
	name = "Radiant Burst"
	desc = "A mutation hidden deep within ethereal genetic code that allows you to blind people nearby."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("There is no darkness, even when you close your eyes!")
	text_lose_indication = span_notice("The blinding light fades.")
	power_path = /datum/action/cooldown/spell/aoe/radiantburst
	instability = 30
	power_coeff = 1 //increases aoe
	synchronizer_coeff = 1 //prevents blinding
	energy_coeff = 1 //reduces cooldown
	conflicts = list(/datum/mutation/human/glow, /datum/mutation/human/glow/anti)
	species_allowed = list(SPECIES_ETHEREAL)

/datum/mutation/human/radiantburst/modify()
	. = ..()
	var/datum/action/cooldown/spell/aoe/radiantburst/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		to_modify.safe = TRUE //don't blind yourself
	to_modify.cooldown_time *= GET_MUTATION_ENERGY(src) //blind more often
	if(GET_MUTATION_POWER(src) > 1)
		to_modify.aoe_radius += 2 //bigger blind

/datum/action/cooldown/spell/aoe/radiantburst
	name = "Radiant Burst"
	desc = "You release all the light that is within you, blinding everyone nearby and yourself."
	button_icon = 'icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "radiantburst"
	active_icon_state = "radiantburst"
	base_icon_state = "radiantburst"
	aoe_radius = 3
	antimagic_flags = NONE
	spell_requirements = NONE
	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS
	sound = 'sound/magic/blind.ogg'
	var/safe = FALSE

/datum/action/cooldown/spell/aoe/radiantburst/cast(atom/cast_on)
	. = ..()
	if(!safe && iscarbon(owner))
		var/mob/living/carbon/dummy = owner
		dummy.flash_act(3) //it's INSIDE you, it's gonna blind
	owner.visible_message(span_warning("[owner] releases a blinding light from within themselves."), span_notice("You release all the light within you."))
	owner.color = LIGHT_COLOR_HOLY_MAGIC
	animate(owner, 0.5 SECONDS, color = null)

/datum/action/cooldown/spell/aoe/radiantburst/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(ishuman(victim))
		var/mob/living/carbon/human/hurt = victim
		hurt.flash_act()//only strength of 1, so sunglasses protect from it
