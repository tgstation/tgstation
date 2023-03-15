/datum/antagonist/living_lube
	name = "Ghost of Honks Past"
	roundend_category = "Ghosts of Honks Past"
	antagpanel_category = "Ghost of Honks Past"
	silent = TRUE
	give_objectives = FALSE
	show_to_ghosts = TRUE

/datum/antagonist/living_lube/on_gain()
	var/datum/objective/annoy_objective = new /datum/objective
	annoy_objective.owner = owner
	annoy_objective = "Annoy the station as much as possible."
	objectives += annoy_objective
	if(isliving(owner.current))
		var/mob/living/simple_animal/hostile/retaliate/clown/lube/lube = owner.current

		lube.maxHealth = 400 //What a god
		lube.health = 400
		lube.melee_damage = 0 //You can't kill people!
		lube.obj_damage = 0
		lube.unsuitable_atmos_damage = 0 //Space won't get this little lube
		lube.minbodytemp = TCMB
		lube.maxbodytemp = T0C + 40
		lube.alpha = 155 //It is a ghost after all
		//Abilities & Traits added here
		var/obj/effect/proc_holder/spell/aoe_turf/knock/living_lube/knock = new
		var/obj/effect/proc_holder/spell/aimed/banana_peel/living_lube/banana_peel = new
		var/obj/effect/proc_holder/spell/voice_of_god/clown/living_lube/voice_of_lube = new
		var/obj/effect/proc_holder/spell/targeted/smoke/living_lube/smoke = new
		var/obj/effect/proc_holder/spell/targeted/displacement/displacement = new
		lube.mind.AddSpell(knock)
		lube.mind.AddSpell(banana_peel)
		lube.mind.AddSpell(voice_of_lube)
		lube.mind.AddSpell(smoke)
		lube.mind.AddSpell(displacement)
	. = ..()

/datum/antagonist/living_lube/greet()
	var/mob/living/carbon/lube = owner.current

	owner.current.playsound_local(get_turf(owner.current), 'sound/items/bikehorn.ogg',100,0, use_reverb = FALSE)
	to_chat(owner, "<span class='boldannounce'>You are the Living Lube!\nYou are an agent of chaos. Annoy the station as much as possible\n\nYou don't want to hurt anyone, but you must be as much of an annoyance as possible.\n\nHonk!</span>")
	owner.announce_objectives()
	lube.name = prob(99) ? "Ghost of Honks Past" : "Ghost of Pee Pee Peter" //like from that one time!

