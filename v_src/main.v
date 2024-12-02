module main

fn main() {

	// Image


	//World


	mut world := Hittable_List{}
	/*
	for a in -11..11 {
		for b in -11..11{
			choose_mat := random_double()
			center := Point3.new(a + 0.9*random_double(), 0.2, b + 0.9*random_double())

			if (center-Point3.new(4.0, 0.2, 0.0)).length() > 0.9 {

				if choose_mat < 0.8 {
					albedo := Color.random() * Color.random()
					sphere_material := Material.new(
						mat: EMaterial.lambertian
						albedo: albedo
					)
					center2 := center + Vec3.new(0, random_double_bound(0, 0.5), 0)
					world.add(new_moving_sphere(center, center2,
						mat: sphere_material
						radius: 0.2
					))
				}
				else if choose_mat < 0.95 {
					albedo := Color.random_in_range(0.5, 1.0)
					fuzz := random_double_bound(0.0, 0.5)

					sphere_material := Material.new(
						mat: EMaterial.metal
						albedo: albedo
						fuzz: fuzz
					) 

					world.add(new_sphere(center,
						radius: 0.2,
						mat: sphere_material
					 ))
				}
				else {
					sphere_material := Material.new(
						mat: EMaterial.dielectric
						refraction_index: 1.5
					)
					world.add(new_sphere(center,
						radius: 0.2,
						mat: sphere_material
					 ))
				}
			}
		}
	}
	*/

	material1 := Material.new(
		mat: EMaterial.dielectric
		refraction_index: 1.5
	)
	world.add(Hittable.new(Point3.new(0.0, 1.0, 0.0),
		radius: 1.0,
		mat: material1
	 ))

	material2 := Material.new(
		mat: EMaterial.lambertian
		albedo: Color.new(0.4, 0.2, 0.1)
	)

	world.add(Hittable.new(Point3.new(-4.0, 1.0, 0.0),
		radius: 1.0,
		mat: material2
	 ))

	material3 := Material.new(
		mat: EMaterial.metal
		albedo: Color.new(0.4, 0.2, 0.1),
		fuzz: 0.0
	)
	world.add(Hittable.new(Point3.new(4.0, 1.0, 0.0),
		radius: 1.0,
		mat: material3
	 ))
	ground_material := Material.new(
		mat: EMaterial.lambertian
		albedo: Color.new(0.5, 1.5, 0.5)
	)

	world.add(Hittable.new(Point3.new(0.0, -1000, 0.0),
		radius: 1000.0,
		mat: ground_material
	 ))

	world2 := Bvh_node.new_from_list(world)


	
	mut cam := Camera.new()

	cam.aspect_ratio = 16.0/9.0
	cam.image_width = 400
	cam.samples_per_pixel = 100
	cam.max_depth = 50

	cam.vfov = 20
	cam.lookfrom = Point3.new(13.0, 2.0, 3.0)
	cam.lookat 	= Point3.new(0.0, 0.0, 0.0)
	cam.vup = Vec3.new(0.0, 1.0, 0.0) 

	cam.defocus_angle = 0.6
	cam.focus_dist = 10.0

	cam.render(world2).save_png("image3.png")

	//camera

			//r := f64(j) / f64(image_width-1)
			//g := f64(i) / f64(image_height-1)
			//b := 0.0

			//ir := int(255.999 * r)
			//ig := int(255.999 * g)
			//ib := int(255.999 * b)

			//print("${ir} ${ig} ${ib}\n")
		
	
}