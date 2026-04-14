.globl main
.extern malloc
.extern atoi
.extern printf

.section .rodata
# Format string for space-separated integers
res_fmt: .string "%d "
newline: .string "\n"

.text
main:
    # 1. Setup stack frame (64 bytes, 16-byte aligned)
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)   # n (number of elements)
    sd s1, 40(sp)   # arr pointer
    sd s2, 32(sp)   # res pointer
    sd s3, 24(sp)   # stack pointer
    sd s4, 16(sp)   # top (stack index)
    sd s5, 8(sp)    # i (loop counter)
    sd s6, 0(sp)    # argv storage

    # 2. Handle Arguments
    addi s0, a0, -1      # s0 = argc - 1
    li t0, 1
    blt s0, t0, exit_all # Exit if no numbers provided
    
    mv s6, a1            # CRITICAL: Save argv in s6 to survive malloc

    # Allocate memory for input array, result array, and stack
    slli a0, s0, 2
    call malloc
    mv s1, a0

    slli a0, s0, 2
    call malloc
    mv s2, a0

    slli a0, s0, 2
    call malloc
    mv s3, a0

    # 3. Convert argv strings to integers
    li s5, 0
load_loop:
    bge s5, s0, start_logic
    
    addi t0, s5, 1
    slli t0, t0, 3       # 8-byte offset for argv pointers
    add t0, s6, t0
    ld a0, 0(t0)         # Load string pointer
    
    call atoi            
    
    slli t1, s5, 2
    add t1, s1, t1
    sw a0, 0(t1)         # Store in arr[i]
    
    addi s5, s5, 1
    j load_loop

# 4. Monotonic Stack Logic O(n)
start_logic:
    li s4, -1            # stack top = -1
    addi s5, s0, -1      # i = n - 1 (iterate backwards)

main_algo:
    blt s5, zero, print_results

pop_while:
    blt s4, zero, pop_done 

    # Compare arr[stack[top]] with arr[i]
    slli t0, s4, 2
    add t0, s3, t0
    lw t1, 0(t0)         # t1 = index from stack
    
    slli t1, t1, 2
    add t1, s1, t1
    lw t2, 0(t1)         # t2 = value at stack[top]

    slli t3, s5, 2
    add t3, s1, t3
    lw t4, 0(t3)         # t4 = value at arr[i]

    # Stop popping if top is strictly greater [cite:64,69]
    bgt t2, t4, pop_done
    
    addi s4, s4, -1      # pop()
    j pop_while

pop_done:
    slli t0, s5, 2
    add t0, s2, t0       # Address of res[i]
    
    blt s4, zero, set_minus
    # res[i] = stack[top]
    slli t1, s4, 2
    add t1, s3, t1
    lw t2, 0(t1)
    sw t2, 0(t0)
    j push_curr

set_minus:
    li t1, -1            # No greater element found [cite:70,76]
    sw t1, 0(t0)

push_curr:
    addi s4, s4, 1       # push current index onto stack
    slli t0, s4, 2
    add t0, s3, t0
    sw s5, 0(t0)

    addi s5, s5, -1
    j main_algo

# 5. Output results
print_results:
    li s5, 0
out_loop:
    bge s5, s0, exit_all
    
    la a0, res_fmt
    slli t0, s5, 2
    add t0, s2, t0
    lw a1, 0(t0)
    call printf

    addi s5, s5, 1
    j out_loop

exit_all:
    la a0, newline
    call printf

    # Restore and Return
    ld s6, 0(sp)
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret