/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return
//Human Overlays Indexes/////////
#define FIRE_LAYER				1		//If you're on fire (/tg/ shit)
#define MUTANTRACE_LAYER		2		//TODO: make part of body?
#define MUTATIONS_LAYER			3
#define DAMAGE_LAYER			4
#define UNIFORM_LAYER			5
#define ID_LAYER				6
#define SHOES_LAYER				7
#define GLOVES_LAYER			8
#define EARS_LAYER				9
#define SUIT_LAYER				10
#define GLASSES_LAYER			11
#define BELT_LAYER				12		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		13
#define BACK_LAYER				14
#define HAIR_LAYER				15		//TODO: make part of head layer?
#define GLASSES_OVER_HAIR_LAYER	16
#define FACEMASK_LAYER			17
#define HEAD_LAYER				18
#define HANDCUFF_LAYER			19
#define LEGCUFF_LAYER			20
#define L_HAND_LAYER			21
#define R_HAND_LAYER			22
#define TAIL_LAYER				23		//bs12 specific. this hack is probably gonna come back to haunt me
#define TARGETED_LAYER			24		//BS12: Layer for the target overlay from weapon targeting system
#define TOTAL_LAYERS			25
//////////////////////////////////
/mob/dead/cultify()
	if(icon_state != "ghost-narsie")
		icon = 'icons/mob/mob.dmi'
		icon_state = "ghost-narsie"
		overlays = 0
		if(mind.current)
			if(istype(mind.current, /mob/living/carbon/human/))	//dressing our ghost with a few items that he was wearing just before dying
				var/mob/living/carbon/human/H = mind.current	//note that ghosts of players that died more than a few seconds before meeting nar-sie won't have any of these overlays
				/*overlays += H.overlays_standing[6]//ID
				overlays += H.overlays_standing[9]//Ears
				overlays += H.overlays_standing[10]//Suit
				overlays += H.overlays_standing[11]//Glasses
				overlays += H.overlays_standing[12]//Belt
				overlays += H.overlays_standing[14]//Back
				overlays += H.overlays_standing[18]//Head
				overlays += H.overlays_standing[19]//Handcuffs
				*/
				overlays += H.obj_overlays[ID_LAYER]
				overlays += H.obj_overlays[EARS_LAYER]
				overlays += H.obj_overlays[SUIT_LAYER]
				overlays += H.obj_overlays[GLASSES_LAYER]
				overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
				overlays += H.obj_overlays[BELT_LAYER]
				overlays += H.obj_overlays[BACK_LAYER]
				overlays += H.obj_overlays[HEAD_LAYER]
				overlays += H.obj_overlays[HANDCUFF_LAYER]
		invisibility = 0
		src << "<span class='sinister'>Even as a non-corporal being, you can feel Nar-Sie's presence altering you. You are now visible to everyone.</span>"

/mob/dead/singuloCanEat()
	return 0


//Human Overlays Indexes/////////
#undef FIRE_LAYER
#undef MUTANTRACE_LAYER
#undef MUTATIONS_LAYER
#undef DAMAGE_LAYER
#undef UNIFORM_LAYER
#undef ID_LAYER
#undef SHOES_LAYER
#undef GLOVES_LAYER
#undef EARS_LAYER
#undef SUIT_LAYER
#undef GLASSES_LAYER
#undef FACEMASK_LAYER
#undef BELT_LAYER
#undef SUIT_STORE_LAYER
#undef BACK_LAYER
#undef HAIR_LAYER
#undef GLASSES_OVER_HAIR_LAYER
#undef HEAD_LAYER
#undef HANDCUFF_LAYER
#undef LEGCUFF_LAYER
#undef L_HAND_LAYER
#undef R_HAND_LAYER
#undef TAIL_LAYER
#undef TARGETED_LAYER
#undef TOTAL_LAYERS