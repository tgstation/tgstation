/// One of the potential shuttle loans you might receive.
/datum/shuttle_loan_situation
	/// Who sent the shuttle
	var/sender = "Центральное Командование"
	/// What they said about it.
	var/announcement_text = "Unset announcement text"
	/// What the shuttle says about it.
	var/shuttle_transit_text = "Unset transit text"
	/// Supply points earned for taking the deal.
	var/bonus_points = CARGO_CRATE_VALUE * 50
	/// Response for taking the deal.
	var/thanks_msg = "Грузовой шаттл должен вернуться через пять минут. За ваши хлопоты будут начислены бонусные очки снабжения."
	/// Small description of the loan for easier log reading.
	var/logging_desc

/datum/shuttle_loan_situation/New()
	. = ..()
	if(!logging_desc)
		stack_trace("No logging blurb set for [src.type]!")
	if(HAS_TRAIT(SSstation, STATION_TRAIT_LOANER_SHUTTLE))
		bonus_points *= 1.15

/// Spawns paths added to `spawn_list`, and passes empty shuttle turfs so you can spawn more complicated things like dead bodies.
/datum/shuttle_loan_situation/proc/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented get_spawned_items() on [src.type].")

/datum/shuttle_loan_situation/antidote
	sender = "Центральное Командование: Научно-исследовательский центр"
	announcement_text = "Ваша станция была выбрана для проведения эпидемиологического исследования. Пришлите нам свой грузовой шаттл, чтобы получить образцы для исследования."
	shuttle_transit_text = "Орбразцы вирусов в пути."
	logging_desc = "Virus shuttle"

/datum/shuttle_loan_situation/antidote/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/obj/effect/mob_spawn/corpse/human/assistant/infected_assistant = pick(list(
		/obj/effect/mob_spawn/corpse/human/assistant/beesease_infection,
		/obj/effect/mob_spawn/corpse/human/assistant/brainrot_infection,
		/obj/effect/mob_spawn/corpse/human/assistant/spanishflu_infection,
	))
	for(var/i in 1 to 10)
		if(prob(15))
			spawn_list.Add(/obj/item/reagent_containers/cup/bottle)
		else if(prob(15))
			spawn_list.Add(/obj/item/reagent_containers/syringe)
		else if(prob(25))
			spawn_list.Add(/obj/item/shard)
		var/turf/assistant_turf = pick_n_take(empty_shuttle_turfs)
		new infected_assistant(assistant_turf)
	spawn_list.Add(/obj/structure/closet/crate)
	spawn_list.Add(/obj/item/reagent_containers/cup/bottle/pierrot_throat)
	spawn_list.Add(/obj/item/reagent_containers/cup/bottle/magnitis)

/datum/shuttle_loan_situation/department_resupply
	sender = "Центральное Командование: Отдел снабжения"
	announcement_text = "Кажется, в этом месяце мы заказали в два раза больше пакетов пополнения для нашего отдела. Мы можем отправить их вам?"
	shuttle_transit_text = "Пополнение для департаментов в пути."
	thanks_msg = "Грузовой шаттл должен вернуться через пять минут."
	bonus_points = 0
	logging_desc = "Resupply packages"

/datum/shuttle_loan_situation/department_resupply/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/list/crate_types = list(
		/datum/supply_pack/emergency/equipment,
		/datum/supply_pack/security/supplies,
		/datum/supply_pack/organic/food,
		/datum/supply_pack/emergency/weedcontrol,
		/datum/supply_pack/engineering/tools,
		/datum/supply_pack/engineering/engiequipment,
		/datum/supply_pack/science/robotics,
		/datum/supply_pack/science/plasma,
		/datum/supply_pack/medical/supplies
		)
	for(var/crate in crate_types)
		var/datum/supply_pack/pack = SSshuttle.supply_packs[crate]
		pack.generate(pick_n_take(empty_shuttle_turfs))

	for(var/i in 1 to 5)
		var/decal = pick(/obj/effect/decal/cleanable/food/flour, /obj/effect/decal/cleanable/blood/gibs/robot_debris, /obj/effect/decal/cleanable/blood/oil)
		new decal(pick_n_take(empty_shuttle_turfs))

/datum/shuttle_loan_situation/syndiehijacking
	sender = "Центральное Командование: Контрразведка"
	announcement_text = "Синдикат пытается проникнуть на вашу станцию. Если вы позволите им захватить ваш грузовой шаттл, вы избавите нас от головной боли."
	shuttle_transit_text = "Команда захвата Синдиката в пути."
	logging_desc = "Syndicate boarding party"

/datum/shuttle_loan_situation/syndiehijacking/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/imports/specialops]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/mob/living/basic/trooper/syndicate/ranged/infiltrator)
	spawn_list.Add(/mob/living/basic/trooper/syndicate/ranged/infiltrator)
	if(prob(75))
		spawn_list.Add(/mob/living/basic/trooper/syndicate/ranged/infiltrator)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/trooper/syndicate/ranged/infiltrator)

/datum/shuttle_loan_situation/lots_of_bees
	sender = "Центральное Командование: Отдел по уборке"
	announcement_text = "Один из наших грузовых кораблей, перевозивший груз пчел, подвергся нападению экотеррористов. Вы можете навести порядок?"
	shuttle_transit_text = "Зараженный шаттл в пути."
	bonus_points = CARGO_CRATE_VALUE * 100 //Toxin bees can be unbeelievably lethal
	logging_desc = "Shuttle full of bees"

/datum/shuttle_loan_situation/lots_of_bees/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/organic/hydroponics/beekeeping_fullkit]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/bee_terrorist)
	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/cargo_tech)
	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/cargo_tech)
	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	spawn_list.Add(/obj/item/gun/ballistic/automatic/pistol/no_mag)
	spawn_list.Add(/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/structure/beebox/unwrenched)
	spawn_list.Add(/obj/item/queen_bee/bought)
	spawn_list.Add(/obj/structure/closet/crate/hydroponics)

	for(var/i in 1 to 8)
		spawn_list.Add(/mob/living/basic/bee/toxin)

	for(var/i in 1 to 5)
		var/decal = pick(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/insectguts)
		new decal(pick_n_take(empty_shuttle_turfs))

	for(var/i in 1 to 10)
		var/casing = /obj/item/ammo_casing/spent
		new casing(pick_n_take(empty_shuttle_turfs))

/datum/shuttle_loan_situation/jc_a_bomb
	sender = "Отдел безопасности Центрального Командования"
	announcement_text = "Мы обнаружили активированную бомбу Синдиката рядом с топливопроводами нашего ВИП-шаттла. Если вы справитесь с задачей, мы заплатим вам за ее обезвреживание."
	shuttle_transit_text = "Заминированный шаттл в пути. Соблюдайте предельную осторожность."
	thanks_msg = "На шаттле находится бомба. Рекомендуется эвакуировать отдел снабжения."
	bonus_points = CARGO_CRATE_VALUE * 225 //If you mess up, people die and the shuttle gets turned into swiss cheese
	logging_desc = "Shuttle with a ticking bomb"

/datum/shuttle_loan_situation/jc_a_bomb/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	spawn_list.Add(/obj/machinery/syndicatebomb/shuttle_loan)
	if(prob(95))
		spawn_list.Add(/obj/item/paper/fluff/cargo/bomb)
	else
		spawn_list.Add(/obj/item/paper/fluff/cargo/bomb/allyourbase)

/datum/shuttle_loan_situation/papers_please
	sender = "Центральное Командование: Отдел бюрократии"
	announcement_text = "Соседней станции нужна помощь с документами. Не могли бы вы помочь нам с оформлением?"
	shuttle_transit_text = "Документы в пути."
	thanks_msg = "Грузовой шаттл должен вернуться через пять минут. Оплата будет произведена после оформления и возвращения документов."
	bonus_points = 0 //Payout is made when the stamped papers are returned
	logging_desc = "Paperwork shipment"

/datum/shuttle_loan_situation/papers_please/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	spawn_list += subtypesof(/obj/item/paperwork) - typesof(/obj/item/paperwork/photocopy) - typesof(/obj/item/paperwork/ancient)

/datum/shuttle_loan_situation/pizza_delivery
	sender = "Центральное Командование: Отдел космопиццы"
	announcement_text = "Похоже, что соседняя станция случайно доставила вам свою пиццу."
	shuttle_transit_text = "Доставка пиццы!"
	thanks_msg = "Грузовой шаттл должен вернуться через пять минут."
	bonus_points = 0
	logging_desc = "Pizza delivery"

/datum/shuttle_loan_situation/pizza_delivery/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/naughtypizza = list(/obj/item/pizzabox/bomb, /obj/item/pizzabox/margherita/robo) //oh look another blacklist, for pizza nonetheless!
	var/nicepizza = list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/mushroom)
	for(var/i in 1 to 6)
		spawn_list.Add(pick(prob(5) ? naughtypizza : nicepizza))

/datum/shuttle_loan_situation/russian_party
	sender = "Центральное Командование: Программа по работе с русскими"
	announcement_text = "Группа злых русских хочет устроить вечеринку. Сможете ли вы отправить им свой грузовой шаттл, а затем избавиться от них?"
	shuttle_transit_text = "Пьяные русские уже в пути."
	logging_desc = "Russian party squad"

/datum/shuttle_loan_situation/russian_party/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/service/party]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/mob/living/basic/trooper/russian)
	spawn_list.Add(/mob/living/basic/trooper/russian/ranged) //drops a mateba
	spawn_list.Add(/mob/living/basic/bear/russian)
	if(prob(75))
		spawn_list.Add(/mob/living/basic/trooper/russian)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/bear/russian)

/datum/shuttle_loan_situation/spider_gift
	sender = "Центральное Командование: Дипломатический корпус"
	announcement_text = "Клан Паука прислал нам таинственный подарок. Можем ли мы отправить его вам, чтобы вы посмотрели, что внутри?"
	shuttle_transit_text = "Подарок от Клана Паука в пути."
	logging_desc = "Shuttle full of spiders"

/datum/shuttle_loan_situation/spider_gift/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/imports/specialops]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/mob/living/basic/spider/giant)
	spawn_list.Add(/mob/living/basic/spider/giant)
	spawn_list.Add(/mob/living/basic/spider/giant/nurse)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/spider/giant/hunter)

	var/turf/victim_turf = pick_n_take(empty_shuttle_turfs)

	new /obj/effect/decal/remains/human(victim_turf)
	new /obj/item/clothing/shoes/jackboots/fast(victim_turf)
	new /obj/item/clothing/mask/balaclava(victim_turf)

	for(var/i in 1 to 5)
		var/turf/web_turf = pick_n_take(empty_shuttle_turfs)
		new /obj/structure/spider/stickyweb(web_turf)

#define DENT_WALL "dent"
#define CHANGE_WALL "change"
#define DISMANTLE_WALL "dismantle"

#define BREAK_TILE "break"
#define PLATING_TILE "plating"
#define RUST_TILE "rust"

/**
 * A special shuttle loan situation enabled by the 'mail blocked' station trait.
 * It sends back a lot of mail to the station, at the cost of wrecking the cargo shuttle a little.
 */
/datum/shuttle_loan_situation/mail_strike
	sender = "Профсоюз почтовых рабочих \"Спинворд\""
	announcement_text = "Профсоюз почтовых рабочих хочет одолжить ваш грузовой шаттл, чтобы применить на нем \"продвинутую тактику профсоюзных забастовок\". Оплата письмами."
	bonus_points = 0
	thanks_msg = "Грузовой шаттл должен вернуться через пять минут."
	shuttle_transit_text = "Почту не оставить!"
	logging_desc = "Shuttle full of shady mail"

/datum/shuttle_loan_situation/mail_strike/spawn_items(list/spawn_list, list/empty_shuttle_turfs, list/blocked_shutte_turfs)
	for(var/i in 1 to rand(7, 12))
		var/turf/closed/wall/wall = pick_n_take(blocked_shutte_turfs)
		if(!istype(wall))
			continue
		var/static/list/wall_bad_stuff = list(DENT_WALL = 85, CHANGE_WALL = 13, DISMANTLE_WALL = 2)
		var/static/list/possible_new_walls = list(
			/turf/closed/wall/mineral/sandstone,
			/turf/closed/wall/mineral/wood,
			/turf/closed/wall/mineral/iron,
			/turf/closed/wall/metal_foam_base,
			/turf/closed/wall/r_wall,
		)
		var/damage_done = pick_weight(wall_bad_stuff)
		switch(damage_done)
			if(DENT_WALL)
				for(var/dent in 1 to rand(1, MAX_DENT_DECALS))
					wall.add_dent(prob(90) ? WALL_DENT_SHOT : WALL_DENT_HIT)
			if(CHANGE_WALL)
				wall.ChangeTurf(pick(possible_new_walls - wall.type))
				if(prob(25))
					for(var/dent in 1 to rand(1, MAX_DENT_DECALS))
						wall.add_dent(prob(90) ? WALL_DENT_SHOT : WALL_DENT_HIT)
			if(DISMANTLE_WALL)
				wall.dismantle_wall()

	for(var/i in 1 to rand(7, 12))
		var/turf/open/floor/floor = pick_n_take(empty_shuttle_turfs)
		if(!istype(floor))
			continue
		var/static/list/floor_bad_stuff = list(BREAK_TILE = 65, PLATING_TILE = 25, RUST_TILE = 10)
		var/damage_done = pick_weight(floor_bad_stuff)
		switch(damage_done)
			if(BREAK_TILE)
				if(prob(50))
					floor.break_tile()
				else
					floor.burn_tile()
			if(PLATING_TILE)
				if(prob(25))
					floor.remove_tile()
				else
					floor.make_plating()
			if(RUST_TILE)
				floor.ChangeTurf(/turf/open/floor/plating/rust)
	if(prob(25))
		spawn_list += pick(/obj/effect/gibspawner/robot, /obj/effect/gibspawner/human)

	for(var/i in 1 to rand(4, 7))
		spawn_list += /obj/structure/closet/crate/mail/full/mail_strike

#undef BREAK_TILE
#undef PLATING_TILE
#undef RUST_TILE

#undef DENT_WALL
#undef CHANGE_WALL
#undef DISMANTLE_WALL
