package p2

import "core:bytes"
import "core:fmt"
import "core:math/linalg"
import "core:os"
import "core:sort"

Vector3 :: [3]f64
Distance :: struct {
	distance: f64,
	v1:       u32,
	v2:       u32,
}

part2 :: proc() {
	data := #load("../input")
	// data, _ := os.read_entire_file_from_filename("test")

	data_len := bytes.count(data, {'\n'})

	vectors := make([]Vector3, data_len)

	row := 0
	for line in bytes.split_iterator(&data, {'\n'}) {
		defer row += 1

		coordinates := bytes.split(line, {','})
		vector: Vector3
		for coord, i in coordinates {
			vector[i] = quick_parse(coord)
		}

		vectors[row] = vector
	}

	// fmt.println(vectors)

	distances := make([]Distance, data_len * data_len)

	for i in u32(0) ..< u32(len(vectors) - 1) {
		for j in u32(i + 1) ..< u32(len(vectors)) {
			distance := Distance{linalg.distance(vectors[i], vectors[j]), i, j}
			distances[i * u32(data_len) + j] = distance
		}
	}

	sort.quick_sort_proc(distances, proc(d1: Distance, d2: Distance) -> int {
		if d1.distance < d2.distance {
			return -1
		}
		if d1.distance == d2.distance {
			return 0
		}
		return 1
	})

	// fmt.println(distances)

	circuits := make([][dynamic]u32, data_len) // Array of circuits with the indices of vectors in them

	for &circuit, i in circuits {
		append(&circuit, u32(i))
	}

	// fmt.println(circuits)

	min_distance_index: int

	for {
		for ; min_distance_index < len(distances) && distances[min_distance_index].distance == 0;
		    min_distance_index += 1 {}

		distances[min_distance_index].distance = 0

		min_distance := distances[min_distance_index]

		// fmt.println(min_distance)

		circuit1 := find_circuit(circuits, min_distance.v1)
		circuit2 := find_circuit(circuits, min_distance.v2)

		if circuit1 == circuit2 {
			continue
		}

		for vector_index in circuits[circuit1] {
			append(&circuits[circuit2], vector_index)
		}
		clear(&circuits[circuit1])

		if len(circuits[circuit2]) == data_len {
			fmt.println(u64(vectors[min_distance.v1].x * vectors[min_distance.v2].x))
			break
		}

		// fmt.println(circuits)
		// fmt.println(distances)
	}

	// fmt.println(circuits)

}

quick_parse :: proc(str: []byte) -> (num: f64) {
	for digit in str {
		num *= 10
		num += f64(digit - '0')
	}

	return
}

find_circuit :: proc(circuits: [][dynamic]u32, vector: u32) -> (found: u32) {
	c1_loop: for circuit, circuit_index in circuits {
		for vector_index in circuit {
			if vector_index == vector {
				found = u32(circuit_index)
				break c1_loop
			}
		}
	}
	return
}
