/*
Destabilized extracts:
	Throwable extracts that apply an effect on hit.
*/

/obj/item/slimecross/destabilized
	name = "destabilized extract"
	desc = "It seems ready to burst at any moment."
	effect = "destabilized"
	icon_state = "destabilized"
	amountToCreate = 5
	var/reusable = FALSE

/obj/item/slimecross/destabilized/throw_impact(atom/A, datum/thrownthing/T)
	if(!..()) //For those tactical catches
		if(hitEffect(A, T.thrower))
			playsound(get_turf(A), 'sound/misc/splort.ogg', get_volume_by_throwforce_and_or_w_class(), 1, -1)
			if(!reusable)
				qdel(src)

/obj/item/slimecross/destabilized/proc/hitEffect(atom/A, mob/thrower)
	return TRUE //But nothing happens...

/obj/item/slimecross/destabilized/grey
	colour = "grey"

/obj/item/slimecross/destabilized/grey/hitEffect(atom/A, mob/thrower)
	. = ..()
	var/mob/living/simple_animal/slime/S = new (get_turf(A))
	S.rabid = TRUE
	S.Friends += thrower
	if(isliving(A))
		var/mob/living/L = A
		S.Target = L
		if(S.CanFeedon(L))
			S.Feedon(L)

/obj/item/slimecross/destabilized/orange
	colour = "orange"

/obj/item/slimecross/destabilized/orange/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		if(L.fire_stacks < 1)
			L.fire_stacks = 1
		L.IgniteMob()
	else
		new /obj/effect/hotspot(get_turf(A))

/obj/item/slimecross/destabilized/purple
	colour = "purple"

/obj/item/slimecross/destabilized/purple/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.reagents.add_reagent(/datum/reagent/medicine/regen_jelly, 50)
	else
		var/datum/reagents/R = new/datum/reagents(50)
		R.add_reagent(/datum/reagent/medicine/regen_jelly, 50)
		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(R, 1, get_turf(A))
		smoke.start()

/obj/item/slimecross/destabilized/blue
	colour = "blue"

/obj/item/slimecross/destabilized/blue/hitEffect(atom/A, mob/thrower)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(50)
	R.add_reagent(/datum/reagent/water, 50)
	R.reaction(get_turf(A), TOUCH, 50)
	qdel(R) //Reaction doesnt use up the reagents
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		C.slip(100, src, NONE, 20, FALSE)

/obj/item/slimecross/destabilized/metal
	colour = "metal"

/obj/item/slimecross/destabilized/metal/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		to_chat(L, "<span class='warning'>You suddenly find yourself trapped in a dark cage!</span>")
		L.apply_status_effect(/datum/status_effect/cageTrapped)
	else
		new /obj/structure/metalCage(get_turf(A))

/obj/item/slimecross/destabilized/yellow
	colour = "yellow"

/obj/item/slimecross/destabilized/yellow/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.electrocute_act(rand(5,20), src, 1, TRUE)
		playsound(L, "sparks", 50, 1)
	else
		empulse(get_turf(A), 1, 1)

/obj/item/slimecross/destabilized/darkpurple
	colour = "dark purple"

/obj/item/slimecross/destabilized/darkpurple/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.fire_stacks += 5
		L.reagents.add_reagent("plasma", 10)
	else
		var/datum/reagents/R = new/datum/reagents(10)
		R.add_reagent("plasma", 10)
		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(R, 1, get_turf(A))
		smoke.start()

/obj/item/slimecross/destabilized/darkblue
	colour = "dark blue"

/obj/item/slimecross/destabilized/darkblue/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.apply_status_effect(/datum/status_effect/freon/destabilized)

/obj/item/slimecross/destabilized/silver
	colour = "silver"

/obj/item/slimecross/destabilized/silver/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.nutrition = NUTRITION_LEVEL_FAT + 1
		to_chat(L, "<span class='warning'>You suddenly feel gorged!</span>")

/obj/item/slimecross/destabilized/bluespace
	colour = "bluespace"

/obj/item/slimecross/destabilized/bluespace/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		do_teleport(A, get_turf(thrower), 1)
	if(isobj(A))
		var/obj/O = A
		if(!O.anchored)
			do_teleport(O, get_turf(thrower), 1)

/obj/item/slimecross/destabilized/sepia
	colour = "sepia"

/obj/item/slimecross/destabilized/sepia/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/datum/proximity_monitor/advanced/timestop/TS = new()
		TS.host = A
		TS.freeze_atom(A)
		to_chat(A, "<span class='warning'>You suddenly feel every molecule in your body grind to a halt!</span>")
		QDEL_IN(TS, 70)
	else
		new /obj/effect/timestop(get_turf(A), null, 50)

/obj/item/slimecross/destabilized/cerulean
	colour = "cerulean"

/obj/item/slimecross/destabilized/cerulean/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(ismovableatom(A))
		new /mob/living/simple_animal/hostile/clone(get_turf(A), A, thrower)
	else
		new /mob/living/simple_animal/hostile/clone(get_turf(A), thrower, thrower)

/obj/item/slimecross/destabilized/pyrite
	colour = "pyrite"

/obj/item/slimecross/destabilized/pyrite/hitEffect(atom/A, mob/thrower)
	. = ..()
	var/turf/T = get_turf(A)
	T.add_atom_colour("#[rand_hex_color()]", WASHABLE_COLOUR_PRIORITY)
	for(var/atom/atoms in T)
		atoms.add_atom_colour("#[rand_hex_color()]", WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/destabilized/red
	colour = "red"

/obj/item/slimecross/destabilized/red/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		C.apply_status_effect(/datum/status_effect/heavyBleeding)
	else
		new /obj/effect/decal/cleanable/blood(get_turf(A))

/obj/item/slimecross/destabilized/green
	colour = "green"

/obj/item/slimecross/destabilized/green/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A) && isliving(thrower))
		var/mob/living/LTarget = A
		var/mob/living/LThrower = thrower
		var/damageToDeal
		if(iscarbon(LThrower))
			var/mob/living/carbon/CThrower = LThrower
			var/damageType = findBiggestLoss(CThrower)
			damageToDeal = min(CThrower.get_damage_amount(damageType), 25)
			CThrower.apply_damage_type(-25, damageType)
			if(iscarbon(LTarget))
				var/mob/living/carbon/CTarget = LTarget
				CTarget.apply_damage_type(damageToDeal, damageType)
				return
			LTarget.adjustBruteLoss(damageToDeal)
			return
		damageToDeal = -(LThrower.adjustBruteLoss(-25))
		LTarget.adjustBruteLoss(damageToDeal)

/obj/item/slimecross/destabilized/green/proc/findBiggestLoss(mob/living/carbon/C)
	var/damageType = BRUTE
	var/maxDamage = C.get_damage_amount(BRUTE)
	var/burnDamage = C.get_damage_amount(BURN)
	if(burnDamage > maxDamage)
		maxDamage = burnDamage
		damageType = BURN
	var/toxinDamage = C.get_damage_amount(TOX)
	if(toxinDamage > maxDamage)
		maxDamage = toxinDamage
		damageType = TOX
	var/oxyDamage = C.get_damage_amount(OXY)
	if(oxyDamage > maxDamage)
		maxDamage = oxyDamage
		damageType = OXY
	var/cloneDamage = C.get_damage_amount(CLONE)
	if(cloneDamage > maxDamage)
		maxDamage = cloneDamage
		damageType = CLONE
	var/staminaDamage = C.get_damage_amount(STAMINA)
	if(staminaDamage > maxDamage)
		maxDamage = staminaDamage
		damageType = STAMINA
	var/brainDamage = C.get_damage_amount(BRAIN)
	if(brainDamage > maxDamage)
		maxDamage = brainDamage
		damageType = BRAIN
	return damageType

/obj/item/slimecross/destabilized/pink
	colour = "pink"
	reusable = TRUE //Hugs are hard enough to come by as is.

/obj/item/slimecross/destabilized/pink/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(!isliving(A) || !iscarbon(thrower))
		return FALSE //Don't play the noise unless it lands a hit on a eligible mob.
	var/mob/living/carbon/CThrower = thrower
	if(iscarbon(A))
		var/mob/living/carbon/CTarget = A
		CTarget.help_shake_act(CThrower)
	else
		var/mob/living/LTarget = A
		var/oldIntent = CThrower.a_intent
		CThrower.a_intent = "help"
		LTarget.attack_hand(CThrower)
		CThrower.a_intent = oldIntent

/obj/item/slimecross/destabilized/gold
	colour = "gold"

/obj/item/slimecross/destabilized/gold/hitEffect(atom/A, mob/thrower)
	. = ..()
	new /obj/effect/temp_visual/goliath_tentacle(get_turf(A), thrower, FALSE)

/obj/item/slimecross/destabilized/oil
	colour = "oil"

/obj/item/slimecross/destabilized/oil/hitEffect(atom/A, mob/thrower)
	. = ..()
	explosion(get_turf(A),-1,-1,2, flame_range = 4)

/obj/item/slimecross/destabilized/black
	colour = "black"

/obj/item/slimecross/destabilized/black/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		L.blind_eyes(10)
		to_chat(L, "<span class='warning'>Your vision is suddenly clouded with inky blackness!</span>")
	else
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(2, get_turf(A))
		smoke.start()

/obj/item/slimecross/destabilized/lightpink
	colour = "light pink"

/obj/item/slimecross/destabilized/lightpink/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.reagents.add_reagent(/datum/reagent/pax, 5)
		else
			var/oldFaction = L.faction
			L.faction |= thrower.faction
			addtimer(CALLBACK(src, .proc/depacify, L, oldFaction), 50)
	else
		new /obj/effect/decal/cleanable/crayon(get_turf(A), "#[rand_hex_color()]", "peace")

/obj/item/slimecross/destabilized/lightpink/proc/depacify(mob/living/M, var/oldFaction)
	M.faction = oldFaction

/obj/item/slimecross/destabilized/adamantine
	colour = "adamantine"

/obj/item/slimecross/destabilized/adamantine/hitEffect(atom/A, mob/thrower)
	. = ..()
	for(var/turf/T in spiral_range(1, get_turf(A)))
		new /obj/item/shard(T)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		var/obj/item/targetShoes = H.get_item_by_slot(SLOT_SHOES)
		if(targetShoes)
			H.dropItemToGround(targetShoes)

/obj/item/slimecross/destabilized/rainbow
	colour = "rainbow"

/obj/item/slimecross/destabilized/rainbow/hitEffect(atom/A, mob/thrower)
	. = ..()
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		H.apply_status_effect(/datum/status_effect/cellularDestabilization)