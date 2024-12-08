import math
struct Constant_medium {
	boundary Hittable
	neg_inv_density f64
	phase_function Material
	bbox Aabb
}

fn Constant_medium.new(boundary Hittable, density f64, tex Texture) Constant_medium{
	return Constant_medium {
		boundary: boundary
		neg_inv_density: (-1.0 / density)
		phase_function: Isotropic.new(tex)
		bbox: boundary.bounding_box()
	}
}

fn Constant_medium.new_color(boundary Hittable, density f64, albedo Color) Constant_medium {
	return Constant_medium {
		boundary: boundary
		neg_inv_density: (-1.0 / density)
		phase_function: Isotropic.new_color(albedo)
		bbox: boundary.bounding_box()
	}
}

fn (c Constant_medium) hit(r Ray, ray_t1 Interval, mut rec Hit_Record) bool {
	mut ray_t := ray_t1
	mut rec1 := Hit_Record{}
	mut rec2 := Hit_Record{}
	if !c.boundary.hit(r, universe_interval, mut rec1) { return false }

	if !c.boundary.hit(r, Interval.new(rec1.t + .0001, infinity), mut rec2) {return false}

	if rec1.t < ray_t.min {rec1.t = ray_t.min}
	if rec2.t > ray_t.max {rec2.t = ray_t.max}

	if rec1.t >= rec2.t {return false}
	if rec1.t <0 { rec1.t = 0}

	ray_length := r.direction().length()
	distance_inside_boundary := (rec2.t - rec1.t) * ray_length
	hit_distance := c.neg_inv_density * math.log(random_double())

	if hit_distance > distance_inside_boundary {
		return false
	}

	rec.t = rec1.t + hit_distance / ray_length
	rec.p = r.at(rec.t)
	rec.normal = Vec3.new(1, 0, 0)
	rec.front_face = true
	rec.mat = c.phase_function

	return true
}