///how much we multiply cooldown (deciseconds) by to get the amount of blood to remove.
///BLOOD_VOLUME_NORMAL is 560, expensive spells max out at around 60 seconds which is 600 deciseconds
///removing 9/10ths of the cooldown from that puts us at 540 deciseconds, mult by 0.5 gives 270 blood taken
///one second is worth 5 blood, roughly half of your normal amount of blood taken for a huge spell, seems fair
#define COOLDOWN_TO_BLOOD_RATIO 0.5

/**
 * # splattercasting component!
 *
 * Component that makes casted spells cost blood from the user and dramatically lowers their cooldown.
 */
/datum/component/splattercasting

/datum/component/splattercasting/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/splattercasting/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_SPECIES_LOSS, .proc/on_species_change)
	RegisterSignal(parent, COMSIG_MOB_SPELL_PROJECTILE, .proc/on_spell_projectile)
	RegisterSignal(parent, COMSIG_MOB_AFTER_SPELL_CAST, .proc/on_after_spell_cast)

/datum/component/splattercasting/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOB_AFTER_SPELL_CAST))

///signal sent when a spell casts a projectile
/datum/component/splattercasting/proc/on_species_change(mob/living/carbon/source, datum/species/lost_species)
	SIGNAL_HANDLER
	qdel(src)

///signal sent when the parent casts a spell that has a projectile
/datum/component/splattercasting/proc/on_spell_projectile(mob/living/carbon/source, datum/action/cooldown/spell/spell, atom/cast_on, obj/projectile/to_fire)
	SIGNAL_HANDLER

	to_fire.color = "#FF0000"
	to_fire.name = "blood-[to_fire.name]"

///signal sent after parent casts a spell
/datum/component/splattercasting/proc/on_after_spell_cast(mob/living/carbon/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER

	//normal cooldown spell has
	var/cooldown_remaining = spell.next_use_time - world.time
	//how much we discount, we make the spell cost 1/10th of its actual cooldown
	var/new_cooldown = cooldown_remaining / 10
	//convert how much cooldown that spell saved into blood cost
	var/blood_cost = (cooldown_remaining - new_cooldown ) * COOLDOWN_TO_BLOOD_RATIO

	spell.StartCooldown(new_cooldown)
	source.blood_volume -= blood_cost

	var/cost_desc

	switch(blood_cost)
		if(1 to 50)
			cost_desc = "trickle"
		if(51 to 100)
			cost_desc = "stream"
		if(101 to 200)
			cost_desc = "river"
		if(201 to INFINITY)
			cost_desc = "torrent"

	to_chat(source, span_danger("You feel a [cost_desc] of your blood drained into the spell you just cast."))
