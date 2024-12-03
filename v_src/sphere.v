module main
import math

fn new_sphere(center Point3, params Hittable_Params) Hittable {
	rvec := Vec3.new(params.radius, params.radius, params.radius)
	return Hittable{
		shape: Shape.sphere
		radius: math.max(0.0, params.radius)
		center: Ray.new(center, Vec3.new(0,0,0))
		mat: params.mat
		bbox: Aabb.new_from_points(center - rvec, center + rvec)
	}
}

fn new_moving_sphere(center1 Point3, center2 Point3, params Hittable_Params) Hittable{
	rvec := Vec3.new(params.radius, params.radius, params.radius)
	center := Ray.new(center1, center2 - center1)
	box1 := Aabb.new_from_points(center.at(0) - rvec, center.at(0) + rvec)
	box2 := Aabb.new_from_points(center.at(1) - rvec, center.at(1) + rvec)
	return Hittable{
		shape: Shape.sphere
		radius: math.max(0.0, params.radius)
		center: center
		mat: params.mat
		bbox: Aabb.new_from_aabb(box1, box2)
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
	rec.u, rec.v = get_sphere_uv(outward_normal, rec.u, rec.v)
	rec.mat = s.mat
	return true
}
fn get_sphere_uv(p Point3,u f64, v f64) (f64, f64){
	theta:= math.acos(-p.y())
	phi := math.atan2(-p.z(), p.x()) + math.pi

	return phi / (2*math.pi), theta / math.pi
}