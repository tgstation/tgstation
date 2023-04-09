//Space bears!
/mob/living/simple_animal/hostile/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs.","grumbles.","grawls.")
	emote_taunt = list("stares ferociously", "stomps")
	speak_chance = 1
	taunt_chance = 25
	turns_per_move = 5
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/costume/bearpelt = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	maxHealth = 60
	health = 60
	speed = 0

	obj_damage = 60
	melee_damage_lower = 15 // i know it's like half what it used to be, but bears cause bleeding like crazy now so it works out
	melee_damage_upper = 15
	wound_bonus = -5
	bare_wound_bonus = 10 // BEAR wound bonus am i right
	sharpness = SHARP_EDGED
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	friendly_verb_continuous = "bear hugs"
	friendly_verb_simple = "bear hug"

	//Space bears aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	faction = list(FACTION_RUSSIAN)

	footstep_type = FOOTSTEP_MOB_CLAW

	var/armored = FALSE

/mob/living/simple_animal/hostile/bear/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_cell_sample()

/mob/living/simple_animal/hostile/bear/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BEAR, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/bear/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	AddElement(/datum/element/ridable, /datum/component/riding/creature/bear)
	can_buckle = TRUE
	buckle_lying = 0

/mob/living/simple_animal/hostile/bear/update_icons()
	..()
	if(armored)
		add_overlay("armor_bear")

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/hostile/bear/hudson
	name = "Hudson"
	gender = MALE
	desc = "Feared outlaw, this guy is one bad news bear." //I'm sorry...

/mob/living/simple_animal/hostile/bear/snow
	name = "space polar bear"
	icon_state = "snowbear"
	icon_living = "snowbear"
	icon_dead = "snowbear_dead"
	desc = "It's a polar bear, in space, but not actually in space."
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)

/mob/living/simple_animal/hostile/bear/russian
	name = "combat bear"
	desc = "A ferocious brown bear decked out in armor plating, a red star with yellow outlining details the shoulder plating."
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	faction = list(FACTION_RUSSIAN)
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/costume/bearpelt = 1, /obj/item/bear_armor = 1)
	melee_damage_lower = 18
	melee_damage_upper = 20
	wound_bonus = 0
	armour_penetration = 20
	health = 120
	maxHealth = 120
	armored = TRUE
	gold_core_spawnable = HOSTILE_SPAWN

/obj/item/bear_armor
	name = "pile of bear armor"
	desc = "A scattered pile of various shaped armor pieces fitted for a bear, some duct tape, and a nail filer. Crude instructions \
		are written on the back of one of the plates in russian. This seems like an awful idea."
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "bear_armor_upgrade"

/obj/item/bear_armor/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/bear) && proximity_flag)
		var/mob/living/simple_animal/hostile/bear/A = target
		if(A.armored)
			to_chat(user, span_warning("[A] has already been armored up!"))
			return
		A.armored = TRUE
		A.maxHealth += 60
		A.health += 60
		A.armour_penetration += 20
		A.melee_damage_lower += 3
		A.melee_damage_upper += 5
		A.wound_bonus += 5
		A.update_icons()
		to_chat(user, span_info("You strap the armor plating to [A] and sharpen [A.p_their()] claws with the nail filer. This was a great idea."))
		qdel(src)

/mob/living/simple_animal/hostile/bear/butter //The mighty companion to Cak. Several functions used from it.
	name = "Terrygold"
	icon_state = "butterbear"
	icon_living = "butterbear"
	icon_dead = "butterbear_dead"
	desc = "I can't believe its not a bear!"
	faction = list(FACTION_NEUTRAL, FACTION_RUSSIAN)
	obj_damage = 11
	melee_damage_lower = 0
	melee_damage_upper = 0
	sharpness = NONE //it's made of butter
	armour_penetration = 0
	response_harm_continuous = "takes a bite out of"
	response_harm_simple = "take a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	death_message = "loses its false life and collapses!"
	butcher_results = list(/obj/item/food/butter = 6, /obj/item/food/meat/slab = 3, /obj/item/organ/internal/brain = 1, /obj/item/organ/internal/heart = 1)
	attack_sound = 'sound/weapons/slap.ogg'
	attack_vis_effect = ATTACK_EFFECT_DISARM
	attack_verb_simple = "slap"
	attack_verb_continuous = "slaps"

/mob/living/simple_animal/hostile/bear/butter/add_cell_sample()
	return //You cannot grow a real bear from butter.

/mob/living/simple_animal/hostile/bear/butter/Life(delta_time = SSMOBS_DT, times_fired) //Heals butter bear really fast when he takes damage.
	if(stat)
		return
	if(health < maxHealth)
		heal_overall_damage(5 * delta_time) //Fast life regen, makes it hard for you to get eaten to death.

/mob/living/simple_animal/hostile/bear/butter/attack_hand(mob/living/user, list/modifiers) //Borrowed code from Cak, feeds people if they hit you. More nutriment but less vitamin to represent BUTTER.
	..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 1)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.1)

/mob/living/simple_animal/hostile/bear/butter/CheckParts(list/parts) //Borrowed code from Cak, allows the brain used to actually control the bear.
	..()
	var/obj/item/organ/internal/brain/candidate = locate(/obj/item/organ/internal/brain) in contents
	if(!candidate || !candidate.brainmob || !candidate.brainmob.mind)
		return
	candidate.brainmob.mind.transfer_to(src)
	to_chat(src, "[span_boldbig("You are a butter bear!")]<b> You're a mostly harmless bear/butter hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free butter to the station!</b>")
	var/default_name = "Terrygold"
	var/new_name = sanitize_name(reject_bad_text(tgui_input_text(src, "You are the [name]. Would you like to change your name to something else?", "Name change", default_name, MAX_NAME_LEN)), cap_after_symbols = FALSE)
	if(new_name)
		to_chat(src, span_notice("Your name is now <b>[new_name]</b>!"))
		name = new_name

/mob/living/simple_animal/hostile/bear/butter/AttackingTarget() //Makes the butter bear's attacks against vertical targets slip said targets
	. = ..()
	if(isliving(target)) //we don't check for . here, since attack_animal() (and thus AttackingTarget()) will return false if your damage dealt is 0
		var/mob/living/L = target
		if((L.body_position == STANDING_UP))
			L.Knockdown(20)
			playsound(loc, 'sound/misc/slip.ogg', 15)
			L.visible_message(span_danger("[L] slips on [src]'s butter!"))
