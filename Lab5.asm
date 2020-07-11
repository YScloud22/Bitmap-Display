#########################################################################################################################################################
# Created by:   Shi, Yingkit
#               yshi81
#               5 June 2020
#
# Assingment:   Lab 5: Functions and Graphics
#	        CSE 12: Computer Systems and Assmebly Language 
#	        UC Santa Cruz, Spring 2020
#
# Description:  This program will use functions to perform graphics operations on a small simulated display (Bitmap Display).
#
# Notes:        This program is intended to be run from the MARS IDE.
#########################################################################################################################################################

#Pseudocode: 
#Given a color, will fill the bitmap display with that color.
#Given a coordinate in $a0
#sets corresponding value
#in memory to the color given by $a1
#Given a coordinate, returns the color of that pixel
#iterate through the square points
#if the point lies inside the circle 
#plot the circle using the Bresenham's circle drawing algorithm
## Macro that stores the value in %reg on the stack and moves the stack pointer
##Macro takes the value on the top of the stack and loads it into %reg then moves the stack pointer
##Macro that takes as input coordinates in the format(0x00XX00YY)
##returns 0x000000XX in %x and returns 0x000000YY in %y
##takes Coordinates in (%x,%y) where %x = 0x000000XX and %y= 0x000000YY and returns %output = (0x00XX00YY)
##bitmap: Loop for Loop if [128 x 128] grid is not Colored
##Draw pixel: Create Address from given hex value(which was converted to x and y)
##add the calculated value of $t1 to Base Address of display
##Get pixel: Create Address from given hex value(which was converted to x and y)
## add the calculated value of $t1 to Base Address of display
##$v0 is the color of pixel
##solid circle: $t1 = xc, $t2 = yc (Output Values from getCoordinates Macro) 
##Save S registers to stack
##Conditions are Exit Loop if (i <= xmax) is false and Exit Loop if (j <= ymax) is false
##draw circle: #$t1 = x, $t2 = y (Output Values from getCoordinates Macro) and save S registers to stack
##while (y >= x), Exit Loop if (y >= x) is false
##if (d > 0)  { y=y-1;  d = d + 4 * (x - y) + 10;}
##Else  { d = d + 4 * x + 6;}
##outloop34 to get S registers from stack
##circle pixela: $t1 = xc, $t2 = yc (Output Values from getCoordinates Macro)
##save S registers to stack
##$a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
##Perform draw_pixel(xc+x, yc+y),(xc-x, yc+y),(xc+x, yc-y),(xc-x, yc-y),(xc+y, yc+x),(xc-y, yc+x),(xc+y, yc-x)


# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)
	and %x, %input, 0x000000FF		# Extract value of register X(%x) by performing and operation of Intput register(%intput) and value 0x000000FF
	srl %y, %input, 16			# Extract value of register Y(%y) by shifting value of intput register(%intput) by 16 bits to right
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
	add %output, %x, $0			# add value of x to the Output register(%output) to make its value 0x000000XX
	sll %output, %output, 16		# shift value of output register(%output) by 16 bits to left to make it 0x00XX0000 
	add %output, %output, %y		# add value of y to the Output register(%output) to make its value 0x00XX00YY
.end_macro 


.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
clear_bitmap: nop	
	
	li $t0,16384		# Loop limit 16384 (128 x 128)
	li $t1, 0XFFFF0000	# $t1 = Base Address for Display
	
    Loop1: nop
        
        beq $t0,0,OutLoop1	# Exit Loop if [128 x 128] grid is Colored
        nop			# nop added after branch Instruction 
        
        sw $a0, 0($t1)		# Store Color to the Bitmap display
        sub $t0, $t0, 1		# Decrement Loop Counter
        addi $t1, $t1, 4	# Get Next Pixel Address in $t1
        
        b Loop1
    
    OutLoop1:
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************  
draw_pixel: nop
	push($ra)
	
	getCoordinates($a0 $t1 $t2)	#$t1 = x, $t2 = y (Output Values from getCoordinates Macro) 
	
	# Creating Address from given hex value(which was converted to x and y)
	li $t3, 0XFFFF0000	# $t3 = Base Address for Display
	
	mul $t1, $t1, 128	# Multiply max row number(128) with X Coordinate value and save in $t1
	add $t1 ,$t1, $t2	# add column number to the calculated value of $t2
	
	mul $t1, $t1, 4		# convert the calculated value of $t1 to word address.
	
	add $a0, $t3, $t1	# add the calculated value of $t1 to Base Address of display
	
	sw $a1, 0($a0)		# Store Color to the Bitmap display to Given coordinate of pixel 
        
        pop($ra)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	push($ra)
	
	getCoordinates($a0 $t1 $t2)	#$t1 = x, $t2 = y (Output Values from getCoordinates Macro) 
	
	# Creating Address from given hex value(which was converted to x and y)
	li $t3, 0XFFFF0000	# $t3 = Base Address for Display
	
	mul $t1, $t1, 128	# Multiply max row number(128) with X Coordinate value and save in $t1
	add $t1 ,$t1, $t2	# add column number to the calculated value of $t2
	
	mul $t1, $t1, 4		# convert the calculated value of $t1 to word address.
	
	add $a0, $t3, $t1	# add the calculated value of $t1 to Base Address of display
	
	lw $v0, 0($a0)		# Load Color of pixel from the Given Bitmap pixel Address in $v0 register
	
	pop($ra)
	jr $ra

#***********************************************
# draw_solid_circle:
#  Considering a square arround the circle to be drawn  
#  iterate through the square points and if the point 
#  lies inside the circle (x - xc)^2 + (y - yc)^2 = r^2
#  then plot it.
#-----------------------------------------------------
# draw_solid_circle(int xc, int yc, int r) 
#    xmin = xc-r
#    xmax = xc+r
#    ymin = yc-r
#    ymax = yc+r
#    for (i = xmin; i <= xmax; i++) 
#        for (j = ymin; j <= ymax; j++) 
#            a = (i - xc)*(i - xc) + (j - yc)*(j - yc)	 
#            if (a < r*r ) 
#                draw_pixel(x,y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_solid_circle: nop
	
	push($ra)
	
	getCoordinates($a0 $t1 $t2)	#$t1 = xc, $t2 = yc (Output Values from getCoordinates Macro) 

	push($s1)			# Save S registers in stack
	push($s2)
	push($s3)
	
	sub $t3, $t1, $a1		#    xmin($t3) = xc-r
	add $t4, $t1, $a1		#    xmax($t4) = xc+r
	sub $t5, $t2, $a1		#    ymin($t5) = yc-r
	add $t6, $t2, $a1		#    ymax($t6) = yc+r
	
	move $s1, $t3			#    i($s1) = xmin;

    Loop2: nop				#    for (i = xmin; i <= xmax; i++)
        
        bgt $s1, $t4, OutLoop2		#    Exit Loop if (i <= xmax) is false
        nop				#    nop added after branch Instruction 
        
        move $s2, $t5			#    j($s2) = ymin;
        
    Loop3: nop				#    for (j = ymin; j <= ymax; j++) 
        
        bgt $s2, $t6, OutLoop3		#    Exit Loop if (j <= ymax) is false
        nop				#    nop added after branch Instruction 
        
        # Calculating value of a($t7) = (i - xc)*(i - xc) + (j - yc)*(j - yc)
        sub $s3, $s1, $t1		# $s3 = (i - xc)
        mul $t7, $s3, $s3		# $t7 = (i - xc)*(i - xc)
        
        sub $s3, $s2, $t2		# $s3 = (j - yc)
        mul $s3, $s3, $s3		# $s3 = (j - yc)*(j - yc)
        
        add $t7, $t7, $s3		# a($t7) = (i - xc)*(i - xc) + (j - yc)*(j - yc)
        
        mul $s3, $a1, $a1		# $s3 = r*r
        
        bge $t7, $s3, Next1		#            if (a < r*r ) { draw_pixel(x,y)} 	
        nop
        
        # Perform draw_pixel(x,y)
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        push($t3)
                
        formatCoordinates($a0 $s1 $s2)
        move $a1,$a2
        jal draw_pixel
        
        pop($t3)
        pop($t2)
        pop($t1)
        pop($a1)
        pop($a0)
          
    Next1:
        add $s2, $s2, 1			# Increment Loop Counter (j++)
        
        b Loop3
    
    OutLoop3:    
        add $s1, $s1, 1			# Increment Loop Counter (i++)
        
        b Loop2
    
    OutLoop2:
    	
    	pop($s3)			# Get S registers from stack
        pop($s2)
        pop($s1)
    	
    	pop($ra)
	jr $ra
		
#***********************************************
# draw_circle:
#  Given the coordinates of the center of the circle
#  plot the circle using the Bresenham's circle 
#  drawing algorithm 	
#-----------------------------------------------------
# draw_circle(xc, yc, r) 
#    x = 0 
#    y = r 
#    d = 3 - 2 * r 
#    draw_circle_pixels(xc, yc, x, y) 
#    while (y >= x) 
#        x=x+1 
#        if (d > 0) 
#            y=y-1  
#            d = d + 4 * (x - y) + 10 
#        else
#            d = d + 4 * x + 6 
#        draw_circle_pixels(xc, yc, x, y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of the circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color of line in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_circle: nop

	push($ra)
	
	getCoordinates($a0 $t1 $t2)	#$t1 = x, $t2 = y (Output Values from getCoordinates Macro) 
	
	push($s3)			# Save S registers in stack
	
	li $t3, 0			#    x = 0 
	move $t4, $a1			#    y = r 
	li $t5, 3			#    d = 3 
	mul $s3, $a1, 2			#    $s3 = 2 * r
        sub $t5, $t5, $s3		#    d = 3 - 2 * r
        
        # Perform draw_circle_pixels(xc, yc, x, y)
        push($a0)
        push($a1)
        push($a2)
        push($t1)
        push($t2)
        push($t3)
                
        
        move $a1,$a2
        move $a2,$t3
        move $a3,$t4
        jal draw_circle_pixels
        
        pop($t3)
        pop($t2)
        pop($t1)
        pop($a2)
        pop($a1)
        pop($a0)
        
       	
    Loop4: nop				#    while (y >= x) 
        
        blt $t4, $t3, OutLoop4		#    Exit Loop if (y >= x) is false
        nop				#    nop added after branch Instruction 
  	
  	add $t3, $t3, 1			#    x = x + 1 
        
        ble $t5, 0, Else		#    if (d > 0)  { y=y-1;  d = d + 4 * (x - y) + 10;}
        nop
        
        sub $t4, $t4, 1			#    y = y - 1 
        
        sub $s3, $t3, $t4		#    $s3 = (x - y)
        mul $s3, $s3, 4			#    $s3 = 4 * (x - y)
        add $t5, $t5, $s3		#    d = d + 4 * (x - y)
        add $t5, $t5, 10		#    d = d + 4 * (x - y) + 10
        
        
        b Next2
        
    Else:				#    Else  { d = d + 4 * x + 6;}
        
        mul $s3, $t3, 4			#    $s3 = 4 * x
        add $t5, $t5, $s3		#    d = d + 4 * x
        add $t5, $t5, 6			#    d = d + 4 * x + 6; 
              
    Next2:
        # Perform draw_circle_pixels(xc, yc, x, y)
        push($a0)
        push($a1)
        push($a2)
        push($t1)
        push($t2)
        push($t3)
                
        
        move $a1,$a2
        move $a2,$t3
        move $a3,$t4
        jal draw_circle_pixels
        
        pop($t3)
        pop($t2)
        pop($t1)
        pop($a2)
        pop($a1)
        pop($a0)
        
        b Loop4  
    
    OutLoop4:
    	pop($s3)			# Get S registers from stack
        
    	pop($ra)
	jr $ra
	
#*****************************************************
# draw_circle_pixels:
#  Function to draw the circle pixels 
#  using the octans' symmetry
#-----------------------------------------------------
# draw_circle_pixels(xc, yc, x, y)  
#    draw_pixel(xc+x, yc+y) 
#    draw_pixel(xc-x, yc+y)
#    draw_pixel(xc+x, yc-y)
#    draw_pixel(xc-x, yc-y)
#    draw_pixel(xc+y, yc+x)
#    draw_pixel(xc-y, yc+x)
#    draw_pixel(xc+y, yc-x)
#    draw_pixel(xc-y, yc-x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#    $a2 = current x value from the Bresenham's circle algorithm
#    $a3 = current y value from the Bresenham's circle algorithm
#   Outputs:
#    No register outputs	
#*****************************************************
draw_circle_pixels: nop
	push($ra)
	getCoordinates($a0 $t1 $t2)	#$t1 = xc, $t2 = yc (Output Values from getCoordinates Macro) 
	
	push($s1)			# Save S registers in stack
	push($s2)
	
	# Perform draw_pixel(xc+x, yc+y) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        add $s1, $t1, $a2                
        add $s2, $t2, $a3
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc-x, yc+y) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        sub $s1, $t1, $a2                
        add $s2, $a3, $t2
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc+x, yc-y) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        add $s1, $t1, $a2                
        sub $s2, $t2, $a3
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc-x, yc-y) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        sub $s1, $t1, $a2                
        sub $s2, $t2, $a3
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc+y, yc+x) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        add $s1, $t1, $a3                
        add $s2, $t2, $a2
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc-y, yc+x) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        sub $s1, $t1, $a3                
        add $s2, $t2, $a2
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc+y, yc-x) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        add $s1, $t1, $a3                
        sub $s2, $t2, $a2
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	# Perform draw_pixel(xc-y, yc-x) 
        push($a0)
        push($a1)
        push($t1)
        push($t2)
        
        sub $s1, $t1, $a3                
        sub $s2, $t2, $a2
        formatCoordinates($a0 $s1 $s2)	# $a0 = 0x00XX00YY(Output Values from formatCoordinates Macro)
        jal draw_pixel
        
        pop($t2)
        pop($t1)
	pop($a1)
        pop($a0)
	
	pop($s2)			# Get S registers from stack
        pop($s1)
        
        
	pop($ra)
	jr $ra
