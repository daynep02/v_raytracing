module main

struct Ray {
	orig Point3
	dir Vec3
	tm f64
}

@[params]
struct Ray_Params {
	tm f64 = 0.0
}

fn Ray.new(origin Point3, direction Vec3, r Ray_Params) Ray {
	return Ray {
		orig: origin,
		dir: direction
		tm: r.tm
	}
}

fn (r Ray) origin() Point3 {return r.orig}
fn (r Ray) direction() Vec3 {return r.dir}

fn (r Ray) at(t f64) Point3 {return r.orig + r.dir.scale(t)}

fn (r Ray) time() f64 { return r.tm }