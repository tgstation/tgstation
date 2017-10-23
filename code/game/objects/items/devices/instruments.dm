//copy pasta of the space piano, don't hurt me -Pete
/obj/item/device/instrument
	name = "generic instrument"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "mid"

/obj/item/device/instrument/Initialize()
	. = ..()
	song = new(instrumentId, src, instrumentExt)

/obj/item/device/instrument/Destroy()
	qdel(song)
	song = null
	return ..()

/obj/item/device/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/device/instrument/Initialize(mapload)
	. = ..()
	if(mapload)
		song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded

/obj/item/device/instrument/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 1
	interact(user)

/obj/item/device/instrument/interact(mob/user)
	if(!user)
		return

	if(!isliving(user) || user.stat || user.restrained() || user.lying)
		return

	user.set_machine(src)
	song.interact(user)

/obj/item/device/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	force = 10
	hitsound = "swing_hit"
	instrumentId = "violin"

/obj/item/device/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	item_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/device/instrument/piano_synth
	name = "synthesizer"
	desc = "An advanced electronic synthesizer that can be used as various instruments."
	icon_state = "synth"
	item_state = "synth"
	instrumentId = "piano"
	instrumentExt = "ogg"
	var/static/list/insTypes = list("accordion" = "mid", "bikehorn" = "ogg", "glockenspiel" = "mid", "guitar" = "ogg", "harmonica" = "mid", "piano" = "ogg", "recorder" = "mid", "saxophone" = "mid", "trombone" = "mid", "violin" = "mid", "xylophone" = "mid")	//No eguitar you ear-rapey fuckers.
	actions_types = list(/datum/action/item_action/synthswitch)

/obj/item/device/instrument/piano_synth/proc/changeInstrument(name = "piano")
	song.instrumentDir = name
	song.instrumentExt = insTypes[name]

/obj/item/device/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	instrumentExt = "ogg"
	force = 10
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrumentId = "guitar"

/obj/item/device/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrumentId = "eguitar"
	instrumentExt = "ogg"

/obj/item/device/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	instrumentId = "glockenspiel"

/obj/item/device/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	item_state = "accordion"
	instrumentId = "accordion"

/obj/item/device/instrument/brass/trumpet
	name = "trumpet"
	desc = "To announce the arrival of the king!"
	icon_state = "trumpet"
	item_state = "trombone"
	instrumentId = "trombone"

/obj/item/device/instrument/brass/trumpet/spectral
	name = "spectral trumpet"
	desc = "Things are about to get spooky!"
	icon_state = "trumpet"
	item_state = "trombone"
	force = 0
	instrumentId = "trombone"
	attack_verb = list("played","jazzed","trumpeted","mourned","dooted")

/obj/item/device/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	item_state = "saxophone"
	instrumentId = "saxophone"

/obj/item/device/instrument/brass/saxophone/spectral
	name = "spectral saxophone"
	desc = "This spooky sound will be sure to leave mortals in bones."
	icon_state = "saxophone"
	item_state = "saxophone"
	instrumentId = "saxophone"
	force = 0
	attack_verb = list("played","jazzed","saxxed","mourned","dooted")

/obj/item/device/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	item_state = "trombone"
	instrumentId = "trombone"

/obj/item/device/instrument/brass/trombone/spectral
	name = "spectral trombone"
	desc = "A skeleton's favorite instrument. Apply directly on the mortals."
	instrumentId = "trombone"
	icon_state = "trombone"
	item_state = "trombone"
	force = 0
	attack_verb = list("played","jazzed","tromboned","mourned","dooted")

/obj/item/device/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	icon_state = "recorder"
	item_state = "recorder"
	instrumentId = "recorder"

/obj/item/device/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	item_state = "harmonica"
	instrumentId = "harmonica"
	slot_flags = SLOT_MASK
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)

/obj/item/device/instrument/harmonica/speechModification(message)
	if(song.playing && ismob(loc))
		to_chat(loc, "<span class='warning'>You stop playing the harmonica to talk...</span>")
		song.playing = FALSE
	return message

/obj/item/device/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	attack_verb = list("beautifully honks")
	instrumentId = "bikehorn"
	instrumentExt = "ogg"
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'

//spooky stuff
/obj/item/device/instrument/brass/trumpet/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/trombone/En4.mid', 100,1,-1)
	spectral_attack(C, user)
	..()

/obj/item/device/instrument/brass/saxophone/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/saxophone/En4.mid', 100,1,-1)
	spectral_attack(C, user)
	..()

/obj/item/device/instrument/brass/trombone/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/trombone/Cn4.mid', 100,1,-1)
	spectral_attack(C, user)
	..()

//spooky procs
/obj/item/device/instrument/brass/proc/spectral_attack(mob/living/carbon/C, mob/user)
	if(ishuman(user)) //this weapon wasn't meant for mortals.
		var/mob/living/carbon/human/U = user
		if(!istype(U.dna.species, /datum/species/skeleton))
			U.adjustStaminaLoss(15) //Extra Damage
			attack(user)
			to_chat(U, "<span class= 'danger'> Your ears weren't meant for this spectral sound.</span>")
			return ..()

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.dna.species, /datum/species/skeleton))
			return ..() //undead are unaffected by the spook-pocalypse.
		if(istype(H.dna.species, /datum/species/zombie))
			H.adjustStaminaLoss(20)
			H.Knockdown(15) //zombies can't resist the doot
		C.Jitter(35)
		C.stuttering = 20
		C.adjustStaminaLoss(20) //only humanoids lose the will to live
		to_chat(C, "<font color='red' size='4'><B>DOOT</B></span>")

		if((H.getStaminaLoss() > 95) && (!istype(H.dna.species, /datum/species/skeleton)) && (!istype(H.dna.species, /datum/species/golem)) && (!istype(H.dna.species, /datum/species/android)) && (!istype(H.dna.species, /datum/species/jelly)))
			H.Knockdown(20)
			H.set_species(/datum/species/skeleton)
			H.visible_message("<span class='warning'>[H] has given up on life as a mortal.</span>")
			to_chat(H, "<B>You are the spooky skeleton!</B>")
			to_chat(H, "A new life and identity has begun. Help your fellow skeletons into bringing out the spooky-pocalypse. You haven't forgotten your past life, and are still beholden to past loyalties.")
			change_name(H)	//time for a new name!

	else
		C.Jitter(15)
		C.stuttering = 20

/obj/item/device/instrument/brass/proc/change_name(mob/living/carbon/human/H)
	var/t = stripped_input(H, "Enter your new skeleton name", H.real_name, null, MAX_NAME_LEN)
	if(!t)
		t = "spooky skeleton"
	H.real_name = t