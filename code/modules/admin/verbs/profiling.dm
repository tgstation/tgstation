var/global/PROFILING_VERBS = list(
	/client/proc/disable_scrubbers,
	/client/proc/disable_vents,
)
/*
/client/proc/disable_scrubbers()
	set category = "Debug"
	set name = "Disable all scrubbers"

	disable_scrubbers = !disable_scrubbers
	to_chat(world, "<span class='danger'>Scrubbers are now [disable_scrubbers?"OFF":"ON"].</span>")
*/

#define gen_disable_proc(TYPE,LABEL) \
/client/proc/disable_##TYPE() { \
	set category = "Debug"; \
	set name = "Disable all "+LABEL; \
	disable_##TYPE = !disable_##TYPE; \
	to_chat(world, "<span class='danger'></span>"+LABEL+" are now <b>[disable_##TYPE?"OFF":"ON"]</b>."); \
	}

gen_disable_proc(scrubbers,"Scrubbers")
gen_disable_proc(vents,    "Vents")

#undef gen_disable_proc
