#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main() {
    char op[6]; // max 5 chars for op name
    int a, b;

    // keep reading until eof
    while (scanf("%5s %d %d", op, &a, &b) == 3) {

        // build the .so path from the op name
        char path[32];
        snprintf(path, sizeof(path), "./lib%s.so", op);

        // load the shared library at runtime
        void *handle = dlopen(path, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "dlopen failed for '%s': %s\n", op, dlerror());
            continue;
        }

        // flush any stale error before calling dlsym
        // (dlsym can return NULL for valid reasons so we check dlerror instead)
        dlerror();

        typedef int (*op_func_t)(int, int);
        op_func_t func = (op_func_t)dlsym(handle, op);

        char *err = dlerror();
        if (err) {
            fprintf(stderr, "dlsym failed: %s\n", err);
            dlclose(handle);
            continue;
        }

        printf("%d\n", func(a, b));

        // close after each op so only one .so is in memory at a time
        dlclose(handle);
    }

    return 0;
}