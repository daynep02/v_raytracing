enum EMaterial {
	metal
	lambertian
}

struct Material {
	material EMaterial 
	albedo 	 Color
}

@[params]
struct Material_Params {
	mat EMaterial = EMaterial.lambertian
	albedo Color = Color.new(0.5, 0.5, 0.5)
}


fn Material.new(mp Material_Params) Material {
	return Material {
		material: mp.mat
		albedo: mp.albedo
	}
}

fn (m Material) scatter(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool{
	match m.material {
		.metal {return false}
		.lambertian {m.scatter_lambertian(r_in, rec, mut attenuation, mut scattered)}
	}
	return false
}

fn (l Material) scatter_lambertian(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	mut scatter_direction := rec.normal + random_unit_vector()

	if scatter_direction.near_zero() {
		scatter_direction = rec.normal
	}
	scattered = Ray.new(rec.p, scatter_direction)
	attenuation = l.albedo
	return true
}

fn (m Material) scatter_metal(r_in Ray, rec Hit_Record, mut attenuation Color, mut scattered Ray) bool {
	reflected := reflect(r_in.direction(), rec.normal)

	scattered = Ray.new(rec.p, reflected)
	attenuation = m.albedo
	return true
}