#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

#include <uci.h>
#include <string.h>


// Portion de code d'après https://rosettacode.org/wiki/Hello_world/Web_server#C
//
//
int main(int argc, char **argv)
{

    // Recupération des paramètres de configuration depuis 'uci'
    //
    struct uci_context *uci_c;
    struct uci_ptr      uci_p;
    char               *uci_lookup_text;
    #define MESSAGE_SIZE 128
    char message[MESSAGE_SIZE +1];

    uci_c = uci_alloc_context();
    if (uci_c)
    { 
        uci_lookup_text = strdup("helloserver.@server[0].message");

        if (uci_lookup_ptr (uci_c, &uci_p, uci_lookup_text, true) == UCI_OK && uci_p.o != NULL)
            snprintf(message, MESSAGE_SIZE, "%s", uci_p.o->v.string);
        else
            perror("Impossible de lire le message a afficher");
        free(uci_lookup_text);
    }
    else
    {
        perror("Erreur de creation du contexte dans uci_alloc_context");
    }
    uci_free_context (uci_c);


    //
    //
    int one = 1, client_fd;
    struct sockaddr_in svr_addr, cli_addr;
    socklen_t sin_len = sizeof(cli_addr);
    #define RESPONSE_SIZE 1200
    char response[RESPONSE_SIZE +1];

    
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)
        perror("can't open socket");
    
    setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(int));
    
    int port = 8080;
    svr_addr.sin_family = AF_INET;
    svr_addr.sin_addr.s_addr = INADDR_ANY;
    svr_addr.sin_port = htons(port);
    
    if (bind(sock, (struct sockaddr *) &svr_addr, sizeof(svr_addr)) == -1) {
        close(sock);
        perror("Can't bind");
    }
    
    listen(sock, 5);
    while (1) {
        client_fd = accept(sock, (struct sockaddr *) &cli_addr, &sin_len);
        printf("got connection\n");
    
        if (client_fd == -1) {
            perror("Can't accept");
            continue;
        }

        snprintf(response, RESPONSE_SIZE, "HTTP/1.1 200 OK\r\n"
        "Content-Type: text/html; charset=UTF-8\r\n\r\n"
        "<!DOCTYPE html><html><head><title>%s World</title>"
        "<style>body { background-color: #111 }"
        "h1 { font-size:4cm; text-align: center; color: black;"
        " text-shadow: 0 0 2mm red}</style></head>"
        "<body><h1>%s World!</h1></body></html>\r\n", message, message);

        write(client_fd, response, strlen(response) - 1); /*-1:'\0'*/
        close(client_fd);
    }
}

