package p1_llrb

import "core:bytes"
import "core:fmt"
import "core:os"

LLRB_Color :: enum {
	BLACK,
	RED,
}

LLRB_Node :: struct {
	value: u64,
	index: u32,
	left:  ^LLRB_Node,
	right: ^LLRB_Node,
	color: LLRB_Color,
}

flip_color :: proc(node: ^LLRB_Node) {
	switch node.color {
	case .RED:
		node.color = .BLACK
	case .BLACK:
		node.color = .RED
	}
}

is_node_red :: proc(node: ^LLRB_Node) -> bool {
	return node != nil && node.color == .RED
}

llrb_rotate_left :: proc(node: ^LLRB_Node) -> ^LLRB_Node {
	target := node.right
	node.right = target.left
	target.left = node
	target.color = node.color
	node.color = .RED
	return target
}

llrb_rotate_right :: proc(node: ^LLRB_Node) -> ^LLRB_Node {
	target := node.left
	node.left = target.right
	target.right = node
	target.color = node.color
	node.color = .RED
	return target
}

llrb_flip_colors :: proc(node: ^LLRB_Node) {
	flip_color(node)
	flip_color(node.left)
	flip_color(node.right)
}

new_llrb_node :: proc(value: u64) -> (node: ^LLRB_Node) {
	node = new(LLRB_Node)
	node.value = value
	node.index = 0xFFFFFFFF
	node.color = .RED
	return
}

llrb_insert :: proc(node: ^LLRB_Node, value: u64) -> ^LLRB_Node {
	node := node

	if node == nil {
		return new_llrb_node(value)
	}

	if (is_node_red(node.left) && is_node_red(node.right)) {
		llrb_flip_colors(node)
	}

	if value < node.value {
		node.left = llrb_insert(node.left, value)
	} else if value > node.value {
		node.right = llrb_insert(node.right, value)
	}

	if (!is_node_red(node.left) && is_node_red(node.right)) {
		node = llrb_rotate_left(node)
	}
	if (is_node_red(node.left) && is_node_red(node.left.left)) {
		node = llrb_rotate_right(node)
	}

	return node
}

llrb_print_node :: proc(node: ^LLRB_Node) {
	if node != nil {
		llrb_print_node(node.left)
		fmt.print(node.value, "")
		llrb_print_node(node.right)
	}
}

llrb_count_and_index :: proc(node: ^LLRB_Node, next_index: u32) -> u32 {
	if node == nil {
		return 0
	}

	left_count := llrb_count_and_index(node.left, next_index)

	node.index = next_index + left_count

	right_count := llrb_count_and_index(node.right, next_index + left_count + 1)

	return left_count + right_count + 1
}

llrb_search_greater :: proc(node: ^LLRB_Node, value: u64) -> (index: u32, ok: bool) {
	if node == nil {
		index = 0xFFFFFFFF
		ok = false
	} else if value == node.value {
		index = node.index
		ok = true
	} else if value < node.value {
		index, ok = llrb_search_greater(node.left, value)
		if !ok {
			index = node.index
			ok = true
		}
	} else if value > node.value {
		index, ok = llrb_search_greater(node.right, value)
	}
	return
}

llrb_search_lesser :: proc(node: ^LLRB_Node, value: u64) -> (index: u32, ok: bool) {
	if node == nil {
		index = 0xFFFFFFFF
		ok = false
	} else if value == node.value {
		index = node.index
		ok = true
	} else if value < node.value {
		index, ok = llrb_search_lesser(node.left, value)
	} else if value > node.value {
		index, ok = llrb_search_lesser(node.right, value)
		if !ok {
			index = node.index
			ok = true
		}
	}
	return
}

Range :: struct {
	start: u64,
	end:   u64,
}

part1_llrb :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	sum: u64 = 0

	id_ranges: [dynamic]Range

	for range_str in bytes.split_iterator(&data, {'\n'}) {
		start_str, _, end_str := bytes.partition(range_str, {'-'})

		start := parse_u64(start_str)

		if len(end_str) == 0 {
			break
		}

		end := parse_u64(end_str)

		append(&id_ranges, Range{start, end})
	}

	llrb_root: ^LLRB_Node

	for id_str in bytes.split_iterator(&data, {'\n'}) {
		ingredient_id := parse_u64(id_str)

		llrb_root = llrb_insert(llrb_root, ingredient_id)
		llrb_root.color = .BLACK
	}

	node_count := llrb_count_and_index(llrb_root, 0)

	// llrb_print_node(llrb_root)
	// fmt.println()

	fresh_index := make([]i8, node_count)

	for range in id_ranges {
		id_start, ok_s := llrb_search_greater(llrb_root, range.start)
		id_end, ok_e := llrb_search_lesser(llrb_root, range.end)

		if !ok_s || !ok_e || id_end < id_start {
			continue
		}

		for id := id_start; id <= id_end; id += 1 {
			fresh_index[id] = 1
		}

		// fmt.println(id_start, id_end)
	}

	total_fresh := 0

	for is_fresh in fresh_index {
		total_fresh += int(is_fresh)
	}

	fmt.println(total_fresh)
}

parse_u64 :: proc(value: []byte) -> (result: u64) {
	result = 0
	for c in value {
		result *= 10
		result += u64(c - '0')
	}
	return
}
