/datum/chemical_reaction/cryogenic_fluid
	name = "cryogenic_fluid"
	id = "cryogenic_fluid"
	results = list("cryogenic_fluid" = 4)
	required_reagents = list("cryostylane" = 2, "lube" = 1, "pyrosium" = 2) //kinda difficult
	required_catalysts = list("plasma" = 1)
	required_temp = 100
	is_cold_recipe = TRUE
	mob_react = FALSE
	mix_message = "<span class='danger'>In a sudden explosion of vapour, the container begins to rapidly freeze and a frothing fluid begins to creep up the edges!</span>"

/datum/chemical_reaction/cryogenic_fluid/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 0 // cools the fuck down
	return

//casschem explosions
/datum/chemical_reaction/reagent_explosion/superboom//explodes on creation
	name = "N-amino azidotetrazole"
	id = "superboom"
	results = list("superboom" = 4)
	required_reagents = list("sboom" = 3, "ammonia" = 3,"dizinc" = 2)
	required_catalysts = list("tabunb" = 1)
	required_temp = 310
	pressure_required = 35
	strengthdiv = 1

/datum/chemical_reaction/reagent_explosion/superboom/on_reaction(datum/reagents/holder, created_volume)//not if stabilising agent is present
	if(holder.has_reagent("stabilizing_agent") && holder.chem_pressure < 40)
		return
	holder.remove_reagent("superboom", created_volume)

/datum/chemical_reaction/reagent_explosion/superboom_explosion//and when heated slightly
	name = "N-amino azidotetrazole explosion"
	id = "superboom_explosion"
	required_reagents = list("superboom" = 1)
	required_temp = 315
	strengthdiv = 0.5

/datum/chemical_reaction/reagent_explosion/sazide//explodes on creation
	name = "Sodium Azide"
	id = "sazide"
	results = list("sazide" = 4)
	required_reagents = list("hydrazine" = 1, "sacid" = 1, "nitrogen" = 1 , "ethanol" = 1)
	centrifuge_recipe = TRUE
	strengthdiv = 8

/datum/chemical_reaction/reagent_explosion/sazide/on_reaction(datum/reagents/holder, created_volume)//not if stabilising agent is present
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("sazide", created_volume)

/datum/chemical_reaction/reagent_explosion/sazide_explosion//and when heated slightly
	name = "N-amino azidotetrazole explosion"
	id = "superboom_explosion"
	required_reagents = list("sazide" = 1)
	required_temp = 574
	strengthdiv = 8

/datum/chemical_reaction/proto_fireball
	name = "Protomatised Plasma Fireball "
	id = "proto_fireball"
	required_reagents = list("proto" = 1)
	required_temp = 400
	mix_message = "<span class='boldannounce'>The protomatised plasma begins to boil very violently; superheating the surrounding air!</span>"

/datum/chemical_reaction/proto_fireball/on_reaction(datum/reagents/holder, created_volume)
	var/turf/open/T = get_turf(holder.my_atom)
	if(istype(T) && T.air)
		if(created_volume < 15)
			T.atmos_spawn_air("plasma=[created_volume];TEMP=[created_volume * 250]")//very fucking hot
		else
			T.atmos_spawn_air("plasma=[100];co2=[800];TEMP=[created_volume * 1000]")
			var/datum/gas_reaction/hippie_fusion/F = new
			F.react(T.air, T)

	return

/datum/chemical_reaction/reagent_explosion/dizinc_explosion
	name = "Diethly Zinc Explosion"
	id = "dizinc_explosion"
	required_reagents = list("dizinc" = 1, "oxygen" = 1)
	strengthdiv = 7


//over reaction stuff
/datum/chemical_reaction/proc/over_reaction(datum/reagents/holder, created_volume)
	if(istype(holder, /obj/effect/decal/cleanable/chempile))//smoke spam in chempiles is a big fat sausage of a NO
		holder.clear_reagents()
		return

	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, 4, location, 0)
		S.start()
	if(holder)
		holder.clear_reagents()

/datum/chemical_reaction/over_reactible
	var/exothermic_gain = 0
	var/overheat_threshold = 0
	var/overpressure_threshold = 0
	var/can_overheat = FALSE
	var/can_overpressure = FALSE

/datum/chemical_reaction/over_reactible/on_reaction(datum/reagents/holder, created_volume)
	..()
	holder.chem_temp += exothermic_gain

	if(can_overheat == TRUE && holder.chem_temp >= overheat_threshold)
		over_reaction(holder)
	if(can_overpressure == TRUE && holder.chem_pressure >= overpressure_threshold)
		over_reaction(holder, created_volume)

//all regular pyrotechnic recipes

/datum/chemical_reaction/hydrazine
	name = "Hydrazine"
	id = "hydrazine"
	results = list("hydrazine" = 4)
	required_reagents = list("bleach" = 1, "ammonia" = 1)
	required_temp = 430
	mix_message = "A furiously fuming oily liquid is produced!"

/datum/chemical_reaction/sboom
	name = "Nitrogenated isopropyl alcohol"
	id = "sboom"
	results = list("sboom" = 5, "tabuna" = 5)
	required_reagents = list("isopropyl" = 1, "nitrogen" = 6,"carbon" = 3)
	required_catalysts = list("goop" = 1)
	required_temp = 590
	pressure_required = 50

/datum/chemical_reaction/over_reactible/hexamine
	name = "Hexamine"
	id = "hexamine"
	results = list("hexamine" = 5)
	required_reagents = list("ammonia" = 3, "carbon" = 3)
	required_catalysts = list("iron" = 1)
	required_temp = 230
	pressure_required = 35
	is_cold_recipe = TRUE
	exothermic_gain = 25
	can_overheat = TRUE
	overheat_threshold = 245

/datum/chemical_reaction/over_reactible/oxyplas
	name = "Plasminate"
	id = "oxyplas"
	results = list("oxyplas" = 4, "hydrogen" = 4)
	required_catalysts = list("iron" = 2)
	required_reagents = list("plasma" = 5, "water" = 3)
	required_temp = 340
	can_overheat = TRUE
	overheat_threshold = 370

/datum/chemical_reaction/over_reactible/proto
	name = "Protomatised Plasma"
	id = "proto"
	results = list("proto" = 2, "radgoop" = 6)
	required_reagents = list("oxyplas" = 2, "hexamine" = 3)
	required_temp = 320
	radioactivity_required = 20
	can_overheat = TRUE
	overheat_threshold = 340

/datum/chemical_reaction/over_reactible/proto
	name = "Protomatised Plasma"
	id = "proto"
	results = list("proto" = 2, "radgoop" = 6)
	required_reagents = list("oxyplas" = 2, "hexamine" = 3)
	required_temp = 320
	radioactivity_required = 20
	can_overheat = TRUE
	overheat_threshold = 340

/datum/chemical_reaction/sparky
	name = "Electrostatic substance"
	id = "sparky"
	results = list("sparky" = 6, "radgoop" = 4)
	required_reagents = list("uranium" = 4, "carbon" = 2)
	radioactivity_required = 10

/datum/chemical_reaction/over_reactible/impvolt
	name = "Translucent mixture"
	id = "impvolt"
	results = list("impvolt" = 4, "emit_on" = 2)
	required_reagents = list("sparky" = 4, "teslium" = 2)
	required_temp = 290
	is_cold_recipe = TRUE
	bluespace_recipe = TRUE
	can_overheat = TRUE
	overheat_threshold = 310
	exothermic_gain = 20

/datum/chemical_reaction/over_reactible/volt
	name = "Sparking mixture"
	id = "volt"
	results = list("volt" = 2, "dizinc" = 1)
	required_reagents = list("impvolt" = 1, "methphos" = 1)
	required_temp = 250
	is_cold_recipe = TRUE
	can_overheat = TRUE
	overheat_threshold = 270
	exothermic_gain = 30

/datum/chemical_reaction/emit
	name = "Emittrium"
	id = "emit"
	results = list("emit" = 8, "radium" = 2)
	required_reagents = list("uranium" = 2 , "sparky" = 4 , "volt" = 2)
	bluespace_recipe = TRUE

/datum/chemical_reaction/emit_on
	name = "Emittrium_on"
	id = "emit_on"
	results = list("emit_on" = 1)
	required_reagents = list("emit" = 1)
	required_temp = 400

/datum/chemical_reaction/over_reactible/dizinc
	name = "Diethyl Mercury"
	id = "dizinc"
	results = list("dizinc" = 2)
	required_reagents = list("mercury" = 1, "ethanol" = 2)
	required_temp = 290
	is_cold_recipe = TRUE
	can_overheat = TRUE
	overheat_threshold = 310
	exothermic_gain = 30

/datum/chemical_reaction/arclumin
	name = "Arc-Luminol"
	id = "arclumin"
	results = list("arclumin" = 2)
	required_reagents = list("teslium" = 2, "rotatium" = 2, "liquid_dark_matter" = 2, "colorful_reagent" = 2) //difficult
	required_catalysts = list("plasma" = 1)
	required_temp = 400
	mix_message = "<span class='danger'>In a blinding flash of light, a glowing frothing solution forms and begins discharging!</span>"
	mix_sound = 'sound/effects/pray_chaplain.ogg'//truly a miracle

/datum/chemical_reaction/arclumin/on_reaction(datum/reagents/holder)//so bright it flashbangs
	var/location = get_turf(holder.my_atom)
	for(var/mob/living/carbon/C in get_hearers_in_view(3, location))
		if(C.flash_act())
			if(get_dist(C, location) < 2)
				C.Knockdown(50)
			else
				C.Stun(50)

/datum/chemical_reaction/reagent_explosion/on_reaction(datum/reagents/holder, created_volume, var/log=TRUE)//added much needed sanity check
	var/turf/T = get_turf(holder.my_atom)
	var/list/log_blacklist_typecache = list(/obj/effect/decal/cleanable/chempile, /obj/effect/particle_effect/vapour)
	log_blacklist_typecache = typecacheof(log_blacklist_typecache)
	if(is_type_in_typecache(holder.my_atom, log_blacklist_typecache))//anti spam
		log = FALSE
	if(isnull(T))
		return FALSE
	var/area/A = get_area(T)
	var/inside_msg
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		inside_msg = " inside [key_name_admin(M)]"
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
	if(log)
		message_admins("Reagent explosion reaction occurred at [A] [ADMIN_COORDJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
		log_game("Reagent explosion reaction occurred at [A] [COORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(modifier + round(created_volume/strengthdiv, 1), T, 0, 0)
	e.start(log)
	holder.clear_reagents()