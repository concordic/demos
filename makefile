CC = clang
CFLAGS = -Iinclude -framework Cocoa -framework OpenGL -framework IOKit

LIBS = $(wildcard lib/*.a)

main: src/main.o ${LIBS}
	${CC} ${CFLAGS} $^ -o main
