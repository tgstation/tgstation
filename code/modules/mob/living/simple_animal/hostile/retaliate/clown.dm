/mob/living/simple_animal/hostile/retaliate/clown
	name = "Clown"
	desc = "A denizen of clown planet."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	health_doll_icon = "clown" //if >32x32, it will use this generic. for all the huge clown mobs that subtype from this
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	turns_per_move = 5
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "robusts"
	response_harm_simple = "robust"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
	emote_see = list("honks", "squeaks")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 75
	health = 75
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = 1
	loot = list(/obj/effect/mob_spawn/human/clown/corpse)

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = 370
	unsuitable_atmos_damage = 10
	unsuitable_heat_damage = 15
	footstep_type = FOOTSTEP_MOB_SHOE
	var/banana_time = 0 // If there's no time set it won't spawn.
	var/banana_type = /obj/item/grown/bananapeel
	var/attack_reagent

/mob/living/simple_animal/hostile/retaliate/clown/attack_hand(mob/living/carbon/human/user, list/modifiers)
	..()
	playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE)

/mob/living/simple_animal/hostile/retaliate/clown/Life()
	. = ..()
	if(banana_time && banana_time < world.time)
		var/turf/T = get_turf(src)
		var/list/adjacent =  T.GetAtmosAdjacentTurfs(1)
		new banana_type(pick(adjacent))
		banana_time = world.time + rand(30,60)

/mob/living/simple_animal/hostile/retaliate/clown/AttackingTarget()
	. = ..()
	if(attack_reagent && . && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(attack_reagent, rand(1,5))

/mob/living/simple_animal/hostile/retaliate/clown/lube
	name = "Living Lube"
	desc = "A puddle of lube brought to life by the honkmother."
	icon_state = "lube"
	icon_living = "lube"
	turns_per_move = 1
	response_help_continuous = "dips a finger into"
	response_help_simple = "dip a finger into"
	response_disarm_continuous = "gently scoops and pours aside"
	response_disarm_simple = "gently scoop and pour aside"
	emote_see = list("bubbles", "oozes")
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/particle_effect/foam)

/mob/living/simple_animal/hostile/retaliate/clown/lube/Initialize()
	. = ..()
	AddElement(/datum/element/snailcrawl)

/mob/living/simple_animal/hostile/retaliate/clown/banana
	name = "Clownana"
	desc = "A fusion of clown and banana DNA birthed from a botany experiment gone wrong."
	icon_state = "banana tree"
	icon_living = "banana tree"
	response_disarm_continuous = "peels"
	response_disarm_simple = "peel"
	response_harm_continuous = "peels"
	response_harm_simple = "peel"
	turns_per_move = 1
	speak = list("HONK", "Honk!", "YA-HONK!!!")
	emote_see = list("honks", "bites into the banana", "plucks a banana off its head", "photosynthesizes")
	maxHealth = 120
	health = 120
	speed = -10
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap, /obj/item/seeds/banana)
	banana_time = 20

/mob/living/simple_animal/hostile/retaliate/clown/honkling
	name = "Honkling"
	desc = "A divine being sent by the Honkmother to spread joy. It's not dangerous, but it's a bit of a nuisance."
	icon_state = "honkling"
	icon_living = "honkling"
	turns_per_move = 1
	speed = -10
	harm_intent_damage = 1
	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_verb_continuous = "cheers up"
	attack_verb_simple = "cheer up"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap, /obj/item/seeds/banana/bluespace)
	banana_type = /obj/item/grown/bananapeel
	attack_reagent = /datum/reagent/consumable/laughter

/mob/living/simple_animal/hostile/retaliate/clown/fleshclown
	name = "Fleshclown"
	desc = "A being forged out of the pure essence of pranking, cursed into existence by a cruel maker."
	icon_state = "fleshclown"
	icon_living = "fleshclown"
	response_help_continuous = "reluctantly pokes"
	response_help_simple = "reluctantly poke"
	response_disarm_continuous = "sinks his hands into the spongy flesh of"
	response_disarm_simple = "sink your hands into the spongy flesh of"
	response_harm_continuous = "cleanses the world of"
	response_harm_simple = "cleanse the world of"
	speak = list("HONK", "Honk!", "I didn't ask for this", "I feel constant and horrible pain", "YA-HONK!!!", "this body is a merciless and unforgiving prison", "I was born out of mirthful pranking but I live in suffering")
	emote_see = list("honks", "sweats", "jiggles", "contemplates its existence")
	speak_chance = 5
	dextrous = TRUE
	maxHealth = 140
	health = 140
	speed = -5
	melee_damage_upper = 15
	attack_verb_continuous = "limply slaps"
	attack_verb_simple = "limply slap"
	obj_damage = 5
	loot = list(/obj/item/clothing/suit/hooded/bloated_human, /obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/fleshclown/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/retaliate/clown/longface
	name = "Longface"
	desc = "Often found walking into the bar."
	icon_state = "long face"
	icon_living = "long face"
	move_resist = INFINITY
	turns_per_move = 10
	response_help_continuous = "tries to awkwardly hug"
	response_help_simple = "try to awkwardly hug"
	response_disarm_continuous = "pushes the unwieldy frame of"
	response_disarm_simple = "push the unwieldy frame of"
	response_harm_continuous = "tries to shut up"
	response_harm_simple = "try to shut up"
	speak = list("YA-HONK!!!")
	emote_see = list("honks", "squeaks")
	speak_chance = 60
	maxHealth = 150
	health = 150
	pixel_x = -16
	base_pixel_x = -16
	speed = 10
	harm_intent_damage = 5
	melee_damage_lower = 5
	attack_verb_continuous = "YA-HONKs"
	attack_verb_simple = "YA-HONK"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk
	name = "Honk Hulk"
	desc = "A cruel and fearsome clown. Don't make him angry."
	icon_state = "honkhulk"
	icon_living = "honkhulk"
	move_resist = INFINITY
	response_help_continuous = "tries desperately to appease"
	response_help_simple = "try desperately to appease"
	response_disarm_continuous = "foolishly pushes"
	response_disarm_simple = "foolishly push"
	response_harm_continuous = "angers"
	response_harm_simple = "anger"
	speak = list("HONK", "Honk!", "HAUAUANK!!!", "GUUURRRRAAAHHH!!!")
	emote_see = list("honks", "sweats", "grunts")
	speak_chance = 5
	maxHealth = 400
	health = 400
	pixel_x = -16
	base_pixel_x = -16
	speed = 2
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 20
	attack_verb_continuous = "pummels"
	attack_verb_simple = "pummel"
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown
	name = "Chlown"
	desc = "A real lunkhead who somehow gets all the girls."
	icon_state = "chlown"
	icon_living = "chlown"
	response_help_continuous = "submits to"
	response_help_simple = "submit to"
	response_disarm_continuous = "tries to assert dominance over"
	response_disarm_simple = "try to assert dominance over"
	response_harm_continuous = "makes a weak beta attack at"
	response_harm_simple = "make a weak beta attack at"
	speak = list("HONK", "Honk!", "Bruh", "cheeaaaahhh?")
	emote_see = list("asserts his dominance", "emasculates everyone implicitly")
	maxHealth = 500
	health = 500
	speed = -2
	armour_penetration = 20
	attack_verb_continuous = "steals the girlfriend of"
	attack_verb_simple = "steal the girlfriend of"
	attack_sound = 'sound/items/airhorn2.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus
	name = "Honkmunculus"
	desc = "A slender wiry figure of alchemical origin."
	icon_state = "honkmunculus"
	icon_living = "honkmunculus"
	response_help_continuous = "skeptically pokes"
	response_help_simple = "skeptically poke"
	response_disarm_continuous = "pushes the unwieldy frame of"
	response_disarm_simple = "push the unwieldy frame of"
	speak = list("honk")
	emote_see = list("squirms", "writhes")
	speak_chance = 1
	maxHealth = 200
	health = 200
	speed = -5
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attack_verb_continuous = "ferociously mauls"
	attack_verb_simple = "ferociously maul"
	environment_smash = ENVIRONMENT_SMASH_NONE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap)
	attack_reagent = /datum/reagent/peaceborg/confuse

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/destroyer
	name = "The Destroyer"
	desc = "An ancient being born of arcane honking."
	icon_state = "destroyer"
	icon_living = "destroyer"
	response_disarm_continuous = "bounces off of"
	response_harm_continuous = "bounces off of"
	speak = list("HONK!!!", "The Honkmother is merciful, so I must act out her wrath.", "parce mihi ad beatus honkmother placet mihi ut peccata committere,", "DIE!!!")
	maxHealth = 400
	health = 400
	speed = 5
	harm_intent_damage = 30
	melee_damage_lower = 20
	melee_damage_upper = 40
	armour_penetration = 30
	stat_attack = HARD_CRIT
	attack_verb_continuous = "acts out divine vengeance on"
	attack_verb_simple = "act out divine vengeance on"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/mutant
	name = "Unknown"
	desc = "Kill it for its own sake."
	icon_state = "mutant"
	icon_living = "mutant"
	move_resist = INFINITY
	turns_per_move = 10
	response_help_continuous = "reluctantly sinks a finger into"
	response_help_simple = "reluctantly sink a finger into"
	response_disarm_continuous = "squishes into"
	response_disarm_simple = "squish into"
	response_harm_continuous = "squishes into"
	response_harm_simple = "squish into"
	speak = list("aaaaaahhhhuuhhhuhhhaaaaa", "AAAaaauuuaaAAAaauuhhh", "huuuuuh... hhhhuuuooooonnnnkk", "HuaUAAAnKKKK")
	emote_see = list("squirms", "writhes", "pulsates", "froths", "oozes")
	speak_chance = 10
	maxHealth = 130
	health = 130
	pixel_x = -16
	base_pixel_x = -16
	speed = -5
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_verb_continuous = "awkwardly flails at"
	attack_verb_simple = "awkwardly flail at"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/slow
	speed = 20
	move_to_delay = 60

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton
	name = "banana glutton"
	desc = "Something that was once a clown"
	icon_state = "glutton"
	icon_living = "glutton"
	speak = list("hey, buddy", "HONK!!!", "H-h-h-H-HOOOOONK!!!!", "HONKHONKHONK!!!", "HEY, BUCKO, GET BACK HERE!!!", "HOOOOOOOONK!!!")
	emote_see = list("jiggles", "wobbles")
	health = 200
	mob_size = MOB_SIZE_LARGE
	speed = 1
	melee_damage_lower = 10
	melee_damage_upper = 15
	force_threshold = 10 //lots of fat to cushion blows.
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 2, STAMINA = 0, OXY = 1)
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	loot = list(/obj/effect/gibspawner/xeno/bodypartless, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless)
	deathsound = 'sound/misc/sadtrombone.ogg'
	food_type = list(/obj/item/food/cheesiehonkers, /obj/item/food/cornchips)
	tame_chance = 30
	///This is the list of items we are ready to regurgitate,
	var/list/prank_pouch = list()
	///This ability lets you fire a single random item from your pouch.
	var/obj/effect/proc_holder/regurgitate/my_regurgitate

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/Initialize()
	. = ..()
	my_regurgitate = new
	AddAbility(my_regurgitate)
	add_cell_sample()

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/attacked_by(obj/item/I, mob/living/user)
	if(!check_edible(I))
		return ..()
	eat_atom(I)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/AttackingTarget(atom/attacked_target)
	if(!check_edible(attacked_target))
		return ..()
	eat_atom(attacked_target)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!check_edible(A))
		return ..()
	eat_atom(A)

///Returns whether or not the supplied movable atom is edible.
/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/proc/check_edible(atom/movable/potential_food)
	if(isliving(potential_food))
		var/mob/living/living_morsel = potential_food
		if(living_morsel.mob_size > MOB_SIZE_SMALL)
			return FALSE
		else
			return TRUE

	if(IS_EDIBLE(potential_food))
		if(prank_pouch.len >= 8)
			to_chat(src, "<span class='warning'>Your prank pouch is filled to the brim! You don't think you can swallow any more morsels right now.</span>")
			return FALSE
		return TRUE

///This proc eats the atom, certain funny items are stored directly in the prank pouch while bananas grant a heal based on their potency and the peels are retained in the pouch.
/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/proc/eat_atom(atom/movable/eaten_atom)

	var/static/funny_items = list(/obj/item/food/pie/cream,
								/obj/item/food/grown/tomato,
								/obj/item/food/meatclown)

	visible_message("<span class='warning>[src] eats [eaten_atom]!</span>", "<span class='notice'>You eat [eaten_atom].</span>")
	if(is_type_in_list(eaten_atom, funny_items))
		eaten_atom.forceMove(src)
		prank_pouch += eaten_atom

	else if(istype(eaten_atom, /obj/item/food/grown/banana))
		var/obj/item/food/grown/banana/banana_morsel = eaten_atom
		adjustBruteLoss(-banana_morsel.seed.potency * 0.25)
		prank_pouch += banana_morsel.generate_trash(src)
		qdel(eaten_atom)
	else
		qdel(eaten_atom)
	playsound(loc,'sound/items/eatfood.ogg', rand(30,50), TRUE)
	flick("glutton_mouth", src)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/tamed()
	. = ..()
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/glutton)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_GLUTTON, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	prank_pouch -= AM

///This ability will let you fire one random item from your pouch,
/obj/effect/proc_holder/regurgitate
	name = "Regurgitate"
	desc = "Regurgitates a single item from the depths of your pouch."
	action_background_icon_state = "bg_changeling"
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "regurgitate"
	active = FALSE

/obj/effect/proc_holder/regurgitate/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	fire(user)

/obj/effect/proc_holder/regurgitate/fire(mob/living/carbon/user)
	if(active)
		user.icon_state = initial(user.icon_state)
		remove_ranged_ability("<span class='notice'>Your throat muscles relax.</span>")
	else
		user.icon_state = "glutton_tongue"
		add_ranged_ability(user, "<span class='notice'>Your throat muscles tense up. <B>Left-click to regurgitate a funny morsel!</B></span>", TRUE)

/obj/effect/proc_holder/regurgitate/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()

	if(.)
		return

	if(!istype(ranged_ability_user, /mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton) || ranged_ability_user.stat)
		remove_ranged_ability()
		return

	var/mob/living/simple_animal/hostile/retaliate/clown/mutant/glutton/pouch_owner = ranged_ability_user
	if(!pouch_owner.prank_pouch.len)
		//active = FALSE
		pouch_owner.icon_state = "glutton"
		remove_ranged_ability("<span class='notice'>Your prank pouch is empty,.</span>")
		return

	var/obj/item/projected_morsel = pick(pouch_owner.prank_pouch)
	projected_morsel.forceMove(pouch_owner.loc)
	projected_morsel.throw_at(target, 8, 2, pouch_owner)
	flick("glutton_mouth", pouch_owner)
	playsound(pouch_owner, 'sound/misc/soggy.ogg', 75)


