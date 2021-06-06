/obj/item/device/soundsynth
	name = "sound synthesizer"
	desc = "A device that is able to create sounds."
	icon_state = "soundsynth"
	item_state = "radio"
	w_class = W_CLASS_TINY

	var/tmp/spam_flag = 0 //To prevent mashing the button to cause annoyance like a huge idiot.
	var/selected_sound = "sound/items/bikehorn.ogg"
	var/shiftpitch = 1
	var/volume = 50

	var/list/sound_list = list( //How I would like to add tabbing to make this not as messy, but BYOND doesn't like that.
	"Honk" = "selected_sound=sound/items/bikehorn.ogg&shiftpitch=1&volume=50",
	"Applause" = "selected_sound=sound/effects/applause.ogg&shiftpitch=1&volume=65",
	"Laughter" = "selected_sound=sound/effects/laughtrack.ogg&shiftpitch=1&volume=65",
	"Rimshot" = "selected_sound=sound/effects/rimshot.ogg&shiftpitch=1&volume=65",
	"Trombone" = "selected_sound=sound/misc/sadtrombone.ogg&shiftpitch=1&volume=50",
	"Airhorn" = "selected_sound=sound/items/airhorn.ogg&shiftpitch=1&volume=50",
  "Alert" = "selected_sound=sound/effects/alert.ogg&shiftpitch=1&volume=50",
  "Boom" = "selected_sound=sound/effects/explosion1.ogg&shiftpitch=1&volume=50",
	"Boom from Afar" = "selected_sound=sound/effects/explosionfar.ogg&shiftpitch=1&volume=50",
  "Bubbles" = "selected_sound=sound/effects/bubbles.ogg&shiftpitch=1&volume=50",
  "Construction Noises" = "selected_sound=sound/items/deconstruct.ogg&shiftpitch=1&volume=60",
  "Creepy Whisper" = "selected_sound=sound/hallucinations/turn_around1.ogg&shiftpitch=1&volume=50",
  "Ding" = "selected_sound=sound/machines/ding.ogg&shiftpitch=1&volume=50",
  "Double Beep" = "selected_sound=sound/machines/twobeep.ogg&shiftpitch=1&volume=50",
  "Flush" = "selected_sound=sound/machines/disposalflush.ogg&shiftpitch=1&volume=40",
  "Startup" = "selected_sound=sound/mecha/nominal.ogg&shiftpitch=0&volume=50",
  "Welding Noises" = "selected_sound=sound/items/Welder.ogg&shiftpitch=1&volume=55",
	"Short Slide Whistle" = "selected_sound=sound/effects/slide_whistle_short.ogg&shiftpitch=1&volume=50",
	"Long Slide Whistle" = "selected_sound=sound/effects/slide_whistle_long.ogg&shiftpitch=1&volume=50",
	"Time Stop" = "selected_sound=sound/magic/timeparadox2.ogg&shiftpitch=0&volume=80",
	)

/obj/item/device/soundsynth/verb/pick_sound()
	set category = "Object"
	set name = "Select Sound Playback"
	var/chosen_sound = input("Pick a sound:", null) as null|anything in sound_list
	if(!chosen_sound)
		return
	to_chat(usr, "Sound playback set to: [chosen_sound]!")
	var/list/sound_parser = params2list(sound_list[chosen_sound])
	selected_sound = sound_parser["selected_sound"]
	shiftpitch = text2num(sound_parser["shiftpitch"])
	volume = text2num(sound_parser["volume"])

/obj/item/device/soundsynth/attack_self(mob/user as mob)
	if(spam_flag + 2 SECONDS < world.timeofday)
		playsound(src, selected_sound, volume, shiftpitch)
		spam_flag = world.timeofday

/obj/item/device/soundsynth/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user)
		pick_sound()
	else if(spam_flag + 2 SECONDS < world.timeofday)
		M.playsound_local(get_turf(src), selected_sound, volume, shiftpitch)
		spam_flag = world.timeofday

/obj/item/device/soundsynth/AltClick()
	if(!usr.incapacitated() && Adjacent(usr))
		pick_sound()
		return
	return ..()
