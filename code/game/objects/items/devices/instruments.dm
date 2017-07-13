//copy pasta of the space piano, don't hurt me -Pete
/obj/item/device/instrument
	name = "generic instrument"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "ogg"

/obj/item/device/instrument/New()
	song = new(instrumentId, src)
	song.instrumentExt = instrumentExt
	..()

/obj/item/device/instrument/Destroy()
	qdel(song)
	song = null
	return ..()

/obj/item/device/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/device/instrument/Initialize(mapload)
	..()
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
	desc = "An electronic synthesizer that can play piano music."
	icon_state = "synth"
	item_state = "synth"
	instrumentId = "piano"

/obj/item/device/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
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
