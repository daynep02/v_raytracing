import math
struct Quad {
	q Point3
	u Vec3
	v Vec3
	d f64
	w Vec3
	normal Vec3
	mat Material
	bbox Aabb
}

fn Quad.new(q Point3, u Vec3, v Vec3, mat Material) Quad{
	n := u.cross(v)
	normal := unit_vector(n)
	d := normal.dot(q)
	return Quad {
		q: q
		u: u
		v: v
		d: d
		w: n.scale(1.0 / n.dot(n))
		normal: normal
		mat: mat
		bbox: set_bounding_box(q, u, v)
	}

}

fn (q Quad) bounding_box() Aabb{
	return q.bbox
}

fn set_bounding_box(q Point3, u Vec3, v Vec3) Aabb {
	bbox_diagonal1 := Aabb.new_from_points(q, q + u + v)
	bbox_diagonal2 := Aabb.new_from_points(q + u, q + v)
	return Aabb.new_from_aabb(bbox_diagonal1, bbox_diagonal2)
}

fn (q Quad) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	denom := q.normal.dot(r.direction())
	if math.abs(denom) < 1e-8 {
		return false
	}

	t := (q.d - q.normal.dot(r.origin())) / denom
	if !ray_t.contain(t) { return false }

	intersection := r.at(t)
	planar_hitpt_vector := intersection - q.q
	alpha := q.w.dot(planar_hitpt_vector.cross(q.u))
	beta := q.w.dot(q.u.cross(planar_hitpt_vector))

	if !q.is_interior(alpha, beta, mut rec) {return false}
	rec.t = t
	rec.p = intersection
	rec.mat = q.mat
	rec.set_face_normal(r, q.normal)
	return true
}

fn (q Quad) is_interior(a f64, b f64, mut rec Hit_Record) bool {
	unit_interval := Interval.new(0, 1)

	if !unit_interval.contain(a) || !unit_interval.contain(b) {
		return false
	}

	rec.u = a
	rec.v = b
	return true
}