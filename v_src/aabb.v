struct Aabb {
	pub mut:
	x Interval = Interval{}
	y Interval = Interval{}
	z Interval = Interval{}
}

fn Aabb.new(x Interval, y Interval, z Interval) Aabb{
	return Aabb {
		x: x
		y: y
		z: z
	}
}

fn Aabb.new_from_points(a Point3, b Point3) Aabb{
	return Aabb {
		x: if a.x() <= b.x() {Interval.new(a.x(), b.x())} else {Interval.new(b.x(), a.x())}
		y: if a.y() <= b.y() {Interval.new(a.y(), b.y())} else {Interval.new(b.y(), a.y())}
		z: if a.z() <= b.z() {Interval.new(a.z(), b.z())} else {Interval.new(b.z(), a.z())}
	}
}

fn Aabb.new_from_aabb(box0 Aabb, box1 Aabb) Aabb{
	return Aabb {
		x: Interval.new_from_intervals(box0.x, box1.x)
		y: Interval.new_from_intervals(box0.y, box1.y)
		z: Interval.new_from_intervals(box0.z, box1.z)
	}
}

fn (a Aabb) axis_interval(n int) &Interval {
	if n == 1 {return &a.y}
	else if n == 2 {return &a.z}
	else {return &a.x}
}

fn (a Aabb) hit(r Ray, ray_ta Interval) bool {
	mut ray_t := ray_ta
	ray_orig := r.origin()
	ray_dir := r.direction()

	for axis in 0..3 {
		ax := a.axis_interval(axis)
		adinv := 1.0 / ray_dir.index(axis)

		t0 := (ax.min - ray_orig.index(axis)) * adinv
		t1 := (ax.max - ray_orig.index(axis)) * adinv

		if t0 < t1 {
			if t0 > ray_t.min { ray_t.min = t0}
			if t1 < ray_t.max { ray_t.max = t1}
		} else {
			if t1 > ray_t.min {ray_t.min = t1}
			if t0 < ray_t.max { ray_t.max = t0}
		}

		if ray_t.max <= ray_t.min {
			return false
		}
	}
	return true
}

fn (a Aabb) longest_axis() int {
	if a.x.size() > a.y.size() {
		return if a.x.size() > a.z.size() {0} else {2}
	}
	else {
		return if a.y.size() > a.z.size() {1} else {2}
	}
}

const empty_aabb := Aabb.new(empty_interval, empty_interval, empty_interval)
const universe_aabb :=  Aabb.new(universe_interval, universe_interval, universe_interval)
