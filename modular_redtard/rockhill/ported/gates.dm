/obj/structure/rockhill/gate
	name = "gate"
	desc = "A strong steel gate."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/gate.dmi'
	icon_state = "gate1"
	base_state = "gate"
	density = TRUE
	opacity = TRUE
	max_integrity = 5000
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')

/obj/structure/rockhill/gate/bars
	name = "gate"
	desc = "A strong steel gate."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/gate.dmi'
	icon_state = "bar1"
	base_state = "bar"
	density = TRUE
	opacity = FALSE
	max_integrity = 5000
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')

/obj/structure/rockhill/gate/bars/preopen
	name = "gate"
	desc = "A strong steel gate."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/gate.dmi'
	icon_state = "bar0"
	base_state = "bar"
	density = TRUE
	opacity = FALSE
	max_integrity = 5000
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')

/obj/structure/rockhill/gate/preopen
	name = "gate"
	desc = "A strong steel gate."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/gate.dmi'
	icon_state = "gate0"
	base_state = "gate"
	density = TRUE
	opacity = TRUE
	max_integrity = 5000
	resistance_flags = NONE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (2).ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')

/obj/structure/rockhill/winch
	name = "winch"
	desc = "A gatekeeper's only, and most important responsibility."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "winch"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
