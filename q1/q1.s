.global make_node
make_node:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd s0, 8(sp)

    mv s0, a0            # save val before malloc overwrites a0
    li a0, 24            # sizeof(Node) = int + padding + 2 pointers
    call malloc

    sw s0, 0(a0)         # node->val = val
    sd zero, 8(a0)       # node->left = NULL
    sd zero, 16(a0)      # node->right = NULL

    ld s0, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret


.global insert
insert:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd s0, 8(sp)
    sd s1, 0(sp)

    mv s0, a0            # s0 = root
    mv s1, a1            # s1 = val

    beqz s0, make_new    # if root == NULL, create new node

    lw t0, 0(s0)         # t0 = root->val
    blt s1, t0, go_left  # if val < root->val, go left
    bgt s1, t0, go_right # if val > root->val, go right
    j insert_done        # if equal, duplicate so just return root

make_new:
    mv a0, s1
    call make_node       # allocate new node, returned in a0
    j insert_return      # skip mv a0, s0 or we return NULL instead of new node

go_left:
    ld a0, 8(s0)         # a0 = root->left
    mv a1, s1
    call insert
    sd a0, 8(s0)         # root->left = result
    j insert_done

go_right:
    ld a0, 16(s0)        # a0 = root->right
    mv a1, s1
    call insert
    sd a0, 16(s0)        # root->right = result

insert_done:
    mv a0, s0            # return root

insert_return:
    ld s1, 0(sp)
    ld s0, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret


.global get
get:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd s0, 8(sp)
    sd s1, 0(sp)

    mv s0, a0            # s0 = root
    mv s1, a1            # s1 = val

    beqz s0, get_null    # if root == NULL, return NULL

    lw t0, 0(s0)         # t0 = root->val
    beq s1, t0, get_found
    blt s1, t0, get_left # if val < root->val, go left
    j get_right          # else go right

get_null:
    li a0, 0             # return NULL
    j get_done

get_found:
    mv a0, s0            # return pointer to this node
    j get_done

get_left:
    ld a0, 8(s0)         # a0 = root->left
    mv a1, s1
    call get
    j get_done

get_right:
    ld a0, 16(s0)        # a0 = root->right
    mv a1, s1
    call get

get_done:
    ld s1, 0(sp)
    ld s0, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret


.global getAtMost
# int getAtMost(int val, struct Node* root)
getAtMost:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd s0, 8(sp)
    sd s1, 0(sp)

    mv s0, a0            # s0 = val (upper bound)
    mv s1, a1            # s1 = root

    beqz s1, gam_null    # if root == NULL, return -1

    lw t0, 0(s1)         # t0 = root->val
    beq s0, t0, gam_found
    blt s0, t0, gam_left # if val < root->val, answer must be in left subtree
    j gam_right          # else root->val is a candidate, but right might be closer

gam_null:
    li a0, -1            # return -1
    j gam_done

gam_found:
    mv a0, s0            # exact match, return val
    j gam_done

gam_left:
    mv a0, s0            # a0 = val
    ld a1, 8(s1)         # a1 = root->left
    call getAtMost
    j gam_done

gam_right:
    mv a0, s0
    ld a1, 16(s1)        # a1 = root->right
    call getAtMost

    li t0, -1
    bne a0, t0, gam_done # right subtree found something, return it
    lw a0, 0(s1)         # right had nothing <= val, fall back to root->val

gam_done:
    ld s1, 0(sp)
    ld s0, 8(sp)
    ld ra, 16(sp)
    addi sp, sp, 24
    ret