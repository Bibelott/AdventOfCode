package p1

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

Range :: struct {
	start: u64,
	end:   u64,
}

part1 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	data_string := strings.clone_from_bytes(data)

	sum: u64 = 0

	id_ranges: [dynamic]Range

	for range_str in strings.split_lines_iterator(&data_string) {
		start_str, _, end_str := strings.partition(range_str, "-")

		start, _ := strconv.parse_u64(start_str)

		if end_str == "" {
			break
		}

		end, _ := strconv.parse_u64(end_str)

		append(&id_ranges, Range{start, end})
	}

	total_fresh := 0

	for id_str in strings.split_lines_iterator(&data_string) {
		ingredient_id, _ := strconv.parse_u64(id_str)

		for range in id_ranges {
			if ingredient_id >= range.start && ingredient_id <= range.end {
				total_fresh += 1
				break
			}
		}
	}

	fmt.println(total_fresh)
}
