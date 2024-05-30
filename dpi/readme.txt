linux:
make 

windows:
gcc -I/usr/include -fPIC -shared -o server.dll server.c -lws2_32 