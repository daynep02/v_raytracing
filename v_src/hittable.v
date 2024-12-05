module main
struct Hit_Record {
mut:
	p Point3
	normal Vec3
	t f64
	front_face bool
	u f64
	v f64
	mat Material
}


/*
@[noinit]
struct Hittable {
	shape Shape
	center Ray
	radius f64
	mat Material
	bbox Aabb
}
*/
type Hittable = Sphere | Quad | Bvh_node | Hittable_List

@[params]
struct Hittable_Params  {
	mat Material = Lambertian.new_color( Color.new(0.5, 0.5, 0.5))
	radius f64 = 0.5
}

fn (h Hittable) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	return match h{
		Sphere {h.hit(r, ray_t, mut rec) }
		Quad {h.hit(r, ray_t, mut rec)}
		Bvh_node {h.hit(r, ray_t, mut rec)}
		Hittable_List {h.hit(r, ray_t, mut rec)}
	}
}

fn (mut h Hit_Record) set_face_normal(r Ray, outward_normal Vec3) {
	h.front_face = r.direction().dot(outward_normal) < 0
	h.normal = if h.front_face {outward_normal} else {outward_normal.negate()}
}

fn (h Hittable) bounding_box() Aabb {
	return h.bbox
}
