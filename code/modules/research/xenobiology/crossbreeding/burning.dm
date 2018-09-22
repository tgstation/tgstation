/*
Burning extracts:
	Have a unique, primarily offensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/burning
	name = "burning extract"
	desc = "It's boiling over with barely-contained energy."
	effect = "burning"
	container_type = INJECTABLE | DRAWABLE
	icon_state = "burning"

/obj/item/slimecross/burning/Initialize()
	. = ..()
	create_reagents(10)

/obj/item/slimecross/burning/attack_self(mob/user)
	if(!reagents.has_reagent("plasma",10))
		to_chat(user, "<span class='warning'>This extract needs to be full of plasma to activate!</span>")
		return
	reagents.remove_reagent("plasma",10)
	to_chat(user, "<span class='notice'>You squeeze the extract, and it absorbs the plasma!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	playsound(src, 'sound/magic/fireball.ogg', 50, 1)
	do_effect(user)

/obj/item/slimecross/burning/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/burning/grey
	colour = "grey"

/obj/item/slimecross/burning/grey/do_effect(mob/user)
	var/mob/living/simple_animal/slime/S = new(get_turf(user),"grey")
	S.visible_message("<span class='danger'>A baby slime emerges from [src], and it nuzzles [user] before burbling hungrily!</span>")
	S.Friends[user] = 20 //Gas, gas, gas
	S.bodytemperature = T0C + 400 //We gonna step on the gas.
	S.nutrition = S.get_hunger_nutrition() //Tonight, we fight!
	..()

/obj/item/slimecross/burning/orange
	colour = "orange"

/obj/item/slimecross/burning/orange/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] boils over with a caustic gas!</span>")
	var/datum/reagents/R = new/datum/reagents(100)
	R.add_reagent("condensedcapsaicin", 100)

	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, 7, get_turf(user))
	smoke.start()
	..()

/obj/item/slimecross/burning/purple
	colour = "purple"

/obj/item/slimecross/burning/purple/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] fills with a bubbling liquid!</span>")
	new /obj/item/slimecrossbeaker/autoinjector/slimestimulant(get_turf(user))
	..()

/obj/item/slimecross/burning/blue
	colour = "blue"

/obj/item/slimecross/burning/blue/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] flash-freezes the area!</span>")
	for(var/turf/open/T in range(3, get_turf(user)))
		T.MakeSlippery(TURF_WET_PERMAFROST, min_wet_time = 10, wet_time_to_add = 5)
	for(var/mob/living/carbon/M in range(5, get_turf(user)))
		if(M != user)
			M.bodytemperature = BODYTEMP_COLD_DAMAGE_LIMIT + 10 //Not quite cold enough to hurt.
			to_chat(M, "<span class='danger'>You feel a chill run down your spine, and the floor feels a bit slippery with frost...</span>")
	..()

/obj/item/slimecross/burning/metal
	colour = "metal"

/obj/item/slimecross/burning/metal/do_effect(mob/user)
	for(var/turf/closed/wall/W in range(1,get_turf(user)))
		W.dismantle_wall(1)
		playsound(W, 'sound/effects/break_stone.ogg', 50, 1)
	user.visible_message("<span class='danger'>[src] pulses violently, and shatters the walls around it!</span>")
	..()

/obj/item/slimecross/burning/yellow
	colour = "yellow"

/obj/item/slimecross/burning/yellow/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] explodes into an electrical field!</span>")
	playsound(get_turf(src), 'sound/weapons/zapbang.ogg', 50, 1)
	for(var/mob/living/M in range(4,get_turf(user)))
		if(M != user)
			var/mob/living/carbon/C = M
			if(istype(C))
				C.electrocute_act(25,src)
			else
				M.adjustFireLoss(25)
			to_chat(M, "<span class='danger'>You feel a sharp electrical pulse!</span>")
	..()

/obj/item/slimecross/burning/darkpurple
	colour = "dark purple"

/obj/item/slimecross/burning/darkpurple/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] sublimates into a cloud of plasma!</span>")
	var/turf/T = get_turf(user)
	T.atmos_spawn_air("plasma=60")
	..()

/obj/item/slimecross/burning/darkblue
	colour = "dark blue"

/obj/item/slimecross/burning/darkblue/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] releases a burst of chilling smoke!</span>")
	var/datum/reagents/R = new/datum/reagents(100)
	R.add_reagent("frostoil", 40)
	user.reagents.add_reagent("cryoxadone",10)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, 7, get_turf(user))
	smoke.start()
	..()

/obj/item/slimecross/burning/silver
	colour = "silver"

/obj/item/slimecross/burning/silver/do_effect(mob/user)
	var/amount = rand(3,6)
	var/list/turfs = list()
	for(var/turf/open/T in range(1,get_turf(user)))
		turfs += T
	for(var/i = 0, i < amount, i++)
		var/path = get_random_food()
		var/obj/item/O = new path(pick(turfs))
		O.reagents.add_reagent("slimejelly",5) //Oh god it burns
		if(prob(50))
			O.desc += " It smells strange..."
	user.visible_message("<span class='danger'>[src] produces a few pieces of food!</span>")
	..()

/obj/item/slimecross/burning/bluespace
	colour = "bluespace"

/obj/item/slimecross/burning/bluespace/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] sparks, and lets off a shockwave of bluespace energy!</span>")
	for(var/mob/living/L in range(1, get_turf(user)))
		if(L != user)
			do_teleport(L, get_turf(L), 6, asoundin = 'sound/effects/phasein.ogg') //Somewhere between the effectiveness of fake and real BS crystal
			new /obj/effect/particle_effect/sparks(get_turf(L))
			playsound(get_turf(L), "sparks", 50, 1)
	..()

/obj/item/slimecross/burning/sepia
	colour = "sepia"

/obj/item/slimecross/burning/sepia/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] shapes itself into a camera!</span>")
	new /obj/item/camera/timefreeze(get_turf(user))
	..()

/obj/item/slimecross/burning/cerulean
	colour = "cerulean"

/obj/item/slimecross/burning/cerulean/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] produces a potion!</span>")
	new /obj/item/slimepotion/extract_cloner(get_turf(user))
	..()

/obj/item/slimecross/burning/pyrite
	colour = "pyrite"

/obj/item/slimecross/burning/pyrite/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] releases a colorful wave of energy, which shatters the lights!</span>")
	var/area/A = get_area(user.loc)
	for(var/obj/machinery/light/L in A) //Shamelessly copied from the APC effect.
		L.on = TRUE
		L.break_light_tube()
		L.on = FALSE
		stoplag()
	..()

/obj/item/slimecross/burning/red
	colour = "red"

/obj/item/slimecross/burning/red/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] pulses a hazy red aura for a moment, which wraps around [user]!</span>")
	for(var/mob/living/simple_animal/slime/S in view(7, get_turf(user)))
		if(user in S.Friends)
			var/friendliness = S.Friends[user]
			S.Friends = list()
			S.Friends[user] = friendliness
		else
			S.Friends = list()
		S.rabid = 1
		S.visible_message("<span class='danger'>The [S] is driven into a dangerous frenzy!</span>")
	..()

/obj/item/slimecross/burning/green
	colour = "green"

/obj/item/slimecross/burning/green/do_effect(mob/user)
	var/which_hand = "l_hand"
	if(!(user.active_hand_index % 2))
		which_hand = "r_hand"
	var/mob/living/L = user
	if(!istype(user))
		return
	var/obj/item/held = L.get_active_held_item() //This should be itself, but just in case...
	L.dropItemToGround(held)
	var/obj/item/melee/arm_blade/slime/blade = new(user)
	if(!L.put_in_hands(blade))
		qdel(blade)
		user.visible_message("<span class='warning'>[src] melts onto [user]'s arm, boiling the flesh horribly!</span>")
	else
		user.visible_message("<span class='danger'>[src] sublimates the flesh around [user]'s arm, transforming the bone into a gruesome blade!</span>")
	user.emote("scream")
	L.apply_damage(30,BURN,which_hand)
	..()

/obj/item/slimecross/burning/pink
	colour = "pink"

/obj/item/slimecross/burning/pink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] shrinks into a small, gel-filled pellet!</span>")
	new /obj/item/slimecrossbeaker/pax(get_turf(user))
	..()

/obj/item/slimecross/burning/gold
	colour = "gold"

/obj/item/slimecross/burning/gold/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] shudders violently, and summons an army for [user]!</span>")
	for(var/i in 1 to 3) //Less than gold normally does, since it's safer and faster.
		var/mob/living/simple_animal/S = create_random_mob(get_turf(user), HOSTILE_SPAWN)
		S.faction |= "[REF(user)]"
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(S, pick(NORTH,SOUTH,EAST,WEST))
	..()

/obj/item/slimecross/burning/oil
	colour = "oil"

/obj/item/slimecross/burning/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] begins to shake with rapidly increasing force!</span>")
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/burning/oil/proc/boom()
	explosion(get_turf(src), 2, 4, 4) //Same area as normal oils, but increased high-impact values by one each, then decreased light by 2.
	qdel(src)

/obj/item/slimecross/burning/black
	colour = "black"

/obj/item/slimecross/burning/black/do_effect(mob/user)
	var/mob/living/L = user
	if(!istype(L))
		return
	user.visible_message("<span class='danger'>[src] absorbs [user], transforming [user.p_them()] into a slime!</span>")
	var/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform/S = new()
	S.remove_on_restore = TRUE
	user.mind.AddSpell(S)
	S.cast(list(user),user)
	..()

/obj/item/slimecross/burning/lightpink
	colour = "light pink"

/obj/item/slimecross/burning/lightpink/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] lets off a hypnotizing pink glow!</span>")
	for(var/mob/living/carbon/C in view(7, get_turf(user)))
		C.reagents.add_reagent("pax",5)
	..()

/obj/item/slimecross/burning/adamantine
	colour = "adamantine"

/obj/item/slimecross/burning/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] crystallizes into a large shield!</span>")
	new /obj/item/twohanded/required/adamantineshield(get_turf(user))
	..()

/obj/item/slimecross/burning/rainbow
	colour = "rainbow"

/obj/item/slimecross/burning/rainbow/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] flattens into a glowing rainbow blade.</span>")
	new /obj/item/kitchen/knife/rainbowknife(get_turf(user))
	..()

//Misc. things added

/obj/item/camera/timefreeze
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1

/obj/item/camera/timefreeze/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return
	new /obj/effect/timestop(get_turf(target), 2, 50, list(user))
	. = ..()
	var/text = "The camera fades away"
	if(disk)
		text += ", leaving the disk behind!"
		user.put_in_hands(disk)
	else
		text += "!"
	to_chat(user,"<span class='notice'>[text]</span>")
	qdel(src)

/obj/item/slimepotion/extract_cloner
	name = "extract cloning potion"
	desc = "An more powerful version of the extract enhancer potion, capable of cloning regular slime extracts."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/extract_cloner/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers))
		return ..(target, user, proximity)
	if(istype(target, /obj/item/slimecross))
		to_chat(user, "<span class='warning'>[target] is too complex for the potion to clone!</span>")
		return
	if(!istype(target, /obj/item/slime_extract))
		return
	var/obj/item/slime_extract/S = target
	if(S.recurring)
		to_chat(user, "<span class='warning'>[target] is too complex for the potion to clone!</span>")
		return
	var/path = S.type
	var/obj/item/slime_extract/C = new path(get_turf(target))
	C.Uses = S.Uses
	to_chat(user, "<span class='notice'>You pour the potion onto [target], and the fluid solidifies into a copy of it!</span>")
	qdel(src)
	return

/obj/item/melee/arm_blade/slime
	name = "slimy boneblade"
	desc = "What remains of the bones in your arm. Incredibly sharp, and painful for both you and your opponents."
	force = 15
	force_string = "painful"

/obj/item/melee/arm_blade/slime/attack(mob/living/L, mob/user)
	. = ..()
	if(prob(20))
		user.emote("scream")

/obj/item/kitchen/knife/rainbowknife
	name = "rainbow knife"
	desc = "A strange, transparent knife which constantly shifts color. It hums slightly when moved."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rainbowknife"
	item_state = "rainbowknife"
	force = 15
	throwforce = 15
	damtype = BRUTE

/obj/item/kitchen/knife/rainbowknife/afterattack(atom/O, mob/user, proximity)
	if(proximity && istype(O, /mob/living))
		damtype = pick(BRUTE, BURN, TOX, OXY, CLONE)
	switch(damtype)
		if(BRUTE)
			hitsound = 'sound/weapons/bladeslice.ogg'
			attack_verb = list("slashed","sliced","cut")
		if(BURN)
			hitsound = 'sound/weapons/sear.ogg'
			attack_verb = list("burned","singed","heated")
		if(TOX)
			hitsound = 'sound/weapons/pierce.ogg'
			attack_verb = list("poisoned","dosed","toxified")
		if(OXY)
			hitsound = 'sound/effects/space_wind.ogg'
			attack_verb = list("suffocated","winded","vacuumed")
		if(CLONE)
			hitsound = 'sound/items/geiger/ext1.ogg'
			attack_verb = list("irradiated","mutated","maligned")
	return ..()

/obj/item/twohanded/required/adamantineshield
	name = "adamantine shield"
	desc = "A gigantic shield made of solid adamantium."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "adamshield"
	item_state = "adamshield"
	w_class = WEIGHT_CLASS_HUGE
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	slot_flags = ITEM_SLOT_BACK
	block_chance = 75
	throw_range = 1 //How far do you think you're gonna throw a solid crystalline shield...?
	throw_speed = 2
	force = 15 //Heavy, but hard to wield.
	attack_verb = list("bashed","pounded","slammed")
	item_flags = SLOWS_WHILE_IN_HAND


/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform
	name = "Slime Transformation"
	desc = "Transform from a human to a slime, or back again!"
	action_icon_state = "transformslime"
	cooldown_min = 0
	charge_max = 0
	invocation_type = "none"
	shapeshift_type = /mob/living/simple_animal/slime/transformedslime
	convert_damage = TRUE
	convert_damage_type = CLONE
	var/remove_on_restore = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform/Restore(mob/living/M)
	if(remove_on_restore)
		if(M.mind)
			M.mind.RemoveSpell(src)
	..()

/mob/living/simple_animal/slime/transformedslime

/mob/living/simple_animal/slime/transformedslime/Reproduce() //Just in case.
	to_chat(src, "<span class='warning'>I can't reproduce...</span>")
	return
