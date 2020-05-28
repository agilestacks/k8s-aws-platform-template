package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
)

func startHTTPServer(port string) *http.Server {
	srv := &http.Server{Addr: ":" + port}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "Success.")
	})

	go func() {
		if err := srv.ListenAndServe(); err != nil {
			log.Printf("httpcheck: ListenAndServe() error: %s", err)
		}
	}()

	return srv
}

func main() {

	port := os.Getenv("HTTPCHECK_PORT")
	waitEnv := os.Getenv("HTTPCHECK_WAIT")
	wait, _ := strconv.ParseInt(waitEnv, 10, 64)

	log.Printf("httpcheck: Starting httpcheck service.")

	srv := startHTTPServer(port)

	log.Printf("httpcheck: Serving on port: %v", port)

	time.Sleep(time.Duration(wait) * time.Second)

	log.Printf("httpcheck: Stopping httpcheck server")

	if err := srv.Close(); err != nil {
		log.Printf("httpcheck: Close() error: %s", err)
	}

	log.Printf("httpcheck: Done. exiting.")
}
