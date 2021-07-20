/datum/antagonist/protagonist/scaredy_prince
	name = "Scaredy royalty"
	outfit_type = /datum/outfit/royal_prince
	max_age = 25
	var/family_name

/datum/antagonist/protagonist/scaredy_prince/New()
	. = ..()
	family_name = pick(GLOB.medieval_family_names)

/datum/antagonist/protagonist/scaredy_prince/on_gain()
	. = ..()
	var/mob/living/carbon/human/royalty_human = owner.current

	royalty_human.dna.add_mutation(LIGHT_MEDIEVAL, MUT_OTHER)
	royalty_human.dna.add_mutation(GOOD_LOOKING, MUT_OTHER)
	royalty_human.add_quirk(/datum/quirk/badback)
	ADD_TRAIT(royalty_human, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION) //Thick fingers is probably a weird way to explain it but I don't want to add a new trait. They are a feudal nerd that doesn't use guns. f
	royalty_human.gain_trauma(new /datum/brain_trauma/mild/phobia/supernatural(), TRAUMA_RESILIENCE_ABSOLUTE) //The gods are out for me!


	addtimer(CALLBACK(src, .proc/announce_arrival), 10 SECONDS)

/datum/antagonist/protagonist/scaredy_prince/equip_protagonist()
	. = ..()
	var/new_name = "[owner.current.first_name()] [family_name]"
	owner.current.fully_replace_character_name(owner.current.real_name, new_name)

/datum/antagonist/protagonist/scaredy_prince/greet()
	. = ..()
	to_chat(owner.current, span_greenannounce("You are a royal member of house [family_name]. Do your house proud in a honorable visit to the station! Make sure to be courteous to the crew of the station to strengthen your family's ties with them, but be wary of traitorous cretins looking to kill you! Be sure to act like medieval royalty would."))
	owner.announce_objectives()

/datum/antagonist/protagonist/scaredy_prince/proc/announce_arrival()
	. = ..()
	minor_announce("Central Command has assigned your station a visit from nobility ruling a local medieval world. Make sure they are treated well and protected, as they are an important asset to Nanotrasen's future developments.", "Royal visit!")
	SEND_SOUND(world, sound('sound/ambience/protag/royal_decree.ogg', volume = 50))
