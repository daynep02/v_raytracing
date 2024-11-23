module main
import math
import rand

const infinity := math.inf(1)

@[inline]
fn degrees_to_radians(degrees f64) f64 {
	return degrees * math.pi/180.0
}

@[inline]
fn random_double() f64 {
	return rand.f64()
}

@[inline]
fn random_double_bound(min f64, max f64) f64{
	return min + ((max-min) * random_double())
}