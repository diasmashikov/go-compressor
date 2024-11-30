package compression

import (
	"fmt"
	"go-compressor/models"
)

type Provider struct {
    strategies map[string]models.CompressionStrategy
}

func NewProvider() *Provider {
    p := &Provider{
        strategies: make(map[string]models.CompressionStrategy),
    }
    
    p.RegisterStrategy(NewStdlibStrategy())
    p.RegisterStrategy(NewPngQuantStrategy())
    
    return p
}

func (p *Provider) RegisterStrategy(strategy models.CompressionStrategy) {
    p.strategies[strategy.GetName()] = strategy
}

func (p *Provider) GetStrategy(name string) (models.CompressionStrategy, error) {
    strategy, exists := p.strategies[name]
    if !exists {
        return nil, fmt.Errorf("compression strategy '%s' not found", name)
    }
    return strategy, nil
}