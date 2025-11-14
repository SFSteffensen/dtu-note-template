# DTU Template Development Justfile
# Usage: just <recipe>
# Cross-platform compatible (Linux, macOS, Windows with sh/bash)

# Default recipe - show help
default:
    @just help

# Show available commands
help:
    @echo "DTU Template Development Commands:"
    @echo ""
    @echo "Development:"
    @echo "  setup     - Create test directory and validate dependencies"
    @echo "  dev       - Development workflow (setup + examples)"
    @echo "  test      - Test template compilation"
    @echo "  clean     - Clean generated files"
    @echo ""
    @echo "Examples:"
    @echo "  examples  - Compile all example documents"
    @echo ""
    @echo "Validation:"
    @echo "  validate  - Check package structure"

# Setup development environment
setup:
    @echo "Setting up development environment..."
    @mkdir -p test-output
    @typst --version
    @echo "Setup complete!"

# Validate package structure
validate:
    @echo "Validating package structure..."
    @test -f typst.toml || (echo "❌ Error: Missing typst.toml" && exit 1)
    @test -f src/lib.typ || (echo "❌ Error: Missing src/lib.typ" && exit 1)
    @test -f src/assets/dtu-logo-cmyk.png || (echo "❌ Error: Missing DTU logo" && exit 1)
    @echo "✅ Package structure valid!"

# Clean generated files
clean:
    @echo "Cleaning generated files..."
    @rm -rf test-output
    @echo "Clean complete!"

# Compile example documents
examples: setup
    @echo "Compiling examples..."
    @typst compile --root . "examples/note-example.typ" "test-output/note-example.pdf"
    @typst compile --root . "examples/assignment-example.typ" "test-output/assignment-example.pdf"
    @echo "Examples compiled to test-output/"

# Test template compilation
test: setup validate
    @echo "Testing template compilation..."
    @printf '#import "../src/lib.typ": dtu-note\n\n#show: dtu-note.with(course: "TEST", title: "Test")\n\n= Test\nThis is a test.\n' > test-output/test.typ
    @typst compile --root . "test-output/test.typ" "test-output/test.pdf"
    @echo "✅ Test compilation successful!"

# Development workflow
dev: setup validate examples
    @echo "Development environment ready!"
    @echo "Examples compiled. Edit files and run 'just examples' to recompile."

# Watch for changes and recompile (requires inotify-tools on Linux or fswatch on macOS)
watch:
    @echo "Watching for changes..."
    @echo "Note: This requires 'watchexec' to be installed"
    @echo "Install with: cargo install watchexec-cli"
    watchexec -e typ -w src -w examples "just examples"

# Run all checks (for CI)
ci: clean setup validate test examples
    @echo "✅ All CI checks passed!"
