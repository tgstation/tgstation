//Particle effects used in Bloodsucker code

//Brazier particle effect
//Created using '/particles/bonfire' from 'code/game/objects/effects/particles/fire.dm' as a reference
/particles/brazier
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "brazier_particle"
	width = 32
	height = 48
	count = 250
	spawning = 1.5
	lifespan = 1.1 SECONDS
	fade = 1.9 SECONDS
	grow = -0.05
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 6)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.9)
	scale = generator(GEN_VECTOR, list(0.65, 0.65), list(0.9, 0.9), NORMAL_RAND)
	rotation = 36
	spin = generator(GEN_NUM, -36, 36, NORMAL_RAND)
