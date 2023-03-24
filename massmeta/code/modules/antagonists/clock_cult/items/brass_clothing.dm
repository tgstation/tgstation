/obj/item/clothing/suit/clockwork
	name = "латунная броня"
	desc = "Прочный латунный доспех, который носили солдаты армий Ратвара."
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	worn_icon = 'icons/mob/clothing/suits/chaplain.dmi'
	armor = /datum/armor/clockwork_suit
	slowdown = 0.6
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/clockwork, /obj/item/stack/tile/bronze, /obj/item/clockwork, /obj/item/gun/energy/kinetic_accelerator/crossbow/clockwork)

/datum/armor/clockwork_suit
	melee = 50
	bullet = 60
	laser = 30
	energy = 80
	bomb = 80
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/equipped(mob/living/user, slot)
	. = ..()
	spawn(20)
		if(src && user && !is_servant_of_ratvar(user))
			to_chat(user, span_userdanger("Чувствую прилив энергии по всему телу!"))
			user.dropItemToGround(src, TRUE)
			var/mob/living/carbon/C = user
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				H.electrocution_animation(20)
			C.adjust_jitter(100 SECONDS)
			C.adjust_stutter(10 SECONDS)

/obj/item/clothing/suit/clockwork/speed
	name = "роба божества"
	desc = "Блестящий костюм, светящийся яркой энергией. Владелец сможет быстро перемещаться по полям битвы, но сможет выдержать меньший урон перед падением.."
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "clockwork_cuirass_speed"
	slowdown = -0.3
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = /datum/armor/clockwork_cuirass_speed

/datum/armor/clockwork_cuirass_speed
	melee = 40
	bullet = 40
	laser = 10
	energy = -20
	bomb = 60
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/cloak
	name = "плащ-покров"
	desc = "Шатающийся плащ, который рассеивает свет вокруг себя, искажая внешний вид пользователя, из-за чего его трудно увидеть невооруженным глазом. Однако он обеспечивает очень слабую защиту.."
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cloak"
	armor = /datum/armor/clockwork_cloak
	slowdown = 0.4
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/shroud_active = FALSE
	var/i
	var/f
	var/start
	var/previous_alpha

/datum/armor/clockwork_cloak
	melee = 10
	bullet = 60
	laser = 40
	energy = 20
	bomb = 40
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/suit/clockwork/cloak/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING && !shroud_active)
		shroud_active = TRUE
		previous_alpha = user.alpha
		animate(user, alpha=140, time=30)
		start = user.filters.len
		var/X,Y,rsq
		for(i=1, i<=7, ++i)
			do
				X = 60*rand() - 30
				Y = 60*rand() - 30
				rsq = X*X + Y*Y
			while(rsq<100 || rsq>900)
			user.filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
		for(i=1, i<=7, ++i)
			f = user.filters[start+i]
			animate(f, offset=f:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
			animate(offset=f:offset-1, time=rand()*20+10)

/obj/item/clothing/suit/clockwork/cloak/dropped(mob/user)
	. = ..()
	if(shroud_active)
		shroud_active = FALSE
		for(i=1, i<=min(7, user.filters.len), ++i) // removing filters that are animating does nothing, we gotta stop the animations first
			f = user.filters[start+i]
			animate(f)
		do_sparks(3, FALSE, user)
		user.filters = null
		animate(user, alpha=previous_alpha, time=30)

/obj/item/clothing/glasses/clockwork
	name = "базовые механические очки"
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"

/obj/item/clothing/glasses/clockwork/equipped(mob/user, slot)
	. = ..()
	if(!is_servant_of_ratvar(user))
		to_chat(user, span_userdanger("Чувствую прилив энергии по всему телу!"))
		user.dropItemToGround(src, TRUE)
		var/mob/living/carbon/C = user
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.electrocution_animation(20)
		C.adjust_jitter(100 SECONDS)
		C.adjust_stutter(10 SECONDS)

/obj/item/clothing/glasses/clockwork/wraith_spectacles
	name = "призрачные очки"
	desc = "Мистические очки, светящиеся яркой энергией. Некоторые говорят, что могут видеть то, чего не следует видеть."
	icon_state = "wraith_specs"
	invis_view = SEE_INVISIBLE_OBSERVER
	invis_override = null
	flash_protect = -1
	vision_flags = SEE_MOBS
	glass_colour_type = /datum/client_colour/glass_colour/yellow
	var/mob/living/wearer
	var/applied_eye_damage

/obj/item/clothing/glasses/clockwork/wraith_spectacles/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/clockwork/wraith_spectacles/equipped(mob/living/user, slot)
	. = ..()
	if(!isliving(user))
		return
	if(slot == ITEM_SLOT_EYES)
		wearer = user
		applied_eye_damage = 0
		START_PROCESSING(SSobj, src)
		to_chat(user, span_nezbere("Внезапно вижу гораздо больше, но мои глаза начинают болеть..."))

/obj/item/clothing/glasses/clockwork/wraith_spectacles/process()
	. = ..()
	if(!wearer)
		STOP_PROCESSING(SSobj, src)
		return
	//~1 damage every 2 seconds, maximum of 70 after 140 seconds
	wearer.adjustOrganLoss(ORGAN_SLOT_EYES, 1, 70)
	applied_eye_damage = min(applied_eye_damage + 1, 70)

/obj/item/clothing/glasses/clockwork/wraith_spectacles/dropped(mob/user)
	. = ..()
	if(wearer && is_servant_of_ratvar(wearer))
		to_chat(user, span_nezbere("Моим глазам становится лучше."))
		addtimer(CALLBACK(wearer, /mob/living.proc/adjustOrganLoss, ORGAN_SLOT_EYES, -applied_eye_damage), 600)
		wearer = null
		applied_eye_damage = 0
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/clockcult
	name = "латунный шлем"
	desc = "Прочный латунный шлем, который носили солдаты армий Ратвара. Включает в себя встроенный диммер для защиты от вспышки, а также заглушку скрытого уровня для заводских сред."
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	worn_icon = 'icons/mob/clothing/head/chaplain.dmi'
	armor = /datum/armor/clockwork_helmet
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	flash_protect = 1

/datum/armor/clockwork_helmet
	melee = 50
	bullet = 60
	laser = 30
	energy = 80
	bio = 100
	bomb = 80
	fire = 100
	acid = 100

/obj/item/clothing/shoes/clockcult
	name = "латунные протекторы"
	desc = "Пара крепких латунных сапог, которые носили солдаты армий Ратвара."
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"

/obj/item/clothing/gloves/clockcult
	name = "латунные рукавицы"
	desc = "Пара крепких латунных перчаток, которые носили солдаты армий Ратвара."
	icon = 'massmeta/icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	siemens_coefficient = 0
	armor = /datum/armor/clockwork_gloves
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/datum/armor/clockwork_gloves
	fire = 80
	acid = 50
