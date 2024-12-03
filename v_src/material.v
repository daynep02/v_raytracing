import math
enum EMaterial {
	metal
	lambertian
	dielectric
}

struct Material {
	material EMaterial 
	albedo 	 Color
	fuzz f64
	refraction_index f64
	tex Texture
}

@[params]
struct Material_Params {
	mat EMaterial = EMaterial.lambertian
	albedo Color = Color.new(1.0, 1.0, 1.0)
	fuzz f64 = 0.0
	refraction_index f64 = 1.0
	tex ?Texture = none
}


fn Material.new(mp Material_Params) Material {
	return Material {
		material: mp.mat
		albedo: mp.albedo
		fuzz: if mp.fuzz < 1.0 {mp.fuzz} else {1.0} 
		refraction_index: mp.refraction_index 
		tex: if c := mp.tex { c } else { Solid_Color.new(mp.albedo) }
	}
}

fn (m Material) scatter(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool{
	return match m.material {
		.metal {m.scatter_metal(r_in, rec, mut attenuation, mut scattered)}
		.lambertian {m.scatter_lambertian(r_in, rec, mut attenuation, mut scattered)}
		.dielectric {m.scatter_dielectric(r_in, rec, mut attenuation, mut scattered)}
	}
}

fn (l Material) scatter_lambertian(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	mut scatter_direction := rec.normal + random_unit_vector()

	if scatter_direction.near_zero() {
		scatter_direction = rec.normal
	}
	scattered = Ray.new(rec.p, scatter_direction, tm: r_in.time())
	attenuation = l.tex.value(rec.u, rec.v, rec.p)
	return true
}

fn (m Material) scatter_metal(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	mut reflected := reflect(r_in.direction(), rec.normal) 
	reflected = unit_vector(reflected) + random_unit_vector().scale(m.fuzz)
	scattered = Ray.new(rec.p, reflected, tm: r_in.time())
	attenuation = m.albedo
	return (scattered.direction().dot(rec.normal) > 0)
}

fn (m Material) scatter_dielectric(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	attenuation = Color.new(1.0, 1.0, 1.0)
	ri := if rec.front_face {1.0/m.refraction_index} else {m.refraction_index}

	unit_direction := unit_vector(r_in.direction())
	cos_theta := math.min(unit_direction.negate().dot(rec.normal), 1.0)
	sin_theta := math.sqrt(1.0 - cos_theta * cos_theta)


	direction := if (ri * sin_theta) > 1.0 || m.dielectric_reflectence(cos_theta, ri) > random_double() {reflect(unit_direction, rec.normal)} else {refract(unit_direction, rec.normal, ri)}

	scattered = Ray.new(rec.p, direction, tm: r_in.time())
	return true
}

fn (m Material) dielectric_reflectence(cosine f64, refraction_index f64) f64 {
	r0 := math.pow((1.0 - refraction_index) / (1.0 + refraction_index), 2)
	return (r0 + (1-r0)* math.pow((1-cosine), 5))

}