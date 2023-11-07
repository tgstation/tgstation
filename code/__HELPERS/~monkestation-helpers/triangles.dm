/// A list that caches base appearances of triangles for later access.
GLOBAL_LIST_EMPTY(triangle_appearances)

/// Returns a mutable appearance of a triangle of the given points, and caches it for later use
/proc/get_triangle_appearance(x1,y1, x2,y2, x3,y3, icon_size = 32, icon = 'monkestation/code/modules/shadowcasting/icons/geometric.dmi', icon_state = "triangle")
	var/key = "[x1]_[y2]_[x2]_[y2]_[x3]_[y3]_[icon_size]_[icon]_[icon_state]"
	if(GLOB.triangle_appearances[key])
		return GLOB.triangle_appearances[key]
	var/mutable_appearance/triangle_appearance = mutable_appearance(icon, icon_state)
	triangle_appearance.transform = transform_triangle(x1,y1, x2,y2, x3,y3, icon_size)
	GLOB.triangle_appearances[key] = triangle_appearance
	return triangle_appearance

/// Returns a matrix which when applied to a proper triangle image, creates an arbitrary triangle
/proc/transform_triangle(x1, y1, x2, y2, x3, y3, icon_size = 32)
	var/i = 1/icon_size
	var/a = (x3*i)-(x2*i)
	var/b = -(x2*i)+(x1*i)
	var/c = (x3*0.5)+(x1*0.5)
	var/d = (y1*i)-(y2*i)
	var/e = -(y2*i)+(y3*i)
	var/f = (y1*0.5)+(y3*0.5)
	return matrix(a,b,c,e,d,f)
