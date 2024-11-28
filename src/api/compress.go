package api

import (
	"encoding/json"
	"fmt"
	"go-compressor/models"
	"go-compressor/service/compression" // new package path
	"io"
	"net/http"
	"strings"
)

func CompressImageHandler(w http.ResponseWriter, r *http.Request) {
    
    // Create compression provider once
    provider := compression.NewProvider()
    
    // Get strategy from query param or default to "bimg"
    strategyName := r.URL.Query().Get("strategy")
    if strategyName == "" {
        strategyName = "pngquant" // default strategy
    }
    
    strategy, err := provider.GetStrategy(strategyName)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid compression strategy: %v", err), http.StatusBadRequest)
        return
    }

    // Parse multipart form
    if err := r.ParseMultipartForm(20 * 1024 * 1024); err != nil {
        http.Error(w, "Can't parse the image", http.StatusBadRequest)
        return
    }

    imageFilesHeaders, ok := r.MultipartForm.File["image_files"]
    if !ok || len(imageFilesHeaders) == 0 {
        http.Error(w, "Please, upload an image file", http.StatusBadRequest)
        return
    }

    // Process first image (keeping single image logic for now)
    imageFileHeader := imageFilesHeaders[0]

    // Validate file extension
    if !strings.HasSuffix(strings.ToLower(imageFileHeader.Filename), ".png") {
        http.Error(w, "We accept only .png format image files", http.StatusBadRequest)
        return
    }

    // Read file bytes
    imageFile, err := imageFileHeader.Open()
    if err != nil {
        http.Error(w, "Could not read the file", http.StatusBadRequest)
        return
    }
    defer imageFile.Close()

    fileBytes, err := io.ReadAll(imageFile)
    if err != nil {
        http.Error(w, "Cannot read bytes", http.StatusBadRequest)
        return
    }

    // Prepare compression input
    input := &models.CompressionInput{
        ImageBytes: fileBytes,
        Filename:   imageFileHeader.Filename,
        Options:    map[string]interface{}{},
    }

    // Perform compression using selected strategy
    output, err := strategy.Compress(r.Context(), input)
    if err != nil {
        http.Error(w, fmt.Sprintf("Compression failed: %v", err), http.StatusInternalServerError)
        return
    }

    // Prepare response
    compressedImageMetadata := models.ImageMetadata{
        Filename:  imageFileHeader.Filename,
        ImageSize: len(output.CompressedBytes),
    }

    response := models.Response{
        Status:  "success",
        Message: "Image compressed successfully",
        Data: models.CompressedImageResponse{
            ImageMetadata:   compressedImageMetadata,
            SizeDifference: float32(imageFileHeader.Size) / float32(len(output.CompressedBytes)),
            OriginalSize:   imageFileHeader.Size,
        },
    }

    // Set response headers
    responseJSON, err := json.Marshal(response)
    if err != nil {
        http.Error(w, "Failed to encode metadata", http.StatusInternalServerError)
        return
    }

    // Add these lines at the start of your CompressImageHandler function
    w.Header().Set("Access-Control-Allow-Origin", "*")
    w.Header().Set("Access-Control-Allow-Headers", "*")
    w.Header().Set("Access-Control-Expose-Headers", "X-Compression-Metadata")
    w.Header().Set("X-Compression-Metadata", string(responseJSON))
    w.Header().Set("Content-Type", "image/png")
    w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", compressedImageMetadata.Filename))
    w.Header().Set("Content-Length", fmt.Sprintf("%d", len(output.CompressedBytes)))

    // Write compressed image
    if _, err := w.Write(output.CompressedBytes); err != nil {
        http.Error(w, "Failed to write compressed image", http.StatusInternalServerError)
        return
    }
}