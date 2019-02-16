/*
Burning extracts:
	Have a unique, primarily offensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/burning
	name = "burning extract"
	desc = "It's boiling over with barely-contained energy."
	effect = "burning"
	icon_state = "burning"

/obj/item/slimecross/burning/Initialize()
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

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
	S.set_nutrition(S.get_hunger_nutrition()) //Tonight, we fight!
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
			do_teleport(L, get_turf(L), 6, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //Somewhere between the effectiveness of fake and real BS crystal
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
