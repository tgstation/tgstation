/datum/mood_event/handcuffed
	description = "I guess my antics have finally caught up with me."
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
	description = "I have brought shame upon my name, and betrayed my fellow mimes by breaking our sacred vow..."
	mood_change = -8

/datum/mood_event/on_fire
	description = "I'M ON FIRE!!!"
	mood_change = -12

/datum/mood_event/suffocation
	description = "CAN'T... BREATHE..."
	mood_change = -12

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

/datum/mood_event/slipped
	description = "I slipped. I should be more careful next time..."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = "I used to be an adventurer like you, until I took a screwdriver to the eye."
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "Those goddamn engineers can't do anything right..."
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/cascade // Big boi delamination
	description = "The engineers have finally done it, we are all going to die..."
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/depression_minimal
	description = "I feel a bit down."
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/depression_mild
	description = "I feel sad for no particular reason."
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/depression_moderate
	description = "I feel miserable."
	mood_change = -14
	timeout = 2 MINUTES

/datum/mood_event/depression_severe
	description = "I've lost all hope."
	mood_change = -16
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
	description = "I can't even end it all!"
	mood_change = -15
	timeout = 60 SECONDS

/datum/mood_event/dismembered
	description = "AHH! I WAS USING THAT LIMB!"
	mood_change = -10
	timeout = 8 MINUTES

/datum/mood_event/dismembered/add_effects(obj/item/bodypart/limb)
	if(limb)
		description = "AHH! I WAS USING THAT [full_capitalize(limb.plaintext_zone)]"

/datum/mood_event/reattachment
	description = "Ouch! My limb feels like I fell asleep on it."
	mood_change = -3
	timeout = 2 MINUTES

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
		var/mob/living/carbon/human/H = owner
		SEND_SIGNAL(H, COMSIG_ORGAN_WAG_TAIL, TRUE, 3 SECONDS)
		description = "They want to play on the table!"
		mood_change = 2

/datum/mood_event/table_limbsmash
	description = "That fucking table, man that hurts..."
	mood_change = -3
	timeout = 3 MINUTES

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

/datum/mood_event/nyctophobia
	description = "It sure is dark around here..."
	mood_change = -3

/datum/mood_event/claustrophobia
	description = "Why do I feel trapped?!  Let me out!!!"
	mood_change = -7
	timeout = 1 MINUTES

/datum/mood_event/bright_light
	description = "I hate it in the light...I need to find a darker place..."
	mood_change = -12

/datum/mood_event/family_heirloom_missing
	description = "I'm missing my family heirloom..."
	mood_change = -4

/datum/mood_event/healsbadman
	description = "I feel like I'm held together by flimsy string, and could fall apart at any moment!"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/jittery
	description = "I'm nervous and on edge and I can't stand still!!"
	mood_change = -2

/datum/mood_event/choke
	description = "I CAN'T BREATHE!!!"
	mood_change = -10

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

/datum/mood_event/spooked
	description = "The rattling of those bones... It still haunts me."
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/loud_gong
	description = "That loud gong noise really hurt my ears!"
	mood_change = -3
	timeout = 2 MINUTES

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

/datum/mood_event/artbad
	description = "I've produced better art than that from my ass."
	mood_change = -2
	timeout = 2 MINUTES

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

/datum/mood_event/high_five_alone
	description = "I tried getting a high-five with no one around, how embarassing!"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/high_five_full_hand
	description = "Oh god, I don't even know how to high-five correctly..."
	mood_change = -1
	timeout = 45 SECONDS

/datum/mood_event/left_hanging
	description = "But everyone loves high fives! Maybe people just... hate me?"
	mood_change = -2
	timeout = 90 SECONDS

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

//These are unused so far but I want to remember them to use them later
/datum/mood_event/surgery
	description = "THEY'RE CUTTING ME OPEN!!"
	mood_change = -8

/datum/mood_event/bald
	description = "I need something to cover my head..."
	mood_change = -3

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

/datum/mood_event/tail_regained_right
	description = "My tail is back, but that was traumatic..."
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/tail_regained_wrong
	description = "Is this some kind of sick joke?! This is NOT the right tail."
	mood_change = -12 // -8 for tail still missing + -4 bonus for being frakenstein's monster
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

/datum/mood_event/gamer_lost
	description = "If I'm not good at video games, can I truly call myself a gamer?"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/lost_52_card_pickup
	description = "This is really embarrassing! I'm ashamed to pick up all these cards off the floor..."
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/russian_roulette_lose
	description = "I gambled my life and lost! I guess this is the end..."
	mood_change = -20
	timeout = 10 MINUTES

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
