/datum/supply_pack/materials
	group = "Canisters & Materials"

/datum/supply_pack/materials/cardboard50
	name = "50 листов картона"
	desc = "Создайте кучу коробок."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/cardboard/fifty)
	crate_name = "ящик листов картона"

/datum/supply_pack/materials/license50
	name = "50 пустых номерных знаков"
	desc = "Создайте кучу номерных знаков."
	cost = CARGO_CRATE_VALUE * 2  // 50 * 25 + 700 - 1000 = 950 credits profit
	access_view = ACCESS_BRIG_ENTRANCE
	contains = list(/obj/item/stack/license_plates/empty/fifty)
	crate_name = "ящик пустых номерных знаков"

/datum/supply_pack/materials/plastic50
	name = "50 листов пластика"
	desc = "Соберите множество игрушек из пятьдесяти листов пластика!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/plastic/fifty)
	crate_name = "ящик листов пластика"

/datum/supply_pack/materials/sandstone30
	name = "30 песчаных блоков"
	desc = "Не песок, но и не камень, эти тридцать блоков всё равно справятся с поставленной задачей."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/mineral/sandstone/thirty)
	crate_name = "ящик песчаных блоков"

/datum/supply_pack/materials/wood50
	name = "50 досок"
	desc = "Превратите скучный металлический пол отдела в красивый\
		деревянный паркет и многое другое при помощи этих пятидесяти досок!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "ящик досок"

/datum/supply_pack/materials/foamtank
	name = "Ящик с канистрой пены для пожаротушения"
	desc = "Содержит канистру пены для пожаротушения. Также известной как \"бич плазмаменов\"."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/structure/reagent_dispensers/foamtank)
	crate_name = "ящик с канистрой пены для пожаротушения"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/fueltank
	name = "Ящик с канистрой топлива"
	desc = "Содержит топливный бак для сварки. Осторожно, легко воспламеняется."
	cost = CARGO_CRATE_VALUE * 1.6
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	crate_name = "ящик с канистрой топлива"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/hightankfuel
	name = "Ящик с большой канистрой топлива"
	desc = "Содержит крупный топливный бак для сварки. Держите подальше от открытого огня."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/structure/reagent_dispensers/fueltank/large)
	crate_name = "ящик с большой канистрой топлива"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/watertank
	name = "Ящик с канистрой воды"
	desc = "Содержит канистру с дигидромонооксидом... звучит крайне опасно."
	cost = CARGO_CRATE_VALUE * 1.2
	contains = list(/obj/structure/reagent_dispensers/watertank)
	crate_name = "ящик с канистрой воды"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/gas_canisters
	cost = CARGO_CRATE_VALUE * 0.05
	contains = list(/obj/machinery/portable_atmospherics/canister)
	crate_type = /obj/structure/closet/crate/large
	test_ignored = TRUE

/datum/supply_pack/materials/gas_canisters/generate_supply_packs()
	var/list/canister_packs = list()

	var/obj/machinery/portable_atmospherics/canister/fakeCanister = /obj/machinery/portable_atmospherics/canister
	// This is the amount of moles in a default canister
	var/moleCount = (initial(fakeCanister.maximum_pressure) * initial(fakeCanister.filled)) * initial(fakeCanister.volume) / (R_IDEAL_GAS_EQUATION * T20C)

	for(var/gasType in GLOB.meta_gas_info)
		var/datum/gas/gas = gasType
		var/name = initial(gas.name)
		if(!initial(gas.purchaseable))
			continue
		var/datum/supply_pack/materials/pack = new
		pack.name = "Канистра [name]"
		pack.desc = "Содержит канистру [name]."
		if(initial(gas.dangerous))
			pack.access = ACCESS_ATMOSPHERICS
			pack.access_view = ACCESS_ATMOSPHERICS
		pack.crate_name = "ящик с канистрой [name]"
		pack.id = "[type]([name])"

		pack.cost = cost + moleCount * initial(gas.base_value) * 1.6
		pack.cost = CEILING(pack.cost, 10)

		pack.test_ignored = FALSE

		pack.contains = list(GLOB.gas_id_to_canister[initial(gas.id)])

		pack.crate_type = crate_type

		canister_packs += pack

	return canister_packs
