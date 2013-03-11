//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, adjacent turf proc, distance proc)
For the adjacent turf proc i wrote:
/turf/proc/AdjacentTurfs
And for the distance one i wrote:
/turf/proc/Distance
So an example use might be:

src.path_list = AStar(src.loc, target.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance)

Note: The path is returned starting at the END node, so i wrote reverselist to reverse it for ease of use.

src.path_list = reverselist(src.pathlist)

Then to start on the path, all you need to do it:
Step_to(src, src.path_list[1])
src.path_list -= src.path_list[1] or equivilent to remove that node from the list.

Optional extras to add on (in order):
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Minnodedist: Minimum number of nodes to return in the path, could be used to give a path a minimum
length to avoid portals or something i guess?? Not that they're counted right now but w/e.
*/

// Modified to provide ID argument - supplied to 'adjacent' proc, defaults to null
// Used for checking if route exists through a door which can be opened

// Also added 'exclude' turf to avoid travelling over; defaults to null


PriorityQueue
	var/L[]
	var/cmp
	New(compare)
		L = new()
		cmp = compare
	proc
		IsEmpty()
			return !L.len
		Enqueue(d)
			var/i
			var/j
			L.Add(d)
			i = L.len
			j = i>>1
			while(i > 1 &&  call(cmp)(L[j],L[i]) > 0)
				L.Swap(i,j)
				i = j
				j >>= 1

		Dequeue()
			if(!L.len) return 0
			. = L[1]
			Remove(1)

		Remove(i)
			if(i > L.len) return 0
			L.Swap(i,L.len)
			L.Cut(L.len)
			if(i < L.len)
				_Fix(i)
		_Fix(i)
			var/child = i + i
			var/item = L[i]
			while(child <= L.len)
				if(child + 1 <= L.len && call(cmp)(L[child],L[child + 1]) > 0)
					child++
				if(call(cmp)(item,L[child]) > 0)
					L[i] = L[child]
					i = child
				else
					break
				child = i + i
			L[i] = item
		List()
			var/ret[] = new()
			var/copy = L.Copy()
			while(!IsEmpty())
				ret.Add(Dequeue())
			L = copy
			return ret
		RemoveItem(i)
			var/ind = L.Find(i)
			if(ind)
				Remove(ind)
PathNode
	var/datum/source
	var/PathNode/prevNode
	var/f
	var/g
	var/h
	var/nt		// Nodes traversed
	New(s,p,pg,ph,pnt)
		source = s
		prevNode = p
		g = pg
		h = ph
		f = g + h
		source.bestF = f
		nt = pnt

datum
	var/bestF
proc
	PathWeightCompare(PathNode/a, PathNode/b)
		return a.f - b.f

	AStar(start,end,adjacent,dist,maxnodes,maxnodedepth = 30,mintargetdist,minnodedist,id=null, var/turf/exclude=null)

//		world << "A*: [start] [end] [adjacent] [dist] [maxnodes] [maxnodedepth] [mintargetdist], [minnodedist] [id]"
		var/PriorityQueue/open = new /PriorityQueue(/proc/PathWeightCompare)
		var/closed[] = new()
		var/path[]
		start = get_turf(start)
		if(!start) return 0

		open.Enqueue(new /PathNode(start,null,0,call(start,dist)(end)))

		while(!open.IsEmpty() && !path)
		{
			var/PathNode/cur = open.Dequeue()
			closed.Add(cur.source)

			var/closeenough
			if(mintargetdist)
				closeenough = call(cur.source,dist)(end) <= mintargetdist

			if(cur.source == end || closeenough)
				path = new()
				path.Add(cur.source)
				while(cur.prevNode)
					cur = cur.prevNode
					path.Add(cur.source)
				break

			var/L[] = call(cur.source,adjacent)(id)
			if(minnodedist && maxnodedepth)
				if(call(cur.source,minnodedist)(end) + cur.nt >= maxnodedepth)
					continue
			else if(maxnodedepth)
				if(cur.nt >= maxnodedepth)
					continue

			for(var/datum/d in L)
				if(d == exclude)
					continue
				var/ng = cur.g + call(cur.source,dist)(d)
				if(d.bestF)
					if(ng + call(d,dist)(end) < d.bestF)
						for(var/i = 1; i <= open.L.len; i++)
							var/PathNode/n = open.L[i]
							if(n.source == d)
								open.Remove(i)
								break
					else
						continue

				open.Enqueue(new /PathNode(d,cur,ng,call(d,dist)(end),cur.nt+1))
				if(maxnodes && open.L.len > maxnodes)
					open.L.Cut(open.L.len)
		}

		var/PathNode/temp
		while(!open.IsEmpty())
			temp = open.Dequeue()
			temp.source.bestF = 0
		while(closed.len)
			temp = closed[closed.len]
			temp.bestF = 0
			closed.Cut(closed.len)

		if(path)
			for(var/i = 1; i <= path.len/2; i++)
				path.Swap(i,path.len-i+1)

		return path
