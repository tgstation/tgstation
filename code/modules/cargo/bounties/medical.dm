/datum/bounty/item/medical/heart
	name = "Сердце"
	description = "Командор Джонсон в критическом состоянии после ещё одного пережитого сердечного приступа. Врачи говорят, что им нужно новое сердце как можно быстрее. Отправьте одно, быстро! Мы возьмём и кибернетическое, но только улучшенное."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(
		/obj/item/organ/heart = TRUE,
		/obj/item/organ/heart/cybernetic = FALSE,
		/obj/item/organ/heart/cybernetic/tier2 = TRUE,
		/obj/item/organ/heart/cybernetic/tier3 = TRUE,
	)

/datum/bounty/item/medical/lung
	name = "Лёгкие"
	description = "Недавний взрыв на Центральном Командовании оставил многих сотрудников с пробитыми лёгкими. Отправьте нам несколько лишних экземпляров. Мы возьмём и кибернетические, но только улучшенные."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/lungs = TRUE,
		/obj/item/organ/lungs/cybernetic = FALSE,
		/obj/item/organ/lungs/cybernetic/tier2 = TRUE,
		/obj/item/organ/lungs/cybernetic/tier3 = TRUE,
	)

/datum/bounty/item/medical/appendix
	name = "Аппендикс"
	description = "Повар Центрального Командования Гибб хочет приготовить блюдо, используя, особый деликатес: аппендикс. Если вы отправите один, он вам заплатит."
	reward = CARGO_CRATE_VALUE * 5 //there are no synthetic appendixes
	wanted_types = list(/obj/item/organ/appendix = TRUE)

/datum/bounty/item/medical/ears
	name = "Уши"
	description = "Множество сотрудников станции 12 остались глухими в следствие неавторизованной клоунады. Отправьте им новые уши. Мы возьмём и кибернетические, но только улучшенные."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/ears = TRUE,
		/obj/item/organ/ears/cybernetic = FALSE,
		/obj/item/organ/ears/cybernetic/upgraded = TRUE,
		/obj/item/organ/ears/cybernetic/whisper = TRUE,
		/obj/item/organ/ears/cybernetic/xray = TRUE,
		/obj/item/organ/ears/cybernetic/volume = TRUE,
	)

/datum/bounty/item/medical/liver
	name = "Печень"
	description = "Множество высокопоставленных дипломатов ЦК были госпитализированы с отказом печени после встречи с тремя послами Третьего Советского Союза. Помогите нам, ладно? Мы возьмём и кибернетические, но только улучшенные."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/liver = TRUE,
		/obj/item/organ/liver/cybernetic = FALSE,
		/obj/item/organ/liver/cybernetic/tier2 = TRUE,
		/obj/item/organ/liver/cybernetic/tier3 = TRUE,
	)

/datum/bounty/item/medical/eye
	name = "Органические глаза"
	description = "Директор исследований Виллем на станции 5 запрашивает пару органических глаз. Не спрашивайте зачем, просто отправьте ему."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(
		/obj/item/organ/eyes = TRUE,
		/obj/item/organ/eyes/robotic = FALSE,
	)

/datum/bounty/item/medical/tongue
	name = "Языки"
	description = "Недавняя атака мимов экстремистов оставила экипаж станции 23 немыми. Отправьте несколько лишних языков."
	reward = CARGO_CRATE_VALUE * 10
	required_count = 3
	wanted_types = list(/obj/item/organ/tongue = TRUE)

/datum/bounty/item/medical/lizard_tail
	name = "Хвост ящерицы"
	description = "Федерация волшебников похитила у Нанотрейзен хвосты ящеров. Пока ЦК разбирается с волшебниками, не может ли станция отправить хвост из своих запасов?"
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/item/organ/tail/lizard = TRUE)

/datum/bounty/item/medical/cat_tail
	name = "Хвост кошки"
	description = "На Центральном Командовании кончились щётки для чистки сильнозагрязнённых труб. Не выручите ли вы нас отправкой кошачьего хвоста?"
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/item/organ/tail/cat = TRUE)

/datum/bounty/item/medical/chainsaw
	name = "Бензопила"
	description = "У СМО на ЦК имеются проблемы с операциями на големах. Она просит одну бензопилу, пожалуйста."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/item/chainsaw = TRUE)

/datum/bounty/item/medical/tail_whip //Like the cat tail bounties, with more processing.
	name = "Nine Tails whip"
	description = "Командор Джексон ищет отличное дополнение для её коллекции экзотического оружия. Она вас наградит и за кошачий, и за ящерский девятихвост."
	reward = CARGO_CRATE_VALUE * 8
	wanted_types = list(/obj/item/melee/chainofcommand/tailwhip = TRUE)

/datum/bounty/item/medical/surgerycomp
	name = "Хирургический компьютер"
	description = "После очередного взрывного инцидента на нашем ежегодном сырфесте на ЦК, у нас лежит огромная куча раненного экипажа. Пожалуйста, отправьте нам свежий хирургический компьютер, когда это возможно."
	reward = CARGO_CRATE_VALUE * 12
	wanted_types = list(/obj/machinery/computer/operating = TRUE)

/datum/bounty/item/medical/surgerytable
	name = "Хирургический стол"
	description = "После недавнего притока инфицированного экипажа, мы замечаем, что маски не справляются в одиночку. Серебрянные операционные столы, к слову, могут нам помочь, отправьте нам один для использования."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/structure/table/optable = TRUE)

/datum/bounty/item/medical/scanning
	name = "Crew Medical Scanning"
	description = "Conduct a routine medical scan using any health analyzer of a crew member with with a near perfect bill of health or better to ensure the crew is taking their medical care seriously. Then, print the medical report and ship it back to us."
	reward = CARGO_CRATE_VALUE * 8
	required_count = 2
	wanted_types = list(/obj/item/paper/medical_report = TRUE)

/datum/bounty/item/medical/scanning/applies_to(obj/shipped)
	. = ..()
	if(!istype(shipped, /obj/item/paper/medical_report))
		return FALSE
	var/obj/item/paper/medical_report/report = shipped
	if(!report)
		return FALSE

	var/mob/living/patient = report.last_healthy_scanned_mob?.resolve()
	if(patient)
		return TRUE
	return FALSE
