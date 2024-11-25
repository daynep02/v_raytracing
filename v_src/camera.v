module main
import gfx
import math

@[noinit]
struct Camera {
mut:

	image_height int
	center Point3
	pixel00_loc Point3
	pixel_delta_u Vec3
	pixel_delta_v Vec3
	pixel_samples_scale f64
pub mut:
	aspect_ratio f64 = 1.0
	image_width int = 100
	samples_per_pixel int = 10
	max_depth int = 10
	vfov f64 = 90.0
}


fn(c Camera) ray_color(r Ray, depth int, world Hittable_List) Color{
	mut rec := Hit_Record{}
	if depth <= 0 {
		return Color.new(0,0,0)
	}

	if world.hit(r, Interval.new(0.001, infinity), mut rec) {
		mut scattered := Ray{}
		mut attenuation := Color{}
		if rec.mat.scatter(r, rec, mut attenuation, mut scattered) {
			return attenuation * c.ray_color(scattered, depth-1, world)
		}
		return Color.new(0,0,0)
	}

	unit_direction := unit_vector(r.direction())
	a := (unit_direction.y() + 1.0) * 0.5
	return Color.new(1.0, 1.0, 1.0).scale(1.0-a) + Color.new(0.5, 0.7, 1.0).scale(a)
	
}

@[params]
pub struct CameraConfig {
	aspect_ratio f64 = 1.0
	image_width int = 100
}

fn Camera.new(c CameraConfig) Camera{
	return Camera{
		aspect_ratio: c.aspect_ratio
		image_width: c.image_width
	}
}

fn (mut c Camera) initialize() {
	mut image_height := int(f64(c.image_width)/c.aspect_ratio)
	c.image_height = if image_height < 1 {1} else {image_height}

	c.center = Point3.new(0,0,0)

	focal_length := 1.0
	theta := degrees_to_radians(c.vfov)
	h := math.tan(theta/2.0)
	viewport_height :=  2.0 * h * focal_length
	viewport_width := viewport_height * (f64(c.image_width)/f64(c.image_height))

	viewport_u := Vec3.new(viewport_width, 0, 0)
	viewport_v := Vec3.new(0, -viewport_height, 0)

	c.pixel_delta_u = viewport_u.scale(1.0/f64(c.image_width))
	c.pixel_delta_v = viewport_v.scale(1.0/f64(c.image_height))

	viewport_upper_left := c.center - Vec3.new(0, 0, focal_length) - viewport_u.scale(0.5) - viewport_v.scale(0.5)
	c.pixel00_loc = viewport_upper_left + (c.pixel_delta_u + c.pixel_delta_v).scale(0.5)
	
	c.pixel_samples_scale = 1.0 / f64(c.samples_per_pixel)

}

fn (mut c Camera) render(world Hittable_List) {
	c.initialize()
	mut image := gfx.Image.new(gfx.Size2i.new(c.image_width, c.image_height))
	for j in 0..c.image_height {
		for i in 0..c.image_width{
			mut pixel_color := Color.new(0,0,0)
			for _ in 0..c.samples_per_pixel {
				r := c.get_ray(i, j)
				pixel_color = pixel_color + c.ray_color(r, c.max_depth, world)
			}
			pixel_color = pixel_color.scale(c.pixel_samples_scale)
			image.set_xy(i, j, gfx.Color.new(linear_to_gamma(pixel_color.x()), linear_to_gamma(pixel_color.y()), linear_to_gamma(pixel_color.z())))
		}
	}
	image.save_png("image.png")
}


fn (c Camera) sample_square() Vec3{
	return Vec3.new(random_double() -0.5, random_double() -0.5, 0.0)
}

fn (c Camera) get_ray(i int, j int) Ray {
	offset := c.sample_square() 

	pixel_sample := c.pixel00_loc + (c.pixel_delta_u.scale((f64(i) + offset.x()))) + (c.pixel_delta_v.scale(f64(j) + offset.y()))

	ray_origin := c.center
	ray_direction := pixel_sample - ray_origin

	return Ray.new(ray_origin, ray_direction)
}