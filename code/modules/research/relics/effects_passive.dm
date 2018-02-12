/datum/relic_effect/passive/size_change/apply(obj/item/A)
	A.w_class = CLAMP(A.w_class + rand(1,3) * pick(-1,1),WEIGHT_CLASS_TINY,WEIGHT_CLASS_BULKY)

/datum/relic_effect/passive/throw_power/apply(obj/item/A)
	A.throwforce = rand(0,10)
	if(prob(50))
		A.throwforce *= rand(1,4)

/datum/relic_effect/passive/attack_power/apply(obj/item/A)
	A.force = rand(0,15)
	if(prob(30))
		A.force *= rand(1,3)

/datum/relic_effect/passive/damage_type/apply(obj/item/A)
	A.damtype = pick(BURN,OXY,TOX)
	if(prob(30))
		A.damtype = STAMINA
	else if(prob(10))
		A.damtype = pick(CLONE,BRAIN)

/datum/relic_effect/passive/sharp
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

/datum/relic_effect/passive/light/apply(/obj/item/A)
	if(prob(50))
		A.light_color = pick(LIGHT_COLOR_GREEN,LIGHT_COLOR_RED,LIGHT_COLOR_YELLOW,LIGHT_COLOR_BLUE,LIGHT_COLOR_CYAN,LIGHT_COLOR_ORANGE,LIGHT_COLOR_PINK)
	var/power = 0
	if(prob(50))
		power = rand(1,6)
	if(prob(20)) //darklight
		power = -power
	A.set_light(l_range = rand(1,20) * 0.5, l_power = power)

/datum/relic_effect/passive/reagents/no_react
	firstname = list("statis","cryo","nanofrost","hyperfreeze","modulated","temporal","stabilized")

/datum/relic_effect/passive/reagents/no_react/apply(obj/item/A)
	if(A.reagents)
		A.reagents.set_reacting(FALSE)

/datum/relic_effect/passive/reagents/big_beaker
	firstname = list("huge","ginormous","deep","singularity","bluespace")

/datum/relic_effect/passive/reagents/big_beaker/apply(obj/item/A)
	if(!A.reagents)
		return
	A.reagents.maximum_volume += rand(1,100)
	if(prob(60))
		A.reagents.maximum_volume *= rand(2,10)
	else if(prob(5)) //The holy grail rofl
		A.reagents.maximum_volume = A.reagents.maximum_volume ** rand(2,4)

/datum/relic_effect/passive/reagents/fill_beaker/apply(obj/item/A)
	if(!A.reagents)
		return
	var/times = min(rand(1,10),reagents.maximum_volume)
	for(var/count in 1 to times)
		A.reagents.add_reagent(get_random_reagent_id(),rand(1,round(reagents.maximum_volume / times)))

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

/datum/relic_effect/passive/loadsadosh
	firstname = list("expensive","commercially-viable","nanocorp","THE ARM","syndi")

/datum/relic_effect/passive/loadsadosh/apply(obj/item/A)
	if(!GLOB.exports_list.len)
		setupExports()
	var/datum/export/relic = new()
	relic.specific_relic = A
	relic.unit_name = A.name
	relic.cost = rand(1,5000)
	if(prob(40)) //Sometimes it's worth even more dosh
		relic.cost *= rand(1,25)
	GLOB.exports_list += relic

/datum/export/relic
	cost = 100
	var/obj/item/specific_relic

/datum/export/relic/applies_to(obj/O, contr = 0, emag = 0)
	if(!get_cost(O, contr, emag))
		return FALSE
	return O == specific_relic