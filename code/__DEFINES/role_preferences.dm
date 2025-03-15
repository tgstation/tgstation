// Значения для предпочтений ANTAG, ролей событий и т. Д.
// Они синхронизируются с базой данных, если вы измените значения определения.
// Затем вы должны обновить базу данных!

#define ROLE_BROTHER "Blood Brother"
#define ROLE_CHANGELING "Changeling"
#define ROLE_CULTIST "Cultist"
#define ROLE_HERETIC "Heretic"
#define ROLE_MALF "Malf AI"
#define ROLE_OPERATIVE "Operative"
#define ROLE_TRAITOR "Traitor"
#define ROLE_WIZARD "Wizard"
#define ROLE_SPY "Spy"

// Midround roles
#define ROLE_ABDUCTOR "Abductor"
#define ROLE_ALIEN "Xenomorph"
#define ROLE_BLOB "Blob"
#define ROLE_BLOB_INFECTION "Blob Infection"
#define ROLE_CHANGELING_MIDROUND "Changeling (Midround)"
#define ROLE_FUGITIVE "Fugitive"
#define ROLE_LONE_OPERATIVE "Lone Operative"
#define ROLE_MALF_MIDROUND "Malf AI (Midround)"
#define ROLE_NIGHTMARE "Nightmare"
#define ROLE_NINJA "Space Ninja"
#define ROLE_OBSESSED "Obsessed"
#define ROLE_OPERATIVE_MIDROUND "Operative (Midround)"
#define ROLE_PARADOX_CLONE "Paradox Clone"
#define ROLE_REV_HEAD "Head Revolutionary"
#define ROLE_SLEEPER_AGENT "Syndicate Sleeper Agent"
#define ROLE_SPACE_DRAGON "Space Dragon"
#define ROLE_SPIDER "Spider"
#define ROLE_WIZARD_MIDROUND "Wizard (Midround)"
#define ROLE_VOIDWALKER "Voidwalker"

// Latejoin roles
#define ROLE_HERETIC_SMUGGLER "Heretic Smuggler"
#define ROLE_PROVOCATEUR "Provocateur"
#define ROLE_STOWAWAY_CHANGELING "Stowaway Changeling"
#define ROLE_SYNDICATE_INFILTRATOR "Syndicate Infiltrator"

// Другие роли
#define ROLE_ANOMALY_GHOST "Ectoplasmic Anomaly Ghost"
#define ROLE_BRAINWASHED "Brainwashed Victim"
#define ROLE_DEATHSQUAD "Deathsquad"
#define ROLE_DRONE "Drone"
#define ROLE_EMAGGED_BOT "Malfunctioning Bot"
#define ROLE_HIVE "Hivemind Host" // Роль удалена, оставлена здесь в целях безопасности.
#define ROLE_HYPNOTIZED "Hypnotized Victim"
#define ROLE_LAVALAND "Lavaland"
#define ROLE_LAZARUS_BAD "Slaved Revived Mob"
#define ROLE_LAZARUS_GOOD "Friendly Revived Mob"
#define ROLE_MIND_TRANSFER "Mind Transfer Potion"
#define ROLE_MONKEY_HELMET "Monkey Mind Magnification Helmet"
#define ROLE_OVERTHROW "Syndicate Mutineer" // Роль удалена, оставлена здесь в целях безопасности.
#define ROLE_PAI "pAI"
#define ROLE_POSIBRAIN "Posibrain"
#define ROLE_PYROCLASTIC_SLIME "Pyroclastic Anomaly Slime"
#define ROLE_REV "Revolutionary"
#define ROLE_REVENANT "Revenant"
#define ROLE_SENTIENCE "Sentience Potion Spawn"
#define ROLE_SOULTRAPPED_HERETIC "Soultrapped Heretic"
#define ROLE_SYNDICATE "Syndicate"

#define ROLE_CLOWN_OPERATIVE "Clown Operative"
#define ROLE_FREE_GOLEM "Free Golem"
#define ROLE_MORPH "Morph"
#define ROLE_NUCLEAR_OPERATIVE "Nuclear Operative"
#define ROLE_POSITRONIC_BRAIN "Positronic Brain"
#define ROLE_SANTA "Santa"
#define ROLE_SERVANT_GOLEM "Servant Golem"
#define ROLE_SLAUGHTER_DEMON "Slaughter Demon"
#define ROLE_WIZARD_APPRENTICE "apprentice"
#define ROLE_SYNDICATE_MONKEY "Syndicate Monkey Agent"
#define ROLE_CONTRACTOR_SUPPORT "Contractor Support Unit"
#define ROLE_OPERATIVE_OVERWATCH "Operative Overwatch Agent"
#define ROLE_SYNDICATE_SABOBORG "Syndicate Sabotage Cyborg"
#define ROLE_SYNDICATE_MEDBORG "Syndicate Medical Cyborg"
#define ROLE_SYNDICATE_ASSAULTBORG "Syndicate Assault Cyborg"

#define ROLE_RECOVERED_CREW "Recovered Crew"

// Спавн роли
#define ROLE_ANCIENT_CREW "Ancient Crew"
#define ROLE_ASHWALKER "Ash Walker"
#define ROLE_BATTLECRUISER_CAPTAIN "Battlecruiser Captain"
#define ROLE_BATTLECRUISER_CREW "Battlecruiser Crew"
#define ROLE_BEACH_BUM "Beach Bum"
#define ROLE_BOT "Bot"
#define ROLE_DERELICT_DRONE "Derelict Drone"
#define ROLE_ESCAPED_PRISONER "Escaped Prisoner"
#define ROLE_EXILE "Exile"
#define ROLE_FUGITIVE_HUNTER "Fugitive Hunter"
#define ROLE_GHOST_ROLE "Ghost Role"
#define ROLE_HERMIT "Hermit"
#define ROLE_HOTEL_STAFF "Hotel Staff"
#define ROLE_LAVALAND_SYNDICATE "Lavaland Syndicate"
#define ROLE_LIFEBRINGER "Lifebringer"
#define ROLE_MAINTENANCE_DRONE "Maintenance Drone"
#define ROLE_SKELETON "Skeleton"
#define ROLE_SPACE_BAR_PATRON "Space Bar Patron"
#define ROLE_SPACE_BARTENDER "Space Bartender"
#define ROLE_SPACE_DOCTOR "Space Doctor"
#define ROLE_SPACE_PIRATE "Space Pirate"
#define ROLE_SPACE_SYNDICATE "Space Syndicate"
#define ROLE_SYNDICATE_CYBERSUN "Cybersun Space Syndicate" // Призрачная роль Синди из "Руин забытого корабля"
#define ROLE_SYNDICATE_CYBERSUN_CAPTAIN "Cybersun Space Syndicate Captain" // Забытый корабль, капитан Синди
#define ROLE_SYNDICATE_DRONE "Syndicate Drone"
#define ROLE_VENUSHUMANTRAP "Venus Human Trap"
#define ROLE_ZOMBIE "Zombie"

// Связанный с виртуальным dom
#define ROLE_GLITCH "Glitch" // Родительский тип для всех ролей vdom
#define ROLE_CYBER_POLICE "Cyber Police"
#define ROLE_CYBER_TAC "Cyber Tac"
#define ROLE_NETGUARDIAN "NetGuardian Prime"

/// Здесь указаны антагонисты, с которыми вы можете работать в настройках.
/// Клавиши - это антагонисты, значения - это количество дней с момента первого подключения игрока к игре.
///	Первое подключение для воспроизведения.
GLOBAL_LIST_INIT(special_roles, list(
	// Раундстарт
	ROLE_BROTHER = 0,
	ROLE_CHANGELING = 0,
	ROLE_CLOWN_OPERATIVE = 14,
	ROLE_CULTIST = 14,
	ROLE_HERETIC = 0,
	ROLE_MALF = 0,
	ROLE_OPERATIVE = 14,
	ROLE_REV_HEAD = 14,
	ROLE_TRAITOR = 0,
	ROLE_WIZARD = 14,
	ROLE_SPY = 0,

	// В раунде
	ROLE_ABDUCTOR = 0,
	ROLE_ALIEN = 0,
	ROLE_BLOB = 0,
	ROLE_BLOB_INFECTION = 0,
	ROLE_CHANGELING_MIDROUND = 0,
	ROLE_FUGITIVE = 0,
	ROLE_LONE_OPERATIVE = 14,
	ROLE_MALF_MIDROUND = 0,
	ROLE_NIGHTMARE = 0,
	ROLE_NINJA = 0,
	ROLE_OBSESSED = 0,
	ROLE_OPERATIVE_MIDROUND = 14,
	ROLE_PARADOX_CLONE = 0,
	ROLE_REVENANT = 0,
	ROLE_SLEEPER_AGENT = 0,
	ROLE_SPACE_DRAGON = 0,
	ROLE_SPIDER = 0,
	ROLE_WIZARD_MIDROUND = 14,
	ROLE_VOIDWALKER = 0,

	// Позднее присоединение
	ROLE_HERETIC_SMUGGLER = 0,
	ROLE_PROVOCATEUR = 14,
	ROLE_SYNDICATE_INFILTRATOR = 0,
	ROLE_STOWAWAY_CHANGELING = 0,

	// Я не совсем понимаю, почему они здесь, но они не двигаются
	ROLE_GLITCH = 0,
	ROLE_PAI = 0,
	ROLE_SENTIENCE = 0,
	ROLE_RECOVERED_CREW = 0,
))

//	Работа определяет, что происходит, если вы не соответствуете требованиям для какой-либо работы во время отбора
#define BEOVERFLOW 1
#define BERANDOMJOB 2
#define RETURNTOLOBBY 3
