#include <assert.h>
#include <GLFW/glfw3.h>

GLFWwindow* windowInit(int width, int height, const char* name) {
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

void windowUpdate(GLFWwindow* window, int (*loop)(void*), void* data) {
	assert(window);
	while (!glfwWindowShouldClose(window)) {
		glfwPollEvents();
		int result = loop(data);
		if (result != 0) break;
	}
}

void windowDeinit(GLFWwindow* window) {
	assert(window);
	glfwDestroyWindow(window);
	glfwTerminate();
}
