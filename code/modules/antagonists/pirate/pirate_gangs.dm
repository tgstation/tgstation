///global lists of all pirate gangs that can show up today. they will be taken out of the global lists as spawned so dupes cannot spawn.
GLOBAL_LIST_INIT(light_pirate_gangs, init_pirate_gangs(is_heavy = FALSE))
GLOBAL_LIST_INIT(heavy_pirate_gangs, init_pirate_gangs(is_heavy = TRUE))

///initializes the pirate gangs glob list, adding all subtypes that can roll today.
/proc/init_pirate_gangs(is_heavy)
	var/list/pirate_gangs = list()

	for(var/type in subtypesof(/datum/pirate_gang))
		var/datum/pirate_gang/possible_gang = new type
		if(!possible_gang.can_roll())
			qdel(possible_gang)
		else if(possible_gang.is_heavy_threat == is_heavy)
			pirate_gangs += possible_gang
	return pirate_gangs

///datum for a pirate team that is spawning to attack the station.
/datum/pirate_gang
	///name of this gang, for spawning feedback
	var/name = "Space Bugs"

	///Whether or not this pirate crew is a heavy-level threat
	var/is_heavy_threat = FALSE
	///the random ship name chosen from pirates.json
	var/ship_name
	///the ship they load in on.
	var/ship_template_id = "ERROR"
	///the key to the json list of pirate names
	var/ship_name_pool = "some_json_key"
	///inbound message title the station receives
	var/threat_title = "Pay away the Space Bugs"
	///the contents of the message sent to the station.
	///%SHIPNAME in the content will be replaced with the pirate ship's name
	///%PAYOFF in the content will be replaced with the requested credits.
	var/threat_content = "This is the %SHIPNAME. Give us %PAYOFF credits or we bug out the universe trying to spawn!"
	///station receives this message upon the ship's spawn
	var/arrival_announcement = "We have come for your Bungopoints!"
	///what the station can say in response, first item pays the pirates, second item rejects it.
	var/list/possible_answers = list("Please, go away! We'll pay!", "I accept oblivion.")

	///station responds to message and pays the pirates
	var/response_received = "Yum! Bungopoints!"
	///station responds to message and pays the pirates
	var/response_rejected = "Foo! No Bungopoints!"
	///station pays the pirates, but after the ship spawned
	var/response_too_late = "Your Bungopoints arrived too late, rebooting world..."
	///station pays the pirates... but doesn't have enough cash.
	var/response_not_enough = "Not enough Bungopoints have been added into my bank account, rebooting world..."

	/// Have the pirates been paid off?
	var/paid_off = FALSE
	/// The colour of their announcements when sent to players
	var/announcement_color = "red"

/datum/pirate_gang/New()
	. = ..()
	ship_name = pick(strings(PIRATE_NAMES_FILE, ship_name_pool))

///whether this pirate gang can roll today. this is called when the global list initializes, so
///returning FALSE means it cannot show up at all for the entire round.
/datum/pirate_gang/proc/can_roll()
	return TRUE

///returns a new comm_message datum from this pirate gang
/datum/pirate_gang/proc/generate_message(payoff)
	var/built_threat_content = replacetext(threat_content, "%SHIPNAME", ship_name)
	built_threat_content = replacetext(built_threat_content, "%PAYOFF", payoff)
	return new /datum/comm_message(threat_title, built_threat_content, possible_answers)

///classic FTL-esque space pirates.
/datum/pirate_gang/rogues
	name = "Rogues"

	ship_template_id = "default"
	ship_name_pool = "rogue_names"

	threat_title = "Предложение по защите сектора"
	threat_content = "Привет, приятель! Это %SHIPNAME. Не могу не заметить, что у тебя дикий \
		и сумасшедший шаттл без страховки! Безумец. Что, если с ним что-то случится?! Мы \
		провели быструю оценку ваших доходов в этом секторе и просим %PAYOFF кредитов, чтобы покрыть вашу \
		страховку шаттла на случай стихийного бедствия."
	arrival_announcement = "Не хотите ли вы рассмотреть наше предложение? К сожалению, время для переговоров прошло. Открывайте, мы скоро прибудем на борт."
	possible_answers = list("Приобрести страховку.","Отклонить предложение.")

	response_received = "Халявные деньги. Съебываем, ребята."
	response_rejected = "Не платить было ошибкой, теперь вам нужно пройти курс по экономике."
	response_too_late = "Платите или нет, но игнорирование нас стало вопросом нашей гордости. Теперь пришло время научить вас уважению."
	response_not_enough = "Вы думали, мы не заметим, если вы недоплатите? Смешно. Скоро мы с вами увидимся."

///aristocrat lizards looking to hunt the serfs
/datum/pirate_gang/silverscales
	name = "Silverscales"

	ship_template_id = "silverscale"
	ship_name_pool = "silverscale_names"

	threat_title = "Запрос на выплату дани"
	threat_content = "Это %SHIPNAME. Серебряные Чешуи желают получить кое-какую дань \
		от ваших плебейских ящеров. %PAYOFF кредитов должно хватить."
	arrival_announcement = "Разумеется, вы не заслуживаете всего этого на борту своего судна. Оно подойдет нам гораздо лучше."
	possible_answers = list("Мы заплатим.","Дань? Серьёзно? Проваливайте.")

	response_received = "Щедрое пожертвование. Пусть когти Тизиры дотянутся до самых дальних точек космоса."
	response_rejected = "Не зря же первое правило охоты гласит: не уходи без добычи."
	response_too_late = "Я вижу, что вы пытаетесь заплатить, но охота уже началась."
	response_not_enough = "Вы отправили оскорбительное \"пожертвование\". За вами начата охота."

///undead skeleton crew looking for booty
/datum/pirate_gang/skeletons
	name = "Skeleton Pirates"

	is_heavy_threat = TRUE
	ship_template_id = "dutchman"
	ship_name_pool = "skeleton_names" //just points to THE ONE AND ONLY

	threat_title = "Передача имущества"
	threat_content = "Эгегей! Это %SHIPNAME. Выплачивайте %PAYOFF кредитов или пойдете по доске."
	arrival_announcement = "Веселый Роджер не будет ждать вечно, дружки; мы тут распластались рядом и готовы отправить вам подарки."
	possible_answers = list("Мы заплатим.","Мы не потерпим вымогательства.")

	response_received = "Спасибо за кредиты, аборигены."
	response_rejected = "Черт бы побрал! Все на палубу, мы собираемся забрать их богатства."
	response_too_late = "Слишком поздно просить пощады!"
	response_not_enough = "Пытаетесь одурачить нас? Пожалеете об этом."

///Expirienced formed employes of Interdyne Pharmaceutics now in a path of thievery and reckoning
/datum/pirate_gang/interdyne
	name = "Restless Ex-Pharmacists"

	is_heavy_threat = TRUE
	ship_template_id = "ex_interdyne"
	ship_name_pool = "interdyne_names"

	threat_title = "Финансирование исследований"
	threat_content = "Приветствую вас, это %SHIPNAME. Нам требуется некоторое финансирование для наших фармацевтических операций. \
		%PAYOFF кредитов должно быть достаточно."
	arrival_announcement = "Мы скромно просим вас о значительном поступлении средств для будущих исследований нашего дела. Конечно, было бы неприятно, если бы вы заболели, но мы можем это исправить."
	possible_answers = list("Ладно.","Найдите себе работу!")

	response_received = "Благодарим вас за щедрость. Ваши деньги не будут потрачены понапрасну."
	response_rejected = "О, ты не станция, ты опухоль. Что ж, придется ее вырезать."
	response_too_late = "Поздно. Надеемся, вам понравится рак кожи!"
	response_not_enough = "Этого недостаточно для наших операций. Боюсь, нам придется одолжить немного."
	announcement_color = "purple"

///Previous Nanotrasen Assitant workers fired for many reasons now looking for revenge and your bank account.
/datum/pirate_gang/grey
	name = "The Grey Tide"

	ship_template_id = "grey"
	ship_name_pool = "grey_names"

	threat_title = "Ограбление"
	threat_content = "Это %SHIPNAME. Отдавайте свои деньги. \
		%PAYOFF кредитов может быть достаточно."
	arrival_announcement = "Отличные у вас вещи, теперь они наши."
	possible_answers = list("Пожалуйста, не бейте.","ВЫ ОТВЕТИТЕ ПЕРЕД ЗАКОНОМ!!!")

	response_received = "Подождите, вы действительно отдали свои деньги? Спасибо, но мы все равно придем за остальным!"
	response_rejected = "Ответим перед законом? Мы и есть закон! И вы понесете ответственность!"
	response_too_late = "Ничего, да? Похоже, \"Тайд\" прибывает на борт!"
	response_not_enough = "Пытаетесь наебать? Ничего страшного, мы возьмем вашу станцию в качестве залога."
	announcement_color = "yellow"

///Agents from the space I.R.S. heavily armed to stea- I mean, collect the station's tax dues
/datum/pirate_gang/irs
	name = "Space IRS Agents"

	is_heavy_threat = TRUE
	ship_template_id = "irs"
	ship_name_pool = "irs_names"

	threat_title = "Пропущеные налоговые платежи"
	threat_content = "%SHIPNAME на месте. Мы заметили, что ваша станция не платит налоги... \
		Давайте исправим это. Ваши недостающие налоговые отчисления составляют %PAYOFF кредитов \
		Мы настоятельно рекомендуем выплатить сумму налога, \
		чтобы нам не пришлось отправлять команду на вашу станцию, для разрешения ситуации."
	arrival_announcement = "Это команда по разрешению налоговых конфликтов, готовьтесь к тому, что ваши активы будут ликвидированы, а вас обвинят в налоговом мошенничестве, \
		если вы не заплатите налоги вовремя."
	possible_answers = list("Знаете, я как раз собирался заплатить. Спасибо за напоминание!","Мне все равно, кого присылает налоговая служба, я не буду платить налоги!")

	response_received = "Оплата произведена, мы приветствуем вас как законопослушных граждан, платящих налоги."
	response_rejected = "Понимаем, я отправляю команду на вашу станцию, чтобы решить этот вопрос."
	response_too_late = "Слишком поздно, уже отправлена команда, которая решает этот вопрос напрямую."
	response_not_enough = "Вы неправильно заполнили налоговую декларацию. Мы направили команду для ликвидации активов и ареста вас за налоговое мошенничество. \
		Ничего личного, парень."
	announcement_color = "yellow"

//Mutated Ethereals who have adopted bluespace technology in all the wrong ways.
/datum/pirate_gang/lustrous
	name = "Geode Scavengers"

	ship_template_id = "geode"
	ship_name_pool = "geode_names"

	threat_title = "Странное сообщение"
	threat_content = "Кристалл матери-пустоты трескается, и на свет появляется %SHIPNAME. Мы - Блестящие, руки хрустального короля.\
		Наши сундуки с блюспейс пылью иссякли, поэтому наш синтез прекратился. %PAYOFF кредитов исправят это!"
	arrival_announcement = "Мы прибыли, мы всегда были здесь, и мы уже исчезли."
	possible_answers = list("Аа, эм, окей? Хорошо.","У нас нет времени на бредни сумасшедших, проваливайте.")


	response_received = "Отличная посылка, синтез будет продолжен."
	response_rejected = "Грубость в вашей речи необходимо нейтрализовать. И мы можем помочь вам в этом прямо сейчас."
	response_too_late = "Тогда вы не были готовы, а теперь это время прошло. Мы можем идти только вперед, никогда не возвращаясь назад."
	response_not_enough = "Вы оскорбили нас, но вражды не будет, только стремительное правосудие!"
	announcement_color = "purple"

//medieval militia, from OUTER SPACE!
/datum/pirate_gang/medieval
	name = "Medieval Warmongers"

	is_heavy_threat = TRUE
	ship_template_id = "medieval"
	ship_name_pool = "medieval_names"

	threat_title = "ЗАЯВЛЕНИЕ НА ВЫПЛАТУ ГОНОРАРА"
	threat_content = "ПРИВЕТСТВУЮ, ЭТО %SHIPNAME И МЫ СОБИРАЕМ ДАНЬ \
		ОТ ВАССАЛОВ НА НАШЕЙ ТЕРРИТОРИИ, ТАК ПОЛУЧИЛОСЬ, ЧТО ВЫ ТОЖЕ НА НЕЙ!!! ОБЫЧНО \
		МЫ УБИВАЕМ ТАКИХ СЛАБАКОВ, КАК ВЫ, ЗА ВТОРЖЕНИЕ НА НАШУ ЗЕМЛЮ, НО МЫ ГОТОВЫ \
		ПРИВЕТСТВОВАТЬ ВАС В НАШЕМ ПРОСТРАНСТВЕ, ЕСЛИ ВЫ ЗАПЛАТИТЕ %PAYOFF КРЕДИТОВ КАК ДАНЬ НАШЕМУ ПРАВУ. БУДЬТЕ МУДРЫ В СВОЕМ ВЫБОРЕ!!! \
		(отправить сообщение. отправить сообщение. почему сообщение не отправляется?)."
	arrival_announcement = "Я ПОНЯЛ, КАК УПРАВЛЯТЬ СВОИМ КОРАБЛЁМ, МЫ ПРИЧАЛИМ К ВАМ ЧЕРЕЗ МИНУТУ!!!"
	possible_answers = list("Ладно, мне нравится, когда мой череп цел.","Болваны, свалите играть куда подальше.")

	response_received = "ЭТОГО БУДЕТ ДОСТАТОЧНО, ПОМНИТЕ, КТО ЯВЛЯЕТСЯ ВАШИМ ВЛАДЕЛЬЦЕМ!!!"
	response_rejected = "ГЛУПОЕ РЕШЕНИЕ, Я СДЕЛАЮ ИЗ ТВОЕЙ ТУШКИ ОБРАЗЕЦ ДЛЯ ПОДРАЖАНИЯ!!! (кто-нибудь помнит, как управлять нашим кораблём?)"
	response_too_late = "ТЫ УЖЕ В ОСАДЕ, ШУТ, ТЫ БЕЗМОЗГЛЫЙ ИЛИ НЕВЕЖЕСТВЕННЫЙ?!"
	response_not_enough = "ТЫ СЧИТАЕШЬ МЕНЯ ШУТОМ? ТЫ, ТУХЛОЕ МЯСО!!! (я забыл, как управлять кораблем, зараза)."
