/datum/species/moth
	name = "\improper Mothman"
	plural_form = "Mothmen"
	id = SPECIES_MOTH
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/moth = SPRITE_ACCESSORY_NONE,
	)
	mutant_organs = list(
		/obj/item/organ/wings/moth = "Plain",
		/obj/item/organ/antennae = "Plain",
	)
	meat = /obj/item/food/meat/slab/human/mutant/moth
	mutanttongue = /obj/item/organ/tongue/moth
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_cookie = /obj/item/food/muffin/moffin
	species_language_holder = /datum/language_holder/moth
	death_sound = 'sound/mobs/humanoids/moth/moth_death.ogg'
	payday_modifier = 1.0
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

/datum/species/moth/randomize_features()
	var/list/features = ..()
	features[FEATURE_MOTH_MARKINGS] = pick(SSaccessories.feature_list[FEATURE_MOTH_MARKINGS])
	return features

/datum/species/moth/get_scream_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/scream_moth.ogg'

/datum/species/moth/get_cough_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)


/datum/species/moth/get_cry_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/moth/get_sneeze_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'


/datum/species/moth/get_laugh_sound(mob/living/carbon/human/moth)
	return 'sound/mobs/humanoids/moth/moth_laugh1.ogg'

/datum/species/moth/get_sigh_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/moth/get_sniff_sound(mob/living/carbon/human/moth)
	if(moth.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/moth/get_physical_attributes()
	return "Moths have large and fluffy wings, which help them navigate the station if gravity is offline by pushing the air around them. \
		Due to that, it isn't of much use out in space. Their eyes are very sensitive."

/datum/species/moth/get_species_description()
	return "Нианы инсектоидные гуманоиды, ведущие кочевой образ жизни. \
	Они общительны, ценят коллектив и известны как торговцы, инженеры и посредники."

/datum/species/moth/get_species_lore()
	return list(
	"Родной мир Ниан - Зувийен, некогда богатая и разнообразная планета с множеством биомов и форм жизни. \
	Долгое время нианы жили разрозненными кланами, развивая культуру и науку, не покидая привычные регионы. \
	Со временем нестабильность местной звезды начала необратимо разрушать климат планеты. \
	Катастрофы и истощение ресурсов поставили цивилизацию ниан на грань вымирания.",

	"В условиях нарастающего кризиса нианы были вынуждены объединиться и пересмотреть своё устройство общества. \
	Борьба за ресурсы сменилась поиском долгосрочных решений для спасения вида. \
	Понимая, что Зувийен обречён, нианы начали активное освоение космоса и строительство звездного флота. \
	Так началась история их народа за пределами родного мира.",

	"Попытки спасти Зувийен с помощью терраформирования и автономных систем завершились катастрофой. \
	С тех пор нианы продолжают жить среди звёзд, сохраняя культуру и надежду однажды обрести новый дом.",
)



/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Прелестные крылья",
			SPECIES_PERK_DESC = "Моли могут летать в помещениях под давлением в условиях невесомости и безопасно приземляться с небольшой высоты.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "План питания",
			SPECIES_PERK_DESC = "Моли могут поедать одежду, чтобы временно подкрепиться.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Опаленные крылья",
			SPECIES_PERK_DESC = "Крылья молей хрупкие и легко сгорают.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Яркие огоньки",
			SPECIES_PERK_DESC = "Молям нужен дополнительный слой защиты от вспышек, чтобы защитить глаза \
				от офицеров службы безопасности или сварочных аппаратов. Сварочные \
				маски полностью спасают от вспышек.",
		),
	)

	return to_add
