/datum/reagent/cryogenic_fluid
	name = "Cryogenic Fluid"
	id = "cryogenic_fluid"
	description = "Extremely cold superfluid used to put out fires that will viciously freeze people on contact causing severe pain and burn damage, weak if ingested."
	color = "#b3ffff"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	processes = TRUE

/datum/reagent/cryogenic_fluid/process()
	if(holder)
		data++
		holder.chem_temp = max(holder.chem_temp - 15, TCMB)

	if(data >= 13)
		STOP_PROCESSING(SSreagent_states, src)
	..()

/datum/reagent/cryogenic_fluid/on_mob_life(mob/living/M) //not very pleasant but fights fires
	M.adjust_fire_stacks(-2)
	M.adjustStaminaLoss(2)
	M.adjustBrainLoss(1)
	M.bodytemperature = max(M.bodytemperature - 10, TCMB)
	return ..()

/datum/reagent/cryogenic_fluid/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST,INJECT))
			M.bodytemperature = max(M.bodytemperature - 50, TCMB)
			if(show_message)
				to_chat(M, "<span class='warning'>You feel like you are freezing from the inside!</span>")
		else
			if (reac_volume >= 5)
				if(show_message)
					to_chat(M, "<span class='danger'>You can feel your body freezing up and your metabolism slow, the pain is excruciating!</span>")
				M.bodytemperature = max(M.bodytemperature - 5*reac_volume, TCMB) //cold
				M.adjust_fire_stacks(-(12*reac_volume))
				M.losebreath += (0.2*reac_volume) //no longer instadeath rape but losebreath instead much more immulshion friendly
				M.drowsyness += 2
				M.confused += 6
				M.brainloss += (0.25*reac_volume) //hypothermia isn't good for the brain

			else
			 M.bodytemperature = max(M.bodytemperature - 15, TCMB)
			 M.adjust_fire_stacks(-(6*reac_volume))
	return ..()

/datum/reagent/cryogenic_fluid/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return FALSE
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T) //instantly delts hotspots
	if(isopenturf(T))
		var/turf/open/O = T
		if(hotspot)
			if(O.air)
				var/datum/gas_mixture/G = O.air
				G.temperature = 0
				G.react()
				qdel(hotspot)
		if(reac_volume >= 6)
			O.freon_gas_act() //freon in my pocket

/datum/reagent/impvolt
	name = "Translucent mixture"
	id = "impvolt"
	description = "It's sparking slightly."
	color = "#CABFAC"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/impvolt/on_mob_life(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='userdanger'>Your insides burn!</span>")
		M.adjustFireLoss(10)
	..()

/datum/reagent/volt
	name = "Sparking mixture"
	id = "volt"
	description = " A bubbling concoction of sparks and static electricity."
	color = "#11BFAC"

/datum/reagent/volt/on_mob_life(mob/living/M)
	if(prob(20))
		for(var/mob/living/T in view(M.loc,6))
			M.Beam(T, icon_state="lightning[rand(1,12)]",time=5)
			T.electrocute_act(15, "\a lightning from [M]")
		playsound(M.loc, 'sound/magic/lightningbolt.ogg', 50, 1)
		holder.remove_reagent(src.id,10, safety = 1)
	..()

/datum/reagent/emit
	name = "Emittrium"
	id = "emit"
	description = "An unstable compound prone to emitting intense bursts of plasma when in an excited state, it currently appears inert."
	color = "#AAFFAA"

/datum/reagent/emit_on
	name = "Glowing Emittrium"
	id = "emit_on"
	description = "It's rather radioactive and glowing painfully bright, you feel the need to RUN!"
	color = "#1211FB"
	processes = TRUE

/datum/reagent/emit_on/process()
	if(holder)
		playsound(get_turf(holder.my_atom), 'sound/weapons/emitter.ogg', 50, 1)
		for(var/direction in GLOB.cardinals)
			var/obj/item/projectile/beam/emitter/P = new /obj/item/projectile/beam/emitter(get_turf(holder.my_atom))
			switch(direction)
				if(1)
					P.fire(dir2angle(1))

				if(2)
					P.fire(dir2angle(2))

				if(4)
					P.fire(dir2angle(4))

				if(8)
					P.fire(dir2angle(8))

		holder.remove_reagent(src.id,10,safety = 1)
	..()

/datum/reagent/emit_on/on_mob_life(mob/living/M)
	M.apply_effect(5,IRRADIATE,0)
	..()

/datum/reagent/sboom
	name = "Nitrogenated isopropyl alcohol"
	id = "sboom"
	description = "Hmm , needs more nitrogen!"
	color = "#13BC5E"

/datum/reagent/superboom//oh boy
	name = "N-amino azidotetrazole"
	id = "superboom"
	description = "An absurdly unstable chemical prone to causing gigantic explosions when even slightly disturbed. Only an idiot would attempt to create this."
	color = "#13BC5E"
	processes = TRUE

/datum/reagent/superboom/on_mob_life(mob/living/M)
	if(M.m_intent == MOVE_INTENT_RUN && current_cycle <= 5)
		var/location = get_turf(holder.my_atom)
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(volume, 0.5), location, 0, 0, message = 0)
		e.start()
		holder.clear_reagents()
	..()

/datum/reagent/superboom/on_ex_act()
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(round(volume, 0.5), location, 0, 0, message = 0)
	e.start()
	holder.clear_reagents()
	..()

/datum/reagent/superboom/process()
	if(prob(0.5) && holder) //even if you do nothing it can explode
		var/location = get_turf(holder.my_atom)
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(volume, 0.5), location, 0, 0, message = 0)
		e.start()
		holder.clear_reagents()
	..()

/datum/reagent/sparky
	name = "Electrostatic substance"
	id = "sparky"
	description = "A charged substance that generates an electromagnetic field capable of interfering with light fixtures."
	color = "#A300B3"

/datum/reagent/sparky/on_mob_life(mob/living/M)
	for(var/obj/machinery/light/L in range(M, 5))
		if(prob(25))
			L.flicker()
		if(prob(15))
			L.light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_BLUE, LIGHT_COLOR_CYAN, LIGHT_COLOR_LAVA)
		if(prob(2))
			L.break_light_tube()

	if(prob(10))
		M.adjustFireLoss(3)//extremely weak damage
		do_sparks(2, TRUE, M)
	if(prob(5))
		M.adjust_fire_stacks(2)
		holder.remove_reagent(src.id,5,safety = 1)
	..()

/datum/reagent/dizinc//more dangerous than clf3 when ingested with slower metabolism, less effective on touch and doesn't burn objects
	name = "Diethyl zinc"
	id = "dizinc"
	description = "Highly pyrophoric substance that incinerates carbon based life, although it's not so effective on objects"
	color = "#000067"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/dizinc/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(4)
	M.IgniteMob()
	..()

/datum/reagent/dizinc/reaction_mob(mob/living/M, method=TOUCH)
	if(method != INGEST && method != INJECT)
		M.adjust_fire_stacks(pick(1, 3))
		M.IgniteMob()
		..()

/datum/reagent/hexamine
	name = "Hexamine"
	id = "hexamine"
	description = "Used in fuel production"
	color = "#000067"
	metabolization_rate = 4 * REAGENTS_METABOLISM

/datum/reagent/hexamine/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(3)//increases burn time
	..()

/datum/reagent/hexamine/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	M.adjust_fire_stacks(min(reac_volume/2, 10))//much more effective on the outside
	..()

/datum/reagent/oxyplas//very rapidly heats people up then metabolises
	name = "Plasminate"
	id = "oxyplas"
	description = "A toxic and flammable precursor"
	color = "#FF32A1"
	metabolization_rate = 4 * REAGENTS_METABOLISM

/datum/reagent/oxyplas/reaction_mob(mob/living/M, method=TOUCH)
	var/turf/T = get_turf(M)
	for(var/turf/F in range(1,T))
		new /obj/effect/hotspot(F)
	..()

/datum/reagent/oxyplas/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	M.bodytemperature += 60
	..()

/datum/reagent/proto//volatile. causes fireballs when heated or put in a burning human
	name = "Protomatised plasma"
	id = "proto"
	description = "An exceedingly pyrophoric state of plasma that superheats air and lifeforms alike"
	color = "#FF0000"

/datum/reagent/proto/reaction_mob(mob/living/M, method=TOUCH)
	var/turf/T = get_turf(M)
	for(var/turf/F in range(1,T))
		new /obj/effect/hotspot(F)
	..()

/datum/reagent/proto/on_mob_life(mob/living/M)
	if(M.on_fire)
		var/turf/T = get_turf(M)
		for(var/turf/F in range(1,T))
			new /obj/effect/hotspot(F)
	else
		M.reagents.add_reagent(pick("clf3", "dizinc", "oxyplas", "plasma"), 2)//ouch
	..()

/datum/reagent/arclumin//memechem made in honour of the late arclumin
	name = "Arc-Luminol"
	id = "arclumin"
	description = "You have no idea what the fuck this is but it looks absurdly unstable. It is emitting a sickly glow suggesting ingestion is probably not a great idea."
	reagent_state = LIQUID
	color = "#ffff66" //RGB: 255, 255, 102
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/arclumin/on_mob_life(mob/living/carbon/M)//windup starts off with constant shocking, confusion, dizziness and oscillating luminosity
	M.electrocute_act(1, 1, 1, stun = FALSE) //Override because it's caused from INSIDE of you
	M.set_light(rand(1,3))
	M.confused += 2
	M.dizziness += 4
	if(current_cycle >= 20) //the fun begins as you become a demigod of chaos
		var/turf/open/T = get_turf(holder.my_atom)
		switch(rand(1,6))

			if(1)
				playsound(T, 'sound/magic/lightningbolt.ogg', 50, 1)
				tesla_zap(T, zap_range = 6, power = 1000, explosive = FALSE)//weak tesla zap
				M.Stun(2)

			if(2)
				playsound(T, 'sound/effects/EMPulse.ogg', 30, 1)
				do_teleport(M, T, 5)

			if(3)
				M.randmuti()
				if(prob(75))
					M.randmutb()
				if(prob(1))
					M.randmutg()
				M.updateappearance()
				M.domutcheck()

			if(4)
				empulse(T, 3, 5, 1)

			if(5)
				playsound(T, 'sound/effects/supermatter.ogg', 20, 1)
				radiation_pulse(T, 4, 8, 25, 0)

			if(6)
				T.atmos_spawn_air("water_vapor= 40 ;TEMP= 298")//janitor friendly
	..()

/datum/reagent/arclumin/on_mob_delete(mob/living/M)// so you don't remain at luminosity 3 forever
	M.set_light(0)

/datum/reagent/arclumin/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)//weak on touch, short teleport and low damage shock, will however give a permanent weak glow
	if(method == TOUCH)
		M.electrocute_act(5, 1, 1, stun = FALSE)
		M.set_light(1)
		var/turf/T = get_turf(M)
		do_teleport(M, T, 2)

/datum/reagent/cryostylane
	processes = TRUE

/datum/reagent/cryostylane/process()
	if(holder)
		if(holder.has_reagent("oxygen"))
			holder.remove_reagent("oxygen", 1)
			holder.chem_temp -= 10
			holder.handle_reactions()
	..()

/datum/reagent/pyrosium
	processes = TRUE

/datum/reagent/pyrosium/process()
	if(holder)
		if(holder.has_reagent("oxygen"))
			holder.remove_reagent("oxygen", 1)
			holder.chem_temp += 10
			holder.handle_reactions()
	..()
