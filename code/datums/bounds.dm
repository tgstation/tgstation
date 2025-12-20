/// An 2D/3D Axis-Aligned Bounding Box (or AABB) that is defined by a minimum vector and a maximum vector.
/// The dimensions of the bounds are defined by the dimensions of the minimum and maximum vectors.
/datum/bounds
	var/vector/min
	var/vector/max

/// Creates a new set of bounds with the given min and max vectors.
/datum/bounds/New(vector/min, vector/max)
	src.min = min
	src.max = max

/// Returns a deep copy of these bounds.
/datum/bounds/proc/get_copy()
	return new /datum/bounds(vector(min), vector(max))

/// Returns a 2D deep copy of these bounds.
/datum/bounds/proc/get_copy_2D()
	return new /datum/bounds(vector(min.x, min.y), vector(max.x, max.y))

/// Returns a 3D deep copy of these bounds.
/datum/bounds/proc/get_copy_3D()
	return new /datum/bounds(vector(min.x, min.y, min.z), vector(max.x, max.y, max.z))

/// Makes these bounds a deep copy of the given bounds.
/datum/bounds/proc/set_copy(datum/bounds/other)
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	min.x = other_min.x
	min.y = other_min.y

	if (min.len > 2 || other_min.len > 2)
		min.z = other_min.z

	max.x = other_max.x
	max.y = other_max.y

	if (max.len > 2 || other_max.len > 2)
		max.z = other_max.z

/// Makes these bounds a 2D deep copy of the given bounds.
/datum/bounds/proc/set_copy_2D(datum/bounds/other)
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	min.x = other_min.x
	min.y = other_min.y

	max.x = other_max.x
	max.y = other_max.y

/// Makes these bounds a 3D deep copy of the given bounds.
/datum/bounds/proc/set_copy_3D(datum/bounds/other)
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	min.x = other_min.x
	min.y = other_min.y
	min.z = other_min.z

	max.x = other_max.x
	max.y = other_max.y
	max.z = other_max.z

/// Returns the center of the bounds.
/datum/bounds/proc/get_center()
	RETURN_TYPE(/vector)
	return (min + max) / 2

/// Sets the center of the bounds.
/datum/bounds/proc/set_center(vector/center)
	var/vector/extents = (max - min) / 2
	min = center - extents
	max = center + extents

/// Returns the size of the bounds.
/datum/bounds/proc/get_size()
	RETURN_TYPE(/vector)
	return max - min

/// Sets the size of the bounds.
/datum/bounds/proc/set_size(vector/size)
	var/vector/center = (min + max) / 2
	min = center - size / 2
	max = center + size / 2

/// Gets the extents/ranges/half-size of the bounds.
/datum/bounds/proc/get_extents()
	RETURN_TYPE(/vector)
	return (max - min) / 2

/// Sets the extents/ranges/half-size of the bounds.
/datum/bounds/proc/set_extents(vector/extents)
	var/vector/center = (min + max) / 2
	min = center - extents
	max = center + extents

/// Sets the min of these bounds to (0, 0, 0) while preserving their size.
/datum/bounds/proc/localize()
	max = max - min
	min -= min // preserves 2D/3D

/datum/bounds/proc/get_localized()
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(min - min, max - min) // preserves 2D/3D

/// Sets these bounds to the largest bounds within both these bounds and the given bounds. Can't go negative.
/datum/bounds/proc/intersect_clamped(datum/bounds/other)
	min = max(min, other.min, vector(0, 0))
	max = min(max, other.max, vector(0, 0))

/// Sets these bounds to the largest bounds within both these bounds and the given bounds. Can go negative.
/datum/bounds/proc/intersect_unclamped(datum/bounds/other)
	min = max(min, other.min)
	max = min(max, other.max)

/// Returns the largest bounds within both these bounds and the given bounds. Can't go negative.
/datum/bounds/proc/get_intersection_clamped(datum/bounds/other)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(max(min, other.min, vector(0, 0)), min(max, other.max, vector(0, 0)))

/// Returns the largest bounds within both these bounds and the given bounds. Can go negative.
/datum/bounds/proc/get_intersection_unclamped(datum/bounds/other)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(max(min, other.min), min(max, other.max))

/// Sets these bounds to the smallest bounds that contain both these bounds and the given bounds.
/datum/bounds/proc/unite(datum/bounds/other)
	min = min(min, other.min)
	max = max(max, other.max)

/// Returns the smallest bounds that contain both these bounds and the given bounds.
/datum/bounds/proc/get_union(datum/bounds/other)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(min(min, other.min), max(max, other.max))

/// Offsets these bounds by the given vector.
/datum/bounds/proc/offset(vector/offset)
	min += offset
	max += offset

/// Returns a copy of these bounds offset by the given vector.
/datum/bounds/proc/get_offset(vector/offset)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(min + offset, max + offset)

/// Offsets these bounds by the negative of the given vector.
/datum/bounds/proc/negative_offset(vector/offset)
	min -= offset
	max -= offset

/// Returns a copy of these bounds offset by the negative of the given vector.
/datum/bounds/proc/get_negative_offset(vector/offset)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(min - offset, max - offset)

/// Divides the min and max of these bounds by the given vector.
/datum/bounds/proc/divide(vector/divisor)
	min /= divisor
	max /= divisor

/// Returns a copy of these bounds with min and max divided by the given vector.
/datum/bounds/proc/get_divided(vector/divisor)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(min / divisor, max / divisor)

/// Multiplies the min and max of these bounds by the given vector.
/datum/bounds/proc/multiply(vector/multiplier)
	min *= multiplier
	max *= multiplier

/// Returns a copy of these bounds with min and max multiplied by the given vector.
/datum/bounds/proc/get_multiplied(vector/multiplier)
	RETURN_TYPE(/datum/bounds)
	return new /datum/bounds(min * multiplier, max * multiplier)

/// Returns whether these bounds contain the given point. (min inclusive, max exclusive)
/datum/bounds/proc/contains(vector/point)
	var/point_x = point.x
	var/point_y = point.y
	var/point_z = point.z

	return point_x >= min.x && point_y >= min.y && point_z >= min.z && \
		point_x < max.x && point_y < max.y && point_z < max.z

/// Returns whether these bounds are equal to the given bounds.
/datum/bounds/proc/equals(datum/bounds/other)
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	return min.x == other_min.x && min.y == other_min.y && min.z == other_min.z && \
		max.x == other_max.x && max.y == other_max.y && max.z == other_max.z

/// Returns whether these bounds overlap with the given bounds. (half-open)
/datum/bounds/proc/overlaps(datum/bounds/other)
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	return min.x < other_max.x && min.y < other_max.y && min.z < other_max.z && \
		max.x > other_min.x && max.y > other_min.y && max.z > other_min.z
