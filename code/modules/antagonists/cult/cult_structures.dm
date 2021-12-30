/obj/structure/destructible/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	debris = list(/obj/item/stack/sheet/runed_metal = 1)
	///if you want to add a special, non-default part of the description that only cultists and observers can see, store it in this variable
	var/cultist_examine_message

/obj/structure/destructible/cult/proc/conceal() //for spells that hide cult presence
	set_density(FALSE)
	visible_message(span_danger("[src] fades away."))
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes
	set_light_power(0)
	set_light_range(0)
	update_light()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/proc/reveal() //for spells that reveal cult presence
	set_density(initial(density))
	invisibility = 0
	visible_message(span_danger("[src] suddenly appears!"))
	alpha = initial(alpha)
	set_light_range(initial(light_range))
	set_light_power(initial(light_power))
	update_light()
	START_PROCESSING(SSfastprocess, src)


/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is [anchored ? "":"not "]secured to the floor.")
	if(IS_CULTIST(user) || isobserver(user))
		if(cultist_examine_message)
			. += span_cult("[cultist_examine_message]")
		if(cooldowntime > world.time)
			. += "<span class='cult italic'>The magic in [src] is too weak, [p_they()] will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>"

/obj/structure/destructible/cult/examine_status(mob/user)
	if(IS_CULTIST(user) || isobserver(user))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		return span_cult("[t_It] [t_is] at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(istype(user, /mob/living/simple_animal/hostile/construct/artificer))
		if(atom_integrity < max_integrity)
			user.changeNext_move(CLICK_CD_MELEE)
			atom_integrity = min(max_integrity, atom_integrity + 5)
			Beam(user, icon_state="sendbeam", time=4)
			user.visible_message(span_danger("[user] repairs \the <b>[src]</b>."), \
				span_cult("You repair <b>[src]</b>, leaving [p_they()] at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability."))
		else
			to_chat(user, span_cult("You cannot repair [src], as [p_theyre()] undamaged!"))
	else
		..()

/obj/structure/destructible/cult/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	update_appearance()

/obj/structure/destructible/cult/update_icon_state()
	icon_state = "[initial(icon_state)][anchored ? null : "_off"]"
	return ..()

/obj/structure/destructible/cult/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/structure/destructible/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar'Sie."
	cultist_examine_message = "A blood cultist can use it to create eldritch whetstones, construct shells, and flasks of unholy water."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>The altar shatters, leaving only the wailing of the damned!</span>"

/obj/structure/destructible/cult/talisman/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("You're pretty sure you know exactly what this is used for and you can't seem to touch it."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/list/items = list(
		"Eldritch Whetstone" = image(icon = 'icons/obj/kitchen.dmi', icon_state = "cult_sharpener"),
		"Construct Shell" = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct_cult"),
		"Flask of Unholy Water" = image(icon = 'icons/obj/drinks.dmi', icon_state = "holyflask")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Eldritch Whetstone")
			pickedtype += /obj/item/sharpener/cult
		if("Construct Shell")
			pickedtype += /obj/structure/constructshell
		if("Flask of Unholy Water")
			pickedtype += /obj/item/reagent_containers/glass/beaker/unholywater
		else
			return
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && IS_CULTIST(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You kneel before the altar and your faith is rewarded with the [choice]!"))

/obj/structure/destructible/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar'Sie."
	cultist_examine_message = "A blood cultist can use it to create Nar'Sien hardened armor, flagellant's robes, and eldritch longswords."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = "<span class='warning'>The forge breaks apart into shards with a howling scream!</span>"

/obj/structure/destructible/cult/forge/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("The heat radiating from [src] pushes you back."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/list/items = list(
		"Nar'Sien Hardened Armor" = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cult_armor"),
		"Flagellant's Robe" = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cultrobes"),
		"Eldritch Longsword" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "cultblade")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Nar'Sien Hardened Armor")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/hardened
		if("Flagellant's Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Eldritch Longsword")
			pickedtype += /obj/item/melee/cultblade
		else
			return
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && IS_CULTIST(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You work the forge as dark knowledge guides your hands, creating the [choice]!"))



/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	light_range = 1.5
	light_color = COLOR_SOFT_RED
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/destructible/cult/pylon/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 5, \
		brute_heal = 0.4, \
		burn_heal = 0.4, \
		blood_heal = 0.4, \
		simple_heal = 1.2, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HEALS_FROM_CULT_PYLONS, \
		healing_color = COLOR_CULT_RED, \
	)

	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circle_view_turfs(src, 5))
			if(istype(T, /turf/open/floor/engine/cult))
				cultturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/engine/cult,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm,
			))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		if(length(validturfs))
			var/turf/T = pick(validturfs)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else if (length(cultturfs))
			var/turf/open/floor/engine/cult/F = pick(cultturfs)
			new /obj/effect/temp_visual/cult/turf/floor(F)
		else
			// Are we in space or something? No cult turfs or
			// convertable turfs?
			last_corrupt = world.time + corrupt_delay*2

/obj/structure/destructible/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	cultist_examine_message = "A blood cultist can use it to create zealot's blindfolds, shuttle curse orbs, and veil walker equipment."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = "<span class='warning'>The books and tomes of the archives burn into ash as the desk shatters!</span>"

/obj/structure/destructible/cult/tome/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("These books won't open and it hurts to even try and read the covers."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/list/items = list(
		"Zealot's Blindfold" = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold"),
		"Shuttle Curse" = image(icon = 'icons/obj/cult.dmi', icon_state = "shuttlecurse"),
		"Veil Walker Set" = image(icon = 'icons/obj/cult.dmi', icon_state = "shifter")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Zealot's Blindfold")
			pickedtype += /obj/item/clothing/glasses/hud/health/night/cultblind
		if("Shuttle Curse")
			pickedtype += /obj/item/shuttle_curse
		if("Veil Walker Set")
			pickedtype += /obj/item/cult_shift
			pickedtype += /obj/item/flashlight/flare/culttorch
		else
			return
	if(src && !QDELETED(src) && anchored && pickedtype.len && Adjacent(user) && !user.incapacitated() && IS_CULTIST(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You summon the [choice] from the archives!"))

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
