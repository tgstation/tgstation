// MARK: Declensions

// Падежи русского языка
/// Именительный: Кто это? Клоун и ассистуха.
#define NOMINATIVE "именительный"
/// Родительный: Откусить кусок от кого? От клоуна и ассистухи.
#define GENITIVE "родительный"
/// Дательный: Дать полный доступ кому? Клоуну и ассистухе.
#define DATIVE "дательный"
/// Винительный: Обвинить кого? Клоуна и ассистуху.
#define ACCUSATIVE "винительный"
/// Творительный: Возить по полу кем? Клоуном и ассистухой.
#define INSTRUMENTAL "творительный"
/// Предложный: Прохладная история о ком? О клоуне и об ассистухе.
#define PREPOSITIONAL "предложный"

/// Макрос для упрощения создания листа падежей для объекта
#define RU_NAMES_LIST(base, nominative, genitive, dative, accusative, instrumental, prepositional) (list("base" = base, NOMINATIVE = nominative, GENITIVE = genitive, DATIVE = dative, ACCUSATIVE = accusative, INSTRUMENTAL = instrumental, PREPOSITIONAL = prepositional))

/// Макрос для добавления значений для переменных
#define RU_NAMES_LIST_INIT(base, nominative, genitive, dative, accusative, instrumental, prepositional)\
	ru_names = RU_NAMES_LIST(base, nominative, genitive, dative, accusative, instrumental, prepositional);\
	ru_name_base = base;\
	ru_name_nominative = nominative;\
	ru_name_genitive = genitive;\
	ru_name_dative = dative;\
	ru_name_accusative = accusative;\
	ru_name_instrumental = instrumental;\
	ru_name_prepositional = prepositional
