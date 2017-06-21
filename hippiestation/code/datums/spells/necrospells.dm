// Necrolord
/obj/effect/proc_holder/spell/targeted/trigger/soulflare
	name = "Soulflare"
	desc = "Deals high damage to an enemy in 3 different damage types, as well as paralyzing them for 1 seconds If it hits an enemy in critical condition, it instantly kills them and lowers the cooldown permanently, to a maximum of 6."
	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "NEKROSIS"
	invocation_type = "shout"
	message = "<span class='notice'>Your head feels like it's being burned as you fall to the ground!</span>"
	cooldown_min = 300
	level_max = 0 // no upgrades because it allows you to get 0 cooldown if you wait with upgrades.
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/soulflare")
	action_icon_state = "soulflare"

/obj/effect/proc_holder/spell/targeted/inflict_handler/soulflare
	amt_unconscious = 1
	amt_dam_fire = 15
	amt_dam_brute = 15
	amt_dam_oxy = 15
	sound = 'hippiestation/sound/effects/Necrolord_Soulflare_Cast.ogg'

/obj/effect/proc_holder/spell/targeted/inflict_handler/soulflare/cast(list/targets, mob/user = usr)
	var/obj/effect/proc_holder/spell/targeted/trigger/soulflare/SF = locate(/obj/effect/proc_holder/spell/targeted/trigger/soulflare, user.mind.spell_list)
	var/mob/living/carbon/human/target = targets[1]
	if(target.health <= 0)
		if(!target.stat & DEAD)
			target.adjustOxyLoss(500)
			to_chat(user, "<span class='notice'>You've successfully killed [target], refunding your spell and decreasing it's cooldown permanently.</span>")
			user.playsound_local(user, 'hippiestation/sound/effects/Necrolord_Soulflare_Crit.ogg')
			if(SF.charge_max >= 61)
				SF.charge_max -= 10
			SF.charge_counter = SF.charge_max
		else
			to_chat(user, "<span class='warning'>[target] is already dead!</span>")
			SF.charge_counter = SF.charge_max
	..()

/obj/effect/proc_holder/spell/targeted/explodecorpse
	name = "Corpse Explosion"
	desc = "Explodes a corpse in a very, very big and pretty explosion. The explosion is 9x9 centered on the target, so make sure to maintain distance when you cast it. Who needs maxcaps when you can just go green and recycle?"
	school = "transmutation"
	charge_max = 200
	clothes_req = 1
	invocation = "BO'NES T'O BO'MS"
	invocation_type = "shout"
	cooldown_min = 10
	centcom_cancast = FALSE
	sound = 'hippiestation/sound/effects/corpseexplosion.ogg'
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "raisedead"

/obj/effect/proc_holder/spell/targeted/explodecorpse/cast(list/targets, mob/user = usr)
	..()
	var/mob/living/carbon/target = targets[1]
	if(!target)
		return
	if(target.stat & DEAD)
		message_admins("[user] casted corpse explosion on [target]")
		explosion(target,1,2,4,2)
		to_chat(user, "<font color=purple><b>You redirect an absurd amount of energy into [target]'s corpse, causing it to violently explode!</b></font>")
	else
		to_chat(user, "<span class='warning'>[target] isn't a dead corpse!</span>")
		charge_counter = initial(charge_counter)

/obj/effect/proc_holder/spell/self/soulsplit
	name = "Soulsplit"
	desc = "Enter a wraith-like form, traveling at very high speeds and moving through objects. However, maintaining this form requires you to be at full health to maintain concentration!"
	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	centcom_cancast = FALSE
	invocation = "TRAVEL ME BONES"
	invocation_type = "shout"
	cooldown_min = 150
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "soulsplit"

/obj/effect/proc_holder/spell/self/soulsplit/cast(list/targets, mob/living/user = usr)
	if(user.health >= 100)
		to_chat(user, "<font color=purple><b>You enter your wraith form, leaving you vulnerable yet very manoeuvrable.</b></font>")
		user.incorporeal_move = 2
		addtimer(CALLBACK(user, /mob/living/.proc/soulsplit_wearoff), 35)
	else
		to_chat(user, "<span class='warning'>You cannot concentrate on casting soulsplit while injured!</span>")
		charge_counter = initial(charge_counter)

/mob/living/proc/soulsplit_wearoff()
	if(incorporeal_move)
		incorporeal_move = FALSE
		to_chat(src, "<span class='warning'>Soulsplit wears off!</span>")
