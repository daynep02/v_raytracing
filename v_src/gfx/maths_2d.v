module gfx

import math
import rand

@[noinit]
pub struct Point2i {
pub:
    x int @[required]
    y int @[required]
}

@[noinit]
pub struct Point2 {
pub:
    x f64 @[required]
    y f64 @[required]
}

@[noinit]
pub struct Vector2i {
pub:
    x int @[required]
    y int @[required]
}

@[noinit]
pub struct Vector2 {
pub:
    x f64 @[required]
    y f64 @[required]
}

@[noinit]
pub struct Size2i {
pub:
    width  int @[required]
    height int @[required]
}

@[noinit]
pub struct Size2 {
pub:
    width  f64 @[required]
    height f64 @[required]
}

@[noinit]
pub struct LineSegment2i {
pub:
    p0 Point2i @[required]
    p1 Point2i @[required]
}




///////////////////////////////////////////////////////////
// constants

pub const origin2 = Point2{ 0.0, 0.0 }



///////////////////////////////////////////////////////////
// constructors

pub fn Point2i.new(x int, y int) Point2i {
    return Point2i{ x y }
}

pub fn Point2.new(x f64, y f64) Point2 {
    return Point2{ x y }
}

pub fn Vector2i.new(x int, y int) Vector2i {
    return Vector2i{ x y }
}

pub fn Vector2.new(x f64, y f64) Vector2 {
    return Vector2{ x y }
}

pub fn LineSegment2i.new(p0 Point2i, p1 Point2i) LineSegment2i {
    return LineSegment2i{ p0 p1 }
}

pub fn Size2.new(width f64, height f64) Size2 {
    return Size2{ width height }
}

pub fn Size2i.new(width int, height int) Size2i {
    return Size2i{ width height }
}

pub fn Point2i.rand(min Point2i, max Point2i) Point2i {
    x := rand.int_in_range(min.x, max.x) or { return min }
    y := rand.int_in_range(min.y, max.y) or { return min }
    return Point2i{ x, y }
}



///////////////////////////////////////////////////////////
// printing methods

pub fn (p Point2i) str() string {
    return 'Point2i{ $p.x, $p.y }'
}

pub fn (p Point2) str() string {
    return 'Point2{ $p.x, $p.y }'
}

pub fn (v Vector2) str() string {
    return 'Vector2{ $v.x, $v.y }'
}

pub fn (v Vector2i) str() string {
    return 'Vector2i{ $v.x, $v.y }'
}


///////////////////////////////////////////////////////////
// direction and magnitude/length methods

pub fn (v Vector2) length_squared() f64 {
    return v.dot(v)
}

pub fn (v Vector2) length() f64 {
    return math.sqrt(v.length_squared())
}

pub fn (v Vector2) l1_norm() f64 {
    return math.abs(v.x) + math.abs(v.y)
}

pub fn (v Vector2) l2_norm() f64 {
    return v.length()
}

pub fn (v Vector2) linf_norm() f64 {
    return math.max(math.abs(v.x), math.abs(v.y))
}

pub fn (v Vector2) normalized() Vector2 {
    l := v.length()
    return Vector2{ v.x / l, v.y / l }
}

pub fn (v Vector2i) abs() Vector2i {
    return Vector2i{ math.abs(v.x), math.abs(v.y) }
}
pub fn (v Vector2i) sign() Vector2i {
    return Vector2i{ sign(v.x), sign(v.y) }
}


///////////////////////////////////////////////////////////
// interpolation methods

pub fn (a Point2i) average(b Point2i) Point2i {
    return Point2i{ int((a.x + b.x) / 2), int((a.y + b.y) / 2) }
}

pub fn Point2i.average(ps ...Point2i) Point2i {
    mut x := 0
    mut y := 0
    if ps.len == 0 { return Point2i{ 0 0 } }
    for p in ps {
        x += p.x
        y += p.y
    }
    return Point2i{ int(f64(x) / f64(ps.len)), int(f64(y) / f64(ps.len)) }
}

pub fn Point2.average(ps ...Point2) Point2 {
    mut x := f64(0)
    mut y := f64(0)
    if ps.len == 0 { return Point2{ 0 0 } }
    for p in ps {
        x += p.x
        y += p.y
    }
    return Point2{ x / f64(ps.len), y / f64(ps.len) }
}

pub fn (a Point2) average(b Point2) Point2 {
    return Point2{ (a.x + b.x) / 2, (a.y + b.y) / 2}
}

pub fn (from Point2) lerp(to Point2, factor f64) Point2 {
    return Point2{
        from.x * (1.0 - factor) + to.x * factor,
        from.y * (1.0 - factor) + to.y * factor,
    }
}

pub fn (from Vector2) lerp(to Vector2, factor f64) Vector2 {
    return Vector2{
        from.x * (1.0 - factor) + to.x * factor,
        from.y * (1.0 - factor) + to.y * factor,
    }
}


///////////////////////////////////////////////////////////
// comparison methods

pub fn (a Point2i) == (b Point2i) bool {
    return a.x == b.x && a.y == b.y
}



///////////////////////////////////////////////////////////
// arithmetic methods

// int points and vectorss

pub fn (p Point2i) add(v Vector2i) Point2i {
    return Point2i{ p.x + v.x, p.y + v.y }
}
pub fn (p Point2i) - (o Point2i) Vector2i {
    return Vector2i{ p.x - o.x, p.y - o.y }
}

pub fn (p Point2i) sub(v Vector2i) Point2i {
    return Point2i{ p.x - v.x, p.y - v.y }
}
pub fn (p Point2i) diff(o Point2i) Vector2i {
    return Vector2i{ p.x - o.x, p.y - o.y }
}

pub fn (a Vector2i) add(b Vector2i) Vector2i {
    return Vector2i{ a.x + b.x, a.y + b.y }
}
pub fn (a Vector2i) +(b Vector2i) Vector2i {
    return Vector2i{ a.x + b.x, a.y + b.y }
}
pub fn (a Vector2i) sub(b Vector2i) Vector2i {
    return Vector2i{ a.x - b.x, a.y - b.y }
}
pub fn (a Vector2i) - (b Vector2i) Vector2i {
    return Vector2i{ a.x - b.x, a.y - b.y }
}


// float points and vectors

// NOTE: cannot have Point2 + Vector2 or Point2 - Vector2, because V
//       only allows operator overloading if both types are the same

pub fn (p Point2) add(v Vector2) Point2 {
    return Point2{ p.x + v.x, p.y + v.y }
}
pub fn (a Vector2) add(b Vector2) Vector2 {
    return Vector2{ a.x + b.x, a.y + b.y }
}

pub fn (p Point2) sub(v Vector2) Point2 {
    return Point2{ p.x - v.x, p.y - v.y }
}
pub fn (a Vector2) sub(b Vector2) Vector2 {
    return Vector2{ a.x - b.x, a.y - b.y }
}
pub fn (a Point2) diff(b Point2) Vector2 {
    return Vector2{ a.x - b.x, a.y - b.y }
}

pub fn (a Vector2) dot(b Vector2) f64 {
    return a.x * b.x + a.y * b.y
}

pub fn (a Vector2) mult(b Vector2) Vector2 {
    return Vector2{ a.x * b.x, a.y * b.y }
}

pub fn (a Vector2) scale(s f64) Vector2 {
    return Vector2{ a.x * s, a.y * s }
}

pub fn (v Vector2) negate() Vector2 {
    return Vector2{ -v.x, -v.y }
}



///////////////////////////////////////////////////////////
// extra point methods

pub fn (a Point2) vector_to(b Point2) Vector2 {
    return Vector2{ b.x - a.x, b.y - a.y }
}

pub fn (p Point2i) xy() (int, int) {
    return p.x, p.y
}

pub fn (p Point2) as_point2i() Point2i {
    return Point2i{ int(p.x), int(p.y) }
}
