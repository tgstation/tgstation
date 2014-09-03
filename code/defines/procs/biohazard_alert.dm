var/global/list/outbreak_level_words=list(
	/* 1 */ 'sound/vox_fem/one.ogg',
	/* 2 */ 'sound/vox_fem/two.ogg',
	/* 3 */ 'sound/vox_fem/three.ogg',
	/* 4 */ 'sound/vox_fem/four.ogg',
	/* 5 */ 'sound/vox_fem/five.ogg',
	/* 6 */ 'sound/vox_fem/six.ogg',
	/* 7 */ 'sound/vox_fem/seven.ogg',
)
/proc/biohazard_alert(var/level=0)
	if(!level)
		level = rand(4,7)
	command_alert("Confirmed outbreak of level [level] biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
	var/list/vox_sentence=list(
		'sound/AI/outbreak_before.ogg',
		outbreak_level_words[level],
		'sound/AI/outbreak_after.ogg',
	)
	for(var/word in vox_sentence)
		play_vox_sound(word,STATION_Z,null)

/*
#warning TELL N3X15 TO COMMENT THIS SHIT OUT
/mob/verb/test_biohazard()
	biohazard_alert()
*/