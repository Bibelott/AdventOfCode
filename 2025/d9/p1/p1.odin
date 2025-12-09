package p1

import "core:bytes"
import "core:fmt"
import "core:os"

TilePos :: [2]i64

run :: proc() {
	data := #load("../input")
	// data, _ := os.read_entire_file_from_filename("test")

	data_len := bytes.count(data, {'\n'})

	tiles := make([]TilePos, data_len)

	row := 0
	for line in bytes.split_iterator(&data, {'\n'}) {
		defer row += 1

		x_str, _, y_str := bytes.partition(line, {','})

		tiles[row] = TilePos{quick_parse(x_str), quick_parse(y_str)}
	}

	// fmt.println(tiles)

	max_square: i64 = 0

	for i in 0 ..< (len(tiles) - 1) {
		corner1 := tiles[i]
		for j in (i + 1) ..< len(tiles) {
			corner2 := tiles[j]

			area := (abs(corner1.x - corner2.x) + 1) * (abs(corner1.y - corner2.y) + 1)

			// fmt.println(area)

			if area > max_square {
				max_square = area
			}
		}
	}

	fmt.println(max_square)
}

quick_parse :: proc(str: []byte) -> (num: i64) {
	for digit in str {
		num *= 10
		num += i64(digit - '0')
	}

	return
}
