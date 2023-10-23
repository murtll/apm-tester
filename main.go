package main

import (
	"io"
	"math/rand"
	"net/http"

	"golang.org/x/net/context/ctxhttp"

	"go.elastic.co/apm/module/apmhttp/v2"
	"go.elastic.co/apm/v2"
)

var tracingClient = apmhttp.WrapClient(http.DefaultClient)

func serverHandler(w http.ResponseWriter, req *http.Request) {
	url := "https://jsonplaceholder.typicode.com/posts/1"

	// some random errors
	if rand.Int() % 3 == 0 {
		url = "foo"
	}

	// Propagate the transaction context contained in req.Context().
	resp, err := ctxhttp.Get(req.Context(), tracingClient, url)
	if err != nil {
		apm.CaptureError(req.Context(), err).Send()
		http.Error(w, "failed to query backend", 500)
		return
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		apm.CaptureError(req.Context(), err).Send()
		http.Error(w, "failed to query backend", 500)
		return
	}
	w.Write(body)
}

func main() {
	http.ListenAndServe(":8080", apmhttp.Wrap(http.HandlerFunc(serverHandler)))
}
