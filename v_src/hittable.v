module main
import math
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
type Hittable = Sphere | Quad | Bvh_node | Hittable_List | Translate | Rotate_y

struct Translate {
	object Hittable
	offset Vec3
	bbox Aabb
}

struct Rotate_y {
	object Hittable
	sin_theta f64
	cos_theta f64
	bbox Aabb
}

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
		Translate {h.hit(r, ray_t, mut rec)}
		Rotate_y {h.hit(r, ray_t, mut rec)}
	}
}

fn (mut h Hit_Record) set_face_normal(r Ray, outward_normal Vec3) {
	h.front_face = r.direction().dot(outward_normal) < 0
	h.normal = if h.front_face {outward_normal} else {outward_normal.negate()}
}

fn (h Hittable) bounding_box() Aabb {
	return h.bbox
}

fn Translate.new(object Hittable, offset Vec3) Translate {
	return Translate {
		object: object
		offset: offset
		bbox: object.bounding_box().add_vec3(offset)
	}
}

fn (t Translate) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	offset_r := Ray.new(r.origin() - t.offset, r.direction(), tm: r.time())

	if !t.object.hit(offset_r, ray_t, mut rec) {
		return false
	}

	rec.p = rec.p + t.offset

	return true
}

fn Rotate_y.new(object Hittable, angle f64) Rotate_y {
	radians := degrees_to_radians(angle)
	sin_theta := math.sin(radians)
	cos_theta := math.cos(radians)

	bbox := object.bounding_box()

	mut min := Point3.new(infinity, infinity, infinity)
	mut max := Point3.new(-infinity, -infinity, -infinity)

	for i in 0..2 {
		for j in 0..2 {
			for k in 0..2 {
				x := i * bbox.x.max + (1-i)*bbox.x.min
				y := j * bbox.y.max + (1-i)*bbox.y.min
				z := k * bbox.z.max + (1-i)*bbox.z.min

				newx := cos_theta * x + sin_theta*z
				newz := -sin_theta*x + cos_theta*z

				tester := Vec3.new(newx, y, newz)

				for c in 0..3 {
					min.e[c] = math.min(min.e[c], tester.e[c])
					max.e[c] = math.max(max.e[c], tester.e[c])
				}
			}
		}
	}

	return Rotate_y {
		object: object
		sin_theta: sin_theta
		cos_theta: cos_theta
		bbox: Aabb.new_from_points(min, max)
	}
}

fn (r Rotate_y) bounding_box() Aabb { return r.bbox }

fn (ro Rotate_y) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	origin := Point3.new((ro.cos_theta * r.origin().x()) - (ro.sin_theta * r.origin().z()), r.origin().y(), (ro.sin_theta * r.origin().x()) + (ro.cos_theta * r.origin().z()))
	direction := Vec3.new((ro.cos_theta * r.direction().x()) - (ro.sin_theta * r.direction().z()), r.direction().y(), (ro.sin_theta * r.direction().x()) + (ro.cos_theta * r.direction().z()))

	rotated_r := Ray.new(origin, direction, tm: r.time())

	if !ro.object.hit(rotated_r, ray_t, mut rec) {return false}

	rec.p = Point3.new((ro.cos_theta * rec.p.x()) - (ro.sin_theta * rec.p.z()), rec.p.y(), (ro.sin_theta * rec.p.x()) + (ro.cos_theta * rec.p.z()))
	rec.normal = Point3.new((ro.cos_theta * rec.normal.x()) - (ro.sin_theta * rec.normal.z()), rec.normal.y(), (ro.sin_theta * rec.normal.x()) + (ro.cos_theta * rec.normal.z()))

	return true
}
