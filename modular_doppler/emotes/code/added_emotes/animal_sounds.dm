// Quill rustling, from vox originally but someone can manage a use for it

/datum/emote/living/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/voxrustle.ogg'

// Birds peeping

/datum/emote/living/peep
	key = "peep"
	key_third_person = "peeps"
	message = "peeps like a bird!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/peep_once.ogg'

/datum/emote/living/peep2
	key = "peep2"
	key_third_person = "peeps twice"
	message = "peeps twice like a bird!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/peep.ogg'

// Weird moth sounds

/datum/emote/living/mothsqueak
	key = "msqueak"
	key_third_person = "lets out a tiny squeak"
	message = "lets out a tiny squeak!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/mothsqueak.ogg'

/datum/emote/living/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters!"
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)
	vary = TRUE

/datum/emote/living/chitter/get_sound(mob/living/user)
	if(ismoth(user))
		return 'modular_doppler/emotes/sound/mothchitter.ogg'
	else
		return 'sound/mobs/non-humanoids/insect/chitter.ogg'

/datum/emote/living/flutter
	key = "flutter"
	key_third_person = "rapidly flutters their wings!"
	message = "rapidly flutters their wings!"
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'sound/mobs/humanoids/moth/moth_flutter.ogg'

// Mouse squeak but an emote

/datum/emote/living/mousesqueak
	key = "squeak"
	key_third_person = "squeaks"
	message = "squeaks!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg'

// Barking, like a dog

/datum/emote/living/bark
	key = "bark"
	key_third_person = "barks"
	message = "barks!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/bark2.ogg'

/datum/emote/living/growl
	key = "growl"
	key_third_person = "growls"
	message = "lets out a growl."
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/growl.ogg'

/datum/emote/living/woof
	key = "woof"
	key_third_person = "woofs"
	message = "lets out a woof."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/woof.ogg'

// !! MOST IMPORTANT EMOTE IN THE CODEBASE !!

/datum/emote/living/meow
	key = "meow"
	key_third_person = "meows"
	message = "meows!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = SFX_CAT_MEOW

// Expanded feline content

/datum/emote/living/hiss
	key = "hiss1"
	key_third_person = "hisses"
	message = "hisses!"
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/hiss.ogg'

/datum/emote/living/rpurr
	key = "rpurr"
	key_third_person = "purrs!"
	message = "purrs!"
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/raptor_purr.ogg'

/datum/emote/living/purr
	key = "purr"
	key_third_person = "purrs!"
	message = "purrs!"
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/feline_purr.ogg'

/datum/emote/living/mggaow
	key = "mggaow"
	key_third_person = "meows loudly"
	message = "meows loudly!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/mggaow.ogg'

/datum/emote/living/mrrp
	key = "mrrp"
	key_third_person = "mrrps"
	message = "mrrps!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/mrrp.ogg'

/datum/emote/living/prbt
	key = "prbt"
	key_third_person = "prbts!"
	message = "prbts!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/prbt.ogg'

// Putting a slime in a hydraulic press

/datum/emote/living/squish
	key = "squish"
	key_third_person = "squishes"
	message = "squishes!"
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/slime_squish.ogg'

// Avian sounds

/datum/emote/living/bawk
	key = "bawk"
	key_third_person = "bawks"
	message = "bawks like a chicken."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/bawk.ogg'

/datum/emote/living/caw
	key = "caw"
	key_third_person = "caws"
	message = "caws!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/caw.ogg'

/datum/emote/living/caw2
	key = "caw2"
	key_third_person = "caws twice"
	message = "caws twice!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/caw2.ogg'

/datum/emote/living/hoot
	key = "hoot"
	key_third_person = "hoots"
	message = "hoots!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/hoot.ogg'

// Sheep sounds

/datum/emote/living/baa
	key = "baa"
	key_third_person = "baas"
	message = "lets out a baa."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/baa.ogg'

/datum/emote/living/baa2
	key = "baa2"
	key_third_person = "baas"
	message = "bleats."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/baa2.ogg'

// I'm not sure what this sound belongs to I'll be honest

/datum/emote/living/wurble
	key = "wurble"
	key_third_person = "wurbles"
	message = "lets out a wurble."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/wurble.ogg'

/datum/emote/living/warble
	key = "warble"
	key_third_person = "warbles"
	message = "warbles!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/warbles.ogg'

/datum/emote/living/trills
	key = "trills"
	key_third_person = "trills!"
	message = "trills!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/trills.ogg'

// Rattling (snakegirl content)

/datum/emote/living/rattle
	key = "rattle"
	key_third_person = "rattles"
	message = "rattles!"
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/rattle.ogg'

// I can't be bothered to sort these any more

/datum/emote/living/moo
	key = "moo"
	key_third_person = "moos!"
	message = "moos!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/moo.ogg'

/datum/emote/living/honk
	key = "honk1"
	key_third_person = "honks loudly like a goose!"
	message = "honks loudly like a goose!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'modular_doppler/emotes/sound/goose_honk.ogg'

/datum/emote/living/gnash
	key = "gnash"
	key_third_person = "gnashes"
	message = "gnashes."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/items/weapons/bite.ogg'

/datum/emote/living/thump
	key = "thump"
	key_third_person = "thumps"
	message = "thumps their foot!"
	emote_type = EMOTE_AUDIBLE
	cant_muffle = TRUE
	vary = TRUE
	sound = 'sound/effects/glass/glassbash.ogg'
