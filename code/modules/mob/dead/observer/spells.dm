

var/global/list/boo_phrases=list(
	"You feel a chill run down your spine.",
	"You think you see a figure in your peripheral vision.",
	"What was that?",
	"The hairs stand up on the back of your neck.",
	"You are filled with a great sadness.",
	"Something doesn't feel right...",
	"You feel a presence in the room.",
	"It feels like someone's standing behind you.",
)

/obj/effect/proc_holder/spell/aoe_turf/boo
	name = "Boo!"
	desc = "Fuck with the living."

	ghost = 1

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = ""
	invocation_type = "none"
	range = 1 // Or maybe 3?

/obj/effect/proc_holder/spell/aoe_turf/boo/cast(list/targets)
	for(var/turf/T in targets)
		for(var/atom/A in T.contents)

			// Bug humans
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H && H.client)
					H << "<i>[pick(boo_phrases)]</i>"

			// Blessed object? Skippit.
			if(isobj(A) && A:blessed)
				continue

			// Flicker unblessed lights in range
			if(istype(A,/obj/machinery/light))
				var/obj/machinery/light/L = A
				if(L)
					L.flicker()

			// OH GOD BLUE APC (single animation cycle)
			if(istype(A, /obj/machinery/power/apc))
				A:spookify()

			if(istype(A, /obj/machinery/status_display))
				A:spookymode=1

			if(istype(A, /obj/machinery/ai_status_display))
				A:spookymode=1