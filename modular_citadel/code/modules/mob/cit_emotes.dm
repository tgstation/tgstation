/mob
	var/nextsoundemote = 1

//Disables the custom emote blacklist from TG that normally applies to slimes.
/datum/emote/living/custom
	mob_type_blacklist_typecache = list(/mob/living/brain)

/datum/emote/living/scream/run_emote(mob/living/user, params) //I can't not port this shit, come on.
	if(user.nextsoundemote >= world.time || user.stat != CONSCIOUS)
		return
	var/sound
	var/miming = user.mind ? user.mind.miming : 0
	if(!user.is_muzzled() && !miming)
		user.nextsoundemote = world.time + 7
		if(issilicon(user))
			sound = 'modular_citadel/sound/voice/scream_silicon.ogg'
			if(iscyborg(user))
				var/mob/living/silicon/robot/S = user
				if(S.cell.charge < 20)
					to_chat(S, "<span class='warning'>Scream module deactivated. Please recharge.</span>")
					return
				S.cell.use(200)
		if(ismonkey(user))
			sound = 'modular_citadel/sound/voice/scream_monkey.ogg'
		if(istype(user, /mob/living/simple_animal/hostile/gorilla))
			sound = 'sound/creatures/gorilla.ogg'
		if(ishuman(user))
			user.adjustOxyLoss(5)
			sound = pick('modular_citadel/sound/voice/scream_m1.ogg', 'modular_citadel/sound/voice/scream_m2.ogg')
			if(user.gender == FEMALE)
				sound = pick('modular_citadel/sound/voice/scream_f1.ogg', 'modular_citadel/sound/voice/scream_f2.ogg')
			if(is_species(user, /datum/species/android) || is_species(user, /datum/species/synth) || is_species(user, /datum/species/ipc))
				sound = 'modular_citadel/sound/voice/scream_silicon.ogg'
			if(is_species(user, /datum/species/lizard))
				sound = 'modular_citadel/sound/voice/scream_lizard.ogg'
			if(is_species(user, /datum/species/skeleton))
				sound = 'modular_citadel/sound/voice/scream_skeleton.ogg'
			if (is_species(user, /datum/species/fly) || is_species(user, /datum/species/insect))
				sound = 'modular_citadel/sound/voice/scream_moth.ogg'
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

/datum/emote/sound/carbon/snap
	key = "snap"
	key_third_person = "snaps"
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE
	sound = 'sound/effects/snap01.ogg'
	mob_type_allowed_typecache = list(/mob/living/carbon/)


/datum/emote/living/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snap/run_emote(mob/living/user, params)
	if(ishuman(user))
		if(user.nextsoundemote >= world.time)
			return
		user.nextsoundemote = world.time + 7
		playsound(user, 'modular_citadel/sound/voice/snap.ogg', 50, 1, -1)
	. = ..()

/datum/emote/living/snap2
	key = "snap2"
	key_third_person = "snaps twice"
	message = "snaps twice."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snap2/run_emote(mob/living/user, params)
	if(ishuman(user))
		if(user.nextsoundemote >= world.time)
			return
		user.nextsoundemote = world.time + 7
		playsound(user, 'modular_citadel/sound/voice/snap2.ogg', 50, 1, -1)
	. = ..()

/datum/emote/living/snap3
	key = "snap3"
	key_third_person = "snaps thrice"
	message = "snaps thrice."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snap3/run_emote(mob/living/user, params)
	if(ishuman(user))
		if(user.nextsoundemote >= world.time)
			return
		user.nextsoundemote = world.time + 7
		playsound(user, 'modular_citadel/sound/voice/snap3.ogg', 50, 1, -1)
	. = ..()

/datum/emote/living/nya
	key = "nya"
	key_third_person = "nyas audibly"
	message = "nyas"
	emote_type = EMOTA_AUDIBLE
	sound = 'sound/effects/nya.ogg'
	mob_type_allowed_typecache = list(/mob/living/carbon/)