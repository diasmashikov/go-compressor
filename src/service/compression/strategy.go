package compression // Note: Changed to a subpackage

import (
	"bytes"
	"context"
	"fmt"
	"go-compressor/models"
	"image"
	"image/png"
	"os"
	"os/exec"
	"time"
)

// StdlibStrategy implements standard library PNG compression
type StdlibStrategy struct{}

func NewStdlibStrategy() *StdlibStrategy {
    return &StdlibStrategy{}
}

func (s *StdlibStrategy) GetName() string {
    return "stdlib"
}

func (s *StdlibStrategy) Compress(ctx context.Context, input *models.CompressionInput) (*models.CompressionOutput, error) {
    startTime := time.Now()
    
    var buffer bytes.Buffer
    encoder := png.Encoder{CompressionLevel: png.BestCompression}
    
    // Convert bytes to image for encoding
    img, _, err := image.Decode(bytes.NewReader(input.ImageBytes))
    if err != nil {
        return nil, fmt.Errorf("error decoding image: %w", err)
    }
    
    if err := encoder.Encode(&buffer, img); err != nil {
        return nil, fmt.Errorf("error encoding image: %w", err)
    }
    
    compressedBytes := buffer.Bytes()
    
    return &models.CompressionOutput{
        CompressedBytes: compressedBytes,
        OriginalSize:    int64(len(input.ImageBytes)),
        CompressedSize:  int64(len(compressedBytes)),
        CompressionTime: time.Since(startTime).Milliseconds(),
        Algorithm:       s.GetName(),
    }, nil
}

type PngQuantStrategy struct{}

func NewPngQuantStrategy() *PngQuantStrategy {
    return &PngQuantStrategy{}
}

func (s *PngQuantStrategy) GetName() string {
    return "pngquant"
}

func (s *PngQuantStrategy) Compress(ctx context.Context, input *models.CompressionInput) (*models.CompressionOutput, error) {
    startTime := time.Now()

    inputFile, err := os.CreateTemp("", "input-*.png")
    if err != nil {
        return nil, fmt.Errorf("failed to create temp input file: %w", err)
    }
    defer os.Remove(inputFile.Name())

    if _, err := inputFile.Write(input.ImageBytes); err != nil {
        return nil, fmt.Errorf("failed to write input file: %w", err)
    }

    outputFile, err := os.CreateTemp("", "output-*.png")
    if err != nil {
        return nil, fmt.Errorf("failed to create temp output file: %w", err)
    }
    fmt.Println(outputFile.Name())
    defer os.Remove(outputFile.Name()) 

    cmd := exec.CommandContext(ctx, "pngquant", "--quality=60-80", "--output", outputFile.Name(), inputFile.Name())
    var stderr bytes.Buffer
    cmd.Stderr = &stderr

    if err := cmd.Run(); err != nil {
        return nil, fmt.Errorf("pngquant failed: %s, error: %w", stderr.String(), err)
    }

    compressedBytes, err := os.ReadFile(outputFile.Name())
    if err != nil {
        return nil, fmt.Errorf("failed to read compressed file: %w", err)
    }

    return &models.CompressionOutput{
        CompressedBytes: compressedBytes,
        OriginalSize:    int64(len(input.ImageBytes)),
        CompressedSize:  int64(len(compressedBytes)),
        CompressionTime: time.Since(startTime).Milliseconds(),
        Algorithm:       s.GetName(),
    }, nil
}

// !!! Temporarily outdated due to worse efficiencies on all possible metrics for PNG compression !!!
// !!! However, remaining to stay here for the future reference for working with BIMG             !!!

// BimgStrategy implements bimg-based compression
// type BimgStrategy struct{}

// func NewBimgStrategy() *BimgStrategy {
//     return &BimgStrategy{}
// }

// func (s *BimgStrategy) GetName() string {
//     return "bimg"
// }

// func (s *BimgStrategy) Compress(ctx context.Context, input *models.CompressionInput) (*models.CompressionOutput, error) {
//     startTime := time.Now()
    
//     image := bimg.NewImage(input.ImageBytes)
//     options := bimg.Options{
//         Lossless: true,
//         Compression: 9,
//         Type: bimg.PNG,
//     }
    
//     compressed, err := image.Process(options)
//     if err != nil {
//         return nil, fmt.Errorf("failed to process image: %w", err)
//     }
    
//     return &models.CompressionOutput{
//         CompressedBytes: compressed,
//         OriginalSize:    int64(len(input.ImageBytes)),
//         CompressedSize:  int64(len(compressed)),
//         CompressionTime: time.Since(startTime).Milliseconds(),
//         Algorithm:       s.GetName(),
//     }, nil
// }

