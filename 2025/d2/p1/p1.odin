package p1

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

part1 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	data_string := strings.clone_from_bytes(data)

	sum: u64 = 0

	for range_untrimmed in strings.split_iterator(&data_string, ",") {
		range := strings.trim(range_untrimmed, "\n ")
		start_str, _, end_str := strings.partition(range, "-")

		start, _ := strconv.parse_u64(start_str)
		end, _ := strconv.parse_u64(end_str)

		outer_loop: for id := start; id <= end; id += 1 {
			id_str := fmt.aprint(id)

			divide_into := 2

			// Misread the instructions, we're only checking if it's repeated twice
			// Keeping it though, because my spidey sense is tingling

			// divide_loop: for divide_into := 2; divide_into <= len(id_str); divide_into += 1 {
			if len(id_str) % divide_into != 0 {
				continue
			}

			slice_length := len(id_str) / divide_into

			first_slice := id_str[:slice_length]

			for i := 1; i < divide_into; i += 1 {
				current_slice := id_str[i * slice_length:][:slice_length]

				if strings.compare(current_slice, first_slice) != 0 { 	// different
					continue outer_loop
				}
			}

			// all slices are the same

			// fmt.println("Found invalid id:", id)

			sum += id
			// break
			// }
		}
	}

	fmt.println(sum)
}
