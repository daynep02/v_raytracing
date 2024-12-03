module main
import math
struct Interval {
	mut:
	min f64
	max f64
}


fn Interval.new(mi f64, ma f64) Interval{
	return Interval{
		min: mi
		max: ma
	}
}

fn Interval.new_from_intervals(a Interval, b Interval) Interval{
	return Interval {
		min: if a.min <= b.min {a.min} else {b.min}
		max: if a.max >= b.max {a.max} else {b.max}
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

fn (i Interval) expand(delta f64) Interval{
	padding := delta / 2.0
	return Interval.new(i.min - padding, i.max + padding)
}

const empty_interval := Interval.new(math.inf(1), math.inf(-1))
const universe_interval := Interval.new(math.inf(-1), math.inf(1))