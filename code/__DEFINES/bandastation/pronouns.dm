// MARK: Declensions

// Падежи русского языка
/// Именительный: Кто это? Клоун и ассистуха.
#define NOMINATIVE 1
/// Родительный: Откусить кусок от кого? От клоуна и ассистухи.
#define GENITIVE 2
/// Дательный: Дать полный доступ кому? Клоуну и ассистухе.
#define DATIVE 3
/// Винительный: Обвинить кого? Клоуна и ассистуху.
#define ACCUSATIVE 4
/// Творительный: Возить по полу кем? Клоуном и ассистухой.
#define INSTRUMENTAL 5
/// Предложный: Прохладная история о ком? О клоуне и об ассистухе.
#define PREPOSITIONAL 6

/// Макрос для упрощения создания листа падежей для объекта
#define RU_NAMES_LIST_INIT(nominative, genitive, dative, accusative, instrumental, prepositional) (list(NOMINATIVE = nominative, GENITIVE = genitive, DATIVE = dative, ACCUSATIVE = accusative, INSTRUMENTAL = instrumental, PREPOSITIONAL = prepositional))
