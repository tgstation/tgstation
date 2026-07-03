/datum/species/skrell
	name = "Скрелл"
	plural_form = "Скреллы"
	id = SPECIES_SKRELL
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NODROWN,
		TRAIT_SWIMMER,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_language_holder = /datum/language_holder/skrell
	mutantbrain = /obj/item/organ/brain/skrell
	mutantheart = /obj/item/organ/heart/skrell
	mutantlungs = /obj/item/organ/lungs/skrell
	mutanteyes = /obj/item/organ/eyes/skrell
	mutanttongue = /obj/item/organ/tongue/skrell
	mutantliver = /obj/item/organ/liver/skrell
	mutantstomach = /obj/item/organ/stomach/skrell
	mutant_organs = list(
		/obj/item/organ/head_tentacle = /datum/sprite_accessory/skrell_head_tentacle/short::name,
		/obj/item/organ/cloth_wrap = /datum/sprite_accessory/skrell_cloth_wrap/short::name,
		/obj/item/organ/tentacle_ornament = /datum/sprite_accessory/skrell_tentacle_ornament/none::name,
	)
	exotic_bloodtype = BLOOD_TYPE_SKRELL

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/skrell,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/skrell,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/skrell,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/skrell,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/skrell,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/skrell,
	)
	payday_modifier = 1.5

/datum/species/skrell/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = COLOR_TRUE_BLUE
	human.dna.features[FEATURE_SKRELL_HEAD_TENTACLE] = /datum/sprite_accessory/skrell_head_tentacle/long::name
/// When creating a picture for the preferences UI, organs are created first, and only then dna.features are given
	for(var/obj/item/organ/O in human.organs)
		if(istype(O, /obj/item/organ/head_tentacle) || istype(O, /obj/item/organ/tentacle_ornament) || istype(O, /obj/item/organ/cloth_wrap))
			qdel(O)
	var/obj/item/organ/head_tentacle/T = new()
	T.Insert(human, special = TRUE)

	human.update_body(is_creating = TRUE)

/datum/species/skrell/randomize_features()
	var/list/features = ..()
	features[FEATURE_SKRELL_CLOTH_WRAP_TOGGLE] = prob(50) ? pick(SSaccessories.feature_list[FEATURE_SKRELL_CLOTH_WRAP_TOGGLE]) : SPRITE_ACCESSORY_NONE

	var/cloth_color = "#[random_color()]"
	features[FEATURE_SKRELL_CLOTH_WRAP_COLOR] = cloth_color
	return features

/datum/species/skrell/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "box-open",
			SPECIES_PERK_NAME = "Головной карман",
			SPECIES_PERK_DESC = "Имеют орган головного кармана, вмещающий маленький предмет",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fish-fins",
			SPECIES_PERK_NAME = "Подводное дыхание",
			SPECIES_PERK_DESC = "Скреллы являются амфибиями и могут дышать под водой",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "person-swimming",
			SPECIES_PERK_NAME = "Прекрасные пловцы",
			SPECIES_PERK_DESC = "Миры скреллов почти полностью покрыты водой, что не могло не повлиять на их адаптацию",
		),
	)
	return to_add

/datum/species/skrell/get_physical_attributes()
	return "Скреллы представляют собой двуногих гуманоидов, \
		отличительной которых есть наличе мешочка в их головных щупальцах а так же полная непереносимость алкоголя"

/datum/species/skrell/get_species_description()
	return "Скреллы - вид амфибий, родом с Кверрбалака, влажной тропической планеты, полной болот и архипелагов. \
	Скреллы это высокоразвитая и разумная раса, живущая под властью Кверр-Кэтиш, главного правительственного органа.<br/><br/> \
	Скреллы травоядны и изобильны по своей природе благодаря главным постулатам скреллской культуры. \
	Хотя Скреллы предпочитают дипломатию, они участвуют в крупнейшем военном союзе в галактике - Человеко-Скреллаинском Альянсе."

/datum/species/skrell/get_species_lore()
	return list(
		"Скреллианская Империя – надгосударственный союз скреллианских городов-государств, \
			княжеств и небольших королевств. Империя всю свою историю является децентрализованным образованием \
			со сложной феодальной иерархической структурой, \
			объединяющей несколько тысяч территориально-государственных образований, \
			но, несмотря на это, Империи удается проводить более-менее схожую политику во всех своих уголках. \
			Официальной политической идеологией Империи и опорой её общественного строя является Вечный мир.",

		"Вечный мир – скреллианская реакционная неофеодальная политическая идеология и \
			консервативное общественно-политическое движение, целью которого является \
			сохранение традиционной общественно-экономической структуры, основанной на структуре древнего общества скреллов, \
			а также устанавливаемый на их основе автократический режим.",

		"Вечный мир характеризуется жесткой социальной иерархией - кастовой системой, отсутствием социальной мобильности, \
			подавлением оппозиции и индивидуальных свобод, коллективизмом, диктатурой правящей касты Кверр-Кэтиш \
			и её сплоченностью – против управляемых каст, высокой степенью административной децентрализации.",

		"Теоретики Вечного мира утверждают необходимость в данном политическом строе с позиции философии \
			материалистического рационализма, общественной стабильности и технологического прогресса. \
			С их точки зрения, административная и политическая децентрализация, наличие специально выделенной \
			сосуществующей друг с другом касты управленцев и скреллианская экономическая структура минимизируют \
			необходимость в межгосударственных конфликтах, а классовое сотрудничество между кастами скреллианского \
			общества позволяет максимизировать экономическое и научно-прогрессивное развитие всего общества \
			и цивилизации скреллов в целом.",

		"Критики Вечного мира считают, что целью этого строя является не качество жизни и развитие скреллианской цивилизации, \
			а политический контроль и власть сама по себе.",

		"Исполнительную власть в Империи номинально осуществляет учрежденное в 2331 г. н.э. Имперское Представительство, \
			однако законодательно его полномочия ограничены внешней политикой. \
			Представитель избирается Имперским Собранием – центральным форумом Империи. \
			Исполнение внутренней политики Империи возложено на правительства имперских субъектов. \
			Концепция Вечного мира предполагает коллективное участие всей касты Кверров вне зависимости \
			от государственной принадлежности в поддержании стабильности Империи и сплоченности Кверр-Кэтиш, \
			а законы Империи выражают коллективную волю всей правящей касты.",

		"Правителями государств скреллов являются короли, называемые Кверр-Скриа. \
			Как правило, они управляют одной городской агломерацией. \
			Спорные вопросы между государствами обычно решаются через дипломатические меры, \
			в крайних случаях - через силы специальных операций, но открытые конфронтации \
			и войны избегаются для поддержания стабильности и экономической взаимосвязанности.",

		"Однако некоторые расширяют подконтрольные территории до нескольких, \
			порою доходя до размеров человеческих государств, – таких именуют Крри-Кверриа, \
			что чаще всего (хотя и неверно) переводят как «император». \
			Такие случаи чаще всего происходят на пограничных или слабозаселенных территориях, \
			где центральное управление и оборона необходимы для выживания всей колонии.  \
			В других мирах экспансии Крри-Кверриа единым образом противостоят другие Кверры, \
			стремящиеся к исполнению постулатов Вечного мира, к сохранению баланса сил и статуса-кво. \
			Как правило, самопровозглашенные императоры встречают отпор от своего Ксаку Моглар (двора) \
			в виде неповиновения и от других Кверр-Скриа в форме дипломатических союзов и скрытых операций, \
			но в истории были и случаи открытых карательных экспедиций, собранных с ОСС по всей Империи для \
			недопущения образования центров объединения и, как следствие, общественного прогресса."
	)
