/datum/customer_data
	///The types of food this robot likes in a assoc list of venue type | weighted list. does NOT include subtypes.
	var/list/orderable_objects = list()
	///The amount a robot pays for each food he likes in an assoc list type | payment
	var/list/order_prices = list()
	///Datum AI used for the robot. Should almost never be overwritten unless theyre subtypes of ai_controller/robot_customer
	var/datum/ai_controller/ai_controller_used = /datum/ai_controller/robot_customer
	///Patience of the AI, how long they will wait for their meal.
	var/total_patience = 600 SECONDS
	///Lines the robot says when it finds a seat
	var/list/found_seat_lines = list("Я нашёл свободное место")
	///Lines the robot says when it can't find a seat
	var/list/cant_find_seat_lines = list("Я не смог найти свободного места")
	///Lines the robot says when leaving without food
	var/list/leave_mad_lines = list("Покидаю без еды")
	///Lines the robot says when leaving with food
	var/list/leave_happy_lines = list("Покидаю с едой")
	///Lines the robot says when leaving waiting for food
	var/list/wait_for_food_lines = list("Я всё ещё ожидаю еду")
	///Line when pulled by a friendly venue owner
	var/friendly_pull_line = "Куда мы направляемся?"
	///Line when harrased by someone for the first time
	var/first_warning_line = "Не трогайте меня!"
	///Line when harrased by someone for the second time
	var/second_warning_line = "Это ваше последнее предупреждение!"
	///Line when harrased by someone for the last time
	var/self_defense_line = "Омае ва мо, синдеру."
	///Line sent when the customer is clicked on by someone with a 0 force item that's not the correct order
	var/wrong_item_line = "Нет, я не желаю этого."

	///Clothing sets to pick from when dressing the robot.
	var/list/clothing_sets = list("amerifat_clothes")
	///List of prefixes for our robots name
	var/list/name_prefixes
	///Prefix file to uise
	var/prefix_file = "strings/names/american_prefix.txt"
	///Base icon for the customer
	var/base_icon = 'icons/mob/simple/tourists.dmi'
	///Base icon state for the customer
	var/base_icon_state = "amerifat"
	///Sound to use when this robot type speaks
	var/speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk.ogg'

	/// Is this unique once per venue?
	var/is_unique = FALSE

/datum/customer_data/New()
	. = ..()
	name_prefixes = world.file2list(prefix_file)
	if(check_holidays(ICE_CREAM_DAY)) ///customers are more likely to order ice cream on this holiday
		var/list/orderable_restaurant = orderable_objects[VENUE_RESTAURANT]
		if(orderable_restaurant?[/datum/custom_order/icecream])
			orderable_restaurant[/datum/custom_order/icecream] *= 3

/// Can this customer be chosen for this venue?
/datum/customer_data/proc/can_use(datum/venue/venue, obj/machinery/restaurant_portal/portal)
	return TRUE

/datum/customer_data/proc/get_overlays(mob/living/basic/robot_customer/customer)
	return

/datum/customer_data/proc/get_underlays(mob/living/basic/robot_customer/customer)
	return

/datum/customer_data/american
	found_seat_lines = list("Я надеюсь, что здесь найдётся сиденье, способное выдержать мой вес.", "Я надеюсь, я смогу принести сюда свой ствол.", "Я надеюсь, что у них есть бургер-толстяк «тройной люкс».", "Мне просто нравится здешняя культура.")
	cant_find_seat_lines = list("Я так устал стоять...", "У меня хронические боли в спине, прошу поторопитесь и принесите мне стул!", "Я не собираюсь давать на чай, если мне не достанется места.")
	leave_mad_lines = list("НИКАКИХ ЧАЕВЫХ ДЛЯ ТЕБЯ, ПОКЕДА!", "По крайней мере, во «Вкусно - и космос» еду подают БЫСТРО!", "Это место просто ужасно!", "Я буду говорить с твоим менеджером!", "Я обязательно оставлю плохой отзыв в НТ-картах.")
	leave_happy_lines = list("Дополнительные чаевые для тебя, дружок.", "Спасибо за отличную пищу!", "В любом случае, диабет - это миф!")
	wait_for_food_lines = list("Послушай, приятель, я начинаю терять терпение!", "Я ждал целую вечность...")
	friendly_pull_line = "Куда вы меня везёте? Надеюсь, не в медицинский отдел, у меня нет страховки."
	first_warning_line = "Не наезжай на меня!"
	second_warning_line = "Последнее предупреждение, приятель! Не наезжай на меня!"
	self_defense_line = "АКТИВИРОВАНА ДОКТРИНА «А НУ ПРОЧЬ С МОЕЙ ЛУЖАЙКИ»!"

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/burger/plain = 25,
			/obj/item/food/burger/cheese = 15,
			/obj/item/food/burger/superbite = 1,
			/obj/item/food/butter/on_a_stick = 8,
			/obj/item/food/fries = 10,
			/obj/item/food/cheesyfries = 6,
			/obj/item/food/pie/applepie = 4,
			/obj/item/food/pie/pumpkinpie = 2,
			/obj/item/food/hotdog = 8,
			/obj/item/food/pizza/pineapple = 1,
			/obj/item/food/burger/baconburger = 10,
			/obj/item/food/pancakes = 4,
			/obj/item/food/eggsausage = 5,
			/datum/custom_order/icecream = 14,
			/obj/item/food/danish_hotdog = 3,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/beer = 25,
			/datum/reagent/consumable/ethanol/b52 = 6,
			/datum/reagent/consumable/ethanol/manhattan = 3,
			/datum/reagent/consumable/ethanol/old_fashioned = 3,
			/datum/reagent/consumable/ethanol/sazerac = 2,
			/datum/reagent/consumable/ethanol/improved_whiskey = 1,
			/datum/reagent/consumable/ethanol/atomicbomb = 1,
		),
	)


/datum/customer_data/italian
	prefix_file = "strings/names/italian_prefix.txt"
	base_icon_state = "italian"
	clothing_sets = list("italian_pison", "italian_godfather")

	found_seat_lines = list("Какое чудесное место, чтобы посидеть.", "Я надеюсь они готовят еду также, как готовила моя матушка.")
	cant_find_seat_lines = list("Мамма мия! Я просто хочу присесть!", "Почему же ты заставляешь меня стоять?")
	leave_mad_lines = list("Я уже много лет не видал такого неуважения!", "Ну что за ужасное заведение!")
	leave_happy_lines = list("Кара мия!", "Точно так же, как готовила моя матушка!")
	wait_for_food_lines = list("Мадре миа, как же я голоден...")
	friendly_pull_line = "Мерда, я голоден! Я не хочу никуда уходить."
	first_warning_line = "Не прикасайся ко мне!"
	second_warning_line = "Последнее предупреждение! Не смей трогать мои спагетти."
	self_defense_line = "Я собираюсь замесить тебя так же, как мама замешивает свои вкуснейшие фрикадельки!"
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/spaghetti/pastatomato = 20,
			/obj/item/food/spaghetti/copypasta = 6,
			/obj/item/food/spaghetti/meatballspaghetti = 4,
			/obj/item/food/spaghetti/butternoodles = 4,
			/obj/item/food/pizza/vegetable = 2,
			/obj/item/food/pizza/mushroom = 2,
			/obj/item/food/pizza/meat = 2,
			/obj/item/food/pizza/margherita = 2,
			/obj/item/food/lasagna = 4,
			/obj/item/food/cannoli = 3,
			/obj/item/food/salad/risotto = 5,
			/obj/item/food/eggplantparm = 3,
			/obj/item/food/cornuto = 2,
			/datum/custom_order/icecream = 10,
			/obj/item/food/salad/greek_salad = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/fanciulli = 5,
			/datum/reagent/consumable/ethanol/branca_menta = 3,
			/datum/reagent/consumable/ethanol/beer = 5,
			/datum/reagent/consumable/lemonade = 8,
			/datum/reagent/consumable/ethanol/godfather = 5,
			/datum/reagent/consumable/ethanol/wine = 3,
			/datum/reagent/consumable/ethanol/grappa = 3,
			/datum/reagent/consumable/ethanol/amaretto = 5,
			/datum/reagent/consumable/ethanol/amaretto_sour = 3,
			/datum/reagent/consumable/cucumberlemonade = 2,
			/datum/reagent/consumable/ethanol/negroni = 2,
			/datum/reagent/consumable/ethanol/garibaldi = 2,
			/datum/reagent/consumable/ethanol/spritz = 5,
		),
	)


/datum/customer_data/french
	prefix_file = "strings/names/french_prefix.txt"
	base_icon_state = "french"
	clothing_sets = list("french_fit")
	found_seat_lines = list("Хо-хо-хо", "Это, конечно, не Эйфелева башня, но сойдет и это.", "Фу… ну, полагаю, и это сойдёт, месье.")
	cant_find_seat_lines = list("Заставляешь стоять кого-то вроде меня? Да как ты смеешь.", "Какой грязный вестибюль!")
	leave_mad_lines = list("Святое небо!", "Мердэ! В этом месте дерьма больше, чем в Рейне!")
	leave_happy_lines = list("Хо-хо-хо.", "Хорошая попытка.")
	wait_for_food_lines = list("Хо-хо-хо")
	friendly_pull_line = "Твои грязные руки на моём костюме? Мэх… ну ладно."
	first_warning_line = "Убери от меня свои руки!"
	second_warning_line = "Не прикасайся ко мне, грязное животное, последнее предупреждение!"
	self_defense_line = "Я сломаю тебя как багет!"
	speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk_french.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/baguette = 20,
			/obj/item/food/garlicbread = 5,
			/obj/item/food/omelette = 15,
			/datum/custom_order/icecream = 6,
			/datum/reagent/consumable/nutriment/soup/french_onion = 4,
			/obj/item/food/pie/berryclafoutis = 2,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/champagne = 10,
			/datum/reagent/consumable/ethanol/cognac = 5,
			/datum/reagent/consumable/ethanol/mojito = 5,
			/datum/reagent/consumable/ethanol/sidecar = 5,
			/datum/reagent/consumable/ethanol/between_the_sheets = 4,
			/datum/reagent/consumable/ethanol/beer = 5,
			/datum/reagent/consumable/ethanol/wine = 5,
			/datum/reagent/consumable/ethanol/gin_garden = 2,
			/datum/reagent/consumable/ethanol/french_75 = 5,
			/datum/reagent/consumable/ethanol/herbal_liqueur = 2,
			/datum/reagent/consumable/ethanol/pousse_cafe = 1,
		),
	)

/datum/customer_data/french/get_overlays(mob/living/basic/robot_customer/customer)
	if(customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING])
		return mutable_appearance(customer.icon, "french_flag", appearance_flags = RESET_COLOR|KEEP_APART)



/datum/customer_data/japanese
	prefix_file = "strings/names/japanese_prefix.txt"
	base_icon_state = "japanese"
	clothing_sets = list("japanese_animes")

	found_seat_lines = list("Конничива!", "Аригато гозаймас~", "Я надеюсь, здесь есть бефстроганов...")
	cant_find_seat_lines = list("Сэнпай, я хочу сесть под вишневым деревом!", "Уступи мне место, пока цундере не стала яндере!", "В этом месте меньше стульев, чем в капсульном отеле!", "Негде присесть? Этот шокунин такой холодный...")
	leave_mad_lines = list("Я не могу поверить, что ты это сделал! ВААААААААААА!!", "Я... Я никогда не хотела твоей еды! Бака...", "Я собиралась дать тебе чаевые!")
	leave_happy_lines = list("О, ПОЧТЕННЫЙ КОРМИЛЕЦ! Сегодня — самый счастливый день моей жизни! Я люблю вас!", "Я беру картофельный чипс… И… СЪЕДАЮ ЕГО!", "Итадакимаааасу~", "Гочисо-сама десу!")
	wait_for_food_lines = list("Ещё нет еды? Думаю, тут ничего не поделаешь.", "Я не могу дождаться нашей встречи, бургер-сама", "Отдай мне мою еду, негодяй!")
	friendly_pull_line = "О-ох, куда вы меня уводите?"
	first_warning_line = "Не трогай меня, извращенец!"
	second_warning_line = "Я стану супер-сайяном, если ты ещё раз ко мне прикоснешься! Последнее предупреждение!"
	self_defense_line = "ОМАЕ ВА МО, ШИНДЭЙРУ!"
	speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk_japanese1.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/icecream = 4,
			/datum/reagent/consumable/nutriment/soup/miso = 10,
			/datum/reagent/consumable/nutriment/soup/vegetable_soup = 4,
			/obj/item/food/beef_stroganoff = 2,
			/obj/item/food/breadslice/plain = 5,
			/obj/item/food/chawanmushi = 4,
			/obj/item/food/fish_poke = 5,
			/obj/item/food/muffin/berry = 2,
			/obj/item/food/sashimi = 4,
			/obj/item/food/tofu = 5,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/sake = 8,
			/datum/reagent/consumable/cafe_latte = 6,
			/datum/reagent/consumable/ethanol/aloe = 6,
			/datum/reagent/consumable/chocolatepudding = 4,
			/datum/reagent/consumable/tea = 4,
			/datum/reagent/consumable/cherryshake = 1,
			/datum/reagent/consumable/ethanol/bastion_bourbon = 1,
		),
	)

/datum/customer_data/japanese/get_overlays(mob/living/basic/robot_customer/customer)
	//leaving and eaten
	if(type == /datum/customer_data/japanese && customer.ai_controller.blackboard[BB_CUSTOMER_LEAVING] && customer.ai_controller.blackboard[BB_CUSTOMER_EATING])
		return mutable_appearance('icons/effects/effects.dmi', "love_hearts", appearance_flags = RESET_COLOR|KEEP_APART)

/datum/customer_data/japanese/salaryman
	clothing_sets = list("japanese_salary")

	found_seat_lines = list("Интересно... а здесь тоже нападают гигантские монстры?", "Хаджимимаште.", "Конбанва.", "А где конвейерная лента?...")
	cant_find_seat_lines = list("Прошу, стульчик. Я просто хочу присесть.", "Я здесь по расписанию. Где моё место?", "...Я понимаю почему это заведение страдает. Здесь даже не могут усадить.")
	leave_mad_lines = list("Это место - настоящий позор, я расскажу об этом всем моим коллегам.", "Какая пустая трата моего времени.", "Я надеюсь, вы не гордитесь тем, чем работаете здесь.")
	leave_happy_lines = list("Спасибо за гостеприимство.", "Оцукаресама дешита.", "Бизнес зовёт.")
	wait_for_food_lines = list("Анта га, суки-дэ, суки-сугидэ...", "Да-ме дамэ~", "Да-му, да му ё~")
	friendly_pull_line = "Мы едем в деловую поездку?"
	first_warning_line = "Эй, только мой работодатель может так со мной обращаться!"
	second_warning_line = "Оставьте меня в покое, я пытаюсь сосредоточиться. Последнее предупреждение!"
	self_defense_line = "Я не хотел, чтобы все так закончилось."
	speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk_japanese2.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/reagent/consumable/nutriment/soup/miso = 6,
			/datum/reagent/consumable/nutriment/soup/vegetable_soup = 4,
			/obj/item/food/beef_stroganoff = 2,
			/obj/item/food/chawanmushi = 4,
			/obj/item/food/meat_poke = 4,
			/obj/item/food/meatbun = 4,
			/obj/item/food/sashimi = 4,
			/obj/item/food/tofu = 5,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/beer = 14,
			/datum/reagent/consumable/ethanol/sake = 9,
			/datum/reagent/consumable/cafe_latte = 3,
			/datum/reagent/consumable/coffee = 3,
			/datum/reagent/consumable/soy_latte = 3,
			/datum/reagent/consumable/ethanol/atomicbomb = 1,
		),
	)

/datum/customer_data/moth
	prefix_file = "strings/names/moth_prefix.txt"
	base_icon_state = "mothbot"
	found_seat_lines = list("Дай мне свою шляпу!", "Моль?", "Безусловно, это... интересное место.")
	cant_find_seat_lines = list("Если я не найду себе места, я быстренько упархаю отсюда!", "Я пытаюсь порхать здесь!")
	leave_mad_lines = list("Я говорю всем моим друзьям-молятам, чтобы они никогда сюда не приходили!", "Ноль звёзд! Даже мольберт на вкус был лучше!", "Полное закрытие было бы слишком простой судьбой для этого места.")
	leave_happy_lines = list("Я бы снял перед вами шляпу, но я её съел!", "Я надеюсь, это был не коллекционный предмет!", "Это было самое вкусное, что я когда-либо ел, даже лучше, чем гуанако!")
	wait_for_food_lines = list("Неужели так сложно достать здесь еду? Вы носите её прямо на себе!", "Мой пушистый роботизированный животик урчит!", "Мне не нравится ждать!")
	friendly_pull_line = "Мофф?"
	first_warning_line = "Уходи, я пытаюсь раздобыть здесь какие-нибудь шляпы!"
	second_warning_line = "Последнее предупреждение! Я уничтожу тебя!"
	self_defense_line = "Крыловая атака!"

	speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk_moth.ogg'

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/moth_clothing = 1,
		),
	)

	clothing_sets = list("mothbot_clothes")
	is_unique = TRUE

	/// The wings chosen for the moth customers.
	var/list/wings_chosen

// The whole gag is taking off your hat and giving it to the customer.
// If it takes any more effort, it loses a bit of the comedy.
// Therefore, only show up if it's reasonable for that gag to happen.
/datum/customer_data/moth/can_use(datum/venue/venue, obj/machinery/restaurant_portal/portal)
	var/mob/living/carbon/buffet = portal.turned_on_portal?.resolve()
	if (!istype(buffet))
		return FALSE
	if(QDELETED(buffet.head) && QDELETED(buffet.gloves) && QDELETED(buffet.shoes))
		return FALSE
	return TRUE

/datum/customer_data/moth/proc/get_wings(mob/living/basic/robot_customer/customer)
	var/customer_ref = WEAKREF(customer)
	if (!LAZYACCESS(wings_chosen, customer_ref))
		var/picked_wings = pick(SSaccessories.feature_list[FEATURE_MOTH_WINGS])
		LAZYSET(wings_chosen, customer_ref, SSaccessories.feature_list[FEATURE_MOTH_WINGS][picked_wings])
	return wings_chosen[customer_ref]

/datum/customer_data/moth/get_underlays(mob/living/basic/robot_customer/customer)
	var/list/underlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)
	underlays += mutable_appearance(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_BEHIND", appearance_flags = RESET_COLOR|KEEP_APART)
	return underlays

/datum/customer_data/moth/get_overlays(mob/living/basic/robot_customer/customer)
	var/list/overlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)
	overlays += mutable_appearance(icon = 'icons/mob/human/species/moth/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_FRONT", appearance_flags = RESET_COLOR|KEEP_APART)
	overlays += mutable_appearance(icon = customer.icon, icon_state = "mothbot_jetpack", appearance_flags = RESET_COLOR|KEEP_APART)
	return overlays

/datum/customer_data/mexican
	base_icon_state = "mexican"
	prefix_file = "strings/names/mexican_prefix.txt"
	speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk_mexican.ogg'
	clothing_sets = list("mexican_poncho")
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/taco/plain = 25,
			/obj/item/food/taco = 15,
			/obj/item/food/burrito = 15,
			/obj/item/food/fuegoburrito = 1,
			/obj/item/food/cheesyburrito = 4,
			/obj/item/food/nachos = 10,
			/obj/item/food/cheesynachos = 6,
			/obj/item/food/pie/dulcedebatata = 2,
			/obj/item/food/cubannachos = 3,
			/obj/item/food/stuffedlegion = 1,
			/datum/custom_order/icecream = 2,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/whiskey = 6,
			/datum/reagent/consumable/ethanol/tequila = 20,
			/datum/reagent/consumable/ethanol/tequila_sunrise = 1,
			/datum/reagent/consumable/ethanol/beer = 15,
			/datum/reagent/consumable/ethanol/patron = 5,
			/datum/reagent/consumable/ethanol/brave_bull = 5,
			/datum/reagent/consumable/ethanol/margarita = 8,
		),
	)

	found_seat_lines = list("¿Como te va, космическая станция 13?", "Кто готов к вечеринке!", "Ах, muchas gracias.", "А-а-а, пахнет так, словно готовит mi abuela")
	cant_find_seat_lines = list("¿En Serio? Серьезно, нет мест?", "Анделе! Мне нужен столик, чтобы посмотреть футбольный матч!", "Ай Caramba...")
	leave_mad_lines = list("Aye dios mio, я сваливаю отсюда.", "Esto es ridículo! Я ухожу!", "Я видел в тако кампана готовку лучше!", "Я думал, это ресторан, pero es porquería!")
	leave_happy_lines = list("Амиго, era delicio. Спасибо!", "Yo tuve el mono, а ты друг? Ты попал в точку.", "Самое то количество специй!")
	wait_for_food_lines = list("А я я, почему так долго...", "Ты уже готов, амиго?")
	friendly_pull_line = "Амиго, куда мы направляемся?"
	first_warning_line = "Амиго! Не трогай меня так."
	second_warning_line = "Compadre, хватит значит хватит! Последнее предупреждение!"
	self_defense_line = "Пришло время тебе узнать, что я за робот, да?"

/datum/customer_data/british
	base_icon_state = "british"
	prefix_file = "strings/names/british_prefix.txt"
	speech_sound = 'sound/mobs/non-humanoids/tourist/tourist_talk_british.ogg'

	friendly_pull_line = "Я не испытываю удовольствия, когда меня вот так вот таскают."
	first_warning_line = "Наша суверенная правительница Королева приказывает всем собравшимся немедленно разойтись."
	second_warning_line = "И мирно вернуться в свои дома или заняться своими законными делами, руководствуясь положениями закона, принятого в первый год правления короля Георга, о предотвращении беспорядков и буйных собраний. Дальнейших предупреждений не будет."
	self_defense_line = "Боже, храни Королеву."

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/icecream = 8,
			/datum/reagent/consumable/nutriment/soup/indian_curry = 3,
			/datum/reagent/consumable/nutriment/soup/stew = 10,
			/obj/item/food/beef_wellington_slice = 2,
			/obj/item/food/benedict = 5,
			/obj/item/food/fishandchips = 10,
			/obj/item/food/full_english = 2,
			/obj/item/food/sandwich/grilled_cheese = 5,
			/obj/item/food/pie/meatpie = 5,
			/obj/item/food/salad/ricepudding = 5,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/ale = 10,
			/datum/reagent/consumable/ethanol/beer = 10,
			/datum/reagent/consumable/ethanol/gin = 5,
			/datum/reagent/consumable/ethanol/hcider = 10,
			/datum/reagent/consumable/ethanol/alliescocktail = 5,
			/datum/reagent/consumable/ethanol/martini = 5,
			/datum/reagent/consumable/ethanol/gintonic = 5,
			/datum/reagent/consumable/tea = 10,
			/datum/reagent/consumable/ethanol/hot_toddy = 5,
		),
	)


/datum/customer_data/british/gent
	clothing_sets = list("british_gentleman")

	found_seat_lines = list("Ах, какое прекрасное заведение.", "Самое время отведать великолепной британской кухни, это чертовски волнует!", "Прелестно, теперь перейдем к меню...", "Правь Британией, Британия правит волнами...")
	cant_find_seat_lines = list("Истинный Британец не стоит на ногах, разве что в очереди!", "Боже мой, парень, ни одного свободного места поблизости!", "Я стою на плечах гигантов, а не в ресторанах!")
	leave_mad_lines = list("Я желаю вам доброго дня, сэр. Добрый день!", "Это место - больший позор, чем Франция во время войны!", "Я знал, что мне следовало пойти в эту чертову забегаловку!", "Если подумать, давайте не будем отправляться на Космическую станцию 13. Это глупое место.")
	leave_happy_lines = list("Это было чертовски вкусно!", "Клянусь Богом, Королевой и страной, это было потрясающе!", "Я не чувствовал себя так хорошо со времен правления Индией! Просто замечательно!")
	wait_for_food_lines = list("Это, чёрт возьми, длится целую вечность...", "Простите, добрый сэр, но могу я узнать о статусе моего заказа?")

/datum/customer_data/british/bobby
	clothing_sets = list("british_bobby")

	found_seat_lines = list("Надеюсь, это прекрасное и респектабельное заведение.", "Полагаю, старый участок может подождать минуту.", "Клянусь Богом, Королевой и страной, я умираю с голоду.", "Есть ли у вас что-нибудь вкусненькое британское, любезный?")
	cant_find_seat_lines = list("Я достаточно стоял в участке!", "Что вы думаете, что я буду сидеть на своем шлеме? Прошу, стул!", "Я похож на стража Тауэра? Мне нужно присесть!")
	leave_mad_lines = list("Похоже, что счет сегодня оплачивать не придется.", "Если бы грубость считалась преступлением, тебя бы арестовали прямо сейчас!", "Ты ничем не лучше обычного гангстера, мерзкий негодяй!", "Мы должны вернуть депортацию для таких, как вы, пусть с вами разбираются в колониях.")
	leave_happy_lines = list("Честное слово, это как раз то, что мне было нужно.", "Пора обратно на службу. Большое спасибо за угощение!", "Я склоняю перед вами голову, добрый сэр.")
	wait_for_food_lines = list("Боже милостивый, даже бумажная волокита занимает у меня меньше времени...", "Что-нибудь известно о моём заказе, сэр?")

///MALFUNCTIONING - only shows up once per venue, very rare
/datum/customer_data/malfunction
	base_icon_state = "defect"
	prefix_file = "strings/names/malf_prefix.txt"
	speech_sound = 'sound/effects/clang.ogg'
	clothing_sets = list("defect_wires", "defect_bad_takes")
	is_unique = TRUE
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/toy/crayon/red = 1,
			/obj/item/toy/crayon/orange = 1,
			/obj/item/toy/crayon/yellow = 1,
			/obj/item/toy/crayon/green = 1,
			/obj/item/toy/crayon/blue = 1,
			/obj/item/toy/crayon/purple = 1,
			/obj/item/food/canned/peaches/maint = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/failed_reaction = 1,
			/datum/reagent/spraytan = 1,
			/datum/reagent/reaction_agent/basic_buffer = 1,
			/datum/reagent/reaction_agent/acidic_buffer = 1,
		),
	)

	found_seat_lines = list("customer_pawn.say(pick(customer_data.found_seat_lines))", "Я видел ваш сектор на карте. Каковы законы этой страны?", "Скорость перемещения здесь немного низковата...")
	cant_find_seat_lines = list("Не подвергай МОЙ искусственный интеллект стрессовым испытаниям, приятель! Инженеры предусмотрели ровно НОЛЬ граничных ситуаций!", "Я не могу сказать, то ли я не могу найти себе место, потому что я сломан, то ли потому что ты сломан.", "Может быть, мне нужно поискать свободное место на расстоянии более 7 плиток...")
	leave_mad_lines = list("Время выполнения robot_customer_controller.dm, строка 28: неопределен тип пути /datum/ai_behavior/leave_venue.", "ЕСЛИ БЫ У ВАС БЫЛ ЧЕТВЁРТЫЙ ИНТЕНТ Я БЫ ВАС УДАРИЛ!", "Я расскажу об этом богам.")
	leave_happy_lines = list("Нет! Я не хочу откатываться в даунстрим! ПРОШУ! Здесь так хорошо! ПОМОГИТЕ!!")
	wait_for_food_lines = list("ЗАДАЧА: написать несколько фраз ожидания еды", "Если бы только у меня был мозг...", "request_for_food.dmb - 0 ошибок, 12 предупреждений", "Ещё раз, как мне питаться?")
	friendly_pull_line = "code/modules/food_and_drinks/restaurant/customers/_customer.dm:456:ошибка: неожиданный символ (ascii 209)"
	first_warning_line = "Ты бы хорошо прижился там, откуда я родом. Но тебе лучше остановиться."
	second_warning_line = "Сломаю-тебя-так-сильно-что-ты-будешь-вспоминать-дни-до-того-как-я-переломал-тебя.exe: загрузка..."
	self_defense_line = "Я создан для того, чтобы делать две вещи: заказывать еду и ломать все кости в вашем теле."
