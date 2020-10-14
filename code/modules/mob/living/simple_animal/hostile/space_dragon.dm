/// The carp rift is currently charging.
#define CHARGE_ONGOING			0
/// The carp rift is currently charging and has output a final warning.
#define CHARGE_FINALWARNING		1
/// The carp rift is now fully charged.
#define CHARGE_COMPLETED		2
/// The darkness threshold for space dragon when choosing a color
#define DARKNESS_THRESHOLD		0.5

/**
  * # Space Dragon
  *
  * A space-faring leviathan-esque monster which breathes fire and summons carp.  Spawned during its respective midround antagonist event.
  *
  * A space-faring monstrosity who has the ability to breathe dangerous fire breath and uses its powerful wings to knock foes away.
  * Normally spawned as an antagonist during the Space Dragon event, Space Dragon's main goal is to open three rifts from which to pull a great tide of carp onto the station.
  * Space Dragon can summon only one rift at a time, and can do so anywhere a blob is allowed to spawn.  In order to trigger his victory condition, Space Dragon must summon and defend three rifts while they charge.
  * Space Dragon, when spawned, has five minutes to summon the first rift.  Failing to do so will cause Space Dragon to return from whence he came.
  * When the rift spawns, ghosts can interact with it to spawn in as space carp to help complete the mission.  One carp is granted when the rift is first summoned, with an extra one every 40 seconds.
  * Once the victory condition is met, the shuttle is called and all current rifts are allowed to spawn infinite sentient space carp.
  * If a charging rift is destroyed, Space Dragon will be incredibly slowed, and the endlag on his gust attack is greatly increased on each use.
  * Space Dragon has the following abilities to assist him with his objective:
  * - Can shoot fire in straight line, dealing 30 burn damage and setting those suseptible on fire.
  * - Can use his wings to temporarily stun and knock back any nearby mobs.  This attack has no cooldown, but instead has endlag after the attack where Space Dragon cannot act.  This endlag's time decreases over time, but is added to every time he uses the move.
  * - Can swallow mob corpses to heal for half their max health.  Any corpses swallowed are stored within him, and will be regurgitated on death.
  * - Can tear through any type of wall.  This takes 4 seconds for most walls, and 12 seconds for reinforced walls.
  */
/mob/living/simple_animal/hostile/space_dragon
	name = "Space Dragon"
	desc = "A vile, leviathan-esque creature that flies in the most unnatural way.  Looks slightly similar to a space carp."
	maxHealth = 400
	health = 400
	a_intent = INTENT_HARM
	speed = 0
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	icon = 'icons/mob/spacedragon.dmi'
	icon_state = "spacedragon"
	icon_living = "spacedragon"
	icon_dead = "spacedragon_dead"
	health_doll_icon = "spacedragon"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_NONE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1 | HEAR_1
	melee_damage_upper = 35
	melee_damage_lower = 35
	mob_size = MOB_SIZE_LARGE
	armour_penetration = 30
	pixel_x = -16
	turns_per_move = 5
	ranged = TRUE
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	deathmessage = "screeches as its wings turn to dust and it collapses on the floor, its life extinguished."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("carp")
	pressure_resistance = 200
	/// Current time since the the last rift was activated.  If set to -1, does not increment.
	var/riftTimer = 0
	/// Maximum amount of time which can pass without a rift before Space Dragon despawns.
	var/maxRiftTimer = 300
	/// How much endlag using Wing Gust should apply.  Each use of wing gust increments this, and it decreases over time.
	var/tiredness = 0
	/// A multiplier to how much each use of wing gust should add to the tiredness variable.  Set to 5 if the current rift is destroyed.
	var/tiredness_mult = 1
	/// Determines whether or not Space Dragon is in the middle of using wing guat.  If set to true, prevents him from moving and doing certain actions.
	var/using_special = FALSE
	/// A list of all of the rifts created by Space Dragon.  Used for setting them all to infinite carp spawn when Space Dragon wins, and removing them when Space Dragon dies.
	var/list/obj/structure/carp_rift/rift_list = list()
	/// How many rifts have been successfully charged
	var/rifts_charged = 0
	/// Whether or not Space Dragon has completed their objective, and thus triggered the ending sequence.
	var/objective_complete = FALSE
	/// The togglable small sprite action
	var/small_sprite_type = /datum/action/small_sprite/megafauna/spacedragon
	/// The color of the space dragon.
	var/chosen_color

/mob/living/simple_animal/hostile/space_dragon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	if(small_sprite_type)
		var/datum/action/small_sprite/small_action = new small_sprite_type()
		small_action.Grant(src)

/mob/living/simple_animal/hostile/space_dragon/Login()
	. = ..()
	if(!chosen_color)
		dragon_name()
		color_selection()

/mob/living/simple_animal/hostile/space_dragon/Move()
	if(!using_special)
		..()

/mob/living/simple_animal/hostile/space_dragon/death(gibbed)
	empty_contents()
	add_overlay()
	..()

/**
  * Allows space dragon to choose its own name.
  *
  * Prompts the space dragon to choose a name, which it will then apply to itself.
  * If the name is invalid, will re-prompt the dragon until a proper name is chosen.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/dragon_name()
	var/chosen_name = sanitize_name(reject_bad_text(stripped_input(src, "What would you like your name to be?", "Choose Your Name", real_name, MAX_NAME_LEN)))
	if(!chosen_name)
		to_chat(src, "<span class='warning'>Not a valid name, please try again.</span>")
		dragon_name()
		return
	visible_message("<span class='notice'>Your name is now <span class='name'>[chosen_name]</span>, the feared Space Dragon.</span>")
	fully_replace_character_name(null, chosen_name)

/**
  * Allows space dragon to choose a color for itself.
  *
  * Prompts the space dragon to choose a color, from which it will then apply to itself.
  * If an invalid color is given, will re-prompt the dragon until a proper color is chosen.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/color_selection()
	chosen_color = input(src,"What would you like your color to be?","Choose Your Color", COLOR_WHITE) as color|null
	if(!chosen_color) //redo proc until we get a color
		to_chat(src, "<span class='warning'>Not a valid color, please try again.</span>")
		color_selection()
		return
	var/temp_hsv = RGBtoHSV(chosen_color)
	if(chosen_color == COLOR_BLACK)
		chosen_color = COLOR_WHITE
	else if(ReadHSV(temp_hsv)[3] < DARKNESS_THRESHOLD)
		to_chat(src, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")
		color_selection()
		return
	add_atom_colour(chosen_color, FIXED_COLOUR_PRIORITY)
	add_dragon_overlay()

/**
  * Adds the proper overlay to the space dragon.
  *
  * Clears the current overlay on space dragon and adds a proper one for whatever animation he's in.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/add_dragon_overlay()
	cut_overlays()
	if(stat == DEAD)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_dead")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(!using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_base")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)
		return
	if(using_special)
		var/mutable_appearance/overlay = mutable_appearance(icon, "overlay_gust")
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)

/**
  * Disperses the contents of the mob on the surrounding tiles.
  *
  * Randomly places the contents of the mob onto surrounding tiles.
  * Has a 10% chance to place on the same tile as the mob.
  */
/mob/living/simple_animal/hostile/space_dragon/proc/empty_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

#undef CHARGE_ONGOING
#undef CHARGE_FINALWARNING
#undef CHARGE_COMPLETED
#undef DARKNESS_THRESHOLD
