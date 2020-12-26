myProg:	main.o	game.o
	gcc main.o game.o -o myExec

main.o: main.s
	as main.s -o main.o

main.s: main.asm
	m4 main.asm > main.s

game.o: game.s
	as game.s -o game.o

game.s: game.asm
	m4 game.asm > game.s
