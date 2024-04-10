/obj/item/deployablemine
	name = "deployable mine"
	desc = "An unarmed landmine. It can be planted to arm it."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "landmine"
	w_class = WEIGHT_CLASS_SMALL
	var/mine_type = /obj/effect/mine
	var/arming_time = 3 SECONDS

/obj/item/deployablemine/afterattack(atom/plantspot, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(plantspot,/turf/open/floor))
		to_chat(user, span_warning("You can't plant the mine here!"))
		return
	to_chat(user, span_notice("You start arming the [src]..."))
	if(do_after(user, arming_time, src))
		new mine_type(plantspot)
		to_chat(user, span_notice("You plant and arm the [src]."))
		log_combat(user, src, "planted and armed")
		qdel(src)

/obj/item/deployablemine/stun
	desc = "An unarmed stun mine. It can be planted to arm it."
	mine_type = /obj/effect/mine/stun

/obj/item/deployablemine/heavy
	name = "deployable sledgehammer mine"
	desc = "An unarmed heavy stun mine designed to cripple those who step upon it."
	mine_type = /obj/effect/mine/stun/heavy
	arming_time = 10 SECONDS

/obj/item/deployablemine/explosive
	name = "explosive mine"
	desc = "An unarmed explosive mine designed to give whomever steps upon it the last bad day of their lives."
	mine_type = /obj/effect/mine/explosive

/obj/item/deployablemine/honk
	name = "deployable honkblaster 1000"
	desc = "An advanced pranking landmine for clowns, honk! Delivers an extra loud HONK to the head when triggered. It can be planted to arm it, or have its sound customised with a sound synthesiser."
	mine_type = /obj/effect/mine/sound
/** another time, another place.
/obj/item/deployablemine/traitor
	name = "exploding rubber duck"
	desc = "A pressure activated explosive disguised as a rubber duck. Plant it to arm."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	mine_type = /obj/effect/mine/explosive/traitor

/obj/item/deployablemine/traitor/bigboom
	name = "high yield exploding rubber duck"
	desc = "A pressure activated explosive disguised as a rubber duck. Plant it to arm. This version is fitted with high yield X4 for a larger blast."
	mine_type = /obj/effect/mine/explosive/traitor/bigboom
**/
/obj/item/deployablemine/gas
	name = "oxygen gas mine"
	desc = "An unarmed mine that releases oxygen into the air when triggered. Pretty pointless huh."
	mine_type = /obj/effect/mine/gas

/obj/item/deployablemine/plasma
	name = "incendiary mine"
	desc = "An unarmed mine that releases plasma into the air when triggered, then ignites it."
	mine_type = /obj/effect/mine/gas/plasma

/obj/item/deployablemine/sleepy
	name = "knockout mine"
	desc = "An unarmed mine that releases N2O into the air when triggered. Nighty Night!"
	mine_type = /obj/effect/mine/gas/n2o



/obj/item/deployablemine/explosive/mothplushie
	name = "moth plushie"
	desc = "An adorable mothperson plushy. It's a huggable bug!"
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "moffplush"
	inhand_icon_state = "moffplush"
	mine_type = /obj/effect/mine/explosive/mothplushie

/obj/item/deployablemine/explosive/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "map_plushie_lizard"
	inhand_icon_state = "plushie_lizard"
	mine_type = /obj/effect/mine/explosive/lizardplushie

/obj/item/deployablemine/explosive/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon_state = "map_plushie_carp"
	inhand_icon_state = "carp_plushie"
	icon = 'icons/obj/toys/plushes.dmi'
	mine_type = /obj/effect/mine/explosive/carpplushie

/obj/item/deployablemine/explosive/bubbleplush
	name = "\improper Bubblegum plushie"
	desc = "The friendly red demon that gives good miners gifts."
	icon_state = "bubbleplush"
	icon = 'icons/obj/toys/plushes.dmi'
	mine_type = /obj/effect/mine/explosive/bubbleplush

/obj/item/deployablemine/explosive/plushvar
	name = "\improper Ratvar plushie"
	desc = "An adorable plushie of the clockwork justiciar himself with new and improved spring arm action."
	icon_state = "plushvar"
	icon = 'icons/obj/toys/plushes.dmi'
	mine_type = /obj/effect/mine/explosive/plushvar

/obj/item/deployablemine/explosive/narplush
	name = "\improper Nar'sie plushie"
	desc = "A small stuffed doll of the elder goddess Nar'sie. Who thought this was a good children's toy?"
	icon_state = "narplush"
	icon = 'icons/obj/toys/plushes.dmi'
	mine_type = /obj/effect/mine/explosive/narplush

/obj/item/deployablemine/explosive/nukeplushie
	name = "operative plushie"
	desc = "A stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	inhand_icon_state = "plushie_nuke"
	icon = 'icons/obj/toys/plushes.dmi'
	mine_type = /obj/effect/mine/explosive/nukeplushie

/obj/item/deployablemine/explosive/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "map_plushie_slime"
	inhand_icon_state = "plushie_slime"
	icon = 'icons/obj/toys/plushes.dmi'
	mine_type = /obj/effect/mine/explosive/slimeplushie

/obj/item/deployablemine/explosive/fakeian
	name = "Ian"
	desc = "It's the HoP's beloved corgi."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "corgi"
	mine_type = /obj/effect/mine/explosive/fakeian
