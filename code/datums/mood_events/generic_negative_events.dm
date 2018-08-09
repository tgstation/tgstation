/datum/mood_event/handcuffed
	description = "<span class='warning'>I guess my antics have finally caught up with me.</span>\n"
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
  description = "<span class='boldwarning'>I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow...</span>\n"
  mood_change = -8

/datum/mood_event/on_fire
	description = "<span class='boldwarning'>I'M ON FIRE!!!</span>\n"
	mood_change = -8

/datum/mood_event/suffocation
	description = "<span class='boldwarning'>CAN'T... BREATHE...</span>\n"
	mood_change = -6

/datum/mood_event/burnt_thumb
	description = "<span class='warning'>I shouldn't play with lighters...</span>\n"
	mood_change = -1
	timeout = 1200

/datum/mood_event/cold
	description = "<span class='warning'>It's way too cold in here.</span>\n"
	mood_change = -2

/datum/mood_event/hot
	description = "<span class='warning'>It's getting hot in here.</span>\n"
	mood_change = -2

/datum/mood_event/creampie
	description = "<span class='warning'>I've been creamed. Tastes like pie flavor.</span>\n"
	mood_change = -2
	timeout = 1800

/datum/mood_event/slipped
	description = "<span class='warning'>I slipped. I should be more careful next time...</span>\n"
	mood_change = -2
	timeout = 1800

/datum/mood_event/eye_stab
	description = "<span class='boldwarning'>I used to be an adventurer like you, until I took a screwdriver to the eye.</span>\n"
	mood_change = -4
	timeout = 1800

/datum/mood_event/delam //SM delamination
	description = "<span class='boldwarning'>Those God damn engineers can't do anything right...</span>\n"
	mood_change = -2
	timeout = 2400

/datum/mood_event/depression
	description = "<span class='warning'>I feel sad for no particular reason.</span>\n"
	mood_change = -9
	timeout = 1200

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
  description = "<span class='boldwarning'>I can't even end it all!</span>\n"
  mood_change = -10
  timeout = 600

/datum/mood_event/dismembered
  description = "<span class='boldwarning'>AHH! I WAS USING THAT LIMB!</span>\n"
  mood_change = -8
  timeout = 2400

/datum/mood_event/noshoes
	 description = "<span class='warning'>I am a disgrace to comedy everywhere!</span>\n"
	 mood_change = -5

/datum/mood_event/tased
	description = "<span class='warning'>There's no \"z\" in \"taser\". It's in the zap.</span>\n"
	mood_change = -3
	timeout = 1200

/datum/mood_event/embedded
	description = "<span class='boldwarning'>Pull it out!</span>\n"
	mood_change = -7

/datum/mood_event/table
	description = "<span class='warning'>Someone threw me on a table!</span>\n"
	mood_change = -2
	timeout = 1200

/datum/mood_event/table/add_effects()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(iscatperson(H))
			H.dna.species.start_wagging_tail(H)
			addtimer(CALLBACK(H.dna.species, /datum/species.proc/stop_wagging_tail, H), 30)
			description =  "<span class='nicegreen'>They want to play on the table!</span>\n"
			mood_change = 2

/datum/mood_event/brain_damage
  mood_change = -3

/datum/mood_event/brain_damage/add_effects()
  var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
  description = "<span class='warning'>Hurr durr... [damage_message]</span>\n"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
  description = "<span class='warning'>HULK SMASH!</span>\n"
  mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
  description = "<span class='warning'>I should have paid attention to the epilepsy warning.</span>\n"
  mood_change = -3
  timeout = 3000

/datum/mood_event/nyctophobia
	description = "<span class='warning'>It sure is dark around here...</span>\n"
	mood_change = -3

/datum/mood_event/family_heirloom_missing
	description = "<span class='warning'>I'm missing my family heirloom...</span>\n"
	mood_change = -4

//These are unused so far but I want to remember them to use them later
/datum/mood_event/cloned_corpse
	description = "<span class='boldwarning'>I recently saw my own corpse...</span>\n"
	mood_change = -6

/datum/mood_event/surgery
	description = "<span class='boldwarning'>HE'S CUTTING ME OPEN!!</span>\n"
	mood_change = -8
