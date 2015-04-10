/spell/targeted/shoesnatch

	name = "Shoe Snatching Charm"
	desc = "This spell will allow you to steal somebodies shoes right off of their feet!"
	school = "evocation"
	charge_type = Sp_RECHARGE
	charge_max = 150
	spell_flags = 0
	invocation = "H'NK!"
	invocation_type = SpI_SHOUT
	range = 7
	max_targets = 1
	cooldown_min = 30
	selection_type = "range"

	compatible_mobs = list(/mob/living/carbon/human)

	hud_state = "wiz_shoes"


/spell/targeted/shoesnatch/cast(list/targets, mob/user = user)
	..()
	for(var/mob/living/carbon/human/target in targets)
		var /obj/old_shoes = target.shoes
		if(old_shoes)
			sparks_spread = 1
			sparks_amt = 4
			target.drop_from_inventory(old_shoes)
			target.visible_message(	"<span class='danger'>[target]'s shoes suddenly vanish!</span>", \
									"<span class='danger'>Your shoes suddenly vanish!</span>")
			user.put_in_active_hand(old_shoes)
