package compression

import (
	"fmt"
	"go-compressor/models"
)

// Provider handles creation and retrieval of compression strategies
type Provider struct {
    strategies map[string]models.CompressionStrategy
}

// NewProvider returns *Provider (pointer to Provider)
// because we want to SHARE THE SAME Provider across our app
func NewProvider() *Provider {
    p := &Provider{
        strategies: make(map[string]models.CompressionStrategy),
    }
    
    // Register default strategies
    p.RegisterStrategy(NewStdlibStrategy())
    p.RegisterStrategy(NewPngQuantStrategy())
    
    return p
}

// This is a method on *Provider (pointer receiver)
// It means this method can MODIFY the Provider it's called on
func (p *Provider) RegisterStrategy(strategy models.CompressionStrategy) {
    p.strategies[strategy.GetName()] = strategy
}

// GetStrategy returns a strategy by name
func (p *Provider) GetStrategy(name string) (models.CompressionStrategy, error) {
    strategy, exists := p.strategies[name]
    if !exists {
        return nil, fmt.Errorf("compression strategy '%s' not found", name)
    }
    return strategy, nil
}