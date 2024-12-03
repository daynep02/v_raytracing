import os
import json
struct Bvh_node {
	left ?&Bvh_node
	right ?&Bvh_node
	object ?Hittable
	bbox Aabb
}

fn Bvh_node.new_from_list(list Hittable_List) Bvh_node{
	mut cloned_objects := list.objects.clone()
	node := Bvh_node.new(mut cloned_objects, 0, cloned_objects.len)
	mut file := os.create('testfile.json') or {
		return node
	}

	file.write_string(json.encode(node)) or {
		file.close()
		return node
	}
	file.close()
	return node
	
}

fn Bvh_node.new(mut objects []Hittable, start int, end int) Bvh_node{
	//todo

	mut bbox := empty_aabb
	for index in start .. end {
		bbox = Aabb.new_from_aabb(bbox, objects[index].bounding_box()) 
	}

	axis := bbox.longest_axis()

	box_x_compare  := fn (a &Hittable, b &Hittable) int {
		return box_compare(a, b, 0)
	}
	box_y_compare  := fn (a &Hittable, b &Hittable) int {
		return box_compare(a, b, 1)
	}
	box_z_compare  := fn (a &Hittable, b &Hittable) int {
		return box_compare(a, b, 2)
	}

	comparator := if axis == 0 {box_x_compare}
	else if axis == 1 {box_y_compare}
	else {box_z_compare}

	object_span := end - start

	if object_span == 1 {
		left := objects[start]
		right := objects[start]
		return Bvh_node {
			left: none
			right: none
			bbox: bbox
			object: objects[start]
		}
	}else if object_span == 2 {
		left_object := objects[start]
		right_object := objects[start+1]
		return Bvh_node {
			left: &Bvh_node{
				left: none
				right: none
				bbox: left_object.bounding_box()
				object: left_object
			}
			right: &Bvh_node {
				left: none
				right: none
				bbox: right_object.bounding_box()
				object: right_object
			}
			bbox : bbox
		}
	}		
	else {
		objects[start..end].sort_with_compare(comparator)
		mid := start + object_span / 2
		left := Bvh_node.new(mut objects, start, mid)
		right := Bvh_node.new(mut objects, mid, end)
		return Bvh_node {
			left: &left
			right: &right
			bbox : Aabb.new_from_aabb(left.bounding_box(), right.bounding_box())
			object: none
		}
	}
}

fn (b Bvh_node) bounding_box() Aabb{
	return b.bbox
}


fn (b Bvh_node) hit( r Ray, mut ray_t Interval, mut rec Hit_Record) bool{
	if  o := b.object {
		return o.hit(r, ray_t, mut rec)
	}
	if !b.bbox.hit(r, ray_t){
		return false
	}


	mut hit_left := false
	mut hit_right := false
	
	if l := b.left {
		hit_left = l.hit(r, mut ray_t, mut rec)
	}
	if ri := b.right {
		hit_right = ri.hit(r, mut Interval.new(ray_t.min, if hit_left {rec.t} else {ray_t.max}), mut rec)
	}
	/*
	if hit_left && hit_right {
		//println("Hit left and right\nRay: ${r}, ray_t ${ray_t}, rec ${rec}")
	}
	*/

	return (hit_right || hit_left)

	
}

fn box_compare(a Hittable, b Hittable, axis_index int) int {
	a_axis_interval := a.bounding_box().axis_interval(axis_index)
	b_axis_interval := b.bounding_box().axis_interval(axis_index)
	return if a_axis_interval.min < b_axis_interval.min {-1}
	else {1}
} 