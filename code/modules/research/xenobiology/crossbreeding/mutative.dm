//All mutative extracts result in items so let's just put them in a single file for the ease of readability.
/obj/item/slimecross/mutative
	icon_state = "mutative"
	name = "mutated"
	effect = "mutative"

/obj/item/slimecross/mutative/darkpurple
	colour = "dark purple"
	effect_desc = "Fully stocks up any pacman type generator with fuel."

/obj/item/slimecross/mutative/darkblue
	colour = "dark blue"
	effect_desc = "Turns 50u of water into single stack of snow."

/obj/item/slimecross/mutative/darkblue/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!target.reagents)
		return
	var/datum/reagents/reggies = target.reagents
	var/datum/reagent/water = reggies.has_reagent(/datum/reagent/water)
	if(!water)
		return
	var/sheet_num = FLOOR(water.volume / 50,1)
	if(!sheet_num)
		return
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	reggies.remove_reagent(/datum/reagent/water,sheet_num*50)
	var/locc = drop_location()
	for(var/num in 1 to sheet_num)
		new /obj/item/stack/sheet/mineral/snow(locc)

/obj/item/slimecross/mutative/green
	colour = "green"
	effect_desc = "Single use core, use it in your hand to become immune to damage slow down and soft crit, but your blood becomes acid and if you die you are gibbed."

/obj/item/slimecross/mutative/green/attack_self(mob/user)
	. = ..()
	if(do_after(user,10 SECONDS,TRUE,user))
		playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
		to_chat(user, "<span class='warning'>You feel your whole body shift...</span>")
		user.emote("scream")
		ADD_TRAIT(user,TRAIT_DISFIGURED,type)
		ADD_TRAIT(user,TRAIT_GIB_DEATH,type)
		ADD_TRAIT(user,TRAIT_IGNOREDAMAGESLOWDOWN,type)
		ADD_TRAIT(user,TRAIT_NOSOFTCRIT,type)
		if(!istype(user,/mob/living/carbon/human))
			return
		var/mob/living/carbon/human/human_user = user
		human_user.dna.species.exotic_blood = /datum/reagent/toxin/acid/nitracid
		human_user.AdjustParalyzed(5 SECONDS)

/obj/item/slimecross/mutative/oil
	colour = "oil"
	effect_desc = "Provides long-lasting mood buff."

/obj/item/slimecross/mutative/oil/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	SEND_SIGNAL(user,COMSIG_ADD_MOOD_EVENT,"oil_buff",/datum/mood_event/oil_buff)
	qdel(src)

/obj/item/slimecross/mutative/item_spawner
	effect_desc = "Use in hand to recieve the corresponding item."
	///Item to spawn
	var/item_spawner

/obj/item/slimecross/mutative/item_spawner/item_spawner/attack_self(mob/user)
	. = ..()
	if(item_spawner)
		playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
		new item_spawner(drop_location())
		qdel(src)

/obj/item/slimecross/mutative/item_spawner/grey
	item_spawner = /obj/item/slimeball
	colour = "grey"

/obj/item/slimecross/mutative/item_spawner/orange
	item_spawner = /obj/item/spear/slime
	colour = "orange"

/obj/item/slimecross/mutative/item_spawner/purple
	item_spawner = /obj/item/stack/medical/slime_patch
	colour = "purple"

/obj/item/slimecross/mutative/item_spawner/blue
	item_spawner = /obj/item/tank/internals/emergency_oxygen/slime
	colour = "blue"

/obj/item/slimecross/mutative/item_spawner/metal
	item_spawner = /obj/item/stack/sheet/slime
	colour = "metal"

/obj/item/slimecross/mutative/item_spawner/yellow
	item_spawner = /obj/item/stack/cable_coil/slime
	colour = "yellow"

/obj/item/slimecross/mutative/item_spawner/silver
	item_spawner = /obj/item/reagent_containers/food/snacks/pie/plain/slime
	colour = "silver"

/obj/item/slimecross/mutative/item_spawner/bluespace
	item_spawner = /obj/item/wormhole_jaunter/slime
	colour = "bluespace"

/obj/item/slimecross/mutative/item_spawner/sepia
	item_spawner = /obj/item/storage/photo_album/slime
	colour = "sepia"

/obj/item/slimecross/mutative/item_spawner/cerulean
	item_spawner = /obj/machinery/photocopier/slime
	colour = "cerulean"

/obj/item/slimecross/mutative/item_spawner/pyrite
	item_spawner = /obj/item/clothing/under/suit/blacktwopiece/slime
	colour = "pyrite"

/obj/item/slimecross/mutative/item_spawner/red
	item_spawner = /obj/item/slime_iv
	colour = "red"

/obj/item/slimecross/mutative/item_spawner/pink
	item_spawner = /obj/item/slime_letter
	colour = "pink"

/obj/item/slimecross/mutative/gold
	colour = "gold"

/obj/item/slimecross/mutative/gold/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	for(var/I in 0 to 25)
		new /obj/item/coin/slime(drop_location())
	qdel(src)

/obj/item/slimecross/mutative/item_spawner/black
	item_spawner = /obj/item/slime_veil
	colour = "black"

/obj/item/slimecross/mutative/item_spawner/lightpink
	item_spawner = /obj/item/kitchen/knife/slime
	colour = "light pink"

/obj/item/slimecross/mutative/item_spawner/adamantine
	item_spawner = /obj/item/claymore/slime
	colour = "adamantine"

/obj/item/slimecross/mutative/item_spawner/rainbow
	item_spawner = /obj/item/guardiancreator/slime
	colour = "rainbow"
