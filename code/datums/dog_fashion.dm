/datum/dog_fashion
	var/name
	var/desc
	var/emote_see
	var/emote_hear
	var/speak
	var/speak_emote

	// This isn't applied to the dog, but stores the icon_state of the
	// sprite that the associated item uses
	var/icon_file
	var/obj_icon_state
	var/obj_alpha
	var/obj_color

/datum/dog_fashion/New(mob/M)
	name = replacetext(name, "REAL_NAME", M.real_name)
	desc = replacetext(desc, "NAME", name)

/datum/dog_fashion/proc/apply(mob/living/basic/pet/dog/D)
	if(name)
		D.name = name
	if(desc)
		D.desc = desc
	if(speak_emote)
		D.speak_emote = string_list(speak_emote)

/datum/dog_fashion/proc/apply_to_speech(datum/ai_planning_subtree/random_speech/speech)
	if(emote_see)
		speech.emote_see = string_list(emote_see)
	if(emote_hear)
		speech.emote_hear = string_list(emote_hear)
	if(speak)
		speech.speak = string_list(speak)

/datum/dog_fashion/proc/get_overlay(dir)
	if(icon_file && obj_icon_state)
		var/image/corgI = image(icon_file, obj_icon_state, dir = dir)
		corgI.alpha = obj_alpha
		corgI.color = obj_color
		return corgI


/datum/dog_fashion/head
	icon_file = 'icons/mob/simple/corgi_head.dmi'

/datum/dog_fashion/back
	icon_file = 'icons/mob/simple/corgi_back.dmi'

/datum/dog_fashion/head/helmet
	name = "Sergeant REAL_NAME"
	desc = "The ever-loyal, the ever-vigilant."

/datum/dog_fashion/head/chef
	name = "Sous chef REAL_NAME"
	desc = "Your food will be taste-tested. All of it."


/datum/dog_fashion/head/captain
	name = "Captain REAL_NAME"
	desc = "Probably better than the last captain."

/datum/dog_fashion/head/kitty
	name = "Runtime"
	emote_see = list("coughs up a furball", "stretches")
	emote_hear = list("purrs")
	speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
	desc = "They're a cute little kitty-cat! ... wait ... what the hell?"

/datum/dog_fashion/head/rabbit
	name = "Hoppy"
	emote_see = list("twitches their nose", "hops around a bit")
	desc = "This is Hoppy. They're a corgi-...urmm... bunny rabbit."

/datum/dog_fashion/head/beret
	name = "Yann"
	desc = "Mon dieu! C'est un chien!"
	speak = list("le woof!", "le bark!", "JAPPE!!")
	emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of them.")


/datum/dog_fashion/head/detective
	name = "Detective REAL_NAME"
	desc = "NAME sees through your lies..."
	emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.","takes a candycorn from the hat.")


/datum/dog_fashion/head/nurse
	name = "Nurse REAL_NAME"
	desc = "NAME needs 100cc of beef jerky... STAT!"

/datum/dog_fashion/head/pirate
	name = "Pirate-title Pirate-name"
	desc = "Yaarghh!! Thar' be a scurvy dog!"
	emote_see = list("hunts for treasure.","stares coldly...","gnashes their tiny corgi teeth!")
	emote_hear = list("growls ferociously!", "snarls.")
	speak = list("Arrrrgh!!","Grrrrrr!")

/datum/dog_fashion/head/pirate/New(mob/M)
	..()
	name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"

/datum/dog_fashion/head/ushanka
	name = "Communist-title Realname"
	desc = "A follower of Karl Barx."
	emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vanguardism.")

/datum/dog_fashion/head/ushanka/New(mob/M)
	..()
	name = "[pick("Comrade","Commissar","Glorious Leader")] [M.real_name]"

/datum/dog_fashion/head/warden
	name = "Officer REAL_NAME"
	emote_see = list("drools.","looks for donuts.")
	desc = "Stop right there criminal scum!"

/datum/dog_fashion/head/warden_red
	name = "Officer REAL_NAME"
	emote_see = list("drools.","looks for donuts.")
	desc = "Stop right there criminal scum!"

/datum/dog_fashion/head/blue_wizard
	name = "Grandwizard REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI NATH!")

/datum/dog_fashion/head/red_wizard
	name = "Pyromancer REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "ONI SOMA!")

/datum/dog_fashion/head/cardborg
	name = "Borgi"
	speak = list("Ping!","Beep!","Woof!")
	emote_see = list("goes rogue.", "sniffs out non-humans.")
	desc = "Result of robotics budget cuts."

/datum/dog_fashion/head/ghost
	name = "\improper Ghost"
	speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
	emote_see = list("stumbles around.", "shivers.")
	emote_hear = list("howls!","groans.")
	desc = "Spooky!"
	obj_icon_state = "sheet"

/datum/dog_fashion/head/santa
	name = "Santa's Corgi Helper"
	emote_hear = list("barks Christmas songs.", "yaps merrily!")
	emote_see = list("looks for presents.", "checks their list.")
	desc = "They're very fond of milk and cookies."

/datum/dog_fashion/head/cargo_tech
	name = "Corgi Tech REAL_NAME"
	desc = "The reason your yellow gloves have chew-marks."

/datum/dog_fashion/head/reindeer
	name = "REAL_NAME the red-nosed Corgi"
	emote_hear = list("lights the way!", "illuminates.", "yaps!")
	desc = "They have a very shiny nose."

/datum/dog_fashion/head/sombrero
	name = "Segnor REAL_NAME"
	desc = "You must respect Elder Dogname"

/datum/dog_fashion/head/sombrero/New(mob/M)
	..()
	desc = "You must respect Elder [M.real_name]."

/datum/dog_fashion/head/hop
	name = "Lieutenant REAL_NAME"
	desc = "Can actually be trusted to not run off on their own."

/datum/dog_fashion/head/deathsquad
	name = "Trooper REAL_NAME"
	desc = "That's not red paint. That's real corgi blood."

/datum/dog_fashion/head/clown
	name = "REAL_NAME the Clown"
	desc = "Honkman's best friend."
	speak = list("HONK!", "Honk!")
	emote_see = list("plays tricks.", "slips.")

/datum/dog_fashion/back/deathsquad
	name = "Trooper REAL_NAME"
	desc = "That's not red paint. That's real corgi blood."

/datum/dog_fashion/head/festive
	name = "Festive REAL_NAME"
	desc = "Ready to party!"
	obj_icon_state = "festive"

/datum/dog_fashion/head/pumpkin/unlit
	name = "Headless HoP-less REAL_NAME"
	desc = "A spooky dog spirit of a beloved pet who lost their owner."
	obj_icon_state = "pumpkin0"
	speak = list("BOO!", "AUUUUUUU", "RAAARGH!")
	emote_see = list("shambles around.", "yaps ominously.", "shivers.")
	emote_hear = list("howls at the Moon.", "yaps at the crows!")

/datum/dog_fashion/head/pumpkin/lit
	obj_icon_state = "pumpkin1"

/datum/dog_fashion/head/blumpkin/unlit
	name = "Hue-less Headless HoP-less REAL_NAME"
	desc = "An evil dog spirit of a beloved pet that haunts your treats pantries!"
	obj_icon_state = "blumpkin0"
	speak = list("BOO!", "AUUUUUUU", "RAAARGH!")
	emote_see = list("shambles around.", "yaps ominously.", "shivers.")
	emote_hear = list("howls at the Moon.", "yaps at the crows!", "growls eerily!")

/datum/dog_fashion/head/blumpkin/lit
	obj_icon_state = "blumpkin1"
