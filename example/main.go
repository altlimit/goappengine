package main

import (
	"log"
	"net/http"

	"google.golang.org/appengine/v2"
)

func main() {
	log.Printf("Server Started")
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "Hello World", http.StatusOK)
	})
	appengine.Main()
}
