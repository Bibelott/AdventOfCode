package p1

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:time"

parse_u64 :: proc(value: []byte) -> (result: u64) {
	result = 0
	for c in value {
		result *= 10
		result += u64(c - '0')
	}
	return
}

part1 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	plus_array: [dynamic]u64
	times_array: [dynamic]u64

	total: u64 = 0

	i := 0

	operator: i8 = 0

	line: []byte

	number_loop: for line_iter in bytes.split_iterator(&data, {'\n'}) {
		line = line_iter
		i = 0
		for number_str in bytes.split_iterator(&line, {' '}) {
			if len(number_str) == 0 {
				continue
			}
			if number_str[0] == '+' {
				operator = 0
				break number_loop
			} else if number_str[0] == '*' {
				operator = 1
				break number_loop
			}

			number := parse_u64(number_str)

			if len(plus_array) <= i || len(times_array) <= i {
				append(&plus_array, number)
				append(&times_array, number)
			} else {
				plus_array[i] += number
				times_array[i] *= number
			}
			i += 1
		}
	}

	i = 0
	data_index := 1

	for operator != -1 {
		defer i += 1

		if operator == 0 {
			total += plus_array[i]
		} else {
			total += times_array[i]
		}

		operator_index := bytes.index_any(line[data_index:], {'+', '*'})

		if operator_index == -1 {
			break
		}

		operator_index += data_index

		data_index = operator_index + 1

		if line[operator_index] == '+' {
			operator = 0
		} else if line[operator_index] == '*' {
			operator = 1
		} else {
			operator = -1
		}
	}

	fmt.println(total)
}
