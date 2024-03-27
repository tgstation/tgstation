/obj/item/storage/box/syndie_kit/chefchemicals/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/fentanyl(src)
	new /obj/item/reagent_containers/glass/bottle/fentanyl(src)
	new /obj/item/reagent_containers/glass/bottle/cyanide(src)
	new /obj/item/reagent_containers/glass/bottle/cyanide(src)
	new /obj/item/reagent_containers/glass/bottle/coniine(src)
	new /obj/item/reagent_containers/glass/bottle/coniine(src)
	new /obj/item/reagent_containers/glass/bottle/amanitin(src)
	new /obj/item/reagent_containers/glass/bottle/amanitin(src)


/obj/item/storage/bag/plantssyndie
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	item_state = "plantbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plantssyndie/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 100
	STR.max_items = 100
	STR.display_numerical_stacking = TRUE
	STR.set_holdable(list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/grown,
		/obj/item/reagent_containers/honeycomb,
		/obj/item/seeds,
		))

/obj/item/storage/bag/plantssyndie/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/grown/nettle/death(src)
	new /obj/item/reagent_containers/food/snacks/grown/berries/poison(src)
	new /obj/item/reagent_containers/food/snacks/grown/berries/death(src)
	new /obj/item/reagent_containers/food/snacks/grown/cannabis/death(src)
	new /obj/item/reagent_containers/food/snacks/grown/banana/mime(src)
	new /obj/item/reagent_containers/food/snacks/grown/banana/bluespace(src)
	new /obj/item/reagent_containers/food/snacks/grown/firelemon(src)
	new /obj/item/reagent_containers/food/snacks/grown/bungofruit(src)
	new /obj/item/reagent_containers/food/snacks/grown/mushroom/angel(src)
	new /obj/item/reagent_containers/food/snacks/grown/tomato/killer(src)
	new /obj/item/seeds/replicapod(src)

/obj/item/storage/bag/plantssyndiebluespace
	name = "plant bag"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbag"
	item_state = "plantbag"
	resistance_flags = FLAMMABLE

/obj/item/storage/bag/plantssyndiebluespace/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 999
	STR.max_items = 999
	STR.display_numerical_stacking = TRUE
	STR.set_holdable(list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/grown,
		/obj/item/reagent_containers/honeycomb,
		/obj/item/seeds,
		))


/obj/item/storage/box/syndie_kit/two_freedom_implant_bundle/PopulateContents()
	new /obj/item/implanter/freedom(src)
	new /obj/item/implanter/freedom(src)


/obj/item/storage/box/syndie_kit/syndie_relief_bundle/PopulateContents()
	new /obj/item/stack/telecrystal/five(src)
	new /obj/item/stack/telecrystal/five(src)


/obj/item/storage/box/syndie_kit/bluespace_crystal_arti_bundle/PopulateContents()
	for(var/i in 1 to 20)
		new /obj/item/stack/ore/bluespace_crystal/artificial(src)


/obj/item/storage/box/syndie_kit/escapist_bundle/PopulateContents()
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/card/id/syndicate(src)
	new /obj/item/pen/blue/sleepy(src)
	new /obj/item/card/emag(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)
	new /obj/item/implanter/uplink(src)
	new /obj/item/pen/red/edagger(src)
	for(var/i in 1 to 4)
		new /obj/item/grenade/plastic/c4(src)


/obj/item/storage/box/syndie_kit/donkpocket_bundle/PopulateContents()
	var/list/item_list = list(
		/obj/item/storage/box/donkpockets,
		/obj/item/storage/box/donkpockets/donkpocketspicy,
		/obj/item/storage/box/donkpockets/donkpocketteriyaki,
		/obj/item/storage/box/donkpockets/donkpocketpizza,
		/obj/item/storage/box/donkpockets/donkpocketberry,
		/obj/item/storage/box/donkpockets/donkpockethonk
	)

	for(var/i in 1 to 24)
		var/item = pick(item_list)
		new item(src)


/obj/item/storage/box/syndie_kit/construction_bundle/PopulateContents()
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)


/obj/item/storage/firstaid/medical_variety_pack
	name = "Medical Variety Pack"
	desc = "It's a bluespace medical kit, it's capable of holding far more medical supplies than normal."
	icon = 'icons/myimports/storage.dmi'
	icon_state = "medkit_bluespace"

/obj/item/storage/firstaid/medical_variety_pack/PopulateContents()
	new /obj/item/storage/firstaid/regular(src)
	if(prob(50))
		new /obj/item/storage/firstaid/fire(src)
	if(prob(50))
		new /obj/item/storage/firstaid/toxin(src)
	if(prob(50))
		new /obj/item/storage/firstaid/o2(src)
	if(prob(50))
		new /obj/item/storage/firstaid/brute(src)
	if(prob(35))
		new /obj/item/storage/firstaid/advanced(src)
	new /obj/item/stack/medical/bone_gel(src)
	new /obj/item/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/charcoal(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/coagulant(src)
	if(prob(25))
		new /obj/item/reagent_containers/glass/bottle/probital(src)
	if(prob(25))
		new /obj/item/reagent_containers/glass/bottle/modafinil(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/leporazine(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/oculine(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/inacusiate(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/sal_acid(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/oxandrolone(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/pen_acid(src)
	if(prob(10))
		new /obj/item/reagent_containers/glass/bottle/salbutamol(src)
	new /obj/item/storage/pill_bottle/iron(src)
	if(prob(10))
		new /obj/item/storage/pill_bottle/bicaridine(src)
	if(prob(10))
		new /obj/item/storage/pill_bottle/kelotane(src)
	if(prob(10))
		new /obj/item/storage/pill_bottle/antitoxin(src)
	if(prob(10))
		new /obj/item/storage/pill_bottle/dexalin(src)
	if(prob(10))
		new /obj/item/storage/pill_bottle/coagulant(src)
	new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/firstaid/deluxe_medical_variety_pack
	name = "Deluxe Medical Variety Pack"
	desc = "It's a bluespace medical kit, it's capable of holding far more medical supplies than normal."
	icon = 'icons/myimports/storage.dmi'
	icon_state = "medkit_bluespace2"

/obj/item/storage/firstaid/deluxe_medical_variety_pack/PopulateContents()
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/brute(src)
	if(prob(60))
		new /obj/item/storage/firstaid/advanced(src)
	new /obj/item/reagent_containers/glass/bottle/omnizine(src)
	new /obj/item/reagent_containers/glass/bottle/omnizine(src)
	new /obj/item/stack/medical/bone_gel(src)
	if(prob(80))
		new /obj/item/reagent_containers/glass/bottle/morphine(src)
	if(prob(80))
		new /obj/item/reagent_containers/glass/bottle/charcoal(src)
	if(prob(80))
		new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/coagulant(src)
	if(prob(40))
		new /obj/item/reagent_containers/glass/bottle/probital(src)
	if(prob(40))
		new /obj/item/reagent_containers/glass/bottle/modafinil(src)
	if(prob(25))
		new /obj/item/reagent_containers/glass/bottle/leporazine(src)
	if(prob(30))
		new /obj/item/reagent_containers/glass/bottle/oculine(src)
	if(prob(30))
		new /obj/item/reagent_containers/glass/bottle/inacusiate(src)
	if(prob(25))
		new /obj/item/reagent_containers/glass/bottle/naniterestoration(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/storage/pill_bottle/iron(src)
	if(prob(70))
		new /obj/item/storage/pill_bottle/iron(src)
	new /obj/item/storage/pill_bottle/mannitol(src)
	new /obj/item/storage/pill_bottle/mutadone(src)
	if(prob(25))
		new /obj/item/storage/pill_bottle/bicaridine(src)
	if(prob(25))
		new /obj/item/storage/pill_bottle/kelotane(src)
	if(prob(25))
		new /obj/item/storage/pill_bottle/antitoxin(src)
	if(prob(25))
		new /obj/item/storage/pill_bottle/dexalin(src)
	if(prob(25))
		new /obj/item/storage/pill_bottle/coagulant(src)
	if(prob(50))
		new /obj/item/storage/pill_bottle/stimulant(src)
	if(prob(60))
		new /obj/item/reagent_containers/autoinjector/medipen/salacid(src)
	if(prob(60))
		new /obj/item/reagent_containers/autoinjector/medipen/oxandrolone(src)
	if(prob(60))
		new /obj/item/reagent_containers/autoinjector/medipen/salbutamol(src)
	if(prob(60))
		new /obj/item/reagent_containers/autoinjector/medipen/atropine(src)
	new /obj/item/reagent_containers/autoinjector/medipen/blood_loss(src)


/obj/item/storage/box/syndie_kit/syndiecigsdeluxepack/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter(src)


/obj/item/storage/box/syndie_kit/chemistry_machine_bundle/PopulateContents()
	new /obj/item/circuitboard/machine/chem_dispenser(src)
	new /obj/item/circuitboard/machine/chem_heater(src)
	new /obj/item/circuitboard/machine/chem_master(src)
	new /obj/item/circuitboard/machine/reagentgrinder(src)
	new /obj/item/stack/sheet/metal/twenty(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stock_parts/micro_laser/quadultra(src)
	new /obj/item/stock_parts/capacitor/quadratic(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/matter_bin/bluespace(src)
	new /obj/item/stock_parts/matter_bin/bluespace(src)
	new /obj/item/stock_parts/cell/high(src)
	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/glass(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/wrench(src)
	new /obj/item/screwdriver(src)


/obj/item/storage/box/syndie_kit/syndie_inducer_bundle/PopulateContents()
	new /obj/item/inducer/syndicate(src)
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/cell/hyper(src)
	new /obj/item/screwdriver(src)


/obj/item/storage/box/syndie_kit/xenobio_starter_kit/PopulateContents()
	new /obj/item/slimecross/industrial/grey(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/storage/box/monkeycubes(src)
	new /obj/item/storage/box/monkeycubes(src)


/obj/item/storage/box/syndie_kit/eyewear_hud_bundle/PopulateContents()
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health/night(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/glasses/hud/diagnostic(src)
	new /obj/item/clothing/glasses/hud/diagnostic/night(src)
	new /obj/item/clothing/glasses/hud/diagnostic/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security(src)
	new /obj/item/clothing/glasses/hud/security/night(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/clothing/glasses/science/night(src)


/obj/item/storage/box/syndie_kit/cleanbot_bundle
	name = "Cleanbot Bundle"

/obj/item/storage/box/syndie_kit/cleanbot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/cleanbot(src)

/obj/item/storage/box/syndie_kit/firebotbot_bundle
	name = "Firebot Bundle"

/obj/item/storage/box/syndie_kit/firebotbot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/firebot(src)

/obj/item/storage/box/syndie_kit/medibot_bundle
	name = "Medibot Bundle"

/obj/item/storage/box/syndie_kit/medibot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/medbot(src)

/obj/item/storage/box/syndie_kit/floorbot_bundle
	name = "Floorbot Bundle"

/obj/item/storage/box/syndie_kit/floorbot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/floorbot(src)

/obj/item/storage/box/syndie_kit/honkbot_bundle
	name = "Honkbot Bundle"

/obj/item/storage/box/syndie_kit/honkbot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/honkbot(src)

/obj/item/storage/box/syndie_kit/secbot_bundle
	name = "Securitron Bundle"

/obj/item/storage/box/syndie_kit/secbot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/secbot(src)

/obj/item/storage/box/syndie_kit/atmosbot_bundle
	name = "Atmosbot Bundle"

/obj/item/storage/box/syndie_kit/atmosbot_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/storage/box/assembly/atmosbot(src)


/obj/item/storage/box/syndie_kit/robotic_pal_assembly_bundle
	name = "Robotic Pals Assembly Kit"

/obj/item/storage/box/syndie_kit/robotic_pal_assembly_bundle/PopulateContents()
	new /obj/item/storage/box/syndie_kit/cleanbot_bundle(src)
	new /obj/item/storage/box/syndie_kit/firebotbot_bundle(src)
	new /obj/item/storage/box/syndie_kit/medibot_bundle(src)
	new /obj/item/storage/box/syndie_kit/floorbot_bundle(src)
	new /obj/item/storage/box/syndie_kit/honkbot_bundle(src)
	new /obj/item/storage/box/syndie_kit/secbot_bundle(src)
	new /obj/item/storage/box/syndie_kit/atmosbot_bundle(src)


/obj/item/storage/box/syndie_kit/pill_teeth_bundle/PopulateContents()
	new /obj/item/surgical_drapes(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/storage/pill_bottle/epinephrine(src)
	new /obj/item/storage/pill_bottle/iron(src)
	new /obj/item/storage/pill_bottle/mannitol(src)
	new /obj/item/storage/pill_bottle/stimulant(src)
	new /obj/item/reagent_containers/pill/bicaridine(src)
	new /obj/item/reagent_containers/pill/kelotane(src)
	new /obj/item/reagent_containers/pill/antitoxin(src)
	new /obj/item/reagent_containers/pill/dexalin(src)
	if(prob(25))
		new /obj/item/reagent_containers/pill/tricordrazine(src)
	new /obj/item/reagent_containers/pill/coagulant(src)


/obj/item/storage/box/syndie_kit/chem_storage_implant_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/implantcase/syndiechem(src)
	new /obj/item/implanter(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/beaker(src)

/obj/item/storage/box/syndie_kit/chem_storage_implant/PopulateContents()
	new /obj/item/implantcase/syndiechem(src)
	new /obj/item/implanter(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/beaker(src)


/obj/item/storage/firstaid/syndiecigsvarietypack
	name = "Syndicate Variety Cigarettes"
	icon = 'icons/myimports/storage.dmi'
	icon_state = "cigarettepacker"

/obj/item/storage/firstaid/syndiecigsvarietypack/PopulateContents()
	new /obj/item/storage/fancy/cigarettes/robust_sal_acid(src)
	new /obj/item/storage/fancy/cigarettes/dromedary_oxandrolone(src)
	new /obj/item/storage/fancy/cigarettes/space_cigarette_pen_acid(src)
	new /obj/item/storage/fancy/cigarettes/uplift_salbutamol(src)

/obj/item/storage/firstaid/syndiecigsvarietypackdeluxe
	name = "Syndicate Variety Cigarettes Deluxe Edition"
	icon = 'icons/myimports/storage.dmi'
	icon_state = "cigarettepacker2"

/obj/item/storage/firstaid/syndiecigsvarietypackdeluxe/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10

/obj/item/storage/firstaid/syndiecigsvarietypackdeluxe/PopulateContents()
	new /obj/item/storage/fancy/cigarettes/deluxe_antibrute_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_antiburn_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_antioxygen_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_antitoxin_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_speedup_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_cureall_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_sensory_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_strange_cigarette_pack(src)
	new /obj/item/storage/fancy/cigarettes/deluxe_slimey_cigarette_pack(src)
	new /obj/item/lighter(src)


/obj/item/storage/box/syndie_kit/holy_healing_bundle/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/bottle/omnizine(src)
	new /obj/item/reagent_containers/glass/bottle/mutagen(src)


/obj/item/storage/box/syndie_kit/burning_extract_bundle/PopulateContents()
	new /obj/item/slimecross/burning/yellow(src)
	new /obj/item/slimecross/burning/metal(src)
	new /obj/item/slimecross/burning/gold(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/syringe(src)
	var/list/types = subtypesof(/obj/item/slimecross/burning/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/charged_extract_bundle/PopulateContents()
	new /obj/item/slimecross/charged/darkblue(src)
	new /obj/item/slimecross/charged/red(src)
	new /obj/item/slimecross/charged/green(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/syringe(src)
	var/list/types = subtypesof(/obj/item/slimecross/charged/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/chilling_extract_bundle/PopulateContents()
	new /obj/item/slimecross/chilling/metal(src)
	new /obj/item/slimecross/chilling/darkblue(src)
	new /obj/item/slimecross/chilling/bluespace(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/syringe(src)
	var/list/types = subtypesof(/obj/item/slimecross/chilling/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/consuming_extract_bundle/PopulateContents()
	new /obj/item/slimecross/consuming/purple(src)
	new /obj/item/slimecross/consuming/metal(src)
	new /obj/item/slimecross/consuming/oil(src)
	var/list/types = subtypesof(/obj/item/slimecross/consuming/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/industrial_extract_bundle/PopulateContents()
	new /obj/item/slimecross/industrial/purple(src)
	new /obj/item/slimecross/industrial/gold(src)
	new /obj/item/slimecross/industrial/pink(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/syringe(src)
	var/list/types = subtypesof(/obj/item/slimecross/industrial/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/regenerative_extract_bundle/PopulateContents()
	new /obj/item/slimecross/regenerative/purple(src)
	new /obj/item/slimecross/regenerative/sepia(src)
	new /obj/item/slimecross/regenerative/adamantine(src)
	var/list/types = subtypesof(/obj/item/slimecross/regenerative/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/stabilized_extract_bundle/PopulateContents()
	new /obj/item/slimecross/stabilized/purple(src)
	new /obj/item/slimecross/stabilized/bluespace(src)
	new /obj/item/slimecross/stabilized/adamantine(src)
	var/list/types = subtypesof(/obj/item/slimecross/stabilized/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/crystalized_extract_bundle/PopulateContents()
	new /obj/item/slimecross/crystalized/rainbow(src)
	new /obj/item/slimecross/crystalized/purple(src)
	new /obj/item/slimecross/crystalized/orange(src)
	var/list/types = subtypesof(/obj/item/slimecross/crystalized/)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/clown_trolling_security_bundle/PopulateContents()
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/sunglasses(src)


/obj/item/storage/box/syndie_kit/clown_stun_resist_bundle/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/bottle/probital(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/modafinil(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/bottle/methamphetamine(src)


/obj/item/storage/box/syndie_kit/syndicate_virus_box/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/glass/bottle/random_virus(src)
	new /obj/item/reagent_containers/glass/bottle/flu_virion(src)
	new /obj/item/reagent_containers/glass/bottle/cold(src)
	new /obj/item/reagent_containers/glass/bottle/fake_gbs(src)
	new /obj/item/reagent_containers/glass/bottle/magnitis(src)
	new /obj/item/reagent_containers/glass/bottle/pierrot_throat(src)
	new /obj/item/reagent_containers/glass/bottle/brainrot(src)
	new /obj/item/reagent_containers/glass/bottle/anxiety(src)
	new /obj/item/reagent_containers/glass/bottle/beesease(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/reagent_containers/glass/bottle/mutagen(src)

/**
/obj/item/storage/box/syndie_kit/manifold_injector_bundle
	name = "Bundle of HMS Injectors"

/obj/item/storage/box/syndie_kit/manifold_injector_bundle/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6

/obj/item/storage/box/syndie_kit/manifold_injector_bundle/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/autoinjector/medipen/manifoldinjector(src)
**/

/obj/item/storage/box/syndie_kit/syndie_hypnotism_bundle/PopulateContents()
	new /obj/item/assembly/flash/hypnotic(src)
	new /obj/item/grenade/hypnotic(src)
	for(var/i in 1 to 5)
		new /obj/item/grenade/chem_grenade/mindbreaker(src)


/obj/item/storage/box/syndie_kit/lathe_supply_package
	name = "Lathe Supply Package"

/obj/item/storage/box/syndie_kit/lathe_supply_package/PopulateContents()
	new /obj/item/circuitboard/machine/autolathe(src)
	new /obj/item/circuitboard/machine/protolathe(src)
	for(var/i in 1 to 5)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/stack/sheet/glass(src)
	new /obj/item/stack/sheet/metal/ten(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)


/obj/item/storage/box/syndie_kit/nocturine_deluxe/PopulateContents()
	new /obj/item/pen/blue/sleepy(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/bottle/nocturine/full(src)


/obj/item/storage/box/syndie_kit/deluxe_barkeep_package/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker/large/doctor_delight(src)
	new /obj/item/reagent_containers/glass/beaker/large/laughter(src)
	new /obj/item/reagent_containers/glass/beaker/large/superlaughter(src)
	new /obj/item/reagent_containers/glass/beaker/large/coffee(src)
	new /obj/item/reagent_containers/glass/beaker/large/tea(src)
	new /obj/item/reagent_containers/glass/beaker/large/lemonade(src)
	new /obj/item/reagent_containers/glass/beaker/large/hot_ice_coffee(src)
	new /obj/item/reagent_containers/glass/beaker/large/icetea(src)
	new /obj/item/reagent_containers/glass/beaker/large/nuka_cola(src)
	new /obj/item/reagent_containers/glass/beaker/large/grey_bull(src)
	new /obj/item/reagent_containers/glass/beaker/large/cinderella(src)
	new /obj/item/reagent_containers/glass/beaker/large/cherryshake(src)
	new /obj/item/reagent_containers/glass/beaker/large/bluecherryshake(src)
	new /obj/item/reagent_containers/glass/beaker/large/vanillashake(src)
	new /obj/item/reagent_containers/glass/beaker/large/caramelshake(src)
	new /obj/item/reagent_containers/glass/beaker/large/choccyshake(src)
	new /obj/item/reagent_containers/glass/beaker/large/strawberryshake(src)
	new /obj/item/reagent_containers/glass/beaker/large/bananashake(src)
	new /obj/item/reagent_containers/glass/beaker/large/pumpkin_latte(src)
	new /obj/item/reagent_containers/glass/beaker/large/hot_coco(src)
	new /obj/item/reagent_containers/glass/beaker/large/grenadine(src)
	new /obj/item/reagent_containers/glass/beaker/large/shirley_temple(src)
	new /obj/item/reagent_containers/glass/beaker/large/red_queen(src)
	new /obj/item/reagent_containers/glass/beaker/large/agua_fresca(src)
	new /obj/item/reagent_containers/glass/beaker/large/mississippi_queen(src)
	new /obj/item/reagent_containers/glass/beaker/large/kahlua(src)
	new /obj/item/reagent_containers/glass/beaker/large/whiskey(src)
	new /obj/item/reagent_containers/glass/beaker/large/thirteenloko(src)
	new /obj/item/reagent_containers/glass/beaker/large/cuba_libre(src)
	new /obj/item/reagent_containers/glass/beaker/large/screwdrivercocktail(src)


/obj/item/storage/box/syndie_kit/helpful_barkeep_drinks/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/doctor_delight(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/grey_bull(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/cuba_libre(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/screwdrivercocktail(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/alexander(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/bastion_bourbon(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/bloody_mary(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/brave_bull(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/beaker/large/changelingsting(src)
	for(var/i in 1 to 1)
		new /obj/item/reagent_containers/glass/beaker/large/demonsblood(src)
	for(var/i in 1 to 1)
		new /obj/item/reagent_containers/glass/beaker/large/devilskiss(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/hearty_punch(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/the_juice(src)
	for(var/i in 1 to 1)
		new /obj/item/reagent_containers/glass/beaker/large/neurotoxin(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/glass/beaker/large/turbo(src)


/obj/item/storage/box/syndie_kit/janitor_acidnade_bundle/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/grenade/chem_grenade/highacidfoam(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	for(var/i in 1 to 5)
		new /obj/item/assembly/prox_sensor(src)
	for(var/i in 1 to 6)
		new /obj/item/assembly/signaler(src)


/obj/item/storage/box/syndie_kit/janitor_bloodnade_bundle/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/grenade/chem_grenade/bloodyfoam(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)


/obj/item/storage/box/syndie_kit/bluespace_bodybag_bundle/PopulateContents()
	new /obj/item/bodybag/bluespace(src)
	new /obj/item/bodybag/bluespace(src)
	new /obj/item/pen/blue/sleepy(src)
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/glass/bottle/chloralhydrate(src)


/obj/item/storage/box/syndie_kit/n2o_nade_bundle/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/chem_grenade/nofoam(src)


/obj/item/storage/box/syndie_kit/gas_nades_bundle/PopulateContents()
	new /obj/item/grenade/chem_grenade/nofoam(src)
	new /obj/item/grenade/chem_grenade/freonfoam(src)
	new /obj/item/grenade/chem_grenade/halonfoam(src)
	new /obj/item/grenade/chem_grenade/healiumfoam(src)
	new /obj/item/grenade/chem_grenade/npfoam(src)
	new /obj/item/grenade/chem_grenade/nitriumfoam(src)
	new /obj/item/grenade/chem_grenade/pluoxiumfoam(src)
	new /obj/item/grenade/chem_grenade/zaukerfoam(src)


/obj/item/storage/box/syndie_kit/stimulant_kit/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/autoinjector/medipen/stimpack/large(src)


/obj/item/storage/box/syndie_kit/paramedic_defib_box/PopulateContents()
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/card/emag(src)


/obj/item/storage/box/syndie_kit/regen_implant_box/PopulateContents()
	new /obj/item/autosurgeon/syndicate/regenerative(src)
	new /obj/item/autosurgeon/syndicate/regenerative(src)
	new /obj/item/autosurgeon/syndicate/regenerative(src)


/obj/item/storage/box/syndie_kit/chem_storage_implant/PopulateContents()
	new /obj/item/implantcase/syndiechem(src)
	new /obj/item/implanter(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/beaker(src)


/obj/item/storage/box/syndie_kit/stripperclips762/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/ammo_box/a762(src)


/obj/item/storage/box/syndie_kit/flamethrower_bundle/PopulateContents()
	new /obj/item/flamethrower/full(src)
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/plasma(src)
	for(var/i in 1 to 3)
		new /obj/item/grenade/chem_grenade/incendiary(src)


/obj/item/storage/box/syndie_kit/molotovs/PopulateContents()
	new /obj/item/lighter(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/ethanol(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/fuel(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/clf3(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/phlogiston(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/napalm(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/hellwater(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/plasma(src)
	new /obj/item/reagent_containers/food/drinks/bottle/molotov/spore_burning(src)


/obj/item/storage/box/syndie_kit/antigravnades/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/grenade/antigravity/syndicate(src)


/obj/item/storage/box/syndie_kit/launchpadcamerabundle/PopulateContents()
	new /obj/item/stack/sheet/metal/ten(src)
	new /obj/item/stack/sheet/metal/five(src)
	for(var/i in 1 to 4)
		new /obj/item/stack/sheet/glass(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/circuitboard/computer/launchpad_console(src)
	new /obj/item/circuitboard/machine/launchpad(src)
	new /obj/item/circuitboard/computer/advanced_camera(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stack/ore/bluespace_crystal(src)
	new /obj/item/wrench(src)
	new /obj/item/screwdriver(src)
	new /obj/item/multitool(src)


/obj/item/storage/box/syndie_kit/bioterrorammo/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker/large/polonium(src)
	new /obj/item/reagent_containers/glass/beaker/large/venom(src)
	new /obj/item/reagent_containers/glass/beaker/large/fentanyl(src)
	new /obj/item/reagent_containers/glass/beaker/large/formaldehyde(src)
	new /obj/item/reagent_containers/glass/beaker/large/spewium(src)
	new /obj/item/reagent_containers/glass/beaker/large/cyanide(src)
	new /obj/item/reagent_containers/glass/beaker/large/histamine(src)
	new /obj/item/reagent_containers/glass/beaker/large/initropidril(src)
	new /obj/item/reagent_containers/glass/beaker/large/pancuronium(src)
	new /obj/item/reagent_containers/glass/beaker/large/sodium_thiopental(src)
	new /obj/item/reagent_containers/glass/beaker/large/coniine(src)
	new /obj/item/reagent_containers/glass/beaker/large/curare(src)
	new /obj/item/reagent_containers/glass/beaker/large/amanitin(src)
	new /obj/item/reagent_containers/glass/beaker/large/condensedcapsaicin(src)


/obj/item/storage/box/syndie_kit/bioterrorammodeluxe/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker/large/polonium(src)
	new /obj/item/reagent_containers/glass/beaker/large/venom(src)
	new /obj/item/reagent_containers/glass/beaker/large/fentanyl(src)
	new /obj/item/reagent_containers/glass/beaker/large/formaldehyde(src)
	new /obj/item/reagent_containers/glass/beaker/large/spewium(src)
	new /obj/item/reagent_containers/glass/beaker/large/cyanide(src)
	new /obj/item/reagent_containers/glass/beaker/large/histamine(src)
	new /obj/item/reagent_containers/glass/beaker/large/initropidril(src)
	new /obj/item/reagent_containers/glass/beaker/large/pancuronium(src)
	new /obj/item/reagent_containers/glass/beaker/large/sodium_thiopental(src)
	new /obj/item/reagent_containers/glass/beaker/large/coniine(src)
	new /obj/item/reagent_containers/glass/beaker/large/curare(src)
	new /obj/item/reagent_containers/glass/beaker/large/amanitin(src)
	new /obj/item/reagent_containers/glass/beaker/large/condensedcapsaicin(src)
	new /obj/item/reagent_containers/glass/beaker/large/amatoxin(src)
	new /obj/item/reagent_containers/glass/beaker/large/lexorin(src)
	new /obj/item/reagent_containers/glass/beaker/large/slimejelly(src)
	new /obj/item/reagent_containers/glass/beaker/large/spore_burning(src)
	new /obj/item/reagent_containers/glass/beaker/large/mutetoxin(src)
	new /obj/item/reagent_containers/glass/beaker/large/staminatoxin(src)
	new /obj/item/reagent_containers/glass/beaker/large/sulfonal(src)
	new /obj/item/reagent_containers/glass/beaker/large/lipolicide(src)
	new /obj/item/reagent_containers/glass/beaker/large/heparin(src)
	new /obj/item/reagent_containers/glass/beaker/large/rotatium(src)
	new /obj/item/reagent_containers/glass/beaker/large/anacea(src)
	new /obj/item/reagent_containers/glass/beaker/large/acid(src)
	new /obj/item/reagent_containers/glass/beaker/large/fluacid(src)
	new /obj/item/reagent_containers/glass/beaker/large/nitracid(src)
	new /obj/item/reagent_containers/glass/beaker/large/delayed(src)
	new /obj/item/reagent_containers/glass/beaker/large/bungotoxin(src)
	new /obj/item/reagent_containers/glass/beaker/large/leadacetate(src)
	new /obj/item/reagent_containers/glass/beaker/large/teslium(src)


/obj/item/storage/box/syndie_kit/boxed_dehydrated_carp/PopulateContents()
	for(var/i in 1 to 8)
		new /obj/item/toy/plush/carpplushie/dehy_carp(src)


/obj/item/storage/box/syndie_kit/fourtyfivemmmagbox/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m45(src)


/obj/item/storage/box/syndie_kit/fourtyfivemmmagboxcs/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m45/cs(src)


/obj/item/storage/box/syndie_kit/fourtyfivemmmagboxsp/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m45/sp(src)


/obj/item/storage/box/syndie_kit/explosivemines/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/deployablemine/explosive(src)


/obj/item/storage/box/syndie_kit/rapidmine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/deployablemine/rapid(src)


/obj/item/storage/box/syndie_kit/heavymine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/deployablemine/heavy(src)


/obj/item/storage/box/syndie_kit/plasmafiremine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/deployablemine/plasma(src)


/obj/item/storage/box/syndie_kit/sleepymine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/deployablemine/sleepy(src)


/obj/item/storage/box/syndie_kit/syndiefirearmauth/PopulateContents()
	new /obj/item/implanter/weapons_auth(src)
//IMPORTED FROM FULP
/obj/item/storage/box/syndie_kit/stickers
	name = "sticker kit"

/obj/item/storage/box/syndie_kit/stickers/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8

/obj/item/storage/box/syndie_kit/stickers/PopulateContents()
	var/list/types = subtypesof(/obj/item/sticker/syndicate)
	for(var/i in 1 to 8)
		var/type = pick(types)
		new type(src)
//New stuff cont.
/obj/item/storage/box/syndie_kit/operative_chemical_plant
	name = "Support Setup: Chemical Plant"

/obj/item/storage/box/syndie_kit/operative_chemical_plant/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 27

/obj/item/storage/box/syndie_kit/operative_chemical_plant/PopulateContents()
	new /obj/item/circuitboard/machine/chem_dispenser(src)
	new /obj/item/circuitboard/machine/chem_heater(src)
	new /obj/item/circuitboard/machine/chem_master(src)
	new /obj/item/circuitboard/machine/reagentgrinder(src)
	new /obj/item/stack/sheet/metal/twenty(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stock_parts/micro_laser/quadultra(src)
	new /obj/item/stock_parts/capacitor/quadratic(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/matter_bin/bluespace(src)
	new /obj/item/stock_parts/matter_bin/bluespace(src)
	new /obj/item/stock_parts/cell/bluespace(src)
	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/glass(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/wrench(src)
	new /obj/item/screwdriver(src)
	new /obj/item/storage/box/beakers(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/box/beakers/bluespace(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/box/beakers/variety(src)


/obj/item/storage/box/syndie_kit/operative_nanite_lab
	name = "Support Setup: Nanite Lab"

/obj/item/storage/box/syndie_kit/operative_nanite_lab/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 30

/obj/item/storage/box/syndie_kit/operative_nanite_lab/PopulateContents()
	new /obj/item/circuitboard/computer/nanite_chamber_control(src)
	new /obj/item/circuitboard/machine/nanite_chamber(src)
	new /obj/item/circuitboard/machine/nanite_program_hub(src)
	new /obj/item/circuitboard/machine/nanite_programmer(src)
	new /obj/item/circuitboard/computer/nanite_cloud_controller(src)
	new /obj/item/stack/sheet/metal/twenty(src)
	new /obj/item/stack/sheet/metal/five(src)
	for(var/i in 1 to 4)
		new /obj/item/stack/sheet/glass(src)
	new /obj/item/stack/cable_coil(src)
	for(var/i in 1 to 4)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
	for(var/i in 1 to 4)
		new /obj/item/stock_parts/manipulator/femto(src)
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
	new /obj/item/stock_parts/matter_bin/bluespace(src)
	new /obj/item/wrench(src)
	new /obj/item/screwdriver(src)
	new /obj/item/nanite_scanner(src)
	new /obj/item/nanite_remote(src)
	new /obj/item/storage/box/disks_nanite_full(src)
	new /obj/item/clothing/glasses/hud/diagnostic(src)
	for(var/i in 1 to 3)
		new /obj/item/organ/heart/nanite(src)
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/glass/bottle/naniterestoration(src)


/obj/item/storage/box/disks_nanite_random
	name = "nanite program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_random/PopulateContents()
	var/list/types = subtypesof(/obj/item/disk/nanite_program/)
	for(var/i in 1 to 6)
		var/type = pick(types)
		new type(src)

/obj/item/storage/box/disks_nanite_full
	name = "nanite program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_full/PopulateContents()
	new /obj/item/storage/box/disks_nanite_sensor(src)
	new /obj/item/storage/box/disks_nanite_utility(src)
	new /obj/item/storage/box/disks_nanite_healing(src)
	new /obj/item/storage/box/disks_nanite_augment(src)
	new /obj/item/storage/box/disks_nanite_weapon(src)
	new /obj/item/storage/box/disks_nanite_suppress(src)
	new /obj/item/storage/box/disks_nanite_glitch(src)
	new /obj/item/storage/box/disks_nanite_experi(src)
	new /obj/item/storage/box/disks_nanite_construct(src)
	new /obj/item/storage/box/disks_nanite_illegal(src)

/obj/item/storage/box/disks_nanite_sensor
	name = "nanite sensor program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_sensor/PopulateContents()
	new /obj/item/disk/nanite_program/sensor_health(src)
	new /obj/item/disk/nanite_program/sensor_damage(src)
	new /obj/item/disk/nanite_program/sensor_crit(src)
	new /obj/item/disk/nanite_program/sensor_death(src)
	new /obj/item/disk/nanite_program/sensor_voice(src)
	new /obj/item/disk/nanite_program/sensor_race(src)
	new /obj/item/disk/nanite_program/sensor__nanite_volume(src)

/obj/item/storage/box/disks_nanite_utility
	name = "nanite utility program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_utility/PopulateContents()
	new /obj/item/disk/nanite_program/metabolic_synthesis(src)
	new /obj/item/disk/nanite_program/research(src)
	new /obj/item/disk/nanite_program/researchplus(src)
	new /obj/item/disk/nanite_program/viral(src)
	new /obj/item/disk/nanite_program/monitoring(src)
	new /obj/item/disk/nanite_program/self_scan(src)
	new /obj/item/disk/nanite_program/stealth(src)
	new /obj/item/disk/nanite_program/relay(src)
	new /obj/item/disk/nanite_program/repeater(src)
	new /obj/item/disk/nanite_program/relay_repeater(src)
	new /obj/item/disk/nanite_program/access(src)
	new /obj/item/disk/nanite_program/dermal_button(src)
	new /obj/item/disk/nanite_program/mitosis(src)
	new /obj/item/disk/nanite_program/spreading(src)

/obj/item/storage/box/disks_nanite_healing
	name = "nanite healing program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_healing/PopulateContents()
	new /obj/item/disk/nanite_program/regenerative(src)
	new /obj/item/disk/nanite_program/temperature(src)
	new /obj/item/disk/nanite_program/purging(src)
	new /obj/item/disk/nanite_program/brain_heal(src)
	new /obj/item/disk/nanite_program/blood_restoring(src)
	new /obj/item/disk/nanite_program/repairing(src)
	new /obj/item/disk/nanite_program/purging_advanced(src)
	new /obj/item/disk/nanite_program/regenerative_advanced(src)
	new /obj/item/disk/nanite_program/brain_heal_advanced(src)
	new /obj/item/disk/nanite_program/defib(src)

/obj/item/storage/box/disks_nanite_augment
	name = "nanite augmentation program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_augment/PopulateContents()
	new /obj/item/disk/nanite_program/nervous(src)
	new /obj/item/disk/nanite_program/hardening(src)
	new /obj/item/disk/nanite_program/refractive(src)
	new /obj/item/disk/nanite_program/coagulating(src)
	new /obj/item/disk/nanite_program/conductive(src)
	new /obj/item/disk/nanite_program/mindshield(src)

/obj/item/storage/box/disks_nanite_weapon
	name = "nanite weaponized program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_weapon/PopulateContents()
	new /obj/item/disk/nanite_program/necrotic(src)
	new /obj/item/disk/nanite_program/toxic(src)
	new /obj/item/disk/nanite_program/memory_leak(src)
	new /obj/item/disk/nanite_program/aggressive_replication(src)
	new /obj/item/disk/nanite_program/meltdown(src)
	new /obj/item/disk/nanite_program/explosive(src)
	new /obj/item/disk/nanite_program/heart_stop(src)
	new /obj/item/disk/nanite_program/emp(src)
	new /obj/item/disk/nanite_program/pyro(src)
	new /obj/item/disk/nanite_program/cryo(src)

/obj/item/storage/box/disks_nanite_suppress
	name = "nanite suppression program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_suppress/PopulateContents()
	new /obj/item/disk/nanite_program/sleepy(src)
	new /obj/item/disk/nanite_program/shock(src)
	new /obj/item/disk/nanite_program/stun(src)
	new /obj/item/disk/nanite_program/pacifying(src)
	new /obj/item/disk/nanite_program/blinding(src)
	new /obj/item/disk/nanite_program/mute(src)
	new /obj/item/disk/nanite_program/speech(src)
	new /obj/item/disk/nanite_program/voice(src)
	new /obj/item/disk/nanite_program/hallucination(src)

/obj/item/storage/box/disks_nanite_glitch
	name = "nanite glitched program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_glitch/PopulateContents()
	new /obj/item/disk/nanite_program/glitch(src)
	new /obj/item/disk/nanite_program/necrotic(src)
	new /obj/item/disk/nanite_program/toxic(src)
	new /obj/item/disk/nanite_program/suffocating(src)
	new /obj/item/disk/nanite_program/brain_decay(src)
	new /obj/item/disk/nanite_program/brain_misfire(src)
	new /obj/item/disk/nanite_program/skin_decay(src)
	new /obj/item/disk/nanite_program/nerve_decay(src)

/obj/item/storage/box/disks_nanite_experi
	name = "nanite experimental program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_experi/PopulateContents()
	new /obj/item/disk/nanite_program/accelerated_synthesis(src)
	new /obj/item/disk/nanite_program/fake_death(src)
	new /obj/item/disk/nanite_program/bodily_augment(src)
	new /obj/item/disk/nanite_program/sticky_fingers(src)
	new /obj/item/disk/nanite_program/bluespace_blood(src)
	new /obj/item/disk/nanite_program/speedboost(src)
	new /obj/item/disk/nanite_program/extinguisher(src)
	new /obj/item/disk/nanite_program/antishove(src)

/obj/item/storage/box/disks_nanite_construct
	name = "nanite constructive program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_construct/PopulateContents()
	new /obj/item/disk/nanite_program/convert_nanites(src)
	new /obj/item/disk/nanite_program/construct_tool(src)
	new /obj/item/disk/nanite_program/construct_tool_adv(src)
	new /obj/item/disk/nanite_program/construct_tool_super(src)
	new /obj/item/disk/nanite_program/botsummon(src)

/obj/item/storage/box/disks_nanite_illegal
	name = "nanite illegal program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite_illegal/PopulateContents()
	new /obj/item/disk/nanite_program/freedom(src)
	new /obj/item/disk/nanite_program/construct_ammo(src)
	new /obj/item/disk/nanite_program/construct_c4(src)
	new /obj/item/disk/nanite_program/slipresist(src)
	new /obj/item/disk/nanite_program/braintrauma(src)
	new /obj/item/disk/nanite_program/antidisarm(src)
	new /obj/item/disk/nanite_program/paralysis(src)
	new /obj/item/disk/nanite_program/suicidal(src)


/obj/item/storage/box/syndie_kit/construction_bundle_deluxe
	name = "Construction Package Deluxe"

/obj/item/storage/box/syndie_kit/construction_bundle_deluxe/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 20

/obj/item/storage/box/syndie_kit/construction_bundle_deluxe/PopulateContents()
	new /obj/item/stack/sheet/metal/fifty(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/sheet/rglass/fifty(src)
	new /obj/item/stack/sheet/plasmaglass/fifty(src)
	new /obj/item/stack/sheet/titaniumglass/fifty(src)
	new /obj/item/stack/sheet/plastitaniumglass/fifty(src)
	new /obj/item/stack/sheet/plasteel/fifty(src)
	new /obj/item/stack/sheet/mineral/plastitanium/fifty(src)
	new /obj/item/stack/sheet/mineral/titanium/fifty(src)
	new /obj/item/stack/sheet/mineral/gold/fifty(src)
	new /obj/item/stack/sheet/mineral/silver/fifty(src)
	new /obj/item/stack/sheet/mineral/plasma/fifty(src)
	new /obj/item/stack/sheet/mineral/uranium/fifty(src)
	new /obj/item/stack/sheet/mineral/diamond/fifty(src)
	for(var/i in 1 to 50)
		new /obj/item/stack/sheet/bluespace_crystal(src)
	for(var/i in 1 to 50)
		new /obj/item/stack/sheet/dilithium_crystal(src)
	new /obj/item/stack/sheet/mineral/bananium/fifty(src)
	new /obj/item/stack/sheet/mineral/wood/fifty(src)
	new /obj/item/stack/sheet/plastic/fifty(src)


/obj/item/storage/box/syndie_kit/syndiecake_bundle/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/food/snacks/syndicake/super(src)


/obj/item/storage/box/syndie_kit/operative_genetics_lab
	name = "Support Setup: Genetics Lab"

/obj/item/storage/box/syndie_kit/operative_genetics_lab/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 20

/obj/item/storage/box/syndie_kit/operative_genetics_lab/PopulateContents()
	new /obj/item/circuitboard/computer/scan_consolenew(src)
	new /obj/item/circuitboard/machine/clonescanner(src)
	new /obj/item/stack/sheet/metal/ten(src)
	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/glass(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stock_parts/micro_laser/quadultra(src)
	new /obj/item/stock_parts/matter_bin/bluespace(src)
	new /obj/item/stock_parts/scanning_module/triphasic(src)
	new /obj/item/wrench(src)
	new /obj/item/screwdriver(src)
	new /obj/item/storage/pill_bottle/mutadone(src)
	new /obj/item/storage/pill_bottle/mannitol(src)
	new /obj/item/storage/box/monkeycubes(src)
	new /obj/item/gun/syringe/dna(src)

	var/list/item_list = list(
		/obj/item/dnainjector/hulkmut,
		/obj/item/dnainjector/firebreath,
		/obj/item/dnainjector/acidspit,
		/obj/item/dnainjector/xraymut,
		/obj/item/dnainjector/dwarf,
		/obj/item/dnainjector/ravenous,
		/obj/item/dnainjector/clumsymut,
		/obj/item/dnainjector/spacemut,
		/obj/item/dnainjector/radiantburst,
		/obj/item/dnainjector/heatmut,
		/obj/item/dnainjector/blindmut,
		/obj/item/dnainjector/telemut,
		/obj/item/dnainjector/deafmut,
		/obj/item/dnainjector/h2m,
		/obj/item/dnainjector/chameleonmut,
		/obj/item/dnainjector/mutemut,
		/obj/item/dnainjector/lasereyesmut,
		/obj/item/dnainjector/void,
		/obj/item/dnainjector/mindread,
		/obj/item/dnainjector/radioactive,
		/obj/item/dnainjector/radproof,
		/obj/item/dnainjector/insulated,
		/obj/item/dnainjector/shock,
		/obj/item/dnainjector/spacialinstability,
		/obj/item/dnainjector/acidflesh,
		/obj/item/dnainjector/twoleftfeet,
		/obj/item/dnainjector/geladikinesis,
		/obj/item/dnainjector/thermal,
		/obj/item/dnainjector/fierysweat,
		/obj/item/dnainjector/thickskin,
		/obj/item/dnainjector/densebones
	)

	for(var/i in 1 to 6)
		var/item = pick(item_list)
		new item(src)


/obj/item/storage/box/syndie_kit/resupplybeacon_implant/PopulateContents()
	new /obj/item/implanter/clerksignaller(src)


/obj/item/storage/box/syndie_kit/goloudbeaconbundle
	name = "NT-Annihilation 'Go Loud' Kit"

/obj/item/storage/box/syndie_kit/goloudbeaconbundle/PopulateContents()
	new /obj/item/stack/telecrystal/twenty(src)
	new /obj/item/stack/telecrystal/five(src)
	new /obj/item/stack/telecrystal/five(src)
	new /obj/item/stack/telecrystal/five(src)
	new /obj/item/pen/red/edagger(src)
	new /obj/item/reagent_containers/autoinjector/medipen/atropine(src)


/obj/item/storage/box/syndie_kit/spininverters/PopulateContents()
	new /obj/item/swapper(src)
	new /obj/item/swapper(src)


/obj/item/storage/box/syndie_kit/operative_virology_package
	name = "Virology Package"

/obj/item/storage/box/syndie_kit/operative_virology_package/PopulateContents()
	new /obj/item/circuitboard/computer/pandemic(src)
	new /obj/item/storage/box/syndie_kit/syndicate_virus_box(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/mutagen(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/plasma(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/synaptizine(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/formaldehyde(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/mutagenvirusfood(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/mutagenvirusfoodsugar(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/synaptizinevirusfood(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/plasmavirusfood(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/plasmavirusfoodweak(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/uraniumvirusfood(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/uraniumvirusfoodunstable(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/uraniumvirusfoodstable(src)
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/syringe/antiviral(src)
	new /obj/item/reagent_containers/dropper(src)


/obj/item/storage/box/syndie_kit/operative_hydroponics_package
	name = "Hydroponics Package"

/obj/item/storage/box/syndie_kit/operative_hydroponics_package/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/circuitboard/machine/hydroponics(src)
	new /obj/item/circuitboard/machine/biogenerator(src)
	new /obj/item/circuitboard/machine/seed_extractor(src)
	new /obj/item/circuitboard/machine/plantgenes(src)
	new /obj/item/circuitboard/machine/smartfridge(src)
	for(var/i in 1 to 2)
		new /obj/item/circuitboard/machine/vendor(src)
	new /obj/item/vending_refill/hydroseeds(src)
	new /obj/item/vending_refill/hydronutrients(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/storage/bag/plantssyndie(src)
	new /obj/item/storage/box/disks_plantgene(src)
	new /obj/item/reagent_containers/spray/plantbgone(src)


/obj/item/storage/box/syndie_kit/operative_xenobiology_package
	name = "Xenobiology Package"

/obj/item/storage/box/syndie_kit/operative_xenobiology_package/PopulateContents()
	new /obj/item/circuitboard/computer/xenobiology(src)
	new /obj/item/circuitboard/machine/processor/slime(src)
	new /obj/item/circuitboard/machine/monkey_recycler(src)
	new /obj/item/storage/box/syndie_kit/xenobio_starter_kit(src)
	for(var/i in 1 to 5)
		new /obj/item/extinguisher(src)
	for(var/i in 1 to 5)
		new /obj/item/slime_extract/grey(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/glass/bottle/plasma(src)
	new /obj/item/reagent_containers/dropper(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/burning_extract_bundle(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/charged_extract_bundle(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/chilling_extract_bundle(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/consuming_extract_bundle(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/industrial_extract_bundle(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/regenerative_extract_bundle(src)
	if(prob(50))
		new /obj/item/storage/box/syndie_kit/stabilized_extract_bundle(src)


/obj/item/storage/box/syndie_kit/operative_bioweapon_lab
	name = "Support Setup: Bio-Weapon Laboratory"


/obj/item/storage/box/syndie_kit/operative_bioweapon_lab/PopulateContents()
	new /obj/item/storage/box/syndie_kit/operative_virology_package(src)
	new /obj/item/storage/box/syndie_kit/operative_hydroponics_package(src)
	new /obj/item/storage/box/syndie_kit/operative_xenobiology_package(src)
	for(var/i in 1 to 9)
		new /obj/item/stack/sheet/metal/ten(src)
	new /obj/item/stack/sheet/glass/fifty(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil(src)
	for(var/i in 1 to 15)
		new /obj/item/stock_parts/matter_bin/bluespace(src)
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/manipulator/femto(src)
	new /obj/item/stock_parts/scanning_module/triphasic(src)
	new /obj/item/stock_parts/micro_laser/quadultra(src)
	new /obj/item/wrench(src)
	new /obj/item/screwdriver(src)
	new /obj/item/stack/spacecash/c1000(src)


/obj/item/storage/box/syndie_kit/adrenalineimplant/PopulateContents()
	new /obj/item/implanter/adrenalin(src)


/obj/item/storage/box/syndie_kit/restore_nanite_kit/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/autoinjector/medipen/restorationnaniteinjector(src)

/obj/item/storage/box/syndie_kit/mutatekit
	name = "medical aid kit" // Mutation Toxin Kit
	icon = 'icons/fulpimport/obj/storage/medkit.dmi'
	icon_state = "medkit"

/obj/item/storage/box/syndie_kit/mutatekit/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12

/obj/item/storage/box/syndie_kit/mutatekit/PopulateContents()
	new /obj/item/reagent_containers/syringe/big/mutatehuman(src)
	new /obj/item/reagent_containers/syringe/big/mutateslime(src)
	new /obj/item/reagent_containers/syringe/big/mutatefelinid(src)
	new /obj/item/reagent_containers/syringe/big/mutatelizard(src)
	new /obj/item/reagent_containers/syringe/big/mutatefly(src)
	new /obj/item/reagent_containers/syringe/big/mutatemoth(src)
	new /obj/item/reagent_containers/syringe/big/mutatepod(src)
	new /obj/item/reagent_containers/syringe/big/mutateethereal(src)
	new /obj/item/reagent_containers/syringe/big/mutatepreternis(src)
	new /obj/item/reagent_containers/syringe/big/mutatepolysmorph(src)
	new /obj/item/reagent_containers/syringe/big/mutatejelly(src)
	new /obj/item/reagent_containers/syringe/big/mutateandroid(src)


/obj/item/storage/secure/briefcase/cargonia
	force = 25

/obj/item/storage/secure/briefcase/cargonia/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60
	regenerate_cash()

/obj/item/storage/secure/briefcase/cargonia/proc/regenerate_cash()
	addtimer(CALLBACK(src, PROC_REF(regenerate_cash)), 30 SECONDS)

	var/mob/M = get(loc, /mob)
	if(!istype(M))
		return
	if(is_syndicate(M))
		var/datum/component/storage/STR = GetComponent(/datum/component/storage)
		var/turf/floor = get_turf(src)
		var/obj/item/I = new /obj/item/stack/spacecash/c1000(floor)
		if(STR.can_be_inserted(I, stop_messages=TRUE))
			STR.handle_item_insertion(I, prevent_warning=TRUE)
		else
			qdel(I)


/obj/item/storage/secure/briefcase/luckywinner
	force = 15
	var/list/item_list = list(
		/obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/reagent_containers/food/drinks/soda_cans/rootbeer,
		/obj/item/reagent_containers/food/drinks/soda_cans/tonic,
		/obj/item/reagent_containers/food/drinks/soda_cans/sodawater,
		/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime,
		/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_up,
		/obj/item/reagent_containers/food/drinks/soda_cans/starkist,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko,
		/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game,
		/obj/item/reagent_containers/food/drinks/soda_cans/shamblers,
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull,
		/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy,
		/obj/item/reagent_containers/food/drinks/soda_cans/sprited_cranberry,
		/obj/item/reagent_containers/food/drinks/soda_cans/air,
		/obj/item/reagent_containers/food/drinks/soda_cans/buzz_fuzz,
		/obj/item/reagent_containers/food/drinks/soda_cans/mystery,
		/obj/item/reagent_containers/food/drinks/soda_cans/changelingsting,
		/obj/item/reagent_containers/food/drinks/soda_cans/devilskiss,
		/obj/item/reagent_containers/food/drinks/soda_cans/turbo,
		/obj/item/reagent_containers/food/drinks/soda_cans/hearty_punch,
		/obj/item/reagent_containers/food/drinks/soda_cans/robust_nukie,
		/obj/item/reagent_containers/food/drinks/soda_cans/fireball,
		/obj/item/reagent_containers/food/drinks/soda_cans/fireworks,
		/obj/item/reagent_containers/food/drinks/soda_cans/mutate_fizz,
		/obj/item/reagent_containers/food/drinks/soda_cans/aged_soda,
		/obj/item/reagent_containers/food/drinks/soda_cans/antidote,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_walker,
		/obj/item/reagent_containers/food/drinks/soda_cans/anti_water,
		/obj/item/reagent_containers/food/drinks/soda_cans/nano_pop,
		/obj/item/reagent_containers/food/drinks/soda_cans/ice_e,
		/obj/item/reagent_containers/food/drinks/soda_cans/simple_times,
		/obj/item/reagent_containers/food/drinks/soda_cans/chocolate_sips,
		/obj/item/reagent_containers/food/drinks/soda_cans/honey_med,
		/obj/item/reagent_containers/food/drinks/soda_cans/unstable_vortex,
		/obj/item/reagent_containers/food/drinks/soda_cans/clown_juice,
		/obj/item/reagent_containers/food/drinks/soda_cans/gold_soda,
		/obj/item/reagent_containers/food/drinks/soda_cans/sleepy_time,
		/obj/item/reagent_containers/food/drinks/soda_cans/nocturnal
	)

/obj/item/storage/secure/briefcase/luckywinner/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60
	regenerate_stock()

/obj/item/storage/secure/briefcase/luckywinner/proc/regenerate_stock()
	addtimer(CALLBACK(src, PROC_REF(regenerate_stock)), 30 SECONDS)

	var/mob/M = get(loc, /mob)
	if(!istype(M))
		return
	if(is_syndicate(M))
		var/datum/component/storage/STR = GetComponent(/datum/component/storage)
		var/turf/floor = get_turf(src)
		var/obj/item/Selected = pick(item_list)
		var/obj/item/I = new Selected(floor)
		//new item(floor)
		if(STR.can_be_inserted(I, stop_messages=TRUE))
			STR.handle_item_insertion(I, prevent_warning=TRUE)
		else
			qdel(I)


/obj/item/storage/secure/briefcase/bluespace
	force = 15
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	custom_price = 1000

/obj/item/storage/secure/briefcase/bluespace/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 60
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 60


/obj/item/storage/box/syndie_kit/syndirigcells/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/stock_parts/cell/syndirig(src)


/obj/item/storage/box/lights/mixed/syndirigged
	name = "box of replacement lights"
	illustration = "lightmixed"

/obj/item/storage/box/lights/mixed/syndirigged/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 14

/obj/item/storage/box/lights/mixed/syndirigged/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/light/tube/syndirig(src)
	for(var/i in 1 to 7)
		new /obj/item/light/bulb/syndirig(src)


/obj/item/storage/box/syndie_kit/killertomato/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/food/snacks/grown/tomato/killer(src)
	new /obj/item/seeds/tomato/killer(src)


/obj/item/storage/box/syndie_kit/trackingimplants/PopulateContents()
	new /obj/item/implanter/stealthimplanter/tracking(src)
	for(var/i in 1 to 5)
		new /obj/item/implantcase/tracking/syndicate(src)


/obj/item/storage/box/syndie_kit/riggedglowsticks/PopulateContents()
	var/list/types = subtypesof(/obj/item/flashlight/syndirig/glowstick/)
	for(var/i in 1 to 6)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/riggedplushies/PopulateContents()
	var/list/item_list = list(
		/obj/item/deployablemine/explosive/mothplushie,
		/obj/item/deployablemine/explosive/lizardplushie,
		/obj/item/deployablemine/explosive/carpplushie,
		/obj/item/deployablemine/explosive/bubbleplush,
		/obj/item/deployablemine/explosive/plushvar,
		/obj/item/deployablemine/explosive/narplush,
		/obj/item/deployablemine/explosive/nukeplushie,
		/obj/item/deployablemine/explosive/slimeplushie
	)

	for(var/i in 1 to 6)
		var/item = pick(item_list)
		new item(src)


/obj/item/storage/box/syndie_kit/weaponattachments
	name = "box"

/obj/item/storage/box/syndie_kit/weaponattachments/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6

/obj/item/storage/box/syndie_kit/weaponattachments/PopulateContents()
	new /obj/item/attachment/scope/simple(src)
	new /obj/item/attachment/scope/holo(src)
	new /obj/item/attachment/scope/infrared(src)
	new /obj/item/attachment/grip/vertical(src)
	new /obj/item/attachment/laser_sight(src)

	var/list/item_list = list(
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/ammo_box/magazine/tommygunm45,
		/obj/item/ammo_box/magazine/ak712x82
	)

	for(var/i in 1 to 1)
		var/item = pick(item_list)
		new item(src)


/obj/item/storage/box/monkeycubes/syndis
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/monkeycubes/syndis/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/monkeycube))

/obj/item/storage/box/monkeycubes/syndis/PopulateContents()
	var/list/item_list = list(
		/obj/item/reagent_containers/food/snacks/monkeycube/syndi,
		/obj/item/reagent_containers/food/snacks/monkeycube/syndi/sword,
		/obj/item/reagent_containers/food/snacks/monkeycube/syndi/ranged,
		/obj/item/reagent_containers/food/snacks/monkeycube/syndi/shotgun,
		/obj/item/reagent_containers/food/snacks/monkeycube/syndi/smg
	)

	for(var/i in 1 to 6)
		var/item = pick(item_list)
		new item(src)


/obj/item/storage/box/syndie_kit/trappeddisks/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/computer_hardware/hard_drive/portable/syndicate/trap(src)


/obj/item/storage/box/syndie_kit/piratekit
	name = "Pirate Kit"

/obj/item/storage/box/syndie_kit/piratekit/PopulateContents()
	new /obj/item/gun/ballistic/handcannon/syndicate(src)
	for(var/i in 1 to 4)
		new /obj/item/ammo_casing/caseless/cannonball(src)
	new /obj/item/book/granter/crafting_recipe/syndipiratemanual(src)


/obj/item/storage/box/syndie_kit/riggedglitterbombs
	name = "Box of Explosive Glitterbombs"

/obj/item/storage/box/syndie_kit/riggedglitterbombs/PopulateContents()
	var/list/item_list = list(
		/obj/item/grenade/chem_grenade/pyro/glitter/explosive/pink,
		/obj/item/grenade/chem_grenade/pyro/glitter/explosive/blue,
		/obj/item/grenade/chem_grenade/pyro/glitter/explosive/white
	)

	for(var/i in 1 to 5)
		var/item = pick(item_list)
		new item(src)


/obj/item/storage/box/syndie_kit/stealthmicrobomb/PopulateContents()
	new /obj/item/implanter/stealthimplanter/explosive(src)


/obj/item/storage/firstaid/emergency/combatmedipens/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/autoinjector/medipen/combatmedicine(src)


/obj/item/storage/bag/chemistry/syndimedipens/PopulateContents()
	new /obj/item/reagent_containers/autoinjector/medipen/combatmedicine(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/autoinjector/medipen/cardiaccs(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/autoinjector/medipen/bloodlosscs(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/autoinjector/medipen/lifesupportcs(src)

/obj/item/storage/bag/chemistry/syndimedipens/deluxe/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/autoinjector/medipen/combatmedicine(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/autoinjector/medipen/cardiaccs(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/autoinjector/medipen/bloodlosscs(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/autoinjector/medipen/lifesupportcs(src)


/obj/item/storage/box/syndie_kit/synditoykit
	name = "syndicate snack box"
	desc = "A single cardboard box designed to hold various snacks. Loved by syndicate agents everywhere."
	icon = 'icons/myimports/storage.dmi'
	icon_state = "nukietoy"

/obj/item/storage/box/syndie_kit/synditoykit/PopulateContents()
	new /obj/item/reagent_containers/food/drinks/soda_cans/robust_nukie(src)
	new /obj/item/reagent_containers/food/snacks/syndicake(src)

	var/list/types = subtypesof(/obj/item/reagent_containers/food/)
	for(var/i in 1 to 4)
		var/type = pick(types)
		new type(src)


/obj/item/storage/box/syndie_kit/syndisauce/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/condiment/pack/syndicate(src)


/obj/item/storage/box/syndie_kit/syndikey/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/encryptionkey/syndicate(src)


/obj/item/storage/box/syndie_kit/waspimplant/PopulateContents()
	new /obj/item/implanter/wasps(src)

/obj/item/storage/box/syndie_kit/waspimplantmacro/PopulateContents()
	new /obj/item/implanter/wasps/macro(src)

/obj/item/storage/box/syndie_kit/teslaimplant/PopulateContents()
	new /obj/item/implanter/tesla(src)

/obj/item/storage/box/syndie_kit/teslaimplantmacro/PopulateContents()
	new /obj/item/implanter/tesla/macro(src)


/obj/item/storage/box/syndie_kit/syndifulton/PopulateContents()
	new /obj/item/book/granter/crafting_recipe/syndifultons(src)
	for(var/i in 1 to 2)
		new /obj/item/extraction_pack/syndicate(src)
	for(var/i in 1 to 2)
		new /obj/item/fulton_core/syndicate(src)





