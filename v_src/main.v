module main



fn main() {

	// Image


	//World

	mut world := Hittable_List{}


	material_ground := Material.new(
		mat: EMaterial.lambertian
		albedo: Color.new(0.8, 0.8, 0.0)
	)	

	material_center := Material.new(
		mat: EMaterial.lambertian
		albedo: Color.new(0.1, 0.2, 0.5)
	)

	material_left := Material.new(
		mat: EMaterial.metal
		albedo: Color.new(0.8, 0.8, 0.8)
	)

	material_right := Material.new(
		mat: EMaterial.metal
		albedo: Color.new(0.8, 0.6, 0.2)
	)

	world.add(Hittable{
		shape: Shape.sphere,
		center: Point3.new(0.0, -100.5, -1.0),
		radius: 100.0
		mat: material_ground
	})
	world.add(Hittable{
		shape: Shape.sphere,
		center: Point3.new(0.0, 0.0, -1.2)
		radius: 0.5, 
		mat: material_center
	})
	world.add(Hittable{
		shape: Shape.sphere,
		center: Point3.new(1.0, 0.0, -1.0)
		radius: 0.5,
		mat: material_left
	})
	world.add(Hittable{
		shape: Shape.sphere,
		center: Point3.new(1.0, 0.0, -1.0)
		radius: 0.5,
		mat: material_right
	})


	
	mut cam := Camera.new()

	cam.aspect_ratio = 16.0/9.0
	cam.image_width = 400
	cam.samples_per_pixel = 100
	cam.max_depth = 50 

	cam.render(world)

	//camera

			//r := f64(j) / f64(image_width-1)
			//g := f64(i) / f64(image_height-1)
			//b := 0.0

			//ir := int(255.999 * r)
			//ig := int(255.999 * g)
			//ib := int(255.999 * b)

			//print("${ir} ${ig} ${ib}\n")
		
	
}