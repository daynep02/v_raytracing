import math
import gfx

struct Solid_Color {
	albedo Color
}

struct Checker_Texture {
	inv_scale f64
	even Texture
	odd Texture
}

struct Image_Texture {
	image gfx.Image
}

struct Noise_Texture {
	noise Perlin
}

type Texture = Solid_Color | Checker_Texture | Image_Texture | Noise_Texture

fn (t Texture) value(u f64, v f64, p Point3) Color{
	return match t {

		Solid_Color{ t.value(u, v, p) }
		Checker_Texture { t.value(u, v, p) }
		Image_Texture {t.value(u, v, p)}
		Noise_Texture {t.value(u, v, p)}
	}
}

fn Solid_Color.new(albedo Color) Solid_Color {
	return Solid_Color {
		albedo: albedo
	}
}

fn Solid_Color.new_rgb(red f64, green f64, blue f64) Solid_Color {
	return Solid_Color {
		albedo: Color.new(red, green, blue)
	}
}

fn (c Solid_Color) value(u f64, v f64, p Point3) Color {
	return c.albedo
}

fn Checker_Texture.new(scale f64, even Texture, odd Texture) Checker_Texture{
	return Checker_Texture {
		inv_scale: scale
		even: even
		odd: odd
	}
}

fn Checker_Texture.new_colors(scale f64, c1 Color, c2 Color) Checker_Texture{
	return Checker_Texture.new(scale, Solid_Color.new(c1), Solid_Color.new(c2))
}

fn (c Checker_Texture) value(u f64, v f64, p Point3) Color {
	x_integer := int(math.floor(c.inv_scale * p.x()))
	y_integer := int(math.floor(c.inv_scale * p.y()))
	z_integer := int(math.floor(c.inv_scale * p.z()))

	is_even := (x_integer + y_integer + z_integer) % 2 == 0

	return if is_even {c.even.value(u, v, p)} else {c.odd.value(u, v, p)}
}

fn Image_Texture.new(filename string) Image_Texture {
	return Image_Texture {
		image: gfx.Image.load_jpg(filename)
	} 
}

fn (t Image_Texture) value(u f64, v f64, p Point3) Color{
	if t.image.height() <= 0 { return Color.new(0, 1, 1)}

	u1 := Interval.new(0, 1).clamp(u)
	v1 := 1.0 - Interval.new(0,1).clamp(v)

	i := int(u1 * f64(t.image.width()))
	j := int(v1 * f64(t.image.height()))

	pixel := t.image.get_xy(i, j)
	return Color.new(pixel.r, pixel.g, pixel.b)

}

fn Noise_Texture.new() Noise_Texture{
	return Noise_Texture {
		noise: Perlin.new()
	}
}

fn (n Noise_Texture) value(u f64, v f64, p Point3) Color {
	return Color.new(1, 1, 1).scale(n.noise.noise(p))
}