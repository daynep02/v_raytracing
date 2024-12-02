module main
struct Hittable_List {
mut:
	objects []Hittable = []Hittable{}
	bbox Aabb
}

fn Hittable_List.new(object Hittable) Hittable_List{
	return Hittable_List {
		objects: [object]
		bbox: object.bounding_box()
	}	
}

fn (mut hl Hittable_List) clear() {
	hl.objects = []Hittable{}
}

fn (mut hl Hittable_List) add(object Hittable) {
	hl.objects << object
	hl.bbox = Aabb.new_from_aabb(hl.bbox, object.bounding_box())
}

fn (mut hl Hittable_List) add_list(objects Hittable_List) {
	hl.objects << objects.objects
}

fn (hl Hittable_List) hit(r Ray, ray_t Interval, mut rec Hit_Record) bool {
	mut hit_anything := false
	mut tmp_rec := Hit_Record{}

	mut closest_so_far := ray_t.max
	for object in hl.objects {
		if object.hit(r, Interval.new(ray_t.min, closest_so_far), mut tmp_rec){
			hit_anything = true
			closest_so_far = tmp_rec.t
			rec = tmp_rec
		}
	}

	return hit_anything
}

fn (hl Hittable_List) boudning_box() Aabb {
	return hl.bbox
}