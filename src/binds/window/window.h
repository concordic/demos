#ifndef WINDOW_H
#include <GLFW/glfw3.h>
#define WINDOW_H


GLFWwindow* initWindow(int width, int height, const char* name);

void updateWindow(GLFWwindow* window, int (*loop)(void));

void deinitWindow(GLFWwindow* window);

#endif
