package p2

import "core:bytes"
import "core:fmt"
import "core:os"

Position :: [2]f64

LineDirection :: enum {
	Vertical,
	Horizontal,
}

Line :: struct {
	a:   Position,
	b:   Position,
	dir: LineDirection,
}

run :: proc() {
	data := #load("../input")
	// data, _ := os.read_entire_file_from_filename("test")

	data_len := bytes.count(data, {'\n'})

	tiles := make([]Position, data_len)

	row := 0
	for line in bytes.split_iterator(&data, {'\n'}) {
		defer row += 1

		x_str, _, y_str := bytes.partition(line, {','})

		tiles[row] = Position{quick_parse(x_str), quick_parse(y_str)}
	}

	// fmt.println(tiles)

	outline := make([]Line, data_len)

	for i := 1; i <= data_len; i += 1 {
		previous := tiles[i - 1]
		current := tiles[i % data_len]
		next := tiles[(i + 1) % data_len]

		offset: Position

		// fmt.println(previous, current, next)

		dir: LineDirection

		if current.y == previous.y {
			dir = .Horizontal
			if current.x > previous.x { 	// Going right
				if next.y < current.y { 	// Turning left
					//fmt.println("RU")
					offset = Position{-0.5, -0.5}
				} else { 	// Turning right
					//fmt.println("RD")
					offset = Position{0.5, -0.5}
				}
			} else { 	// Going left
				if next.y > current.y { 	// Turning left
					//fmt.println("LD")
					offset = Position{0.5, 0.5}
				} else { 	// Turning right
					//fmt.println("LU")
					offset = Position{-0.5, 0.5}
				}
			}
		} else {
			dir = .Vertical
			if current.y > previous.y { 	// Going down
				if next.x > current.x { 	// Turning left
					//fmt.println("DR")
					offset = Position{-0.5, 0.5}
				} else { 	// Turning right
					//fmt.println("DL")
					offset = Position{0.5, 0.5}
				}
			} else { 	// Going up
				if next.x < current.x { 	// Turning left
					//fmt.println("UL")
					offset = Position{-0.5, 0.5}
				} else { 	// Turning right
					//fmt.println("UR")
					offset = Position{-0.5, -0.5}
				}
			}
		}

		outline[i % data_len] = Line{outline[i - 1].b, current + offset, dir}
	}

	outline[1].a = outline[0].b

	// fmt.println(outline)

	max_square: f64 = 0

	for i in 0 ..< (len(tiles) - 1) {
		corner1 := tiles[i]
		outer: for j in (i + 1) ..< len(tiles) {
			corner3 := tiles[j]

			area := (abs(corner1.x - corner3.x) + 1) * (abs(corner1.y - corner3.y) + 1)

			// fmt.println(area)

			corner2 := Position{corner1.x, corner3.y}
			corner4 := Position{corner3.x, corner1.y}

			lines: []Line = {
				Line {
					a = corner1,
					b = corner2,
					dir = corner1.x == corner2.x ? .Vertical : .Horizontal,
				},
				Line {
					a = corner2,
					b = corner3,
					dir = corner2.x == corner3.x ? .Vertical : .Horizontal,
				},
				Line {
					a = corner3,
					b = corner4,
					dir = corner3.x == corner4.x ? .Vertical : .Horizontal,
				},
				Line {
					a = corner4,
					b = corner1,
					dir = corner4.x == corner1.x ? .Vertical : .Horizontal,
				},
			}

			for line_rect in lines {
				for line_outline in outline {
					if line_rect.dir == line_outline.dir {
						continue
					}

					if line_rect.dir == .Horizontal {
						if ((line_rect.a.y > line_outline.a.y &&
								   line_rect.a.y < line_outline.b.y) ||
							   (line_rect.a.y > line_outline.b.y &&
									   line_rect.a.y < line_outline.a.y)) &&
						   ((line_outline.a.x > line_rect.a.x &&
									   line_outline.a.x < line_rect.b.x) ||
								   (line_outline.a.x > line_rect.b.x &&
										   line_outline.a.x < line_rect.a.x)) {
							// fmt.println(line_rect, "and", line_outline, "intersect")
							continue outer
						}
					} else if line_rect.dir == .Vertical {
						if ((line_outline.a.y > line_rect.a.y &&
								   line_outline.a.y < line_rect.b.y) ||
							   (line_outline.a.y > line_rect.b.y &&
									   line_outline.a.y < line_rect.a.y)) &&
						   ((line_rect.a.x > line_outline.a.x &&
									   line_rect.a.x < line_outline.b.x) ||
								   (line_rect.a.x > line_outline.b.x &&
										   line_rect.a.x < line_outline.a.x)) {
							// fmt.println(line_rect, "and", line_outline, "intersect")
							continue outer
						}

					}
				}
			}

			if area > max_square {
				max_square = area
			}
		}
	}

	fmt.println(u64(max_square))
}

quick_parse :: proc(str: []byte) -> (num: f64) {
	for digit in str {
		num *= 10
		num += f64(digit - '0')
	}

	return
}
