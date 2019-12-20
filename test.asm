# Define vector a[0..3] as [5, 7, -2, 40]
# Define vector b[0..3] as [65, -23, 17, 1024]
# Define vector c[0..3] as [0, 0, 0, 0]
# Initialize sum = 0
#
# While i <- 0 to 3
#   c[i] = 2 * (a[i] + b[i]) i=i+1
# End While

# base addresses
# a -> $1
# b -> $2
# c -> $3

# sum -> $10

# i -> $15

sub $1, $1, $1 # $1 = 0
sub $2, $2, $2
sub $3, $3, $3

addi $2, $2, 16
addi $3, $3, 32

sub $10, $10, $10 # init $10 to zero

addi $13, $0, 4
beq $15, $13, 1000 # branch if i == 4

sll $14, $15, 2 # 14 = 4 * i
add $4, $1, $14 # 4 -> a[i]'s address
add $5, $2, $14 # 5 -> b[i]'s address
add $6, $3, $14 # 6 -> c[i]'s address

lw $4, 0($4) # 4 -> a[i]
lw $5, 0($5) # 5 -> b[i]

add $7, $4, $5 # 4 -> a[i] + b[i]
sll $7, $7, 1

sw $7, 0($6)

addi $15, $15, 1

j 4
