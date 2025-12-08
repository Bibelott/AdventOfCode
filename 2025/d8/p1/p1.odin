package p1

import "core:bytes"
import "core:fmt"
import "core:math/linalg"
import "core:os"
import "core:sort"

CONNECTIONS :: 1000

Vector3 :: [3]f32
Distance :: struct {
	distance: f32,
	v1:       u32,
	v2:       u32,
}

part1 :: proc() {
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

	i := 0
	for i < CONNECTIONS {
		defer i += 1

		min_distance: Distance
		for index in min_distance_index + 1 ..< len(distances) {
			distance := distances[index]
			if distance.distance == 0 {
				continue
			}

			min_distance = distance
			min_distance_index = index
			break
		}

		distances[min_distance_index].distance = 0

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

		// for v1, j in circuits[circuit2] {
		// 	for v2 in circuits[circuit2][j + 1:] {
		// 		distances[v1 * u32(data_len) + v2] = 0
		// 		distances[v2 * u32(data_len) + v1] = 0
		//
		// 	}
		// }

		// fmt.println(circuits)
		// fmt.println(distances)
	}

	// fmt.println(circuits)

	product := 1
	for i in 0 ..< 3 {
		max_len := 0
		max_circuit: ^[dynamic]u32
		for &circuit in circuits {
			if len(circuit) > max_len {
				max_len = len(circuit)
				max_circuit = &circuit
			}
		}
		// fmt.println(max_circuit^)
		clear(max_circuit)
		product *= max_len
	}

	fmt.println(product)
}

quick_parse :: proc(str: []byte) -> (num: f32) {
	for digit in str {
		num *= 10
		num += f32(digit - '0')
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
