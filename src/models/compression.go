package models

import "context"

// CompressionStrategy defines the interface for all compression algorithms
type CompressionStrategy interface {
    // Compress takes raw image bytes and returns compressed bytes
    Compress(ctx context.Context, input *CompressionInput) (*CompressionOutput, error)
    // GetName returns the identifier for this compression strategy
    GetName() string
}

// CompressionInput encapsulates all possible input parameters
type CompressionInput struct {
    ImageBytes []byte
    Filename   string
    Options    map[string]interface{} // Flexible options for different algorithms
}

// CompressionOutput contains the compression result
type CompressionOutput struct {
    CompressedBytes []byte
    OriginalSize    int64
    CompressedSize  int64
    CompressionTime int64  // in milliseconds
    Algorithm       string // which algorithm was used
}

type ImageMetadata struct {
	Filename string
	ImageSize int
}


type CompressedImageResponse struct {
    ImageMetadata   ImageMetadata `json:"compressed_image_metadata"`
    SizeDifference  float32      `json:"size_difference"`
    OriginalSize    int64        `json:"original_size"`
}
