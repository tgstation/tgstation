#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/food/fishmeat/carp = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	food_type = list(/obj/item/food/meat)
	tame_chance = 10
	bonus_tame_chance = 5
	search_objects = 1
	wanted_objects = list(/obj/item/storage/cans)

	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")

	//Space carp aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	is_flying_animal = TRUE
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN
	var/random_color = TRUE //if the carp uses random coloring
	var/rarechance = 1 //chance for rare color variant
	var/snack_distance = 0

	var/static/list/carp_colors = list(\
	"lightpurple" = "#c3b9f1", \
	"lightpink" = "#da77a8", \
	"green" = "#70ff25", \
	"grape" = "#df0afb", \
	"swamp" = "#e5e75a", \
	"turquoise" = "#04e1ed", \
	"brown" = "#ca805a", \
	"teal" = "#20e28e", \
	"lightblue" = "#4d88cc", \
	"rusty" = "#dd5f34", \
	"beige" = "#bbaeaf", \
	"yellow" = "#f3ca4a", \
	"blue" = "#09bae1", \
	"palegreen" = "#7ef099", \
	)
	var/static/list/carp_colors_rare = list(\
	"silver" = "#fdfbf3", \
	)

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	add_cell_sample()
	carp_randomify(rarechance)

/mob/living/simple_animal/hostile/carp/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CARP, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/carp/proc/carp_randomify(rarechance)
	if(random_color)
		var/our_color
		if(prob(rarechance))
			our_color = pick(carp_colors_rare)
			add_atom_colour(carp_colors_rare[our_color], FIXED_COLOUR_PRIORITY)
		else
			our_color = pick(carp_colors)
			add_atom_colour(carp_colors[our_color], FIXED_COLOUR_PRIORITY)
	regenerate_icons()

/mob/living/simple_animal/hostile/carp/death(gibbed)
	. = ..()
	cut_overlays()
	if(!random_color || gibbed)
		return
	regenerate_icons()

/mob/living/simple_animal/hostile/carp/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(.)
		regenerate_icons()

/mob/living/simple_animal/hostile/carp/regenerate_icons()
	cut_overlays()
	if(!random_color)
		return
	var/mutable_appearance/base_overlay = mutable_appearance(icon, stat == DEAD ? "base_dead_mouth" : "base_mouth")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)
	..()

/mob/living/simple_animal/hostile/carp/proc/chomp_plastic()
	var/obj/item/storage/cans/tasty_plastic = locate(/obj/item/storage/cans) in view(1, src)
	if(tasty_plastic && Adjacent(tasty_plastic))
		visible_message("<span class='notice'>[src] gets its head stuck in [tasty_plastic], and gets cut breaking free from it!</span>", "<span class='notice'>You try to avoid [tasty_plastic], but it looks so... delicious... Ow! It cuts the inside of your mouth!</span>")

		new /obj/effect/decal/cleanable/plastic(loc)

		adjustBruteLoss(5)
		qdel(tasty_plastic)

/mob/living/simple_animal/hostile/carp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		chomp_plastic()

/mob/living/simple_animal/hostile/carp/tamed()
	. = ..()
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/carp)

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	maxbodytemp = INFINITY
	gold_core_spawnable = NO_SPAWN
	del_on_death = 1
	random_color = FALSE
	food_type = list()
	tame_chance = 0
	bonus_tame_chance = 0

/mob/living/simple_animal/hostile/carp/holocarp/add_cell_sample()
	return

/mob/living/simple_animal/hostile/carp/megacarp
	icon = 'icons/mob/broadMobs.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	health_doll_icon = "megacarp"
	maxHealth = 20
	health = 20
	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_color = FALSE
	food_type = list()
	tame_chance = 0
	bonus_tame_chance = 0

	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 20

	var/regen_cooldown = 0

/mob/living/simple_animal/hostile/carp/megacarp/Initialize()
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10,20)
	maxHealth += rand(30,60)
	move_to_delay = rand(3,7)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MEGACARP, CELL_VIRUS_TABLE_GENERIC_MOB)

/mob/living/simple_animal/hostile/carp/megacarp/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MEGACARP, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/carp/megacarp/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/simple_animal/hostile/carp/megacarp/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	AddElement(/datum/element/ridable, /datum/component/riding/creature/megacarp)
	can_buckle = TRUE
	buckle_lying = 0

/mob/living/simple_animal/hostile/carp/megacarp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(regen_cooldown < world.time)
		heal_overall_damage(2 * delta_time)

/mob/living/simple_animal/hostile/carp/lia
	name = "Lia"
	real_name = "Lia"
	desc = "A failed experiment of Nanotrasen to create weaponised carp technology. This less than intimidating carp now serves as the Head of Security's pet."
	gender = FEMALE
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	faction = list("neutral")
	health = 200
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	icon_living = "magicarp"
	icon_state = "magicarp"
	maxHealth = 200
	random_color = FALSE
	food_type = list()
	tame_chance = 0
	bonus_tame_chance = 0
	pet_bonus = TRUE
	pet_bonus_emote = "bloops happily!"

/mob/living/simple_animal/hostile/carp/cayenne
	name = "Cayenne"
	real_name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	gender = FEMALE
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	faction = list(ROLE_SYNDICATE)
	rarechance = 10
	food_type = list()
	tame_chance = 0
	bonus_tame_chance = 0
	pet_bonus = TRUE
	pet_bonus_emote = "bloops happily!"
	/// Keeping track of the nuke disk for the functionality of storing it.
	var/obj/item/disk/nuclear/disky

/mob/living/simple_animal/hostile/carp/cayenne/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_DISK_VERIFIER, INNATE_TRAIT) //carp can verify disky
	ADD_TRAIT(src, TRAIT_ADVANCEDTOOLUSER, INNATE_TRAIT) //carp SMART

/mob/living/simple_animal/hostile/carp/cayenne/death(gibbed)
	disky.forceMove(drop_location())
	disky = null
	return ..()

/mob/living/simple_animal/hostile/carp/cayenne/Destroy(force)
	. = ..()
	QDEL_NULL(disky)

/mob/living/simple_animal/hostile/carp/cayenne/examine(mob/user)
	. = ..()
	if(disky)
		. += "<span class='notice'>Wait... is that [disky] in [p_their()] mouth?</span>"

/mob/living/simple_animal/hostile/carp/cayenne/AttackingTarget(atom/attacked_target)
	if(istype(attacked_target, /obj/item/disk/nuclear))
		var/obj/item/disk/nuclear/potential_disky = attacked_target
		if(potential_disky.anchored)
			return
		potential_disky.forceMove(src)
		disky = potential_disky
		to_chat(src, "<span class='nicegreen'>YES!! You manage to pick up [disky]. (Click anywhere to place it back down.)</span>")
		regenerate_icons()
		if(!disky.fake)
			client.give_award(/datum/award/achievement/misc/cayenne_disk, src)
		return
	if(disky)
		if(isopenturf(attacked_target))
			to_chat(src, "<span class='notice'>You place [disky] on [attacked_target]</span>")
			disky.forceMove(attacked_target.drop_location())
			disky = null
			regenerate_icons()
		else
			disky.melee_attack_chain(src, attacked_target)
		return
	return ..()

/mob/living/simple_animal/hostile/carp/cayenne/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if(AM == disky)
		disky = null
		regenerate_icons()

/mob/living/simple_animal/hostile/carp/cayenne/regenerate_icons()
	. = ..()
	if(!disky || stat == DEAD)
		return
	cut_overlays()
	add_overlay("disk_mouth")
	var/mutable_appearance/disk_overlay = mutable_appearance(icon, "disk_overlay")
	disk_overlay.appearance_flags = RESET_COLOR
	add_overlay(disk_overlay)

#undef REGENERATION_DELAY
