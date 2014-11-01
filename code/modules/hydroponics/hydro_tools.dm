//Analyzer, pestkillers, weedkillers, nutrients, hatchets, cutters.

/obj/item/weapon/wirecutters/clippers
	name = "plant clippers"
	desc = "A tool used to take samples from plants."

/obj/item/device/analyzer/plant_analyzer
	name = "plant analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"

/obj/item/device/analyzer/plant_analyzer/attack_self(mob/user as mob)
	return 0

/obj/item/device/analyzer/plant_analyzer/afterattack(obj/target, mob/user, flag)
	if(!flag) return

	var/datum/seed/grown_seed
	var/datum/reagents/grown_reagents
	if(istype(target,/obj/structure/rack) || istype(target,/obj/structure/table))
		return ..()
	else if(istype(target,/obj/item/weapon/reagent_containers/food/snacks/grown))

		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = target
		grown_seed = seed_types[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/weapon/grown))

		var/obj/item/weapon/grown/G = target
		grown_seed = seed_types[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/seeds))

		var/obj/item/seeds/S = target
		grown_seed = S.seed

	else if(istype(target,/obj/machinery/portable_atmospherics/hydroponics))

		var/obj/machinery/portable_atmospherics/hydroponics/H = target
		grown_seed = H.seed
		grown_reagents = H.reagents

	if(!grown_seed)
		user << "\red [src] can tell you nothing about [target]."
		return

	var/dat = "<h3>Plant data for [target]</h3>"
	user.visible_message("\blue [user] runs the scanner over [target].")

	dat += "<h2>General Data</h2>"

	dat += "<table>"
	dat += "<tr><td><b>Endurance</b></td><td>[grown_seed.endurance]</td></tr>"
	dat += "<tr><td><b>Yield</b></td><td>[grown_seed.yield]</td></tr>"
	dat += "<tr><td><b>Lifespan</b></td><td>[grown_seed.lifespan]</td></tr>"
	dat += "<tr><td><b>Maturation time</b></td><td>[grown_seed.maturation]</td></tr>"
	dat += "<tr><td><b>Production time</b></td><td>[grown_seed.production]</td></tr>"
	dat += "<tr><td><b>Potency</b></td><td>[grown_seed.potency]</td></tr>"
	dat += "</table>"

	if(grown_reagents && grown_reagents.reagent_list && grown_reagents.reagent_list.len)
		dat += "<h2>Reagent Data</h2>"

		dat += "<br>This sample contains: "
		for(var/datum/reagent/R in grown_reagents.reagent_list)
			dat += "<br>- [R.id], [grown_reagents.get_reagent_amount(R.id)] unit(s)"

	dat += "<h2>Other Data</h2>"

	if(grown_seed.harvest_repeat)
		dat += "This plant can be harvested repeatedly.<br>"

	if(grown_seed.immutable == -1)
		dat += "This plant is highly mutable.<br>"
	else if(grown_seed.immutable > 0)
		dat += "This plant does not possess genetics that are alterable.<br>"

	if(grown_seed.products && grown_seed.products.len)
		dat += "The mature plant will produce [grown_seed.products.len == 1 ? "fruit" : "[grown_seed.products.len] varieties of fruit"].<br>"

	if(grown_seed.requires_nutrients)
		if(grown_seed.nutrient_consumption < 0.05)
			dat += "It consumes a small amount of nutrient fluid.<br>"
		else if(grown_seed.nutrient_consumption > 0.2)
			dat += "It requires a heavy supply of nutrient fluid.<br>"
		else
			dat += "It requires a supply of nutrient fluid.<br>"

	if(grown_seed.requires_water)
		if(grown_seed.water_consumption < 1)
			dat += "It requires very little water.<br>"
		else if(grown_seed.water_consumption > 5)
			dat += "It requires a large amount of water.<br>"
		else
			dat += "It requires a stable supply of water.<br>"

	if(grown_seed.mutants && grown_seed.mutants.len)
		dat += "It exhibits a high degree of potential subspecies shift.<br>"

	dat += "It thrives in a temperature of [grown_seed.ideal_heat] Kelvin."

	if(grown_seed.lowkpa_tolerance < 20)
		dat += "<br>It is well adapted to low pressure levels."
	if(grown_seed.highkpa_tolerance > 220)
		dat += "<br>It is well adapted to high pressure levels."

	if(grown_seed.heat_tolerance > 30)
		dat += "<br>It is well adapted to a range of temperatures."
	else if(grown_seed.heat_tolerance < 10)
		dat += "<br>It is very sensitive to temperature shifts."

	dat += "<br>It thrives in a light level of [grown_seed.ideal_light] lumen[grown_seed.ideal_light == 1 ? "" : "s"]."

	if(grown_seed.light_tolerance > 10)
		dat += "<br>It is well adapted to a range of light levels."
	else if(grown_seed.light_tolerance < 3)
		dat += "<br>It is very sensitive to light level shifts."

	if(grown_seed.toxins_tolerance < 3)
		dat += "<br>It is highly sensitive to toxins."
	else if(grown_seed.toxins_tolerance > 6)
		dat += "<br>It is remarkably resistant to toxins."

	if(grown_seed.pest_tolerance < 3)
		dat += "<br>It is highly sensitive to pests."
	else if(grown_seed.pest_tolerance > 6)
		dat += "<br>It is remarkably resistant to pests."

	if(grown_seed.weed_tolerance < 3)
		dat += "<br>It is highly sensitive to weeds."
	else if(grown_seed.weed_tolerance > 6)
		dat += "<br>It is remarkably resistant to weeds."

	switch(grown_seed.spread)
		if(1)
			dat += "<br>It is capable of growing beyond the confines of a tray."
		if(2)
			dat += "<br>It is a robust and vigorous vine that will spread rapidly."

	switch(grown_seed.carnivorous)
		if(1)
			dat += "<br>It is carniovorous and will eat tray pests for sustenance."
		if(2)
			dat	+= "<br>It is carnivorous and poses a significant threat to living things around it."

	if(grown_seed.parasite)
		dat += "<br>It is capable of parisitizing and gaining sustenance from tray weeds."
	if(grown_seed.alter_temp)
		dat += "<br>It will periodically alter the local temperature by [grown_seed.alter_temp] degrees Kelvin."

	if(grown_seed.biolum)
		dat += "<br>It is [grown_seed.biolum_colour ? "<font color='[grown_seed.biolum_colour]'>bio-luminescent</font>" : "bio-luminescent"]."
	if(grown_seed.flowers)
		dat += "<br>It has [grown_seed.flower_colour ? "<font color='[grown_seed.flower_colour]'>flowers</font>" : "flowers"]."

	if(dat)
		user << browse(dat,"window=plant_analyzer")

	return

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/weapon/plantspray
	icon = 'icons/obj/hydroponics.dmi'
	item_state = "spray"
	flags = TABLEPASS | FPRINT | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 4
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/pest_kill_str = 0
	var/weed_kill_str = 0

/obj/item/weapon/plantspray/weeds // -- Skie

	name = "weed-spray"
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon_state = "weedspray"
	weed_kill_str = 6

/obj/item/weapon/plantspray/pests
	name = "pest-spray"
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon_state = "pestspray"
	pest_kill_str = 6

/obj/item/weapon/plantspray/pests/old
	name = "bottle of pestkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/weapon/plantspray/pests/old/carbaryl
	name = "bottle of carbaryl"
	icon_state = "bottle16"
	toxicity = 4
	pest_kill_str = 2

/obj/item/weapon/plantspray/pests/old/lindane
	name = "bottle of lindane"
	icon_state = "bottle18"
	toxicity = 6
	pest_kill_str = 4

/obj/item/weapon/plantspray/pests/old/phosmet
	name = "bottle of phosmet"
	icon_state = "bottle15"
	toxicity = 8
	pest_kill_str = 7

/obj/item/weapon/minihoe // -- Numbers
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = FPRINT | TABLEPASS | CONDUCT | NOBLUDGEON
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	attack_verb = list("slashed", "sliced", "cut", "clawed")


// *************************************
// Weedkiller defines for hydroponics
// *************************************

/obj/item/weedkiller
	name = "bottle of weedkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	var/toxicity = 0
	var/weed_kill_str = 0

/obj/item/weedkiller/triclopyr
	name = "bottle of glyphosate"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS
	toxicity = 4
	weed_kill_str = 2

/obj/item/weedkiller/lindane
	name = "bottle of triclopyr"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	flags = FPRINT |  TABLEPASS
	toxicity = 6
	weed_kill_str = 4

/obj/item/weedkiller/D24
	name = "bottle of 2,4-D"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	flags = FPRINT |  TABLEPASS
	toxicity = 8
	weed_kill_str = 7


// *************************************
// Nutrient defines for hydroponics
// *************************************

/obj/item/weapon/reagent_containers/glass/fertilizer
	name = "fertilizer bottle"
	desc = "A small glass bottle. Can hold up to 10 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	flags = FPRINT |  TABLEPASS | OPENCONTAINER
	possible_transfer_amounts = null
	w_class = 2.0

	var/fertilizer //Reagent contained, if any.

	//Like a shot glass!
	amount_per_transfer_from_this = 10
	volume = 10

/obj/item/weapon/reagent_containers/glass/fertilizer/New()
	..()

	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

	if(fertilizer)
		reagents.add_reagent(fertilizer,10)

/obj/item/weapon/reagent_containers/glass/fertilizer/ez
	name = "bottle of E-Z-Nutrient"
	icon_state = "bottle16"
	fertilizer = "eznutrient"

/obj/item/weapon/reagent_containers/glass/fertilizer/l4z
	name = "bottle of Left 4 Zed"
	icon_state = "bottle18"
	fertilizer = "left4zed"

/obj/item/weapon/reagent_containers/glass/fertilizer/rh
	name = "bottle of Robust Harvest"
	icon_state = "bottle15"
	fertilizer = "robustharvest"

//Hatchets and things to kill kudzu
/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 12.0
	w_class = 2.0
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	sharp = 1
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")

/obj/item/weapon/hatchet/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

//If it's a hatchet it goes here. I guess
/obj/item/weapon/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 3
	w_class = 4.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	slot_flags = SLOT_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/weapon/scythe/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(A, /obj/effect/plantsegment))
		for(var/obj/effect/plantsegment/B in orange(A,1))
			if(prob(80))
				del B
		del A