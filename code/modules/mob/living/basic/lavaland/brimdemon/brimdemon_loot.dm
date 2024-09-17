/// Brimdemon crusher trophy, it... makes a funny sound?
/obj/item/crusher_trophy/brimdemon_fang
	name = "brimdemon's fang"
	icon_state = "brimdemon_fang"
	desc = "A fang from a brimdemon's corpse."
	denied_type = /obj/item/crusher_trophy/brimdemon_fang
	/// Cartoon punching vfx
	var/static/list/comic_phrases = list("BOOM", "BANG", "KABLOW", "KAPOW", "OUCH", "BAM", "KAPOW", "WHAM", "POW", "KABOOM")

/obj/item/crusher_trophy/brimdemon_fang/effect_desc()
	return "mark detonation to create visual and audiosensory effects at the target"

/obj/item/crusher_trophy/brimdemon_fang/on_mark_detonation(mob/living/target, mob/living/user)
	target.balloon_alert_to_viewers("[pick(comic_phrases)]!")
	playsound(target, 'sound/mobs/non-humanoids/brimdemon/brimdemon_crush.ogg', 100)

/// Reagent pool left by dying brimdemon
/obj/effect/decal/cleanable/brimdust
	name = "brimdust"
	desc = "Dust from a brimdemon. It is considered valuable for its' botanical abilities."
	icon_state = "brimdust"
	icon = 'icons/obj/mining.dmi'
	layer = FLOOR_CLEAN_LAYER
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/brimdust/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/brimdust, 15)

/// Ashwalker ore sensor crafted from brimdemon ash
/obj/item/ore_sensor
	name = "ore sensor"
	desc = "Using demonic frequencies, this ear-mounted tool detects ores in the nearby terrain."
	icon_state = "oresensor"
	icon = 'icons/obj/mining.dmi'
	slot_flags = ITEM_SLOT_EARS
	var/range = 5
	var/cooldown = 4 SECONDS //between the standard and the advanced ore scanner in strength
	COOLDOWN_DECLARE(ore_sensing_cooldown)

/obj/item/ore_sensor/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_EARS)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/ore_sensor/dropped(mob/user, silent)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/ore_sensor/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, ore_sensing_cooldown))
		return
	COOLDOWN_START(src, ore_sensing_cooldown, cooldown)
	mineral_scan_pulse(get_turf(src), range, src)
