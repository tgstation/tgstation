/mob
	var/nextsoundemote = 1

/datum/emote/living/scream/run_emote(mob/living/user, params)
	if(user.nextsoundemote >= world.time || user.stat != CONSCIOUS)
		return
	var/sound
	var/miming = user.mind ? user.mind.miming : 0
	if(!user.is_muzzled() && !miming)
		user.nextsoundemote = world.time + 7
		if(issilicon(user))
			sound = 'hippiestation/sound/voice/scream_silicon.ogg'
			if(iscyborg(user))
				var/mob/living/silicon/robot/S = user
				if(S.cell.charge < 20)
					to_chat(S, "<span class='warning'>Scream module deactivated. Please recharge.</span>")
					return
				S.cell.use(200)
		if(ismonkey(user))
			sound = 'hippiestation/sound/voice/scream_monkey.ogg'
		if(ishuman(user))
			user.adjustOxyLoss(5)
			sound = pick('hippiestation/sound/voice/scream_m1.ogg', 'hippiestation/sound/voice/scream_m2.ogg')
			if(user.gender == FEMALE)
				sound = pick('hippiestation/sound/voice/scream_f1.ogg', 'hippiestation/sound/voice/scream_f2.ogg')
			if(is_species(user, /datum/species/android) || is_species(user, /datum/species/synth) || is_species(user, /datum/species/ipc))
				sound = 'hippiestation/sound/voice/scream_silicon.ogg'
			if(is_species(user, /datum/species/lizard))
				sound = 'hippiestation/sound/voice/scream_lizard.ogg'
			if(is_species(user, get_all_of_type(/datum/species/skeleton)))
				sound = 'hippiestation/sound/voice/scream_skeleton.ogg'
			if (is_species(user, /datum/species/fly))
				sound = 'hippiestation/sound/voice/scream_moth.ogg'
			if (is_species(user, /datum/species/bird))
				sound = 'hippiestation/sound/voice/caw.ogg'
			if (is_species(user, /datum/species/tarajan))
				sound = 'hippiestation/sound/voice/cat.ogg'
		if(isalien(user))
			sound = 'sound/voice/hiss6.ogg'
		LAZYINITLIST(user.alternate_screams)
		if(LAZYLEN(user.alternate_screams))
			sound = pick(user.alternate_screams)
		playsound(user.loc, sound, 50, 1, 4, 1.2)
		message = "screams!"
	else if(miming)
		message = "acts out a scream."
	else
		message = "makes a very loud noise."
	. = ..()

/datum/emote/living/burp/run_emote(mob/living/user, params)
	if(ishuman(user))
		if(user.nextsoundemote >= world.time)
			return
		user.nextsoundemote = world.time + 7
		playsound(user, 'hippiestation/sound/voice/burp.ogg', 50, 1, -1)
	. = ..()

/datum/emote/living/cough/run_emote(mob/living/user, params)
	if(ishuman(user))
		if(user.nextsoundemote >= world.time)
			return
		user.nextsoundemote = world.time + 7
		var/coughsound = pick('hippiestation/sound/voice/cough1.ogg', 'hippiestation/sound/voice/cough2.ogg', 'hippiestation/sound/voice/cough3.ogg', 'hippiestation/sound/voice/cough4.ogg')
		if(user.gender == FEMALE)
			coughsound = pick('hippiestation/sound/voice/cough_f1.ogg', 'hippiestation/sound/voice/cough_f2.ogg', 'hippiestation/sound/voice/cough_f3.ogg')
		playsound(user.loc, coughsound, 50, 1, 5)
		user.adjustOxyLoss(5)
	. = ..()