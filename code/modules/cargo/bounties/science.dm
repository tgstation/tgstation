
/datum/bounty/item/science/relic
	name = "Обнаруженные E.X.P.E.R.I-MENTORом девайсы"
	description = "Пссс, слушайте. Не рассказывайте ассистентам, но мы урезаем им стоимость тех 'странных объектов', что они находят. Найдите одно такое устройство и обследуйте его с помощью E.X.P.E.R.I-MENTORа, после отправьте его нам."
	reward = CARGO_CRATE_VALUE * 8
	wanted_types = list(/obj/item/relic = TRUE)

/datum/bounty/item/science/relic/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/relic/experiment = O
	if(experiment.activated)
		return TRUE
	return

/datum/bounty/item/science/bepis_disc
	name = "Переформатированный технологический диск"
	description = "Оказывается, что дискеты на которых BEPIS печатает экспериментальные узлы имеют хорошую вместимость данных. Отправьте нам несколько дискет, когда они будут готовы."
	reward = CARGO_CRATE_VALUE * 8
	wanted_types = list(
		/obj/item/disk/design_disk/bepis/remove_tech = TRUE,
		/obj/item/disk/design_disk/bepis = TRUE,
	)

/datum/bounty/item/science/genetics
	name = "Genetics Disability Mutator"
	description = "Понимание генома гуманоидов является первым шагом для лечения многих появившихся в космосе генетических деффектов и увеличения наших базовых возможностей."
	reward = CARGO_CRATE_VALUE * 2
	wanted_types = list(/obj/item/dnainjector = TRUE)
	///What's the instability
	var/desired_instability = 0

/datum/bounty/item/science/genetics/New()
	. = ..()
	desired_instability = rand(10,40)
	reward += desired_instability * (CARGO_CRATE_VALUE * 0.2)
	description += " Мы хотим инжектор ДНК с общей нестабильностью выше [desired_instability] очков."

/datum/bounty/item/science/genetics/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/dnainjector/mutator = O
	if(mutator.used)
		return FALSE
	var/inst_total = 0
	for(var/pot_mut in mutator.add_mutations)
		var/datum/mutation/mutation = pot_mut
		if(initial(mutation.quality) != POSITIVE)
			continue
		inst_total += mutation.instability
	if(inst_total >= desired_instability)
		return TRUE
	return FALSE

//******Modular Computer Bounties******
/datum/bounty/item/science/ntnet
	name = "Модульные планшеты"
	description = "Оказывается, что NTnet на самом деле не был фантазией, кто же знал. Отправьте несколько функционирующих КПК, чтобы помочь нам освоить новейшие технологии."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 4
	wanted_types = list(/obj/item/modular_computer/pda = TRUE)
	var/require_powered = TRUE

/datum/bounty/item/science/ntnet/applies_to(obj/O)
	if(!..())
		return FALSE
	if(require_powered)
		var/obj/item/modular_computer/computer = O
		if(!istype(computer) || !computer.enabled)
			return FALSE
	return TRUE

/datum/bounty/item/science/ntnet/laptops
	name = "Модульные ноутбуки"
	description = "Центральному Командованию нужно что-то намного мощнее планшета, но более портативное чем консоль. Помогите этим старикам, отправив нам несколько работающих ноутбуков. Отправьте их включенными."
	reward = CARGO_CRATE_VALUE * 3
	required_count = 2
	wanted_types = list(/obj/item/modular_computer/laptop = TRUE)

/datum/bounty/item/science/ntnet/console
	name = "Модульные компьютерные консоли"
	description = "Наш отдел больших данных нуждается в более мощном оборудовании для игры в 'Разбомби Кубан Пи-', кхм, для тщательного мониторинга угроз в вашем секторе. Отправьте нам работающую модульную компьютерную консоль."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 1
	wanted_types = list(/obj/machinery/modular_computer = TRUE)
	require_powered = FALSE

/datum/bounty/item/science/ntnet/console/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/machinery/modular_computer/computer = O
	if(!istype(computer) || !computer.cpu)
		return FALSE
	return TRUE


//******Anomaly Cores******
/datum/bounty/item/science/ref_anomaly
	name = "Переработанное блюспейс ядро"
	description = "Нам нужно блюспейс ядро для помещения в Фазона. Пожалуйста, отправьте нам одно."
	reward = CARGO_CRATE_VALUE * 20
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bluespace = TRUE)

/datum/bounty/item/science/ref_anomaly/can_get(obj/O)
	var/anomaly_type = wanted_types[1]
	if(SSresearch.created_anomaly_types[anomaly_type] >= SSresearch.anomaly_hard_limit_by_type[anomaly_type])
		return FALSE
	return TRUE

/datum/bounty/item/science/ref_anomaly/flux
	name = "Переработанное флюкс ядро"
	description = "Мы пытаемся создать тесла пушку, чтобы разобраться с молями. Отправьте нам флюкс ядро, пожалуйста."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/flux = TRUE)

/datum/bounty/item/science/ref_anomaly/pyro
	name = "Переработанное пирокластическое ядро"
	description = "Нам нужно изучить переработанное пирокластическое ядро, пожалуйста отправьте одно."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/pyro = TRUE)

/datum/bounty/item/science/ref_anomaly/grav
	name = "Переработанное гравитационное ядро"
	description = "Центральный НИО пытается обнаружить способ заставить мехов парить, отправьте гравитационное ядро."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/grav = TRUE)

/datum/bounty/item/science/ref_anomaly/vortex
	name = "Переработанное вортекс ядро"
	description = "Мы собираемся бросить вортекс ядро в червоточину и посмотреть, что произойдёт. Отправьте одно."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/vortex = TRUE)

/datum/bounty/item/science/ref_anomaly/hallucination
	name = "Переработанное галюциногенное ядро"
	description = "Мы создаём лучшую версию космических наркотиков, отправьте нам ядро для воспроизведения его эффектов."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/hallucination = TRUE)

/datum/bounty/item/science/ref_anomaly/bioscrambler
	name = "Переработанное биоскрэмблер ядро"
	description = "Наш ящер уборщик потерял все свои конечности, отправьте нам биоскрэмблер ядро для их замены."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bioscrambler = TRUE)

/datum/bounty/item/science/ref_anomaly/dimensional
	name = "Переработанное пространственное ядро"
	description = "Мы пытаемся сохранить деньги на наших ежегодных реновациях ЦК. Отправьте нам пространственное ядро."
	wanted_types = list(/obj/item/assembly/signaler/anomaly/dimensional = TRUE)
