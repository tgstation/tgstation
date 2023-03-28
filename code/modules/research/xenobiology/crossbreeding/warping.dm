/*
Warping extracts crossbreed
put up a rune with bluespace effects, lots of those runes are fluff or act as a passive buff, others are just griefing tools
*/

/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon_state = "warping"
	effect = "warping"
	colour = "grey"
	///what runes will be drawn depending on the crossbreed color
	var/obj/effect/warped_rune/runepath
	/// the number of "charge" a bluespace crossbreed start with
	var/warp_charge = INFINITY
	///time it takes to store the rune back into the crossbreed
	var/storing_time = 5 SECONDS
	///time it takes to draw the rune
	var/drawing_time = 5 SECONDS
	var/max_cooldown = 30 SECONDS
	var/cooldown = 0

/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "greyspace_rune"
	move_resist = INFINITY //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.
	anchored = TRUE
	layer = MID_TURF_LAYER
	resistance_flags = FIRE_PROOF
	var/dir_sound = 'sound/effects/phasein.ogg'
	var/activated_on_step = FALSE
	///is only used for bluespace crystal erasing as of now
	var/storing_time = 5 SECONDS
	///Nearly all runes needs to know which turf they are on
	var/turf/rune_turf
	var/remove_on_activation = TRUE

/obj/item/slimecross/warping/examine()
	. = ..()
	. += "It has [warp_charge] charge left"

///runes can also be deleted by bluespace crystals relatively fast as an alternative to cleaning them.
/obj/effect/warped_rune/attackby(obj/item/used_item, mob/user)
	. = ..()
	if(!istype(used_item,/obj/item/stack/sheet/bluespace_crystal) && !istype(used_item,/obj/item/stack/ore/bluespace_crystal))
		return

	var/obj/item/stack/space_crystal = used_item
	if(do_after(user, storing_time,target = src)) //the time it takes to nullify it depends on the rune too
		to_chat(user, "<span class='notice'>You nullify the effects of the rune with the bluespace crystal!</span>")
		space_crystal.use(1)
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)
		qdel(src)

/obj/effect/warped_rune/acid_act()
	. = ..()
	visible_message("<span class='warning'>[src] has been dissolved by the acid</span>")
	playsound(src, 'sound/items/welder.ogg', 150, TRUE)
	qdel(src)


///nearly all runes use their turf in some way so we set rune_turf to their turf automatically, the rune also start on cooldown if it uses one.
/obj/effect/warped_rune/Initialize()
	. = ..()
	add_overlay("blank", TRUE)
	rune_turf = get_turf(src)
	RegisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_rune)

/obj/effect/warped_rune/proc/clean_rune()
	qdel(src)

///using the extract on the floor will "draw" the rune.
/obj/item/slimecross/warping/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(istype(target, runepath)) //checks if the target is a rune and then if you can store it
		if(do_after(user, storing_time,target = target))
			warping_crossbreed_absorb(target, user)
		return

	if(isturf(target) && locate(/obj/effect/warped_rune) in target) //check if the target is a floor and if there's a rune on said floor
		to_chat(user, "<span class='warning'>There is already a bluespace rune here!</span>")
		return

	if(!isfloorturf(target))
		to_chat(user, "<span class='warning'>you cannot draw a rune here!</span>")
		return

	if(warp_charge < 1) //check if we have at least 1 charge left.
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(!check_cd(user))
		return

	if(do_after(user, drawing_time,target = target))
		if(warp_charge >= 1 && (!locate(/obj/effect/warped_rune) in target) && check_cd(user)) //check one last time if a rune has been drawn during the do_after and if there's enough charges left
			warping_crossbreed_spawn(target,user)
			make_cd()


///spawns the rune, taking away one rune charge
/obj/item/slimecross/warping/proc/warping_crossbreed_spawn(atom/target, mob/user)
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
	warp_charge--
	new runepath(target)
	to_chat(user, "<span class='notice'>You carefully draw the rune with [src].</span>")


///absorb the rune into the crossbreed adding one more charge to the crossbreed.
/obj/item/slimecross/warping/proc/warping_crossbreed_absorb(atom/target, mob/user)
	//to_chat(user, "<span class='notice'>You store the rune in [src].</span>")
	qdel(target)
	warp_charge++

/obj/item/slimecross/warping/proc/check_cd(user)
	if(world.time < cooldown)
		if(user)
			to_chat(user, "<span class='warning'>[src] is recharging energy.</span>")
		return FALSE
	return TRUE

/obj/item/slimecross/warping/proc/make_cd()
	cooldown = world.time + max_cooldown

/obj/effect/warped_rune/attack_hand(mob/living/user)
	. = ..()
	do_effect(user)

/obj/effect/warped_rune/proc/do_effect(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(remove_on_activation)
		playsound(rune_turf, dir_sound, 20, TRUE)
		to_chat(user, ("<span class='notice'>[src] fades.</span>"))
		qdel(src)

/obj/effect/warped_rune/Crossed(atom/movable/AM, oldloc)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(activated_on_step)
		playsound(rune_turf, dir_sound, 20, TRUE)
		visible_message("<span class='notice'>[src] fades.</span>")
		qdel(src)

/obj/item/slimecross/warping/grey
	name = "greyspace crossbreed"
	colour = "grey"
	effect_desc = "Draws a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace

/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components."
	icon_state = "rune_grey"
	///extractype is used to remember the type of the extract on the rune
	var/extractype
	var/req_extracts = 8

/obj/effect/warped_rune/greyspace/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Requires absorbing [req_extracts] [extractype ? "[extractype] extracts" : "slime extracts"].</span>")

/obj/effect/warped_rune/greyspace/do_effect(mob/user)
	for(var/obj/item/slime_extract/extract in rune_turf)
		if(extract.color_slime == extractype || !extractype) //check if the extract is the first one or of the right color.
			extractype = extract.color_slime
			qdel(extract) //vores the slime extract
			req_extracts--
			if(req_extracts <= 0)
				new /mob/living/simple_animal/slime (rune_turf, extractype) //spawn a slime from the extract's color
				req_extracts = initial(req_extracts)
				extractype = null // reset extractype to FALSE to allow a new extract type
				. = ..()
				break
			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
		else
			to_chat(user, "<span class='warning'>Requires a [extractype ? "[extractype] extracts" : "slime extract"].</span>")


/obj/item/slimecross/warping/orange
	colour = "orange"
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Draws a rune that can summon a bonfire."

/obj/effect/warped_rune/orangespace
	desc = "This can be activated to summon a bonfire."
	icon_state = "rune_orange"

/obj/effect/warped_rune/orangespace/do_effect(mob/user)
	var/obj/structure/bonfire/bluespace/B = new (rune_turf)
	B.start_burning()
	. = ..()

/obj/item/slimecross/warping/purple
	colour = "purple"
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = "Draws a rune that may be activated to summon two random medical items."

/obj/effect/warped_rune/purplespace
	desc = "This can be activated to summon two random medical."
	icon_state = "rune_purple"

/obj/effect/warped_rune/purplespace/do_effect(mob/user)
	var/list/medical = list(
		/obj/item/stack/medical/gauze,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/pill/oxandrolone,
		/obj/item/reagent_containers/pill/mutadone,
		/obj/item/reagent_containers/pill/patch/synthflesh,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/blood_filter)

	for(var/i in 1 to 2)
		var/path = pick_n_take(medical)
		new path(rune_turf)
	. = ..()

/obj/item/slimecross/warping/blue
	colour = "blue"
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "Draw a rune that is slippery like water and may be activated to cover all adjacent tiles in ice."

/obj/effect/warped_rune/cyanspace
	icon_state = "rune_blue"
	desc = "Its slippery like water and may be activated to cover all adjacent tiles in ice."

/obj/effect/warped_rune/cyanspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		T.MakeSlippery(TURF_WET_PERMAFROST, 1 MINUTES)
	. = ..()

/obj/effect/warped_rune/cyanspace/Initialize()
	. = ..()
	AddComponent(/datum/component/slippery, 30)

/obj/effect/warped_rune/cyanspace/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/dark_blue
	colour = "dark blue"
	runepath = /obj/effect/warped_rune/darkcyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "Draw a rune that can lower the temperature of whoever steps on it."

/obj/effect/warped_rune/darkcyanspace
	icon_state = "rune_dark_blue"
	desc = "Refreshing!"
	remove_on_activation = FALSE

/obj/effect/warped_rune/darkcyanspace/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		var/mob/living/L = AM
		L.adjust_bodytemperature(-300)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/metal
	colour = "metal"
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that may be activated to create a 3x3 block of invisible walls."

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "This can be activated to to create a 3x3 block of invisible walls."
	icon_state = "rune_metal"

/obj/effect/warped_rune/metalspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src))
		new /obj/effect/forcefield/mime(T, 150)
	. = ..()

/obj/item/slimecross/warping/yellow
	colour = "yellow"
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = "Draw a rune that causes electrical interference."

/obj/effect/warped_rune/yellowspace
	desc = "Be careful with taking power cells with you!"
	icon_state = "rune_yellow"
	remove_on_activation = FALSE

/obj/effect/warped_rune/yellowspace/Crossed(atom/movable/AM, oldloc)
	var/obj/item/stock_parts/cell/C = AM.get_cell()
	if(!C && isliving(AM))
		var/mob/living/L = AM
		for(var/obj/item/I in L.get_all_contents())
			C = I.get_cell()
			if(C?.charge)
				break
	if(C?.charge)
		do_sparks(5,FALSE,C)
		empulse(rune_turf, 1, 1)
		C.use(C.charge)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/darkpurple
	colour = "dark purple"
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Draw a rune that can transmute plasma into any other material."

/obj/effect/warped_rune/darkpurplespace
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rune_dark_purple"
	desc = "To gain something you must sacrifice something else in return."
	var/static/list/materials = list(/obj/item/stack/sheet/iron, /obj/item/stack/sheet/glass, /obj/item/stack/sheet/mineral/silver,
									/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/mineral/diamond, /obj/item/stack/sheet/mineral/uranium,
									/obj/item/stack/sheet/mineral/titanium, /obj/item/stack/sheet/mineral/uranium,
									/obj/item/stack/sheet/bluespace_crystal)

/obj/effect/warped_rune/darkpurplespace/do_effect(mob/user)
	if(locate(/obj/item/stack/sheet/mineral/plasma) in rune_turf)
		var/amt = 0
		for(var/obj/item/stack/sheet/mineral/plasma/P in rune_turf)
			amt += P.amount
			qdel(P)
		var/path_material = pick(materials)
		new path_material(rune_turf, amt)
		return ..()
	else
		to_chat(user, "<span class='warning'>Requires plasma!</span>")

/obj/item/slimecross/warping/silver
	colour = "silver"
	effect_desc = "Draw a rune that can feed whoever steps on it.."
	runepath = /obj/effect/warped_rune/silverspace

/obj/effect/warped_rune/silverspace
	desc = "This feeds whoever steps on it."
	icon_state = "rune_silver"
	remove_on_activation = FALSE

/obj/effect/warped_rune/silverspace/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.reagents.add_reagent(/datum/reagent/consumable/nutriment, 100)
		activated_on_step = TRUE
	. = ..()

GLOBAL_DATUM(blue_storage, /obj/item/storage/backpack/holding/bluespace)

/obj/item/storage/backpack/holding/bluespace
	name = "warped rune"
	anchored = TRUE
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/slimecross/warping/bluespace
	colour = "bluespace"
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = "Draw a rune that serves as a bluespace container."

/obj/effect/warped_rune/bluespace
	desc = "When activated, it gives access to a bluespace container."
	icon_state = "rune_bluespace"
	remove_on_activation = FALSE

/obj/effect/warped_rune/bluespace/do_effect(mob/user)
	if(!GLOB.blue_storage)
		GLOB.blue_storage = new
	GLOB.blue_storage.loc = loc
	GLOB.blue_storage.atom_storage?.open_storage(user)
	playsound(rune_turf, dir_sound, 20, TRUE)
	. = ..()

/obj/item/slimecross/warping/sepia
	colour = "sepia"
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = "Rune activates automatically when stepped on, triggering a timestop around it."

/obj/effect/warped_rune/sepiaspace
	desc = "stepping on it stops time around it."
	icon_state = "rune_sepia"
	remove_on_activation = FALSE

/obj/effect/warped_rune/sepiaspace/Crossed(atom/movable/AM, oldloc)
	new /obj/effect/timestop(rune_turf, null, null, null)
	activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/cerulean
	colour = "cerulean"
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = "Draws a rune that creates a hologram of the first living thing that stepped on the tile."

/obj/effect/warped_rune/ceruleanspace
	desc = "A shadow of what once passed these halls, a memory perhaps?"
	icon_state = "rune_cerulean"
	remove_on_activation = FALSE
	///hologram that will be spawned by the rune
	var/obj/effect/overlay/holotile
	///mob the hologram will copy
	var/mob/living/holo_host
	///used to remember the recent speech of the holo_host
	var/list/recent_speech
	///used to remember the timer ID that activates holo_talk

/obj/effect/warped_rune/ceruleanspace/proc/holo_talk()
	if(holotile && length(recent_speech)) //the proc should'nt be called if the list is empty in the first place but we might as well make sure.
		holotile.say(recent_speech[pick(recent_speech)]) //say one of the 10 latest sentence said by the holo_host
		addtimer(CALLBACK(src, .proc/holo_talk), 10 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/warped_rune/ceruleanspace/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && !holo_host)
		holo_host = AM

/obj/effect/warped_rune/ceruleanspace/do_effect(mob/user)
	. = ..()
	if(holo_host && !holotile)
		holo_creation()
		remove_on_activation = TRUE
		playsound(rune_turf, dir_sound, 20, TRUE)

/obj/effect/warped_rune/ceruleanspace/proc/holo_creation()
	addtimer(CALLBACK(src, .proc/holo_talk), 10 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	if(locate(holotile) in rune_turf)//here to delete the previous hologram,
		QDEL_NULL(holotile)

	holotile = new(rune_turf) //setting up the hologram to look like the person that just stepped in
	holotile.icon = holo_host.icon
	holotile.icon_state = holo_host.icon_state
	holotile.alpha = 200
	holotile.name = "[holo_host.name] (Hologram)"
	holotile.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	holotile.copy_overlays(holo_host, TRUE)
	holotile.anchored = TRUE
	holotile.density = FALSE

	//the code that follows is basically the code that changeling use to get people's last spoken sentences with a few tweaks.
	recent_speech = list() //resets the list from its previous sentences
	var/list/say_log = list()
	var/log_source = holo_host.logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type] //reverse the list so we get the last sentences instead of the first
			if(islist(reversed))
				say_log = reverse_range(reversed.Copy())
				break

	if(length(say_log) > 10) //we're going to get up to the last 10 sentences spoken by the holo_host
		recent_speech = say_log.Copy(say_log.len - 11, 0)
	else
		for(var/spoken_memory in say_log)
			if(recent_speech.len >= 10)
				break
			recent_speech[spoken_memory] = say_log[spoken_memory]

	if(!length(recent_speech)) //lazy lists don't work here for whatever reason so we set it to null manually if the list is empty.
		recent_speech = null

///destroys the hologram with the rune
/obj/effect/warped_rune/ceruleanspace/Destroy()
	QDEL_NULL(holotile)
	holo_host = null
	recent_speech = null
	return ..()

/obj/item/slimecross/warping/pyrite
	colour = "pyrite"
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whatever steps on it."

/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "rune_pyrite"
	remove_on_activation = FALSE
	var/colour = "#FFFFFF"

/obj/effect/warped_rune/pyritespace/Initialize()
	. = ..()
	colour = pick("#FFFFFF", "#FF0000", "#FFA500", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#FF00FF")

/obj/effect/warped_rune/pyritespace/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		AM.add_atom_colour(colour, WASHABLE_COLOUR_PRIORITY)
		activated_on_step = TRUE
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	. = ..()

/obj/item/slimecross/warping/green
	colour = "green"
	effect_desc = "Draw a rune that alters the DNA of those who step on it."
	runepath = /obj/effect/warped_rune/greenspace

/obj/effect/warped_rune/greenspace
	desc = "Warning: don't step on this if you want to keep your genes."
	icon_state = "rune_green"
	remove_on_activation = FALSE

/obj/effect/warped_rune/greenspace/Crossed(atom/movable/AM, oldloc)
	if(ishuman(AM))
		randomize_human(AM)
		activated_on_step = TRUE
	. = ..()

/* pink rune, makes people slightly happier after walking on it*/
/obj/item/slimecross/warping/pink
	colour = "pink"
	effect_desc = "Draws a rune that makes people happier!"
	runepath = /obj/effect/warped_rune/pinkspace

/obj/effect/warped_rune/pinkspace
	desc = "Love is the only reliable source of happiness we have left. But like everything, it comes with a price."
	icon_state = "rune_pink"
	remove_on_activation = FALSE

///adds the jolly mood effect along with hug sound effect.
/obj/effect/warped_rune/pinkspace/Crossed(atom/movable/AM, oldloc)
	if(istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/human_target = AM
		playsound(rune_turf, "sound/weapons/thudswoosh.ogg", 50, TRUE)
		human_target.add_mood_event("jolly", /datum/mood_event/jolly)
		to_chat(AM, "<span class='notice'>You feel happier.</span>")
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/gold
	colour = "gold"
	runepath = /obj/effect/warped_rune/goldspace
	effect_desc = "Draw a rune that exchanges objects of this dimension for objects of a parallel dimension."

/obj/effect/warped_rune/goldspace
	icon_state = "rune_gold"
	desc = "This can be activated to transmute valuable items into a random item."
	remove_on_activation = FALSE
	var/target_value = 5000
	var/static/list/common_items = list(
		/obj/item/toy/plush/carpplushie,
		/obj/item/toy/plush/bubbleplush,
		/obj/item/toy/plush/ratplush,
		/obj/item/toy/plush/narplush,
		/obj/item/toy/plush/snakeplushie,
		/obj/item/toy/plush/nukeplushie,
		/obj/item/toy/plush/slimeplushie,
		/obj/item/toy/plush/awakenedplushie,
		/obj/item/toy/plush/beeplushie,
		/obj/item/toy/plush/moth,
		/obj/item/toy/eightball/haunted,
		/obj/item/toy/foamblade,
		/obj/item/toy/katana,
		/obj/item/toy/snappop/phoenix,
		/obj/item/toy/redbutton,
		/obj/item/toy/toy_xeno,
		/obj/item/toy/reality_pierce,
		/obj/item/toy/xmas_cracker,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted,
		/obj/item/gun/ballistic/shotgun/toy/unrestricted,
		/obj/item/gun/ballistic/shotgun/toy/crossbow,
		/obj/item/clothing/mask/facehugger/toy,
		/obj/item/clothing/under/costume/roman,
		/obj/item/clothing/under/costume/pirate,
		/obj/item/clothing/under/costume/kilt/highlander,
		/obj/item/clothing/under/costume/gladiator/ash_walker,
		/obj/item/clothing/under/costume/geisha,
		/obj/item/clothing/under/costume/villain,
		/obj/item/clothing/under/costume/singer/yellow,
		/obj/item/clothing/under/costume/russian_officer
	)

	var/static/list/uncommon_items = list(
		/obj/item/clothing/suit/space/hardsuit/ancient,
		/obj/item/gun/energy/laser/retro/old,
		/obj/item/storage/toolbox/mechanical/old,
		/obj/item/storage/toolbox/emergency/old,
		/obj/structure/closet/crate/necropolis,
		/obj/item/card/emagfake,
		/obj/item/gun/ballistic/revolver/reverse,
		/obj/item/flashlight/flashdark,
		/obj/item/storage/belt/sabre,
		/obj/effect/mob_spawn/ghost_role/drone,
		/obj/item/sharpener,
		/mob/living/simple_animal/hostile/cat_butcherer
	)

	var/static/list/rare_items = list(
		/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/captain,
		/obj/structure/spawner/skeleton,
	)


/obj/effect/warped_rune/goldspace/do_effect(mob/user)
	var/price = 0
	var/list/valuable_items = list()
	for(var/obj/item/I in rune_turf)
		var/datum/export_report/ex = export_item_and_contents(I, dry_run=TRUE)
		for(var/x in ex.total_amount)
			if(ex.total_value[x])
				price += ex.total_value[x]
				valuable_items |= I

	if(price >= target_value)
		remove_on_activation = TRUE
		var/path
		switch(rand(1,100))
			if(1 to 80)
				path = pick(common_items)
			if(80 to 95)
				path = pick(uncommon_items)
			else
				path = pick(rare_items)

		var/atom/movable/A = new path(rune_turf)
		QDEL_LIST(valuable_items)
		to_chat(user, "<spawn class='notice'>[src] shines and [A] appears before you.</span>")
	else
		to_chat(user, "<span class='warning'>The sacrifice is insufficient.</span>")
	. = ..()

//oil
/obj/item/slimecross/warping/oil
	colour = "oil"
	runepath = /obj/effect/warped_rune/oilspace
	effect_desc = "Draw a rune that can explode whoever steps on it."

/obj/effect/warped_rune/oilspace
	icon_state = "rune_oil"
	desc = "This is basically a mine."
	remove_on_activation = FALSE

/obj/effect/warped_rune/oilspace/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		var/amt = rand(4,12)
		C.reagents.add_reagent(/datum/reagent/water, amt)
		C.reagents.add_reagent(/datum/reagent/potassium, amt)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/black
	colour = "black"
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "Draw a rune that can transmute a corpse into a shade."

/obj/effect/warped_rune/blackspace
	icon_state = "rune_black"
	desc = "Souls are like any other material, you just have to find the right place to manufacture them."

/obj/effect/warped_rune/blackspace/do_effect(mob/user)
	for(var/mob/living/carbon/human/host in rune_turf)
		if(host.key) //checks if the ghost and brain's there
			to_chat(user, "<span class='warning'>This body can't be transmuted by the rune in this state!</span>")
			return

		to_chat(user, "<span class='warning'>The rune is trying to repair [host.name]'s soul!</span>")
		var/list/candidates = poll_candidates_for_mob("Do you want to replace the soul of [host.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, host, POLL_IGNORE_SHADE)//todo: fix desc

		if(length(candidates) && !host.key) //check if anyone wanted to play as the dead person and check if no one's in control of the body one last time.
			var/mob/dead/observer/ghost = pick(candidates)

			host.key = ghost.key
			var/mob/living/simple_animal/shade/S = host.change_mob_type(/mob/living/simple_animal/shade , rune_turf, "Shade", FALSE)
			S.maxHealth = 1
			S.health = 1
			S.faction = host.faction
			S.copy_languages(host, LANGUAGE_MIND)
			playsound(host, "sound/magic/castsummon.ogg", 50, TRUE)
			qdel(host)
			activated_on_step = TRUE
			return ..()

		to_chat(user, "<span class='warning'>The rune failed! Maybe you should try again later.</span>")


/obj/item/slimecross/warping/lightpink
	colour = "light pink"
	runepath = /obj/effect/warped_rune/lightpinkspace
	effect_desc = "Draw a frog that makes whoever steps on it peaceful."

/obj/effect/warped_rune/lightpinkspace
	desc = "Peace and love."
	icon_state = "rune_light_pink"
	remove_on_activation = FALSE

/obj/effect/warped_rune/lightpinkspace/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.reagents.add_reagent(/datum/reagent/pax, 10)
		activated_on_step = TRUE
	. = ..()

/obj/item/slimecross/warping/adamantine
	colour = "adamantine"
	runepath = /obj/effect/warped_rune/adamantinespace
	effect_desc = "Draw a rune that can summon reflective fields."

/obj/effect/warped_rune/adamantinespace
	desc = "This can be activated to summon reflective fields."
	icon_state = "rune_adamantine"

/obj/structure/reflector/box/anchored/mob_pass/CanPass(atom/movable/mover, turf/target)
	if(isliving(mover))
		return TRUE
	return ..()

/obj/effect/warped_rune/adamantinespace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		var/obj/structure/reflector/box/anchored/mob_pass/D = new (T)
		D.set_angle(dir2angle(get_dir(src, D)))
		D.admin = TRUE
		QDEL_IN(D, 300)
	activated_on_step = TRUE
	. = ..()


///the template of the warped_room map
GLOBAL_DATUM(warped_room, /datum/map_template/warped_room)

/* Used to teleport anything over it to a unique room similar to hilbert's hotel.*/

/obj/item/slimecross/warping/rainbow
	colour = "rainbow"
	effect_desc = "Draws a rune that can be activated to teleport whoever is standing on it."
	runepath = /obj/effect/warped_rune/rainbowspace

/obj/effect/warped_rune/rainbowspace
	icon_state = "rune_rainbow"
	desc = "This is where I go when I want to be alone. Yet they keep clawing at the walls until everything crumbles."
	remove_on_activation = FALSE

/obj/effect/warped_room_exit
	name = "warped_rune"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rune_rainbow"
	desc = "Use this rune if you want to leave this place. You will have to leave eventually."
	move_resist = INFINITY
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/datum/map_template/warped_room
	name = "Warped room"
	mappath = '_maps/templates/warped_room.dmm'
	var/obj/effect/warped_room_exit/exit_rune
	var/list/rainbow_runes = list()

/area/warped_room
	name = "warped room"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = HIDDEN_AREA | NOTELEPORT

///creates the warped room and place an exit rune to exit the room
/obj/effect/warped_rune/rainbowspace/Initialize()
	. = ..()
	if(!GLOB.warped_room)
		GLOB.warped_room = new
		///current x,y,z location of the reserved space for the rune room
		var/datum/turf_reservation/room_reservation = SSmapping.RequestBlockReservation(GLOB.warped_room.width, GLOB.warped_room.height) //monkey sees valid location
		GLOB.warped_room.load(locate(room_reservation.bottom_left_coords[1], room_reservation.bottom_left_coords[2], room_reservation.bottom_left_coords[3]))//monkey room activate
		GLOB.warped_room.exit_rune = new (locate(room_reservation.bottom_left_coords[1] + 3, room_reservation.bottom_left_coords[2] + 6, room_reservation.bottom_left_coords[3]))
	GLOB.warped_room.rainbow_runes += src

/obj/effect/warped_rune/rainbowspace/do_effect(mob/user)
	var/tp_mob = FALSE
	for(var/mob/living/carbon/human/customer in rune_turf)
		tp_mob = TRUE
		customer.forceMove(get_turf(GLOB.warped_room.exit_rune))
	if(tp_mob)
		playsound(rune_turf, dir_sound, 20, TRUE)
	. = ..()

///Will delete the room when the rune is destroyed if no customer is left in the room.
/obj/effect/warped_rune/rainbowspace/Destroy()
	GLOB.warped_room?.rainbow_runes -= src
	return ..()

///anyone on the exit rune when it is used will be teleported to the rune that was used to teleport to the warped room
/obj/effect/warped_room_exit/attack_hand(mob/living/user)
	. = ..()
	var/exit_turf
	var/tp_mob = FALSE
	for(var/mob/living/carbon/human/customer in get_turf(src))
		do_sparks(3, FALSE, get_turf(src))
		if(!exit_turf)
			if(GLOB.warped_room?.rainbow_runes.len)
				var/obj/effect/warped_rune/WR = pick(GLOB.warped_room.rainbow_runes)
				exit_turf = WR.rune_turf
			else
				exit_turf = find_safe_turf()
		customer.forceMove(exit_turf)
		tp_mob = TRUE
	if(tp_mob)
		playsound(get_turf(src), 'sound/effects/phasein.ogg', 20, TRUE)
