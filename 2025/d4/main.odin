package main

import "core:fmt"
import "core:time"

import "p1"
import "p1_cuda"
import "p2"

main :: proc() {
	timer_start := time.now()
	fmt.println("Part 1:")
	p1.part1()
	fmt.println("Time:", time.since(timer_start))

	fmt.println()

	timer_start = time.now()
	fmt.println("Part 1 - CUDA Solution:")
	p1_cuda.part1_cuda()
	fmt.println("Time:", time.since(timer_start))

	fmt.println()

	timer_start = time.now()
	fmt.println("Part 2:")
	p2.part2()
	fmt.println("Time:", time.since(timer_start))
}
