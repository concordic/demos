#include <assert.h>
#include "window.h"

GLFWwindow* initWindow(int width, int height, const char* name) {
	assert(name);
	glfwInit();
	glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
	glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

	GLFWwindow* window = glfwCreateWindow(
		width, height, name, 
		NULL, NULL
	);
	return window;
}

void updateWindow(GLFWwindow* window, int (*loop)()) {
	assert(window);
	while (!glfwWindowShouldClose(window)) {
		glfwPollEvents();
		int result = loop();
		if (result != 0) break;
	}
}

void deinitWindow(GLFWwindow* window) {
	assert(window);
	glfwDestroyWindow(window);
	glfwTerminate();
}
