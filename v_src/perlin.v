import math
struct Perlin {
	mut: 
	point_count int = 256
	randfloat [256]f64 
	perm_x [256]int 
	perm_y [256]int 
	perm_z [256]int 

}

fn Perlin.new() Perlin{
	mut p := Perlin{}	
	for i in 0..p.point_count {
		p.randfloat[i] = random_double()
	}
	perlin_generate_perm(mut p.perm_x)
	perlin_generate_perm(mut p.perm_y)
	perlin_generate_perm(mut p.perm_z)
	return p
}

fn (p Perlin) noise(point Point3) f64{
	mut u := point.x() - math.floor(point.x())
	mut v := point.y() - math.floor(point.y())
	mut w := point.z() - math.floor(point.z())
	u = u*u*(3-2*u)
	v = v*v*(3-2*v)
	w = w*w*(3-2*w)
	i := int(4.0 * point.x()) & 255
	j := int(4.0 * point.z()) & 255
	k := int(4.0 * point.z()) & 255
	mut c := [2][2][2]f64

	for di in 0..2{
		for dj in 0..2{
			for dk in 0..2 {
				c[di][dj][dk] = p.randfloat[p.perm_x[(i + di) & 255] ^ p.perm_y[(j + dj) & 255] ^ p.perm_z[(k + dk) & 255]]
			}
		}
	}

	return trilinear_interp(c, u, v, w)
}

fn perlin_generate_perm(mut p [256]int) {
	for i in 0..256 {
		p[i] = i
	} 
	permute(mut p, 256)
}

fn permute(mut p [256]int, n int) {
	for i := n-1; i > 0; i-- {
		target := random_int(0, i)
		tmp := p[i]
		p[i] = p[target]
		p[target] = tmp
	}
}

fn trilinear_interp(c [2][2][2]f64, u f64, v f64, w f64) f64 {
	mut accum := 0.0
	for i in 0..2{
		for j in 0..2{
			for k in 0..2 {
				accum += (i*u + (1-i)*(1-u)) * (j*v + (1-j)*(1-v)) * (k*w + (1-k)*(1-w)) * c[i][j][k];
			}
		}
	}
	return accum
}