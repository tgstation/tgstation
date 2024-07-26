/obj/structure/ore_vein
	name = "ore vein"
	desc = "An ore vein that can mined."
	icon = 'monkestation/code/modules/blueshift/icons/ore.dmi'
	icon_state = "stone1"
	base_icon_state = "stone"
	density = TRUE
	anchored = TRUE
	/// When we start mining, what do we tell the user they're mining?
	var/ore_descriptor = "stone"
	/// What type of ore do we drop?
	var/ore_type = /obj/item/stack/stone
	/// How much ore do we drop?
	var/ore_amount = 5
	/// If the ore vein has been recently mined. If so, we cannot mine and must wait for it to regenerate.
	var/depleted = FALSE
	/// How long it takes for the ore to 'respawn' after being mined.
	var/regeneration_time = 3 MINUTES
	/// How long it takes for a tool to mine the ore vein.
	var/mining_time = 10 SECONDS
	/// How many unique sprites for ore we have, we will pick them at random.
	var/unique_sprites = 3
	/// If we should pick a random sprite for the ore vein or not.
	var/random_sprite = TRUE
	/// Our original description to hold. We'll revert to this when switching between the ore vein being depleted and not.
	var/base_desc = ""

/obj/structure/ore_vein/Initialize(mapload)
	. = ..()
	base_desc = desc
	if(random_sprite)
		base_icon_state += "[rand(1, (unique_sprites))]"

	icon_state = base_icon_state

/obj/structure/ore_vein/update_icon_state()
	icon_state = "[base_icon_state][depleted ? "_depleted" : ""]"

	return ..()

/obj/structure/ore_vein/examine()
	. = ..()
	. += "[depleted ? "The ore vein is exhausted." : ""]"

/obj/structure/ore_vein/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour != TOOL_MINING)
		to_chat(user, span_notice("You need a pickaxe to mine this."))
		return FALSE
	if(!ore_type)
		to_chat(user, span_notice("There's no ore to mine!"))
		return FALSE
	if(!ore_amount)
		to_chat(user, span_notice("The [src] is too low quality to yield any useful amount of [ore_descriptor]."))
		return FALSE
	if(depleted == TRUE)
		to_chat(user, span_notice("This ore vein is exhausted."))
		return FALSE
	// Our early return checks to tell the user what went wrong.
	to_chat(user, span_notice("You start mining the [ore_descriptor]..."))
	if(W.use_tool(src, user, src.mining_time, volume=50))
		to_chat(user, span_notice("You mine the [ore_descriptor]."))
		if(ore_type && ore_amount && depleted == FALSE)
			new ore_type(loc, ore_amount)
		SSblackbox.record_feedback("tally", "pick_used_mining", 1, W.type)
		depleted = TRUE
		update_icon_state()
		addtimer(CALLBACK(src, PROC_REF(regenerate_ore)), regeneration_time)

/// After the ore vein finishes its wait, we make the ore 'respawn' and return the ore to its original post-Initialize() icon_state.
/obj/structure/ore_vein/proc/regenerate_ore()
	depleted = FALSE
	update_icon_state()

/obj/structure/ore_vein/stone
	name = "large rocks"
	desc = "Various types of high quality stone that could probably make a good construction material if dug up and refined."

/obj/structure/ore_vein/iron
	name = "rusted rocks"
	desc = "The rusty brown color on these rocks gives away the fact they are full of iron!"
	icon_state = "iron1"
	base_icon_state = "iron"
	ore_descriptor = "iron"
	ore_type = /obj/item/stack/ore/iron

/obj/structure/ore_vein/silver
	name = "silvery-blue rocks"
	desc = "These rocks have the giveaway blued-silver look of, well, raw silver."
	icon_state = "silver1"
	base_icon_state = "silver"
	ore_descriptor = "silver"
	ore_type = /obj/item/stack/ore/silver

/obj/structure/ore_vein/gold
	name = "gold streaked rocks"
	desc = "Fairly normal looking rocks... aside from the streaks of shining gold running through some of them!."
	icon_state = "gold1"
	base_icon_state = "gold"
	ore_descriptor = "gold"
	ore_type = /obj/item/stack/ore/gold

/obj/structure/ore_vein/plasma
	name = "plasma rich rocks"
	desc = "Rocks with unrefined plasma visible on the outside of several... Do be careful with open flames near this."
	icon_state = "plasma1"
	base_icon_state = "plasma"
	ore_descriptor = "plasma"
	ore_type = /obj/item/stack/ore/plasma

/obj/structure/ore_vein/diamond
	name = "diamond studded rocks"
	desc = "While nowhere near as rare as you'd think, the diamonds studding these rocks are still both useful and valuable."
	icon_state = "diamond1"
	base_icon_state = "diamond"
	ore_descriptor = "diamond"
	ore_type = /obj/item/stack/ore/diamond

/obj/effect/turf_decal/lunar_sand
	name = "dusty floor"
	icon_state = "moonsandfloor"

/obj/effect/turf_decal/lunar_sand/plating
	name = "dusty plating"
	icon_state = "moonsandplating"
