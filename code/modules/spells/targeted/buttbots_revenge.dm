/spell/targeted/buttbots_revenge
	name = "Butt-Bot's Revenge"
	desc = "This spell removes the target's ass in a firey explosion."

	school = "evocation"
	charge_max = 500
	spell_flags = NEEDSCLOTHES
	invocation = "ARSE NATH"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	sparks_spread = 1
	sparks_amt = 4

	amt_weakened = 8
	amt_stunned = 8

	hud_state = "wiz_butt"

/spell/targeted/buttbots_revenge/cast(var/list/targets)
	..()
	for(var/mob/living/target in targets)
		if(ishuman(target) || ismonkey(target))
			var/mob/living/carbon/C = target
			if(C.op_stage.butt != 4) // does the target have an ass
				var/obj/item/clothing/head/butt/B = new(C.loc)
				B.transfer_buttdentity(C)
				C.op_stage.butt = 4 //No having two butts.
				C << "\red Your ass just blew up!"
			playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
			C.apply_damage(40, BRUTE, "groin")
			C.apply_damage(10, BURN, "groin")
	return