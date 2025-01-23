/proc/get_sfx_doppler(soundin)
	if(istext(soundin))
		switch(soundin)
			if(SFX_BRICK_DROP)
				soundin = pick(
					'modular_doppler/modular_sounds/sound/bricks/brick_drop_1.ogg',
					'modular_doppler/modular_sounds/sound/bricks/brick_drop_2.ogg',
					'modular_doppler/modular_sounds/sound/bricks/brick_drop_3.ogg',
				)
			if(SFX_BRICK_PICKUP)
				soundin = pick(
					'modular_doppler/modular_sounds/sound/bricks/brick_pick_up_1.ogg',
					'modular_doppler/modular_sounds/sound/bricks/brick_pick_up_2.ogg',
				)
			if(SFX_JINGLEBELL)
				soundin = pick(
					'modular_doppler/modular_sounds/sound/items/collarbell1.ogg',
					'modular_doppler/modular_sounds/sound/items/collarbell2.ogg',
					'modular_doppler/modular_sounds/sound/items/collarbell3.ogg',
					'modular_doppler/modular_sounds/sound/items/collarbell4.ogg',
				)
			if(SFX_SKATER)
				soundin = pick(
					'modular_doppler/modular_sounds/sound/items/rollerblade1.ogg',
					'modular_doppler/modular_sounds/sound/items/rollerblade2.ogg',
				)
	return soundin
