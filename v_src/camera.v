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
	u Vec3
	v Vec3
	w Vec3

	defocus_disk_u Vec3
	defocus_disk_v Vec3

pub mut:
	aspect_ratio f64 = 1.0
	image_width int = 100
	samples_per_pixel int = 10
	max_depth int = 10
	vfov f64 = 90.0
	lookfrom Point3 = Point3.new(0.0,0.0,0.0)
	lookat Point3 = Point3.new(0.0,0.0,-1.0)
	vup Vec3 = Vec3.new(0.0,1.0,0.0)

	defocus_angle f64 = 0.0
	focus_dist f64 = 10.0
}

struct Image_S{
	mut:
	image gfx.Image
}
const num_threads = 8


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

	c.center = c.lookfrom

	theta := degrees_to_radians(c.vfov)
	h := math.tan(theta/2.0)
	viewport_height :=  2.0 * h * c.focus_dist
	viewport_width := viewport_height * (f64(c.image_width)/f64(c.image_height))

	c.w = unit_vector(c.lookfrom-c.lookat)
	c.u = unit_vector(c.vup.cross(c.w))
	c.v = c.w.cross(c.u)

	viewport_u := c.u.scale(viewport_width)
	viewport_v := c.v.negate().scale(viewport_height)

	c.pixel_delta_u = viewport_u.scale(1.0/f64(c.image_width))
	c.pixel_delta_v = viewport_v.scale(1.0/f64(c.image_height))

	viewport_upper_left := c.center - (c.w.scale(c.focus_dist)) - viewport_u.scale(1.0/2.0) - viewport_v.scale(1.0/2.0)
	c.pixel00_loc = viewport_upper_left + (c.pixel_delta_u + c.pixel_delta_v).scale(0.5)

	defocus_radius := c.focus_dist * math.tan(degrees_to_radians(c.defocus_angle / 2.0))	

	c.defocus_disk_u = c.u.scale(defocus_radius)
	c.defocus_disk_v = c.v.scale(defocus_radius)
	
	c.pixel_samples_scale = 1.0 / f64(c.samples_per_pixel)

}

fn (c Camera) multi_render(shared image Image_S, world Hittable_List, thread_num int) {
	for j in 0..c.image_height  {
		for i in 0..c.image_width{
			if (i + j) % num_threads != thread_num {
				continue
			}
			mut pixel_color := Color.new(0,0,0)
			for _ in 0..c.samples_per_pixel {
				r := c.get_ray(i, j)
				pixel_color = pixel_color + c.ray_color(r, c.max_depth, world)
			}
			pixel_color = pixel_color.scale(c.pixel_samples_scale)
			lock image{ 
				image.image.set_xy(i, j, gfx.Color.new(linear_to_gamma(pixel_color.x()), linear_to_gamma(pixel_color.y()), linear_to_gamma(pixel_color.z())))
			}
		}
	}
}

fn (mut c Camera) render(world Hittable_List) gfx.Image{
	c.initialize()

	shared image := Image_S{
		image: gfx.Image.new(gfx.Size2i.new(c.image_width, c.image_height))
	}

	mut threads := []thread{}
	for i in 0..num_threads{
		threads << spawn c.multi_render(shared image, world, i)
	}

	threads.wait()
	return image.image
}


fn (c Camera) sample_square() Vec3{
	return Vec3.new(random_double() -0.5, random_double() -0.5, 0.0)
}

fn (c Camera) get_ray(i int, j int) Ray {
	offset := c.sample_square() 

	pixel_sample := c.pixel00_loc + (c.pixel_delta_u.scale((f64(i) + offset.x()))) + (c.pixel_delta_v.scale(f64(j) + offset.y()))

	ray_origin := if c.defocus_angle <= 0.0 {c.center} else {c.defocus_disk_sample()}
	ray_direction := pixel_sample - ray_origin

	ray_time := random_double()

	return Ray.new(ray_origin, ray_direction, tm: ray_time)
}

fn (c Camera) defocus_disk_sample() Point3{
	p := random_in_unit_disk()
	return (c.center + (c.defocus_disk_u.scale(p.x())) + (c.defocus_disk_v.scale(p.y())))
}