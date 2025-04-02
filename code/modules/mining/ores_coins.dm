#define ORESTACK_OVERLAYS_MAX 10

/**********************Mineral ores**************************/

/obj/item/stack/ore
	name = "rock"
	icon = 'icons/obj/ore.dmi'
	icon_state = "ore"
	inhand_icon_state = null
	full_w_class = WEIGHT_CLASS_BULKY
	singular_name = "ore chunk"
	material_flags = MATERIAL_EFFECTS
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into
	var/mine_experience = 5 //How much experience do you get for mining this ore?
	novariants = TRUE // Ore stacks handle their icon updates themselves to keep the illusion that there's more going
	var/list/stack_overlays
	var/scan_state = "" //Used by mineral turfs for their scan overlay.
	var/spreadChance = 0 //Also used by mineral turfs for spreading veins
	drop_sound = SFX_STONE_DROP
	pickup_sound = SFX_STONE_PICKUP
	sound_vary = TRUE

/obj/item/stack/ore/update_overlays()
	. = ..()
	var/difference = min(ORESTACK_OVERLAYS_MAX, amount) - (LAZYLEN(stack_overlays)+1)
	if(!difference)
		return

	if(difference < 0 && LAZYLEN(stack_overlays)) //amount < stack_overlays, remove excess.
		if(LAZYLEN(stack_overlays)-difference <= 0)
			stack_overlays = null
			return
		stack_overlays.len += difference

	else //amount > stack_overlays, add some.
		for(var/i in 1 to difference)
			var/mutable_appearance/newore = mutable_appearance(icon, icon_state)
			newore.pixel_w = rand(-8,8)
			newore.pixel_z = rand(-8,8)
			LAZYADD(stack_overlays, newore)

	if(stack_overlays)
		. += stack_overlays

/obj/item/stack/ore/welder_act(mob/living/user, obj/item/I)
	..()
	if(!refined_type)
		return TRUE

	if(I.use_tool(src, user, 0, volume=50))
		new refined_type(drop_location())
		use(1)

	return TRUE

/obj/item/stack/ore/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(isnull(refined_type))
		return
	else
		var/probability = (rand(0,100))/100
		var/burn_value = probability*amount
		var/amountrefined = round(burn_value, 1)
		if(amountrefined < 1)
			qdel(src)
		else
			new refined_type(drop_location(),amountrefined)
			qdel(src)

/obj/item/stack/ore/uranium
	name = "uranium ore"
	icon_state = "uranium"
	singular_name = "uranium ore chunk"
	points = 30
	material_flags = NONE
	mats_per_unit = list(/datum/material/uranium=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/uranium
	mine_experience = 6
	scan_state = "rock_Uranium"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/uranium

/obj/item/stack/ore/iron
	name = "iron ore"
	icon_state = "iron"
	singular_name = "iron ore chunk"
	points = 1
	mats_per_unit = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/iron
	mine_experience = 1
	scan_state = "rock_Iron"
	spreadChance = 20
	merge_type = /obj/item/stack/ore/iron

/obj/item/stack/ore/glass
	name = "sand pile"
	icon_state = "glass"
	singular_name = "sand pile"
	points = 1
	mats_per_unit = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass
	w_class = WEIGHT_CLASS_TINY
	mine_experience = 0 //its sand
	merge_type = /obj/item/stack/ore/glass

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS), \
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/mineral/sandstone, 1, 1, 50, crafting_flags = NONE, category = CAT_MISC),\
		new /datum/stack_recipe("aesthetic volcanic floor tile", /obj/item/stack/tile/basalt, 2, 1, 50, crafting_flags = NONE, category = CAT_TILES)\
))

/obj/item/stack/ore/glass/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()
	AddComponent(/datum/component/storm_hating)

/obj/item/stack/ore/glass/get_main_recipes()
	. = ..()
	. += GLOB.sand_recipes

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.is_eyes_covered())
		C.visible_message(span_danger("[C]'s eye protection blocks the sand!"), span_warning("Your eye protection blocks the sand!"))
		return
	C.adjust_eye_blur(12 SECONDS)
	C.adjustStaminaLoss(15)//the pain from your eyes burning does stamina damage
	C.adjust_confusion(5 SECONDS)
	to_chat(C, span_userdanger("\The [src] gets into your eyes! The pain, it burns!"))
	qdel(src)

/obj/item/stack/ore/glass/ex_act(severity, target)
	if(severity)
		qdel(src)
		return TRUE

	return FALSE

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"
	mine_experience = 0
	merge_type = /obj/item/stack/ore/glass/basalt

/obj/item/stack/ore/plasma
	name = "plasma ore"
	icon_state = "plasma"
	singular_name = "plasma ore chunk"
	points = 15
	mats_per_unit = list(/datum/material/plasma=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/plasma
	mine_experience = 5
	scan_state = "rock_Plasma"
	spreadChance = 8
	merge_type = /obj/item/stack/ore/plasma

/obj/item/stack/ore/plasma/welder_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("You can't hit a high enough temperature to smelt [src] properly!"))
	return TRUE

/obj/item/stack/ore/silver
	name = "silver ore"
	icon_state = "silver"
	singular_name = "silver ore chunk"
	points = 16
	mine_experience = 3
	mats_per_unit = list(/datum/material/silver=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/silver
	scan_state = "rock_Silver"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/silver

/obj/item/stack/ore/gold
	name = "gold ore"
	icon_state = "gold"
	singular_name = "gold ore chunk"
	points = 18
	mine_experience = 5
	mats_per_unit = list(/datum/material/gold=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/gold
	scan_state = "rock_Gold"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/gold

/obj/item/stack/ore/diamond
	name = "diamond ore"
	icon_state = "diamond"
	singular_name = "diamond ore chunk"
	points = 50
	mats_per_unit = list(/datum/material/diamond=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/diamond
	mine_experience = 10
	scan_state = "rock_Diamond"
	merge_type = /obj/item/stack/ore/diamond

/obj/item/stack/ore/diamond/five
	amount = 5

/obj/item/stack/ore/bananium
	name = "bananium ore"
	icon_state = "bananium"
	singular_name = "bananium ore chunk"
	points = 60
	mats_per_unit = list(/datum/material/bananium=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/bananium
	mine_experience = 15
	scan_state = "rock_Bananium"
	merge_type = /obj/item/stack/ore/bananium

/obj/item/stack/ore/titanium
	name = "titanium ore"
	icon_state = "titanium"
	singular_name = "titanium ore chunk"
	points = 50
	mats_per_unit = list(/datum/material/titanium=SHEET_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium
	mine_experience = 3
	scan_state = "rock_Titanium"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/titanium

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless."
	icon_state = "slag"
	singular_name = "slag chunk"
	merge_type = /obj/item/stack/ore/slag

/obj/item/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/ore.dmi'
	icon_state = "gibtonite"
	inhand_icon_state = "Gibtonite ore"
	w_class = WEIGHT_CLASS_BULKY
	throw_range = 0
	/// if the gibtonite is currently primed for explosion
	var/primed = FALSE
	/// how long does it take for this to detonate
	var/det_time = 10 SECONDS
	/// the timer
	var/det_timer
	/// How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/quality = GIBTONITE_QUALITY_LOW
	/// who attached the rig to us
	var/attacher
	/// the assembly rig
	var/obj/item/assembly_holder/rig
	/// the rig overlay
	var/mutable_appearance/rig_overlay

/obj/item/gibtonite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
	AddComponent(/datum/component/golem_food, consume_on_eat = FALSE, golem_food_key = /obj/item/gibtonite)

/obj/item/gibtonite/examine(mob/user)
	. = ..()
	if(rig)
		. += span_warning("There is some kind of device <b>rigged</b> to it!")
	else
		. += span_notice("You could <b>rig</b> something to it.")

/obj/item/gibtonite/Destroy()
	QDEL_NULL(rig)
	rig_overlay = null
	return ..()

/obj/item/gibtonite/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rig)
		rig = null
		attacher = null
		cut_overlays(rig_overlay)
		UnregisterSignal(src, COMSIG_IGNITER_ACTIVATE)

/obj/item/gibtonite/IsSpecialAssembly()
	return TRUE

/obj/item/gibtonite/attackby(obj/item/I, mob/user, list/modifiers)
	if(istype(I, /obj/item/assembly_holder) && !rig)
		var/obj/item/assembly_holder/holder = I
		if(!(locate(/obj/item/assembly/igniter) in holder.assemblies))
			return ..()
		if(!user.transferItemToLoc(holder, src))
			return
		add_fingerprint(user)
		rig = holder
		holder.master = src
		holder.on_attach()
		rig_overlay = holder
		rig_overlay.pixel_z -= 5
		add_overlay(rig_overlay)
		RegisterSignal(src, COMSIG_IGNITER_ACTIVATE, PROC_REF(igniter_prime))
		log_bomber(user, "attached [holder] to ", src)
		attacher = key_name(user)
		user.balloon_alert_to_viewers("attached rig")
		return

	if(I.tool_behaviour == TOOL_WRENCH && rig)
		rig.on_found()
		if(QDELETED(src))
			return
		user.balloon_alert_to_viewers("detached rig")
		user.log_message("detached [rig] from [src].", LOG_GAME)
		user.put_in_hands(rig)
		return

	if(I.tool_behaviour == TOOL_MINING || istype(I, /obj/item/resonator) || I.force >= 10)
		GibtoniteReaction(user, "A resonator has primed for detonation a")
		return

	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) || I.tool_behaviour == TOOL_MULTITOOL)
		defuse(user)
		return

	return ..()

/// Stop the reaction and reduce ore explosive power
/obj/item/gibtonite/proc/defuse(mob/defuser)
	if (!primed)
		return
	primed = FALSE
	if(det_timer)
		deltimer(det_timer)
	defuser?.visible_message(span_notice("The chain reaction stopped! ...The ore's quality looks diminished."), span_notice("You stopped the chain reaction. ...The ore's quality looks diminished."))
	icon_state = "gibtonite"
	quality = GIBTONITE_QUALITY_LOW

/obj/item/gibtonite/attack_self(user)
	if(wires)
		wires.interact(user)
	else
		return ..()

/obj/item/gibtonite/bullet_act(obj/projectile/proj)
	GibtoniteReaction(proj.firer, "A projectile has primed for detonation a")
	return ..()

/obj/item/gibtonite/ex_act()
	GibtoniteReaction(null, "An explosion has primed for detonation a")
	return TRUE

/obj/item/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by)
	if(primed)
		return
	primed = TRUE
	playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,TRUE)
	icon_state = "gibtonite_active"
	var/notify_admins = FALSE
	if(!is_mining_level(z))//Only annoy the admins ingame if we're triggered off the mining zlevel
		notify_admins = TRUE

	if(user)
		user.visible_message(span_warning("[user] strikes \the [src], causing a chain reaction!"), span_danger("You strike \the [src], causing a chain reaction."))

	var/attacher_text = attacher ? "Igniter attacher: [ADMIN_LOOKUPFLW(attacher)]" : null

	if(triggered_by)
		log_bomber(user, triggered_by, src, attacher_text, notify_admins)
	else
		log_bomber(user, "Something has primed a", src, "for detonation.[attacher_text ? " " : ""][attacher_text]", notify_admins)

	det_timer = addtimer(CALLBACK(src, PROC_REF(detonate), notify_admins), det_time, TIMER_STOPPABLE)

/obj/item/gibtonite/proc/detonate(notify_admins)
	if(primed)
		switch(quality)
			if(GIBTONITE_QUALITY_HIGH)
				explosion(src, devastation_range = 2, heavy_impact_range = 4, light_impact_range = 9, flame_range = 0, flash_range = 0, adminlog = notify_admins)
			if(GIBTONITE_QUALITY_MEDIUM)
				explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 5, flame_range = 0, flash_range = 0, adminlog = notify_admins)
			if(GIBTONITE_QUALITY_LOW)
				explosion(src, heavy_impact_range = 1, light_impact_range = 3, flame_range = 0, flash_range = 0, adminlog = notify_admins)
		qdel(src)

/obj/item/gibtonite/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if (throwingdatum.dist_travelled < 2 || !isliving(hit_atom))
		return
	var/mob/living/hit_mob = hit_atom
	hit_mob.Paralyze(1.5 SECONDS)
	hit_mob.Knockdown(8 SECONDS)

/obj/item/gibtonite/proc/igniter_prime()
	SIGNAL_HANDLER
	GibtoniteReaction(null, "An attached rig has primed a")

/obj/item/stack/ore/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = base_pixel_x + rand(0, 16) - 8
	pixel_y = base_pixel_y + rand(0, 8) - 8

/obj/item/stack/ore/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE)
		qdel(src)
		return TRUE

	return FALSE


/*****************************Coin********************************/

// The coin's value is a value of its materials.
// Yes, the gold standard makes a come-back!
// This is the only way to make coins that are possible to produce on station actually worth anything.
/obj/item/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin"
	obj_flags = CONDUCTS_ELECTRICITY
	force = 1
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron = COIN_MATERIAL_AMOUNT)
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cooldown = 0
	var/value = 0
	var/coinflip
	item_flags = NO_MAT_REDEMPTION //You know, it's kind of a problem that money is worth more extrinsicly than intrinsically in this universe.
	///If you do not want this coin to be valued based on its materials and instead set a custom value set this to TRUE and set value to the desired value.
	var/override_material_worth = FALSE
	/// The name of the heads side of the coin
	var/heads_name = "heads"
	/// If the coin has an action or not
	var/has_action = FALSE

/obj/item/coin/Initialize(mapload)
	. = ..()
	coinflip = pick(sideslist)
	icon_state = "coin_[coinflip]"
	pixel_x = base_pixel_x + rand(0, 16) - 8
	pixel_y = base_pixel_y + rand(0, 8) - 8
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_BAIT_ALLOW_FISHING_DUD), INNATE_TRAIT)

/obj/item/coin/finalize_material_effects(list/materials)
	. = ..()
	if(override_material_worth)
		return
	value = 0
	for(var/datum/material/material as anything in materials)
		value += material.value_per_unit * materials[material][MATERIAL_LIST_OPTIMAL_AMOUNT]

/obj/item/coin/get_item_credit_value()
	return value

/obj/item/coin/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] contemplates suicide with \the [src]!"))
	if (!attack_self(user))
		user.visible_message(span_suicide("[user] couldn't flip \the [src]!"))
		return SHAME
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 1 SECONDS)//10 = time takes for flip animation
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/coin/proc/manual_suicide(mob/living/user)
	var/index = sideslist.Find(coinflip)
	if (index == 2)//tails
		user.visible_message(span_suicide("\the [src] lands on [coinflip]! [user] promptly falls over, dead!"))
		user.adjustOxyLoss(200)
		user.death(FALSE)
		user.set_suicide(TRUE)
		user.suicide_log()
	else
		user.visible_message(span_suicide("\the [src] lands on [coinflip]! [user] keeps on living!"))

/obj/item/coin/examine(mob/user)
	. = ..()
	. += span_info("It's worth [value] credit\s.")

/obj/item/coin/attackby(obj/item/W, mob/user, list/modifiers)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, span_warning("There already is a string attached to this coin!"))
			return

		if (CC.use(1))
			add_overlay("coin_string_overlay")
			string_attached = 1
			to_chat(user, span_notice("You attach a string to the coin."))
		else
			to_chat(user, span_warning("You need one length of cable to attach a string to the coin!"))
			return
	else
		..()

/obj/item/coin/wirecutter_act(mob/living/user, obj/item/I)
	..()
	if(!string_attached)
		return TRUE

	new /obj/item/stack/cable_coil(drop_location(), 1)
	overlays = list()
	string_attached = null
	to_chat(user, span_notice("You detach the string from the coin."))
	return TRUE

/obj/item/coin/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			to_chat(user, span_warning("The coin won't flip very well with something attached!") )
			return FALSE//do not flip the coin
		cooldown = world.time + 15
		flick("coin_[coinflip]_flip", src)
		coinflip = pick(sideslist)
		icon_state = "coin_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)
		var/oldloc = loc
		sleep(1.5 SECONDS)
		if(loc == oldloc && user && !user.incapacitated)
			user.visible_message(span_notice("[user] flips [src]. It lands on [coinflip]."), \
				span_notice("You flip [src]. It lands on [coinflip]."), \
				span_hear("You hear the clattering of loose change."))
		if(has_action)
			if(coinflip == heads_name)
				heads_action(user)
			else
				tails_action(user)
	return TRUE//did the coin flip? useful for suicide_act

/obj/item/coin/proc/heads_action(mob/user)
	return

/obj/item/coin/proc/tails_action(mob/user)
	return

/obj/item/coin/gold
	custom_materials = list(/datum/material/gold = COIN_MATERIAL_AMOUNT)

/obj/item/coin/silver
	custom_materials = list(/datum/material/silver = COIN_MATERIAL_AMOUNT)

/obj/item/coin/diamond
	custom_materials = list(/datum/material/diamond = COIN_MATERIAL_AMOUNT)

/obj/item/coin/plasma
	custom_materials = list(/datum/material/plasma = COIN_MATERIAL_AMOUNT)

/obj/item/coin/uranium
	custom_materials = list(/datum/material/uranium = COIN_MATERIAL_AMOUNT)

/obj/item/coin/titanium
	custom_materials = list(/datum/material/titanium = COIN_MATERIAL_AMOUNT)

/obj/item/coin/bananium
	custom_materials = list(/datum/material/bananium = COIN_MATERIAL_AMOUNT)

/obj/item/coin/adamantine
	custom_materials = list(/datum/material/adamantine = COIN_MATERIAL_AMOUNT)

/obj/item/coin/mythril
	custom_materials = list(/datum/material/mythril = COIN_MATERIAL_AMOUNT)

/obj/item/coin/plastic
	custom_materials = list(/datum/material/plastic = COIN_MATERIAL_AMOUNT)

/obj/item/coin/runite
	custom_materials = list(/datum/material/runite = COIN_MATERIAL_AMOUNT)

/obj/item/coin/twoheaded
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")

/obj/item/coin/antagtoken
	name = "antag token"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	icon_state = "coin_valid"
	custom_materials = list(/datum/material/plastic = COIN_MATERIAL_AMOUNT)
	sideslist = list("valid", "salad")
	heads_name = "valid"
	material_flags = NONE
	override_material_worth = TRUE

/obj/item/coin/iron

/obj/item/coin/gold/debug
	custom_materials = list(/datum/material/gold = COIN_MATERIAL_AMOUNT)
	desc = "If you got this somehow, be aware that it will dust you. Almost certainly."

/obj/item/coin/gold/debug/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			to_chat(user, span_warning("The coin won't flip very well with something attached!") )
			return FALSE//do not flip the coin
		cooldown = world.time + 15
		flick("coin_[coinflip]_flip", src)
		coinflip = pick(sideslist)
		icon_state = "coin_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)
		var/oldloc = loc
		sleep(1.5 SECONDS)
		if(loc == oldloc && user && !user.incapacitated)
			user.visible_message(span_notice("[user] flips [src]. It lands on [coinflip]."), \
				span_notice("You flip [src]. It lands on [coinflip]."), \
				span_hear("You hear the clattering of loose change."))
		SSeconomy.fire()
		to_chat(user,"<span class='bounty'>[SSeconomy.inflation_value()] is the inflation value.</span>")
	return TRUE//did the coin flip? useful for suicide_act


///Coins used in the dutchmen money bag.
/obj/item/coin/silver/doubloon
	name = "doubloon"

/obj/item/coin/gold/doubloon
	name = "doubloon"

/obj/item/coin/adamantine/doubloon
	name = "doubloon"

/obj/item/coin/eldritch
	name = "eldritch coin"
	desc = "A surprisingly heavy, ornate coin. Its sides seem to depict a different image each time you look."
	icon_state = "coin_heretic"
	custom_materials = list(/datum/material/diamond =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plasma =HALF_SHEET_MATERIAL_AMOUNT)
	sideslist = list("heretic", "blade")
	heads_name = "heretic"
	has_action = TRUE
	material_flags = NONE
	/// The range at which airlocks are effected.
	var/airlock_range = 5

/obj/item/coin/eldritch/heads_action(mob/user)
	var/mob/living/living_user = user
	if(!IS_HERETIC(user))
		living_user.adjustBruteLoss(5)
		return
	for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, user))
		if(target_airlock.density)
			target_airlock.open()
			continue
		target_airlock.close(force_crush = TRUE)

/obj/item/coin/eldritch/tails_action(mob/user)
	var/mob/living/living_user = user
	if(!IS_HERETIC(user))
		living_user.adjustFireLoss(5)
		return
	for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, user))
		if(target_airlock.locked)
			target_airlock.unlock()
			continue
		target_airlock.lock()

/obj/item/coin/eldritch/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/door/airlock))
		return NONE
	if(!IS_HERETIC(user))
		user.adjustBruteLoss(5)
		user.adjustFireLoss(5)
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/door/airlock/target_airlock = interacting_with
	to_chat(user, span_warning("You insert [src] into the airlock."))
	target_airlock.emag_act(user, src)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

#undef ORESTACK_OVERLAYS_MAX
