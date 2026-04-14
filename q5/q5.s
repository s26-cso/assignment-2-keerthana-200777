.data
filename: .asciz "input.txt"
msg_yes:  .asciz "Yes\n"
msg_no:   .asciz "No\n"

.text
.globl main
main:
    addi sp, sp, -16         # reserve some stack space to store two characters

    # open the file in read-only mode
    li a0, -100              # current directory
    la a1, filename          # file name
    li a2, 0                 # read only
    li a7, 56
    ecall
    bltz a0, exit            # if file cannot be opened, exit
    mv s0, a0                # save file descriptor

    # move to end of file to get file size
    mv a0, s0
    li a1, 0
    li a2, 2                 # SEEK_END
    li a7, 62
    ecall
    mv s1, a0                # s1 stores file size (right pointer)

    # if file has 0 or 1 characters, it is automatically a palindrome
    li t0, 1
    ble s1, t0, is_yes

    # move right pointer to last character
    addi s1, s1, -1

    # check if last character is newline
    mv a0, s0
    mv a1, s1
    li a2, 0
    li a7, 62
    ecall

    # read last character
    mv a0, s0
    mv a1, sp
    li a2, 1
    li a7, 63
    ecall

    lb t1, 0(sp)
    li t2, 10                # newline character

    # if last character is newline, ignore it
    bne t1, t2, setup
    addi s1, s1, -1

setup:
    li s2, 0                 # left pointer starts from beginning

loop:
    # if pointers meet or cross, string is palindrome
    bge s2, s1, is_yes

    # move to left position
    mv a0, s0
    mv a1, s2
    li a2, 0
    li a7, 62
    ecall

    # read left character
    mv a0, s0
    mv a1, sp
    li a2, 1
    li a7, 63
    ecall

    # move to right position
    mv a0, s0
    mv a1, s1
    li a2, 0
    li a7, 62
    ecall

    # read right character
    mv a0, s0
    addi a1, sp, 1
    li a2, 1
    li a7, 63
    ecall

    lb t1, 0(sp)
    lb t2, 1(sp)

    # if characters are different, not a palindrome
    bne t1, t2, is_no

    # move pointers inward
    addi s2, s2, 1
    addi s1, s1, -1
    j loop

is_yes:
    # print Yes
    li a0, 1
    la a1, msg_yes
    li a2, 4
    li a7, 64
    ecall
    j cleanup

is_no:
    # print No
    li a0, 1
    la a1, msg_no
    li a2, 3
    li a7, 64
    ecall

cleanup:
    # close the file
    mv a0, s0
    li a7, 57
    ecall

exit:
    # restore stack and exit program
    addi sp, sp, 16
    li a0, 0
    li a7, 93
    ecall