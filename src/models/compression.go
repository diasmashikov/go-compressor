package models

import "context"

type CompressionStrategy interface {
    Compress(ctx context.Context, input *CompressionInput) (*CompressionOutput, error)
    GetName() string
}


type CompressionInput struct {
    ImageBytes []byte
    Filename   string
    Options    map[string]interface{}
}

type CompressionOutput struct {
    CompressedBytes []byte
    OriginalSize    int64
    CompressedSize  int64
    CompressionTime int64 
    Algorithm       string 
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
