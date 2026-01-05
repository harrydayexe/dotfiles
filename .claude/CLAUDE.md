```markdown
# Go Documentation Standards

## Package-Level Documentation

Every package must have a package comment (in `doc.go` or any `.go` file):
- Start with "Package packagename"
- Explain purpose and basic usage
- Include a simple code example
- Note concurrency safety if applicable

```go
// Package cache provides an in-memory key-value cache with TTL support.
//
// Basic usage:
//
//     c := cache.New(5 * time.Minute)
//     c.Set("key", "value")
//     val, found := c.Get("key")
//
// All operations are safe for concurrent use.
package cache
```

## Code Documentation Requirements

**Every exported symbol must be documented:**
- Start comment with the symbol name
- First sentence = concise summary
- Document concurrency safety explicitly
- Describe error conditions and return values
- Note special behaviors or edge cases

```go
// Client represents a connection to the API server.
// It is safe for concurrent use by multiple goroutines.
type Client struct { ... }

// NewClient creates a new Client with the provided API key.
// It returns an error if the key format is invalid.
func NewClient(apiKey string) (*Client, error) { ... }

// DefaultTimeout is the default timeout for all operations.
const DefaultTimeout = 30 * time.Second
```

## Repository Files Checklist

**Required:**
- [ ] `README.md` with:
  - Project description (1-2 paragraphs)
  - Installation: `go get github.com/user/repo`
  - Quick start code example
  - Link to pkg.go.dev
  - License info
- [ ] `LICENSE` file
- [ ] `go.mod` and `go.sum` committed

**Recommended:**
- [ ] Testable examples in `*_test.go`:
  - `Example()` for package
  - `ExampleType()` for types
  - `ExampleType_Method()` for methods
  - Include `// Output:` comments
- [ ] `examples/` directory with runnable programs
- [ ] `CHANGELOG.md` for version history
- [ ] `CONTRIBUTING.md` if accepting contributions

## Example Functions

Create testable examples that appear in pkg.go.dev:

```go
// Example demonstrates basic usage of the library.
func Example() {
    client := mylib.NewClient("demo-key")
    result, _ := client.Fetch("data")
    fmt.Println(result)
    // Output: data retrieved successfully
}

// ExampleClient_Connect shows connection establishment.
func ExampleClient_Connect() {
    client := mylib.NewClient("demo-key")
    if err := client.Connect(); err != nil {
        fmt.Println("Connection failed:", err)
        return
    }
    fmt.Println("Connected")
    // Output: Connected
}
```

## README.md Template

```markdown
# ProjectName

Brief description of what the project does (1-2 paragraphs).

## Installation
\`\`\`bash
go get github.com/username/projectname
\`\`\`

## Quick Start
\`\`\`go
package main

import "github.com/username/projectname"

func main() {
    // Simple usage example
}
\`\`\`

## Features
- Key feature 1
- Key feature 2

## Documentation
Full API documentation: https://pkg.go.dev/github.com/username/projectname

## License
[License Type] - see LICENSE file
```

## pkg.go.dev Auto-Indexing

Your module is automatically indexed when:
- Code pushed to public repository
- Version tag created
- Someone runs `go get` on your module

No manual setup required - just write good godoc comments.

## Quick Reference

**Before committing Go code:**
1. Add package comment if new package
2. Document all exported symbols (types, functions, methods, constants, vars)
3. Include concurrency safety notes
4. Document errors and edge cases
5. Add testable examples for key functionality
6. Ensure README.md exists with installation and usage
```
