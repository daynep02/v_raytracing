module main
import math

struct Vec3 {
	mut:
	e []f64 = [0.0, 0.0, 0.0]
}

fn Vec3.new(e0 f64, e1 f64, e2 f64) Vec3 {
	return Vec3{ e: [e0, e1, e2]}
}

fn (u Vec3) negate() Vec3 {
	return Vec3.new(-u.e[0], -u.e[1], -u.e[2])
}

fn (u Vec3) - (v Vec3) Vec3 {
	return Vec3.new(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2])
}

fn (v Vec3) x() f64 { return v.e[0]}
fn (v Vec3) y() f64 { return v.e[1]}
fn (v Vec3) z() f64 { return v.e[2]}

fn (v Vec3) at(i int) f64 { return v.e[i] }

fn (v Vec3) index(i int) f64 {
	return v.e[i]
}

fn (v Vec3) length() f64{
	return math.sqrt(v.length_squared())
}

fn (v Vec3) length_squared() f64 {
	return v.e[0] * v.e[0] + v.e[1] * v.e[1] + v.e[2] * v.e[2]
}

fn (v Vec3) near_zero() bool{
	s := 1e-8
	return (math.abs(v.e[0]) < s && math.abs(v.e[1]) < s && math.abs(v.e[2]) < s)
}

@[inline]
fn (u Vec3) + (v Vec3) Vec3 {
	return Vec3.new(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2])
}

@[inline]
fn (u Vec3) * (v Vec3) Vec3 {
	return Vec3.new(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2])
}

@[inline]
fn (u Vec3) / (v Vec3) Vec3 {
	return Vec3.new(u.e[0] / v.e[0], u.e[1] / v.e[1], u.e[2] / v.e[2])
}

type Point3 = Vec3

@[inline]
fn (v Vec3) scale(t f64) Vec3 {
	return Vec3.new(v.e[0] * t, v.e[1] * t, v.e[2] * t)
}

@[inline]
fn (u Vec3) dot(v Vec3) f64{
	return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2]
}

@[inline]
fn (u Vec3) cross(v Vec3) Vec3{
	return Vec3.new(
		u.e[1] * v.e[2] - u.e[2] * v.e[1],
		u.e[2] * v.e[0] - u.e[0] * v.e[2],
		u.e[0] * v.e[1] - u.e[1] * v.e[0]
	)
}

@[inline]
fn unit_vector(v Vec3) Vec3{ return v.scale(1.0 /v.length())}

fn Vec3.random() Vec3{
	return Vec3.new(random_double(), random_double(), random_double())
}

fn Vec3.random_in_range(min f64, max f64) Vec3{ 
	return Vec3.new(random_double_bound(min, max),random_double_bound(min, max),random_double_bound(min, max))
}

@[inline]
fn random_unit_vector() Vec3 {
	for {
		p := Vec3.random_in_range(-1, 1)
		lensq := p.length_squared()
		if 1e-160 < lensq && lensq <= 1 {
			return p.scale(1.0 / math.sqrt(lensq))
		}
	}
	return Vec3{}
}

@[inline]
fn random_on_hemisphere(normal Vec3) Vec3{
	on_unit_sphere := random_unit_vector()
	if on_unit_sphere.dot(normal) > 0.0 {
		return on_unit_sphere
	}
	return on_unit_sphere.negate()
}

@[inline]
fn reflect(v Vec3, n Vec3) Vec3 {
	return v - n.scale(2 * v.dot(n))
}

@[inline]
fn refract(uv Vec3, n Vec3, etai_over_etat f64) Vec3{
	cos_theta := math.min(uv.negate().dot(n), 1.0)
	r_out_perp := (n.scale(cos_theta) + uv).scale(etai_over_etat)
	r_out_parallel := n.scale(-math.sqrt(math.abs(1.0 - r_out_perp.length_squared())))
	return (r_out_perp + r_out_parallel)
}

@[inline]
fn random_in_unit_disk() Vec3 {
	for {
		p:= Vec3.new(random_double_bound(-1, 1), random_double_bound(-1, 1), 0.0)
		if p.length_squared() < 1{
			return p
		}
	}
	return Vec3{}
}
