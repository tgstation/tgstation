// Overhauled vore system
#define DM_HOLD "Hold"
#define DM_DIGEST "Digest"
#define DM_HEAL "Heal"
#define DM_NOISY "Noisy"
#define DM_DRAGON "Dragon"
#define DM_ABSORB "Absorb"
#define DM_UNABSORB "Un-absorb"

#define isbelly(A) istype(A, /obj/belly)

#define QDEL_NULL_LIST(x) if(x) { for(var/y in x) { qdel(y) } ; x = null }
#define VORE_STRUGGLE_EMOTE_CHANCE 40

// Stance for hostile mobs to be in while devouring someone.
#define HOSTILE_STANCE_EATING	99

/* // removing sizeplay again
GLOBAL_LIST_INIT(player_sizes_list, list("Macro" = SIZESCALE_HUGE, "Big" = SIZESCALE_BIG, "Normal" = SIZESCALE_NORMAL, "Small" = SIZESCALE_SMALL, "Tiny" = SIZESCALE_TINY))
// Edited to make the new travis check go away


GLOBAL_LIST_INIT(digest_pred, list(
		'sound/vore/pred/digest_01.ogg',
		'sound/vore/pred/digest_02.ogg',
		'sound/vore/pred/digest_03.ogg',
		'sound/vore/pred/digest_04.ogg',
		'sound/vore/pred/digest_05.ogg',
		'sound/vore/pred/digest_06.ogg',
		'sound/vore/pred/digest_07.ogg',
		'sound/vore/pred/digest_08.ogg',
		'sound/vore/pred/digest_09.ogg',
		'sound/vore/pred/digest_10.ogg',
		'sound/vore/pred/digest_11.ogg',
		'sound/vore/pred/digest_12.ogg',
		'sound/vore/pred/digest_13.ogg',
		'sound/vore/pred/digest_14.ogg',
		'sound/vore/pred/digest_15.ogg',
		'sound/vore/pred/digest_16.ogg',
		'sound/vore/pred/digest_17.ogg',
		'sound/vore/pred/digest_18.ogg'))

GLOBAL_LIST_INIT(death_pred, list(
		'sound/vore/pred/death_01.ogg',
		'sound/vore/pred/death_02.ogg',
		'sound/vore/pred/death_03.ogg',
		'sound/vore/pred/death_04.ogg',
		'sound/vore/pred/death_05.ogg',
		'sound/vore/pred/death_06.ogg',
		'sound/vore/pred/death_07.ogg',
		'sound/vore/pred/death_08.ogg',
		'sound/vore/pred/death_09.ogg',
		'sound/vore/pred/death_10.ogg'))
*/

GLOBAL_LIST_INIT(vore_sounds, list(
		"Gulp" = 'sound/vore/pred/swallow_01.ogg',
		"Swallow" = 'sound/vore/pred/swallow_02.ogg',
		"Insertion1" = 'sound/vore/pred/insertion_01.ogg',
		"Insertion2" = 'sound/vore/pred/insertion_02.ogg',
		"Tauric Swallow" = 'sound/vore/pred/taurswallow.ogg',
		"Stomach Move"		= 'sound/vore/pred/stomachmove.ogg',
		"Schlorp" = 'sound/vore/pred/schlorp.ogg',
		"Squish1" = 'sound/vore/pred/squish_01.ogg',
		"Squish2" = 'sound/vore/pred/squish_02.ogg',
		"Squish3" = 'sound/vore/pred/squish_03.ogg',
		"Squish4" = 'sound/vore/pred/squish_04.ogg',
		"Rustle (cloth)" = 'sound/effects/rustle5.ogg',
		"rustle2(cloth)"	= 'sound/effects/rustle2.ogg',
		"rustle3(cloth)"	= 'sound/effects/rustle3.ogg',
		"rustle4(cloth)"	= 'sound/effects/rustle4.ogg',
		"rustle5(cloth)"	= 'sound/effects/rustle5.ogg',
		"None" = null))
/*
GLOBAL_LIST_INIT(pred_struggle_sounds, list(
		"Struggle1" = 'sound/vore/pred/struggle_01.ogg',
		"Struggle2" = 'sound/vore/pred/struggle_02.ogg',
		"Struggle3" = 'sound/vore/pred/struggle_03.ogg',
		"Struggle4" = 'sound/vore/pred/struggle_04.ogg',
		"Struggle5" = 'sound/vore/pred/struggle_05.ogg'))

GLOBAL_LIST_INIT(prey_vore_sounds, list(
		"Gulp" = 'sound/vore/prey/swallow_01.ogg',
		"Swallow" = 'sound/vore/prey/swallow_02.ogg',
		"Insertion1" = 'sound/vore/prey/insertion_01.ogg',
		"Insertion2" = 'sound/vore/prey/insertion_02.ogg',
		"Tauric Swallow" = 'sound/vore/prey/taurswallow.ogg',
		"Schlorp" = 'sound/vore/prey/schlorp.ogg',
		"Squish1" = 'sound/vore/prey/squish_01.ogg',
		"Squish2" = 'sound/vore/prey/squish_02.ogg',
		"Squish3" = 'sound/vore/prey/squish_03.ogg',
		"Squish4" = 'sound/vore/prey/squish_04.ogg'))


GLOBAL_LIST_INIT(prey_struggle_sounds, list(
		"Struggle1" = 'sound/vore/prey/struggle_01.ogg',
		"Struggle2" = 'sound/vore/prey/struggle_02.ogg',
		"Struggle3" = 'sound/vore/prey/struggle_03.ogg',
		"Struggle4" = 'sound/vore/prey/struggle_04.ogg',
		"Struggle5" = 'sound/vore/prey/struggle_05.ogg'))

GLOBAL_LIST_INIT(digest_prey, list(
		"digest1"	= 'sound/vore/prey/digest_01.ogg',
		"digest2"	= 'sound/vore/prey/digest_02.ogg',
		"digest3"	= 'sound/vore/prey/digest_03.ogg',
		"digest4"	= 'sound/vore/prey/digest_04.ogg',
		"digest5"	= 'sound/vore/prey/digest_05.ogg',
		"digest6"	= 'sound/vore/prey/digest_06.ogg',
		"digest7"	= 'sound/vore/prey/digest_07.ogg',
		"digest8"	= 'sound/vore/prey/digest_08.ogg',
		"digest9"	= 'sound/vore/prey/digest_09.ogg',
		"digest10"	= 'sound/vore/prey/digest_10.ogg',
		"digest11"	= 'sound/vore/prey/digest_11.ogg',
		"digest12"	= 'sound/vore/prey/digest_12.ogg',
		"digest13"	= 'sound/vore/prey/digest_13.ogg',
		"digest14"	= 'sound/vore/prey/digest_14.ogg',
		"digest15"	= 'sound/vore/prey/digest_15.ogg',
		"digest16"	= 'sound/vore/prey/digest_16.ogg',
		"digest17"	= 'sound/vore/prey/digest_17.ogg',
		"digest18"	= 'sound/vore/prey/digest_18.ogg'))

GLOBAL_LIST_INIT(death_prey, list(
		"death1"	= 'sound/vore/prey/death_01.ogg',
		"death2"	= 'sound/vore/prey/death_02.ogg',
		"death3"	= 'sound/vore/prey/death_03.ogg',
		"death4"	= 'sound/vore/prey/death_04.ogg',
		"death5"	= 'sound/vore/prey/death_05.ogg',
		"death6"	= 'sound/vore/prey/death_06.ogg',
		"death7"	= 'sound/vore/prey/death_07.ogg',
		"death8"	= 'sound/vore/prey/death_08.ogg',
		"death9"	= 'sound/vore/prey/death_09.ogg',
		"death10"	= 'sound/vore/prey/death_10.ogg'))
 */

GLOBAL_LIST_INIT(release_sounds, list(
		"rustle (cloth)"	= 'sound/effects/rustle1.ogg',
		"rustle2 (cloth)"	= 'sound/effects/rustle2.ogg',
		"rustle3 (cloth)"	= 'sound/effects/rustle3.ogg',
		"rustle4 (cloth)"	= 'sound/effects/rustle4.ogg',
		"rustle5 (cloth)"	= 'sound/effects/rustle5.ogg',
		"Stomach Move"		= 'sound/vore/pred/stomachmove.ogg',
		"Pred Escape"		= 'sound/vore/pred/escape.ogg',
		"Splatter"			= 'sound/effects/splat.ogg',
		"None"				= null))