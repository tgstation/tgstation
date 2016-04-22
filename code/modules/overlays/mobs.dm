// Human Overlay objects for the new Overlays system.
/obj/Overlays/fire_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - FIRE_LAYER)

/obj/Overlays/mutantrace_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - MUTANTRACE_LAYER)

/obj/Overlays/mutations_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - MUTATIONS_LAYER)

/obj/Overlays/damage_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - DAMAGE_LAYER)

/obj/Overlays/uniform_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - UNIFORM_LAYER)

/obj/Overlays/shoes_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - SHOES_LAYER)

/obj/Overlays/gloves_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - GLOVES_LAYER)

/obj/Overlays/ears_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - EARS_LAYER)

/obj/Overlays/suit_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - SUIT_LAYER)

/obj/Overlays/glasses_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - GLASSES_LAYER)

/obj/Overlays/belt_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - BELT_LAYER)

/obj/Overlays/suit_store_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - SUIT_STORE_LAYER)

/obj/Overlays/hair_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HAIR_LAYER)

/obj/Overlays/glasses_over_hair_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - GLASSES_OVER_HAIR_LAYER)

/obj/Overlays/facemask_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - FACEMASK_LAYER)

/obj/Overlays/head_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HEAD_LAYER)

/obj/Overlays/back_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - BACK_LAYER)

/obj/Overlays/id_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - ID_LAYER)

/obj/Overlays/handcuff_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - HANDCUFF_LAYER)

/obj/Overlays/legcuff_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - LEGCUFF_LAYER)

/obj/Overlays/l_hand_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - L_HAND_LAYER)

/obj/Overlays/r_hand_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - R_HAND_LAYER)

/obj/Overlays/tail_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - TAIL_LAYER)

/obj/Overlays/targeted_layer
	layer = FLOAT_LAYER - (TOTAL_LAYERS - TARGETED_LAYER)



//Human Overlays Object variables

/mob/living/carbon/human
	var/list/obj/Overlays/obj_overlays[TOTAL_LAYERS]
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