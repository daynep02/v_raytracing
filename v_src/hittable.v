module main
struct Hit_Record {
mut:
	p Point3
	normal Vec3
	t f64
	front_face bool
	mat Material
}

enum Shape {
	sphere
	e
}

struct Hittable {
	shape Shape = Shape.e
	center Point3 = Point3{} 
	radius f64 = 0.0
	mat Material = Material{}
}


fn (h Hittable) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	match h.shape {
		.sphere {
			return h.hit_sphere(r, ray_t, mut rec)
		}
		else {return false}
	}
}

fn (mut h Hit_Record) set_face_normal(r Ray, outward_normal Vec3) {
	h.front_face = r.direction().dot(outward_normal) < 0
	h.normal = if h.front_face {outward_normal} else {outward_normal.negate()}
}
