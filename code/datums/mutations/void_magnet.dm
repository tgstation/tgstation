/datum/mutation/human/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>You feel a heavy, dull force just beyond the walls watching you.</span>"
	instability = 30
	power_path = /datum/action/cooldown/spell/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/human/void/on_life(delta_time, times_fired)
	if(!isturf(owner.loc))
		return
	if(DT_PROB((0.25+((100-dna.stability)/40)) * GET_MUTATION_SYNCHRONIZER(src), delta_time)) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		new /obj/effect/immortality_talisman/void(get_turf(owner), owner)

/datum/action/cooldown/spell/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	button_icon_state = "void_magnet"

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES

	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = INVOCATION_SHOUT

/datum/action/cooldown/spell/void/is_valid_target(atom/cast_on)
	return isturf(cast_on.loc)

/datum/action/cooldown/spell/void/cast(atom/cast_on)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(cast_on), cast_on)
