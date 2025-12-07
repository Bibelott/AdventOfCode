package p2

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

Range :: struct {
	start: u64,
	end:   u64,
}

part2 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	data_string := strings.clone_from_bytes(data)

	id_ranges: [dynamic]Range

	for range_str in strings.split_lines_iterator(&data_string) {
		start_str, _, end_str := strings.partition(range_str, "-")

		start, _ := strconv.parse_u64(start_str)

		if end_str == "" {
			break
		}

		end, _ := strconv.parse_u64(end_str)

		for &check_range in id_ranges {
			if check_range.start <= start && start <= check_range.end {
				start = check_range.end + 1
			} else if check_range.start <= end && end <= check_range.end {
				end = check_range.start - 1
			} else if start <= check_range.start && end >= check_range.end {
				check_range.start = start + 1
				check_range.end = start
			}
		}

		if start <= end {
			append(&id_ranges, Range{start, end})
		}
	}

	total_fresh: u64 = 0

	for range in id_ranges {
		total_fresh += range.end - range.start + 1
	}

	fmt.println(total_fresh)
}
