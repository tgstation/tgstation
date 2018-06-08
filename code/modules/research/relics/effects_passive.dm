/datum/relic_effect/passive/size_change
	weight = 20
	var/w_class

/datum/relic_effect/passive/size_change/init()
	w_class = rand(WEIGHT_CLASS_TINY,WEIGHT_CLASS_BULKY)

/datum/relic_effect/passive/size_change/apply(obj/item/A)
	A.w_class = w_class

/datum/relic_effect/passive/throw_power
	weight = 20
	var/force
	var/speed
	var/range

/datum/relic_effect/passive/throw_power/init()
	force = rand(0,10)
	if(prob(60))
		force *= rand(1,8)
	speed = rand(1,4)
	range = rand(2,7)

/datum/relic_effect/passive/throw_power/apply(obj/item/A)
	A.throwforce = force
	A.throw_speed = speed
	A.throw_range = range

/datum/relic_effect/weapon/attack_power
	weight = 20
	var/force

/datum/relic_effect/weapon/attack_power/init()
	force = rand(5,30)
	if(prob(30))
		force *= rand(1,3)

/datum/relic_effect/weapon/attack_power/apply(obj/item/A)
	A.force = force

/datum/relic_effect/weapon/damage_type
	weight = 20
	var/damtype

/datum/relic_effect/weapon/damage_type/init()
	damtype = pick(BURN,OXY,TOX)
	if(prob(30))
		damtype = STAMINA
	else if(prob(10))
		damtype = pick(CLONE,BRAIN)

/datum/relic_effect/weapon/damage_type/apply(obj/item/A)
	A.damtype = damtype

/datum/relic_effect/passive/tool
	weight = 0 //until tool_behavior is actually used
	hogged_signals = list(COMSIG_ITEM_ATTACK_SELF)
	var/tooltype
	var/toolspeed

/datum/relic_effect/passive/tool/init()
	tooltype = pick(TOOL_CROWBAR,TOOL_MULTITOOL,TOOL_SCREWDRIVER,TOOL_WIRECUTTER,TOOL_WRENCH,TOOL_WELDER)
	toolspeed = rand(1,100) / 10 //Anywhere from 0.1 to 10
	..()

/datum/relic_effect/passive/tool/apply(obj/item/A)
	A.tool_behaviour = tooltype
	A.toolspeed = toolspeed
	..()

/datum/relic_effect/passive/sharp
	weight = 20
	hint = list("It appears to be exceptionally sharp.")
	firstname = list("sharp","slicer","slashing","serrated","hypercutting","triclax")
	lastname = list("saw","blade","cutter","cutinator","sector","laser")

/datum/relic_effect/passive/sharp/apply(obj/item/A)
	A.sharpness = IS_SHARP
	A.hitsound = pick('sound/weapons/bladeslice.ogg','sound/weapons/circsawhit.ogg')
	..()

/datum/relic_effect/passive/sharp/scalpel
	firstname = list("monoatomic","precision")
	lastname = list("scalpel","precision saw","razor")

/datum/relic_effect/passive/sharp/scalpel/apply(obj/item/A)
	..()
	A.sharpness = IS_SHARP_ACCURATE

/datum/relic_effect/passive/light
	hint = list("It constantly emits a bright light.")
	weight = 20
	var/light_color
	var/power = 0
	var/range

/datum/relic_effect/passive/light/init()
	if(prob(50))
		light_color = pick(LIGHT_COLOR_GREEN,LIGHT_COLOR_RED,LIGHT_COLOR_YELLOW,LIGHT_COLOR_BLUE,LIGHT_COLOR_CYAN,LIGHT_COLOR_ORANGE,LIGHT_COLOR_PINK)
	if(prob(50))
		power = rand(1,6)
	if(prob(20)) //darklight
		power = -power / 4
	range = rand(1,20) * 0.5

/datum/relic_effect/passive/light/apply(obj/item/A)
	A.light_color = light_color
	A.set_light(l_range = range, l_power = power)

/datum/relic_effect/passive/materials
	weight = 20
	var/list/materials = list()
	var/static/list/valid_materials = list(MAT_METAL,MAT_GLASS,MAT_SILVER,MAT_GOLD,MAT_DIAMOND,MAT_URANIUM,MAT_PLASMA,MAT_BLUESPACE,MAT_BANANIUM,MAT_TITANIUM,MAT_BIOMASS)

/datum/relic_effect/passive/materials/init()
	var/times = rand(1,valid_materials.len)
	for(var/i in 1 to times)
		var/material = pick(valid_materials)
		materials[material] += rand(100,2000)
		if(prob(20))
			materials[material] *= rand(2,20)

/datum/relic_effect/passive/materials/apply(obj/item/A)
	A.materials = materials

/datum/relic_effect/stock_part
	weight = 20
	firstname = list("flux","high-priority","self-sealing","nuclear","fusion","fission","positronic","blip","argumentative","theoretical","ferro","acceleration")
	lastname = list("manipulator","laser","scanning module","stembolt","capacitor","matter bin","atmos seal","microreactor","module","circuit")
	var/rating

/datum/relic_effect/stock_part/init()
	rating = rand(1,4)
	if(prob(30))
		rating = rand(5,11) //sometimes they're brokenly good

/datum/relic_effect/stock_part/apply(obj/item/stock_parts/A)
	A.rating = rating

/datum/relic_effect/reagents
	weight = 20

/datum/relic_effect/reagents/apply(obj/item/A)
	if(!A.reagents)
		A.create_reagents(pick(20,50,100,200))

/datum/relic_effect/reagents/no_react
	weight = 20
	hint = list("Its insides are stabilized by highly sophisticated technology.")
	firstname = list("statis","cryo","nanofrost","hyperfreeze","modulated","temporal","stabilized")

/datum/relic_effect/reagents/no_react/apply(obj/item/A)
	..()
	if(A.reagents)
		A.reagents.set_reacting(FALSE)

/datum/relic_effect/reagents/big_beaker
	weight = 20
	firstname = list("huge","ginormous","deep","singularity","bluespace")
	var/volume

/datum/relic_effect/reagents/big_beaker/init()
	..()
	volume += rand(1,100)
	if(prob(60))
		volume *= rand(2,10)
	else if(prob(5)) //The holy grail rofl
		volume = volume ** rand(2,4)

/datum/relic_effect/reagents/big_beaker/apply(obj/item/A)
	..()
	if(!A.reagents)
		return
	A.reagents.maximum_volume = volume

/datum/relic_effect/reagents/fill_beaker
	weight = 20

/datum/relic_effect/reagents/fill_beaker/apply(obj/item/A)
	if(!A.reagents)
		return
	var/times = min(rand(1,10),A.reagents.maximum_volume)
	for(var/count in 1 to times)
		A.reagents.add_reagent(get_random_reagent_id(),rand(1,round(A.reagents.maximum_volume / times)))

//Supermatter for experimentor reaction.
/datum/relic_effect/passive/supermatter
	firstname = list("supermatter")
	hogged_signals = list(COMSIG_ITEM_EQUIPPED,COMSIG_PARENT_ATTACKBY)

/datum/relic_effect/passive/supermatter/apply_to_component(obj/item/A,datum/component/relic/comp)
	comp.RegisterSignal(COMSIG_ITEM_EQUIPPED, CALLBACK(src, .proc/touch, A, null))
	comp.RegisterSignal(COMSIG_PARENT_ATTACKBY, CALLBACK(src, .proc/touch, A))

/datum/relic_effect/passive/supermatter/apply(obj/item/A)
	A.color = list(LUMA_R,LUMA_R,0,0, LUMA_G,LUMA_G,0,0, LUMA_B,LUMA_B,0,0, 0,0,0,1, 0.5,0.5,0.5,0)
	A.set_light(l_range = 4)
	A.resistance_flags |= INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	A.AddComponent(/datum/component/radioactive, 400)

/datum/relic_effect/passive/supermatter/proc/touch(obj/item/A,obj/item/W,mob/living/user)
	if(istype(W, /obj/item/hemostat/supermatter) || istype(W, /obj/item/scalpel/supermatter) || istype(W, /obj/item/nuke_core_container/supermatter))
		return //Phew
	radiation_pulse(user, 500, 2)
	playsound(get_turf(user), 'sound/effects/supermatter.ogg', 50, 1)
	if(!W)
		to_chat(user, "<span class='warning'>You reach for \the [A] with your hands. That was dumb.</span>")
		user.dust()
	else
		to_chat(user, "<span class='notice'>As it touches \the [A], \the [W] bursts into dust!</span>")
		qdel(W)

//Sellable for lodsofemone at cargo
/datum/relic_effect/passive/loadsadosh
	weight = 20
	hint = list("The on-board appraisal routine has run out of memory while processing this object.")
	firstname = list("expensive","commercially-viable","nanocorp","THE ARM","syndi")
	var/value
	var/datum/export/relic/export_datum

/datum/relic_effect/passive/loadsadosh/init()
	value = rand(1,5000)
	if(prob(40)) //Sometimes it's worth even more dosh
		value *= rand(1,25)

/datum/relic_effect/passive/loadsadosh/apply(obj/item/A)
	if(!GLOB.exports_list.len)
		setupExports()
	if(!export_datum)
		export_datum = new()
		export_datum.unit_name = A.name
		export_datum.cost = value
		export_datum.init_cost = value
		GLOB.exports_list += export_datum
	export_datum.specific_relics += A
	export_datum.init_cost = value

/datum/export/relic
	cost = 100
	k_elasticity = 0
	var/list/specific_relics

/datum/export/relic/applies_to(obj/O, contr = 0, emag = 0)
	if(!get_cost(O, contr, emag))
		return FALSE
	return (O in specific_relics)