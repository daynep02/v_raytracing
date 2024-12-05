import math
enum EMaterial {
	metal
	lambertian
	dielectric
}

@[params]
struct Material_Params {
	mat EMaterial = EMaterial.lambertian
	albedo Color = Color.new(1.0, 1.0, 1.0)
	fuzz f64 = 0.0
	refraction_index f64 = 1.0
	tex ?Texture = none
}

struct Lambertian {
	tex Texture
}

struct Metal {
	albedo Color
	fuzz f64
}

struct Dielectric {
	refraction_index f64
}

type Material = Lambertian | Metal | Dielectric


fn Lambertian.new(tex Texture) Lambertian{
	return Lambertian { tex: tex }
}

fn Lambertian.new_color(albedo Color) Lambertian {
	return Lambertian.new(Solid_Color.new(albedo))
}


fn Metal.new(albedo Color, fuzz f64) Metal {
	return Metal {
		albedo: albedo
		fuzz: if fuzz < 1.0 {fuzz} else {1.0}
	}
}

fn Dielectric.new(refraction_index f64) Dielectric{
	return Dielectric{refraction_index: refraction_index}
}


fn (m Material) scatter(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool{
	return match m {
		Metal {m.scatter(r_in, rec, mut attenuation, mut scattered)}
		Lambertian {m.scatter(r_in, rec, mut attenuation, mut scattered)}
		Dielectric {m.scatter(r_in, rec, mut attenuation, mut scattered)}
	}
}

fn (l Lambertian) scatter(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	mut scatter_direction := rec.normal + random_unit_vector()

	if scatter_direction.near_zero() {
		scatter_direction = rec.normal
	}
	scattered = Ray.new(rec.p, scatter_direction, tm: r_in.time())
	attenuation = l.tex.value(rec.u, rec.v, rec.p)
	return true
}

fn (m Metal) scatter(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	mut reflected := reflect(r_in.direction(), rec.normal) 
	reflected = unit_vector(reflected) + random_unit_vector().scale(m.fuzz)
	scattered = Ray.new(rec.p, reflected, tm: r_in.time())
	attenuation = m.albedo
	return (scattered.direction().dot(rec.normal) > 0)
}

fn (d Dielectric) scatter(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	attenuation = Color.new(1.0, 1.0, 1.0)
	ri := if rec.front_face {1.0/d.refraction_index} else {d.refraction_index}

	unit_direction := unit_vector(r_in.direction())
	cos_theta := math.min(unit_direction.negate().dot(rec.normal), 1.0)
	sin_theta := math.sqrt(1.0 - cos_theta * cos_theta)


	direction := if (ri * sin_theta) > 1.0 || d.dielectric_reflectence(cos_theta, ri) > random_double() {reflect(unit_direction, rec.normal)} else {refract(unit_direction, rec.normal, ri)}

	scattered = Ray.new(rec.p, direction, tm: r_in.time())
	return true
}

fn (m Dielectric) dielectric_reflectence(cosine f64, refraction_index f64) f64 {
	r0 := math.pow((1.0 - refraction_index) / (1.0 + refraction_index), 2)
	return (r0 + (1-r0)* math.pow((1-cosine), 5))

}