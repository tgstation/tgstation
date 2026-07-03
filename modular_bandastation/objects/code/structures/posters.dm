/obj/structure/sign/poster/apply_holiday()
	var/old_state = icon_state
	. = ..()

	if(icon_state != old_state && icon == 'modular_bandastation/objects/icons/obj/structures/posters.dmi')
		icon = 'icons/obj/poster.dmi'

// Contraband
/obj/structure/sign/poster/contraband/lady
	name = "Соблазнительная Красотка"
	desc = "На плакате изображена крайне сексуальная девушка."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/lady, 32)

/obj/structure/sign/poster/contraband/very_robust
	name = "Робаст"
	desc = "Вы видите слегка потрёпанный плакат, на котором изображен КРАСНЫЙ туллбокс! На плакате написано \"Опасно, робастное!\", некоторые утверждают, что эта красная краска на плакате сделана из настоящей крови."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/very_robust, 32)

/obj/structure/sign/poster/contraband/vodka
	name = "Водка"
	desc = "Рекламный плакат водки, напитка от настоящих мужчин для настоящих мужчин. Почувствуй себя космическим медведем."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband3"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/vodka, 32)

/obj/structure/sign/poster/contraband/wanted
	name = "Вотер Потассиумович"
	desc = "На плакате вы видите: лысый, черноглазый мужчина, лет 30, и его разыскивают на просторах всего космоса. Что он сделал, чтобы его так разыскивали..."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband4"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/wanted, 32)

/obj/structure/sign/poster/contraband/soulless_figures
	name = "Бездушные фигуры"
	desc = "Плакат изображает множество безвольно слоняющихся тёмных фигур. Кажется они смотрят прямо на тебя, жуть..."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband5"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/soulless_figures, 32)

/obj/structure/sign/poster/contraband/your_fate
	name = "Твоя судьба"
	desc = "На плакате изображается дом и ряд одинаковых домов уходящих вдаль, расположенных на кровавом полотне. Ниже можно разглядеть тень искореженной руки.\nНад домами возвышаются существа чертоватого вида, а надпись снизу гласит: \"Твоя судьба?\""
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband6"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/your_fate, 32)

/obj/structure/sign/poster/contraband/watching_eye
	name = "Всевидящее Око"
	desc = "На плакате изображен глаз, излучающий свет. Текст на плакате гласит: \"Оно следит за\", \"Тобой\"."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband7"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/watching_eye, 32)

/obj/structure/sign/poster/contraband/bread
	name = "Кара небесная"
	desc = "Хлебом единым жив человек."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "bread"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/contraband/bread, 32)

// Sword of Altam

/obj/item/poster/random_sword_of_altam
	name = "Random Sword Of Altam Posters (SOA)"
	poster_type = /obj/structure/sign/poster/sword_of_altam/random
	icon_state = "rolled_poster"

/obj/structure/sign/poster/sword_of_altam
	poster_item_name = "SOA poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its vulgar themes have marked it as contraband aboard Nanotrasen space facilities."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/sword_of_altam/random
	name = "random SOA poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/sword_of_altam

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/random, 32)

/obj/structure/sign/poster/sword_of_altam/killer
	name = "Убийца"
	desc = "На плакате изображен мужчина в старом офицерском пальто Нанотрейзен. Краткая надпись снизу гласит: \"Убийца\"."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband8"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/killer, 32)

/obj/structure/sign/poster/sword_of_altam/nt_crap1
	name = "Испорченный плакат НТ"
	desc = "Кто-то с лихвой оторвался на логотипе Компании!"
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband9"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/nt_crap1, 32)

/obj/structure/sign/poster/sword_of_altam/fight_now
	name = "Сражайся! Сейчас!"
	desc = "Громогласный призыв на фоне потрепанного галактического флага вульпканинов. Наступают интересные времена."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband10"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/fight_now, 32)

/obj/structure/sign/poster/sword_of_altam/nt_crap2
	name = "Испорченный плакат НТ"
	desc = "Следы кровавой когтистой лапы на логотипе Компании. Ярый дух протеста!"
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband11"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/nt_crap2, 32)

/obj/structure/sign/poster/sword_of_altam/unite
	name = "Объединяйтесь!"
	desc = "Явно пропагандистский плакат, призывающий к единению вульпканинов."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband12"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/unite, 32)

/obj/structure/sign/poster/sword_of_altam/brotherhood
	name = "Братство"
	desc = "Изображение вульпканинов, объединенных одной целью. Такого история еще не видела."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband13"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/brotherhood, 32)

/obj/structure/sign/poster/sword_of_altam/altam_sword
	name = "Меч Альтама"
	desc = "Меч Альтама - радикальная повстанческая организация вульпканинов, действующая с 2569 года на территории ТСФ и объектах Нанотрейзен, жертвами беспощадных налетов которой являются исключительно люди. Их методы - террор, их цель - месть, их Родина - Альтам."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "contraband14"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/sword_of_altam/altam_sword, 32)

// Legit
/obj/structure/sign/poster/official/mars
	name = "Плакат Марса"
	desc = "Это плакат, выпущенный компанией Generic Space в рамках серии памятных плакатов, посвящённых чудесам космоса."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "legit1"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/mars, 32)

/obj/structure/sign/poster/official/wild_west
	name = "Дикое Карго"
	desc = "Красивое дикое место с собственным шерифом."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "legit2"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/wild_west, 32)

/obj/structure/sign/poster/official/razumause
	name = "Разумышь"
	desc = "Хей-хей! Что может пойти не так, да?"
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "legit3"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/razumause, 32)

/obj/structure/sign/poster/official/assist_pride
	name = "Гордость ассистента"
	desc = "Даже в космосе профессия ассистента востребована. И этот плакат демонстрирует их красоту."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "legit4"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/assist_pride, 32)

/obj/structure/sign/poster/official/cool_scientist
	name = "Крутой генетик"
	desc = "Едва заметная ухмылка и стильные солнцезащитные очки этого мужчины как бы говорят вам: \"Будь крутым, чувак!\". Ниже имеются инициалы J.D. и подпись: \"Лучший генетик сектора Эридана.\""
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "legit5"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/cool_scientist, 32)

/obj/structure/sign/poster/official/atmos_team
	name = "Огонь и лёд"
	desc = "Плакат изображает двух инженеров-атмосферников - рыжеволосого парня с пламенной улыбкой и беловолосую девушку с холодным взглядом. Небольшая надпись в низу гласит: \"С.О. & Э.Ж. - гордость отдела.\""
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "legit6"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/atmos_team, 32)

/obj/structure/sign/poster/official/kurit
	name = "Курение скуривает"
	desc = "ЗАДУМАЙСЯ."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "kurit"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/kurit, 32)

/obj/structure/sign/poster/official/breakfast
	name = "Завтрак"
	desc = "ММ ЕДА..."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "breakfast"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/breakfast, 32)

/obj/structure/sign/poster/official/krill
	name = "Криль"
	desc = "\"Во всём этом мире я один такой. Один на криллион.\""
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "krill"

// Music

/obj/structure/sign/poster/official/selected_ambient_works
	name = "Selected Ambient Works 85–92"
	desc = "Плакат странно выглядящего водопроводного крана. Или это лошадь?.."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "selected_ambient_works"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/selected_ambient_works, 32)

/obj/structure/sign/poster/official/tell_all_the_people
	name = "Tell All The People"
	desc = "\"Скажи чтоб не шли за мной.\""
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "tell_all_the_people"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/tell_all_the_people, 32)

/obj/structure/sign/poster/official/sweet_ginger_green
	name = "Sweet Ginger Green"
	desc = "Когда не знаешь что послушать за работой - врубай Зелёненьких!"
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "sweet_ginger_green"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/sweet_ginger_green, 32)

/obj/structure/sign/poster/official/vine_lady
	name = "Vine Lady"
	desc = "На плакате изображена деликатная дама с бокалом вина."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "vine_lady"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/vine_lady, 32)

/obj/structure/sign/poster/official/a_broken_frame
	name = "A Broken Frame"
	desc = "\"Ищем постеры в журналах моды.\""
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "a_broken_frame"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/a_broken_frame, 32)

/obj/structure/sign/poster/official/fight_songs
	name = "Fight Songs"
	desc = "Критический удар по барабанным перепонкам."
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "fight_songs"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/fight_songs, 32)

/obj/structure/sign/poster/official/rolling_stones
	name = "The Rolling Stones"
	desc = "Куда они катятся?"
	icon = 'modular_bandastation/objects/icons/obj/structures/posters.dmi'
	icon_state = "rolling_stones"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/poster/official/rolling_stones, 32)
