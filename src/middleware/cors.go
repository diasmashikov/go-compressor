package middleware

import (
	"net/http"
)

func CorsMiddleware(next http.HandlerFunc) http.HandlerFunc {
    // Define the allowed origins
    allowedOrigins := map[string]bool{
        "https://gofilecompress.com":       true,
        "https://www.gofilecompress.com":   true,
    }

    return func(w http.ResponseWriter, r *http.Request) {
        origin := r.Header.Get("Origin") 

        if allowedOrigins[origin] {
            w.Header().Set("Access-Control-Allow-Origin", origin)
        }

        w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, X-Requested-With")
        w.Header().Set("Access-Control-Expose-Headers", "X-Compression-Metadata")
        w.Header().Set("Access-Control-Max-Age", "86400")

        
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }

        next(w, r)
    }
}
