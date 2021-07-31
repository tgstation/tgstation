/datum/mood_event/handcuffed
	description = "I guess my antics have finally caught up with me.\n"
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = "I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow...\n"
	mood_change = -8

/datum/mood_event/on_fire
	description = "I'M ON FIRE!!!\n"
	mood_change = -12

/datum/mood_event/suffocation
	description = "CAN'T... BREATHE...\n"
	mood_change = -12

/datum/mood_event/burnt_thumb
	description = "I shouldn't play with lighters...\n"
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = "It's way too cold in here.\n"
	mood_change = -5

/datum/mood_event/hot
	description = "It's getting hot in here.\n"
	mood_change = -5

/datum/mood_event/creampie
	description = "I've been creamed. Tastes like pie flavor.\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = "I slipped. I should be more careful next time...\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = "I used to be an adventurer like you, until I took a screwdriver to the eye.\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "Those goddamn engineers can't do anything right...\n"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/depression_minimal
	description = "I feel a bit down.\n"
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/depression_mild
	description = "I feel sad for no particular reason.\n"
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/depression_moderate
	description = "I feel miserable.\n"
	mood_change = -14
	timeout = 2 MINUTES

/datum/mood_event/depression_severe
	description = "I've lost all hope.\n"
	mood_change = -16
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = "I can't even end it all!\n"
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = "AHH! I WAS USING THAT LIMB!\n"
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/tased
	description = "There's no \"z\" in \"taser\". It's in the zap.\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "Pull it out!\n"
	mood_change = -7

/datum/mood_event/table
	description = "Someone threw me on a table!\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/table/add_effects()
	if(isfelinid(owner))
		var/mob/living/carbon/human/H = owner
		H.dna.species.start_wagging_tail(H)
		addtimer(CALLBACK(H.dna.species, /datum/species.proc/stop_wagging_tail, H), 3 SECONDS)
		description = "<span class='nicegreen'>They want to play on the table!\n"
		mood_change = 2

/datum/mood_event/table_limbsmash
	description = "That fucking table, man that hurts...\n"
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/table_limbsmash/add_effects(obj/item/bodypart/banged_limb)
	if(banged_limb)
		description = "My fucking [banged_limb.name], man that hurts...\n"

/datum/mood_event/brain_damage
	mood_change = -3

/datum/mood_event/brain_damage/add_effects()
	var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
	description = "Hurr durr... [damage_message]\n"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
	description = "HULK SMASH!\n"
	mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
	description = "I should have paid attention to the epilepsy warning.\n"
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/nyctophobia
	description = "It sure is dark around here...\n"
	mood_change = -3

/datum/mood_event/bright_light
	description = "I hate it in the light...I need to find a darker place...\n"
	mood_change = -12

/datum/mood_event/family_heirloom_missing
	description = "I'm missing my family heirloom...\n"
	mood_change = -4

/datum/mood_event/healsbadman
	description = "I feel like I'm held together by flimsy string, and could fall apart at any moment!\n"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/jittery
	description = "I'm nervous and on edge and I can't stand still!!\n"
	mood_change = -2

/datum/mood_event/vomit
	description = "I just threw up. Gross.\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = "I just threw up all over myself. This is disgusting.\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = "Medicine may be good for me but right now it stings like hell.\n"
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = "The rattling of those bones... It still haunts me.\n"
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/loud_gong
	description = "That loud gong noise really hurt my ears!\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/notcreeping
	description = "The voices are not happy, and they painfully contort my thoughts into getting back on task.\n"
	mood_change = -6
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "THEY NEEEEEEED OBSESSIONNNN!!\n"
	mood_change = -30
	timeout = 3 SECONDS

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "THEY NEEEEEEED [unhinged]!!\n"

/datum/mood_event/sapped
	description = "Some unexplainable sadness is consuming me...\n"
	mood_change = -15
	timeout = 90 SECONDS

/datum/mood_event/back_pain
	description = "Bags never sit right on my back, this hurts like hell!\n"
	mood_change = -15

/datum/mood_event/sad_empath
	description = "Someone seems upset...\n"
	mood_change = -1
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "[sadtarget.name] seems upset...\n"

/datum/mood_event/sacrifice_bad
	description = "Those darn savages!\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/artbad
	description = "I've produced better art than that from my ass.\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/graverobbing
	description = "I just desecrated someone's grave... I can't believe I did that...\n"
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/deaths_door
	description = "This is it... I'm really going to die.\n"
	mood_change = -20

/datum/mood_event/gunpoint
	description = "This guy is insane! I better be careful...\n"
	mood_change = -10

/datum/mood_event/tripped
	description = "I can't believe I fell for the oldest trick in the book!\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/untied
	description = "I hate when my shoes come untied!\n"
	mood_change = -3
	timeout = 60 SECONDS

/datum/mood_event/gates_of_mansus
	description = "I HAD A GLIMPSE OF THE HORROR BEYOND THIS WORLD. REALITY UNCOILED BEFORE MY EYES!\n"
	mood_change = -25
	timeout = 4 MINUTES

/datum/mood_event/high_five_alone
	description = "I tried getting a high-five with no one around, how embarassing!\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/high_five_full_hand
	description = "Oh god, I don't even know how to high-five correctly...\n"
	mood_change = -1
	timeout = 45 SECONDS

/datum/mood_event/left_hanging
	description = "But everyone loves high fives! Maybe people just... hate me?\n"
	mood_change = -2
	timeout = 90 SECONDS

/datum/mood_event/too_slow
	description = "NO! HOW COULD I BE... TOO SLOW???\n"
	mood_change = -2 // multiplied by how many people saw it happen, up to 8, so potentially massive. the ULTIMATE prank carries a lot of weight
	timeout = 2 MINUTES

/datum/mood_event/too_slow/add_effects(param)
	var/people_laughing_at_you = 1 // start with 1 in case they're on the same tile or something
	for(var/mob/living/carbon/iter_carbon in oview(owner, 7))
		if(iter_carbon.stat == CONSCIOUS)
			people_laughing_at_you++
			if(people_laughing_at_you > 7)
				break

	mood_change *= people_laughing_at_you
	return ..()

//These are unused so far but I want to remember them to use them later
/datum/mood_event/surgery
	description = "THEY'RE CUTTING ME OPEN!!\n"
	mood_change = -8

/datum/mood_event/bald
	description = "I need something to cover my head...\n"
	mood_change = -3

/datum/mood_event/bad_touch
	description = "I don't like when people touch me.\n"
	mood_change = -3
	timeout = 4 MINUTES

/datum/mood_event/very_bad_touch
	description = "I really don't like when people touch me.\n"
	mood_change = -5
	timeout = 4 MINUTES

/datum/mood_event/noogie
	description = "Ow! This is like space high school all over again...\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/noogie_harsh
	description = "OW!! That was even worse than a regular noogie!\n"
	mood_change = -4
	timeout = 60 SECONDS

/datum/mood_event/aquarium_negative
	description = "All the fish are dead...\n"
	mood_change = -3
	timeout = 90 SECONDS

/datum/mood_event/tail_lost
	description = "My tail!! Why?!\n"
	mood_change = -8
	timeout = 10 MINUTES

/datum/mood_event/tail_balance_lost
	description = "I feel off-balance without my tail.\n"
	mood_change = -2

/datum/mood_event/tail_regained_right
	description = "My tail is back, but that was traumatic...\n"
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_wrong
	description = "Is this some kind of sick joke?! This is NOT the right tail.\n"
	mood_change = -12 // -8 for tail still missing + -4 bonus for being frakenstein's monster
	timeout = 5 MINUTES

/datum/mood_event/burnt_wings
	description = "MY PRECIOUS WINGS!!\n"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/holy_smite //punished
	description = "I have been punished by my deity!\n"
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/banished //when the chaplain is sus! (and gets forcably de-holy'd)
	description = "I have been excommunicated!\n"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/heresy
	description = "I can hardly breathe with all this HERESY going on!\n"
	mood_change = -5
	timeout = 5 MINUTES
