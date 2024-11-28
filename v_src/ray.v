module main

struct Ray {
	orig Point3
	dir Vec3
}

fn Ray.new(origin Point3, direction Vec3) Ray {
	return Ray {
		orig: origin,
		dir: direction
	}
}

fn (r Ray) origin() Point3 {return r.orig}
fn (r Ray) direction() Vec3 {return r.dir}

fn (r Ray) at(t f64) Point3 {return r.orig + r.dir.scale(t)}
