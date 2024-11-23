module main
import math
struct Interval {
	min f64
	max f64
}


fn Interval.new(mi f64, ma f64) Interval{
	return Interval{
		min: mi
		max: ma
	}
}

fn (i Interval) size() f64{
	return i.max - i.min
}

fn (i Interval) contain(x f64) bool{
	return (i.min <= x && x <= i.max)
}

fn (i Interval) surrounds(x f64) bool {
	return (i.min < x && x < i.max)
}

fn (i Interval) clamp(x f64) f64 {
	return if x < i.min {i.min} else if x > i.max {i.max} else {x}
}

const empty := Interval.new(math.inf(1), math.inf(-1))
const universe := Interval.new(math.inf(-1), math.inf(1))