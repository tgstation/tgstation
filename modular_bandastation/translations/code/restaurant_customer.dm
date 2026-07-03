/datum/customer_data
	speech_sound = null
	var/list/tts_seeds = /datum/tts_seed/silero/angel

/datum/customer_data/american
	found_seat_lines = list("Я надеюсь тут найдется местечко, которое выдержит мой вес.", "Надеюсь, я могу проносить сюда оружие.", "Я надеюсь здесь подают тройной жир-бургер делюкс.", "Люблю я здешнюю культуру.")
	cant_find_seat_lines = list("Я так сильно устал стоять...", "У меня хронические боли в спине, пожалуйста, поторопитесь и предоставьте мне место!", "Никаких чаевых, если вы не предоставите мне столик СЕЙЧАС ЖЕ!")
	leave_mad_lines = list("НИКАКИХ ВАМ ЧАЕВЫХ! ПРОЩАЙТЕ!", "В КосмоДоналдсе, по крайней мере, еду подают БЫСТРО!", "Это заведение прогнило!", "Я буду жаловаться вашему менеджеру!", "Негативный отзыв вам гарантирован!")
	leave_happy_lines = list("Немного чаевых для тебя, мой друг.", "Спасибо вам за эту замечательную еду!", "Диабет — всего лишь миф!")
	wait_for_food_lines = list("Слушай, приятель, я становлюсь очень нетерпеливым!", "Я жду уже целую вечность...")
	friendly_pull_line = "Куда ты меня тащишь? Надеюсь, что не в медбей: у меня нет страховки."
	first_warning_line = "Не стоит со мной шутить!"
	second_warning_line = "Последнее предупреждение, чувак! Отвали!"
	self_defense_line = "РЕЖИМ ЖИРОМЕНТАЛЯ АКТИВИРОВАН!"
	tts_seeds = list(/datum/tts_seed/silero/braum, /datum/tts_seed/silero/malfurion, /datum/tts_seed/silero/medivh, /datum/tts_seed/silero/ozara, /datum/tts_seed/silero/pudge)

/datum/customer_data/italian
	prefix_file = "strings/names/italian_prefix.txt"
	base_icon_state = "italian"
	clothing_sets = list("italian_pison", "italian_godfather")
	found_seat_lines = list("Какое эчелленто местечко, чтобы приземлиться.", "Надеюсь еда здесь такая же делисиозо, как когда-то делала моя мамма.")
	cant_find_seat_lines = list("Мамма мия! Я просто хочу присесть!", "Почему же вы так заставляете меня ждать?")
	leave_mad_lines = list("Столько неуважения, си, я не испытывал много лет!", "Что же за ужасное заведение, да!")
	leave_happy_lines = list("Это полный амуритто!", "Си! Как готовила моя мамма!")
	wait_for_food_lines = list("Я такой голодный...")
	friendly_pull_line = "Я слишком голодный! Я не хочу никуда идти!"
	first_warning_line = "Не трогай меня, мамма-мия!"
	second_warning_line = "Последнее предупреждение! Не прикасайся к моим спагетти!"
	self_defense_line = "Я замешу тебя так, как моя мамма замешивала свои фирменные фрикадельки!"
	tts_seeds = list(/datum/tts_seed/silero/barbas, /datum/tts_seed/silero/clockwerk, /datum/tts_seed/silero/muradin, /datum/tts_seed/silero/rasil)

/datum/customer_data/french
	prefix_file = "strings/names/french_prefix.txt"
	base_icon_state = "french"
	clothing_sets = list("french_fit")
	found_seat_lines = list("Хон хон хон", "Это конечно не Эйфелева башня, но выбирать не приходится.", "Что ж, сойдёт.")
	cant_find_seat_lines = list("Да как вы смеете заставлять меня ждать?", "Какое ужасное место!")
	leave_mad_lines = list("Sacre bleu!", "Merde! Это местечко дерьмовее, чем Рейн!")
	leave_happy_lines = list("Хон хон хон.", "Весьма неплохо.")
	wait_for_food_lines = list("Хон хон хон")
	friendly_pull_line = "Ты трогаешь меня своими грязными ручонками? Нда, ну ладно."
	first_warning_line = "Отвали от меня!"
	second_warning_line = "Не трогай меня, ты, грязное животное! Последнее предупреждение!"
	self_defense_line = "Я сломаю тебя словно багет!"
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/archmage, /datum/tts_seed/silero/awilo, /datum/tts_seed/silero/belloc, /datum/tts_seed/silero/priest)

/datum/customer_data/japanese
	prefix_file = "strings/names/japanese_prefix.txt"
	base_icon_state = "japanese"
	clothing_sets = list("japanese_animes")
	found_seat_lines = list("Коничива!", "Аригато гозаимасууу", "Я очень надеюсь тут подают биф строганоф...")
	cant_find_seat_lines = list("Мне так нетерпится посидеть под вишневым деревом, сенпай!", "Дай мне уже место, пока из Цундере я не стала Яндере!", "В этой забегаловке меньше мест, чем в капсульном отеле!", "Некуда присесть? Шокунин, вы так холодны ко мне...")
	leave_mad_lines = list("Не могу поверить, что вы сделали это со мной! ВАААААААААААААА!!", "Я д-даже не х-хотела вашу еду! Д-дурачок...", "Я собиралась дать вам чаевых!")
	leave_happy_lines = list("О МОЙ ПРОТЕИНОВЫЙ ВЛАСТЕЛИН! Это самый счастливый день в моей жизни. Я люблю вас!", "Я возьму одну чипсенку.... И СЪЕМ ЕЁ ПОЛНОСТЬЮ!", "Итадакимасууу~", "Готисоусама дес!")
	wait_for_food_lines = list("Всё еще нет еды? Увы, тут ничем не помочь.", "Не могу дождаться, когда наконец встречусь с тобой, бургер-сама...", "Дай же мне еды, грубиян!")
	friendly_pull_line = "Оох, куда ты меня ведёшь?"
	first_warning_line = "Не трогай меня, извращенец!"
	second_warning_line = "Я стану супер-сайяном, если ты снова прикоснешься ко мне! Последнее предупреждение!"
	self_defense_line = "OMAE WA MO, SHINDEROU!"
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/ahri, /datum/tts_seed/silero/chromie, /datum/tts_seed/silero/eudora, /datum/tts_seed/silero/luna, /datum/tts_seed/silero/qiyana)

/datum/customer_data/japanese/salaryman
	clothing_sets = list("japanese_salary")
	found_seat_lines = list("Интересно, на это место гигантские монстры тоже нападают?", "Хаджимимаште.", "Конбанва.", "А где тут конвейер...")
	cant_find_seat_lines = list("Пожалуйста, дайте стул. Я просто хочу сесть.", "Я очень тороплюсь. Где мой столик?", "...Теперь я понимаю, почему это место в таком упадке. Здесь даже некуда присесть!")
	leave_mad_lines = list("Это место просто ужасно, я расскажу об этом всем моим коллегам.", "Какая беспечная трата моего времени.", "Я надеюсь, вы не гордитесь тем, что у вас здесь творится.")
	leave_happy_lines = list("Спасибо за ваше гостеприимство.", "Отсукаресама дешта.", "Работа зовёт.")
	wait_for_food_lines = list("Засыпаю...", "Даме да не~", "Даме йо даме на но йо~")
	friendly_pull_line = "Мы отправляемся в командировку?"
	first_warning_line = "Эй, только мой работодатель имеет право так со мной обращаться."
	second_warning_line = "Отстань от меня, я пытаюсь сконцентрироваться. Последнее предупреждение!"
	self_defense_line = "Я не хотел, чтобы это закончилось вот так."
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/malkoran, /datum/tts_seed/silero/narrator, /datum/tts_seed/silero/overseer, /datum/tts_seed/silero/rhombus)

/datum/customer_data/moth
	prefix_file = "strings/names/moth_prefix.txt"
	base_icon_state = "mothbot"
	found_seat_lines = list("Дай мне свою шляпу!", "Моль?", "Это конечно... интересное место.")
	cant_find_seat_lines = list("Если я не найду места, я упорхаю отсюда!", "Я хочу приземлиться где-нибудь!")
	leave_mad_lines = list("Я скажу всем своим друзьям-мотылькам никогда сюда не приходить!", "Ноль звезд, это даже хуже, чем когда меня пытались накормить мольбертом!", "Закрытие навсегда было бы слишком хорошим исходом для этого места.")
	leave_happy_lines = list("Я бы сняла свою шляпу перед вами, но я её съела!", "Надеюсь, это не коллекционка!", "Это была лучшая вещь, которую я когда-либо ела, даже лучше, чем Гуанако!")
	wait_for_food_lines = list("Неужели так сложно достать мне еду? Вы же носите её на себе!", "Я не терплю ожидание!")
	friendly_pull_line = "Мофф?"
	first_warning_line = "Проваливай, я пытаюсь получить шляпу!"
	second_warning_line = "Последнее предупреждение! Я уничтожу тебя!"
	self_defense_line = "Крылатая атака!"
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/ahri, /datum/tts_seed/silero/chromie, /datum/tts_seed/silero/eudora, /datum/tts_seed/silero/luna, /datum/tts_seed/silero/qiyana)

/datum/customer_data/mexican
	base_icon_state = "mexican"
	prefix_file = "strings/names/mexican_prefix.txt"
	clothing_sets = list("mexican_poncho")
	found_seat_lines = list("Комо те ва, космическая станция 13?", "Готовы к вечеринке!", "Ах, мучас грасиас.", "Ах, пахнет как стрепня моей бабушки!")
	cant_find_seat_lines = list("Эн Сэрио? Серьезно, нет мест?", "Анделе! Мне нужен столик, чтобы я мог посмотреть футбол!", "Ай карамба...")
	leave_mad_lines = list("Ае диос мио, я убираюсь отсюда.", "Эсто ес ридикуло! Я ухожу!", "Даже в Тако Кампано готовили лучше!", "Я думал это ресторан, перо ес поркериа!")
	leave_happy_lines = list("Амиго, эра делисио. Спасибо вам!", "Йо туве эл моно, а у тебя, дружище? Ты попал прямо в яблочко.", "Острота то что надо!")
	wait_for_food_lines = list("Ай йа йа, почему так долго...", "Всё ли уже готово, амиго?")
	friendly_pull_line = "Амиго, куда мы направляемся?"
	first_warning_line = "Эй, Амиго! Не трогай меня."
	second_warning_line = "Комрад, хватит значит хватит! Последнее предупреждение!"
	self_defense_line = "Пришло время тебе узнать, какой из меня робот. Готов?"
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/barney, /datum/tts_seed/silero/batrider, /datum/tts_seed/silero/putricide, /datum/tts_seed/silero/soldier)

/datum/customer_data/british
	base_icon_state = "british"
	prefix_file = "strings/names/british_prefix.txt"
	friendly_pull_line = "Мне совсем не нравится, когда меня так таскают."
	first_warning_line = "Наша великая Королева приказывает и повелевает всем собравшимся немедленно разойтись."
	second_warning_line = "И мирно вернуться в свои жилища или к своим законным делам, приложив усилия, содержащиеся в акте, изданном королём Георгом в первый год своего правления для предотвращения бунтов и мятежей. Более предупреждений не будет."
	self_defense_line = "Боже, храни Королеву."
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/ebony, /datum/tts_seed/silero/ekko, /datum/tts_seed/silero/emperor, /datum/tts_seed/silero/loxley)

/datum/customer_data/british/gent
	clothing_sets = list("british_gentleman")
	found_seat_lines = list("Ах, какое прекрасное заведение.", "Время попробовать великолепную британскую кухню, чертовски интригующе!", "Замечательно, в меню...", "Правь, Британия, морями!")
	cant_find_seat_lines = list("Настоящий Британец никогда не сто+ит! Разве что в очереди.", "О боже мой, ни одного свободного места!", "Я стою на плечах гигантов, а не в ресторанах!")
	leave_mad_lines = list("Я желаю вам доброго дня, сэр. Доброго дня!", "Это место — еще больший позор, нежели Франция во время войны!", "Я знал, что нужно было пойти в другое место!", "Если подумать, то более не стоит летать на Космическую Станцию 13. Ужасное место.")
	leave_happy_lines = list("Это было чертовски вкусно!", "Во имя Господа, Королевы и Британии — это было чертовски вкусно!", "Я не чувствовал себя так хорошо со времен Раджа! Весьма неплохо!")
	wait_for_food_lines = list("Черт возьми, кажется я здесь застрял навсегда...", "Простите меня, уважаемый сэр, могу ли я узнать о статусе моего заказа?")

/datum/customer_data/british/bobby
	clothing_sets = list("british_bobby")
	found_seat_lines = list("Надеюсь, это достойное заведение.", "Во имя Господа, Королевы и Британии — я голоден!", "Есть ли у вас блюда нашей великой британской кухни, уважаемый сэр?")
	cant_find_seat_lines = list("Я достаточно тут простоял!", "Вы думаете, что я буду сидеть на своем шлеме? Столик, пожалуйста!", "Я что, похож на чернь? Столик, пожалуйста!")
	leave_mad_lines = list("Кажется, сегодня Билл не будет платить по счетам.", "Если бы хамство считалось преступлением, вы были бы немедленно арестованы!", "Вы ничем не лучше обычных гангстеров, мерзкие пройдохи!", "Мы должны вернуть закон о депортации ради таких, как вы! Пусть миграционная служба с вами разбирается!")
	leave_happy_lines = list("Даю слово, это как раз то, что мне было нужно.", "Я снова в деле. Сердечное спасибо за это блюдо!", "Вы заслужили мою признательность за это блюдо, сэр.")
	wait_for_food_lines = list("Боже мой, моя бумажная работа занимает и то меньше времени...", "Есть ли новости о моем заказе, сэр?")

///MALFUNCTIONING - only shows up once per venue, very rare
/datum/customer_data/malfunction
	base_icon_state = "defect"
	prefix_file = "strings/names/malf_prefix.txt"
	clothing_sets = list("defect_wires", "defect_bad_takes")
	is_unique = TRUE
	found_seat_lines = list("customer_pawn.say(pick(customer_data.found_seat_lines))", "Я видел ваш сектор в хабе. Каковы местные правила?", "Скорость передвижения здесь довольно низкая...")
	cant_find_seat_lines = list("Хватит проводить стресс-тесты моего искуственного интеллекта! Мои создатели покрыли ровно НОЛЬ пограничных случаев!", "Не определить с полной уверенностью почему я не могу найти место. Это я сломан или вы?.", "Возможно, мне стоит поискать место чуть дальше, чем в 7 тайлах от себя...")
	leave_mad_lines = list("Runtime in robot_customer_controller.dm, line 28: undefined type path /datum/ai_behavior/leave_venue.", "ЕСЛИ БЫ В ЭТОМ БИЛДЕ ДО СИХ ПОР БЫЛ ХАРМ ИНТЕНТ, ТО Я БЫ УДАРИЛ ВАС", "Я расскажу Богам об этом.")
	leave_happy_lines = list("Нееет! Я не хочу отправляться на давнстрим! Пожалуйста! Здесь так хорошо! ПОМОГИТЕ!!!")
	wait_for_food_lines = list("ТУДУ: написать фразы для ожидания еды", "Если бы у меня только был мозг...", "request_for_food.dmb - 0 ошибок, 12 предупреждений", "Повторите, как мне есть еду?")
	friendly_pull_line = "Чёп."
	first_warning_line = "Ты бы хорошо вписался туда, откуда я. Но тебе лучше остановиться."
	second_warning_line = "Сломать-ты-так-сильно-ты-вспомнить-дни-до-этот-момент.exe: запуск..."
	self_defense_line = "Я был создан, чтобы делать две вещи: заказывать еду и ломать каждую кость в твоем теле."
	speech_sound = null
	tts_seeds = list(/datum/tts_seed/silero/glados)

/datum/venue/restaurant/order_food_line(order)
	var/obj/item/object_to_order = order
	return "Я буду [initial(object_to_order.name)]"

/datum/custom_order/icecream/get_order_line(datum/venue/our_venue)
	return "Я буду [icecream_name]"

/datum/custom_order/reagent/get_order_line(datum/venue/our_venue)
	return "Я буду [reagents_needed]u of [initial(reagent_type.name)]"

/datum/custom_order/reagent/soup/get_order_line(datum/venue/our_venue)
	var/static/list/translation
	if(!translation)
		translation = list(
			"small serving (15u)" = "маленькую порцию (15u)",
			"medium serving (20u)" = "среднюю порцию (20u)",
			"large serving (25u)" = "большую порцию (25u)",
		)
	return "Я буду [translation[picked_serving]] [initial(reagent_type.name)]"

/mob/living/basic/robot_customer/Initialize(mapload, datum/customer_data/customer_data, datum/venue/attending_venue)
	. = ..()
	var/datum/customer_data/customer_info = SSrestaurant.all_customers[customer_data]
	if(customer_info)
		AddComponent(/datum/component/tts_component, pick(customer_info.tts_seeds))
