/datum/mood_event/handcuffed
	description = "I guess my antics have finally caught up with me."
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = "I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow..."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/on_fire
	description = "I'M ON FIRE!!!"
	mood_change = -12
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/suffocation
	description = "CAN'T... BREATHE..."
	mood_change = -12
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/burnt_thumb
	description = "I shouldn't play with lighters..."
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = "It's way too cold in here."
	mood_change = -5

/datum/mood_event/hot
	description = "It's getting hot in here."
	mood_change = -5

/datum/mood_event/creampie
	description = "I've been creamed. Tastes like pie flavor."
	mood_change = -2
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_WHIMSY // if whimsical, no penalty

/datum/mood_event/inked
	description = "I've been splashed with squid ink. Tastes like salt."
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = "I slipped. I should be more careful next time..."
	mood_change = -2
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_WHIMSY // if whimsical, no penalty

/datum/mood_event/eye_stab
	description = "I used to be an adventurer like you, until I took a screwdriver to the eye."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "Those goddamn engineers can't do anything right..."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/cascade // Big boi delamination
	description = "I never thought I'd see a resonance cascade, let alone experience one..."
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/depression
	description = "I feel sad for no particular reason."
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = "I can't even end it all!"
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = "AHH! MY LIMB! I WAS USING THAT!"
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/dismembered/add_effects(obj/item/bodypart/limb)
	if(limb)
		description = "AHH! MY [uppertext(limb.plaintext_zone)]! I WAS USING THAT!"

/datum/mood_event/reattachment
	description = "Ouch! My limb feels like I fell asleep on it."
	mood_change = -3
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_PAIN

/datum/mood_event/reattachment/add_effects(obj/item/bodypart/limb)
	if(limb)
		description = "Ouch! My [limb.plaintext_zone] feels like I fell asleep on it."

/datum/mood_event/tased
	description = "There's no \"z\" in \"taser\". It's in the zap."
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "Pull it out!"
	mood_change = -7

/datum/mood_event/table
	description = "Someone threw me on a table!"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/table/add_effects()
	if(isfelinid(owner)) //Holy snowflake batman!
		var/mob/living/carbon/human/feline = owner
		feline.wag_tail(3 SECONDS)
		description = "They want to play on the table!"
		mood_change = 2

/datum/mood_event/table_limbsmash
	description = "That fucking table, man that hurts..."
	mood_change = -3
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_PAIN

/datum/mood_event/table_limbsmash/add_effects(obj/item/bodypart/banged_limb)
	if(banged_limb)
		description = "My fucking [banged_limb.plaintext_zone], man that hurts..."

/datum/mood_event/brain_damage
	mood_change = -3

/datum/mood_event/brain_damage/add_effects()
	var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
	description = "Hurr durr... [damage_message]"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
	description = "HULK SMASH!"
	mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
	description = "I should have paid attention to the epilepsy warning."
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/photophobia
	description = "The lights are too bright..."
	mood_change = -3
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/nyctophobia
	description = "It sure is dark around here..."
	mood_change = -3
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/claustrophobia
	description = "Why do I feel trapped?! Let me out!!!"
	mood_change = -7
	timeout = 1 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/bright_light
	description = "I hate it in the light... I need to find a darker place..."
	mood_change = -12

/datum/mood_event/family_heirloom_missing
	description = "I'm missing my family heirloom..."
	mood_change = -4

/datum/mood_event/healsbadman
	description = "I feel like I'm held together by flimsy string, and could fall apart at any moment!"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/healsbadman/long_term
	timeout = 10 MINUTES

/datum/mood_event/jittery
	description = "I'm nervous and on edge and I can't stand still!!"
	mood_change = -2

/datum/mood_event/jittery/add_effects(...)
	if(HAS_PERSONALITY(owner, /datum/personality/paranoid))
		mood_change -= 1

/datum/mood_event/choke
	description = "I CAN'T BREATHE!!!"
	mood_change = -10
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/vomit
	description = "I just threw up. Gross."
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = "I just threw up all over myself. This is disgusting."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = "Medicine may be good for me but right now it stings like hell."
	mood_change = -5
	timeout = 60 SECONDS
	event_flags = MOOD_EVENT_PAIN

/datum/mood_event/startled
	description = "Hearing that word made me think about something scary."
	mood_change = -1
	timeout = 1 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/phobia
	description = "I saw something very frightening!"
	mood_change = -4
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/spooked
	description = "The rattling of those bones... It still haunts me."
	mood_change = -4
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/notcreeping
	description = "The voices are not happy, and they painfully contort my thoughts into getting back on task."
	mood_change = -6
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "THEY NEEEEEEED OBSESSIONNNN!!"
	mood_change = -30
	timeout = 3 SECONDS

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "THEY NEEEEEEED [unhinged]!!"

/datum/mood_event/tower_of_babel
	description = "My ability to communicate is an incoherent babel..."
	mood_change = -1
	timeout = 15 SECONDS

/datum/mood_event/back_pain
	description = "Bags never sit right on my back, this hurts like hell!"
	mood_change = -15
	event_flags = MOOD_EVENT_PAIN

/datum/mood_event/sad_empath
	description = "Someone seems upset..."
	mood_change = -1
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "[sadtarget.name] seems upset..."

/datum/mood_event/sacrifice_bad
	description = "Those darn savages!"
	mood_change = -5
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_SPIRITUAL

/datum/mood_event/artbad
	description = "I've produced better art than that from my ass."
	mood_change = -2
	timeout = 2 MINUTES
	event_flags = MOOD_EVENT_ART

/datum/mood_event/artbad/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/creative))
		mood_change = 0
		description = "Everyone has to start their art journey somewhere!"

/datum/mood_event/graverobbing
	description = "I just desecrated someone's grave... I can't believe I did that..."
	mood_change = -8
	timeout = 3 MINUTES

/datum/mood_event/deaths_door
	description = "This is it... I'm really going to die."
	mood_change = -20

/datum/mood_event/gunpoint
	description = "This guy is insane! I better be careful..."
	mood_change = -10
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/tripped
	description = "I can't believe I fell for the oldest trick in the book!"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/untied
	description = "I hate when my shoes come untied!"
	mood_change = -3
	timeout = 60 SECONDS

/datum/mood_event/gates_of_mansus
	description = "I HAD A GLIMPSE OF THE HORROR BEYOND THIS WORLD. REALITY UNCOILED BEFORE MY EYES!"
	mood_change = -25
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/high_five_full_hand
	description = "Oh god, I don't even know how to high-five correctly..."
	mood_change = -1
	timeout = 45 SECONDS

/datum/mood_event/too_slow
	description = "NO! HOW COULD I BE... TOO SLOW???"
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

/datum/mood_event/surgery
	description = "THEY'RE CUTTING ME OPEN!!"
	mood_change = -8
	event_flags = MOOD_EVENT_FEAR
	var/surgery_completed = FALSE

/datum/mood_event/surgery/success
	description = "That surgery really hurt... Glad it worked, I guess..."
	timeout = 3 MINUTES
	surgery_completed = TRUE

/datum/mood_event/surgery/failure
	description = "AHHHHHGH! THEY FILLETED ME ALIVE!"
	timeout = 10 MINUTES
	surgery_completed = TRUE

/datum/mood_event/bald
	description = "I need something to cover my head..."
	mood_change = -3

/datum/mood_event/bald_reminder
	description = "I was reminded that I can't grow my hair back at all! This is awful!"
	mood_change = -5
	timeout = 4 MINUTES

/datum/mood_event/bad_touch
	description = "I don't like when people touch me."
	mood_change = -3
	timeout = 4 MINUTES

/datum/mood_event/very_bad_touch
	description = "I really don't like when people touch me."
	mood_change = -5
	timeout = 4 MINUTES

/datum/mood_event/noogie
	description = "Ow! This is like space high school all over again..."
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/noogie_harsh
	description = "OW!! That was even worse than a regular noogie!"
	mood_change = -4
	timeout = 60 SECONDS

/datum/mood_event/aquarium_negative
	description = "All the fish are dead..."
	mood_change = -3
	timeout = 90 SECONDS

/datum/mood_event/tail_lost
	description = "My tail!! Why?!"
	mood_change = -8
	timeout = 10 MINUTES

/datum/mood_event/tail_balance_lost
	description = "I feel off-balance without my tail."
	mood_change = -2

/datum/mood_event/tail_regained_wrong
	description = "Is this some kind of sick joke?! This is NOT the right tail."
	mood_change = -12 // -8 for tail still missing + -4 bonus for being frakenstein's monster
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_species
	description = "This tail is not mine, but at least it balances me out..."
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_right
	description = "My tail is back, but that was traumatic..."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/burnt_wings
	description = "MY PRECIOUS WINGS!!"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/holy_smite //punished
	description = "I have been punished by my deity!"
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/banished //when the chaplain is sus! (and gets forcably de-holy'd)
	description = "I have been excommunicated!"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/heresy
	description = "I can hardly breathe with all this HERESY going on!"
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/soda_spill
	description = "Cool! That's fine, I wanted to wear that soda, not drink it..."
	mood_change = -2
	timeout = 1 MINUTES

/datum/mood_event/watersprayed
	description = "I hate being sprayed with water!"
	mood_change = -1
	timeout = 30 SECONDS

/datum/mood_event/gamer_withdrawal
	description = "I wish I was gaming right now..."
	mood_change = -5
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/gamer_lost
	description = "If I'm not good at video games, can I truly call myself a gamer?"
	mood_change = -6
	timeout = 10 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/lost_52_card_pickup
	description = "This is really embarrassing! I'm ashamed to pick up all these cards off the floor..."
	mood_change = -3
	timeout = 3 MINUTES
	event_flags = MOOD_EVENT_WHIMSY | MOOD_EVENT_GAMING

/datum/mood_event/russian_roulette_lose_cheater
	description = "I gambled and lost! Good thing I wasn't aiming for my head..."
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/russian_roulette_lose
	description = "I gambled my life and lost! I guess this is the end..."
	mood_change = -20
	timeout = 10 MINUTES

/datum/mood_event/russian_roulette_lose/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/gambler))
		mood_change *= 0.5
		description = "I gambled my life and lost! Truth is, the game was rigged from the start..."
		return

/datum/mood_event/bad_touch_bear_hug
	description = "I just got squeezed way too hard."
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/rippedtail
	description = "I ripped their tail right off, what have I done!"
	mood_change = -5
	timeout = 30 SECONDS

/datum/mood_event/sabrage_fail
	description = "Blast it! That stunt didn't go as planned!"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/body_purist
	description = "I feel cybernetics attached to me, and I HATE IT!"

/datum/mood_event/body_purist/add_effects(power)
	mood_change = power

/datum/mood_event/unsatisfied_nomad
	description = "I've been here too long! I want to go out and explore space!"
	mood_change = -3

/datum/mood_event/moon_insanity
	description = "THE MOON JUDGES AND FINDS ME WANTING!!!"
	mood_change = -3
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/moon_insanity/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/spiritual))
		mood_change *= 2

/datum/mood_event/amulet_insanity
	description = "I sEe THe LiGHt, It mUsT BE stOPPed!"
	mood_change = -6
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/mallet_humiliation
	description = "Getting hit by such a stupid weapon feels rather humiliating..."
	mood_change = -3
	timeout = 10 SECONDS

///Wizard cheesy grand finale - what everyone but the wizard gets
/datum/mood_event/madness_despair
	description = "UNWORTHY, UNWORTHY, UNWORTHY!!!"
	mood_change = -200
	special_screen_obj = "mood_despair"

/datum/mood_event/all_nighter
	description = "I didn't sleep at all last night. I'm exhausted."
	mood_change = -5

//Used by the Veteran Advisor trait job
/datum/mood_event/desentized
	description = "Nothing will ever rival what I've seen in the past..."
	mood_change = -3
	special_screen_obj = "mood_desentized"

//Used for the psychotic brawling martial art, if the person is a pacifist.
/datum/mood_event/pacifism_bypassed
	description = "I DIDN'T MEAN TO HURT THEM!"
	mood_change = -20
	timeout = 10 MINUTES

//Gained when you're hit over the head with wrapping paper or cardboard roll
/datum/mood_event/bapped
	description = "Ow.. my head, I feel a bit foolish now!"
	mood_change = -1
	timeout = 3 MINUTES

/datum/mood_event/bapped/add_effects()
	// Felinids apparently hate being hit over the head with cardboard
	if(isfelinid(owner))
		mood_change = -2

/datum/mood_event/encountered_evil
	description = "I didn't want to believe it, but there are people out there that are genuinely evil."
	mood_change = -1
	timeout = 1 MINUTES

/datum/mood_event/smoke_in_face
	description = "Cigarette smoke is disgusting."
	mood_change = -3
	timeout = 30 SECONDS

/datum/mood_event/smoke_in_face/add_effects(param)
	if(HAS_TRAIT(owner, TRAIT_ANOSMIA))
		description = "Cigarette smoke is unpleasant."
		mood_change = -1
	if(HAS_TRAIT(owner, TRAIT_SMOKER))
		description = "Blowing smoke in my face, really?"
		mood_change = 0

/datum/mood_event/see_death
	description = "I just saw someone die. How horrible..."
	mood_change = -8
	timeout = 5 MINUTES
	/// Message variant for callous people
	var/dont_care_message = "Oh, %DEAD_MOB% died. Shame, I guess."
	/// Message variant for people who care about animals
	var/pet_message = "%DEAD_MOB% just died!!"
	/// Message variant for desensitized people (security, medical, cult with halo, etc)
	var/desensitized_message = "I saw %DEAD_MOB% die."
	var/normal_message = "I just saw %DEAD_MOB% die. How horrible..."

/datum/mood_event/see_death/add_effects(mob/dead_mob)
	if(isnull(dead_mob))
		return
	if(HAS_TRAIT(owner, TRAIT_CULT_HALO) && !HAS_TRAIT(dead_mob, TRAIT_CULT_HALO))
		// When cultists get halos, they stop caring about death
		mood_change = 4
		description = "More souls for the Geometer!"
		return

	var/ispet = istype(dead_mob, /mob/living/basic/pet) || ismonkey(dead_mob)
	if(HAS_PERSONALITY(owner, /datum/personality/callous) || (ispet && HAS_PERSONALITY(owner, /datum/personality/animal_disliker)))
		description = replacetext(dont_care_message, "%DEAD_MOB%", get_descriptor(dead_mob))
		mood_change = 0
		timeout *= 0.5
		return
	// future todo : make the hop care about ian, cmo runtime, etc.
	if(ispet)
		description = replacetext(pet_message, "%DEAD_MOB%", capitalize(dead_mob.name)) // doesn't use a descriptor, so it says "Ian died"
		if(HAS_PERSONALITY(owner, /datum/personality/animal_friend))
			mood_change *= 1.5
			timeout *= 1.25
		else if(!HAS_PERSONALITY(owner, /datum/personality/compassionate))
			mood_change *= 0.25
			timeout *= 0.5
		return
	if(HAS_PERSONALITY(owner, /datum/personality/compassionate))
		mood_change *= 1.5
		timeout *= 1.5
	if(HAS_TRAIT(owner, TRAIT_DESENSITIZED))
		mood_change *= 0.5
		timeout *= 0.5
		description = replacetext(desensitized_message, "%DEAD_MOB%", get_descriptor(dead_mob))
		return

	description = replacetext(normal_message, "%DEAD_MOB%", get_descriptor(dead_mob))

/datum/mood_event/see_death/be_refreshed(datum/mood/home, ...)
	// Every time we get refreshed we get worse if not desensitized
	if(!HAS_TRAIT(owner, TRAIT_DESENSITIZED))
		mood_change *= 1.5
	return ..()

/datum/mood_event/see_death/be_replaced(datum/mood/home, datum/mood_event/new_event, ...)
	// Only be replaced if the incoming event's base mood is worse than our base mood
	// (IE: replace normal death events with gib events, but not the other way around)
	if(initial(new_event.mood_change) > initial(mood_change))
		new_event.mood_change = max(new_event.mood_change, mood_change * 1.5)
		return ..()
	// Otherwise if it's equivalent or worse, refresh it instead
	return be_refreshed(home)

/// Changes "I saw Joe x" to "I saw the engineer x"
/datum/mood_event/see_death/proc/get_descriptor(mob/dead_mob)
	if(isnull(dead_mob))
		return "something"
	if(dead_mob.name != "Unknown" && dead_mob.mind?.assigned_role?.job_flags & JOB_CREW_MEMBER)
		return "the [LOWER_TEXT(dead_mob.mind?.assigned_role.title)]"
	return "someone"

/datum/mood_event/see_death/gibbed
	description = "Someone just exploded in front of me!!"
	mood_change = -12
	timeout = 10 MINUTES
	dont_care_message = "Oh, %DEAD_MOB% exploded. Now I have to get the mop."
	pet_message = "%DEAD_MOB% just exploded!!"
	desensitized_message = "I saw %DEAD_MOB% explode."
	normal_message = "%DEAD_MOB% just exploded in front of me!!"

/datum/mood_event/see_death/dusted
	description = "Someone was just vaporized in front of me!! I don't feel so good..."
	mood_change = -12
	timeout = 10 MINUTES
	dont_care_message = "Oh, %DEAD_MOB% was vaporized. Now I have to get the dustpan."
	pet_message = "%DEAD_MOB% just vaporized!!"
	desensitized_message = "I saw %DEAD_MOB% get vaporized."
	normal_message = "%DEAD_MOB% was just vaporized in front of me!!"

/datum/mood_event/slots/loss
	description = "Aww dang it!"
	mood_change = -2
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_GAMING

/datum/mood_event/slots/loss/add_effects()
	if(HAS_PERSONALITY(owner, /datum/personality/gambler))
		mood_change = 0
		description = "Aww dang it."
	if(HAS_PERSONALITY(owner, /datum/personality/industrious) || HAS_PERSONALITY(owner, /datum/personality/slacking/diligent))
		mood_change *= 1.5

/datum/mood_event/lost_control_of_life
	description = "I've lost control of my life."
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/empathetic_sad
	description = "Seeing sad people makes me sad."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/misanthropic_sad
	description = "Seeing happy people makes me uneasy."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/paranoid/one_on_one
	description = "I'm alone with someone - what if they want to kill me?"
	mood_change = -3
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/paranoid/large_group
	description = "There are so many people around - any one of them could be out to get me!"
	mood_change = -3
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/nt_disillusioned
	description = "I hate the company, and everything it stands for."
	mood_change = -2

/datum/mood_event/disillusioned_revs_lost
	description = "The revolution was defeated... greaaaat."
	mood_change = -2
	timeout = 10 MINUTES

/datum/mood_event/loyalist_revs_win
	description = "The revolution was a success... This will hurt quarterly profits."
	mood_change = -2
	timeout = 10 MINUTES

/datum/mood_event/slacking_off_diligent
	description = "I should get back to work."
	mood_change = -1

/datum/mood_event/unimaginative_patronage
	description = "That felt like a waste of money."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/unimaginative_framing
	description = "I could've hung something more useful there."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/unimaginative_sculpting
	description = "That felt like a waste of materials."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/splattered_with_blood
	description = "Eugh, I just got coated in blood!"
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/splattered_with_blood/can_effect_mob(datum/mood/home, mob/living/who, ...)
	if(isvampire(who))
		return FALSE

	return ..()

/datum/mood_event/splattered_with_blood/add_effects(...)
	if(HAS_TRAIT(owner, TRAIT_CULT_HALO))
		mood_change = 2
		description = "Blood, blood! The Geometer will be pleased."
		return
	if(HAS_TRAIT(owner, TRAIT_MORBID) || HAS_TRAIT(owner, TRAIT_EVIL))
		mood_change = 0
		description = "I just got coated in blood. Fascinating!"
		return
