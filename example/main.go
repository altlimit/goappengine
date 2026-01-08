package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"cloud.google.com/go/datastore"
	"github.com/qedus/nds/v2"
	"github.com/qedus/nds/v2/cachers/memcache"
	"github.com/qedus/nds/v2/cachers/memory"
	"google.golang.org/appengine/v2"
)

var (
	projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
)

type Entity struct {
	Value string
}

func main() {
	log.Printf("Server Started")

	ctx := context.Background()
	dsClient, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer dsClient.Close()

	var cacher nds.Cacher
	if appengine.IsAppEngine() || appengine.IsDevAppServer() {
		cacher = memcache.NewCacher()
	} else {
		// or use redis
		cacher = memory.NewCacher()
	}
	ndsClient, err := nds.NewClient(ctx, cacher, nds.WithDatastoreClient(dsClient))
	if err != nil {
		log.Fatalf("Failed to create nds client: %v", err)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		key := datastore.IDKey("Entity", 0, nil)
		e := &Entity{Value: "Hello World"}

		k, err := ndsClient.Put(ctx, key, e)
		if err != nil {
			http.Error(w, fmt.Sprintf("Failed to put entity: %v", err), http.StatusInternalServerError)
			return
		}
		http.Error(w, fmt.Sprintf("Created Entity: %d", k.ID), http.StatusOK)
	})
	appengine.Main()
}
