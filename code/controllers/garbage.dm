
#define GC_COLLECTIONS_PER_TICK 100
var/global/datum/controller/garbage_collector/garbage
var/global/list/uncollectable_vars=list(
	"alpha",
	"bestF",
	"bounds",
	"bound_height",
	"bound_width",
	"ckey",
	"color",
	"contents",
	"gender",
	"key",
	//"loc",
	"locs",
	"luminosity",
	"parent",
	"parent_type",
	"step_size",
	"glide_size",
	"step_x",
	"step_y",
	"step_z",
	"tag",
	"type",
	"vars",
	"verbs",
	"x",
	"y",
	"z",
)
/datum/controller/garbage_collector
	var/list/queue=list()
	var/waiting=0
	var/turf/trashbin=null

	New()
		trashbin=locate(0,0,CENTCOMM_Z)

	proc/AddTrash(var/atom/movable/A)
		if(!A)
			return
		A.loc=trashbin
		queue.Add(A)
		waiting++

	proc/Pop()
		var/atom/movable/A = queue[1]
		if(!A) return
		if(!istype(A,/atom/movable))
			testing("GC given a [A.type].")
			del(A)
			return
		for(var/vname in A.vars)
			if(vname in uncollectable_vars)
				continue
			//testing("Unsetting [vname] in [A.type]!")
			A.vars[vname]=null
		A.loc=null
		queue.Remove(A)

	proc/process()
		for(var/i=0;i<min(waiting,GC_COLLECTIONS_PER_TICK);i++)
			if(waiting)
				Pop()
				waiting--

/**
* NEVER USE THIS FOR ANYTHING OTHER THAN /atom/movable
* OTHER TYPES CANNOT BE QDEL'D BECAUSE THEIR LOC IS LOCKED OR THEY DON'T HAVE ONE.
*/
/proc/qdel(var/atom/movable/A)
	if(!A) return
	if(!istype(A))
		warning("qdel passed a [A.type]. qdel() can only handle /atom/movable types.")
		del(A)
		return
	garbage.AddTrash(A)