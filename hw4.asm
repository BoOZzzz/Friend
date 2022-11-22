############## FULL NAME ##############
############## SBUID #################
############## NETID ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_person
create_person:
    
    move $t0, $a0	#store $a0 at $t0 
    lw $t1, 0($t0) 	#store max number of node
    lw $t2, 16($t0) 	#store current number of node
    bge $t2, $t1, full
    addi $t2, $t2, 1 	#increment current node by 1
    sw $t2, 16($t0) 	#save number of current nodes
    addi $t0, $t0, 36 	#increment to the address of nodes
    li $t1, 0		#initialize counter
    li $t2, 15
    initialize:
    beq $t1, $t2, initialized
    sw $zero, 0($t0)	#filling 0's into the nodes
    addi $t0, $t0, 4	#increment pointer address
    addi $t1, $t1, 1	#increment counter
    j initialize
    
    initialized:
    addi $t0, $t0, -96
    lw $t2, 8($t0) 
    lw $t1, 16($t0)
    addi $t1, $t1, -1
    mul $t1, $t1, $t2
    addi $t0, $t0, 36
    add $t0, $t0, $t1
    move $v0, $t0		
    j done1
    
    
    full:
    li $v0, -1
    j done1
    
    
  
  done1:  
  jr $ra

.globl is_person_exists
is_person_exists:
    move $t0, $a0	#save network address
    move $t1, $a1	#save node address
    lw $t3, 8($t0)
    lw $t4, 16($t0)
    addi $t0, $t0, 36
    beqz $t1, person_not_exists
    
    verify_person:
    beq $t0, $t1, person_exists
    add $t0, $t0, $t3
    addi $t4, $t4, -1
    bgtz $t4, verify_person
    
    person_not_exists:
    li $v0, 0
    j done2
    
    person_exists:
    li $v0, 1
    j done2
    
    
    
  done2:
  jr $ra

.globl is_person_name_exists
is_person_name_exists:
    lw $t0, 16($a0)		#load total names
    lw $t1, 8($a0)		#load name size
    mul $t0, $t1, $t0
    addi $a0, $a0, 36		#offset to node addr
    li $t6, 0
    move $t5, $a1
    find_length:
    lb $t2, 0($t5)
    beqz $t2, verify_name_exists
    addi $t6, $t6, 1
    addi $t5, $t5, 1
    j find_length

    

    verify_name_exists:
    beqz $t0, name_doesnt_exists
    move $t4, $a0		#save $a0
    move $t5, $a1		#save $a1
    move $t7, $t6		#use $t7 to count length
    verify_name:	
    lb $t2, 0($a0)		#load bytes of $a0	
    lb $t3, 0($a1)		#load bytes of $a1
    beqz $t2, next_person
    bne $t3, $t2, next_person	#if not equal branch to next person
    addi $t7, $t7, -1		#if equal length -1
    addi $a0, $a0, 1		#increment pointer of network addr by 1
    addi $a1, $a1, 1		#increment pointer of name addr by 1
    j verify_name
    
    next_person:
    move $a0, $t4		#load network addr
    move $a1, $t5		#load name addr
    add $a0, $a0, $t1		#increment network addr
    addi $t0, $t0, -1	
    beqz $t7, name_exists
    j verify_name_exists
    
    name_doesnt_exists:
    li $v0, 0
    j done3
    
    name_exists:
    bnez $t2, name_doesnt_exists
    sub $a0, $a0, $t1
    li $v0, 1
    move $v1, $a0
    j done3
    
  done3:  
  jr $ra

.globl add_person_property
add_person_property:
    lw $t0, 24($a0)	#load prop_name
    
    move $t2, $a2	#save prop name to $t2
    li $t1, 'N'
    lb $t3, 0($t2)
    bne $t3, $t1, error1
    li $t1, 'A'
    lb $t3, 1($t2)
    bne $t3, $t1, error1
    li $t1, 'M'
    lb $t3, 2($t2)
    bne $t3, $t1, error1
    li $t1, 'E'
    lb $t3, 3($t2)
    bne $t3, $t1, error1
    
    
    check_person:
    move $t9, $ra
    jal is_person_exists
    move $ra, $t9
    beqz $v0, error2
    
    check_num_char:
    lw $t5, 8($a0)
    li $t1, 0
    find_length_prop_val:
    lb $t3, 0($a3)
    beqz $t3, cont_check_num
    addi $a3, $a3, 1
    addi $t1, $t1, 1
    j find_length_prop_val
    cont_check_num:
    sub $a3, $a3, $t1
    bge $t1, $t5, error3
    
    check_unique_val:
    move $t8, $a1
    move $a1, $a3
    move $t9, $ra
    jal is_person_name_exists
    move $ra, $t9
    bnez $v0, error4
    
    
    save_name:
    lb $t4, 0($a3)
    beqz $t4, success4
    sb $t4, 0($t8)
    addi $a3, $a3, 1
    addi $t8, $t8, 1
    j save_name
    
    
    
    
    error1:
    li $v0, 0
    j done4
    
    error2:
    li $v0, -1
    j done4
    
    error3:
    li $v0, -2
    j done4
    
    error4:
    li $v0, -3
    j done4
    
    success4:
    li $v0, 1
    j done4
    
  done4:
  jr $ra

.globl get_person
get_person:
    move $t9, $ra
    jal is_person_name_exists
    move $ra, $t9
    beqz $v0, person_dne
    move $v0, $v1
    j done5
    
    person_dne:
    li $v0, 0
    j done5

  done5:
  jr $ra

.globl is_relation_exists
is_relation_exists:
  move $t4, $a0
  lw $t0, 16($a0)	#load current nodes
  lw $t1, 8($a0) 	#load node size
  lw $t2, 12($a0)
  lw $t3, 20($a0)
  mul $t0, $t0, $t1	#find node list offset
  addi $a0, $a0, 36
  add $a0, $a0, $t0
  
  move $t0, $t2		#$t0 holds edge size, $t2 free
  check_relation:
  beqz $t3, relation_dne
  lw $t1, 0($a0)
  lw $t2, 4($a0)
  beq $t1, $a1, check_second
  beq $t1, $a2, check_first
  j increment
  
  check_second:
  beq $t2, $a2, relation_exists
  j increment
  
  check_first:
  beq $t2, $a1, relation_exists
  j increment
  
  increment:
  add $a0, $a0, $t0
  addi $t3, $t3, -1
  j check_relation
  
  
  
  relation_exists:
  li $v0, 1
  j done6
  
  relation_dne:
  li $v0, 0
  j done6
  
  done6:
  jr $ra

.globl add_relation
add_relation:
    move $t9, $ra
    jal is_person_exists
    move $ra, $t9
    beqz $v0, error7_1
    move $t8, $a1
    move $a1, $a2
    move $t9, $ra
    jal is_person_exists
    move $ra, $t9
    beqz $v0, error7_1
    
    check_edges:
    lw $t0, 4($a0)
    lw $t1, 20($a0)
    beq $t0, $t1, error7_2
    
    check_relation_exists:
    move $a1, $t8
    move $t8, $a0
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    bnez $v0, error7_3
    
    check_same_person:
    beq $a1, $a2, error7_4
    move $a0, $t8
    lw $t0, 16($a0)		#load current nodes
    lw $t1, 8($a0) 		#load node size
    lw $t2, 12($a0)
    lw $t3, 20($a0)
    mul $t0, $t0, $t1		#find node list offset
    addi $a0, $a0, 36
    add $a0, $a0, $t0
    mul $t2, $t2, $t3
    add $a0, $t2, $a0
    sw $a1, 0($a0)
    sw $a2, 4($a0)
    addi $t3, $t3, 1
    move $a0, $t4
    sw $t3, 20($a0)

    j success7
    
    success7:
    li $v0, 1
    j done7
    
    
    
    error7_1:
    li $v0, 0
    j done7
    
    error7_2:
    li $v0, -1
    j done7
    
    error7_3:
    li $v0, -2
    j done7
    
    error7_4:
    li $v0, -3
    j done7
    
  done7:
  jr $ra

.globl add_relation_property
add_relation_property:
    move $t0, $a3	
    li $t1, 'F'
    lb $t2, 0($t0)
    bne $t2, $t1, error8_2
    li $t1, 'R'
    lb $t2, 1($t0)
    bne $t2, $t1, error8_2
    li $t1, 'I'
    lb $t2, 2($t0)
    bne $t2, $t1, error8_2
    li $t1, 'E'
    lb $t2, 3($t0)
    bne $t2, $t1, error8_2
    li $t1, 'N'
    lb $t2, 4($t0)
    bne $t2, $t1, error8_2
    li $t1, 'D'
    lb $t2, 5($t0)
    bne $t2, $t1, error8_2
    
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    beqz $v0, error8_1
    
    li $t0, 1
    sw $t0, 8($a0)
    li $v0, 1
    j done8
    
    
    error8_1:
    li $v0, 0
    j done8
    
    
    error8_2:
    li $v0, -1
    j done8


 
  done8:
  jr $ra

.globl is_friend_of_friend
is_friend_of_friend:
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    

    move $s0, $a0
    move $s1, $a1 
    move $s2, $a2
    lw $s3, 4($s0)
    move $t9, $ra
    jal is_person_name_exists
    move $ra, $t9
    beqz $v0, dne
    
    move $t9, $ra
    move $a0, $s0
    move $a1, $s2
    jal is_person_name_exists
    move $ra, $t9
    beqz $v0, dne
    
    
    
    
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    lw $t0, 8($a0)
    bnez, $t0, not_fof
    
    
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $s3, $a0
    lw $t1, 0($s3)
    lw $t2, 8($s3)
    lw $s4, 20($s3)
    mul $t1, $t1, $t2
    addi $s3, $s3, 36
    add $s3, $s3, $t1
    
    check_edges_loop:
    beqz $s4, not_fof
    lw $t2, 0($s3)
    beq $t2, $a1, s1
    beq $t2, $a2, s2
    lw $t2, 4($s3)
    beq $t2, $a1, s3
    beq $t2, $a2, s4
    j next_edge
    
    s1:
    lw $t2, 4($s3)
    move $a2, $t2
    move $a0, $s0
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    beqz $v0, next_edge
    li $t0, 1
    lw $t1, 8($a0)
    beq $t0, $t1, fof
    j next_edge
    
    s2:
    lw $t2, 4($s3)
    move $a1, $t2
    move $a0, $s0
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    beqz $v0, next_edge
    li $t0, 1
    lw $t1, 8($a0)
    beq $t0, $t1, fof
    j next_edge
    
    s3:
    lw $t2, 4($s3)
    move $a2, $t2
    move $a0, $s0
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    beqz $v0, next_edge
    li $t0, 1
    lw $t1, 8($a0)
    beq $t0, $t1, fof
    j next_edge
    
    s4:
    lw $t2, 4($s3)
    move $a0, $s0
    move $a1, $t2
    move $t9, $ra
    jal is_relation_exists
    move $ra, $t9
    beqz $v0, next_edge
    li $t0, 1
    lw $t1, 8($a0)
    beq $t0, $t1, fof
    j next_edge
    
    next_edge:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    addi $s3, $s3, 12
    addi $s4, $s4, -1
    j check_edges_loop
    
    

    
    fof:
    li $v0, 1
    j done9
    
    
    dne:
    li $v0, -1
    j done9
    
    not_fof:
    li $v0, 0
    j done9



  done9:
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)
  lw $s4, 16($sp)
  lw $s5, 20($sp)
  addi $sp, $sp, 24
  jr $ra
