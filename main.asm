// Armeen Rashidian
// Name: Armeen Rashidian
// Student ID: 3001 6331 
// CPSC 355, Project Part 2

// Assembly program of Bomberman game

// The file main.asm sets up the program




	.text

// Command-line error messages
tooFewArgsMessage: .string	"\nError. Too few command-line arguments.\n\n"									// Insufficient arguments	
tooManyArgsMessage: .string	"\nError. Too many command-line arguments.\n\n"									// Too many arguments
rowErrorMessage:	.string	"\nError. You entered %d rows. Must enter between 10 to 100 rows.\n\n"			// Invalid row argument
colErrorMessage:	 .string	"\nError. You entered %d columns. Must enter between 10 to 20 columns.\n\n"	// Invalid column argument


// Log file strings
logFileName:	.string	"myGame.log"			// Name of log file
nameHeader:	.string "Name                "  	// 20 bytes
scoreHeader: .string "Score               " 	// 20 bytes
durationHeader: .string "Duration\n"        	// 9 bytes
logFileErrorMessage:	.string	"Error. Something went wrong with logging to the score sheet.\n"	
twentySpaceString:	.string	"                    " // 20 bytes of space 
lineString:	.string	"\n"
space:	.string	" "
nullChar:	.string	"\0"
separator:	.string	"\t"
charString:	.string "%s"
fiveSpace:	.string	"     "
tenSpace:	.string	"          "
decimalString:	.string	"%4.2f     "


// User input messages
welcomeMessage:	.string	"\nWelcome to Bomberman, %s! What would you like to do?\n\n"
topScoresMessage: .string  "To see top scores, enter 'scores'.\n"
playMessage:	.string	"To play, enter 'play'.\n"
exitMessage:	.string	"To exit, enter 'exit'.\n\n"
stringInput:	.string	"%s"
exitOption:	.string	"exit"
playOption:	.string	"play"
scoreOption:	.string	"scores"
inputErrorMessage:	.string	"\nInvalid option.\n"
quitMessage:	.string	"\nExiting program. Goodbye.\n"


//Score messages
scoreMenuMessage:	.string "\nEnter top number of records. Enter 'back' to return to main menu.\n"
backOption:	.string	"back"
invalidSearchMessage:	.string	"\nError. Invalid input. Must enter more than 0 records.\n\n"
insufficientRecordsMessage:	.string	"\nNot enough games played to display that number of records.\n"
readingFileErrorMessage:	.string	"An error occurred while trying to read the log data.\n\n"


	.balign 4
	.global main
	

// Macros for main
	
define(fp, x29)			// Frame pointer 
define(lr, x30)			// Link register
	
define(argc_r, x19)		// Number of arguments in command-line
define(argv_r, x20)		// Address of base of array of pointers to command-line arguments
	
define(M_r, w21)		// Number of rows (M)
define(N_r, w22)		// Number of columns (N)
	
M_s = 4					// Size of M
N_s = 4					// Size of N
Name_s = 8				// Size of address of character array representing player name
	
M_l = 16				// Location of M in main stack
N_l = 20				// Location of N in main stack
Name_l = 24				// Location of address of character array representing player name in stack

arg0_offset = 0			// Offset of first argument of command-line
arg1_offset = 8			// Offset of second argument of command-line
arg2_offset = 16		// Offset of third argument of command-line
arg3_offset = 24		// Offset of fourth argument of command-line
	
main_alloc = -(16 + M_s + N_s + Name_s) & -16		// Space allocated for main
main_dealloc = -(main_alloc)					// Space to be deallocated for main
	
	
	
	
	
	
	
// main runs the program
//	Args: int argc, *char[] argv
// Returns void

main:
	stp		fp,		lr,		[sp, main_alloc]!			// Allocate space on stack
	mov		fp,		sp									// Move fp to sp
	
	mov		argc_r,	x0		// Number of arguments in command-line
	mov		argv_r, x1		// Address of base of array of command-line arguments
	
	cmp		argc_r,	4		// Compare number of command-line arguments to 3
	b.lt	tooFewArgs		// If less than 4, branch to tooFewArguments
	b.gt	tooManyArgs		// If more than 4, branch to tooManyArgs
	
	ldr		x0,		[argv_r, arg1_offset]	// Loading M (number of rows) to x0
	bl		atoi							// Converting array to integer
	cmp		x0,		10						// Comparing M to 10
	b.lt	rowError						// If less than 10, branch to rowError
	cmp		x0,		100						// Comparing M to 100
	b.gt	rowError						// If more than 100, branch to rowError
	str		x0,		[fp, M_l]				// Otherwise, store M in stack
	ldr		M_r,	[fp, M_l]				// Set M_r to M
	
	ldr		x0,		[argv_r, arg2_offset]	// Loading N (number of columns) to x0
	bl		atoi							// Converting array to integer
	cmp		x0,		10						// Comparing N to 10
	b.lt	colError						// If less than 10, branch to colError
	cmp		x0,		20						// Comparing N to 20
	b.gt	colError						// If more than 20, branch to colError
	str		x0,		[fp, N_l]				// Otherwise, store M in stack
	ldr		N_r,	[fp, N_l]				// Set N_r to N
	
	add		x2,		argv_r, arg3_offset		// Load address of name to x0
	str		x2,		[fp, Name_l]			// Store address of name to stack
		
	bl		initializeScoreSheet
	b		GetUserInput 
	b		End
	
// Display error message if less than 3 command-line arguments given
tooFewArgs:
	ldr		x0,		=tooFewArgsMessage		// Load error message
	bl		printf							// Print error message
	b		End								// Branch to End
		
// Displays error message if more t han 3 command-line arguments given
tooManyArgs:
	ldr		x0,		=tooManyArgsMessage		// Load error message
	bl		printf							// Print error message
	b		End								// Branch to End
			
// Displays error message in case of invalid number of rows
rowError:
	mov		x1,		x0						// Row number
	ldr		x0,		=rowErrorMessage		// Load error message
	bl		printf							// Print error message
	b		End								// Branch to End

// Displays error message in case of invalid number of columns
colError:
	mov		x1,		x0						// Column number
	ldr		x0,		=colErrorMessage		// Load error message
	bl		printf							// Print error message
	b		End								// Branch to End


// Get the user input
GetUserInput:
	ldr		x0,		=welcomeMessage
	ldr		x9,		[fp, Name_l]			// Pointer to pointer to name array
	ldr		x1,		[x9]					// Pointer to array 
	bl		printf	
	
	ldr		x0,		=topScoresMessage		// Option to see top scores
	bl		printf
	
	ldr		x0,		=playMessage			// Option to play
	bl		printf

	ldr		x0,		=exitMessage			// Option to exit
	bl		printf
	
	// Scan user input
	ldr		x0,		=stringInput
	ldr		x1,		=userInput
	bl		scanf
	
	// Check if user wants to quit
	ldr		x0,		=exitOption
	ldr		x1,		=userInput
	bl		strcmp
	cmp		x0,		0
	b.eq	Quit
	
	// Check if user wants to see scores
	ldr		x0,		=scoreOption
	ldr		x1,		=userInput
	bl		strcmp
	cmp		x0,		0
	b.eq	Scores
	
	// Check if user wants to play
	ldr		x0,		=playOption
	ldr		x1,		=userInput
	bl		strcmp
	cmp		x0,		0
	b.eq	Play
	
	// If no option was given, print error message
	ldr		x0,		=inputErrorMessage
	bl		printf
	b		GetUserInput

// User wants to exit program
Quit:
	ldr		x0,		=quitMessage	
	bl		printf
	b		End

// User wants to play
Play:
	ldr		x0,		[fp, Name_l]	// Pointer to pointer of name
	ldr		w1,		[fp, M_l]		// M
	ldr		w2,		[fp, N_l]		// N
	SXTW	x1,		w1
	SXTW	x2,		w2
	bl		console
	
	// Get game statistics 
    adrp            x0,             finalDuration
	add             x0,             x0,             :lo12:finalDuration
	ldr             d0,             [x0]

    adrp            x0,             finalTotalScore
    add             x0,             x0,             :lo12:finalTotalScore
    ldr             d1,             [x0]

  	ldr				x0,				[fp, Name_l]	
   
    adrp            x9,             finalQuit
    add             x9,             x9,             :lo12:finalQuit
    ldr             x1,             [x9]
    
	bl				exitGame
	b				GetUserInput

// User wants to see scores		
Scores:
	bl		scoreMenu
	b		GetUserInput	

// End terminates main method	
End:
	ldp		fp,		lr,		[sp], 		main_dealloc		// Deallocate space for method
	ret														// Return 
	
	
	

// exitGame terminates the game, and checks if user quit the game or not
exitGame:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp
	
	cmp		x1,		1
	b.eq	EndExitGame	
	bl		logScore		// If user did not quit game, log their score
	
// Terminate method	
EndExitGame:
	ldp		fp,		lr,		[sp], 		16		// Deallocate space for method
	ret												
	







// scoreMenu allows the user to input how many records they want to search	
scoreMenu:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp	
	b		GetSearchNumber

// Gets user input	
GetSearchNumber:		
	ldr		x0,		=scoreMenuMessage
	bl		printf
	
	// Scan user input
	ldr		x0,		=stringInput
	ldr		x1,		=userInput
	bl		scanf
	
	// Check if user wants to go back
	ldr		x0,		=userInput
	ldr		x1,		=backOption
	bl		strcmp
	cmp		x0,		0
	b.eq 	EndScoreMenu
	
	// Check if user entered an invalid number
	ldr		x0,		=userInput
	bl		atoi
	cmp		x0,		0
	b.le	InvalidNumberError
	
	// Otherwise, call displayTopScores
	bl		displayTopScores
	b		GetSearchNumber

// User gave invalid number	
InvalidNumberError:
	ldr		x0,		=invalidSearchMessage
	bl		printf
	b		GetSearchNumber

// Terminate method
EndScoreMenu:
	ldp		fp,		lr,		[sp],	16
	ret
		
	
	
//



define(File_dr, x23)	
	

// initializeScoreSheet sets up the log file that displays the user scores
// args: none
// return void

initializeScoreSheet:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp
	
	// Check if log file exists
	mov		x0,		-100					// File in program directory
	ldr		x1,		=logFileName						
	mov		x2,		0302					// Read-write || Create if no file || Fail if exists
	mov		x3,		0777					// Read-write permission for everyone 
	mov		x8,		56						// Open I/O request
	svc		0								// Call system function
	
	cmp		x0,		0						// Check if file already exists
	b.lt	EndInitializeScoreSheet
	
	mov		File_dr,		x0				// Move file descriptor to File_dr
	
	// Write "Name" header
	mov		x0,		File_dr
	ldr		x1,		=nameHeader
	mov		x2,		20
	mov		x8,		64
	svc		0
	cmp		x0,		0
	b.lt	logFileError
	
	// Write "Score" header
	mov		x0,		File_dr
	ldr		x1,		=scoreHeader
	mov		x2,		20
	mov		x8,		64
	svc		0
	cmp		x0,		0
	b.lt	logFileError
	
	// Write "Duration" header
	mov		x0,		File_dr
	ldr		x1,		=durationHeader
	mov		x2,		9
	mov		x8,		64
	svc		0
	cmp		x0,		0
	b.lt	logFileError
	
	// Close file
	mov		x0,		File_dr
	mov		x8,		57
	b		EndInitializeScoreSheet

// Executed if writing to file is disrupted
logFileError:
	ldr		x0,		=logFileErrorMessage
	bl		printf

// Terminate method	
EndInitializeScoreSheet:
	ldp		fp,		lr,		[sp],	16
	ret	


	
//
	
	
	
address_s = 8
double_s = 8

// displayTopScores gets data from log file, processes it and displays to user
displayTopScores:
	stp		x29,		x30,		[sp, -16]!
	mov		x29,		sp
	
	mov		x19,	x0			// Number of scores to be searched
	
	// Get number of records
	bl		getNumberRecords
	mov		x20,	x0			// number of records available
	
	// check if records < n
	cmp		x20,	x19
	b.lt	NoRecordsAvailableError

	// OpenFile
	mov		x0,		-100		// file in directory of program
	ldr		x1,		=logFileName
	mov		x2,		00			// read only access
	mov		x8,		56
	svc		0
	cmp		x0,		0
	b.lt	ReadingLogFileError
	mov		x28,	x0
	b		GetToFirstRecord

// Get to first line after header in log file
GetToFirstRecord:
	// Read a character
	mov		x0,		x28			// file descriptor 
	ldr		x1,		=readBuffer
	mov		x2,		1
	mov		x8,		63
	svc		0

	// Compare character to \n
	ldr		x0,		=readBuffer
	ldr		x1,		=lineString
	bl		strcmp
	
	// If \n was read, we have reached the first character
	cmp		x0,		0
	b.ne	GetToFirstRecord
	b		AllocateArraySpace

// Allocate space on stack to store log data	
AllocateArraySpace:
	mov		x11,	3				// 3 entries per record
	mul		x20,	x20,	x11		// Number of arrays in log file
	
	// Allocate space for array of pointers 
	mov		x9,		address_s
	mul		x10,	x9,		x20		// Num records * 8 bytes
	sub		x10,	xzr,	x10		// make negative
	and		x10,	x10,	-16		// and
	add		sp,		sp,		x10
	sub		x21,	x29,	8		// Base address of array 
	mov		x22,	x10				// Space for array
	b		ReadLogData

// Copying data of log file to allocated space in stack	
ReadLogData:
	sub		sp,		sp,		16		// Allocate space to store data from log file
	sub		x25,	sp,		1		// Pointer to log file data array
	mov		x23,	0				// # char until " " seen
	mov		x24,	0				// iterator
	mov		x26,	x25				// Base address of each array in the log file

// Reading each character in log file	
ReadChar:	
	// Store new character in read buffer
	mov		x0,		x28				// file descriptor 
	ldr		x1,		=readBuffer
	mov		x2,		1
	mov		x8,		63
	svc		0
	cmp		x0,		0
	
	// Check if we reached a separator
	ldr		x0,		=readBuffer
	ldr		x1,		=separator
	bl		strcmp
	cmp		x0,		0
	b.eq	ReadArray
	
	// Check if we reached a space
	ldr		x0,		=readBuffer
	ldr		x1,		=space
	bl		strcmp	
	cmp		x0,		0
	b.eq	ReadArray
	
	// Check if we reached a new line
	ldr		x0,		=readBuffer
	ldr		x1,		=lineString
	bl		strcmp
	cmp		x0,		0
	b.eq	ReadArray
	
	// Otherwise, copy character to log data array
	b		CopyChar

// Copy character to stack	
CopyChar:
	mov		w1,		0
	ldr		x0,		=readBuffer
	ldrb	w1,		[x0]
	strb	w1,		[x25]
	
	add		x23,	x23,	1
	sub		x25,	x25,	1
	
	// check if we reached 16 bytes
	cmp		x23,	16
	b.eq	AllocateSpace
	b		ReadChar			// Otherwise, read next character

// Allocate 16 more bytes in stack if needed	
AllocateSpace:
	sub		sp,		sp,		16		
	mov		x23,	0
	b		ReadChar

// Store the address of each array in array of pointers 	
ReadArray:
	// Allocate more space on buffer
	sub		sp,		sp,		16
	
	// Copy separator to delimit each array being stored in log data array
	ldr		x0,		=separator
	ldr		x1,		[x0]
	strb	w1,		[x25]
	
	
	sub		x25,	x25,	1			// Increment char pointer
	sub		x10,	xzr,	x24
	str		x26,	[x21, x10, lsl 3]	// Store address of the array in array of pointers
	add		x24,	x24,	1			// Increment iterator by 1
	
	mov		x26,	x25					// Set pointer to new array
	
	cmp		x24,	x20					// Check if all records have been copied				
	b.lt	NextWord					// If not, find the next word in the log file
	
	// Call readLogData
	mov		x0,		x21					
	mov		x1,		x20
	mov		x2,		x19
	bl		readLogData
	
	// Once everything is done, do away with all of the space that was stored
	mov		x9,		sp
	sub		x9,		x9,		x29
	sub		sp,		sp,		x9
	b		EndDisplayTopScores

// Find next array after previous array is stored 
NextWord:
    // Get character in read buffer
    mov     x0,      x28                     // file descriptor 
    ldr     x1,      =readBuffer
    mov     x2,      1
    mov     x8,      63
    svc     0
    cmp     x0,      0

    // Check if we reached a separator
    ldr     x0,       =readBuffer
    ldr     x1,       =separator
    bl      strcmp
    cmp     x0,       0
    b.eq    NextWord

    // Check if we reached a space
    ldr     x0,       =readBuffer
    ldr     x1,       =space
    bl      strcmp
    cmp     x0,       0
    b.eq    NextWord

    // Check if we reached a new line
    ldr     x0,        =readBuffer
    ldr     x1,        =lineString
    bl      strcmp
    cmp     x0,        0
    b.eq    NextWord
	b		CopyChar	

// Error messaging if user wants to search for more records than are available 
NoRecordsAvailableError:
	ldr		x0,			=insufficientRecordsMessage
	bl		printf
	b		EndDisplayTopScores

// Error messaging if issue appears while reading log file
ReadingLogFileError:
	ldr		x0,			=readingFileErrorMessage
	bl		printf
		
// Terminate method
EndDisplayTopScores:
	ldp		x29,		x30,	[sp], 16
	ret
	
	
	
	
	
	
	


// readLogData processes the raw bytes in the log data array, and stores them into separate rows recording game scores and duration
//

readLogData:
	stp		x29,		x30,		[sp, -16]!
	mov		x29,		sp
	
	// Store arguments
	mov		x19,	x0			// Address of log data array
	mov		x20,	x1			// Number of arrays in log data
	mov		x21,	x2			// Number of records to be searched
	
	mov		x11,	3			// 3 entries per record
	udiv	x20,	x20,	x11	// number of entries per category (name, score, duration)
	
	// Allocate space for Array of Scores
	mov		x10,	8			// 8 bytes
	mul		x10,	x10,	x20	
	sub		x10,	xzr,	x10
	and		x10,	x10,	-16	// Padded bytes
	add		sp,		sp,		x10
	sub		x22,	x29,	8	// Base address of scores array
	b		ReadScores

// Sets up algorithm to store scores for each record	
ReadScores:
	mov		x23,	0			// Iterator for scores array
	mov		x26,	0			// Iterator for log data array
	b		ReadScoresTest

// Set up pointers and buffers 
ReadScoresLoop:
	// Load pointer to every second array from log data array
	add		x10,	x26,	1
	sub		x10,	xzr,	x10
	ldr		x24,	[x19, x10, lsl 3]	// Address to each array in log data array
	ldr     x25,    =stringFloat		// Buffer to store characters in 
	b		CopyScoreTest

// Copy each character representing the score in the raw log data file to a buffer
CopyScoreTest:
	ldrb		w0,		[x24]
	ldr			x1,		=readBuffer
	strb		w0,		[x1]	
	
	// Check if separator reached 
	ldr		x0,		=readBuffer
	ldr		x1,		=separator
	bl		strcmp
	cmp		x0,		0
	b.eq		ScoreCopied				// if separator reached, branch to ScoreCopied

	// Otherwise, update pointers to copy next character to buffer
	ldrb	w0,			[x24]
	strb	w0,			[x25]
	add		x25,		x25,	1
	sub		x24,		x24,	1
	b 		CopyScoreTest		

// Executed once each array of text representing a score is copied in buffer
ScoreCopied:
	// Convert array to double
	ldr		w0,			=nullChar
	strb	w0,			[x25]
	ldr		x0,		=stringFloat
	bl		atof
	
	// Store double in scores array
	sub		x10,		xzr,	x23
	str		d0,		[x22, x10, lsl 3]
	add		x23,		x23,	1
	add		x26,		x26,	3

// Iterate through data until all scores read
ReadScoresTest:
	cmp		x23,	x20			
	b.lt	ReadScoresLoop

	// Allocate space for durations array
	mov     x10,    8                       // 8 bytes
    mul     x10,    x10,    x20     // 48 bytes
    sub     x10,    xzr,    x10
    and     x10,    x10,    -16     // padded bytes
    mov     x27,    x10                 // space for scores array
	sub		x28,	sp,	 	8			// Base addrss of duration array
    add     sp,     sp,     x27
    b       ReadDurations

// Sets up algorithm to store durations for each record
ReadDurations:
    mov     x23,    0                       // iterator
    mov     x26,    0
    b       ReadDurationTest

// Set up pointers and buffers 
ReadDurationLoop:
    // Load every third array
    add             x10,    x26,    2
    sub             x10,    xzr,    x10
    ldr             x24,    [x19, x10, lsl 3]       // address of array 
    ldr             x25,            =stringFloat
    b               CopyDurationTest

// Copy each character representing the score in the raw log data file to a buffer
CopyDurationTest:
    ldrb            w0,             [x24]
    ldr             x1,             =readBuffer
    strb            w0,             [x1]

    ldr             x0,             =readBuffer
    ldr             x1,             =separator
    bl              strcmp
    cmp             x0,             0
    b.eq            DurationCopied

    ldrb            w0,             [x24]
    strb            w0,             [x25]
    add             x25,            x25,    1
    sub             x24,            x24,    1
    b               CopyDurationTest

// Executed once each array of text representing a score is copied in buffer
DurationCopied:
	ldr				w0,				=nullChar
	strb			w0,				[x25]
		
    ldr             x0,             =stringFloat
    bl              atof

    sub             x10,            xzr,    x23
    str             d0,             [x28, x10, lsl 3]
    add             x23,            x23,    1
    add             x26,            x26,    3

// Iterate through data until all scores read
ReadDurationTest:
    cmp             x23,    x20
    b.lt    ReadDurationLoop
	
	// Create space for array of indexes
	mov		x9,		4
	mul		x10,	x20,	x9
	sub		x10,	xzr,	x10
	and		x10,	x10,	-16		// space allocated for frequency array
	sub		x23,	sp,		4		// Base address of frequency array
	add		sp,		sp,		x10		// Allocating space 		
	
	// Call sort
	mov		x0,		x22				// Scores
	mov		x1,		x23				// Array of Indexes
	mov		x2,		x20				// Number of records
	bl		sortScores
	
	// Call display scores
	mov		x0,		x19				// Log array
	mov		x1,		x22				// Scores
	mov		x2,		x28				// Duration
	mov		x3,		x23				// Sorted indices
	mov		x4,		x21				// n
	bl		displayScores
		
		
	// Deallocate space for all arrays on stack
	// Once everything is done, do away with all of the space that was stored
	mov		x9,		sp
	sub		x9,		x9,		x29
	sub		sp,		sp,		x9
		
	ldp		x29,		x30,		[sp],	16
	ret
	
	







// displayScores prints each record from the log file in order of increasing score

displayScores:
	stp		fp,		lr,		[sp, -16]!		// Allocate space in stack for method
	mov		fp,		sp					
	
	// Set up arguments
	mov		x19,	x0					// Log array (raw data of log file)
	mov		x20,	x1					// Scores array
	mov		x21,	x2					// Duration array 
	mov		x22,	x3					// Sorted indices
	mov		x23,	x4					// n
	
	// Method variables
	mov		x24,	0					// Name iterator
	mov		x25,	1					// Score iterator
	mov		x26,	2					// Duration iterator
	mov		x27,	0					// record number
	mov		x28,	0					// record iterator 
	
	
	// Print Score sheet headers
	ldr		x0,		=lineString
	bl		printf
	
	ldr		x0,		=nameHeader
	bl		printf
	
	ldr		x0,		=scoreHeader
	bl		printf
	
	ldr		x0,		=durationHeader
	bl		printf
	
	b		DisplayScoresTest

// Prints name, score and duration for each record	
DisplayScoresLoop:
	sub		x9,		xzr,	x28
	ldr		w27,	[x22, x9, lsl 2]
	SXTW	x27,	w27
	
	// Get Name
	mov		x9,		3
	mul		x9,		x27,	x9
	sub		x9,		xzr,	x9
	ldr		x0,		[x19, x9, lsl 3]	// array of name
	bl		printArray
		
	// Print score
	sub		x9,		xzr,	x27
	ldr		d0,		[x20, x9, lsl 3]	// score
	mov		x0,		8
	ldr		x1,		=freeBuffer
	bl		gcvt
	ldr		x0,		=freeBuffer
	bl		printDecimal
	
	// Print Duration
	sub		x9,		xzr,	x27
	ldr		d0,		[x21, x9, lsl 3]	// score
	mov		x0,		8
	ldr		x1,		=freeBuffer
	bl		gcvt
	ldr		x0,		=freeBuffer
	bl		printDecimal
	
	// Print new line
	ldr		x0,		=lineString
	bl		printf
	
	
	add		x28,		x28,		1

// Iterate until we have displayed the top number of records searched by the user	
DisplayScoresTest:
	cmp		x28,	x23
	b.lt	DisplayScoresLoop	
	
	ldp		x29,		x30,		[sp],	16
	ret
	





// printDecimal prints strings representing double values with aligned spacing when displaying log files
//
printDecimal:
	stp		fp,		lr,		[sp, -32]!		
	mov		fp,		sp
	
	// Store callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	
	// Store arguments
	mov		x19,	x0				// Pointer to string
	bl		strlen
	mov		x2,		x0
	
	// Subtract size of array from 20 char
	mov		x9,		20
	sub		x20,	x9,		x2
	
	// Print the array
	mov		x0,		1
	mov		x1,		x19
	mov		x8,		64
	svc		0
	
	// Check if any white space remaining, and print if so
	cmp		x20,	0
	b.le	EndPrintDecimal
	
	mov		x0,		1
	ldr		x1,		=twentySpaceString
	mov		x2,		x20
	mov		x8,		64
	svc		0

// Terminate method	
EndPrintDecimal:
	// Restore callee-saved registers
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]
	
	ldp		x29,		x30,		[sp],	32
	ret	
	





// printArray prints an array
printArray:
	stp		fp,		lr,		[sp, -32]!		// Allocate space in stack for method
	mov		fp,		sp		
	
	// Store callee-saved registers
	str		x19,	[fp, 16]
	str		x20,	[fp, 24]
	
	// Store arguments
	mov		x19,	x0						// Base of array
	mov		x20,	0						// Number of characters
	
	b		ArrayLoop

// Print each character until a separator encountered	
ArrayLoop:
	// Get each character from array
	mov		x0,		0
	ldrb	w0,		[x19]
	ldr		x1,		=readBuffer	
	strb	w0,		[x1]
	
	// Check if character is separator
	ldr		x0,		=readBuffer
	ldr		x1,		=separator	
	bl		strcmp
	cmp		x0,		0
	b.eq	PrintWhiteSpace
	
	// If not, print the character
	mov		x0,		1
	ldr		x1,		=readBuffer
	mov		x2,		1
	mov		x8,		64
	svc		0
	
	// Update pointer to array, and increment number of characters printed
	sub		x19,	x19,	1
	add		x20,	x20,	1
	
	b		ArrayLoop

// Prints white space, if less than 20 characters printed so far	
PrintWhiteSpace:
	// Check if 20 characters have not been printed yet
	mov		x9,		20
	sub		x9,		x9,		x20		// Space remaining 
	cmp		x9,		0
	b.le	EndPrintArray
	
	// If so, print remaining characters as white space
	mov		x0,		1
	ldr		x1,		=twentySpaceString
	mov		x2,		x9
	mov		x8,		64
	svc		0
	
	b		EndPrintArray

// Terminate method	
EndPrintArray:
	ldr		x19,	[fp, 16]
	ldr		x20,	[fp, 24]

	ldp		x29,		x30,		[sp],	32
	ret








// Macros for sort

define(smaller_r, x11) 		// represents number of times a frequency is smaller than other frequencies in the array
define(i_r, x9)				// i
define(j_r, x10)			// j
define(compare_r, d9)		// Frequency of word being compared against other words
define(compareTo_r, d10) 	// Frequency of other words being compared to compare_r


	// sort fills in the Index array based on the order of frequencies in the Frequency array
// args:
//	x0: Scores array
//	x1: Index array
//  x2: Number of records
// returns void	

sortScores:
	stp		fp,		lr,		[sp, -16]!		// Allocate space in stack for method
	mov		fp,		sp						// Move fp to sp
	
	mov		i_r,		0					// i = 0
	b		InitializeSortedArray			// Branch to InitializeSortedArray

// Set every value in Index array to -1
InitializeSortedArray:
	sub		x12,	xzr,	i_r
	mov		w10,	-1						// -1
	str		w10,	[x1, x12, lsl 2]		// Store -1 at each offset in Index array
	add		i_r,	i_r,		1			// Increment i by 1
	cmp		i_r,		x2					// Compare i to num records
	b.lt	InitializeSortedArray			// If i < num records, loop again
	mov		i_r,		0					// Otherwise, reset i to 0
	mov		j_r,		0					// j = 0
	mov		smaller_r,	0					// smaller: represents number of times a frequency is smaller than other frequencies in the array
	b		SortTest						// Branch to SortTest

// Get frequency of each word that is being compared against other words 
GetCompare:
	sub		x12,	xzr,	i_r
	ldr		compare_r,	[x0, x12, lsl 3]	// Frequency of word being compared against other words
	b		Compare							// branch to Compare

// Compares frequency of each word against other words 
Compare:
	cmp		j_r,	x2						// Compare j to num records
	b.ge	TestIndex	
	sub		x12,	xzr,	j_r					// If j >= M, branch to TestIndex
	ldr		compareTo_r, [x0, x12, lsl 3]	// Otherwise, get frequency of each word
	add		j_r,	j_r,	1				// Increment j by 1
	fcmp	compare_r,		compareTo_r		// Compare frequency of word being compared against this second word
	b.ge	Compare							// If the frequency of the comparing word is greater or equal, re-loop
	add		smaller_r,	smaller_r,	1		// Otherwise, increment smaller by 1 
	b		Compare							// Re-loop again 

// Find the next available slot in Index array to place index of each word
TestIndex:
	sub		x13,	xzr,	smaller_r
	ldr		w12,	[x1, x13, lsl 2]		// Load integer at each offset
	cmp		w12,	-1						// Compare integer to -1
	b.eq	PlaceIndex						// If integer equals -1, branch to PlaceIndex
	add		smaller_r,	smaller_r,	1		// Otherwise, increment smaller by 1, and
	b		TestIndex						// re-loop again 

// Place index of each word in Index array
PlaceIndex:
	sub		x13,	xzr,	smaller_r
	str		w9,		[x1, x13, lsl 2]	// Store index to Index Array at appropriate offset 
	add		i_r,	i_r,		1			// Increment i by 1 to compare a new word against other words 
	mov		j_r,	0						// Reset j = 0
	mov		smaller_r,	0					// Reset smaller = 0
	b		SortTest						// Branch to SortTest 

// Check every frequency in the Frequency array 	
SortTest:
	cmp		i_r,		x2					// Compare i to num records
	b.lt	GetCompare						// If i < M, branch to getCompare
	
	ldp		fp,		lr,		[sp], 16		// Deallocate space on stack		 	
	ret										// Return 
	
		
	
	
	
	
	
	
	
// getNumberRecords determines number of records in log file	

getNumberRecords:
	stp		x29,		x30,		[sp, -32]!
	mov		x29,		sp
	
	// Store callee-saved register
	str		x19,		[x29, 16]
	
	// Open file
	mov		x0,		-100		// file in directory of program
	ldr		x1,		=logFileName
	mov		x2,		00			// read only access
	mov		x8,		56
	svc		0

	// Set up variables
	mov		x20,	x0			// file descriptor 
	mov		x21,	-1			// Number of records
	b		FindNextLine

// Iterate through each character in log file until "\n" is found
FindNextLine:
	// Read single character
	mov		x0,		x20			// file descriptor 
	ldr		x1,		=readBuffer
	mov		x2,		1
	mov		x8,		63
	svc		0
	cmp		x0,		0
	// b.lt	FileError
	
	// Check if \n is found
	ldr		x0,		=readBuffer
	ldr		x1,		=lineString
	bl		strcmp
	cmp		x0,		0
	b.ne	FindNextLine		// If \n not found, loop again 
	b		FoundALine			// Otherwise, branch to FoundALine

// Executed each time an \n char found in log file
FoundALine:
	add		x21,	x21,	1	// Increment each time a line is found
	
	// Read next character
	mov		x0,		x20			// file descriptor 
	ldr		x1,		=readBuffer
	mov		x2,		1
	mov		x8,		63
	svc		0

	// If this character is also \n, we have reached end of file
	ldr		x0,		=readBuffer
	ldr		x1,		=lineString
	bl		strcmp
	cmp		x0,		0
	b.eq	readFileEnd
	b		FindNextLine

// Terminates method 	
readFileEnd:
	mov		x0,		x20
	mov		x8,		57
	svc		0
	
	mov		x0,		x21
	
	ldr		x19,	[x29, 16]
		
	ldp		x29,		x30,		[sp],	32
	ret
	
	
	
	
	
	
	
		
// logScore logs the player name, final score and duration of the gameplay after each win or loss
//
logScore:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp
	
	// Store arguments
	fmov		d19,	d0		 			// duration
	fmov		d20,	d1					// final total score
	ldr			x19,	[x0]				// Name
	
	// Round duration to two decimal points
	fmov		d0,		d19
	bl		roundDecimal
	fmov		d19,	d0
	
	// Round total score to two decimal points
	fmov		d0,		d20
	bl		roundDecimal
	fmov		d20,	d0
	
	// Open up file
	mov		x0,		-100			// File in relative path
	ldr		x1,		=logFileName	// Name of log file
	mov		x2,		02001			// Write-only access || Append 
	mov		x8,		56				// open I/O request
	svc		0						// Call system function
	
	cmp		x0,		0				// error check
//	b.lt	errorLoggingFile
	
	mov		x23,	x0				// 	File descriptor 
	b		WriteName

// Write player name in log file
WriteName:	
	// Get length of name
	mov		x0,		x19				// Name
	bl		strlen
	mov		x20,	x0				// Length of the name
	
	// Write name
	mov		x0,		x23
	mov		x1,		x19
	mov		x2,		x20
	mov		x8,		64
	svc		0
	cmp		x0,		0
//	b.lt	errorLoggingFile

	// Subtract number of characters written from 20, and check if characters remaining
	mov		x9,		20
	sub		x9,		x9,		x20
	cmp		x9,		0
	b.le	WriteScore
	
	// If characters remaining, write as white space
	mov		x0,		x23
	ldr		x1,		=twentySpaceString	
	mov		x2,		x9
	mov		x8,		64
	svc		0
	cmp		x0,		0
//	b.lt	errorLoggingFile
	b		WriteScore

// Write score in log file
WriteScore:
	// Convert score to string
	fmov	d0,		d20
	mov		x0,		8
	ldr		x1,		=freeBuffer	
	bl		gcvt
	
	// Get length of string
	ldr		x0,		=freeBuffer
	bl		strlen
	mov		x20,		x0
	
	// Write the score
	mov		x0,		x23
	ldr		x1,		=freeBuffer
	mov		x2,		x20
	mov		x8,		64
	svc		0
	cmp		x0,		0
//	b.lt	errorLoggingFile

	// Subtract number of characters written from 20, and check if characters remaining
	mov		x9,		20
	sub		x9,		x9,		x20
	cmp		x9,		0
	b.le	WriteDuration
	
	// If characters remaining, write as white space
	mov		x0,		x23
	ldr		x1,		=twentySpaceString	
	mov		x2,		x9
	mov		x8,		64
	svc		0
	cmp		x0,		0
//	b.lt	errorLoggingFile
	b		WriteDuration

// Write duration in log file	
WriteDuration:
	// Convert duration to string
	fmov	d0,		d19
	mov		x0,		8
	ldr		x1,		=freeBuffer	
	bl		gcvt
	
	// Get length of string
	ldr		x0,		=freeBuffer
	bl		strlen
	mov		x20,		x0
	
	// Write duration
	mov		x0,		x23
	ldr		x1,		=freeBuffer
	mov		x2,		x20
	mov		x8,		64
	svc		0
	cmp		x0,		0
//	b.lt	errorLoggingFile

	// Write a line
	mov		x0,		x23
	ldr		x1,		=lineString
	mov		x2,		1
	mov		x8,		64
	svc		0
	cmp		x0,		0
//	b.lt	errorLoggingFile

	// Close file
	mov		x0,		x23
	mov		x8,		57
	svc		0
	
	b		EndLogScore

// Terminate method	
EndLogScore:	
	ldp		fp,		lr,		[sp],	16
	ret
	
		
	



// roundDecimal rounds a double to two precision points
//
roundDecimal:
	stp		fp,		lr,		[sp, -16]!
	mov		fp,		sp
	
	mov		x9,		100
	SCVTF	d1,		x9
	
	fmul	d0,		d0,		d1
	fcvtns	x9,		d0
	
	SCVTF	d0,		x9
	fdiv	d0,		d0,		d1		
	
	
	ldp		fp,		lr,		[sp],	 16
	ret

	
	
	
	


	.bss
userInput:      .skip   20
freeBuffer:     .skip   20
readBuffer: 	.skip       1
junkBuffer:     .skip   3
stringFloat:    .skip   20






	
	
