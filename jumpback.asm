lw $2, 0($0)

j 24
sw $2, 0($0)

j 24
sw $2, 4($0)


j 1000
# method start
# multiplies the value on $2 by 4
# $2 -> 4 * $2
sll $2, $2, 2
jb 
