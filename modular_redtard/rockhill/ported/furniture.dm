/obj/structure/bed/rockhill
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/obj/objects.dmi'
	icon_state = "bed"
	max_integrity = 100
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "bed"
	sleepy = 3
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/bedroll
	name = "bedroll"
	desc = "So you can sleep on the ground in relative peace."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "bedroll"
	sleepy = 2
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/foley/cloth_rip.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/inn
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "inn_bed"
	sleepy = 3
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/inn/double
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "double"
	pixel_y = 0
	sleepy = 3
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 2)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/inn/hay
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "haybed"
	sleepy = 3
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/inn/wool
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "woolbed"
	sleepy = 3
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/inn/wooldouble
	name = "bed"
	desc = "A soft warm bed complete with sheets and pillows."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "double_wool"
	pixel_y = 0
	sleepy = 3
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 2)
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/rockhill/rogue/shit
	name = "straw bed"
	desc = "A rough bed of straw. It's scratchy, and probably hides lots of bugs, but at least it's dry and warm."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "shitbed"
	sleepy = 1
	max_integrity = 100
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = BELOW_OBJ_LAYER

/obj/structure/chair/wood/rockhill/arrestchair
	name = "CASTIFICO"
	desc = "A chair-shaped machine that collects bounties, for a greater reward, in exchange for a penalty that some might consider worse than death."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/machines.dmi'
	icon_state = "evilchair"
	item_chair = null
	max_integrity = 999999
	resistance_flags = NONE
	rockhill_dulling = "bash"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "bench"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/church
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "church_benchleft"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/church/mid
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "church_benchmid"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/church/r
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "church_benchright"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/church/smallbench
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "benchsmall"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/couch
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "redcouch"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/couch/r
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "redcouch2"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/coucha
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "couchaleft"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/coucha/r
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "coucharight"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/couchablack
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "couchablackaleft"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/couchablack/r
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "couchablackaright"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/couchamagenta
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "couchamagentaleft"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/couchamagenta/r
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "couchamagentaright"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/ultimacouch
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "ultimacouchleft"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/ultimacouch/r
	name = "bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "ultimacouchright"
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/frankenstein
	name = "Fulmenor chair"
	desc = "A nightmarish contraption of pipes, and sparking electrodes. It seems permanently fixed to the ground. Affectionately known as the ZRONK device."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/struc48x48.dmi'
	icon_state = "frankenchair0"
	density = FALSE
	pixel_x = -8
	item_chair = null
	max_integrity = 10000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/frankenstein/zizo
	name = "Fulmenor chair"
	desc = "A nightmarish contraption of pipes, and sparking electrodes. It seems permanently fixed to the ground. Affectionately known as the ZRONK device."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/struc48x48.dmi'
	icon_state = "frankenchair0"
	density = FALSE
	pixel_x = -8
	item_chair = null
	max_integrity = 10000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/freedomchair
	name = "LIBERTAS"
	desc = "A chair-shaped machine normally used to place cursed collars onto a prisoner's neck. This one's been tampered with, and now does the opposite - re-purposed to remove those wretched iron collars."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/machines.dmi'
	icon_state = "evilchair"
	color = "#F75D59"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bash"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/hotspring_bench
	name = "park bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures/hotspring.dmi'
	icon_state = "parkbench_sofamiddle"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/hotspring_bench/left
	name = "park bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures/hotspring.dmi'
	icon_state = "parkbench_sofaend_left"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/hotspring_bench/right
	name = "park bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures/hotspring.dmi'
	icon_state = "parkbench_sofaend_right"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/office
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/chairs.dmi'
	icon_state = "officechair_dark"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/smallbench
	name = "small bench"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "benchsmall"
	density = FALSE
	item_chair = null
	sleepy = 0.5
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/stool/rogue
	name = "stool"
	desc = "Three stubby legs nailed to the underside of a small round seat. Stable, if simple."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "barstool"
	item_chair = /obj/item/chair/stool/bar/rogue
	max_integrity = 100
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair1"
	item_chair = null
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair2"
	item_chair = /obj/item/chair/rogue
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue/chair3
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair3"
	item_chair = /obj/item/chair/rogue
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue/chair4
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair4"
	item_chair = /obj/item/chair/rogue
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue/chair5
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair5"
	item_chair = /obj/item/chair/rogue
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue/fancy
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair1"
	item_chair = /obj/item/chair/rogue/fancy
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue/throne
	name = "chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "thronechair"
	item_chair = null
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/rogue/throne/zybantine
	name = "zybantine throne"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_deserttown/icons/throne.dmi'
	icon_state = "zybantinethrone"
	pixel_x = -16
	item_chair = null
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = null
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/wood/zybantine
	name = "zybantine chair"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_deserttown/icons/chairs.dmi'
	icon_state = "zybantinechair"
	item_chair = null
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/zybantine_sofa/left
	name = "zybantine sofa"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_deserttown/icons/chairs.dmi'
	icon_state = "zybantinesofa_left"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/chair/wood/rockhill/zybantine_sofa/right
	name = "zybantine sofa"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_deserttown/icons/chairs.dmi'
	icon_state = "zybantinesofa_right"
	item_chair = null
	max_integrity = 250
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/burial_shroud
	name = "winding sheet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/bodybag.dmi'
	icon_state = "shroud"
	density = FALSE
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	close_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest
	name = "chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest3s"
	density = TRUE
	base_icon_state = "chest3s"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/crafted
	name = "chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest3s"
	density = TRUE
	base_icon_state = "chest3s"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/crate
	name = "crate"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "woodchest"
	density = TRUE
	base_icon_state = "woodchest"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/gold
	name = "chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest3"
	density = TRUE
	base_icon_state = "chest3"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/inqcrate
	name = "otavan chest"
	desc = "A foreboding red chest with black dye-washed silver embellishments."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chestweird2"
	density = TRUE
	base_icon_state = "chestweird2"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/inqreliquary
	name = "otavan reliquary"
	desc = "A foreboding red chest with a intricate lock design. It seems to only fit a very specific key. Choose wisely."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chestweird1"
	density = TRUE
	base_icon_state = "chestweird1"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/loot_chest
	name = "chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest3s"
	density = TRUE
	base_icon_state = "chest3s"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/lootbox
	name = "chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest3s"
	density = TRUE
	base_icon_state = "chest3s"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER
	rockhill_loot = list(
		/obj/item/cooking/pan = 33,
		/obj/item/bomb = 6,
		/obj/item/rogueweapon/huntingknife/idagger = 33,
		/obj/item/clothing/suit/roguetown/armor/gambeson = 33,
		/obj/item/clothing/suit/roguetown/armor/leather = 33,
		/obj/item/roguestatue/gold/loot = 1,
		/obj/item/ingot/iron = 22,
		/obj/item/rogueweapon/huntingknife/cleaver = 22,
		/obj/item/rogueweapon/mace = 22,
		/obj/item/clothing/cloak/raincloak/mortus = 22,
		/obj/item/reagent_containers/food/snacks/butter = 22,
		/obj/item/clothing/mask/cigarette/pipe = 10,
		/obj/item/clothing/mask/cigarette/pipe/westman = 10,
		/obj/item/storage/backpack/rogue/satchel = 33,
		/obj/item/storage/roguebag = 33,
		/obj/item/roguegem/ruby = 1,
		/obj/item/roguegem/blue = 2,
		/obj/item/roguegem/violet = 4,
		/obj/item/roguegem/green = 6,
		/obj/item/roguegem/yellow = 10,
		/obj/item/roguecoin/silver/pile = 4,
		/obj/item/rogueweapon/pick = 23,
		/obj/item/riddleofsteel = 2,
		/obj/item/clothing/neck/roguetown/talkstone = 2,
		)
	rockhill_loot_chance = 70

/obj/structure/closet/crate/wooden/rockhill/crate/chest/neu
	name = "sturdy oak chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest_neu"
	density = TRUE
	base_icon_state = "chest_neu"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/neu_fancy
	name = "fancy chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chestfancy_neu"
	density = TRUE
	base_icon_state = "chestfancy_neu"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/neu_iron
	name = "reinforced chest"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chestiron_neu"
	density = TRUE
	base_icon_state = "chestiron_neu"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/old_crate
	name = "old crate"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "woodchestalt"
	density = TRUE
	base_icon_state = "woodchestalt"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/chest/old_crate/apothseed
	name = "apothecary's herb seed crate"
	desc = "A wooden crate used to store basic herbs."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "woodchestalt"
	density = TRUE
	base_icon_state = "woodchestalt"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER
	rockhill_contents = list(/obj/item/herbseed/matricaria, /obj/item/herbseed/symphitum, /obj/item/herbseed/taraxacum, /obj/item/herbseed/atropa, /obj/item/herbseed/euphrasia, /obj/item/herbseed/paris, /obj/item/herbseed/calendula, /obj/item/herbseed/mentha, /obj/item/herbseed/urtica, /obj/item/herbseed/salvia, /obj/item/herbseed/hypericum, /obj/item/herbseed/benedictus, /obj/item/herbseed/valeriana, /obj/item/herbseed/artemisia, /obj/item/herbseed/rosa, /obj/item/seeds/swampweed, /obj/item/seeds/pipeweed)

/obj/structure/closet/crate/wooden/rockhill/crate/chest/wicker
	name = "wicker basket"
	desc = "Fibers interwoven to make a cheap storage bin."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "wicker"
	density = TRUE
	base_icon_state = "wicker"
	keylock = TRUE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/items/book_close.ogg'
	close_sound = 'modular_redtard/rockhill/sound/items/book_close.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/coffin
	name = "casket"
	desc = "Death basket."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "casket"
	density = TRUE
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	close_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/coffin/royal
	name = "gilded casket"
	desc = "A coffin made of fine wood and gilded metals."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "rcasket"
	density = TRUE
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	close_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/coffin/vampire
	name = "sleep casket"
	desc = "A fancy coffin."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "vcasket"
	density = TRUE
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	close_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer5"
	density = TRUE
	base_icon_state = "drawer5"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer/drawer1
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer1"
	density = TRUE
	base_icon_state = "drawer1"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer/drawer2
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer2"
	density = TRUE
	base_icon_state = "drawer2"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer/drawer3
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer3"
	density = TRUE
	base_icon_state = "drawer3"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer/drawer4
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer4"
	density = TRUE
	base_icon_state = "drawer4"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer/inn
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer5"
	density = TRUE
	pixel_y = 16
	dir = SOUTH
	base_icon_state = "drawer5"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/drawer/random
	name = "drawer"
	desc = "A wooden drawer."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "drawer1"
	density = TRUE
	pixel_y = 8
	base_icon_state = "drawer1"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/chestopen.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/chestclose.ogg'
	max_integrity = 50
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/miningcar
	name = "mine cart"
	desc = "A cart for use on rails. Or off rails, if you're so inclined."
	icon = 'modular_redtard/rockhill/icons/obj/track.dmi'
	icon_state = "minecart"
	density = TRUE
	base_icon_state = "minecart"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	close_sound = 'modular_redtard/rockhill/sound/blank.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "closet"
	density = TRUE
	base_icon_state = "closet"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset/crafted
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "closet"
	density = TRUE
	base_icon_state = "closet"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset/dark
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "closetdark"
	density = TRUE
	base_icon_state = "closetdark"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset/inn
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "closet3"
	density = TRUE
	base_icon_state = "closet3"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset/inn/chest
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "woodchest"
	density = TRUE
	base_icon_state = "woodchest"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset/inn/south
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "closet3"
	density = TRUE
	pixel_y = 16
	dir = SOUTH
	base_icon_state = "closet3"
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/crate/roguecloset/lord
	name = "closet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "closetlord"
	density = TRUE
	base_icon_state = "closetlord"
	keylock = TRUE
	locked = TRUE
	lockid = "lord"
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/foley/doors/creak.ogg'
	close_sound = 'modular_redtard/rockhill/sound/foley/latch.ogg'
	max_integrity = 200
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = BELOW_OBJ_LAYER

/obj/structure/closet/crate/wooden/rockhill/dirthole
	name = "hole"
	desc = "Just a small hole..."
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "hole1"
	density = FALSE
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/cupboard_open.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/cupboard_close.ogg'
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.8

/obj/structure/closet/crate/wooden/rockhill/dirthole/closed
	name = "hole"
	desc = "A mound of dirt with something below."
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "gravecovered"
	density = FALSE
	keylock = FALSE
	locked = TRUE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/cupboard_open.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/cupboard_close.ogg'
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.8

/obj/structure/closet/crate/wooden/rockhill/dirthole/closed/loot
	name = "hole"
	desc = "A mound of dirt with something below."
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "gravecovered"
	density = FALSE
	keylock = FALSE
	locked = TRUE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/cupboard_open.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/cupboard_close.ogg'
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.8

/obj/structure/closet/crate/wooden/rockhill/dirthole/grave
	name = "hole"
	desc = "A hole big enough for a coffin."
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "grave"
	density = FALSE
	keylock = FALSE
	locked = FALSE
	lockid = null
	lock_strength = 100
	open_sound = 'modular_redtard/rockhill/sound/misc/cupboard_open.ogg'
	close_sound = 'modular_redtard/rockhill/sound/misc/cupboard_close.ogg'
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.8

/obj/structure/rack/rockhill/rogue
	name = "rack"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "rack"
	density = TRUE
	max_integrity = 40
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = TABLE_LAYER

/obj/structure/rack/rockhill/rogue/shelf
	name = "rack"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shelf"
	density = FALSE
	pixel_y = 32
	dir = SOUTH
	max_integrity = 40
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = TABLE_LAYER

/obj/structure/rack/rockhill/rogue/shelf/big
	name = "rack"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shelf_big"
	density = FALSE
	pixel_y = 16
	dir = SOUTH
	max_integrity = 40
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = TABLE_LAYER

/obj/structure/rack/rockhill/rogue/shelf/biggest
	name = "rack"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shelf_biggest"
	density = FALSE
	pixel_y = 0
	dir = SOUTH
	max_integrity = 40
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = TABLE_LAYER

/obj/structure/rack/rockhill/rogue/shelf/notdense
	name = "rack"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shelf"
	density = FALSE
	pixel_y = 24
	dir = SOUTH
	max_integrity = 40
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/church
	name = "stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "churchtable"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stone = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/church/alt
	name = "stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "churchtable_alt"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stone = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/church/end
	name = "stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "churchtable_end"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stone = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/church/end/alt
	name = "stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "churchtable_end_alt"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stone = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/church/m
	name = "stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "churchtable_mid"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stone = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/church/m/alt
	name = "stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "churchtable_mid_alt"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stone = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/cooling
	name = "Cooling Table"
	desc = "Used to keep your food cool and rot free"
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood_alt"
	density = TRUE
	max_integrity = 40
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 0, /obj/item/roguegear = 0)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/finer
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablefine2"
	density = TRUE
	max_integrity = 100
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/finestone
	name = "fine stone table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "stonetable_small"
	density = TRUE
	max_integrity = 400
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stoneblock = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/optable
	name = "operating table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/surgery.dmi'
	icon_state = "optable"
	density = TRUE
	max_integrity = 100
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/templestoneslab/slab2
	name = "stone slab"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/modular_deserttown/icons/temple_objects.dmi'
	icon_state = "slab_2"
	density = TRUE
	max_integrity = 400
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/natural/stoneblock = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/vtable
	name = "ancient wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "vtable"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/vtable/v2
	name = "ancient wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "vtable2"
	density = TRUE
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/crafted
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	icon_state = "tablewood1"
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/fancy
	name = "fancy table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures.dmi'
	icon_state = "fancy_table"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/fancy/black
	name = "fancy table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures.dmi'
	icon_state = "fancy_table_black"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/fancy/blue
	name = "fancy table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures.dmi'
	icon_state = "fancy_table_blue"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/fancy/purple
	name = "fancy table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures.dmi'
	icon_state = "fancy_table_purple"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/fancy/red
	name = "fancy table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures.dmi'
	icon_state = "fancy_table_red"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/fancy/royalblack
	name = "fancy table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/obj/structures.dmi'
	icon_state = "fancy_table_royalblack"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/folding
	name = "folding table"
	desc = "A folding table, useful for setting up a temporary workspace."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/gadgets.dmi'
	icon_state = "foldingtableDeployed"
	density = TRUE
	max_integrity = 50
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/middle_east
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 4
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/middle_west
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 8
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/north
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 1
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/north_east
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 5
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/north_west
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 9
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/south_east
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 6
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/large_table/south_west
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "largetable"
	density = TRUE
	dir = 10
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/long_table
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "longtable"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/long_table/east
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "longtable"
	density = TRUE
	dir = 8
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/long_table/mid
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "longtable_mid"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/long_table/mid/alt
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "longtable_mid"
	density = TRUE
	dir = 1
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/long_table/north_east
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "longtable"
	density = TRUE
	dir = 4
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/long_table/right
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "longtable"
	density = TRUE
	dir = 1
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/map
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "map1"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/map/five
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "map5"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/map/four
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "map4"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/map/six
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "map6"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/map/three
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "map3"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/map/two
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "map2"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/poker
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/poor
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood1"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/poor/alt
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood2"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/table/wood/rockhill/wood/poor/alt_alt
	name = "wooden table"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood3"
	density = TRUE
	max_integrity = 70
	resistance_flags = FLAMMABLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/woodimpact (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/combat/hits/onwood/destroyfurniture.ogg')
	rockhill_debris = list(/obj/item/grown/log/tree/small = 1)
	layer = TABLE_LAYER

/obj/structure/rockhill/toilet
	name = "toilet"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "toilet"
	max_integrity = 300
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
