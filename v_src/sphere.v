module main
import math

fn new_sphere(center Point3, params Hittable_Params) Hittable {
	return Hittable{
		shape: Shape.sphere
		center: Ray.new(center, params.center2 - center)
		radius: math.max(0.0, params.radius)
		mat: params.mat
	}
}

fn (s Hittable) hit_sphere(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	current_center := s.center.at(r.time())
	oc := current_center - r.origin()
	a := r.direction().length_squared()
	h := r.direction().dot(oc)
	c := oc.length_squared() - s.radius * s.radius

	discriminant := h * h - a * c

	if discriminant < 0 {return false}

	sqrtd := math.sqrt(discriminant)

	mut root := (h - sqrtd) / a
	if !(ray_t.surrounds(root)) {
		root = (h + sqrtd) / a
		if !(ray_t.surrounds(root)) {
			return false
		}
	}

	rec.t = root
	rec.p = r.at(rec.t)
	outward_normal := (rec.p - current_center).scale(1.0/s.radius)
	rec.set_face_normal(r, outward_normal)
	rec.mat = s.mat
	return true
}