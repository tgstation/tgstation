/datum/mood_event/handcuffed
	description = "<span class='warning'>I guess my antics have finally caught up with me.</span>\n"
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = "<span class='boldwarning'>I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow...</span>\n"
	mood_change = -8

/datum/mood_event/on_fire
	description = "<span class='boldwarning'>I'M ON FIRE!!!</span>\n"
	mood_change = -12

/datum/mood_event/suffocation
	description = "<span class='boldwarning'>CAN'T... BREATHE...</span>\n"
	mood_change = -12

/datum/mood_event/burnt_thumb
	description = "<span class='warning'>I shouldn't play with lighters...</span>\n"
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = "<span class='warning'>It's way too cold in here.</span>\n"
	mood_change = -5

/datum/mood_event/hot
	description = "<span class='warning'>It's getting hot in here.</span>\n"
	mood_change = -5

/datum/mood_event/creampie
	description = "<span class='warning'>I've been creamed. Tastes like pie flavor.</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = "<span class='warning'>I slipped. I should be more careful next time...</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = "<span class='boldwarning'>I used to be an adventurer like you, until I took a screwdriver to the eye.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "<span class='boldwarning'>Those goddamn engineers can't do anything right...</span>\n"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/depression_minimal
	description = "<span class='warning'>I feel a bit down.</span>\n"
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/depression_mild
	description = "<span class='warning'>I feel sad for no particular reason.</span>\n"
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/depression_moderate
	description = "<span class='warning'>I feel miserable.</span>\n"
	mood_change = -14
	timeout = 2 MINUTES

/datum/mood_event/depression_severe
	description = "<span class='warning'>I've lost all hope.</span>\n"
	mood_change = -16
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = "<span class='boldwarning'>I can't even end it all!</span>\n"
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = "<span class='boldwarning'>AHH! I WAS USING THAT LIMB!</span>\n"
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/tased
	description = "<span class='warning'>There's no \"z\" in \"taser\". It's in the zap.</span>\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "<span class='boldwarning'>Pull it out!</span>\n"
	mood_change = -7

/datum/mood_event/table
	description = "<span class='warning'>Someone threw me on a table!</span>\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/table/add_effects()
	if(isfelinid(owner))
		var/mob/living/carbon/human/H = owner
		H.dna.species.start_wagging_tail(H)
		addtimer(CALLBACK(H.dna.species, /datum/species.proc/stop_wagging_tail, H), 3 SECONDS)
		description = "<span class='nicegreen'>They want to play on the table!</span>\n"
		mood_change = 2

/datum/mood_event/table_limbsmash
	description = "<span class='warning'>That fucking table, man that hurts...</span>\n"
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/table_limbsmash/add_effects(obj/item/bodypart/banged_limb)
	if(banged_limb)
		description = "<span class='warning'>My fucking [banged_limb.name], man that hurts...</span>\n"

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
	timeout = 5 MINUTES

/datum/mood_event/nyctophobia
	description = "<span class='warning'>It sure is dark around here...</span>\n"
	mood_change = -3

/datum/mood_event/bright_light
	description = "<span class='boldwarning'>I hate it in the light...I need to find a darker place...</span>\n"
	mood_change = -12

/datum/mood_event/family_heirloom_missing
	description = "<span class='warning'>I'm missing my family heirloom...</span>\n"
	mood_change = -4

/datum/mood_event/healsbadman
	description = "<span class='warning'>I feel like I'm held together by flimsy string, and could fall apart at any moment!</span>\n"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/jittery
	description = "<span class='warning'>I'm nervous and on edge and I can't stand still!!</span>\n"
	mood_change = -2

/datum/mood_event/vomit
	description = "<span class='warning'>I just threw up. Gross.</span>\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = "<span class='warning'>I just threw up all over myself. This is disgusting.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = "<span class='warning'>Medicine may be good for me but right now it stings like hell.</span>\n"
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = "<span class='warning'>The rattling of those bones... It still haunts me.</span>\n"
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/loud_gong
	description = "<span class='warning'>That loud gong noise really hurt my ears!</span>\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/notcreeping
	description = "<span class='warning'>The voices are not happy, and they painfully contort my thoughts into getting back on task.</span>\n"
	mood_change = -6
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "<span class='boldwarning'>THEY NEEEEEEED OBSESSIONNNN!!</span>\n"
	mood_change = -30
	timeout = 3 SECONDS

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "<span class='boldwarning'>THEY NEEEEEEED [unhinged]!!</span>\n"

/datum/mood_event/sapped
	description = "<span class='boldwarning'>Some unexplainable sadness is consuming me...</span>\n"
	mood_change = -15
	timeout = 90 SECONDS

/datum/mood_event/back_pain
	description = "<span class='boldwarning'>Bags never sit right on my back, this hurts like hell!</span>\n"
	mood_change = -15

/datum/mood_event/sad_empath
	description = "<span class='warning'>Someone seems upset...</span>\n"
	mood_change = -1
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "<span class='warning'>[sadtarget.name] seems upset...</span>\n"

/datum/mood_event/sacrifice_bad
	description ="<span class='warning'>Those darn savages!</span>\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/artbad
	description = "<span class='warning'>I've produced better art than that from my ass.</span>\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/graverobbing
	description ="<span class='boldwarning'>I just desecrated someone's grave... I can't believe I did that...</span>\n"
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/deaths_door
	description = "<span class='boldwarning'>This is it... I'm really going to die.</span>\n"
	mood_change = -20

/datum/mood_event/gunpoint
	description = "<span class='boldwarning'>This guy is insane! I better be careful...</span>\n"
	mood_change = -10

/datum/mood_event/tripped
	description = "<span class='boldwarning'>I can't believe I fell for the oldest trick in the book!</span>\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/untied
	description = "<span class='boldwarning'>I hate when my shoes come untied!</span>\n"
	mood_change = -3
	timeout = 60 SECONDS

/datum/mood_event/gates_of_mansus
	description = "<span class='boldwarning'>I HAD A GLIMPSE OF THE HORROR BEYOND THIS WORLD. REALITY UNCOILED BEFORE MY EYES!</span>\n"
	mood_change = -25
	timeout = 4 MINUTES

/datum/mood_event/high_five_alone
	description = "<span class='boldwarning'>I tried getting a high-five with no one around, how embarassing!</span>\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/high_five_full_hand
	description = "<span class='boldwarning'>Oh god, I don't even know how to high-five correctly...</span>\n"
	mood_change = -1
	timeout = 45 SECONDS

/datum/mood_event/left_hanging
	description = "<span class='boldwarning'>But everyone loves high fives! Maybe people just... hate me?</span>\n"
	mood_change = -2
	timeout = 90 SECONDS

/datum/mood_event/too_slow
	description = "<span class='boldwarning'>NO! HOW COULD I BE... TOO SLOW???</span>\n"
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
	description = "<span class='boldwarning'>THEY'RE CUTTING ME OPEN!!</span>\n"
	mood_change = -8

/datum/mood_event/nanite_sadness
	description = "<span class='warning robot'>+++++++HAPPINESS SUPPRESSION+++++++</span>\n"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "<span class='warning robot'>+++++++[message]+++++++</span>\n"

/datum/mood_event/bald
	description ="<span class='warning'>I need something to cover my head...</span>\n"
	mood_change = -3

/datum/mood_event/bad_touch
	description = "<span class='warning'>I don't like when people touch me.</span>\n"
	mood_change = -3
	timeout = 4 MINUTES

/datum/mood_event/very_bad_touch
	description = "<span class='warning'>I really don't like when people touch me.</span>\n"
	mood_change = -5
	timeout = 4 MINUTES

/datum/mood_event/noogie
	description = "<span class='warning'>Ow! This is like space high school all over again...</span>\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/noogie_harsh
	description = "<span class='warning'>OW!! That was even worse than a regular noogie!</span>\n"
	mood_change = -4
	timeout = 60 SECONDS

/datum/mood_event/aquarium_negative
	description = "<span class='warning'>All the fish are dead...</span>\n"
	mood_change = -3
	timeout = 90 SECONDS

/datum/mood_event/burnt_wings
	description = "<span class='boldwarning'>MY PRECIOUS WINGS!!</span>\n"
	mood_change = -10
	timeout = 10 MINUTES
