/obj/item/clothing/shoes/sneakers/mime
	name = "mime shoes"
	icon_state = "mime"

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 10, RAD = 0, FIRE = 70, ACID = 50)
	strip_delay = 40
	resistance_flags = NONE
	permeability_coefficient = 0.05 //Thick soles, and covers the ankle
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	lace_time = 12 SECONDS

/obj/item/clothing/shoes/combat/sneakboots
	name = "sneakboots"
	desc = "These boots have special noise cancelling soles. Perfect for stealth, if it wasn't for the color scheme."
	icon_state = "sneakboots"
	inhand_icon_state = "sneakboots"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF |  ACID_PROOF
	clothing_traits = list(TRAIT_SILENT_FOOTSTEPS)

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT boots"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	armor = list(MELEE = 40, BULLET = 30, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 30, RAD = 30, FIRE = 90, ACID = 50)

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 0.5)
	strip_delay = 5
	equip_delay_other = 50
	permeability_coefficient = 0.9
	can_be_tied = FALSE
	species_exception = list(/datum/species/golem)

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	icon_state = "black"
	resistance_flags = FIRE_PROOF |  ACID_PROOF
	species_exception = null

/obj/item/clothing/shoes/sandal/magic
	name = "magical sandals"
	desc = "A pair of sandals imbued with magic."
	resistance_flags = FIRE_PROOF |  ACID_PROOF

/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 40, ACID = 75)
	can_be_bloody = FALSE
	custom_price = PAYCHECK_EASY * 3
	can_be_tied = FALSE

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of orange rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"

/obj/item/clothing/shoes/galoshes/dry/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/on_step)

/obj/item/clothing/shoes/galoshes/dry/proc/on_step()
	SIGNAL_HANDLER

	var/turf/open/t_loc = get_turf(src)
	SEND_SIGNAL(t_loc, COMSIG_TURF_MAKE_DRY, TURF_WET_WATER, TRUE, INFINITY)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge! Ctrl-click to toggle waddle dampeners."
	name = "clown shoes"
	icon_state = "clown"
	inhand_icon_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown
	var/enabled_waddle = TRUE
	lace_time = 20 SECONDS // how the hell do these laces even work??
	species_exception = list(/datum/species/golem/bananium)

/obj/item/clothing/shoes/clown_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50, falloff_exponent = 20) //die off quick please)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/shoes/clown_shoes/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		if(enabled_waddle)
			user.AddElement(/datum/element/waddling)
		if(user.mind && user.mind.assigned_role == "Clown")
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)
	if(user.mind && user.mind.assigned_role == "Clown")
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")

/obj/item/clothing/shoes/clown_shoes/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_held_item() != src)
		to_chat(user, "<span class='warning'>You must hold the [src] in your hand to do this!</span>")
		return
	if (!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/clown_shoes/jester
	name = "jester shoes"
	desc = "A court jester's shoes, updated with modern squeaking technology."
	icon_state = "jester_shoes"

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	permeability_coefficient = 0.05 //Thick soles, and covers the ankle
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	can_be_tied = FALSE

/obj/item/clothing/shoes/jackboots/fast
	slowdown = -1

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	inhand_icon_state = "winterboots"
	permeability_coefficient = 0.15
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	lace_time = 8 SECONDS

/obj/item/clothing/shoes/winterboots/ice_boots
	name = "ice hiking boots"
	desc = "A pair of winter boots with special grips on the bottom, designed to prevent slipping on frozen surfaces."
	icon_state = "iceboots"
	inhand_icon_state = "iceboots"
	clothing_flags = NOSLIP_ICE

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Nanotrasen-issue Engineering lace-up work boots for the especially blue-collar."
	icon_state = "workboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	permeability_coefficient = 0.15
	strip_delay = 20
	equip_delay_other = 40
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	lace_time = 8 SECONDS
	species_exception = list(/datum/species/golem/uranium)

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/cult
	name = "\improper Nar'Sien invoker boots"
	desc = "A pair of boots worn by the followers of Nar'Sie."
	icon_state = "cult"
	inhand_icon_state = "cult"
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	lace_time = 10 SECONDS

/obj/item/clothing/shoes/cult/alt
	name = "cultist boots"
	icon_state = "cultalt"

/obj/item/clothing/shoes/cult/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/shoes/cult/alt/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	equip_delay_other = 50

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	inhand_icon_state = "roman"
	strip_delay = 100
	equip_delay_other = 100
	permeability_coefficient = 0.9
	can_be_tied = FALSE

/obj/item/clothing/shoes/griffin
	name = "griffon boots"
	desc = "A pair of costume boots fashioned after bird talons."
	icon_state = "griffinboots"
	inhand_icon_state = "griffinboots"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	lace_time = 8 SECONDS

/obj/item/clothing/shoes/bhop
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	inhand_icon_state = "jetboots"
	resistance_flags = FIRE_PROOF
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	actions_types = list(/datum/action/item_action/bhop)
	permeability_coefficient = 0.05
	strip_delay = 30
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash

/obj/item/clothing/shoes/bhop/ui_action_click(mob/user, action)
	if(!isliving(user))
		return

	if(recharging_time > world.time)
		to_chat(user, "<span class='warning'>The boot's internal propulsion needs to recharge still!</span>")
		return

	var/atom/target = get_edge_target_turf(user, user.dir) //gets the user's direction

	if (user.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(src, 'sound/effects/stealthoff.ogg', 50, TRUE, TRUE)
		user.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(user, "<span class='warning'>Something prevents you from dashing forward!</span>")

/obj/item/clothing/shoes/singery
	name = "yellow performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "ysing"
	equip_delay_other = 50

/obj/item/clothing/shoes/singerb
	name = "blue performer's boots"
	desc = "These boots were made for dancing."
	icon_state = "bsing"
	equip_delay_other = 50

/obj/item/clothing/shoes/bronze
	name = "bronze boots"
	desc = "A giant, clunky pair of shoes crudely made out of bronze. Why would anyone wear these?"
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	can_be_tied = FALSE

/obj/item/clothing/shoes/bronze/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/machines/clockcult/integration_cog_install.ogg' = 1, 'sound/magic/clockwork/fellowship_armory.ogg' = 1), 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/clothing/shoes/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either." //Thanks Fel
	icon_state = "wheelys"
	worn_icon_state = "wheelys"
	inhand_icon_state = "wheelys"
	worn_icon = 'icons/mob/large-worn-icons/64x64/feet.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64
	clothing_flags = LARGE_WORN_ICON
	actions_types = list(/datum/action/item_action/wheelys)
	///False means wheels are not popped out
	var/wheelToggle = FALSE
	///The vehicle associated with the shoes
	var/obj/vehicle/ridden/scooter/skateboard/wheelys/wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys

/obj/item/clothing/shoes/wheelys/Initialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	wheels = new wheels(null)
	wheels.link_shoes(src)

/obj/item/clothing/shoes/wheelys/ui_action_click(mob/user, action)
	if(!isliving(user))
		return
	if(!istype(user.get_item_by_slot(ITEM_SLOT_FEET), /obj/item/clothing/shoes/wheelys))
		to_chat(user, "<span class='warning'>You must be wearing the wheely-heels to use them!</span>")
		return
	if(!(wheels.is_occupant(user)))
		wheelToggle = FALSE
	if(wheelToggle)
		wheels.unbuckle_mob(user)
		wheelToggle = FALSE
		return
	wheels.forceMove(get_turf(user))
	wheels.buckle_mob(user)
	wheelToggle = TRUE

/obj/item/clothing/shoes/wheelys/dropped(mob/user)
	if(wheelToggle)
		wheels.unbuckle_mob(user)
		wheelToggle = FALSE
	..()

/obj/item/clothing/shoes/wheelys/proc/toggle_wheels(status)
	if (status)
		worn_icon_state = "[initial(icon_state)]-on"
	else
		worn_icon_state = "[initial(icon_state)]"
	playsound(src, 'sound/weapons/tap.ogg', 10, TRUE)
	update_icon()

/obj/item/clothing/shoes/wheelys/Destroy()
	QDEL_NULL(wheels)
	. = ..()

/obj/item/clothing/shoes/wheelys/rollerskates
	name = "roller skates"
	desc = "An EightO brand pair of roller skates. The wheels are retractable, though're quite bulky to walk in."
	icon_state = "rollerskates"
	worn_icon_state = "rollerskates"
	slowdown = SHOES_SLOWDOWN+1
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/rollerskates
	custom_premium_price = PAYCHECK_EASY * 5
	custom_price = PAYCHECK_EASY * 5

/obj/item/clothing/shoes/wheelys/skishoes
	name = "ski shoes"
	desc = "A pair of shoes equipped with foldable skis! Very handy to move in snowy environments unimpeded."
	icon_state = "skishoes"
	worn_icon_state = "skishoes"
	slowdown = SHOES_SLOWDOWN+1
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/skishoes
	custom_premium_price = PAYCHECK_EASY * 1.6
	custom_price = PAYCHECK_EASY * 1.6

/obj/item/clothing/shoes/kindle_kicks
	name = "Kindle Kicks"
	desc = "They'll sure kindle something in you, and it's not childhood nostalgia..."
	icon_state = "kindleKicks"
	inhand_icon_state = "kindleKicks"
	actions_types = list(/datum/action/item_action/kindle_kicks)
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 3
	light_on = FALSE
	var/lightCycle = 0
	var/active = FALSE


/obj/item/clothing/shoes/kindle_kicks/ui_action_click(mob/user, action)
	if(active)
		return
	active = TRUE
	set_light_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))
	set_light_on(active)
	addtimer(CALLBACK(src, .proc/lightUp), 0.5 SECONDS)

/obj/item/clothing/shoes/kindle_kicks/proc/lightUp(mob/user)
	if(lightCycle < 15)
		set_light_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))
		lightCycle++
		addtimer(CALLBACK(src, .proc/lightUp), 0.5 SECONDS)
	else
		lightCycle = 0
		active = FALSE
		set_light_on(active)

/obj/item/clothing/shoes/russian
	name = "russian boots"
	desc = "Comfy shoes."
	icon_state = "rus_shoes"
	inhand_icon_state = "rus_shoes"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	lace_time = 8 SECONDS

/obj/item/clothing/shoes/cowboy
	name = "cowboy boots"
	desc = "A small sticker lets you know they've been inspected for snakes, It is unclear how long ago the inspection took place..."
	icon_state = "cowboy_brown"
	permeability_coefficient = 0.05 //these are quite tall
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	custom_price = PAYCHECK_EASY
	var/list/occupants = list()
	var/max_occupants = 4
	can_be_tied = FALSE

/obj/item/clothing/shoes/cowboy/Initialize()
	. = ..()
	if(prob(2))
		var/mob/living/simple_animal/hostile/retaliate/poison/snake/bootsnake = new/mob/living/simple_animal/hostile/retaliate/poison/snake(src)
		occupants += bootsnake


/obj/item/clothing/shoes/cowboy/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		for(var/mob/living/occupant in occupants)
			occupant.forceMove(user.drop_location())
			user.visible_message("<span class='warning'>[user] recoils as something slithers out of [src].</span>", "<span class='userdanger'>You feel a sudden stabbing pain in your [pick("foot", "toe", "ankle")]!</span>")
			user.Knockdown(20) //Is one second paralyze better here? I feel you would fall on your ass in some fashion.
			user.apply_damage(5, BRUTE, pick(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			if(istype(occupant, /mob/living/simple_animal/hostile/retaliate/poison))
				user.reagents.add_reagent(/datum/reagent/toxin, 7)
		occupants.Cut()

/obj/item/clothing/shoes/cowboy/MouseDrop_T(mob/living/target, mob/living/user)
	. = ..()
	if(!(user.mobility_flags & MOBILITY_USE) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || target.stat == DEAD)
		return
	if(occupants.len >= max_occupants)
		to_chat(user, "<span class='warning'>[src] are full!</span>")
		return
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/poison/snake) || istype(target, /mob/living/simple_animal/hostile/headcrab) || istype(target, /mob/living/carbon/alien/larva))
		occupants += target
		target.forceMove(src)
		to_chat(user, "<span class='notice'>[target] slithers into [src].</span>")

/obj/item/clothing/shoes/cowboy/container_resist_act(mob/living/user)
	if(!do_after(user, 10, target = user))
		return
	user.forceMove(user.drop_location())
	occupants -= user

/obj/item/clothing/shoes/cowboy/white
	name = "white cowboy boots"
	icon_state = "cowboy_white"

/obj/item/clothing/shoes/cowboy/black
	name = "black cowboy boots"
	desc = "You get the feeling someone might have been hanged in these boots."
	icon_state = "cowboy_black"

/obj/item/clothing/shoes/cowboy/fancy
	name = "bilton wrangler boots"
	desc = "A pair of authentic haute couture boots from Japanifornia. You doubt they have ever been close to cattle."
	icon_state = "cowboy_fancy"
	permeability_coefficient = 0.08

/obj/item/clothing/shoes/cowboy/lizard
	name = "lizard skin boots"
	desc = "You can hear a faint hissing from inside the boots; you hope it is just a mournful ghost."
	icon_state = "lizardboots_green"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 40, ACID = 0) //lizards like to stay warm

/obj/item/clothing/shoes/cowboy/lizard/masterwork
	name = "\improper Hugs-The-Feet lizard skin boots"
	desc = "A pair of masterfully crafted lizard skin boots. Finally a good application for the station's most bothersome inhabitants."
	icon_state = "lizardboots_blue"

/obj/effect/spawner/lootdrop/lizardboots
	name = "random lizard boot quality"
	desc = "Which ever gets picked, the lizard race loses"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "lizardboots_green"
	loot = list(
		/obj/item/clothing/shoes/cowboy/lizard = 7,
		/obj/item/clothing/shoes/cowboy/lizard/masterwork = 1)

/obj/item/clothing/shoes/cookflops
	desc = "All this talk of antags, greytiding, and griefing... I just wanna grill for god's sake!"
	name = "grilling sandals"
	icon_state = "cookflops"
	can_be_tied = FALSE
	species_exception = list(/datum/species/golem)

/obj/item/clothing/shoes/yakuza
	name = "tojo clan shoes"
	desc = "Steel-toed and intimidating."
	icon_state = "MajimaShoes"
	inhand_icon_state = "MajimaShoes_worn"

/obj/item/clothing/shoes/jackbros
	name = "frosty boots"
	desc = "For when you're stepping on up to the plate."
	icon_state = "JackFrostShoes"
	inhand_icon_state = "JackFrostShoes_worn"
/obj/item/clothing/shoes/swagshoes
	name = "swag shoes"
	desc = "They got me for my foams!"
	icon_state = "SwagShoes"
	inhand_icon_state = "SwagShoes"

/obj/item/clothing/shoes/gunboots //admin boots that fire gunshots randomly while walking
	name = "gunboots"
	desc = "This is what all those research points added up to, the ultimate workplace hazard."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes
	/// What projectile do we shoot?
	var/projectile_type = /obj/projectile/bullet/c10mm
	/// Each step, this is the chance we fire a shot
	var/shot_prob = 50

/obj/item/clothing/shoes/gunboots/Initialize()
	. = ..()
	AddComponent(/datum/component/projectile_shooter, projectile_type = projectile_type, shot_prob = shot_prob, signal_or_sig_list = list(COMSIG_SHOES_STEP_ACTION, COMSIG_HUMAN_MELEE_UNARMED_ATTACK))
