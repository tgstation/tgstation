/mob/living/basic/goat/chef
	name = "Боря"
	desc = "Этот козёл - парнокопытное гурме шефа, в его мрачных глазах-бусинках так и читается амибициозный нрав! Он не твой друг, ведь за каждым игривым прыжком может скрываться неожиданный выпад."
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/cow/black/pipa
	name = "Пипа"
	desc = "Старая добрая старушка прямиком с Лай'Оши. Нескончаемый источник природного молока без ГМО. Ну почти без ГМО..."
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/chicken/wife
	name = "Галя"
	desc = "Почетная наседка. Жена Коммандора, следующая за ним в коммандировки по космическим станциям."
	icon_state = "chicken_white"
	icon_living = "chicken_white"
	icon_dead = "chicken_white_dead"
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20

/mob/living/basic/chicken/cock/clucky
	name = "Коммандор Курицын"
	desc = "Также известный как Клакки, Кудахтор и Мистер Вселенная. Его великая армия бесчисленна, а грудка накачана. Ко-ко-ко, вот так вот."
	gold_core_spawnable = NO_SPAWN
	maxHealth = 40 // Veteran
	health = 40

/mob/living/basic/goose/scientist
	name = "Гуськор"
	desc = "Учёный Гусь. Везде учусь. Крайне умная и задиристая птица. Обожает генетику. Надеемся это не бывший пропавший генетик..."
	icon = 'modular_bandastation/mobs/icons/farm_animals.dmi'
	icon_state = "goose_labcoat"
	icon_living = "goose_labcoat"
	icon_dead = "goose_labcoat_dead"
	icon_resting = "goose_labcoat_rest"
	attack_verb_continuous = "щипает по научному"
	attack_verb_simple = "умно щипает"
	gold_core_spawnable = NO_SPAWN
	maxHealth = 80
	health = 80
	resting = TRUE

/mob/living/basic/lizard/big/crocodile/gena
	name = "Гена"
	desc = "Крокодил обожающий музыкальные инструменты и плюшевые игрушки. Пожевать."
	faction = list("neutral")

// rats
/mob/living/basic/mouse/rat/gray/ratatui
	name = "Рататуй"
	real_name = "Рататуй"
	desc = "Личная крыса шеф повара, помогающая ему при готовке наиболее изысканных блюд. До момента пока он не пропадет и повар не начнет готовить что-то новенькое..."
	gold_core_spawnable = NO_SPAWN
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES, FACTION_NEUTRAL)
	maxHealth = 20
	health = 20

/mob/living/basic/mouse/rat/gray/ratatui/update_desc()
	. = ..()
	desc = initial(desc)

/mob/living/basic/mouse/rat/irish/remi
	name = "Реми"
	real_name = "Реми"
	desc = "Близкий друг Рататуя. Не любимец повара, но пока тот не мешает на кухне, ему разрешили здесь остаться. Очень толстая крыса."
	gold_core_spawnable = NO_SPAWN
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES, FACTION_NEUTRAL)
	maxHealth = 25
	health = 25
	transform = matrix(1.250, 0, 0, 0, 1, 0) // Толстячок на +2 пикселя

/mob/living/basic/mouse/rat/irish/remi/update_desc()
	. = ..()
	desc = initial(desc)

/mob/living/basic/mouse/rat/white/brain
	name = "Брейн"
	real_name = "Брейн"
	desc = "Сообразительная личная лабораторная крыса директора исследований, даже освоившая речь. Настолько часто сбегал, что его перестали помещать в клетку. Он явно хочет захватить мир. Где-то спрятался его напарник..."
	gold_core_spawnable = NO_SPAWN
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES, FACTION_NEUTRAL)
	maxHealth = 20
	health = 20
	//universal_speaker = 1
	resting = TRUE

/mob/living/basic/mouse/rat/white/brain/update_desc()
	. = ..()
	desc = initial(desc)

/obj/effect/decal/remains/mouse/pinkie
	name = "Пинки"
	desc = "Когда-то это был напарник самой сообразительной крысы в мире. К сожалению он таковым не являлся..."
	anchored = TRUE

// mouse
/mob/living/basic/mouse/factory/pizdos
	name = "Пиздос"
	desc = "Мышиный пиздос всегда с ним, где на работе опять пиздос. Труд облагораживает мышь. \
			Пиздос наоборот. На работу пиздос как надо мыши, а она не хочет."
	gold_core_spawnable = NO_SPAWN

// hamster
/mob/living/basic/mouse/hamster/representative
	name = "представитель Алексей"
	desc = "Представитель федерации хомяков. Проявите уважение при его виде, \
	ведь он с позитивным исходом решил немало дипломатических вопросов между федерацией мышей, \
	республикой крыс и корпорацией Нанотрейзен. Да и кто вообще хомяка так назвал?!"
	icon = 'modular_bandastation/mobs/icons/mouse.dmi'
	icon_state = "hamster_rep"
	icon_living = "hamster_rep"
	icon_dead = "hamster_rep_dead"
	icon_resting = "hamster_rep_rest"
	held_state = "hamster_rep"
	gold_core_spawnable = NO_SPAWN
	maxHealth = 20
	health = 20
	resting = TRUE

/mob/living/basic/possum/key
	name = "Ключик"
	desc = "Маленький работяга. Его жилетка подчеркивает его рабочие... лапы. Тот еще трудяга. Очень не любит ассистентов в инженерном отделе. И Полли. Интересно, почему?"
	icon_state = "possum_poppy"
	icon_living = "possum_poppy"
	icon_dead = "possum_poppy_dead"
	icon_resting = "possum_poppy_sleep"
	icon_harm = "possum_poppy_aaa"
	maxHealth = 50
	health = 50
	gold_core_spawnable = NO_SPAWN

	held_state = "possum_poppy"

/mob/living/basic/frog/wednesday
	name = "Среда"
	real_name = "Среда"
	desc = "Это Среда, мои чуваки!"
	maxHealth = 30
	health = 30
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/frog/scream/nonconformist
	name = "Нонконформист"
	real_name = "Нонконформитс"
	desc = "Доносит свою позицию через крик."
	maxHealth = 30
	health = 30
	gold_core_spawnable = NO_SPAWN


//cats
/mob/living/basic/pet/cat/floppa
	name = "Большой Шлёпа"
	desc = "Он выглядит так, будто собирается совершить военное преступление."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "floppa"
	icon_living = "floppa"
	icon_dead = "floppa_dead"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/fat/iriska
	name = "Ириска"
	desc = "Упитана. Счастлива. Бюрократы её обожают. И похоже даже черезчур сильно."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/white/penny
	name = "Копейка"
	desc = "Любит таскать монетки и мелкие предметы. Успевайте прятать их!"
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	resting = TRUE

/mob/living/basic/pet/cat/birman/crusher
	name = "Бедокур"
	desc = "Любит крушить всё что не прикручено. Нужно вовремя прибираться."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	resting = TRUE

/mob/living/basic/pet/cat/space/musya
	name = "Муся"
	desc = "Кошка мечтательница, всегда стремящаяся ввысь. Любимая почтенная кошка отдела токсинов. Всегда готова к вылетам!"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/black/salem
	name = "Салем"
	real_name = "Салем"
	desc = "Говорят что это бывший колдун, лишенный всех своих сил и превратившейся в черного кота Советом Колдунов из-за попытки захватить мир, а в руки НТ попал чтобы отбывать своё наказание. Судя по его скверному нраву, это может быть похоже на правду."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

// dogs
/mob/living/basic/pet/dog/brittany/psycho
	name = "Перрито"
	real_name = "Перрито"
	desc = "Собака, обожающая котов, особенно в сапогах, прекрасно лающая на Испанском, прошла терапевтические курсы, готова выслушать все ваши проблемы и выдать вам целебных объятий с завершением в виде почесыванием животика."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	resting = TRUE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/pug/frank
	name = "Фрэнк"
	real_name = "Фрэнк"
	desc = "Мопс полученный в результате эксперимента ученых в черном. Почему его не забрали интересный вопрос. Похоже он всем надоел своей болтовней, после чего его лишили дара речи."
	resting = TRUE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/genn
	name = "Геннадий"
	desc = "Собачий аристократ. Выглядит очень важным и начитанным. Доброжелательный любимец ассистентов."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	resting = TRUE


// fox

/mob/living/basic/pet/fox/forest/alisa
	name = "Алиса"
	desc = "Алиса, любимый питомец любого Офицера Специальных Операций. Интересно, что она говорит?"
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	icon_state = "alisa"
	icon_living = "alisa"
	icon_dead = "alisa_dead"
	icon_resting = "alisa_rest"
	faction = list("nanotrasen")
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/basic/pet/fox/fennec/fenya
	name = "Феня"
	desc = "Миниатюрная лисичка c важным видом и очень большими ушами. Был пойман во время разливания огромного мороженого по формочкам и теперь Магистрат держит его при себе и следит за ним. Но похоже что ему даже нравится быть частью правосудия."
	icon = 'modular_bandastation/mobs/icons/pets.dmi'
	resting = TRUE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
