#define ALERT_AMOUNT_ONLY 1
#define ALERT_ALL_REAGENTS 2

///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	//Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null //The container required for the reaction to happen
	var/required_other = 0 //An integer required for the reaction to happen

	var/result_amount = 0
	var/secondary = 0 //Set to nonzero if secondary reaction
	var/list/secondary_results = list() //Additional reagents produced by the reaction
	var/requires_heating = 0
	var/alert_admins = 0 //1 to alert admins with name and amount, 2 to alert with name and amount of all reagents

/datum/chemical_reaction/proc/log_reaction(var/datum/reagents/holder, var/amt)
	var/datum/log_controller/I = investigations[I_CHEMS]
	var/atom/A = holder.my_atom
	var/turf/T = get_turf(holder.my_atom)
	var/mob/M = get_holder_of_type(A, /mob) //if held by a mob (not necessarily true)

	var/obj/machinery/O = get_holder_of_type(A, /obj/machinery) //rather than showing "in a large beaker" let's show the name of the machine if it's inside one
	if(istype(O))
		A = O

	var/investigate_text = "<small>[time2text(world.timeofday,"hh:mm:ss")] \ref[A] ([T.x],[T.y],[T.z])</small> || "

	if(result)
		investigate_text += "[amt]u of [result] have been created"
	else
		investigate_text += "\A [name] reaction ([amt]u total combined) has taken place"

	if(M)
		investigate_text += " in \a [A], carried by [M.real_name] ([M.key])<br />"
	else
		investigate_text += " in \a [A], last touched by [(A.fingerprintslast ? A.fingerprintslast : "N/A (Last user processed: [usr.ckey])")]<br />"

	I.write(investigate_text)

	if(alert_admins)
		var/admin_text = "[name] reaction [alert_admins == 2 ? "([holder.get_reagent_ids(1)])" : "([amt]u total combined)"] at [formatJumpTo(T)]"
		if(M)
			admin_text += " in \a [A] (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>), carried by [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
		else
			admin_text += " in \a [A] (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>), last touched by [(A.fingerprintslast ? A.fingerprintslast : "N/A (Last user processed: [usr.ckey])")]"
		message_admins(admin_text, 0, 1)
	return investigate_text

/datum/chemical_reaction/proc/on_reaction(var/datum/reagents/holder, var/created_volume)
	return

//I recommend you set the result amount to the total volume of all components.
/datum/chemical_reaction/explosion_potassium
	name = "Water Potassium Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list(WATER = 1, POTASSIUM = 1)
	result_amount = 2
	alert_admins = ALERT_AMOUNT_ONLY

/datum/chemical_reaction/explosion_potassium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat != DEAD)
			e.amount *= 0.5
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/creatine
	name = "Creatine"
	id = CREATINE
	result = CREATINE
	required_reagents = list(NUTRIMENT = 1, BICARIDINE = 1, HYPERZINE = 1, MUTAGEN = 1)
	result_amount = 2

/datum/chemical_reaction/discount
	name = "Discount Dan's Special Sauce"
	id = DISCOUNT
	result = DISCOUNT
	required_reagents = list(IRRADIATEDBEANS = 1, TOXICWASTE = 1, REFRIEDBEANS = 1, MUTATEDBEANS = 1, BEFF = 1, HORSEMEAT = 1, \
							 MOONROCKS = 1, OFFCOLORCHEESE = 1, BONEMARROW = 1, GREENRAMEN = 1, GLOWINGRAMEN = 1, DEEPFRIEDRAMEN = 1)
	result_amount = 12

/datum/chemical_reaction/peptobismol
	name = "Peptobismol"
	id = PEPTOBISMOL
	result = PEPTOBISMOL
	required_reagents = list(ANTI_TOXIN = 1, DISCOUNT = 1)
	result_amount = 2

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list(URANIUM = 1, IRON = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	//100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	//200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()

/datum/chemical_reaction/silicate
	name = "Silicate"
	id = SILICATE
	result = SILICATE
	required_reagents = list(ALUMINUM = 1, SILICON = 1, OXYGEN = 1)
	result_amount = 9

/datum/chemical_reaction/phalanximine
	name = "Phalanximine"
	id = PHALANXIMINE
	result = PHALANXIMINE
	required_reagents = list(HYRONALIN = 1, ETHANOL = 1, MUTAGEN = 1)
	result_amount = 3

/datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = STOXIN
	result = STOXIN
	required_reagents = list(CHLORALHYDRATE = 1, SUGAR = 4)
	result_amount = 5

/datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = STERILIZINE
	result = STERILIZINE
	required_reagents = list(ETHANOL = 1, ANTI_TOXIN = 1, CHLORINE = 1)
	result_amount = 3

/datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = INAPROVALINE
	result = INAPROVALINE
	required_reagents = list(OXYGEN = 1, CARBON = 1, SUGAR = 1)
	result_amount = 3

/datum/chemical_reaction/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = ANTI_TOXIN
	result = ANTI_TOXIN
	required_reagents = list(SILICON = 1, POTASSIUM = 1, NITROGEN = 1)
	result_amount = 3

/datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = MUTAGEN
	result = MUTAGEN
	required_reagents = list(RADIUM = 1, PHOSPHORUS = 1, CHLORINE = 1)
	result_amount = 3

/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = TRAMADOL
	result = TRAMADOL
	required_reagents = list(INAPROVALINE = 1, ETHANOL = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = OXYCODONE
	result = OXYCODONE
	required_reagents = list(ETHANOL = 1, TRAMADOL = 1, PLASMA = 1)
	result_amount = 1

///datum/chemical_reaction/cyanide
//	name = "Cyanide"
//	id = CYANIDE
//	result = CYANIDE
//	required_reagents = list(HYDROGEN = 1, CARBON = 1, NITROGEN = 1)
//	result_amount = 1

/* You attempt to make water by mixing the ingredients for Hydroperoxyl, but you get a big, whopping sum of nothing!
/datum/chemical_reaction/water //Keeping this commented out for posterity.
	name = "Water"
	id = WATER
	result = null //I can't believe it's not water!
	required_reagents = list(OXYGEN = 2, HYDROGEN = 1) //And there goes the atmosphere, thanks greenhouse gases!
	result_amount = 1
*/

/datum/chemical_reaction/water
	name = "Water"
	id = WATER
	result = WATER
	required_reagents = list(HYDROGEN = 2, OXYGEN = 1)
	result_amount = 1

/datum/chemical_reaction/sacid
	name = "Sulphuric Acid"
	id = SACID
	result = SACID
	required_reagents = list(SULFUR = 2, OXYGEN = 3, WATER = 2)
	result_amount = 2

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = THERMITE
	result = THERMITE
	required_reagents = list(ALUMINUM = 1, IRON = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = LEXORIN
	result = LEXORIN
	required_reagents = list(PLASMA = 1, HYDROGEN = 1, NITROGEN = 1)
	result_amount = 3

/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = SPACE_DRUGS
	result = SPACE_DRUGS
	required_reagents = list(MERCURY = 1, SUGAR = 1, LITHIUM = 1)
	result_amount = 3

/datum/chemical_reaction/lube
	name = "Space Lube"
	id = LUBE
	result = LUBE
	required_reagents = list(WATER = 1, SILICON = 1, OXYGEN = 1)
	result_amount = 4

/datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	id = PACID
	result = PACID
	required_reagents = list(SACID = 1, CHLORINE = 1, POTASSIUM = 1)
	result_amount = 3

/datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = SYNAPTIZINE
	result = SYNAPTIZINE
	required_reagents = list(SUGAR = 1, LITHIUM = 1, WATER = 1)
	result_amount = 3

/datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = HYRONALIN
	result = HYRONALIN
	required_reagents = list(RADIUM = 1, ANTI_TOXIN = 1)
	result_amount = 2

/datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = ARITHRAZINE
	result = ARITHRAZINE
	required_reagents = list(HYRONALIN = 1, HYDROGEN = 1)
	result_amount = 2

/datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = IMPEDREZENE
	result = IMPEDREZENE
	required_reagents = list(MERCURY = 1, OXYGEN = 1, SUGAR = 1)
	result_amount = 2

/datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = KELOTANE
	result = KELOTANE
	required_reagents = list(SILICON = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = VIRUSFOOD
	result = VIRUSFOOD
	required_reagents = list(WATER = 5, MILK = 5)
	result_amount = 15

/datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = LEPORAZINE
	result = LEPORAZINE
	required_reagents = list(SILICON = 1, COPPER = 1)
	required_catalysts = list(PLASMA = 5)
	result_amount = 2

/datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = CRYPTOBIOLIN
	result = CRYPTOBIOLIN
	required_reagents = list(POTASSIUM = 1, OXYGEN = 1, SUGAR = 1)
	result_amount = 3

/datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = TRICORDRAZINE
	result = TRICORDRAZINE
	required_reagents = list(INAPROVALINE = 1, ANTI_TOXIN = 1)
	result_amount = 2

/datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = ALKYSINE
	result = ALKYSINE
	required_reagents = list(CHLORINE = 1, NITROGEN = 1, ANTI_TOXIN = 1)
	result_amount = 2

/datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = DEXALIN
	result = DEXALIN
	required_reagents = list(OXYGEN = 2)
	required_catalysts = list(PLASMA = 5)
	result_amount = 1

/datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = DERMALINE
	result = DERMALINE
	required_reagents = list(OXYGEN = 1, PHOSPHORUS = 1, KELOTANE = 1)
	result_amount = 3

/datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = DEXALINP
	result = DEXALINP
	required_reagents = list(DEXALIN = 1, CARBON = 1, IRON = 1)
	result_amount = 3

/datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = BICARIDINE
	result = BICARIDINE
	required_reagents = list(INAPROVALINE = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = HYPERZINE
	result = HYPERZINE
	required_reagents = list(SUGAR = 1, PHOSPHORUS = 1, SULFUR = 1,)
	result_amount = 3

/datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = RYETALYN
	result = RYETALYN
	required_reagents = list(ARITHRAZINE = 1, CARBON = 1)
	result_amount = 2

/datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = CRYOXADONE
	result = CRYOXADONE
	required_reagents = list(DEXALIN = 1, WATER = 1, OXYGEN = 1)
	result_amount = 3

/datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = CLONEXADONE
	result = CLONEXADONE
	required_reagents = list(CRYOXADONE = 1, SODIUM = 1)
	required_catalysts = list(PLASMA = 5)
	result_amount = 2

/datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = SPACEACILLIN
	result = SPACEACILLIN
	required_reagents = list(CRYPTOBIOLIN = 1, INAPROVALINE = 1)
	result_amount = 2

/datum/chemical_reaction/imidazoline
	name = IMIDAZOLINE
	id = IMIDAZOLINE
	result = IMIDAZOLINE
	required_reagents = list(CARBON = 1, HYDROGEN = 1, ANTI_TOXIN = 1)
	result_amount = 2

/datum/chemical_reaction/inacusiate
	name = INACUSIATE
	id = INACUSIATE
	result = INACUSIATE
	required_reagents = list(WATER = 1, CARBON = 1, ANTI_TOXIN = 1)
	result_amount = 3

/datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = ETHYLREDOXRAZINE
	result = ETHYLREDOXRAZINE
	required_reagents = list(OXYGEN = 1, ANTI_TOXIN = 1, CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//react in the body. Also it would be silly if it didn't exist.
	result = WATER
	required_reagents = list(ETHYLREDOXRAZINE = 1, ETHANOL = 1)
	result_amount = 2

/datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = GLYCEROL
	result = GLYCEROL
	required_reagents = list(CORNOIL = 3, SACID = 1)
	result_amount = 1

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin Explosion"
	id = NITROGLYCERIN
	result = NITROGLYCERIN
	required_reagents = list(GLYCEROL = 1, PACID = 1, SACID = 1)
	result_amount = 2
	alert_admins = ALERT_AMOUNT_ONLY

/datum/chemical_reaction/nitroglycerin/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/datum/effect/effect/system/reagents_explosion/e = new()
	e.set_up(round (created_volume/2, 1), holder.my_atom, 0, 0)
	e.holder_damage(holder.my_atom)
	if(isliving(holder.my_atom))
		e.amount *= 0.5
		var/mob/living/L = holder.my_atom
		if(L.stat!=DEAD)
			e.amount *= 0.5
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = SODIUMCHLORIDE
	result = SODIUMCHLORIDE
	required_reagents = list(SODIUM = 1, CHLORINE = 1)
	result_amount = 2

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = null
	required_reagents = list(ALUMINUM = 1, POTASSIUM = 1, SULFUR = 1)
	result_amount = null

/datum/chemical_reaction/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, location)
		s.start()

		playsound(get_turf(src), 'sound/effects/phasein.ogg', 25, 1)

		var/eye_safety = 0

		for(var/mob/living/carbon/M in viewers(get_turf(holder.my_atom), null))
			if(iscarbon(M))
				eye_safety = M.eyecheck()

			if(get_dist(M, location) <= 3)
				if(eye_safety < 1)
					M.flash_eyes(visual = 1)
					M.Weaken(15)
			else if(get_dist(M, location) <= 5)
				if(eye_safety < 1)
					M.flash_eyes(visual = 1)
					M.Stun(5)

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = null
	required_reagents = list(ALUMINUM = 1, PLASMA = 1, SACID = 1 )
	result_amount = 1

/datum/chemical_reaction/napalm/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/turf/location = get_turf(holder.my_atom.loc)

		for(var/turf/simulated/floor/target_tile in range(0,location))
			var/datum/gas_mixture/napalm = new
			var/datum/gas/volatile_fuel/fuel = new
			fuel.moles = created_volume
			napalm.trace_gases += fuel
			napalm.temperature = 400+T0C
			napalm.update_values()
			target_tile.assume_air(napalm)
			spawn(0)
				target_tile.hotspot_expose(700, 400, surfaces = 1)

	holder.del_reagent("napalm")

/datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	result = null
	required_reagents = list(POTASSIUM = 1, SUGAR = 1, PHOSPHORUS = 1)
	result_amount = null
	secondary = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/chemsmoke/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
		S.attach(location)
		S.set_up(holder, 10, 0, location)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
			sleep(10)
			S.start()
	holder.clear_reagents()

/datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = CHLORALHYDRATE
	result = CHLORALHYDRATE
	required_reagents = list(ETHANOL = 1, CHLORINE = 3, WATER = 1)
	result_amount = 1

/datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = ZOMBIEPOWDER
	result = ZOMBIEPOWDER
	required_reagents = list(CARPOTOXIN = 5, STOXIN = 5, COPPER = 5)
	result_amount = 2

/datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = REZADONE
	result = REZADONE
	required_reagents = list(CARPOTOXIN = 1, CRYPTOBIOLIN = 1, COPPER = 1)
	result_amount = 3

/datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = MINDBREAKER
	result = MINDBREAKER
	required_reagents = list(SILICON = 1, HYDROGEN = 1, ANTI_TOXIN = 1)
	result_amount = 5

/datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = "Lipozine"
	result = LIPOZINE
	required_reagents = list(SODIUMCHLORIDE = 1, ETHANOL = 1, RADIUM = 1)
	result_amount = 3

/datum/chemical_reaction/carp_pheromones
	name = "Carp pheromones"
	id = CARPPHEROMONES
	result = CARPPHEROMONES
	required_reagents = list(CARPOTOXIN = 1, LEPORAZINE = 1, CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/vaporize
	name = "Vaporize"
	id = "vaporize"
	result_amount = 52
	result = null

/datum/chemical_reaction/vaporize/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/T = get_turf(holder.my_atom)
	if(!T)
		return
	var/datum/gas_mixture/G = new
	G.temperature = T20C
	disperse(T,G,created_volume)

/datum/chemical_reaction/vaporize/proc/disperse(turf/T,datum/gas_mixture/G,var/vol)
	T.assume_air(G)

/datum/chemical_reaction/vaporize/oxygen
	name = "Vaporize Oxygen"
	id = "vaporizeoxygen"
	required_reagents = list(VAPORSALT = 1, OXYGEN = 1)

/datum/chemical_reaction/vaporize/oxygen/disperse(turf/T,datum/gas_mixture/G,var/vol)
	G.adjust(vol,0,0,0)
	..()

/datum/chemical_reaction/vaporize/nitrogen
	name = "Vaporize Nitrogen"
	id = "vaporizenitrogen"
	required_reagents = list(VAPORSALT = 1, NITROGEN = 1)

/datum/chemical_reaction/vaporize/nitrogen/disperse(turf/T,datum/gas_mixture/G,var/vol)
	G.adjust(0,0,vol,0)
	..()

/datum/chemical_reaction/vaporize/plasma
	name = "Vaporize Plasma"
	id = "vaporizeplasma"
	result_amount = 5 //Let's not go overboard with the plasma, alright?
	required_reagents = list(VAPORSALT = 1, PLASMA = 1)

/datum/chemical_reaction/vaporize/plasma/disperse(turf/T,datum/gas_mixture/G,var/vol)
	G.adjust(0,0,0,vol)
	..()

/datum/chemical_reaction/plasmasolidification
	name = "Solid Plasma"
	id = "solidplasma"
	result = null
	required_reagents = list(IRON = 5, FROSTOIL = 5, PLASMA = 20)
	result_amount = 1

/datum/chemical_reaction/plasmasolidification/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/stack/sheet/mineral/plasma(location)

/datum/chemical_reaction/plastication
	name = "Plastic"
	id = "solidplastic"
	result = null
	required_reagents = list(PACID = 10, PLASTICIDE = 20)
	result_amount = 1

/datum/chemical_reaction/plastication/on_reaction(var/datum/reagents/holder)
	new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom), 10)

/datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = CONDENSEDCAPSAICIN
	result = CONDENSEDCAPSAICIN
	required_reagents = list(CAPSAICIN = 1, ETHANOL = 5)
	result_amount = 5

/datum/chemical_reaction/methylin
	name = "Methylin"
	id = METHYLIN
	result = METHYLIN
	required_reagents = list(HYDROGEN = 1, CHLORINE = 1, ETHANOL = 1)
	required_catalysts = list(FLUORINE = 5)
	result_amount = 1

/datum/chemical_reaction/explosion_bicarodyne
	name = "Explosion"
	id = "explosion_bicarodyne"
	result = null
	required_reagents = list(BICARODYNE = 1, PARACETAMOL = 1)
	result_amount = 1

/datum/chemical_reaction/explosion_bicarodyne/on_reaction(var/datum/reagents/holder, var/created_volume)
	explosion(get_turf(holder.my_atom),1,2,4)
	holder.clear_reagents()

/datum/chemical_reaction/nanobots
	name = "Nanobots"
	id = NANOBOTS
	result = NANOBOTS
	required_reagents = list(NANITES = 1, URANIUM = 10, GOLD = 10, NUTRIMENT = 10, SILICON = 10)
	result_amount = 2

/datum/chemical_reaction/nanobots2
	name = "Nanobots2"
	id = "nanobots2"
	result = NANOBOTS
	required_reagents = list(MEDNANOBOTS = 1, CRYOXADONE = 2)
	result_amount = 1

/datum/chemical_reaction/mednanobots
	name = "Medical Nanobots"
	id = MEDNANOBOTS
	result = MEDNANOBOTS
	required_reagents = list(NANOBOTS = 1, DOCTORSDELIGHT = 5)
	result_amount = 1

/datum/chemical_reaction/comnanobots
	name = "Combat Nanobots"
	id = COMNANOBOTS
	result = COMNANOBOTS
	required_reagents = list(NANOBOTS = 1, MUTAGEN = 5, SILICATE = 5, IRON = 10)
	result_amount = 1

///////////////////////////////////////////////////////////////////////////////////

//Foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = FLUOROSURFACTANT
	required_reagents = list(FLUORINE = 2, CARBON = 2, SACID = 1)
	result_amount = 5


/datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list(FLUOROSURFACTANT = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)
		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution violently bubbles!</span>")

		location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution spews out foam!</span>")

		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 0)
		s.start()
	holder.clear_reagents()

/datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list(ALUMINUM = 3, FOAMING_AGENT = 1, PACID = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution spews out a metallic foam!</span>")

		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 1)
		s.start()

/datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list(IRON = 3, FOAMING_AGENT = 1, PACID = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		var/location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution spews out a metallic foam!</span>")

		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 2)
		s.start()

/datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = FOAMING_AGENT
	result = FOAMING_AGENT
	required_reagents = list(LITHIUM = 1, HYDROGEN = 1)
	result_amount = 1

//Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = AMMONIA
	result = AMMONIA
	required_reagents = list(HYDROGEN = 3, NITROGEN = 1)
	result_amount = 3

/datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = DIETHYLAMINE
	result = DIETHYLAMINE
	required_reagents = list (AMMONIA = 1, ETHANOL = 1)
	result_amount = 2

/datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = CLEANER
	result = CLEANER
	required_reagents = list(AMMONIA = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = PLANTBGONE
	result = PLANTBGONE
	required_reagents = list(TOXIN = 1, WATER = 4)
	result_amount = 5

//Special reaction for mimic meat: injecting it with 5 units of blood causes it to turn into a random food item. Makes more sense than hitting it with a fking rolling pin
/datum/chemical_reaction/mimicshift
	name = "Shapeshift"
	id = "mimic_meat_shift"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/weapon/reagent_containers/food/snacks/meat/mimic

/datum/chemical_reaction/mimicshift/on_reaction(var/datum/reagents/holder)
	if(istype(holder.my_atom, /obj/item/weapon/reagent_containers/food/snacks/meat/mimic))
		var/obj/item/weapon/reagent_containers/food/snacks/meat/mimic/M = holder.my_atom
		M.shapeshift()

		if(ismob(holder.my_atom.loc))
			var/mob/mob_holder = holder.my_atom.loc
			mob_holder.drop_item(holder.my_atom) //Bandaid to work around items becoming invisible when their appearance is changed!

/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

//Grey
/datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimespawn/on_reaction(var/datum/reagents/holder)
	if(!is_in_airtight_object(holder.my_atom)) //Don't pop while ventcrawling.
		feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

		if(istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
			holder.my_atom.visible_message("<span class='rose'>The grenade bursts open and a new baby slime emerges from it!</span>")
		else
			holder.my_atom.visible_message("<span class='rose'>Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")

		var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
		S.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimemonkey/on_reaction(var/datum/reagents/holder)
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)

//Green
/datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = MUTATIONTOXIN
	result = MUTATIONTOXIN
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/green

/datum/chemical_reaction/slimeperidaxon
	name = "Slime Peridaxon"
	id = "m_peridaxon"
	result = null
	required_reagents = list(WATER = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/green
	required_other = 1

/datum/chemical_reaction/slimeperidaxon/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
	B.name = "peridaxon bottle"
	B.reagents.add_reagent(PERIDAXON, 5)
	B.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimedexplus
	name = "Slime Dexalin Plus"
	id = "m_dexplus"
	result = null
	required_reagents = list(OXYGEN = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/green
	required_other = 1

/datum/chemical_reaction/slimedexplus/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
	B.name = "Dexalin Plus Bottle"
	B.reagents.add_reagent(DEXALINP, 5)
	B.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimesdelight
	name = "Slime Doctor's Delight"
	id = "m_doctordelight"
	result = null
	required_reagents = list(SUGAR = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/green
	required_other = 1

/datum/chemical_reaction/slimesdelight/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
	B.name = "Doctor's Delight bottle"
	B.reagents.add_reagent(DOCTORSDELIGHT, 10)
	B.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimebicard
	name = "Slime Bicaridine"
	id = "m_bicaridine"
	result = null
	required_reagents = list(CARBON = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/green
	required_other = 1

/datum/chemical_reaction/slimebicard/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
	B.name = "bicaridine bottle"
	B.reagents.add_reagent(BICARIDINE, 10)
	B.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimedermaline
	name = "Slime Dermaline"
	id = "m_dermaline"
	result = null
	required_reagents = list(PHOSPHORUS = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/green
	required_other = 1

/datum/chemical_reaction/slimedermaline/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/reagent_containers/glass/bottle/B = new /obj/item/weapon/reagent_containers/glass/bottle
	B.name = "Dermaline bottle"
	B.reagents.add_reagent(DERMALINE, 5)
	B.loc = get_turf(holder.my_atom)

//Metal
/datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimemetal/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(holder.my_atom))
	M.amount = 15
	var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
	P.amount = 5
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimegold
	name = "Slime Gold"
	id = "m_gold"
	result = null
	required_reagents = list(COPPER = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimegold/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold
	G.amount = 5
	G.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimesilver
	name = "Slime Silver"
	id = "m_silver"
	result = null
	required_reagents = list(TUNGSTEN = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimesilver/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/silver/S = new /obj/item/stack/sheet/mineral/silver
	S.amount = 5
	S.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeuranium
	name = "Slime Uranium"
	id = "m_uranium"
	result = null
	required_reagents = list(RADIUM = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimeuranium/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/uranium/U = new /obj/item/stack/sheet/mineral/uranium
	U.amount = 5
	U.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimediamond
	name = "Slime diamond"
	id = "m_diamond"
	result = null
	required_reagents = list(CARBON = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimediamond/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/mineral/diamond/K = new /obj/item/stack/sheet/mineral/diamond
	K.amount = 2
	K.loc = get_turf(holder.my_atom)


//Gold
/datum/chemical_reaction/slimecrit
	name = "Slime Crit (Summon Monsters)"
	id = "m_tele"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimecrit/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(!istype(holder.my_atom.loc, /obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)

	var/blocked = list(
		/mob/living/simple_animal/hostile/alien/queen/large,
		/mob/living/simple_animal/hostile/faithless,
		/mob/living/simple_animal/hostile/faithless/cult,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/carp/holocarp,
		/mob/living/simple_animal/hostile/slime,
		/mob/living/simple_animal/hostile/mining_drone,
		/mob/living/simple_animal/hostile/mimic,
		/mob/living/simple_animal/hostile/mimic/crate,
		/mob/living/simple_animal/hostile/mimic/crate/chest,
		/mob/living/simple_animal/hostile/mimic/crate/item,
		) + typesof(/mob/living/simple_animal/hostile/humanoid) + typesof(/mob/living/simple_animal/hostile/asteroid) //Exclusion list for things you don't want the reaction to create.

	var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - blocked //List of possible hostile mobs

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='danger'>A flash blinds you while you start hearing terrifying noises!</span>")
			else
				to_chat(O, "<span class='danger'>You hear a rumbling as a troup of monsters phases into existence!</span>")
		else
			to_chat(O, "<span class='danger'>You hear a rumbling as a troup of monsters phases into existence!</span>")

	for(var/i = 1, i <= 5, i++)
		var/chosen = pick(critters)
		var/mob/living/simple_animal/hostile/C = new chosen(get_turf(holder.my_atom))
		C.faction = "slimesummon"
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimecritlesser
	name = "Slime Crit Lesser (Summon Monsters)"
	id = "m_tele3"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimecritlesser/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(!istype(holder.my_atom.loc, /obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		sleep(50)

	var/blocked = list(
		/mob/living/simple_animal/hostile/alien/queen/large,
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/carp/holocarp,
		/mob/living/simple_animal/hostile/faithless/cult,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/slime,
		/mob/living/simple_animal/hostile/hivebot/tele, //This thing spawns hostile mobs
		/mob/living/simple_animal/hostile/mining_drone,
		) + typesof(/mob/living/simple_animal/hostile/humanoid) + typesof(/mob/living/simple_animal/hostile/asteroid) //Exclusion list for things you don't want the reaction to create.
	var/list/critters = existing_typesof(/mob/living/simple_animal/hostile) - blocked //List of possible hostile mobs

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='rose'>A flash blinds and you can feel a new presence!</span>")
			else
				to_chat(O, "<span class='rose'>You hear a crackling as a creature manifests before you!</span>")
		else
			to_chat(O, "<span class='rose'>You hear a crackling as a creature manifests before you!</span>")

	var/chosen = pick(critters)
	var/mob/living/simple_animal/hostile/C = new chosen
	C.faction = "neutral" //Uh, beepsky ignores mobs in this faction as of Redmine #147 - N3X
	C.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimecritweak
	name = "Slime Animation"
	id = "m_tele4"
	result = null
	required_reagents = list(WATER = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimecritweak/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(!istype(holder.my_atom.loc, /obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to slowly vibrate!</span>")

	spawn(50)
		var/atom/location = holder.my_atom.loc
		if(isturf(location))
			var/list/disguise_candidates = list()

			for(var/obj/item/I in oview(4, holder.my_atom))
				disguise_candidates += I

			var/atom/disguise = null

			if(disguise_candidates.len)
				disguise = pick(disguise_candidates)

			//If there are no nearby items to copy, become a completely random item!
			new/mob/living/simple_animal/hostile/mimic/crate/item(location, disguise) //Create a mimic identical to a nearby item

		else if(istype(location, /obj/structure/closet))
			var/mob/living/simple_animal/hostile/mimic/crate/new_mimic = new(get_turf(location), location.type)
			new_mimic.appearance = location.appearance //Create a crate mimic that looks exactly like the closet!

			for(var/atom/movable/AM in location.contents)
				AM.forceMove(new_mimic) //Move all items from the closet/crate to the new mimic

			qdel(location) //Delete the old closet

		else if(istype(location, /obj/item))
			new /mob/living/simple_animal/hostile/mimic/crate/item(get_turf(location), location) //Copy the item we're inside of, drop it outside the item!

		else if(ismob(location)) //Copy the mob! Owwwwwwwwwww this is going to be fun
			var/mob/M = location

			var/mob/mimic = new /mob/living/simple_animal/hostile/mimic/crate(get_turf(location), location)
			mimic.appearance = M.appearance //Because mimics copy appearances from paths, not actual existing objects.
			to_chat(M, "<span class='sinister'>You feel something thoroughly analyzing you from inside...</span>")

		else
			new /mob/living/simple_animal/hostile/mimic/crate

//Silver
/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork/on_reaction(var/datum/reagents/holder)
	var/blocked = list(
		/obj/item/weapon/reagent_containers/food/snacks,
		/obj/item/weapon/reagent_containers/food/snacks/snackbar,
		/obj/item/weapon/reagent_containers/food/snacks/grown,
		)
	blocked += typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable) //Silver-slime spawned customizable food is borked

	var/list/borks = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked

	//BORK BORK BORK
	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='caution'>A white light blinds you and you think you can smell some food nearby!</span>")
			else
				to_chat(O, "<span class='notice'>A bunch of snacks appears before your very eyes!</span>")
		else
			to_chat(O, "<span class='notice'>A bunch of snacks appears before your very eyes!</span>")

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)

			if(istype(B,/obj/item/weapon/reagent_containers/food/snacks/meat/human))
				B.name = "human-meat"
			if(istype(B,/obj/item/weapon/reagent_containers/food/snacks/human))
				B.name = "human-meat burger"
			if(istype(B,/obj/item/weapon/reagent_containers/food/snacks/fortunecookie))
				var/obj/item/weapon/paper/paper = new /obj/item/weapon/paper(B)
				paper.info = pick("power to the slimes", "have a slime day", "today, you will meet a very special slime", "stay away from cold showers")
				var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/cookie = B
				cookie.trash = paper

			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimedrinks
	name = "Slime Drinks"
	id = "m_tele3"
	result = null
	required_reagents = list(WATER = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimedrinks/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

	var/blocked = list(
		/obj/item/weapon/reagent_containers/food/drinks,
		)
	blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)	//Silver-slime spawned customizable food is borked
	blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/golden_cup) //Was probably never intended to spawn outside admin events

	var/list/borks = existing_typesof(/obj/item/weapon/reagent_containers/food/drinks) - blocked

	//BORK BORK BORK
	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if(ishuman(O))
			var/mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0) && (!istype(H.glasses, /obj/item/clothing/glasses/science)))
				H.flash_eyes(visual = 1)
				to_chat(O, "<span class='caution'>A white light blinds you and you think you can hear bottles rolling on the floor!</span>")
			else
				to_chat(O, "<span class='notice'>A bunch of drinks appears before you!</span>")
		else
			to_chat(O, "<span class='notice'>A bunch of drinks appears before you!</span>")

	for(var/i = 1, i <= 4 + rand(1, 2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen

		if(B)
			B.loc = get_turf(holder.my_atom)

			if(istype(B,/obj/item/weapon/reagent_containers/food/drinks/sillycup))
				B.reagents.add_reagent(WATER, 10)

			if(istype(B,/obj/item/weapon/reagent_containers/food/drinks/flask))
				B.reagents.add_reagent(WHISKEY, 60)

			if(istype(B,/obj/item/weapon/reagent_containers/food/drinks/shaker))
				B.reagents.add_reagent(GARGLEBLASTER, 100)

			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimematerials
	name = "Slime Materials"
	id = "m_mats"
	result = null
	required_reagents = list(CARBON = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimematerials/on_reaction(var/datum/reagents/holder)
	var/list/paths = list(/obj/item/stack/sheet/plasteel,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/mineral/plasma,
			/obj/item/stack/sheet/mineral/silver,
			/obj/item/stack/sheet/mineral/gold,
			/obj/item/stack/sheet/mineral/uranium)
	getFromPool(pick(paths), get_turf(holder.my_atom), 5)
	getFromPool(pick(paths), get_turf(holder.my_atom), 5)


//Blue
/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = FROSTOIL
	required_reagents = list(PLASMA = 5)
	result_amount = 10
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slimefrost/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

//Dark Blue
/datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimefreeze/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
		M.bodytemperature -= 6
		to_chat(M, "<span class='notice'>You feel a chill!</span>")

/datum/chemical_reaction/slimenutrient
	name = "Slime Nutrient"
	id = "m_nutrient"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slimenutrient/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimenutrient/P = new /obj/item/weapon/slimenutrient
	P.loc = get_turf(holder.my_atom)

//Orange
/datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	result = CAPSAICIN
	required_reagents = list(BLOOD = 5)
	result_amount = 10
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimecasp/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

/datum/chemical_reaction/slimefire
	name = "Slime Napalm"
	id = "m_fire"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/orange
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimefire/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)

	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0, location))

		var/datum/gas_mixture/napalm = new
		napalm.toxins = 25
		napalm.temperature = 1400
		target_tile.assume_air(napalm)
		spawn(0)
			target_tile.hotspot_expose(700, 400,surfaces = 1)

//Yellow
/datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimeoverload/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	empulse(get_turf(holder.my_atom), 3, 7)

/datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimecell/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/cell/slime/P = new /obj/item/weapon/cell/slime
	P.loc = get_turf(holder.my_atom)

//Was a broken recipe that was supposed to make the extract produce some light
//I changed it, so it now creates an /obj/item/device/flashlight/lamp/slime
//Basically a lamp with two brightness settings. light slightly yellow
/datum/chemical_reaction/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	result = null
	required_reagents = list(WATER = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeglow/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/device/flashlight/lamp/slime/P = new /obj/item/device/flashlight/lamp/slime
	P.loc = get_turf(holder.my_atom)

//Purple
/datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimepsteroid/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = SLIMEJELLY
	required_reagents = list(SUGAR = 5)
	result_amount = 10
	required_container = /obj/item/slime_extract/purple
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimejam/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name, " ", "_")]")

//Dark Purple
/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slimeplasma/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
	P.amount = 10
	P.loc = get_turf(holder.my_atom)

//Red
/datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	result = GLYCEROL
	required_reagents = list(PLASMA = 5)
	result_amount = 8
	required_container = /obj/item/slime_extract/red
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimeglycerol/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

/datum/chemical_reaction/slimeres
	name = "Slime Res"
	id = "m_nutrient"
	result = null
	required_reagents = list(SUGAR = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimeres/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimeres/P = new /obj/item/weapon/slimeres
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimebloodlust/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

	for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>\The [slime] is driven into a frenzy!</span>")
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>\The [slime] is driven into a frenzy!</span>")

//Pink
/datum/chemical_reaction/slimeppotion
	name = "Slime Potion"
	id = "m_potion"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/slimeppotion/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
	P.loc = get_turf(holder.my_atom)

//Black
/datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	result = AMUTATIONTOXIN
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimemutate2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

/datum/chemical_reaction/slimemednanobots
	name = "Slime Medical Nanobots"
	id = "m_mednanobots"
	result = MEDNANOBOTS
	required_reagents = list(GOLD = 5)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimemednanobots/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

/datum/chemical_reaction/slimecomnanobots
	name  = "Slime Combat Nanobots"
	id = "m_comnanobots"
	result = COMNANOBOTS
	required_reagents = list(URANIUM = 5)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimecomnanobots/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

//Oil
/datum/chemical_reaction/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimeexplosion/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently!</span>")
		sleep(50)
	explosion(get_turf(holder.my_atom), 1 ,3, 6)

/datum/chemical_reaction/slimegenocide
	name = "Slime Genocide" //Oy vey
	id = "m_genocide"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimegenocide/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	for(var/mob/living/carbon/slime/S in viewers(get_turf(holder.my_atom), null)) //Kills slimes
		S.death(0)
	for(var/mob/living/simple_animal/slime/S in viewers(get_turf(holder.my_atom), null)) //Kills pet slimes too
		S.death(0)

//Light Pink
/datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(PLASMA = 5)
	required_other = 1

/datum/chemical_reaction/slimepotion2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeparalyze
	name = "Slime Paralyzer"
	id = "slimepara"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list(BLOOD = 5)
	required_other = 1

/datum/chemical_reaction/slimeparalyze/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	new /obj/item/weapon/slimeparapotion(get_turf(holder.my_atom))

//Adamantine
/datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slimegolem/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/effect/golem_rune/Z = new /obj/effect/golem_rune
	Z.loc = get_turf(holder.my_atom)
	Z.announce_to_ghosts()

/datum/chemical_reaction/slimediamond2
	name = "Slime Diamond2"
	id = "m_Diamond2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_reagents = list(CARBON = 5)
	required_other = 1

/datum/chemical_reaction/slimediamond2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/stack/sheet/mineral/diamond/D = new /obj/item/stack/sheet/mineral/diamond
	D.amount = 5
	D.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimephazon
	name = "Slime Phazon"
	id = "m_Phazon"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_reagents = list(GOLD = 5)
	required_other = 1

/datum/chemical_reaction/slimephazon/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/stack/sheet/mineral/phazon/P = new /obj/item/stack/sheet/mineral/phazon
	P.amount = 5
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeclown
	name = "Slime Clown"
	id = "m_Clown"
	result = null
	required_reagents = list(SILVER = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slimeclown/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/stack/sheet/mineral/clown/C = new /obj/item/stack/sheet/mineral/clown
	C.amount = 5
	C.loc = get_turf(holder.my_atom)

//Bluespace
/datum/chemical_reaction/slimeteleport
	name = "Slime Teleport"
	id = "m_tele"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1
	alert_admins = ALERT_ALL_REAGENTS

/datum/chemical_reaction/slimeteleport/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")

	//Calculate new position (searches through beacons in world)
	var/obj/item/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/beacon/W in beacons)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(chosen)

		//Calculate previous position for transition
		var/turf/from = get_turf(holder.my_atom) //The turf of origin we're travelling from
		var/turf/towards = get_turf(chosen)			 //The turf of origin we're travelling towards

		playsound(towards, 'sound/effects/phasein.ogg', 100, 1)

		var/list/flashers = list()
		for(var/mob/living/carbon/human/M in viewers(towards, null))
			if((M.eyecheck() <= 0) && (!istype(M.glasses, /obj/item/clothing/glasses/science)))
				M.flash_eyes(visual = 1)
				flashers += M

		var/y_distance = towards.y - from.y
		var/x_distance = towards.x - from.x
		for(var/atom/movable/A in range(4, from)) //Iterate thru list of mobs in the area
			if(istype(A, /obj/item/beacon)) //Don't teleport beacons because that's just insanely stupid
				continue
			if(A.anchored)
				continue
			if(istype(A, /obj/structure/cable))
				continue

			var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, towards.z) //Calculate the new place
			if(!A.Move(newloc)) //If the atom, for some reason, can't move, force them to move! We try Move() first to invoke any movement-related checks the atom needs to perform after moving
				A.loc = locate(A.x + x_distance, A.y + y_distance, towards.z)

			spawn()
				if(ismob(A) && !(A in flashers)) //Don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						var/obj/blueeffect = new /obj(src)
						blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
						blueeffect.icon = 'icons/effects/effects.dmi'
						blueeffect.icon_state = "shieldsparkles"
						blueeffect.layer = 17
						blueeffect.mouse_opacity = 0
						M.client.screen += blueeffect
						sleep(20)
						M.client.screen -= blueeffect
						qdel(blueeffect)
						blueeffect = null

/datum/chemical_reaction/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimecrystal/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	if(holder.my_atom)
		var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>\The [BC] appears out of thin air!</span>")

//Cerulean
/datum/chemical_reaction/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slimepsteroid2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimedupe
	name = "Slime Duplicator"
	id = "m_dupe"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slimedupe/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/weapon/slimedupe/P = new /obj/item/weapon/slimedupe
	P.loc = get_turf(holder.my_atom)

//Sepia
/datum/chemical_reaction/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimecamera/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/device/camera/sepia/P = new /obj/item/device/camera/sepia
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimefilm
	name = "Slime Film"
	id = "m_film"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimefilm/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
	P.loc = get_turf(holder.my_atom)

//Pyrite
/datum/chemical_reaction/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	result = null
	required_reagents = list(PLASMA = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slimepaint/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used", "[replacetext(name, " ", "_")]")
	var/list/paints = typesof(/obj/item/weapon/reagent_containers/glass/paint) - /obj/item/weapon/reagent_containers/glass/paint
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimecash
	name = "Slime Cash"
	id = "m_cash"
	result = null
	required_reagents = list(BLOOD = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slimecash/on_reaction(var/datum/reagents/holder)
	var/obj/item/weapon/spacecash/c100/C = new /obj/item/weapon/spacecash/c100/
	C.amount = 1
	C.loc = get_turf(holder.my_atom)

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/enzyme
	name = "Universal Enzyme"
	id = ENZYME
	result = ENZYME
	required_reagents = list(SODIUMCHLORIDE = 1, NUTRIMENT = 1, BLOOD = 1)
	result_amount = 1

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list(SOYMILK = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list(SOYMILK = 2, COCO = 2, SUGAR = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list(MILK = 2, COCO = 2, SUGAR = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = HOT_COCO
	result = HOT_COCO
	required_reagents = list(WATER = 5, COCO = 1)
	result_amount = 5

/*
/datum/chemical_reaction/coffee
	name = "Coffee"
	id = COFFEE
	result = COFFEE
	required_reagents = list("coffeepowder" = 1, WATER = 5)
	result_amount = 5

/datum/chemical_reaction/tea
	name = "Tea"
	id = TEA
	result = TEA
	required_reagents = list("teapowder" = 1, WATER = 5)
	result_amount = 5
*/

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = SOYSAUCE
	result = SOYSAUCE
	required_reagents = list(SOYMILK = 4, SACID = 1)
	result_amount = 5

/datum/chemical_reaction/vinegar
	name = "Malt Vinegar"
	id = VINEGAR
	result = VINEGAR
	required_reagents = list(ETHANOL = 5)
	required_catalysts = list(ENZYME = 1)
	result_amount = 5

/datum/chemical_reaction/sprinkles
	name = "Sprinkles"
	id = SPRINKLES
	result = SPRINKLES
	required_reagents = list(SUGAR = 5)
	required_catalysts = list(ENZYME = 1)
	result_amount = 5

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list(MILK = 40)
	required_catalysts = list(ENZYME = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)

//Jesus christ how horrible
/datum/chemical_reaction/cream
	name = "Cream"
	id = CREAM
	result = CREAM
	required_reagents = list(MILK = 10,SACID = 1)
	result_amount = 5

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list(BLOOD = 5, CLONEXADONE = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = HOT_RAMEN
	result = HOT_RAMEN
	required_reagents = list(WATER = 1, DRY_RAMEN = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = HELL_RAMEN
	result = HELL_RAMEN
	required_reagents = list(CAPSAICIN = 1, HOT_RAMEN = 6)
	result_amount = 6

////////////////////////////////////////// COCKTAILS //////////////////////////////////////

/datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = GOLDSCHLAGER
	result = GOLDSCHLAGER
	required_reagents = list(VODKA = 10, GOLD = 1)
	result_amount = 10

/datum/chemical_reaction/patron
	name = "Patron"
	id = PATRON
	result = PATRON
	required_reagents = list(TEQUILA = 10, SILVER = 1)
	result_amount = 10

/datum/chemical_reaction/bilk
	name = "Bilk"
	id = BILK
	result = BILK
	required_reagents = list(MILK = 1, BEER = 1)
	result_amount = 2

/datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = ICETEA
	result = ICETEA
	required_reagents = list(ICE = 1, TEA = 3)
	result_amount = 4

/datum/chemical_reaction/arnoldpalmer
	name = "Arnold Palmer"
	id = ARNOLDPALMER
	result = ARNOLDPALMER
	required_reagents = list(LEMONADE = 1, ICETEA = 1)
	result_amount = 2

/datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = ICECOFFEE
	result = ICECOFFEE
	required_reagents = list(ICE = 1, COFFEE = 3)
	result_amount = 4

/datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = NUKA_COLA
	result = NUKA_COLA
	required_reagents = list(URANIUM = 1, COLA = 6)
	result_amount = 6

/datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = MOONSHINE
	result = MOONSHINE
	required_reagents = list(CORNOIL = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/wine
	name = "Wine"
	id = WINE
	result = WINE
	required_reagents = list(BERRYJUICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/pinacolada
	name = "Pina Colada"
	id = PINACOLADA
	result = PINACOLADA
	required_reagents = list(RUM = 2, ICE = 1, CREAM = 1)
	result_amount = 4

/datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	result = BEER
	required_reagents = list(FLOUR = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/vodka
	name = "Vodka"
	id = VODKA
	result = VODKA
	required_reagents = list(POTATO = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/sake
	name = "Sake"
	id = SAKE
	result = SAKE
	required_reagents = list(RICE = 10)
	required_catalysts = list(ENZYME = 5)
	result_amount = 10

/datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = KAHLUA
	result = KAHLUA
	required_reagents = list(COFFEE = 5, SUGAR = 5)
	required_catalysts = list(ENZYME = 5)
	result_amount = 5

/datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = GINTONIC
	result = GINTONIC
	required_reagents = list(GIN = 2, TONIC = 1)
	result_amount = 3

/datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = CUBALIBRE
	result = CUBALIBRE
	required_reagents = list(RUM = 2, COLA = 1)
	result_amount = 3

/datum/chemical_reaction/martini
	name = "Classic Martini"
	id = MARTINI
	result = MARTINI
	required_reagents = list(GIN = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = VODKAMARTINI
	result = VODKAMARTINI
	required_reagents = list(VODKA = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/white_russian
	name = "White Russian"
	id = WHITERUSSIAN
	result = WHITERUSSIAN
	required_reagents = list(BLACKRUSSIAN = 3, CREAM = 2)
	result_amount = 5

/datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = WHISKEYCOLA
	result = WHISKEYCOLA
	required_reagents = list(WHISKEY = 2, COLA = 1)
	result_amount = 3

/datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = SCREWDRIVERCOCKTAIL
	result = SCREWDRIVERCOCKTAIL
	required_reagents = list(VODKA = 2, ORANGEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = BLOODYMARY
	result = BLOODYMARY
	required_reagents = list(VODKA = 1, TOMATOJUICE = 2, LIMEJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = GARGLEBLASTER
	result = GARGLEBLASTER
	required_reagents = list(VODKA = 1, GIN = 1, WHISKEY = 1, COGNAC = 1, LIMEJUICE = 1)
	result_amount = 5

/datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = BRAVEBULL
	result = BRAVEBULL
	required_reagents = list(TEQUILA = 2, KAHLUA = 1)
	result_amount = 3

/datum/chemical_reaction/tequila_sunrise
	name = "Tequila Sunrise"
	id = TEQUILASUNRISE
	result = TEQUILASUNRISE
	required_reagents = list(TEQUILA = 2, ORANGEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/toxins_special
	name = "Toxins Special"
	id = TOXINSSPECIAL
	result = TOXINSSPECIAL
	required_reagents = list(RUM = 2, VERMOUTH = 1, PLASMA = 2)
	result_amount = 5

/datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	result = BEEPSKYSMASH
	required_reagents = list(LIMEJUICE = 2, WHISKEY = 2, IRON = 1)
	result_amount = 4

/datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	result = DOCTORSDELIGHT
	required_reagents = list(LIMEJUICE = 1, TOMATOJUICE = 1, ORANGEJUICE = 1, CREAM = 1, TRICORDRAZINE = 1)
	result_amount = 5

/datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = IRISHCREAM
	result = IRISHCREAM
	required_reagents = list(WHISKEY = 2, CREAM = 1)
	result_amount = 3

/datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = MANLYDORF
	result = MANLYDORF
	required_reagents = list (BEER = 1, ALE = 2)
	result_amount = 3

/datum/chemical_reaction/hooch
	name = "Hooch"
	id = HOOCH
	result = HOOCH
	required_reagents = list (SUGAR = 1, ETHANOL = 2, FUEL = 1)
	result_amount = 3

/datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = IRISHCOFFEE
	result = IRISHCOFFEE
	required_reagents = list(IRISHCREAM = 1, COFFEE = 1)
	result_amount = 2

/datum/chemical_reaction/b52
	name = "B-52"
	id = B52
	result = B52
	required_reagents = list(IRISHCARBOMB = 1, KAHLUA = 1, COGNAC = 1)
	result_amount = 3

/datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = ATOMICBOMB
	result = ATOMICBOMB
	required_reagents = list(B52 = 10, URANIUM = 1)
	result_amount = 10

/datum/chemical_reaction/margarita
	name = "Margarita"
	id = MARGARITA
	result = MARGARITA
	required_reagents = list(TEQUILA = 2, LIMEJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = LONGISLANDICEDTEA
	result = LONGISLANDICEDTEA
	required_reagents = list(VODKA = 1, GIN = 1, TEQUILA = 1, CUBALIBRE = 1, ICE = 1)
	result_amount = 5

/datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = THREEMILEISLAND
	result = THREEMILEISLAND
	required_reagents = list(LONGISLANDICEDTEA = 10, URANIUM = 1)
	result_amount = 10

/datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = WHISKEYSODA
	result = WHISKEYSODA
	required_reagents = list(WHISKEY = 2, SODAWATER = 1)
	result_amount = 3

/datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = BLACKRUSSIAN
	result = BLACKRUSSIAN
	required_reagents = list(VODKA = 3, KAHLUA = 2)
	result_amount = 5

/datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = MANHATTAN
	result = MANHATTAN
	required_reagents = list(WHISKEY = 2, VERMOUTH = 1)
	result_amount = 3

/datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	result = "manhattan_proj"
	required_reagents = list(MANHATTAN = 10, URANIUM = 1)
	result_amount = 10

/datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = VODKATONIC
	result = VODKATONIC
	required_reagents = list(VODKA = 2, TONIC = 1)
	result_amount = 3

/datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = GINFIZZ
	result = GINFIZZ
	required_reagents = list(GIN = 2, SODAWATER = 1, LIMEJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = BAHAMA_MAMA
	result = BAHAMA_MAMA
	required_reagents = list(RUM = 2, ORANGEJUICE = 2, LIMEJUICE = 1, ICE = 1)
	result_amount = 6

/datum/chemical_reaction/singulo
	name = "Singulo"
	id = SINGULO
	result = SINGULO
	required_reagents = list(VODKA = 5, RADIUM = 1, WINE = 5)
	result_amount = 10

/datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = ALLIESCOCKTAIL
	result = ALLIESCOCKTAIL
	required_reagents = list(MARTINI = 1, VODKA = 1)
	result_amount = 2

/datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = DEMONSBLOOD
	result = DEMONSBLOOD
	required_reagents = list(RUM = 1, SPACEMOUNTAINWIND = 1, BLOOD = 1, DR_GIBB = 1)
	result_amount = 4

/datum/chemical_reaction/booger
	name = "Booger"
	id = BOOGER
	result = BOOGER
	required_reagents = list(CREAM = 1, BANANA = 1, RUM = 1, WATERMELONJUICE = 1)
	result_amount = 4

/datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = ANTIFREEZE
	result = ANTIFREEZE
	required_reagents = list(VODKA = 2, CREAM = 1, ICE = 1)
	result_amount = 4

/datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = BAREFOOT
	result = BAREFOOT
	required_reagents = list(BERRYJUICE = 1, CREAM = 1, VERMOUTH = 1)
	result_amount = 3

////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

/datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = SBITEN
	result = SBITEN
	required_reagents = list(VODKA = 10, CAPSAICIN = 1)
	result_amount = 10

/datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = RED_MEAD
	result = RED_MEAD
	required_reagents = list(BLOOD = 1, MEAD = 1)
	result_amount = 2

/datum/chemical_reaction/mead
	name = "Mead"
	id = MEAD
	result = MEAD
	required_reagents = list(SUGAR = 1, WATER = 1)
	required_catalysts = list(ENZYME = 5)
	result_amount = 2

/datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = ICED_BEER
	result = ICED_BEER
	required_reagents = list(BEER = 10, FROSTOIL = 1)
	result_amount = 10

/datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = ICED_BEER
	result = ICED_BEER
	required_reagents = list(BEER = 5, ICE = 1)
	result_amount = 6

/datum/chemical_reaction/grog
	name = "Grog"
	id = GROG
	result = GROG
	required_reagents = list(RUM = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = SOY_LATTE
	result = SOY_LATTE
	required_reagents = list(ESPRESSO = 1, SOYMILK = 1)
	result_amount = 2

/datum/chemical_reaction/cafe_latte
	name = "Latte"
	id = CAFE_LATTE
	result = CAFE_LATTE
	required_reagents = list(ESPRESSO = 1, MILK = 1)
	result_amount = 2

/datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = ACIDSPIT
	result = ACIDSPIT
	required_reagents = list(SACID = 1, WINE = 5)
	result_amount = 6

/datum/chemical_reaction/amasec
	name = "Amasec"
	id = AMASEC
	result = AMASEC
	required_reagents = list(IRON = 1, WINE = 5, VODKA = 5)
	result_amount = 10

/datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = CHANGELINGSTING
	result = CHANGELINGSTING
	required_reagents = list(SCREWDRIVERCOCKTAIL = 1, LIMEJUICE = 1, LEMONJUICE = 1)
	result_amount = 5

/datum/chemical_reaction/aloe
	name = "Aloe"
	id = ALOE
	result = ALOE
	required_reagents = list(CREAM = 1, WHISKEY = 1, WATERMELONJUICE = 1)
	result_amount = 2

/datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = ANDALUSIA
	result = ANDALUSIA
	required_reagents = list(RUM = 1, WHISKEY = 1, LEMONJUICE = 1)
	result_amount = 3

/datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = NEUROTOXIN
	result = NEUROTOXIN
	required_reagents = list(GARGLEBLASTER = 1, STOXIN = 1)
	result_amount = 2

/datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = SNOWWHITE
	result = SNOWWHITE
	required_reagents = list(BEER = 1, LEMON_LIME = 1)
	result_amount = 2

/datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = IRISHCARBOMB
	result = IRISHCARBOMB
	required_reagents = list(ALE = 1, IRISHCREAM = 1)
	result_amount = 2

/datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = SYNDICATEBOMB
	result = SYNDICATEBOMB
	required_reagents = list(BEER = 1, WHISKEYCOLA = 1)
	result_amount = 2

/datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = ERIKASURPRISE
	result = ERIKASURPRISE
	required_reagents = list(ALE = 1, LIMEJUICE = 1, WHISKEY = 1, BANANA = 1, ICE = 1)
	result_amount = 5

/datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = DEVILSKISS
	result = DEVILSKISS
	required_reagents = list(BLOOD = 1, KAHLUA = 1, RUM = 1)
	result_amount = 3

/datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = HIPPIESDELIGHT
	result = HIPPIESDELIGHT
	required_reagents = list(PSILOCYBIN = 1, GARGLEBLASTER = 1)
	result_amount = 2

/datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = BANANAHONK
	result = BANANAHONK
	required_reagents = list(BANANA = 1, CREAM = 1, SUGAR = 1)
	result_amount = 3

/datum/chemical_reaction/silencer
	name = "Silencer"
	id = SILENCER
	result = SILENCER
	required_reagents = list(NOTHING = 1, CREAM = 1, SUGAR = 1)
	result_amount = 3

/datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = DRIESTMARTINI
	result = DRIESTMARTINI
	required_reagents = list(NOTHING = 1, GIN = 1)
	result_amount = 2

/datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = LEMONADE
	result = LEMONADE
	required_reagents = list(LEMONJUICE = 1, SUGAR = 1, WATER = 1)
	result_amount = 3

/datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = KIRASPECIAL
	result = KIRASPECIAL
	required_reagents = list(ORANGEJUICE = 1, LIMEJUICE = 1, SODAWATER = 1)
	result_amount = 2

/datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = BROWNSTAR
	result = BROWNSTAR
	required_reagents = list(KAHLUA = 1, "irish_cream" = 4)
	result_amount = 5

/datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = MILKSHAKE
	result = MILKSHAKE
	required_reagents = list(CREAM = 1, ICE = 2, MILK = 2)
	result_amount = 5

/datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = REWRITER
	result = REWRITER
	required_reagents = list(SPACEMOUNTAINWIND = 1, COFFEE = 1)
	result_amount = 2

/datum/chemical_reaction/vinegar
	name = "Vinegar"
	id = VINEGAR
	result = VINEGAR
	required_reagents = list(WINE = 5)
	required_catalysts = list(ENZYME = 5)
	result_amount = 5

//Cafe stuff!
/datum/chemical_reaction/acidtea
	name = "Earl's Grey Tea"
	id = ACIDTEA
	result = ACIDTEA
	required_reagents = list(SACID = 1, TEA = 1)
	result_amount = 2

/datum/chemical_reaction/chifir
	name = "Chifir"
	id = CHIFIR
	result = CHIFIR
	required_reagents = list(TEA = 5, REDTEA = 5, GREENTEA = 5)
	result_amount = 15

/datum/chemical_reaction/yinyang
	name = "Zen Tea"
	id = YINYANG
	result = YINYANG
	required_reagents = list(TEA = 5, NOTHING = 5)
	result_amount = 10

/datum/chemical_reaction/singularitea
	name = "Singularitea"
	id = SINGULARITEA
	result = SINGULARITEA
	required_reagents = list(RADIUM = 1, TEA = 5, REDTEA = 5)
	result_amount = 10

/datum/chemical_reaction/gyro
	name = "Gyro"
	id = GYRO
	result = GYRO
	required_reagents = list(GREENTEA = 5, WHISKEY = 5, IRON = 1)
	result_amount = 10

/datum/chemical_reaction/plasmatea
	name = "Plasma Pekoe"
	id = PLASMATEA
	result = PLASMATEA
	required_reagents = list(TEA = 5, PLASMA = 5)
	result_amount = 10

/datum/chemical_reaction/espresso
	name = "Espresso"
	id = ESPRESSO
	result = ESPRESSO
	required_reagents = list(COFFEE = 1, WATER = 1)
	result_amount = 2

/datum/chemical_reaction/cappuccino
	name = "Cappuccino"
	id = CAPPUCCINO
	result = CAPPUCCINO
	required_reagents = list(ESPRESSO = 1, CREAM = 1)
	result_amount = 2

/datum/chemical_reaction/tonio
	name = "Tonio"
	id = TONIO
	result = TONIO
	required_reagents = list(COFFEE = 5, LIMEJUICE = 1, TOMATOJUICE = 1, LEMONJUICE = 1, WATERMELONJUICE = 1, "honey" = 1)
	result_amount = 10

/datum/chemical_reaction/doppio
	name = "Doppio"
	id = DOPPIO
	result = DOPPIO
	required_reagents = list(COFFEE = 5, REDTEA = 5, GREENTEA = 5)
	result_amount = 10

/datum/chemical_reaction/passione
	name = "Passione"
	id = PASSIONE
	result = PASSIONE
	required_reagents = list(CAPPUCCINO = 5, GOLD = 1, "honey" =5)
	result_amount = 10

/datum/chemical_reaction/seccoffee
	name = "Wake up call"
	id = SECCOFFEE
	result = SECCOFFEE
	required_reagents = list(COFFEE = 5, SPRINKLES = 1, BEEPSKYSMASH = 5)
	result_amount = 10

/datum/chemical_reaction/medcoffee
	name = "Lifeline"
	id = MEDCOFFEE
	result = MEDCOFFEE
	required_reagents = list(COFFEE = 5, DOCTORSDELIGHT = 5, BLOOD = 1)
	result_amount = 10

/datum/chemical_reaction/detcoffee
	name = "Joe"
	id = DETCOFFEE
	result = DETCOFFEE
	required_reagents = list(COFFEE = 5, WHISKEY = 5)
	result_amount = 5

/datum/chemical_reaction/etank
	name = "Recharger"
	id = "tank"
	result = ETANK
	required_reagents = list(COFFEE = 1, IRON = 1, LITHIUM = 1, FUEL = 1, ALUMINUM = 1)
	result_amount = 5

/datum/chemical_reaction/greytea
	name = "Tide"
	id = GREYTEA
	result = GREYTEA
	required_reagents = list(WATER = 5, FUEL = 5)

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = CITALOPRAM
	result = CITALOPRAM
	required_reagents = list(MINDBREAKER = 1, CARBON = 1)
	result_amount = 3

/datum/chemical_reaction/paroxetine
	name = "Paroxetine"
	id = PAROXETINE
	result = PAROXETINE
	required_reagents = list(MINDBREAKER = 1, OXYGEN = 1, INAPROVALINE = 1)
	result_amount = 3


#undef ALERT_AMOUNT_ONLY
#undef ALERT_ALL_REAGENTS
