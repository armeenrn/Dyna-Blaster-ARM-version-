// Armeen Rashidian
// Name: Armeen Rashidian
// Student ID: 3001 6331 
// CPSC 355, Project Part 2

// Assembly program of Bomberman game

// The file game.asm implements the game  



	.text
	
// Strings used to display symbols in the board	
doubleString:	.string	"   %2.2f   "
line:	.string	"\n"
starString:	.string	    "   *      "
rewardString:	.string	"   $      "		// Reward (each reward increments layer of tiles uncovered)
blowString:	.string		"   #      "		// Blows (each blow de-increments layer of tiles uncovered)
tileString:	.string	"   X      "
positiveString: .string "   +      "
negativeString: .string	"   -      "

// Strings used to ensure proper spacing 
sixSpaceString:	.string "%.2f    "
fiveSpaceString: .string " %.2f    "
fourSpaceString: .string "  %.2f    "

// Strings used to show ratios of different tiles
percentCharString:	.string "Percent special characters: %.2f%\n"
percentNegString:	.string "Percent negative floats: %.2f%\n"
percentPositiveString: .string "Percent positive floats: %.2f%\n"

// Strings displaying player stats 
livesString:	.string "\nLives: %d\n"
totalScoreString: .string "Total Score: %.2f\n"
bombsString: .string "Bombs: %d\n"
moveScoreMessage:	.string	"\nTotal uncovered score of %.2f points.\n"

// Strings used to get coordinates from user
askForCoorGeneral:	.string		"\nEnter %s coordinate of the tile you wish to bomb. Enter '-1' to quit game.\n"
xString:	.string	"x"
yString:	.string	"y"
inputString:	.string	"%s"
quitMessage:	.string	"\nYou quit the game.\n\n"

// Strings used for error messaging 
invalidInputMessage:	.string	"Invalid %s input. %d coordinate out of range.\n"
tileUsedErrorMessage:	.string	"Error. This tile has already exploded. Please select another tile.\n"


// Strings used to display acquiring of rewards and blows
rewardMessage:	.string	"You gained %d boosts.\n"
blowMessage:	.string "You gained %d blows.\n"
bombSingleTileMessage:	.string	"Next bomb range is 1 tile only.\n"
bombRegularMessage:	.string	"Next bomb range is of regular effect.\n"
bombEnhancedMessage:	.string	"Next bomb range is %d $ effect.\n"

// Strings used to display result of the game
wonMessage:	.string	"\nYou found the exit tile! Congratulations, you won!\n\n"
outOfBombsMessage:	.string "\nYou've lost. Out of bombs. Game over.\n\n"
outOfLivesMessage:	.string	"\nOut of lives. You've lost. Game over. \n\n"

// Strings used to display loss of a life
lostLifeMessage:	.string	"\nYou lost a life.\n"
resetMessage:	.string	"\nResetting total score...\n\n"




	
	.balign 4
	.global console


// Macros

define(fp, x29)
define(lr, x30)	
	

double_s = 8
int_s = 4


// console sets up the game, and allocates space in the stack for the boardGame and gameTiles array
//	args: x0 (N)
//		  x1 (M)
//	returns void 

console:
	stp		x29,	x30,	[sp, -48]!
	mov		x29,	sp	
	
	// Store arguments in register 
	mov		x20,	x1		// M
	mov		x21,	x2		// N
		
	// Allocate space on stack for the array of floats: boardGame
	mov		x10,	double_s
	mul		x9,		x20,	x21			// Number of tiles 
	mul		x9,		x9,		x10			// Space needed for boardgame
	sub		x9,		xzr,	x9			// Make negative to allocate space
	and		x9,		x9,		-16			// Padded byte	
	add		sp,		sp,		x9			// Allocate space on stack
	sub		x24,	fp,		8			// Base address of boardGame
	mov		x25,	x9					// Space allocated for boardGame
	
	// Allocate space on stack for the array of ints: gameTiles
	mov		x10,	int_s
	mul		x9,		x20,	x21
	mul		x9,		x9,		x10
	sub		x9,		xzr,	x9
	and		x9,		x9,		-16
	add		sp,		sp,		x9
	add		x26,	fp,		x25
	sub		x26,	x26,	4			// Base address of gameTiles
	mov		x27,	x9					// Space allocated for gameTiles
	
	// Calling initializeBoardGame
	mov		x0,		x20
	mov		x1,		x21
	mov		x2,		x24
	mov		x3,		x26
	bl		initializeGame 
	
	// Calling displayFloats
	mov		x0,		x20			// M
	mov		x1,		x21			// N
	mov		x2,		x24			// pointer to boardGame
	mov		x3,		x26			// pointer to gameTiles
	bl		displayFloats 
	
	// Initializing game variables 
	mov		x9,		0
	SCVTF	d19,	x9 			// Total score initialized to 0.0
	mov		x23,	0			// Quit initialized to 0 (if player quits, will be set to 1)
	str		d19,	[fp, 16]	// Total Score
	str		x23,	[fp, 24]	// Quit

	// Store start time to stack
	add		x0,		fp,		32	// Buffer to store start time
	bl		time
	
	// Calling play
	mov		x0,		x20			// M
	mov		x1,		x21			// N
	mov		x2,		x24			// Base address of boardGame
	mov		x3,		x26			// Base address of gameTiles
	add		x4,		fp,		16	// Address of total score
	add		x5,		fp,		24	// Address of quit
	bl		play	
	 
	// Store end time to stack
	add		x0,		fp,		40	// Buffer to store end time
	bl		time
	
	// Calculate duration of game in seconds
	ldr		x0,		[fp, 40]
	ldr		x1,		[fp, 32]
	bl		difftime
	
	// Store duration of game as global variable
	ldr		x0,		=finalDuration
	str		d0,		[x0]

	// Store final total score as global variable
	ldr		d0,		[fp, 16]
	ldr		x1,		=finalTotalScore
	str		d0,		[x1]
	
	// Store quit as global variable
	ldr		x0,		[fp, 24]
	ldr		x1,		=finalQuit
	str		x0,		[x1]
	
	
	// Deallocate space on stack for arrays
	sub		x27,	xzr,	x27
	add		sp,		sp,		x27
	
	sub		x25,	xzr,	x25
	add		sp,		sp,		x25
	
	// Terminate method
	ldp		x29,	x30,	[sp], 48
	ret
	





//	initializeGame sets up the board game. 
//	args:	x0:	M
//			x1: N
//			x2: Base address of boardGame, an array of doubles storing value or symbol of each tile
//			x3: Base address of gameTiles, an array of integers indicating whether each tile exploded or not
//	returns void

initializeGame:
	stp		x29,	x30,	[sp, -96]!
	mov		x29,	sp
	
	// Store callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]

	// Store arguments
	mov		x19,	x0				// M
	mov		x20,	x1				// N
	mov		x21,	x2				// Base address of board game
	mov		x22,	x3				// Base address of game tiles
	
	// Set up other variables 
	mov		x23,	0				// Iterator 
	mul		x24,	x19,	x20		// Number of tiles
	b		setFloatsToZero
	
// Initialize all floats in boardGame to 0.0	
setFloatsToZero:
	
	// Get 0.0
	mov		x0,		0
	mov		x1,		1
	bl		doubleDivision 
	
	// Store 0.0 in each element of the 2d array
	sub		x9,		xzr,	x23
	str		d0,		[x21, x9, lsl 3]
	add		x23,	x23,	1			// Increment iterator by 1
	
	// Test if iterator = Number of tiles
	cmp		x23,	x24
	b.lt	setFloatsToZero				
	b		Continue	

// Randomly determine type of each tile in boardGame (positive, negative, star or other character)	
Continue:		

	// Call setStarLocation
	mov		x0,		x19				// M
	mov		x1,		x20				// N
	mov		x2,		x21				// Base address of board game
	bl		setStarLocation
	
	// Call placeNegatives
	mov		x0,		x19				// M
	mov		x1,		x20				// N
	mov		x2,		x21				// Base address of board game	
	bl		placeNegatives
	
	// Call placeSpecials
	mov		x0,		x19				// M
	mov		x1,		x20				// N
	mov		x2,		x21				// Base address of board game	
	bl		placeSpecials
	
	
	mov		x25,	0				// set new iterator to 0
	b		initializeBoardGameTest
	

// Set each tile in boardGame to a float or symbol based on its current value
initializeBoardGameLoop:
	
	// Get value of each tile
	sub		x9,		xzr,	x25
	ldr		d9,		[x21, x9, lsl 3]
	
	// Get 1.00
	mov		x0,		1
	mov		x1,		1
	bl		doubleDivision 
	
	// If value of tile = 1.00, then this becomes a negative float
	fcmp	d9,		d0
	b.eq	setNegativeFloat
	
	// Get 19.00
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision 
	
	// If value of tile = 19.00, then this becomes the exit tile
	fcmp	d9,		d0
	b.eq	setStar
	
	// Get 2.00
	mov		x0,		2
	mov		x1,		1
	bl		doubleDivision 
	
	// If value of tile = 2.00, then this tile becomes a special character (excluding exit tile)
	fcmp	d9,		d0
	b.eq	setSpecial
	
	// Otherwise, if tile = 0.00, this tile becomes a positive float
	b		setPositiveFloat

// Set 19.00 to tile to represent exit tile
setStar:
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision 

	str		d0,		[x21, x9, lsl 3]
	add		x25,	x25,	1
	b		initializeBoardGameTest

// 	Set tile to a special character
setSpecial:
	bl		initializeCharacter
	sub		x9,		xzr,	x25
	str		d0,		[x21, x9, lsl 3]
	add		x25,	x25,	1
	b		initializeBoardGameTest
	
// Set a negative float for the tile
setNegativeFloat:
	bl		getRandomFloat
	mov		x9,		-1
	SCVTF	d9,		x9
	fmul	d0,		d0,		d9
	sub		x9,		xzr,	x25
	str		d0,		[x21, x9, lsl 3]
	add		x25,	x25,	1
	b		initializeBoardGameTest	
	
// Set tile to a positive float
setPositiveFloat:
	bl		getRandomFloat
	sub		x9,		xzr,	x25
	str		d0,		[x21, x9, lsl 3]
	add		x25,	x25,	1
	b		initializeBoardGameTest	
			

// Run loop until all tiles are set to a specific float or symbol 	
initializeBoardGameTest:
	cmp		x25,	x24				
	b.lt	initializeBoardGameLoop		// if i < tiles, branch to loop	
	
	mov		x25,	0					// reset iterator to 0
	b		initializeGameTilesLoop
	
// Will initialize each tile in gameTiles array to 0, indicating no tile has exploded yet
initializeGameTilesLoop:
	sub		x9,		xzr,	x25
	mov		w10,	0
	str		w10,	[x22,	x9, lsl 2]
	add		x25,	x25,	1
	cmp		x25,	x24
	b.lt	initializeGameTilesLoop
	b		EndInitializeGame
	
// Terminate method			
EndInitializeGame:	

	// Restoer callee-saved registers from stack
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	ldp		x29,	x30,	[sp], 96
	ret


	
	
	
	
//
//
//
	
	

// setStarLocation sets exit star at a random place in the boardGame
// 	args: 
//	 x0 = M, rows
//	 x1 = N, columns
//	 x2 = Base address of boardGame
// Returns void

setStarLocation:
	stp		x29,	x30,	[sp, -96]!
	mov		x29,	sp
	
	// Store callee-saved registers on stack
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments
	mov		x19,	x0				// M
	mov		x20,	x1				// N
	mov		x21,	x2				// Base address of boardGame
	
	// Set up important variables
	mul		x22,	x19,	x20		// Number of tiles
	mov		x23,	1				// Iterator
	b		setStarLocationTest

// Find smallest power of 2 that is greater or equal to number of tiles
setStarLocationLoop:
	lsl		x23,	x23,	1
	b		setStarLocationTest

// Set the float 19.00 to a random tile in boardGame, indicating it is the exit tile	
setStarLocationTest:
	cmp		x23,	x22
	b.lt	setStarLocationLoop	
		
	bl		clock
	bl		srand
	bl		rand
	
	mov		x9,		x23
	
	udiv	x10,	x0,		x22
	sub		x11,	x9,		x22
	madd	x12,	x10,	x11,	x0
	
	sub		x9,		x9,		1
	and		x13,	x12,	x9
	
	sub		x13,	xzr,	x13
	
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision 
	
	str		d0,		[x21, x13, lsl 3]	
	
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	ldp		x29,	x30,	[sp], 96
	ret
	




//
//
//





// placeNegatives randomly determines which tiles will become negative
// 	args: 
//	 x0 = M, rows
//	 x1 = N, columns
//	 x2 = Base address of boardGame
// Returns void

placeNegatives:
	stp		x29,	x30,	[sp, -96]!
	mov		x29,	sp
	
	// Store callee-saved registers to stack
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Storing arguments
	mov		x19,	x0				// M
	mov		x20,	x1				// N
	mov		x21,	x2				// Base address of boaradGame
	
	// Storing important variables 
	mul		x22,	x19,	x20		// Number of tiles
	mov		x23,	1				// Iterator
	b		getBTXNTest
		
getBTXNLoop:
	lsl		x23,	x23,	1
	b		getBTXNTest
	
getBTXNTest:
	cmp		x23,	x22
	b.lt	getBTXNLoop	
	
	mov		x0,		0
	mov		x1,		1
	bl		doubleDivision 
	
	fmov	d9,		d0			// Percentage of negatives
	b		getNumberOfNegativesLoop

// Randomly determine how many tiles will have negative floats, 
//	such that it's between 35-40%
getNumberOfNegativesLoop:
	bl		clock
	bl		srand
	bl		rand
	
	mov		x9,		x23
		
	udiv	x10,	x0,		x22
	sub		x11,	x9	,	x22
	madd	x12,	x10,	x11,	x0
	
	sub		x9,		x9,		1
	and		x13,	x12,	x9
	
	SCVTF	d9,		x13
	SCVTF	d10,	x22
	fdiv	d9,		d9,		d10
	
	mov		x0,		40
	mov		x1,		100
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.gt	getNumberOfNegativesLoop
	
	mov		x0,		35
	mov		x1,		100
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.lt	getNumberOfNegativesLoop
	
	mov		x24,	x13			// Number of negatives
	b		placeNegativesTest

// For the randomly generated number of tiles, set that many random tiles to be negative
placeNegativesLoop:
	bl		clock
	bl		srand
	bl		rand
	
	mov		x9,		x23
	
	udiv	x10,	x0,		x22
	sub		x11,	x9	,	x22
	madd	x12,	x10,	x11,	x0
	
	sub		x9,		x9,		1
	and		x13,	x12,	x9
	sub		x13,	xzr,	x13
	
	ldr		d9,		[x21, x13, lsl 3]
	
	mov		x0,		1
	mov		x1,		1
	bl		doubleDivision 
	
	
	fcmp	d9,		d0
	b.eq	placeNegativesLoop
	
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.eq	placeNegativesLoop
	
	mov		x0,		1
	mov		x1,		1
	bl		doubleDivision 
	
	fmov	d10,	d0
	str		d10,	[x21, x13, lsl 3]
	
	sub		x24,	x24,	1
	b		placeNegativesTest
	
	
placeNegativesTest:
	cmp		x24,	0
	b.gt	placeNegativesLoop
	
	// Restore callee-saved registers from stack
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	// Terminate method 
	ldp		x29,	x30,	[sp], 96
	ret
		
		
			
		
//
//
	

		
		
// placeSpecials determines the location of special character in the boardGame
// 	args: 
//	 x0 = M, rows
//	 x1 = N, columns
//	 x2 = Base address of boardGame
// Returns void

placeSpecials:	
	stp		x29,	x30,	[sp, -96]!
	mov		x29,	sp
	
	// Store callee-saved registers to stack
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments 
	mov		x19,	x0				// M
	mov		x20,	x1				// N
	mov		x21,	x2				// Base address of boaradGame
	
	// Store other variables
	mul		x22,	x19,	x20		// Number of tiles
	mov		x23,	1				// Iterator
	b		getBTXNTestForSpecials
		
getBTXNLoopForSpecials:
	lsl		x23,	x23,	1
	b		getBTXNTestForSpecials
	
getBTXNTestForSpecials:
	cmp		x23,	x22
	b.lt	getBTXNLoopForSpecials
	
	mov		x0,		0
	mov		x1,		1
	bl		doubleDivision 
	
	fmov	d9,	d0				// Percentage of negatives
	b		getNumberOfSpecialsLoop

// Randomly determine how many tiles will have negative floats, 
//	such that it's between 35-40%
getNumberOfSpecialsLoop:	
	bl		clock
	bl		srand
	bl		rand
	
	mov		x9,		x23
	
	udiv	x10,	x0,		x22
	sub		x11,	x9	,	x22
	madd	x12,	x10,	x11,	x0
	
	sub		x9,		x9,		1
	and		x13,	x12,	x9
	sub		x13,	x13,	1
	
	SCVTF	d9,		x13
	SCVTF	d10,	x22
	fdiv	d9,		d9,		d10
	
	mov		x0,		20
	mov		x1,		100
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.gt	getNumberOfSpecialsLoop
	
	mov		x0,		15
	mov		x1,		100
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.lt	getNumberOfSpecialsLoop
	
	mov		x24,	x13			// Number of negatives
	b		placeSpecialsTest

// For the randomly generated number of tiles, set that many random tiles to be negative
placeSpecialsLoop:
	bl		clock
	bl		srand
	bl		rand
	
	mov		x9,		x23
	
	udiv	x10,	x0,		x22
	sub		x11,	x9	,	x22
	madd	x12,	x10,	x11,	x0
	
	sub		x9,		x9,		1
	and		x13,	x12,	x9
	sub		x13,	xzr,	x13
	
	ldr		d9,		[x21, x13, lsl 3]
	
	mov		x0,		1
	mov		x1,		1
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.eq	placeSpecialsLoop
	
	mov		x0,		2
	mov		x1,		1
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.eq	placeSpecialsLoop
	
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision 
	
	fcmp	d9,		d0
	b.eq	placeSpecialsLoop
	
	mov		x0,		2
	mov		x1,		1
	bl		doubleDivision 
	
	fmov	d10,	d0
	str		d10,	[x21, x13, lsl 3]
	
	sub		x24,	x24,	1
	b		placeSpecialsTest
	
	
placeSpecialsTest:
	cmp		x24,	0
	b.gt	placeSpecialsLoop
	
	// Restore callee-saved registers from stack
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	// Terminate method
	ldp		x29,	x30,	[sp], 96
	ret	
	
	
	
	
//
//
//	



// getRandomFloat will return a random double within the bounds given as arguments
//	Args: x0, the minimum value
//		  x1, the maximum value
//		  x2. whether float is negative or not
// Returns a random double in d0

getRandomFloat:
	stp		x29,	x30,	[sp, -16]!
	mov		x29,	sp
	
	// Get random long
	bl		clock
	bl		srand
	bl		rand						// Random long, r
	
	mov		x10,	1501				// Upper bound, a
	mov		x11,	2048				// First power of 2 that is greater or equal to upper bound, b
	sub		x11,	x11,	x10			// Difference: b - a
	udiv	x12,	x0,		x10			// r/(b-a) 
	madd	x13,	x12,	x11,	x0	// r/(b-a) + r
	and		x14,	x13,	2047		// r/(b-a) + r & 2047 will give a random long between 1 to 1500
	
	SCVTF	d0,		x14					// Store this random long as a float
	
	mov		x10,	100					// Divide by 100
	SCVTF	d1,		x10
	fdiv	d0,		d0,		d1
	
	
	ldp		x29,	x30,	[sp], 16
	ret
	
	

//
//
//	
	
// initializeCharacter sets tiles in boardGame that were pre-determined to be a special character

initializeCharacter:
	stp		x29,	x30,	[sp, -16]!
	mov		x29,	sp	
	
	
	bl		clock
	bl		srand
	bl		rand
	
	mov		x9,		1
	mov		x10,	16
	
	and		x0,		x0,		x9
	add		x0,		x0,		16
	
	SCVTF	d0,		x0
	
	ldp		x29,	x30,	[sp], 16
	ret
	
	
	
	
// doubleDivision takes two integers and divides them, returning the quotient as a double
// args: x0 (divisor), x1 (dividend)
// return quotient as double d0

doubleDivision:
	stp		x29,	x30,	[sp, -16]!
	mov		x29,	sp
	
	// Convert integers to doubles and divide 
	SCVTF	d0,		x0
	SCVTF	d1,		x1
	fdiv	d0,		d0,		d1
	
	ldp		x29,	x30,	[sp],	16
	ret




// displayFloats is called at the beginning of the game, and displays the value of each tile in boardGame
//	Args:	x0, M
//			x1, N
//			x2, Pointer to boardGame
//			x3, Pointer to gameTiles

displayFloats:
	stp		x29,	x30,	[sp, -112]!
	mov		x29,	sp
	
	// Store callee-saved registers to stack
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments 
	mov		x19,	x0			// M
	mov		x20,	x1			// N
	mov		x21,	x2			// Base address of boardGame
	mov		x22,	x3			// Base address of Game tiles
	
	// Store i and j variables to iterate 2d array
	mov		x23,	0			// i
	mov		x24,	0			// j
	
	// Initializes charCounter and negCounter to 0, and store them to stack
	mov		w25,	0			// charCounter (number of tiles that are special characters)
	mov		w26,	0			// negCounter  (number of tiles that are negative floats)
	str		w25,	[fp, 88]	// charCounter *int
	str		w26,	[fp, 92]	// negCounter *int
	
	b		displayFloatsTest
	
displayFloatsLoop:
	// Get offset based on iterators
	mul		x9,		x23,	x20	
	add		x9,		x9,		x24
	sub		x9,		xzr,	x9
	
	// Get value of each tile and call printLobby
	ldr		d0,		[x21, x9, lsl 3]
	add		x0,		fp,		88			// Address of char counter
	add		x1,		fp,		92			// Address of neg counter
	bl		printLobby					// Prints the value with proper spacing
	
	// Iterate j and check if j equals column number
	add		x24,	x24,	1
	cmp		x24,	x20
	b.lt	displayFloatsLoop			// If less, than loop again for next vale
	
	// Otherwise, print a new line
	ldr		x0,		=line
	bl		printf
	
	// Reset j to 0, and increment i for next row
	mov		x24,	0	
	add		x23,	x23,	1
	b		displayFloatsTest

// Iterate through 2d table until the tiles in all rows and columns are displayed
displayFloatsTest:
	cmp		x23,	x19		
	b.lt	displayFloatsLoop	
	
	// Print one more line after displaying table
	ldr		x0,		=line
	bl		printf
	
	
	mov		x9,		100				// Store 100 
	
	// Get ratio special characters to size of board
	ldr		w0,		[fp, 88]		// Number of special char
	SXTW	x0,		w0
	mul		x1,		x19,	x20		// Number of tiles
	mul		x0,		x0,		x9
	bl		doubleDivision 
	
	// Print ratio of special characters
	ldr		x0,		=percentCharString
	bl		printf
	
	mov		x9,		100				// Store 100
	
	// Get ratio negative doubles to size of board
	ldr		w0,		[fp, 92]		// Number of negative char
	SXTW	x0,		w0
	mul		x1,		x19,	x20		// Number of tiles
	mul		x0,		x0,		x9
	bl		doubleDivision 
	
	// Print ratio of negative doubles
	ldr		x0,		=percentNegString
	bl		printf
	
	mov		x9,		100				// Store 100
	
	// Get ratio of positive doubles to size of board
	ldr		w0,		[fp, 92]		// Number of negative char
	ldr		w1,		[fp, 88]		// Number of special char
	add		w0,		w0,		w1		// Sum of negative floats and special characters
	mul		w1,		w19,	w20		// Number of tiles
	sub		w0,		w1,		w0
	mul		x0,		x0,		x9
	bl		doubleDivision
	
	// Print ratio of positive doubles to size of board
	ldr		x0,		=percentPositiveString
	bl		printf
	
	// Skip a line
	ldr		x0,		=line
	bl		printf
	
	// Restore callee-saved registers from stack
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	// Terminate method
	ldp		x29,	x30,	[sp], 112
	ret
	





// printLobby used by displayFloats at start of program to ensure board is displayed with good alignment 
//	Args:	d0, the value of each element in boardGame
//			x0, pointer to charCounter
//			x1, pointer to negCounter
// returns void

printLobby:
	stp		x29,	x30,	[sp, -112]!
	mov		x29,	sp
	
	// Load callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments
	fmov	d19,	d0				// float
	mov		x19,	x0				// address of char counter
	mov		x20,	x1				// Address of neg counter
	
	// Get 19.00
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision 	
	
	// Check if value of tile = 19.00
	fcmp	d19,	d0
	b.eq	PrintStar
	
	// Get 16.00
	mov		x0,		16
	mov		x1,		1
	bl		doubleDivision 	
	
	// Check if value of tile = 16.00
	fcmp	d19,	d0
	b.eq	PrintReward
	
	// Get 17.00
	mov		x0,		17
	mov		x1,		1
	bl		doubleDivision 	
	
	// Check if value of tile = 17.00
	fcmp	d19,	d0
	b.eq	PrintBlow
	
	// Else, increment negCounter by 1
	ldr		w9,		[x20]
	add		w9,		w9,		1
	str		w9,		[x20]
	
	// Get -10.00
	mov		x0,		-10
	mov		x1,		1
	bl		doubleDivision 	
	
	// Check if value of tile <= -10.00
	fcmp	d19,	d0
	b.le	PrintSixSpace
	
	// Get 0.00
	mov		x0,		0
	mov		x1,		1
	bl		doubleDivision 	
	
	// Check if value of tile < 0.00
	fcmp	d19,	d0
	b.lt	PrintFiveSpace
	
	// Else, de-increment negCounter by 1
	ldr		w9,		[x20]
	sub		w9,		w9,		1
	str		w9,		[x20]
	
	// Get 10.00
	mov		x0,		10
	mov		x1,		1
	bl		doubleDivision 	
	
	// Check if value of tile < 10.00
	fcmp	d19,	d0
	b.lt	PrintFourSpace
	
	// Else
	b		PrintFiveSpace
	
// Prints exit tile
PrintStar:
	ldr		x0,		=starString
	bl		printf
	
	// Increment charCounter by 1
	ldr		w9,		[x19]
	add		w9,		w9,		1
	str		w9,		[x19]
	
	b		EndPrintLobby

// Prints reward tile ($)	
PrintReward:
	ldr		x0,		=rewardString
	bl		printf
	
	// Increment charCounter by 1
	ldr		w9,		[x19]
	add		w9,		w9,		1
	str		w9,		[x19]
	
	b		EndPrintLobby

// Prints blow tile (#)
PrintBlow:
	ldr		x0,		=blowString
	bl		printf
	
	// Increment charCounter by 1
	ldr		w9,		[x19]
	add		w9,		w9,		1
	str		w9,		[x19]
	
	b		EndPrintLobby	

// Print double with six spaces	
PrintSixSpace:
	ldr		x0,		=sixSpaceString
	fmov	d0,		d19
	bl		printf
	b		EndPrintLobby
	
// Print double with five spaces	
PrintFiveSpace:
	ldr		x0,		=fiveSpaceString
	fmov	d0,		d19
	bl		printf
	b		EndPrintLobby		

// Print double with four spaces	
PrintFourSpace:
	ldr		x0,		=fourSpaceString
	fmov	d0,		d19
	bl		printf
	b		EndPrintLobby	

// Terminate printLobby method
EndPrintLobby:

	// Restore callee-saved registers
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	

	ldp		x29,	x30,	[sp], 112
	ret
			
		
	







s_int_arg1_s = 4

s_arg_alloc = -(s_int_arg1_s) & -16

// play implements the game play, and keeps track of the player stats
// args: x0, M
//		 x1: N
//		 x2: Pointer to boardGame
//		 x3: Pointer to gameTiles
//		 x4: pointer to total score
//		 x5: Pointer to quit
//	Returns void
		
play:
	stp		x29,	x30,	[sp, -144]!
	mov		x29,	sp
	
	// Store callee-saved registers on stack
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments
	mov		x19,	x0				// M
	mov		x20,	x1				// N
	str		x2,		[fp, 88]		// Store pointer to boardGame
	str		x3,		[fp, 96]		// Store pointer to gameTiles
	str		x4,		[fp, 104]		// store pointer to total score
	str		x5,		[fp, 112]		// Store pointer to quit 
	
	// Initialize other variables and store to stack
	mov		x0,		0
	SCVTF	d19,	x0				// move score
	mov		x21,	3				// player lives = 3
	mov		x22,	0				// player star = 0 (if exit tile is found, changed to 1)
	mov		x23,	0				// rewards
	mov		x24,	0				// blows
	str		x22,	[fp, 120]		// Store player star
	str		x23,	[fp, 128]		// Store player boost
	str		x24,	[fp, 136]		// Store player bad
	
	// call getNumberOfBombs
	mov		x0,		x19				// M
	mov		x1,		x20				// N
	bl		getNumberOfBombs	
	mov		x25,	x0				// Number of bombs
	
	// call display
	ldr		x0,		[fp, 88]		// Pointer to boardGame
	ldr		x1,		[fp, 96]		// Pointer to gameTiles
	fmov	d0,		d19				// Move score
	ldr		x9,		[fp, 104]		// Pointer to total score (not part of argument)
	ldr		d1,		[x9]			// Total score
	mov		x2,		x19				// M
	mov		x3,		x20				// N
	mov		x4,		x21				// Player lives
	mov		x5,		x22				// Player star, wont need
	mov		x6,		x23				// Player boost, won't need
	mov		x7,		x24				// Player bad, won't need
	add		sp,		sp,	s_arg_alloc	
	str		w25,	[sp, 0]			// Number of bombs spill over arg
	bl		display
	sub		sp,		sp,	s_arg_alloc	// Deallocate space for spill over arg
	
	b		PlayTest

// Each iteration of this loop implements a player turn
PlayLoop:

	// Allocate space for userInput array (two elements to store x, y coordinates)
	sub		sp,		sp,		16
	add		x26,	fp,		-4		// Pointer to userInput array
	
	// Call getUserInputArray
	mov		x0,		x26				// Pointer to userInput array
	ldr		x1,		[fp, 96]		// Pointer too gameTiles
	mov		x2,		x19				// M
	mov		x3,		x20				// N
	bl		getUserInputArray
	
	// Check if user wants to quit
	ldr		w9,		[x26]
	cmp		w9,		-1
	b.eq	UserQuit

	sub		x25,	x25,	1		// Decrease player bombs by 1
	
	// Allocate space for processedTiles array
	mov		x9,		int_s			// Size of an int
	mul		x10,	x19,	x20		// Number of tiles
	mul		x10,	x10,	x9		// Space needed for final tiles array
	sub		x10,	xzr,	x10		// Negative
	and		x27,	x10,	-16		// padded bytes
	sub		x28,	sp,		4		// Pointer to processedTiles array
	add		sp,		sp,		x27		// Allocate space for processedTiles array
	
	// Call processInput
	mov		x0,		x26				// Pointer to userInput array
	mov		x1,		x28				// Pointer to processedTiles array
	ldr		x2,		[fp, 96]		// Pointer to gameTiles array
	mov		x3,		x19				// M
	mov		x4,		x20				// N
	ldr		x5,		[fp, 128]		// Number of rewards gained last turn
	ldr		x6,		[fp, 136]		// Number of blows gained last turn 
	bl		processInput

	
	// Reset number rewards and blows 
	mov		x9,		0
	str		x9,		[fp, 128]		// boosts = 0
	str		x9,		[fp, 136]		// blows = 0
	
	// call calculateScore
	mov		x0,		x28				// Pointer to processedTiles
	ldr		x1,		[fp, 88]		// Pointer to gameBoard
	mov		x2,		x19				// M
	mov		x3,		x20				// N
	ldr		x4,		[fp, 104]		// Pointer to total score
	add		x5,		fp, 120			// Pointer to player star
	add		x6,		fp, 128			// Pointer to number of rewards
	add		x7,		fp, 136			// Pointer to number of blows
	bl		calculateScore
	
	// Print the move score
	ldr		x0,		=moveScoreMessage
	bl		printf
	
	// Deallocate space for final tiles array
	sub		x27,	xzr,	x27
	add		sp,		sp,		x27
	
	// Deallocate space for user input array
	add		sp,		sp,		16
		
	// Call display again
	ldr		x0,		[fp, 88]		// Pointer to boardGame
	ldr		x1,		[fp, 96]		// Pointer to gameTiles
	fmov	d0,		d19				// Move score
	ldr		x9,		[fp, 104]		// Pointer to total score (not part of argument)
	ldr		d1,		[x9]			// Total score
	mov		x2,		x19				// M
	mov		x3,		x20				// N
	mov		x4,		x21				// Player lives
	mov		x5,		x22				// Player star
	mov		x6,		x23				// Player boost
	mov		x7,		x24				// Player bad
	add		sp,		sp,	s_arg_alloc	
	str		w25,	[sp, 0]			// Number of bombs spill over arg
	bl		display
	sub		sp,		sp,	s_arg_alloc	// Deallocate space for spill over arg
	
	// Check if player uncovered the exit tile
	ldr		x0,		[fp, 120]
	cmp		x0,		1
	b.eq	WonGame
	
	// Check if player out of bombs
	cmp		x25,	0
	ldr		x0,		=outOfBombsMessage
	b.eq	LostGame
	
	// Check if totalScore less than 0
	ldr		x9,		[fp, 104]
	ldr		d9,		[x9]
	mov		x10,	0
	SCVTF	d10,	x10
	fcmp	d9,		d10
	b.lt	LostLife
	
	// Check if user uncovered new rewards or blows
	ldr		x0,		[fp, 128]		// Player boost
	ldr		x1,		[fp, 136]		// Player bad
	bl		checkPacks
	
	b		PlayTest
	
// User has won the game
WonGame:
	ldr		x0,		=wonMessage
	bl		printf
	b		PlayTest	

// User has lost the game
LostGame:
	bl		printf
	b		PlayTest	

// User lost a life
LostLife:
	// Print message indicating user lost life
	ldr		x0,			=lostLifeMessage
	bl		printf
	
	// Decrease number of lives by 1
	sub		x21,		x21,	1
	ldr		x0,			=outOfLivesMessage
	
	// Check if player has no more lives
	cmp		x21,		0
	b.eq	LostGame
	
	// Else, indicate any new rewards or blows uncovered
	ldr		x0,		[fp, 128]		// Player boost
	ldr		x1,		[fp, 136]		// Player bad
	bl		checkPacks
	
	// Indicate to user that total score is being reset 
	ldr		x0,			=resetMessage
	bl		printf
	
	// Reset total score to 0.0
	ldr		x9,			[fp, 104]	// Pointer to total score
	ldr		d9,			[x9]		// Total score
	mov		x10,		0
	SCVTF	d9,			x10
	str		d9,			[x9]
	
	// Call display again
	ldr		x0,		[fp, 88]		// Base address of board game
	ldr		x1,		[fp, 96]		// Base address of game tiles
	fmov	d0,		d19				// Move score
	ldr		x9,		[fp, 104]		// Pointer to total score (not part of argument)
	ldr		d1,		[x9]			// Total score
	mov		x2,		x19				// M
	mov		x3,		x20				// N
	mov		x4,		x21				// Player lives
	mov		x5,		x22				// Player star
	mov		x6,		x23				// Player boost
	mov		x7,		x24				// Player bad
	add		sp,		sp,	s_arg_alloc	
	str		w25,	[sp, 0]			// Number of bombs spill over arg
	bl		display
	sub		sp,		sp,	s_arg_alloc	// Deallocate space for spill over arg
	
	b		PlayTest
		

// Play game until user quits, the exit tile is found, or out of bombs or lives			
PlayTest:
	cmp		x21,	0				// Check player lives <= 0
	b.le	EndPlay
	
	ldr		x22,	[fp, 120]
	cmp		x22,	0				// Check player star != 0
	b.ne	EndPlay
	
	cmp		x25,	0				// Check player bombs > 0
	b.le	EndPlay
	
	b		PlayLoop
	
// User haas quit the game
UserQuit:

	// Set quit to 1
	ldr		x9,		[fp, 112]		// Pointer to quit
	mov		x10,	1
	str		x10,	[x9]
	
	// Print message indicating user quit the game
	ldr		x0,		=quitMessage
	bl		printf
	
	// Deallocate space for user input array
	add		sp,		sp,		16
	b		EndPlay

// Terminate play method	
EndPlay:

	// Restore callee-saved variables	
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	// Deallocate space on stack
	ldp		x29,	x30,	[sp], 144
	ret
	
	
	
	
	
	


arg1_l = 128	

// display is used during the game to display the board, with the uncovered tiles being visible only
// args: x0, Pointer to boardGame
// 		 x1, Pointer to gameTiles
//		 d0, Move score
//		 d1, Total score
//		 x2, M
//		 x3, N
//		 x4, Player lives
//		 x5, Player star
//		 x6, Number of rewards
//		 x7, Number of blows

display:
	stp		x29,	x30,	[sp, -128]!
	mov		x29,	sp
	
	// Store callee-saved registers on stack
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments
	mov		x19,	x0			// Base address of boardGame
	mov		x20,	x1			// Base address of gameTiles
	fmov	d19,	d0			// Move score
	fmov	d20,	d1			// Total score
	mov		x21,	x2			// M
	mov		x22,	x3			// N
	mov		x23,	x4			// Player lives
	mov		x24,	x5			// Player star
	mov		x25,	x6			// Boosts
	mov		x26,	x7			// Blows
	
	// Iterators 
	mov		x27,	0			// i
	mov		x28,	0			// j 
	
	b		DisplayTest
	

// Display each tile in board
DisplayLoop:

	// Check each tile in gameTiles
	mul		x9,		x27,	x22
	add		x9,		x9,		x28
	sub		x9,		xzr,	x9
	ldr		w10,	[x20, x9, lsl 2]
	
	// If value = 0, than tile has not exploded yet
	cmp		w10,	0
	b.eq	PrintX
	
	// Else, load floating point value of the tile from gameBoard
	mov		x0,		15
	mov		x1,		1
	bl		doubleDivision
	fmov	d9,		d0					// get 15.00
	
	mov		x0,		0
	mov		x1,		1
	bl		doubleDivision
	fmov	d10,	d0					// get 0.00
	
	ldr		d0,		[x19, x9, lsl 3]
	
	fcmp	d0,		d9
	b.le	CheckPlusOrMinus
	ldr		x0,		=uselessBuffer		
	ldr		x1,		=uselessBuffer
	bl		printLobby
	b		ColumnTest

// Print genetic "X" to represent unexploded tile
PrintX:
	ldr		x0,		=tileString
	bl		printf
	b		ColumnTest

// Check  + or - for uncovered floating point tiles
CheckPlusOrMinus:
	fcmp	d0,		d10
	b.lt	PrintMinus
	ldr		x0,		=positiveString
	bl		printf
	b		ColumnTest

// Print - for uncovered negative floating point tiles
PrintMinus:	
	ldr		x0,		=negativeString
	bl		printf
	b		ColumnTest

// Iterate through each column in board 
ColumnTest:
	// Increment j and check if it equals column number
	add		x28,	x28,	1
	cmp		x28,	x22
	b.lt	DisplayLoop				// Loop again for next tile if end of column not reached
	
	ldr		x0,		=line			// Otherwise, skip a new line
	bl		printf
	
	// Reset j and increment i by 1 
	mov		x28,	0
	add		x27,	x27,	1
	b		DisplayTest

// Iterate through 2d table until all tiles are displayed
DisplayTest:
	cmp		x27,	x21
	b.lt	DisplayLoop	
	
	// Print number of lives
	ldr		x0,		=livesString
	mov		x1,		x23
	bl		printf
	
	// Print total score
	ldr		x0,		=totalScoreString
	fmov	d0,		d20
	bl		printf
	
	// Print number of bombs 
	ldr		x0,		=bombsString
	ldr		x1,		[fp, arg1_l]		// load argument form stack
	bl		printf
	
	// Restore callee-saved registers
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	// Terminate method
	ldp		x29,	x30,	[sp], 128
	ret
	





//
//



// getUserInputArray gets the board coordinates specified by the user
//	args: x0,	pointer to userInput array
// 		  x1,   pointer to gameTiles array
// 		  x2,   M
//		  x3,   N
getUserInputArray:
	stp		x29,	x30,	[sp, -128]!
	mov		x29,	sp
	
	// Store callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	
	// Store arguments
	mov		x19,	x0			// Pointer to input array
	mov		x20,	x1			// Pointer to game tiles array
	mov		x21,	x2			// M
	mov		x22,	x3			// N
	
	// Stoer variables	
	mov		x25,	0			// x coordinate
	mov		x26,	0			// y coordinate
	b		GetX

// Get x coordinate from user		
GetX:
	// Display message asking for input
	ldr		x0,		=askForCoorGeneral
	ldr		x1,		=xString
	bl		printf
	
	// Scan input from user
	ldr		x0,		=inputString
	ldr		x1,		=userInput
	bl		scanf
	
	// Convert input to integer
	ldr		x0,		=userInput
	bl		atoi
	mov		x25,	x0
	
	// Check if user wants to quit
	cmp		x25,	-1		
	b.eq	UserInputQuit
			
	// Check if x coordinate is out of bounds
	cmp		x25,	x22
	b.ge	InvalidXInput
	cmp		x25,	-1
	b.lt	InvalidXInput	
	
	// Store coordinate to first element in userInput array
	str		w25,	[x19]
	
	b		GetY

// Get y coordinate from user	
GetY:

	// Display message asking for input
	ldr		x0,		=askForCoorGeneral
	ldr		x1,		=yString
	bl		printf
	
	// Scan input from user
	ldr		x0,		=inputString
	ldr		x1,		=userInput
	bl		scanf
	
	// Convert input to integer
	ldr		x0,		=userInput
	bl		atoi
	mov		x26,	x0		
	
	// Check if user wants to quit
	cmp		x26,	-1		
	b.eq	UserInputQuit
	
	// Check if y coordinate is out of bounds
	cmp		x26,	x21
	b.ge	InvalidYInput
	cmp		x26,	-1
	b.lt	InvalidYInput	
	
	// Store y coordinate to second element in userInput array
	str		w26,	[x19, -4]
	
	b		CheckTileUnused	

// Check if tile selected by user has already exploded 	
CheckTileUnused:
	// Get value for the tile in gameTiles
	mul		x9,		x26,	x22
	add		x9,		x9,		x25
	sub		x9,		xzr,	x9
	ldr		w10,	[x20, x9, lsl 2]
	
	// If value = 1, then tile has already exploded, and cannot be used
	cmp		w10,	1
	b.eq	TileUsedError
	
	b		EndUserInputArray	// Otherwise, input is valid
	
// Display error message if x-coordinate invalid	
InvalidXInput:
	ldr		x0,		=invalidInputMessage
	ldr		x1,		=xString
	mov		x2,		x25
	bl		printf
	b		GetX

// Display error message if y-coordinate invalid	
InvalidYInput:
	ldr		x0,		=invalidInputMessage
	ldr		x1,		=yString
	mov		x2,		x26
	bl		printf
	b		GetY	

// Display error message if selected tile already exploded 	
TileUsedError:
	ldr		x0,		=tileUsedErrorMessage	
	bl		printf
	b		GetX

// User wants to quit
UserInputQuit:
	mov		w10,	-1
	str		w10,	[x19]
	str		w10,	[x19, -4]
	b		EndUserInputArray

// Terminate method
EndUserInputArray:
	// Restore callee-saved registers 
	
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	
	ldp		x29,	x30,	[sp], 128
	ret




// processInput determines the tiles that are to explode based on the user's input and any boost or blow packs
//	args: x0, Pointer to userInput array
//		  x1, Pointer to processedTiles array
//		  x2, Pointer to gameTiles array
//		  x3, Pointer to M
//		  x4, Pointer to N
//		  x5, Number of boosts
//		  x6, Number of blows

processInput:
	stp		x29,	x30,	[sp, -128]!
	mov		x29,	sp
	
	// Store-callee saved registers 
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	str		x28,	[fp, 88]

	// Set up variables
	mov		x19,	x0			// Pointer to userInput array
	mov		x20,	x1			// Pointer to processedTiles array
	mov		x21,	x2			// Pointer to gameTiles array
	mov		x22,	x3			// M
	mov		x23,	x4			// N
	mov		x24,	x5			// Player boosts
	mov		x25,	x6			// Player blows
	
	// Get x,y coordinates
	ldr		w9,		[x19]		// x coordinate
	ldr		w10,	[x19, -4]	// y coordinate
	
	// Initialize min and max coordinates
	mov		w11,	0			// min x
	mov		w12,	0			// min y
	mov		w13,	0			// max x
	mov		w14,	0			// max y
	
	
	// Call get range
	mov		w0,		w24				
	mov		w1,		w25				
	bl		getRange
	mov		w15,	w0
		
	// Set up min and max coordinates
	sub		w11,	w9,		w15		// minX = xCoor - range
	sub		w12,	w10,	w15		// minY = yCoor - range
	add		w13,	w9,		w15		// maxX = xCoor + range
	add		w14,	w10,	w15		// maxY = yCoor + range
	
	// Check minX isn't less than 0
	mov		w0,		w11
	bl		checkMin
	mov		w11,	w0
	
	// Check minY isn't less than 0
	mov		w0,		w12
	bl		checkMin
	mov		w12,	w0
	
	// Check maxX isn't greater or equal to number of columns
	mov		w0,		w13
	mov		w1,		w23
	bl		checkMax
	mov		w13,	w0
	
	// Check maxX isn't greater or equal to number of rows
	mov		w0,		w14
	mov		w1,		w22
	bl		checkMax
	mov		w14,	w0
	
	// Set up variables for loop
	mov		w26,	w11		// a, initialized to minX
	mov		w27,	w12		// b, initialized to minY
	mov		x28,	0		// iterator
	
	b		ProcessTest

// Process each tile in range of explosions	
ProcessLoop:

	// Check a <= maxX
	cmp		w26,	w13
	b.gt	Increment
	
	// Determine if that tile already exploded
	mul		w9,		w27,	w23
	add		w9,		w9,		w26
	SXTW	x10,	w9
	sub		x10,	xzr,	x10
	ldr		w10,	[x21, x10, lsl 2]
	
	// If value = 0, tile did not explode yet 
	cmp		w10,	0
	b.eq	AddTile
	
	// Otherwise, check the next tile
	add		w26,	w26,	1
	b		ProcessLoop

// Add unexploded tiles to processsedTiles array
AddTile:
	// Store index of the tile in processsedTiles array
	sub		x10,	xzr,	x28
	str		w9,		[x20, x10, lsl 2]
	
	// Set value of that tile in gameTiles array to 1, indicating it has now exploded
	SXTW	x9,		w9
	sub		x9,		xzr,	x9
	mov		w10,	1
	str		w10,	[x21, x9, lsl 2]
	
	// Increment iterator and a
	add		x28,	x28,	1
	add		w26,	w26,	1
	b		ProcessLoop

// If a > maxX, reset a to minX and increment b	
Increment:
	mov		w26,	w11
	add		w27,	w27,	1
	b		ProcessTest

// Iterate through entire range of rows
ProcessTest:
	cmp		w27,	w14		// check b <= maxy
	b.le	ProcessLoop	
	
	// Set last element in processedTiles array to -1
	sub		x10,	xzr,	x28
	mov		w9,		-1
	str		w9,		[x20, x10, lsl 2]	
	
	// Restore callee-saved registers
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	ldr		x28,	[fp, 88]
	
	ldp		x29,	x30,	[sp], 128
	ret
		
	
	
	
// checkMin checks that the value of the range or any minimum coordinate isn't less than 0, 
//	setting it to 0 otherwise and returning the value

checkMin:
	stp		x29,	x30,	[sp, -16]!
	mov		x29,	sp
	
	cmp		w0,		0
	b.ge	EndCheckMin
	mov		w0,		0
	
EndCheckMin:
	ldp		x29,	x30,	[sp], 16	
	ret	
	


// checkMax checks that the value of any maximum coordinate doesn't exceed its bound, 
//	setting it to the bound otherwise and returning the value

checkMax:
	stp		x29,	x30,	[sp, -16]!
	mov		x29,	sp
	
	cmp		w0,		w1
	b.lt	EndCheckMax
	sub		w0,		w1,		1

EndCheckMax:
	ldp		x29,	x30,	[sp], 16	
	ret	
	
	
	
	
	
	



// calculateScore returns the move score after each turn, and updating total score, and if
//	player uncovered any boosts, blows or the exit tile

calculateScore:
	stp		x29,	x30,	[sp, -128]!
	mov		x29,	sp
	
	// Store callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	str		x21,	[fp, 32]
	str		x22,	[fp, 40]
	str		x23,	[fp, 48]
	str		x24,	[fp, 56]
	str		x25,	[fp, 64]
	str		x26,	[fp, 72]
	str		x27,	[fp, 80]
	str		x28,	[fp, 88]
	
	// Store arguments
	mov		x19,	x0			// Pointer to processedTiles array
	mov		x20,	x1			// Pointer to gameBoard
	mov		x21,	x2			// M
	mov		x22,	x3			// N
	mov		x23,	x4			// Pointer to total score
	mov		x24,	x5			// Pointer to player star
	mov		x25,	x6			// Pointer to player boosts
	mov		x26,	x7			// Pointer to player blows
	
	
	// Initialize method variables
	mov		x27,	0			// i
	mov		w28,	0			// index of tile
	mov		x0,		0
	SCVTF	d10,	x0			// move score
	
	b		calculateScoreTest


// Check each tile
calculateScoreLoop:
	// Load floating point value of each tile from gameBoard
	SXTW	x28,	w28
	sub		x28,	xzr,	x28
	ldr		d9,		[x20, x28, lsl 3]

	// Check if value = 19.00
	mov		x0,		19
	mov		x1,		1
	bl		doubleDivision
	fcmp		d9,		d0
	b.eq	FoundStar
	
	// Check if value == 16.00
	mov		x0,		16
	mov		x1,		1
	bl		doubleDivision
	fcmp		d9,		d0
	b.eq	FoundBoost
	
	// Check if value == 17.00
	mov		x0,		17
	mov		x1,		1
	bl		doubleDivision	
	fcmp		d9,		d0
	b.eq	FoundBlow
	
	// Else, add value to move score
	fadd	d10,	d10,	d9
	
 
	add		x27,	x27,	1			// Increment iterator
	b		calculateScoreTest
	
// Player uncovered the exit tile	
FoundStar:
	mov		x0,		1
	str		x0,		[x24]
	add		x27,	x27,	1
	b		calculateScoreTest
	
// Player uncovered boost (reward pack)
FoundBoost:
	ldr		x0,		[x25]
	add		x0,		x0,		1
	str		x0,		[x25]
	add		x27,	x27,	1
	b		calculateScoreTest

// Player uncovered blow 
FoundBlow:
	ldr		x0,		[x26]
	add		x0,		x0,		1
	str		x0,		[x26]
	add		x27,	x27,	1	
	b		calculateScoreTest

// Iterate through all tiles in processedTiles array
calculateScoreTest:
	sub		x9,		xzr,	x27
	ldr		w28,	[x19, x9, lsl 2]
	cmp		w28,	-1
	b.ne	calculateScoreLoop	

	// Update total score
	ldr		d9,		[x23]
	fadd	d9,		d9,		d10
	str		d9,		[x23]
	
	// Return move score 
	fmov	d0,		d10
	
	// Restore callee-saved registers 
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	ldr		x21,	[fp, 32]
	ldr		x22,	[fp, 40]
	ldr		x23,	[fp, 48]
	ldr		x24,	[fp, 56]
	ldr		x25,	[fp, 64]
	ldr		x26,	[fp, 72]
	ldr		x27,	[fp, 80]
	ldr		x28,	[fp, 88]
	
	ldp		x29,	x30,	[sp], 128
	ret
	
	
	
	

// checkPacks displays messages in case the user uncovered any boosts or blows
checkPacks:	
	stp		fp,		lr,		[sp, -32]!
	mov		fp,		sp
	
	// Store callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	
	// Store arguments
	mov		w19,		w0				// Player boosts
	mov		w20,		w1				// Player Blows
	
	b		CheckPackNum
	
CheckPackNum:	
	cmp		w19,		0			// Check if received any rewards
	b.gt	DisplayPacks
	
	cmp		w20,		0			// Check if received any blows
	b.gt	DisplayPacks
	
	b		EndCheckPacks

DisplayPacks:
	// Display number of boosts uncovered
	ldr		x0,		=rewardMessage
	mov		w1,		w19
	bl		printf	
	
	// Display number of blows uncovered
	ldr		x0,		=blowMessage
	mov		w1,		w20
	bl		printf	
	
	// Check bomb range in next turn
	sub		w9,		w19,	w20		// w9 = Boosts - Blows
	cmp		w9,		0				
	b.lt	DisplaySingleTile		
	b.eq	DisplayRegularEffect	
	b.gt	DisplayEnhancedEffect	
	
// If boosts < blows, next bomb will destroy single tile only	
DisplaySingleTile:
	ldr		x0,		=bombSingleTileMessage
	bl		printf
	b		EndCheckPacks

// If boosts = blows, than next bomb will have a regular range	
DisplayRegularEffect:
	ldr		x0,		=bombRegularMessage
	bl		printf
	b		EndCheckPacks

// If boosts > blows, than next bomb will have enhanced effect	
DisplayEnhancedEffect:
	ldr		x0,		=bombEnhancedMessage	
	mov		w1,		w9
	bl		printf
	b		EndCheckPacks

// Terminate method
EndCheckPacks:
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	
	ldp		fp,		lr,		[sp],	32
	ret
						
	
	
	
		
	
// getRange returns the number of layers to be exploded based on number of boosts and blows
//	If there are more blows than boosts, only a single tile will be exploded.

getRange:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp
	
	// Store arguments
	mov		w24,	w0
	mov		w25,	w1
	
	// Initialize range to 0
	mov		w0,		0
	
	sub		w1,		w24,	w25
	cmp		w1,		0				// Check if boosts < blows
	b.lt	EndGetRange				// If so, range will remain 0, so only one tile explodes 
	
	mov		w0,		1
	lsl		w0,		w0,		w1		// Otherwise, 2^(boosts - blows) layers will explode

// Terminate method	
EndGetRange:
	ldp		fp,		lr,		[sp],	16
	ret
			
			

// getNumberOfBombs determines number of bombs based on dimensions of board, and returns it in x0
//			
getNumberOfBombs:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp
	
	// Calculate number of bombs
	add		x0,		x0,		x1
	mov		x1,		4
	udiv	x0,		x0,		x1	
	
	ldp		fp,		lr,		[sp],	16
	ret		
			
			
	

	
	.data
uselessBuffer:	.word	0				// Extra buffer 

	.bss
userInput:	.skip	20					// Used to store user input



	.global finalTotalScore
finalTotalScore:	.dword	0			// final total score

	.global finalDuration
finalDuration:	.dword	0				// game duration

	.global finalQuit
finalQuit:	.dword	0					// quit

	
	
