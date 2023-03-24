//Components: Used in scripture.
/obj/item/clockwork/component
	name = "мемный компонент"
	desc = "Кусочек известного мема."
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/component_id //What the component is identified as
	var/cultist_message = "Ты не достоин этого мема." //Showed to Nar'Sian cultists if they pick up the component in addition to chaplains
	var/list/servant_of_ratvar_messages = list("ayy" = FALSE, "lmao" = TRUE) //Fluff, shown to servants of Ratvar on a low chance, if associated value is TRUE, will automatically apply ratvarian
	var/message_span = "heavy_brass"

/obj/item/clockwork/component/pickup(mob/living/user)
	..()
	if(IS_CULTIST(user) || (user.mind?.holy_role))
		to_chat(user, "<span class='[message_span]'>[cultist_message]</span>")
		if(user.mind?.holy_role)
			to_chat(user, span_boldannounce("Сила моей веры плавит [src.name]!"))
			var/obj/item/stack/ore/slag/wrath = new /obj/item/stack/ore/slag
			qdel(src)
			user.put_in_active_hand(wrath)

/obj/item/clockwork/component/belligerent_eye
	name = "воинственный глаз"
	desc = "Конструкция из латуни с вращающимся красным центром. Как будто он ищет что-нибудь, чтобы его обидеть."
	icon_state = "belligerent_eye"
	cultist_message = "Глаза бросают на меня сильный ненавистный взгляд."
	servant_of_ratvar_messages = list("\"...\"" = FALSE, "На мгновение мой разум наводнен чрезвычайно жестокими мыслями." = FALSE, "\"...Умри.\"" = TRUE)
	message_span = "neovgre"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "слепой глаз"
	desc = "Тяжелый латунный глаз, его красная радужная оболочка потемнела."
	icon_state = "blind_eye"
	cultist_message = "Глаза смотрят на меня с сильной ненавистью, прежде чем потемнеть."
	servant_of_ratvar_messages = list("Глаз мерцает перед тем как потемнеть." = FALSE, "На меня посмотрели." = FALSE, "\"...\"" = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/belligerent_eye/lens_gem
	name = "жемчужная линза"
	desc = "Крошечный розоватый самоцвет. Он странно отражает свет, почти светится."
	icon_state = "lens_gem"
	cultist_message = "Драгоценный камень на мгновение становится черным и холодным, прежде чем возвращается его обычное свечение."
	servant_of_ratvar_messages = list("\"Отвратительный провал.\"" = TRUE, "Чувствую себя внимательно." = FALSE, "\"Слабаки.\"" = TRUE, "\"Жалкая защита.\"" = TRUE)
	w_class = WEIGHT_CLASS_TINY
	light_range = 1.4
	light_power = 0.4
	light_color = "#F42B9D"

/obj/item/clockwork/component/vanguard_cogwheel
	name = "авангардное зубчатое колесо"
	desc = "Прочная латунная шестеренка со слабо светящимся синим драгоценным камнем в центре.."
	icon_state = "vanguard_cogwheel"
	cultist_message = "\"Молись своему богу, чтобы мы никогда не встретились.\""
	servant_of_ratvar_messages = list("\"Будь осторожен, дитя.\"" = FALSE, "Чувствую необъяснимое спокойствие." = FALSE, "\"Никогда не забывайте: боль временна. То, что вы делаете для Юстициария, вечно.\"" = FALSE)
	message_span = "inathneq"

/obj/item/clockwork/component/vanguard_cogwheel/onyx_prism
	name = "опухшая призма"
	desc = "Опухшая призма с малым отверстием. Она очень тяжелая."
	icon_state = "onyx_prism"
	cultist_message = "Призма болезненно нагревается в моих руках."
	servant_of_ratvar_messages = list("Призма не становится светлее." = FALSE, "\"Так... вы еще не проиграли. Имей надежду, дитя.\"" = TRUE, \
	"\"Лучше эти машины сломаются, чем ты.\"" = TRUE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor
	name = "конденсатор джеис"
	desc = "Странно холодная латунная безделушка. Похоже, он действительно не любит, когда его держат."
	icon_state = "geis_capacitor"
	cultist_message = "\"Постарайся не сойти с ума - мне это понадобится. Хе-хе ...\""
	servant_of_ratvar_messages = list("\"Отвратительный.\"" = FALSE, "\"Ну разве ты не любознательный парень?\"" = FALSE, "Грязное присутствие проникает в мой разум, а затем исчезает." = FALSE, \
	"\"Тот факт, что Ратвар должен зависеть от таких простаков, как ты, ужасен.\"" = FALSE)
	message_span = "sevtug"

/obj/item/clockwork/component/geis_capacitor/fallen_armor
	name = "падшая броня"
	desc = "Безжизненные куски доспехов. Они необычно спроектированы и мне не подойдут."
	icon_state = "fallen_armor"
	cultist_message = "Из глаза маски вырывается красное пламя, прежде чем погаснуть."
	servant_of_ratvar_messages = list("Часть брони на мгновение парит вдали от остальных." = FALSE, "Перед тем как потухнуть в кирасе, в кирасе появляется красное пламя." = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor/antennae
	name = "моторная антенна мании"
	desc = "Пара помятых и изогнутых усиков. Они постоянно издают статическое шипение."
	icon_state = "mania_motor_antennae"
	cultist_message = "Моя голова наполнена статическим электричеством."
	servant_of_ratvar_messages = list("\"Кто-то сломал это.\"" = TRUE, "\"Вы сами сломали это?\"" = TRUE, "\"И вообще, зачем мы отдали это таким простакам?\"" = TRUE, \
	"\"По крайней мере, мы можем использовать их для чего-то - в отличие от меня.\"" = TRUE)

/obj/item/clockwork/component/replicant_alloy
	name = "репликантный сплав"
	desc = "На вид прочный, но очень податливый кусок металла. Кажется, что он хочет превратиться в нечто большее."
	icon_state = "replicant_alloy"
	cultist_message = "Сплав на мгновение приобретает вид кричащего лица."
	servant_of_ratvar_messages = list("\"Всегда есть чем заняться. Доберись до этого.\"" = FALSE, "\"Неработающие руки хуже сломанных. Принимайтесь за работу.\"" = FALSE, \
	"В сплаве на мгновение появляется подробное изображение Ратвара." = FALSE)
	message_span = "nezbere"

/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment
	name = "разбитый фрагмент анимы"
	desc = "Расколотые куски металла. Не подлежит ремонту и полностью непригоден для использования."
	icon_state = "smashed_anime_fragment"
	cultist_message = "Осколки на мгновение завибрируют в моих руках."
	servant_of_ratvar_messages = list("\"...все еще борюсь...\"" = FALSE, "\"...где я...?\"" = FALSE, "\"...верни меня... назад...\"" = FALSE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/replicant_alloy/replication_plate
	name = "пластина репликации"
	desc = "Плоский тяжелый металлический диск с треугольной формой на поверхности."
	icon_state = "replication_plate"
	cultist_message = "Тарелка дрожит в руках, как будто пытается уйти."
	servant_of_ratvar_messages = list("\"Положите это на часы и вернитесь к работе.\"" = FALSE, "\"Хуже тех слуг, каких ты имел до этого.\"" = TRUE, \
	"\"Было бы разумно защитить их лучше, друг.\"" = TRUE)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/hierophant_ansible
	name = "анзибль иерофанта"
	desc = "Какой-то передатчик? Кажется, будто он пытается что-то сказать."
	icon_state = "hierophant_ansible"
	cultist_message = "\"Gur obff fnlf vg'f abg ntnvafg gur ehyrf gb-xvyy lbh.\""
	servant_of_ratvar_messages = list("\"Изгнание - такая скука. Я не могу здесь охотиться.\"" = TRUE, "\"Что тебя держит? Я хочу пойти убить что-нибудь.\"" = TRUE, \
	"\"ХЕХЕХЕХЕХЕХЕХЕ!\"" = FALSE, "\"Если я убью тебя достаточно быстро, ты думаешь, босс заметит?\"" = TRUE)
	message_span = "nzcrentr"

/obj/item/clockwork/component/hierophant_ansible/obelisk
	name = "призма обелиска"
	desc = "Призма, которая иногда ярко светится. Кажется, что-то не так."
	cultist_message = "Призма дико мерцает в моих руках, прежде чем возобновить свое обычное свечение.."
	servant_of_ratvar_messages = list("На мгновение слышу характерный звук сети Иерофанта." = FALSE, "\"Иероф'ант: Тр'а'сляни'я прова'лена.\"" = TRUE, \
	"Обелиск дико мерцает, словно пытаясь открыть шлюз." = FALSE, "\"С'бой про'странствен'ного шл'юза.\"" = TRUE)
	icon_state = "obelisk_prism"
	w_class = WEIGHT_CLASS_NORMAL

//Shards of Alloy, suitable only as a source of power for a replica fabricator.
/obj/item/clockwork/alloy_shards
	name = "осколки репликантного сплава"
	desc = "Сломанные осколки какого-то странно податливого металла. Иногда они двигаются и светятся."
	icon_state = "alloy_shards"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/randomsinglesprite = FALSE
	var/randomspritemax = 2
	var/sprite_shift = 9

/obj/item/clockwork/alloy_shards/Initialize(mapload)
	. = ..()
	if(randomsinglesprite)
		replace_name_desc()
		icon_state = "[icon_state][rand(1, randomspritemax)]"
		pixel_x = rand(-sprite_shift, sprite_shift)
		pixel_y = rand(-sprite_shift, sprite_shift)

/obj/item/clockwork/alloy_shards/proc/replace_name_desc()
	name = "осколок репликантного сплава"
	desc = "Сломанный осколок какого-то странно податливого металла. Иногда он двигается и кажется, что светится."

/obj/item/clockwork/alloy_shards/clockgolem_remains
	name = "обломок механического голема"
	desc = "Куча металлолома. Кажется, поврежден и не подлежит ремонту."
	icon_state = "clockgolem_dead"
	sprite_shift = 0

/obj/item/clockwork/alloy_shards/large
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_large"
	sprite_shift = 9

/obj/item/clockwork/alloy_shards/medium
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_medium"
	sprite_shift = 10

/obj/item/clockwork/alloy_shards/medium/gear_bit
	randomspritemax = 4
	icon_state = "gear_bit"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/medium/gear_bit/replace_name_desc()
	name = "кусочек шестерни"
	desc = "Сломанный кусок шестерни. Ты хочешь это взять?"

/obj/item/clockwork/alloy_shards/medium/gear_bit/large //gives more power

/obj/item/clockwork/alloy_shards/medium/gear_bit/large/replace_name_desc()
	..()
	name = "сложная зубчатая коронка"

/obj/item/clockwork/alloy_shards/small
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	randomspritemax = 3
	icon_state = "shard_small"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/pinion_lock
	name = "фиксатор шестерни"
	desc = "Помятые и поцарапанные шестерни. Очень тяжёлые."
	icon_state = "pinion_lock"
