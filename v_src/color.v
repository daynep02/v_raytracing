module main
import math
type Color = Vec3

@[inline]
fn linear_to_gamma(linear_component f64) f64{
	return if linear_component > 0.0 {math.sqrt(linear_component)} else {0.0}
}
//unused because I am using the Image class added in the gfx module
fn write_color(color Color) {
	r := linear_to_gamma(color.x())
	g := linear_to_gamma(color.y())
	b := linear_to_gamma(color.z())

	intensity := Interval.new(0.000, 0.999)

	rbyte := int(256 * intensity.clamp(r))
	gbyte := int(256 * intensity.clamp(g))
	bbyte := int(256 * intensity.clamp(b))

	print("${rbyte} ${gbyte} ${bbyte}\n")
}