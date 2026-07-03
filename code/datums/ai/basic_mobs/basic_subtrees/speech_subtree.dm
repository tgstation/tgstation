/datum/ai_planning_subtree/random_speech
	//The chance of an emote occurring each second
	var/speech_chance = 0
	///Hearable emotes
	var/list/emote_hear
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see
	///Possible lines of speech the AI can have
	var/list/speak
	///The sound effects associated with this speech, if any
	var/list/sound

/datum/ai_planning_subtree/random_speech/New()
	. = ..()
	if(LAZYLEN(speak))
		speak = string_list(speak)
	if(LAZYLEN(sound))
		sound = string_list(sound)
	if(LAZYLEN(emote_hear))
		emote_hear = string_list(emote_hear)
	if(LAZYLEN(emote_see))
		emote_see = string_list(emote_see)

/datum/ai_planning_subtree/random_speech/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(speech_chance, seconds_per_tick))
		return
	speak(controller)

/// Actually perform an action
/datum/ai_planning_subtree/random_speech/proc/speak(datum/ai_controller/controller)
	var/audible_emotes_length = emote_hear?.len
	var/non_audible_emotes_length = emote_see?.len
	var/speak_lines_length = speak?.len

	var/total_choices_length = audible_emotes_length + non_audible_emotes_length + speak_lines_length

	if (total_choices_length == 0)
		return

	var/random_number_in_range = rand(1, total_choices_length)
	var/sound_to_play = length(sound) > 0 ? pick(sound) : null

	if(random_number_in_range <= audible_emotes_length)
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_hear), sound_to_play)
	else if(random_number_in_range <= (audible_emotes_length + non_audible_emotes_length))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_see))
	else
		controller.queue_behavior(/datum/ai_behavior/perform_speech, pick(speak), sound_to_play)

/datum/ai_planning_subtree/random_speech/insect
	speech_chance = 5
	sound = list('sound/mobs/non-humanoids/insect/chitter.ogg')
	emote_hear = list("стрекочет.")

/datum/ai_planning_subtree/random_speech/insect/spider	// SS220 ADD
	sound = list('modular_bandastation/mobs/sound/spider_talk1.ogg', 'modular_bandastation/mobs/sound/spider_talk2.ogg')	// SS220 EDIT

/datum/ai_planning_subtree/random_speech/mothroach
	speech_chance = 15
	sound = list('sound/mobs/non-humanoids/insect/chitter.ogg')	// SS220 EDIT
	emote_hear = list("трепетает.")

/datum/ai_planning_subtree/random_speech/mouse
	speech_chance = 1
	speak = list("Скви!", "СКВИИИ!", "Скви?")
	sound = list('sound/mobs/non-humanoids/mouse/mousesqueek.ogg')
	emote_hear = list("пищит.")
	emote_see = list("бегает по кругу.", "встряхивается.")

/datum/ai_planning_subtree/random_speech/frog
	speech_chance = 3
	speak = list("Квак!","КУААК!","Квуак!")
	sound = list('modular_bandastation/mobs/sound/frog_talk1.ogg', 'modular_bandastation/mobs/sound/frog_talk2.ogg')	// SS220 EDIT
	emote_hear = list("квак","куак","квуак")
	emote_see = list("прыгает по кругу", "раздувается.", "лежит расслабленная.", "издает гортанные звуки.", "лупает глазками.")

/datum/ai_planning_subtree/random_speech/lizard // all of these have to be three words long or i'm killing you. you're dead.
	speech_chance = 3
	emote_hear = list("топчется.", "шипит.")
	emote_see = list("шумит гортанью", "заплетается языком", "наклоняет голову.", "вертится.")

/datum/ai_planning_subtree/random_speech/sheep
	speech_chance = 5
	speak = list("бэээ","бэээЭЭЭЭЭ!","бэээ...")
	sound = list('sound/mobs/non-humanoids/sheep/sheep1.ogg', 'sound/mobs/non-humanoids/sheep/sheep2.ogg', 'sound/mobs/non-humanoids/sheep/sheep3.ogg')
	emote_hear = list("блеет.")
	emote_see = list("трясет головой.", "пялится вдаль.")

/datum/ai_planning_subtree/random_speech/rabbit
	speech_chance = 10
	speak = list("Мррр.", "Чиррр!", "Мррр?") // rabbits make some weird noises dude i don't know what to tell you
	emote_hear = list("прыгает.")
	emote_see = list("прыгает вокруг.", "скачет вверх и вниз.")

/// For the easter subvariant of rabbits, these ones actually speak catchphrases.
/datum/ai_planning_subtree/random_speech/rabbit/easter
	speak = list(
		"Врывайтесь в Пасху!",
		"Приди за своими яйцами!",
		"Награда для всех!",
	)

/// These ones have a space mask on, so their catchphrases are muffled.
/datum/ai_planning_subtree/random_speech/rabbit/easter/space
	speak = list(
		"Hmph mmph mmmph!",
		"Mmphe mmphe mmphe!",
		"Hmm mmm mmm!",
	)

/datum/ai_planning_subtree/random_speech/chicken
	speech_chance = 15 // really talkative ladies
	speak = list("Кудах!", "КУУУД КУУУД КУДАААААХ!", "Кудах-тах-тах.")
	sound = list('sound/mobs/non-humanoids/chicken/clucks.ogg', 'sound/mobs/non-humanoids/chicken/bagawk.ogg', 'modular_bandastation/mobs/sound/chicken_talk.ogg')
	emote_hear = list("кудахчет.", "клокочет.")
	emote_see = list("ключет землю.", "хлопает крыльями","дерзко машет крыльями")

/datum/ai_planning_subtree/random_speech/chick
	speech_chance = 4
	speak = list("Чирик.", "Чирик?", "Чирип.", "Чик!")
	sound = list('sound/mobs/non-humanoids/chicken/chick_peep.ogg')
	emote_hear = list("чирикает.")
	emote_see = list("клюет землю.","машет крошечными крыльями.")

/datum/ai_planning_subtree/random_speech/cow
	speech_chance = 1
	speak = list("муу?","муу","МУУУУУ")
	sound = list('sound/mobs/non-humanoids/cow/cow.ogg', 'modular_bandastation/mobs/sound/cow_talk1.ogg', 'modular_bandastation/mobs/sound/cow_talk2.ogg')	// SS220 EDIT
	emote_hear = list("мычит.")
	emote_see = list("трясет головой.")

///unlike normal cows, wisdom cows speak of wisdom and won't shut the fuck up
/datum/ai_planning_subtree/random_speech/cow/wisdom
	speech_chance = 15

/datum/ai_planning_subtree/random_speech/cow/wisdom/New()
	. = ..()
	speak = GLOB.wisdoms //Done here so it's setup properly
	sound = list()

/datum/ai_planning_subtree/random_speech/deer
	speech_chance = 1
	speak = list("Вуоооо?", "Воооо", "ВУОООООО")
	emote_hear = list("ревет.")
	emote_see = list("трясет головой.")

/datum/ai_planning_subtree/random_speech/dog
	speech_chance = 1
	sound = list('modular_bandastation/mobs/sound/dog_bark1.ogg', 'modular_bandastation/mobs/sound/dog_bark2.ogg') // SS220 EDIT

/datum/ai_planning_subtree/random_speech/dog/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!isdog(controller.pawn))
		return

	// Stay in sync with dog fashion.
	var/mob/living/basic/pet/dog/dog_pawn = controller.pawn
	dog_pawn.update_dog_speech(src)

	return ..()

/datum/ai_planning_subtree/random_speech/faithless
	speech_chance = 1
	emote_see = list("wails.")

/datum/ai_planning_subtree/random_speech/garden_gnome
	speech_chance = 5
	speak = list("Gnot a gnelf!", "Gnot a gnoblin!", "Howdy chum!")
	emote_hear = list("snores.", "burps.")
	emote_see = list("blinks.")

/datum/ai_planning_subtree/random_speech/tree
	speech_chance = 3
	emote_see = list("photosynthesizes angrily.")

/datum/ai_planning_subtree/random_speech/pig
	speech_chance = 3
	speak = list("хрю?","хрю","хрюк")
	sound = list('sound/mobs/non-humanoids/pig/pig1.ogg', 'sound/mobs/non-humanoids/pig/pig2.ogg')
	emote_hear = list("хрюкает.")
	emote_see = list("обнюхивается.")

/datum/ai_planning_subtree/random_speech/pony
	speech_chance = 3
	sound = list('sound/mobs/non-humanoids/pony/whinny01.ogg', 'sound/mobs/non-humanoids/pony/whinny02.ogg', 'sound/mobs/non-humanoids/pony/whinny03.ogg')
	emote_hear = list("игогочет!")
	emote_see = list("скачет по кругу.")

/datum/ai_planning_subtree/random_speech/pony/tamed
	speech_chance = 3
	sound = list('sound/mobs/non-humanoids/pony/snort.ogg')
	emote_hear = list("фыркает.")
	emote_see = list("фыркает.")

/datum/ai_planning_subtree/random_speech/killer_tomato
	speech_chance = 3
	emote_hear = list("gnashes.", "growls lowly.", "snarls.")
	emote_see = list("salivates.")

/datum/ai_planning_subtree/random_speech/ant
	speech_chance = 1
	speak = list("BZZZZT!", "CHTCHTCHT!", "Bzzz", "ChtChtCht")
	sound = list('sound/mobs/non-humanoids/insect/chitter.ogg')
	emote_hear = list("buzzes.", "clacks.")
	emote_see = list("shakes their head.", "twitches their antennae.")

/datum/ai_planning_subtree/random_speech/fox
	speech_chance = 1
	speak = list("Ack-Ack", "Ack-Ack-Ack-Ackawoooo", "Geckers", "Awoo", "Tchoff")
	emote_hear = list("howls.", "barks.", "screams.")
	emote_see = list("shakes their head.", "shivers.")

/datum/ai_planning_subtree/random_speech/crab
	speech_chance = 1
	sound = list('sound/mobs/non-humanoids/crab/claw_click.ogg')
	emote_hear = list("clicks.")
	emote_see = list("clacks.")

/datum/ai_planning_subtree/random_speech/penguin
	speech_chance = 5
	speak = list("Gah Gah!", "NOOT NOOT!", "NOOT!", "Noot", "noot", "Prah!", "Grah!")
	emote_hear = list("squawks", "gakkers")

/datum/ai_planning_subtree/random_speech/bear
	speech_chance = 5
	emote_hear = list("rawrs.","grumbles.","grawls.", "stomps!")
	emote_see = list("stares ferociously.")
	sound = list('modular_bandastation/mobs/sound/bear_talk1.ogg', 'modular_bandastation/mobs/sound/bear_talk2.ogg', 'modular_bandastation/mobs/sound/bear_talk3.ogg') // SS220 ADD

/datum/ai_planning_subtree/random_speech/cats
	speech_chance = 10
	sound = list(/*SFX_CAT_MEOW*/'modular_bandastation/mobs/sound/cat_meow.ogg') // SS220 EDIT
	emote_hear = list("meows.")
	emote_see = list("meows.")

/datum/ai_planning_subtree/random_speech/blackboard //literal tower of babel, subtree form
	speech_chance = 1

/datum/ai_planning_subtree/random_speech/blackboard/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/list/speech_lines = controller.blackboard[BB_BASIC_MOB_SPEAK_LINES]
	if(isnull(speech_lines))
		return ..()

	// Note to future developers: this behaviour a singleton so this probably doesn't work as you would expect
	// The whole speech tree really needs to be refactored because this isn't how we use AI data these days
	speak = speech_lines[BB_EMOTE_SAY] || list()
	emote_see = speech_lines[BB_EMOTE_SEE] || list()
	emote_hear = speech_lines[BB_EMOTE_HEAR] || list()
	sound = speech_lines[BB_EMOTE_SOUND] || list()
	speech_chance = speech_lines[BB_SPEAK_CHANCE] ? speech_lines[BB_SPEAK_CHANCE] : initial(speech_chance)

	return ..()
