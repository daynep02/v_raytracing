module gfx

import math

// Color is a struct that stores the red, green, and blue intensities of a pixel.  Normally, intensities
// are in [0, 1] range, but values >1 are acceptable (values <0 do not make sense).
@[noinit]
pub struct Color {
pub mut:
    r f64 = 0.0
    g f64 = 0.0
    b f64 = 0.0
}

// Assumes each Color is located at increasing integer positions starting at 0
@[noinit]
pub struct ColorRamp {
pub:
    colors []Color
}

// Color4 is a struct that stores the red, green, and blue intensities and alpha value of a pixel.  Normally,
// intensity values for red, green, and blue are in [0, 1] range, but values >1 are acceptable (values <0 do
// not make sense).  Alpha values only make sense in [0, 1] range, where 0 means fully transparent and 1 means
// fully opaque.
@[noinit]
pub struct Color4 {
pub mut:
    r f64 = 0.0
    g f64 = 0.0
    b f64 = 0.0
    a f64 = 0.0
}

@[noinit]
pub struct Color_u8 {
pub mut:
    r u8
    g u8
    b u8
}
@[noinit]
pub struct Color4_u8 {
pub mut:
    r u8
    g u8
    b u8
    a u8
}



///////////////////////////////////////////////////////////
// constants

pub const black   = Color{ r:0.0, g:0.0, b:0.0 }
pub const white   = Color{ r:1.0, g:1.0, b:1.0 }
pub const red     = Color{ r:1.0, g:0.0, b:0.0 }
pub const yellow  = Color{ r:1.0, g:1.0, b:0.0 }
pub const green   = Color{ r:0.0, g:1.0, b:0.0 }
pub const cyan    = Color{ r:0.0, g:1.0, b:1.0 }
pub const blue    = Color{ r:0.0, g:0.0, b:1.0 }
pub const magenta = Color{ r:1.0, g:0.0, b:1.0 }
pub const brown   = Color{ r:0.7, g:0.5, b:0.0 }

pub const black4   = Color4{ r:0.0, g:0.0, b:0.0, a:1.0 }
pub const white4   = Color4{ r:1.0, g:1.0, b:1.0, a:1.0 }
pub const red4     = Color4{ r:1.0, g:0.0, b:0.0, a:1.0 }
pub const yellow4  = Color4{ r:1.0, g:1.0, b:0.0, a:1.0 }
pub const green4   = Color4{ r:0.0, g:1.0, b:0.0, a:1.0 }
pub const cyan4    = Color4{ r:0.0, g:1.0, b:1.0, a:1.0 }
pub const blue4    = Color4{ r:0.0, g:0.0, b:1.0, a:1.0 }
pub const magenta4 = Color4{ r:1.0, g:0.0, b:1.0, a:1.0 }
pub const brown4   = Color4{ r:0.7, g:0.5, b:0.0, a:1.0 }
pub const transparent4 = Color4{ r:0.0, g:0.0, b:0.0, a:0.0 }

pub const ramp = ColorRamp{
    colors: [
        // https://stackoverflow.com/questions/16500656/which-color-gradient-is-used-to-color-mandelbrot-in-wikipedia#answer-16505538
        Color.from_int([ 66,  30,  15]), // brown 3
        Color.from_int([ 25,   7,  26]), // dark violett
        Color.from_int([  9,   1,  47]), // darkest blue
        Color.from_int([  4,   4,  73]), // blue 5
        Color.from_int([  0,   7, 100]), // blue 4
        Color.from_int([ 12,  44, 138]), // blue 3
        Color.from_int([ 24,  82, 177]), // blue 2
        Color.from_int([ 57, 125, 209]), // blue 1
        Color.from_int([134, 181, 229]), // blue 0
        Color.from_int([211, 236, 248]), // lightest blue
        Color.from_int([241, 233, 191]), // lightest yellow
        Color.from_int([248, 201,  95]), // light yellow
        Color.from_int([255, 170,   0]), // dirty yellow
        Color.from_int([204, 128,   0]), // brown 0
        Color.from_int([153,  87,   0]), // brown 1
        Color.from_int([106,  52,   3]), // brown 2
    ]
}



///////////////////////////////////////////////////////////
// constructors

pub fn Color.new(r f64, g f64, b f64) Color {
    return Color{ r g b }
}
pub fn Color4.new(r f64, g f64, b f64, a f64) Color4 {
    return Color4{ r g b a }
}

// Color.from_u8 creates a Color based on given array of u8 values each in [0, 255] range representing red, green, and blue.
// Each channel is converted to [0, 1] range by dividing by 255.
pub fn Color.from_u8(vals []u8) Color {
    return Color{
        f64(vals[0]) / 255.0,
        f64(vals[1]) / 255.0,
        f64(vals[2]) / 255.0,
    }
}
pub fn Color4.from_u8(vals []u8) Color4 {
    return Color4{
        f64(vals[0]) / 255.0,
        f64(vals[1]) / 255.0,
        f64(vals[2]) / 255.0,
        if vals.len == 4 { f64(vals[3]) / 255.0 } else { 1.0 },
    }
}
pub fn Color.from_int(vals []int) Color {
    return Color{
        f64(vals[0]) / 255.0,
        f64(vals[1]) / 255.0,
        f64(vals[2]) / 255.0,
    }
}
pub fn Color4.from_int(vals []int) Color4 {
    return Color4{
        f64(vals[0]) / 255.0,
        f64(vals[1]) / 255.0,
        f64(vals[2]) / 255.0,
        if vals.len == 4 { f64(vals[3]) / 255.0 } else { 1.0 },
    }
}
pub fn Color.from_f64(vals []f64) Color {
    return Color{ vals[0], vals[1], vals[2] }
}
pub fn Color4.from_f64(vals []f64) Color4 {
    return Color4{ vals[0], vals[1], vals[2], if vals.len == 4 { vals[3] } else { 1.0 } }
}
// hue in [0, 360), saturation in [0, 1], lightness in [0, 1]
pub fn Color.from_hsl(hue f64, saturation f64, lightness f64) Color {
    c := (1.0 - math.abs(2.0 * lightness - 1.0)) * saturation
    x := c * (1.0 - math.abs(math.fmod(hue / 60.0, 2) - 1.0))
    m := lightness - c / 2.0
    mut r := 0.0
    mut g := 0.0
    mut b := 0.0

         if hue <  60 { r, g, b = c, x, 0 }
    else if hue < 120 { r, g, b = x, c, 0 }
    else if hue < 180 { r, g, b = 0, c, x }
    else if hue < 240 { r, g, b = 0, x, c }
    else if hue < 300 { r, g, b = x, 0, c }
    else              { r, g, b = c, 0, x }
    return Color{ r:r+m, g:g+m, b:b+m }
}
// hue in [0, 360), saturation in [0, 1], lightness in [0, 1], alpha in [0,1]
pub fn Color4.from_hsl(hue f64, saturation f64, lightness f64) Color4 {
    return Color4.from_hsla(hue, saturation, lightness, 1.0)
}
pub fn Color4.from_hsla(hue f64, saturation f64, lightness f64, alpha f64) Color4 {
    c := (1.0 - math.abs(2.0 * lightness - 1.0)) * saturation
    x := c * (1.0 - math.abs(math.fmod(hue / 60.0, 2) - 1.0))
    m := lightness - c / 2.0
    mut r := 0.0
    mut g := 0.0
    mut b := 0.0

         if hue <  60 { r, g, b = c, x, 0 }
    else if hue < 120 { r, g, b = x, c, 0 }
    else if hue < 180 { r, g, b = 0, c, x }
    else if hue < 240 { r, g, b = 0, x, c }
    else if hue < 300 { r, g, b = x, 0, c }
    else              { r, g, b = c, 0, x }
    return Color4{ r:r+m, g:g+m, b:b+m, a:alpha }
}


///////////////////////////////////////////////////////////
// printing methods

pub fn (c Color) str() string {
    return 'Color{ $c.r, $c.g, $c.b }'
}

pub fn (c Color4) str() string {
    return 'Color4{ $c.r, $c.g, $c.b, $c.a }'
}


///////////////////////////////////////////////////////////
// conversion methods

pub fn (c Color) as_color_u8(max f64) Color_u8 {
    return Color_u8{
        u8(255.999 * math.clamp(c.r / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.g / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.b / max, 0.0, 1.0))
    }
}

pub fn (c Color4) as_color_u8(max f64) Color_u8 {
    return Color_u8{
        u8(255.999 * math.clamp(c.r / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.g / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.b / max, 0.0, 1.0))
    }
}

pub fn (c Color) as_color4_u8(max f64) Color4_u8 {
    return Color4_u8{
        u8(255.999 * math.clamp(c.r / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.g / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.b / max, 0.0, 1.0))
        255
    }
}

pub fn (c Color4) as_color4_u8(max f64) Color4_u8 {
    return Color4_u8{
        u8(255.999 * math.clamp(c.r / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.g / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.b / max, 0.0, 1.0))
        u8(255.999 * math.clamp(c.a, 0.0, 1.0))
    }
}

pub fn (c Color_u8) as_color() Color {
    return Color{
        f64(c.r) / 255.0
        f64(c.g) / 255.0
        f64(c.b) / 255.0
    }
}

pub fn (c Color_u8) as_color4() Color4 {
    return Color4{
        f64(c.r) / 255.0
        f64(c.g) / 255.0
        f64(c.b) / 255.0
        1.0
    }
}

pub fn (c Color4_u8) as_color() Color {
    return Color{
        f64(c.r) / 255.0
        f64(c.g) / 255.0
        f64(c.b) / 255.0
    }
}

pub fn (c Color4_u8) as_color4() Color4 {
    return Color4{
        f64(c.r) / 255.0
        f64(c.g) / 255.0
        f64(c.b) / 255.0
        f64(c.a) / 255.0
    }
}

// convert each channel to u8 (with scaling and clamping)

pub fn (c Color) r_u8(max f64) u8 {
    return u8(255.999 * math.clamp(c.r / max, 0.0, 1.0))
}
pub fn (c Color) g_u8(max f64) u8 {
    return u8(255.999 * math.clamp(c.g / max, 0.0, 1.0))
}
pub fn (c Color) b_u8(max f64) u8 {
    return u8(255.999 * math.clamp(c.b / max, 0.0, 1.0))
}
pub fn (c Color) rgb_u8(max f64) []u8 {
    return [ c.r_u8(max), c.g_u8(max), c.b_u8(max) ]
}

pub fn (c Color4) r_u8(max f64) u8 {
    return u8(255.999 * math.clamp(c.r / max, 0.0, 1.0))
}
pub fn (c Color4) g_u8(max f64) u8 {
    return u8(255.999 * math.clamp(c.g / max, 0.0, 1.0))
}
pub fn (c Color4) b_u8(max f64) u8 {
    return u8(255.999 * math.clamp(c.b / max, 0.0, 1.0))
}
pub fn (c Color4) a_u8() u8 {
    return u8(255.999 * math.clamp(c.a, 0.0, 1.0))
}
pub fn (c Color4) rgb_u8(max f64) []u8 {
    return [ c.r_u8(max), c.g_u8(max), c.b_u8(max) ]
}
pub fn (c Color4) rgba_u8(max f64) []u8 {
    return [ c.r_u8(max), c.g_u8(max), c.b_u8(max), c.a_u8() ]
}

pub fn (c Color) as_color4() Color4 {
    return Color4{ c.r, c.g, c.b, 1.0 }
}
pub fn (c Color4) as_color() Color {
    return Color{ c.r, c.g, c.b }
}

pub fn (c Color) hue() f64 {
    max := max3(c.r, c.g, c.b)
    min := min3(c.r, c.g, c.b)
    delta := max - min
    if delta == 0 { return 0 }
    if max == c.r { return 60 * math.fmod((c.g - c.b) / delta, 6) }
    if max == c.g { return 60 * ((c.b - c.r) / delta + 2) }
                    return 60 * ((c.r - c.g) / delta + 4)
}
pub fn (c Color) saturation() f64 {
    max := max3(c.r, c.g, c.b)
    min := min3(c.r, c.g, c.b)
    delta := max - min
    if delta == 0 { return 0 }
    return delta / (1.0 - math.abs(2.0 * c.lightness() - 1.0))
}
pub fn (c Color) lightness() f64 {
    return 0.5 * (max3(c.r, c.g, c.b) + min3(c.r, c.g, c.b))
}
pub fn (c Color) hsl() (f64, f64, f64) {
    return c.hue(), c.saturation(), c.lightness()
}

// note: ignores alpha
pub fn (c Color4) hue() f64 {
    max := max3(c.r, c.g, c.b)
    min := min3(c.r, c.g, c.b)
    delta := max - min
    if delta == 0 { return 0 }
    if max == c.r { return 60 * math.fmod((c.g - c.b) / delta, 6) }
    if max == c.g { return 60 * ((c.b - c.r) / delta + 2) }
                    return 60 * ((c.r - c.g) / delta + 4)
}
// note: ignores alpha
pub fn (c Color4) saturation() f64 {
    max := max3(c.r, c.g, c.b)
    min := min3(c.r, c.g, c.b)
    delta := max - min
    if delta == 0 { return 0 }
    return delta / (1.0 - math.abs(2.0 * c.lightness() - 1.0))
}
// note: ignores alpha
pub fn (c Color4) lightness() f64 {
    return 0.5 * (max3(c.r, c.g, c.b) + min3(c.r, c.g, c.b))
}

pub fn (c Color4) hsl() (f64, f64, f64) {
    return c.hue(), c.saturation(), c.lightness()
}
pub fn (c Color4) hsla() (f64, f64, f64, f64) {
    return c.hue(), c.saturation(), c.lightness(), c.a
}


///////////////////////////////////////////////////////////
// arithmetic methods

pub fn (c Color) scale(s f64) Color {
    return Color{ c.r * s, c.g * s, c.b * s }
}
// note: also scales alpha
pub fn (c Color4) scale(s f64) Color4 {
    return Color4{ c.r * s, c.g * s, c.b * s, c.a * s }
}
pub fn (mut c Color) scale_in(s f64) Color {
    c.r *= s
    c.g *= s
    c.b *= s
    return c
}

pub fn (a Color) add(b Color) Color {
    return Color{ a.r + b.r, a.g + b.g, a.b + b.b }
}
pub fn (mut a Color) add_in(b Color) Color {
    a.r += b.r
    a.g += b.g
    a.b += b.b
    return a
}
pub fn (a Color) + (b Color) Color {
    return Color{ a.r + b.r, a.g + b.g, a.b + b.b }
}

pub fn (a Color) mult(b Color) Color {
    return Color{ a.r * b.r, a.g * b.g, a.b * b.b }
}
pub fn (mut a Color) mult_in(b Color) Color {
    a.r *= b.r
    a.g *= b.g
    a.b *= b.b
    return a
}
pub fn (a Color) * (b Color) Color {
    return Color{ a.r * b.r, a.g * b.g, a.b * b.b }
}

pub fn (a Color) lerp(b Color, f f64) Color {
    return Color{
        a.r * (1.0 - f) + b.r * f,
        a.g * (1.0 - f) + b.g * f,
        a.b * (1.0 - f) + b.b * f,
    }
}
// note: also lerps alpha
pub fn (a Color4) lerp(b Color4, f f64) Color4 {
    return Color4{
        a.r * (1.0 - f) + b.r * f,
        a.g * (1.0 - f) + b.g * f,
        a.b * (1.0 - f) + b.b * f,
        a.a * (1.0 - f) + b.a * f,
    }
}

pub fn Color.average(colors ...Color) Color {
    mut avg := Color{ 0 0 0 }
    if colors.len == 0 { return avg }
    for color in colors {
        avg.r += color.r
        avg.g += color.g
        avg.b += color.b
    }
    return avg.scale(1.0 / f64(colors.len))
}

// note: also averages alpha
pub fn Color4.average(colors ...Color4) Color4 {
    mut avg := Color4{ 0 0 0 0 }
    if colors.len == 0 { return avg }
    for color in colors {
        avg.r += color.r
        avg.g += color.g
        avg.b += color.b
        avg.a += color.a
    }
    return avg.scale(1.0 / f64(colors.len))
}


///////////////////////////////////////////////////////////
// color ramp functions

pub fn (colorramp ColorRamp) len() int {
    return colorramp.colors.len
}

pub fn (colorramp ColorRamp) color(loc f64) Color {
    if colorramp.colors.len == 0 { return black }
    wrappedloc := math.fmod(loc, f64(colorramp.len()))
    index := int(wrappedloc)
    blend := wrappedloc - f64(index)
    below := colorramp.colors[index]
    above := colorramp.colors[(index+1) % colorramp.len()]
    return below.lerp(above, blend)
}


///////////////////////////////////////////////////////////
// testing functions

pub fn (c Color) is_black() bool {
    return c.r <= 10e-5 && c.g <= 10e-5 && c.b <= 10e-5
}
// note: ignores alpha
pub fn (c Color4) is_black() bool {
    return c.r <= 10e-5 && c.g <= 10e-5 && c.b <= 10e-5
}

pub fn (c Color4) is_transparent() bool {
    return c.a <= 10e-5
}
pub fn (c Color4) is_opaque() bool {
    return c.a >= 1.0 - 10e-5
}





