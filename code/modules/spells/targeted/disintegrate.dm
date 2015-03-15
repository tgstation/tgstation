/spell/targeted/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	charge_max = 600
	spell_flags = NEEDSCLOTHES
	invocation = "EI NATH"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	sparks_spread = 1
	sparks_amt = 4

	hud_state = "wiz_disint"

/spell/targeted/disintegrate/cast(var/list/targets)
	..()
	for(var/mob/living/target in targets)
		if(ishuman(target) || ismonkey(target))
			var/mob/living/carbon/C = target
			if(!C.has_brain()) // Their brain is already taken out
				var/obj/item/organ/brain/B = new(C.loc)
				B.transfer_identity(C)
		target.gib()
	return