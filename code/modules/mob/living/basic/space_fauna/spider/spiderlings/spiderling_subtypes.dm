/// This whole file is just a container for the spiderling subtypes that actually differentiate into different young spiders. None of them are particularly special as of now.
/// Will differentiate into the base young spider (known colloquially as the "guard" spider).
/mob/living/basic/spider/growing/spiderling/guard
	grow_as = /mob/living/basic/spider/growing/young/guard
	name = "guard spiderling"
	desc = "Furry and brown, it looks defenseless. This one has sparkling red eyes."

/// Will differentiate into the "ambush" young spider.
/mob/living/basic/spider/growing/spiderling/ambush
	grow_as = /mob/living/basic/spider/growing/young/ambush
	name = "ambush spiderling"
	desc = "Furry and white, it looks defenseless. This one has sparkling pink eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "ambush_spiderling"
	icon_dead = "ambush_spiderling_dead"

/// Will differentiate into the "scout" young spider.
/mob/living/basic/spider/growing/spiderling/scout
	grow_as = /mob/living/basic/spider/growing/young/scout
	name = "scout spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling blue eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "scout_spiderling"
	icon_dead = "scout_spiderling_dead"
	sight = SEE_SELF|SEE_MOBS

/// Will differentiate into the "hunter" young spider.
/mob/living/basic/spider/growing/spiderling/hunter
	grow_as = /mob/living/basic/spider/growing/young/hunter
	name = "hunter spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling purple eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "hunter_spiderling"
	icon_dead = "hunter_spiderling_dead"

/// Will differentiate into the "nurse" young spider.
/mob/living/basic/spider/growing/spiderling/nurse
	grow_as = /mob/living/basic/spider/growing/young/nurse
	name = "nurse spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling green eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "nurse_spiderling"
	icon_dead = "nurse_spiderling_dead"

/// Will differentiate into the "tangle" young spider.
/mob/living/basic/spider/growing/spiderling/tangle
	grow_as = /mob/living/basic/spider/growing/young/tangle
	name = "tangle spiderling"
	desc = "Furry and brown, it looks defenseless. This one has dim brown eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "tangle_spiderling"
	icon_dead = "tangle_spiderling_dead"

/// Will differentiate into the "tank" young spider.
/mob/living/basic/spider/growing/spiderling/tank
	grow_as = /mob/living/basic/spider/growing/young/tank
	name = "tank spiderling"
	desc = "Furry and purple, it looks defenseless. This one has dim yellow eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "tank_spiderling"
	icon_dead = "tank_spiderling_dead"

/// Will differentiate into the "breacher" young spider.
/mob/living/basic/spider/growing/spiderling/breacher
	grow_as = /mob/living/basic/spider/growing/young/breacher
	name = "breacher spiderling"
	desc = "Furry and beige, it looks defenseless. This one has dim red eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "breacher_spiderling"
	icon_dead = "breacher_spiderling_dead"

/// Will differentiate into the "midwife" young spider.
/mob/living/basic/spider/growing/spiderling/midwife
	grow_as = /mob/living/basic/spider/growing/young/midwife
	name = "broodmother spiderling"
	desc = "Furry and black, it looks defenseless. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "midwife_spiderling"
	icon_dead = "midwife_spiderling_dead"

/// Will differentiate into the "viper" young spider.
/mob/living/basic/spider/growing/spiderling/viper
	grow_as = /mob/living/basic/spider/growing/young/viper
	name = "viper spiderling"
	desc = "Furry and black, it looks defenseless. This one has sparkling magenta eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "viper_spiderling"
	icon_dead = "viper_spiderling_dead"

/// Will differentiate into the "tarantula" young spider.
/mob/living/basic/spider/growing/spiderling/tarantula
	grow_as = /mob/living/basic/spider/growing/young/tarantula
	name = "tarantula spiderling"
	desc = "Furry and black, it looks defenseless. This one has abyssal red eyes."
	icon = 'icons/mob/simple/arachnoid.dmi'
	icon_state = "tarantula_spiderling"
	icon_dead = "tarantula_spiderling_dead"
