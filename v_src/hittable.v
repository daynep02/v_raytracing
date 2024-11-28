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
}

@[noinit]
struct Hittable {
	shape Shape
	center Ray
	radius f64
	mat Material
}

@[params]
struct Hittable_Params  {
	shape Shape = Shape.sphere
	center2 Point3 = Vec3.new(0,0,0)
	mat Material = Material.new(
		mat: EMaterial.lambertian
		albedo: Color.new(0.5, 0.5, 0.5)
	)
	radius f64 = 0.5
}


fn Hittable.new(center1 Point3, params Hittable_Params) Hittable{
	return match params.shape{
		.sphere{ new_sphere(center1, params)}	
	}
}

fn (h Hittable) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	match h.shape {
		.sphere {
			return h.hit_sphere(r, ray_t, mut rec)
		}
	}
}

fn (mut h Hit_Record) set_face_normal(r Ray, outward_normal Vec3) {
	h.front_face = r.direction().dot(outward_normal) < 0
	h.normal = if h.front_face {outward_normal} else {outward_normal.negate()}
}
