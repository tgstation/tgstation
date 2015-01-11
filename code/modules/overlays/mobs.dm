// Human Overlay objects for the new Overlays system.
/obj/Overlays/fire_layer
	layer = FLOAT_LAYER - 24

/obj/Overlays/mutantrace_layer
	layer = FLOAT_LAYER - 23

/obj/Overlays/mutations_layer
	layer = FLOAT_LAYER - 22

/obj/Overlays/damage_layer
	layer = FLOAT_LAYER - 21

/obj/Overlays/uniform_layer
	layer = FLOAT_LAYER - 20

/obj/Overlays/id_layer
	layer = FLOAT_LAYER - 19

/obj/Overlays/shoes_layer
	layer = FLOAT_LAYER - 18

/obj/Overlays/gloves_layer
	layer = FLOAT_LAYER - 17

/obj/Overlays/ears_layer
	layer = FLOAT_LAYER - 16

/obj/Overlays/suit_layer
	layer = FLOAT_LAYER - 15

/obj/Overlays/glasses_layer
	layer = FLOAT_LAYER - 14

/obj/Overlays/belt_layer
	layer = FLOAT_LAYER - 13

/obj/Overlays/suit_store_layer
	layer = FLOAT_LAYER - 12

/obj/Overlays/back_layer
	layer = FLOAT_LAYER - 11

/obj/Overlays/hair_layer
	layer = FLOAT_LAYER - 10

/obj/Overlays/glasses_over_hair_layer
	layer = FLOAT_LAYER - 9

/obj/Overlays/facemask_layer
	layer = FLOAT_LAYER - 8

/obj/Overlays/head_layer
	layer = FLOAT_LAYER - 7

/obj/Overlays/handcuff_layer
	layer = FLOAT_LAYER - 6

/obj/Overlays/legcuff_layer
	layer = FLOAT_LAYER - 5

/obj/Overlays/l_hand_layer
	layer = FLOAT_LAYER - 4

/obj/Overlays/r_hand_layer
	layer = FLOAT_LAYER - 3

/obj/Overlays/tail_layer
	layer = FLOAT_LAYER - 2

/obj/Overlays/targeted_layer
	layer = FLOAT_LAYER - 1



//Human Overlays Object variables

/mob/living/carbon/human
	var/list/obj/Overlays/obj_overlays[25]
	/*
	var/obj/Overlays/fire_layer/fire_layer = new
	var/obj/Overlays/mutantrace_layer/mutantrace_layer = new
	var/obj/Overlays/mutations_layer/mutations_layer = new
	var/obj/Overlays/damage_layer/damage_layer = new
	var/obj/Overlays/uniform_layer/uniform_layer = new
	var/obj/Overlays/id_layer/id_layer = new
	var/obj/Overlays/shoes_layer/shoes_layer = new
	var/obj/Overlays/gloves_layer/gloves_layer = new
	var/obj/Overlays/ears_layer/ears_layer = new
	var/obj/Overlays/suit_layer/suit_layer = new
	var/obj/Overlays/glasses_layer/glasses_layer = new
	var/obj/Overlays/belt_layer/belt_layer = new
	var/obj/Overlays/suit_store_layer/suit_store_layer = new
	var/obj/Overlays/back_layer/back_layer = new
	var/obj/Overlays/hair_layer/hair_layer = new
	var/obj/Overlays/glasses_over_hair_layer/glasses_over_hair_layer = new
	var/obj/Overlays/facemask_layer/facemask_layer = new
	var/obj/Overlays/head_layer/head_layer = new
	var/obj/Overlays/handcuff_layer/handcuff_layer = new
	var/obj/Overlays/legcuff_layer/legcuff_layer = new
	var/obj/Overlays/l_hand_layer/l_hand_layer = new
	var/obj/Overlays/r_hand_layer/r_hand_layer = new
	var/obj/Overlays/tail_layer/tail_layer = new
	var/obj/Overlays/targeted_layer/targeted_layer = new
	*/