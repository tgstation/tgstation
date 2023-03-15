//Honk armor
/obj/item/clothing/suit/armor/reactive/honk
	name = "reactive honk armor"
	desc = "An experimental suit of armor that honks violently."
	reactivearmor_cooldown_duration = 10 SECONDS

/obj/item/clothing/suit/armor/reactive/honk/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The horn is still recharging!</span>")
			return FALSE
		playsound(get_turf(owner),'sound/items/airhorn.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] honks, converting the attack into a violent honk!</span>")
		var/turf/owner_turf = get_turf(owner)
		owner.Paralyze(3 SECONDS)
		for(var/mob/living/carbon/target_atom as mob in ohearers(7, owner_turf))
			target_atom.Paralyze(6 SECONDS)


		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE


/obj/item/clothing/suit/armor/reactive/honk/emp_act()
	if(active)
		active = FALSE
		playsound(get_turf(src),'sound/items/airhorn.ogg', 100, 1)
		src.visible_message("<span class='danger'>[src] malfunctions, and honks extra hard!</span>")
		for(var/mob/living/carbon/target_atom as mob in hearers(7, get_turf(src))) //Includes the person wearing it
			target_atom.Paralyze(rand(5 SECONDS,20 SECONDS)) //Honk! :)
	return

//Mutation Armour
/obj/item/clothing/suit/armor/reactive/mutation
	name = "reactive mutation armor"
	desc = "An experimental suit of armor that gives off radioactive waves."
	var/list/possible_mutations = list()
	reactivearmor_cooldown_duration = 30 SECONDS

/obj/item/clothing/suit/armor/reactive/mutation/Initialize(mapload)
	. = ..()
	possible_mutations = GLOB.all_mutations
	//These ones either don't let you unmutate, or are species specific
	possible_mutations -= list(RACEMUT,CLUWNEMUT,MUTATE,ACIDOOZE,FIREBREATH,OVERLOAD)

/obj/item/clothing/suit/armor/reactive/mutation/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The armour is still recharging!</span>")
			return FALSE
		playsound(get_turf(owner),'sound/effects/empulse.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out mutating waves of radiation!</span>")
		var/turf/owner_turf = get_turf(owner)

		for(var/mob/living/carbon/human/target_atom as mob in oviewers(7, owner_turf))
			if(!istype(target_atom))
				continue
			if(target_atom.dna && !HAS_TRAIT(target_atom, TRAIT_RADIMMUNE))
				give_rand_mut(target_atom)
				target_atom.rad_act(40)

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE

/obj/item/clothing/suit/armor/reactive/mutation/proc/remove_mutation(var/mob/living/carbon/mutation_holder, var/datum/mutation/selected_mutation)
	mutation_holder.dna.remove_mutation(selected_mutation)

/obj/item/clothing/suit/armor/reactive/mutation/proc/give_rand_mut(var/mob/living/carbon/recipient)
	var/datum/mutation/chosen_mutation = pick(possible_mutations)
	recipient.dna.add_mutation(chosen_mutation)
	addtimer(CALLBACK(src, .proc/remove_mutation, recipient, chosen_mutation), 60 SECONDS)

/obj/item/clothing/suit/armor/reactive/mutation/emp_act()
	if(active)
		active = FALSE
		reactivearmor_cooldown = world.time + 100 SECONDS
		src.visible_message("<span class='danger'>[src] malfunctions, and emits an extra strong wave!</span>")
		playsound(get_turf(src),'sound/effects/empulse.ogg', 100, 1)
		for(var/mob/living/carbon/human/target_atom as mob in viewers(7, get_turf(src))) //Includes the wearer
			if(!istype(target_atom))
				continue
			if(target_atom.dna && !HAS_TRAIT(target_atom, TRAIT_RADIMMUNE))
				give_rand_mut(target_atom) //More mutations more Funny
				give_rand_mut(target_atom)
				give_rand_mut(target_atom)
				target_atom.rad_act(200)
	return

//Walter Armour
/obj/item/clothing/suit/armor/reactive/walter
	name = "reactive walter armor"
	desc = "An experimental suit of armor that gives off walter-ish vibes."
	hit_reaction_chance = 10 //Less Walter Spam

/obj/item/clothing/suit/armor/reactive/walter/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The Walter fabricator is still recharging!</span>")
			return FALSE
		playsound(get_turf(owner),'sound/magic/summonitems_generic.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text] with a Walter appearing out of thin air!</span>")
		var/turf/owner_turf = get_turf(owner)
		new /mob/living/simple_animal/pet/dog/bullterrier/walter(owner_turf) //Walter

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE

/obj/item/clothing/suit/armor/reactive/walter/emp_act()
	src.visible_message("<span class='danger'>[src] malfunctions, and walter appears!</span>")
	if(prob(50)) //50% chance for either a big walter are a few little walters
		var/mob/living/summoned_walter = new /mob/living/simple_animal/pet/dog/bullterrier/walter(get_turf(src))
		summoned_walter.resize = 3
		summoned_walter.update_transform()
	else
		for(var/i in 1 to rand(3,5))
			new /mob/living/simple_animal/pet/dog/bullterrier/walter/smallter(get_turf(src))
	return

#define BASE_FREEZING_POWER 50
#define FREEZING_POWER_DROPOFF 5
#define MIN_EMP_FREEZING_POWER 1
#define MAX_EMP_FREEZING_POWER 100

//Frost Armour
/obj/item/clothing/suit/armor/reactive/glacial
	name = "reactive glacial armor"
	desc = "An experimental suit of armor that chills the air around it."

/obj/item/clothing/suit/armor/reactive/glacial/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The walter fabricator is still recharging!</span>")
			return FALSE
		playsound(get_turf(src),'sound/effects/empulse.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], sending out an icy blast!</span>")
		var/turf/owner_turf = get_turf(owner)
		for(var/mob/living/carbon/target_atom as mob in oviewers(7, owner_turf))
			var/freezing_power = BASE_FREEZING_POWER
			freezing_power -= (FREEZING_POWER_DROPOFF*get_dist(owner_turf,target_atom))
			target_atom.adjust_bodytemperature(-freezing_power) //freezes less from further away

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE

/obj/item/clothing/suit/armor/reactive/glacial/emp_act()
	for(var/mob/living/carbon/target_atom as mob in viewers(7, get_turf(src)))
		var/freezing_power = rand(MIN_EMP_FREEZING_POWER,MAX_EMP_FREEZING_POWER) //:) I love EMPS :)
		switch(freezing_power)
			if(1 to 30)
				src.visible_message("<span class='danger'>[src] malfunctions, letting out an cold breeze.</span>")
			if(31 to 60)
				src.visible_message("<span class='danger'>[src] malfunctions, chilling the air around it.</span>")
			else
				src.visible_message("<span class='danger'>[src] malfunctions, forming ice in the air around you.</span>")
		freezing_power -= (FREEZING_POWER_DROPOFF*get_dist(get_turf(src),target_atom))
		target_atom.adjust_bodytemperature(-freezing_power)
	return

#undef BASE_FREEZING_POWER
#undef FREEZING_POWER_DROPOFF
#undef MIN_EMP_FREEZING_POWER
#undef MAX_EMP_FREEZING_POWER

//Monkey Armour
/obj/item/clothing/suit/armor/reactive/primal
	name = "reactive primal armor"
	desc = "An experimental suit of armor that echoes the screeches of past monkeys."
	reactivearmor_cooldown_duration = 3 MINUTES //Big Cooldown
	hit_reaction_chance = 10 //Low monkey chance

/obj/item/clothing/suit/armor/reactive/primal/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The monkey generator is still recharging!</span>")
			return FALSE
		playsound(get_turf(src),'sound/creatures/monkey/monkey_screech_1.ogg', 100, 1, mixer_channel = CHANNEL_MOB_SOUNDS)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], and screeches with the voices of a million monkeys!</span>")
		return_to_monkey(owner)

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE

/obj/item/clothing/suit/armor/reactive/primal/proc/return_to_monkey(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/simple_animal/hostile/gorilla/new_gorilla = new(get_turf(user))
	user.forceMove(new_gorilla)
	user.mind.transfer_to(new_gorilla)
	ADD_TRAIT(user, TRAIT_NOBREATH, type) //so they dont suffocate while inside the gorilla
	addtimer(CALLBACK(src, .proc/become_human, new_gorilla), 10 SECONDS) //10 seconds should be enough time to realize you are monkey and fuck someone up without being able to pwn a whole group

/obj/item/clothing/suit/armor/reactive/primal/proc/become_human(mob/living/affected_mob)
	var/mob/living/carbon/human/human_mob = locate() in affected_mob
	affected_mob.mind.transfer_to(human_mob)
	human_mob.grab_ghost()
	human_mob.forceMove(get_turf(affected_mob))
	REMOVE_TRAIT(human_mob, TRAIT_NOBREATH, type)
	qdel(affected_mob)

//Petsplosion Armour
/obj/item/clothing/suit/armor/reactive/herd
	name = "reactive herd armor"
	desc = "An experimental suit of armor that creates groups of animals."
	var/list/current_herd = list()
	var/list/pet_type_cache = list()
	reactivearmor_cooldown_duration = 90 SECONDS

/obj/item/clothing/suit/armor/reactive/herd/Initialize(mapload, new_lifespan)
	. = ..()
	//Copied from the petsplosion anomaly since it's already figured out
	pet_type_cache = subtypesof(/mob/living/simple_animal/pet)
	pet_type_cache -= list(/mob/living/simple_animal/pet/penguin,
		/mob/living/simple_animal/pet/dog/corgi/narsie,
		/mob/living/simple_animal/pet/gondola/gondolapod,
		/mob/living/simple_animal/pet/gondola,
		/mob/living/simple_animal/pet/dog)

	pet_type_cache += list(/mob/living/simple_animal/cow,
		/mob/living/simple_animal/sloth,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/cockroach,
		/mob/living/simple_animal/crab)

/obj/item/clothing/suit/armor/reactive/herd/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The animal generator is still recharging!</span>")
			return FALSE
		playsound(get_turf(src),'sound/effects/empulse.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], and summons a herd of animals!</span>")
		var/turf/owner_turf = get_turf(owner)
		become_animal(owner)
		for(var/i in 1 to rand(7,10)) //Summon the disguise herd
			var/mob/living/simple_animal/new_animal = pick(pet_type_cache)
			new_animal = new new_animal(owner_turf)
			//About 60 hp if they have base simplemob hp
			new_animal.maxHealth += 40
			new_animal.health += 40
			current_herd += new_animal

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE

/obj/item/clothing/suit/armor/reactive/herd/proc/become_animal(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/simple_animal/chosen_animal = pick(pet_type_cache)
	chosen_animal = new chosen_animal(get_turf(user))
	user.forceMove(chosen_animal)
	user.mind.transfer_to(chosen_animal)
	ADD_TRAIT(user, TRAIT_NOBREATH, type) //so they dont suffocate while inside the animal
	addtimer(CALLBACK(src, .proc/end_herd, chosen_animal), 30 SECONDS)

/obj/item/clothing/suit/armor/reactive/herd/proc/end_herd(mob/living/affected_mob)
	var/mob/living/carbon/human/human_mob = locate() in affected_mob
	affected_mob.mind.transfer_to(human_mob)
	human_mob.grab_ghost()
	human_mob.forceMove(get_turf(affected_mob))
	REMOVE_TRAIT(human_mob, TRAIT_NOBREATH, type)
	qdel(affected_mob)

	for(var/mob/living/herd_animal in current_herd)
		current_herd -= herd_animal
		qdel(herd_animal)

//Fluidic Armour
/obj/item/clothing/suit/armor/reactive/wet
	name = "reactive wet armor"
	desc = "An experimental suit of armor that's a little more damp than usual."
	reactivearmor_cooldown_duration = 30 SECONDS

/obj/item/clothing/suit/armor/reactive/wet/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The liquid generator is still recharging!</span>")
			return FALSE
		playsound(get_turf(src),'sound/effects/empulse.ogg', 100, 1)
		owner.visible_message("<span class='danger'>[src] blocks [attack_text], and drips a ton of liquid!</span>")
		var/turf/owner_turf = get_turf(owner)
		owner_turf.add_liquid(get_random_reagent_id(), rand(50,100))

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE
