package p1

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:slice"

part1 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	joltage_sum := 0

	for battery_bank in bytes.split_iterator(&data, {'\n'}) {
		digit_index_1, _ := slice.max_index(battery_bank[:len(battery_bank) - 1])
		digit_index_2, _ := slice.max_index(battery_bank[digit_index_1 + 1:])
		digit_index_2 += digit_index_1 + 1

		// fmt.println(rune(battery_bank[digit_index_1]), rune(battery_bank[digit_index_2]))

		joltage_sum += int(battery_bank[digit_index_1] - '0') * 10
		joltage_sum += int(battery_bank[digit_index_2] - '0')
	}

	fmt.println(joltage_sum)
}
