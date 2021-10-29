/obj/structure/ore_vein
	name = "ore vein"
	desc = "An ore vein that can mined."
	icon = 'modular_skyrat/modules/stone/icons/ore.dmi'
	icon_state = "stone"
	density = TRUE
	anchored = TRUE
	/// When we start mining, what do we tell the user they're mining?
	var/ore_descriptor = "stone"
	/// What type of ore do we drop?
	var/ore_type = /obj/item/stack/ore/stone
	/// How much ore do we drop?
	var/ore_amount = 1
	/// If the ore vein has been recently mined. If so, we cannot mine and must wait for it to regenerate.
	var/depleted = FALSE
	/// How long it takes for the ore to 'respawn' after being mined.
	var/regeneration_time = 15 SECONDS
	/// How long it takes for a tool to mine the ore vein.
	var/mining_time = 3 SECONDS
	/// How many unique sprites for ore we have, we will pick them at random.
	var/unique_sprites = 1
	/// If we should pick a random sprite for the ore vein or not.
	var/random_sprite = TRUE
	/// Our original description to hold. We'll revert to this when switching between the ore vein being depleted and not.
	var/base_desc = ""

/obj/structure/ore_vein/Initialize()
	. = ..()
	base_desc = desc
	if(random_sprite == TRUE)
		icon_state += "[rand(1, (unique_sprites))]"
	base_icon_state = icon_state

/obj/structure/ore_vein/update_icon_state()
	. = ..()
	if(depleted == TRUE)
		icon_state = "[base_icon_state]_depleted"
	else
		icon_state = "[base_icon_state]"

/obj/structure/ore_vein/examine()
	. = ..()
	. += "[depleted ? "The ore vein is exhausted." : ""]"

/obj/structure/ore_vein/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour != TOOL_MINING)
		to_chat(user, "<span class='notice'>You need a pickaxe to mine this.</span>")
		return FALSE
	if(!ore_type)
		to_chat(user, "<span class='notice'>There's no ore to mine!</span>")
		return FALSE
	if(!ore_amount)
		to_chat(user, "<span class='notice'>The [src] is too low quality to yield any useful amount of [ore_descriptor].</span>")
		return FALSE
	if(depleted == TRUE)
		to_chat(user, "<span class='notice'>This ore vein is exhausted.</span>")
		return FALSE
//	Our early return checks to tell the user what went wrong.
	to_chat(user, "<span class='notice'>You start mining the [ore_descriptor]...</span>")
	if(W.use_tool(src, user, src.mining_time, volume=50))
		to_chat(user, "<span class='notice'>You mine the [ore_descriptor].</span>")
		if(ore_type && ore_amount && depleted == FALSE)
			new ore_type(loc, ore_amount)
		SSblackbox.record_feedback("tally", "pick_used_mining", 1, W.type)
		depleted = TRUE
		update_icon_state()
		addtimer(CALLBACK(src, .proc/regenerate_ore), regeneration_time)
		
//	After the ore vein finishes its wait, we make the ore 'respawn' and return the ore to its original post-Initialize() icon_state.
/obj/structure/ore_vein/proc/regenerate_ore()
	depleted = FALSE
	update_icon_state()

/obj/structure/ore_vein/stone
	name = "stone mine"
	desc = "High-quality stone that once mined and refined, creates a robust construction material."
	icon_state = "stone"
	ore_type = /obj/item/stack/ore/stone
	ore_amount = 1
	unique_sprites = 2

/obj/structure/ore_vein/iron
	name = "iron mine"
	desc = "An iron ore vein!"
	icon_state = "iron"
	ore_descriptor = "iron"
	ore_type = /obj/item/stack/ore/iron
	ore_amount = 1
	unique_sprites = 2
	mining_time = 5 SECONDS

/obj/structure/ore_vein/silver
	name = "silver mine"
	desc = "Silver! In demand for more than it's beautiful lustre."
	icon_state = "silver"
	ore_descriptor = "silver"
	ore_type = /obj/item/stack/ore/silver
	ore_amount = 1
	unique_sprites = 1
	mining_time = 10 SECONDS
	regeneration_time = 20 SECONDS

/obj/structure/ore_vein/gold
	name = "gold mine"
	desc = "Precious shiny gold! A vital component for goods like electronics all the way to un-manned space vehicles."
	icon_state = "gold"
	ore_descriptor = "gold"
	ore_type = /obj/item/stack/ore/gold
	ore_amount = 1
	unique_sprites = 2
	mining_time = 10 SECONDS
	regeneration_time = 20 SECONDS

/obj/structure/ore_vein/plasma
	name = "plasma mine"
	desc = "Solid plasma! It's rather common."
	icon_state = "plasma"
	ore_descriptor = "plasma"
	ore_type = /obj/item/stack/ore/plasma
	ore_amount = 1
	unique_sprites = 1
	mining_time = 5 SECONDS
	regeneration_time = 20 SECONDS

/obj/structure/ore_vein/diamond
	name = "diamond mine"
	desc = "Diamond! It's rare and its industrial applications keep it very valuable."
	icon_state = "diamond"
	ore_descriptor = "diamond"
	ore_type = /obj/item/stack/ore/diamond
	ore_amount = 1
	unique_sprites = 2
	mining_time = 30 SECONDS
	regeneration_time = 120 SECONDS
