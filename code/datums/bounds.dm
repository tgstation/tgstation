/*+

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
/datum/bounds/proc/get_copy() as /datum/bounds
	return new /datum/bounds(vector(min), vector(max))

/// Returns a 2D deep copy of these bounds.
/datum/bounds/proc/get_copy_2D() as /datum/bounds
	return new /datum/bounds(vector(min.x, min.y), vector(max.x, max.y))

/// Returns a 3D deep copy of these bounds.
/datum/bounds/proc/get_copy_3D() as /datum/bounds
	return new /datum/bounds(vector(min.x, min.y, min.z), vector(max.x, max.y, max.z))

/// Makes these bounds a deep copy of the given bounds.
/datum/bounds/proc/set_copy(datum/bounds/other) as null
	min = vector(other.min)
	max = vector(other.max)

/// Makes these bounds a 2D deep copy of the given bounds.
/datum/bounds/proc/set_copy_2D(datum/bounds/other) as null
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	min = vector(other_min.x, other_min.y)
	max = vector(other_max.x, other_max.y)

/// Makes these bounds a 3D deep copy of the given bounds.
/datum/bounds/proc/set_copy_3D(datum/bounds/other) as null
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	min = vector(other_min.x, other_min.y, other_min.z)
	max = vector(other_max.x, other_max.y, other_max.z)

/// Returns the center of the bounds.
/datum/bounds/proc/get_center() as /vector
	return (min + max) / 2

/// Sets the center of the bounds.
/datum/bounds/proc/set_center(vector/center) as null
	var/vector/extents = (max - min) / 2
	min = center - extents
	max = center + extents

/// Returns the size of the bounds.
/datum/bounds/proc/get_size() as /vector
	return max - min

/// Sets the size of the bounds.
/datum/bounds/proc/set_size(vector/size) as null
	var/vector/center = (min + max) / 2
	min = center - size / 2
	max = center + size / 2

/// Gets the extents/ranges/half-size of the bounds.
/datum/bounds/proc/get_extents() as /vector
	return (max - min) / 2

/// Sets the extents/ranges/half-size of the bounds.
/datum/bounds/proc/set_extents(vector/extents) as null
	var/vector/center = (min + max) / 2
	min = center - extents
	max = center + extents

/// Sets the min of these bounds to (0, 0, 0) while preserving their size.
/datum/bounds/proc/localize() as null
	max = max - min
	min -= min // preserves 2D/3D

/datum/bounds/proc/get_localized() as /datum/bounds
	return new /datum/bounds(min - min, max - min) // preserves 2D/3D

/// Sets these bounds to the largest bounds within both these bounds and the given bounds. Can't go negative.
/datum/bounds/proc/intersect_clamped(datum/bounds/other) as null
	min = max(min, other.min, vector(0, 0))
	max = min(max, other.max, vector(0, 0))

/// Sets these bounds to the largest bounds within both these bounds and the given bounds. Can go negative.
/datum/bounds/proc/intersect_unclamped(datum/bounds/other) as null
	min = max(min, other.min)
	max = min(max, other.max)

/// Returns the largest bounds within both these bounds and the given bounds. Can't go negative.
/datum/bounds/proc/get_intersection_clamped(datum/bounds/other) as /datum/bounds
	return new /datum/bounds(max(min, other.min, vector(0, 0)), min(max, other.max, vector(0, 0)))

/// Returns the largest bounds within both these bounds and the given bounds. Can go negative.
/datum/bounds/proc/get_intersection_unclamped(datum/bounds/other) as /datum/bounds
	return new /datum/bounds(max(min, other.min), min(max, other.max))

/// Sets these bounds to the smallest bounds that contain both these bounds and the given bounds.
/datum/bounds/proc/unite(datum/bounds/other) as null
	min = min(min, other.min)
	max = max(max, other.max)

/// Returns the smallest bounds that contain both these bounds and the given bounds.
/datum/bounds/proc/get_union(datum/bounds/other) as /datum/bounds
	return new /datum/bounds(min(min, other.min), max(max, other.max))

/// Offsets these bounds by the given vector.
/datum/bounds/proc/offset(vector/offset) as null
	min += offset
	max += offset

/// Returns a copy of these bounds offset by the given vector.
/datum/bounds/proc/get_offset(vector/offset) as /datum/bounds
	return new /datum/bounds(min + offset, max + offset)

/// Offsets these bounds by the negative of the given vector.
/datum/bounds/proc/negative_offset(vector/offset) as null
	min -= offset
	max -= offset

/// Returns a copy of these bounds offset by the negative of the given vector.
/datum/bounds/proc/get_negative_offset(vector/offset) as /datum/bounds
	return new /datum/bounds(min - offset, max - offset)

/// Divides the min and max of these bounds by the given vector.
/datum/bounds/proc/divide(vector/divisor) as null
	min /= divisor
	max /= divisor

/// Returns a copy of these bounds with min and max divided by the given vector.
/datum/bounds/proc/get_divided(vector/divisor) as /datum/bounds
	return new /datum/bounds(min / divisor, max / divisor)

/// Multiplies the min and max of these bounds by the given vector.
/datum/bounds/proc/multiply(vector/multiplier) as null
	min *= multiplier
	max *= multiplier

/// Returns a copy of these bounds with min and max multiplied by the given vector.
/datum/bounds/proc/get_multiplied(vector/multiplier) as /datum/bounds
	return new /datum/bounds(min * multiplier, max * multiplier)

/// Returns whether these bounds contain the given point. (min inclusive, max exclusive)
/datum/bounds/proc/contains(vector/point) as num
	return point.x >= min.x && point.y >= min.y && point.z >= min.z && \
		point.x < max.x && point.y < max.y && point.z < max.z

/// Returns whether these bounds are equal to the given bounds.
/datum/bounds/proc/equals(datum/bounds/other) as num
	return min ~= other.min && max ~= other.max

/// Returns whether these bounds overlap with the given bounds. (half-open)
/datum/bounds/proc/overlaps(datum/bounds/other) as num
	var/vector/other_min = other.min
	var/vector/other_max = other.max

	return min.x < other_max.x && min.y < other_max.y && min.z < other_max.z && \
		max.x > other_min.x && max.y > other_min.y && max.z > other_min.z

*/
