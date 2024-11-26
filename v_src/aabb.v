@[noinit]
struct AABB {
	x Interval
	y Interval
	z Interval
}


fn AABB.new(x Interval, y Interval, z Interval) AABB {
	return AABB{
		x: x
		y: y
		z: z
	}
}

fn AABB.new_from_points(a Point3, b Point3) AABB {
	return  AABB{
		x: if a.x() <= b.x() {Interval.new(a.x(), b.x())} else {Interval.new(b.x(), a.x())}
		y: if a.y() <= b.y() {Interval.new(a.y(), b.y())} else {Interval.new(b.y(), a.y())}
		z: if a.z() <= b.z() {Interval.new(a.z(), b.z())} else {Interval.new(b.z(), a.z())}
	}
}

fn AABB.new_from_boxes(box0 AABB, box1 AABB) AABB {
	return AABB.new(Interval.new_from_intervals(box0.x, box1.x),Interval.new_from_intervals(box0.y, box1.y), Interval.new_from_intervals(box0.z, box1.z))
}

fn (a AABB) axis_interval(n int) Interval{
	match n {
		1 {return a.y}
		2 {return a.z}
		else {return a.x}
	}
}

fn (a AABB) hit(r Ray, mut ray_t Interval) bool{
	ray_orig := r.origin()
	ray_dir := r.direction()

	for axis in 0..3 {
		ax := a.axis_interval(axis)
		adinv := if axis == 0 {1.0 / ray_dir.x()} else if axis == 1 {1.0 / ray_dir.y()} else {1.0/ray_dir.z()}

		t0 := if axis == 0 {(ax.min - ray_orig.x()) * adinv} else if axis == 1 {(ax.min - ray_orig.y()) * adinv} else {(ax.min - ray_orig.z()) * adinv} 
		t1 := if axis == 0 {(ax.max - ray_orig.x()) * adinv} else if axis == 1 {(ax.max - ray_orig.y()) * adinv} else {(ax.max - ray_orig.z()) * adinv} 

		if t0 < t1 {
			if t0 > ray_t.min {ray_t.min = t0}
			if t1 < ray_t.max {ray_t.max = t1}
		} else {
			if t1 > ray_t.min {ray_t.min = t1}
			if t0 < ray_t.max {ray_t.max = t0}
		}

		if ray_t.max <= ray_t.min {return false}
	}
	return true
}