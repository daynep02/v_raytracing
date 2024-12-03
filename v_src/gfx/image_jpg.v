module gfx

import stbi


///////////////////////////////////////////////////////////
// jpg loading and saving functions


pub fn Image.load_jpg(filename string) Image {
    jpg := stbi.load(filename) or { panic(err) }
    size := jpg.width * jpg.height
    mut pixels := []Color4_u8{ len:size, cap:size }
    unsafe {
        pixels.data = jpg.data
    }
    mut image := Image.new( Size2i{ jpg.width, jpg.height } )
    for y in 0 .. jpg.height {
        for x in 0 .. jpg.width {
            pixel := pixels[y * jpg.width + x]
            image.set_xy(x, y, pixel.as_color())
        }
    }
    return image
}

pub fn Image4.load_jpg(filename string) Image4 {
    jpg := stbi.load(filename) or { panic(err) }
    size := jpg.width * jpg.height
    mut pixels := []Color4_u8{ len:size, cap:size }
    unsafe {
        pixels.data = jpg.data
    }
    mut image := Image4.new( Size2i{ jpg.width, jpg.height } )
    for y in 0 .. jpg.height {
        for x in 0 .. jpg.width {
            pixel := pixels[y * jpg.width + x]
            image.set_xy(x, y, pixel.as_color4())
        }
    }
    return image
}

pub fn (image Image) save_jpg(filename string) {
    size := image.width() * image.height()
    mut pixels := []Color4_u8{ len:size, cap:size }
    for y in 0 .. image.height() {
        for x in 0 .. image.width() {
            pixels[y * image.width() + x] = image.get_xy(x, y).as_color4_u8(1.0)
        }
    }
    stbi.stbi_write_jpg(filename, image.width(), image.height(), 4, pixels.data, 50) or { panic(err) }
}

pub fn (image Image4) save_jpg(filename string) {
    size := image.width() * image.height()
    mut pixels := []Color4_u8{ len:size, cap:size }
    for y in 0 .. image.height() {
        for x in 0 .. image.width() {
            pixels[y * image.width() + x] = image.get_xy(x, y).as_color4_u8(1.0)
        }
    }
    stbi.stbi_write_jpg(filename, image.width(), image.height(), 4, pixels.data, 50) or { panic(err) }
}

