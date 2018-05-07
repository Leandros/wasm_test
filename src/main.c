
#define EXPORT __attribute__((visibility("default")))

extern void putc(char c);
extern void puts(char const *);

EXPORT int
main(void)
{
    puts("hello, world");
    return 0;
}

EXPORT void
puts(char const *s)
{
    while (*s)
        putc(*s++);
}

