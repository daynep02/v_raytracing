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
	return Quad {
		q: q
		u: u
		v: v
		d: normal.dot(q)
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
	alpha := q.w.dot(planar_hitpt_vector.cross(q.v))
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

@[inline]
fn box(a Point3, b Point3, mat Material) Hittable_List {
	mut sides := Hittable_List{}

	min := Point3.new(math.min(a.x(), b.x()), math.min(a.y(), b.y()), math.min(a.z(), b.z()))
	max := Point3.new(math.max(a.x(), b.x()), math.max(a.y(), b.y()), math.max(a.z(), b.z()))

	dx := Vec3.new(max.x() - min.x(), 0, 0)
	dy := Vec3.new(0, max.y() - min.y(), 0)
	dz := Vec3.new(0, 0, max.z() - min.z())

	sides.add(Quad.new(Point3.new(min.x(), min.y(), max.z()), dx, dy, mat))
	sides.add(Quad.new(Point3.new(max.x(), min.y(), max.z()), dz.negate(), dy, mat))
	sides.add(Quad.new(Point3.new(max.x(), min.y(), min.z()), dx.negate(), dy, mat))
	sides.add(Quad.new(Point3.new(min.x(), min.y(), min.z()), dz, dy, mat))
	sides.add(Quad.new(Point3.new(min.x(), max.y(), max.z()), dx, dz.negate(), mat))
	sides.add(Quad.new(Point3.new(min.x(), min.y(), min.z()), dx, dz, mat))
	return sides
}

@[inline]
fn minecraft_box(a Point3, b Point3, top_tex Texture, side_tex Texture) Hittable_List {
	mut sides := Hittable_List{}

	top_mat := Lambertian.new(top_tex)
	side_mat := Lambertian.new(side_tex)

	min := Point3.new(math.min(a.x(), b.x()), math.min(a.y(), b.y()), math.min(a.z(), b.z()))
	max := Point3.new(math.max(a.x(), b.x()), math.max(a.y(), b.y()), math.max(a.z(), b.z()))

	dx := Vec3.new(max.x() - min.x(), 0, 0)
	dy := Vec3.new(0, max.y() - min.y(), 0)
	dz := Vec3.new(0, 0, max.z() - min.z())

	sides.add(Quad.new(Point3.new(min.x(), min.y(), max.z()), dx, dy, side_mat)) // front
	sides.add(Quad.new(Point3.new(max.x(), min.y(), max.z()), dz.negate(), dy, side_mat)) // right
	sides.add(Quad.new(Point3.new(max.x(), min.y(), min.z()), dx.negate(), dy, side_mat)) // back
	sides.add(Quad.new(Point3.new(min.x(), min.y(), min.z()), dz, dy, side_mat)) // left
	sides.add(Quad.new(Point3.new(min.x(), max.y(), max.z()), dx, dz.negate(), top_mat)) // top 
	sides.add(Quad.new(Point3.new(min.x(), min.y(), min.z()), dx, dz, side_mat)) // bottom
	return sides
}
