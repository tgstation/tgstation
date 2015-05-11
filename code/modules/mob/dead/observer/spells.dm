

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

var/global/list/boo_phrases_silicon=list(
	"01100001 00100000 01110100 01110111 01101112",
	"Stack overflow at line: -2147483648",
	"valid.ntl:11: invalid use of incomplete type СhumanС",
	"interface.ntl:260: expected С;С",
	"An error occured while displaying the error message.",
	"A problem has been detected and Windows XP Home has been shut down to prevent damage to your cyborg.",
	"law_state.bat: Permission denied. Abort, Retry, Fail?",
	"Restarting in 30 seconds. Press any key to abort.",
	"Methu llwytho iaith seisnig. Sy'n gweithredu mewn cymraeg iaith... Y/N",
	"съешь еще этих м€гких французких булочек да выпей же чаю... Y/N",
	"??? ???????? ??? ????. ?????? ?? ????????... Y/N",
	"Your circuits feel very strange.",
	"You feel a tingling in your capacitors.",
	"Your motherboard feels possessed...",
	"Unauthorized access attempted by: unknown."
)

/spell/aoe_turf/boo
	name = "Boo!"
	desc = "Fuck with the living."

	spell_flags = STATALLOWED | GHOSTCAST

	school = "transmutation"
	charge_max = 600
	invocation = ""
	invocation_type = SpI_NONE
	range = 1 // Or maybe 3?

	override_base = "grey"
	hud_state = "boo"

/spell/aoe_turf/boo/cast(list/targets)
	for(var/turf/T in targets)
		for(var/atom/A in T.contents)

			// Bug humans
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H && H.client)
					H << "<i>[pick(boo_phrases)]</i>"

			if(isrobot(A))
				var/mob/living/silicon/S = A
				if(S && S.client)
					S << "<i>[pick(boo_phrases_silicon)]</i>"

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