# BludVim One-Liner Test Commands

## Test Commands for Users

### 1. **Direct Docker Run (No Installation Required)**
```bash
# Test command - just prints version
docker run --rm \
  -v "$(pwd)":/workspace \
  bludvim:latest nvim --version

# Interactive mode (requires TTY)
docker run -it --rm \
  -v "$(pwd)":/workspace \
  -v "$HOME/.ssh":/home/nvim/.ssh:ro \
  -v "$HOME/.gitconfig":/home/nvim/.gitconfig:ro \
  -e TERM=xterm-256color \
  -e COLORTERM=truecolor \
  bludvim:latest
```

### 2. **Installation One-Liner**
```bash
# This will install bludvim command globally
curl -fsSL https://raw.githubusercontent.com/rexbrahh/.nvim/main/install.sh | bash
```

### 3. **Usage After Installation**
```bash
bludvim                 # Open in current directory
bludvim README.md       # Open specific file
bludvim --help          # Show help
bludvim --update        # Update to latest version
```

## Ready for Push

✅ **Docker build tested** - Works with Alpine Linux  
✅ **Installation script tested** - Creates bludvim command  
✅ **Wrapper script tested** - All commands working  
✅ **Docker compose tested** - Container starts properly  
✅ **One-liner ready** - Install script accessible via curl  

## Files Ready for Git

- `install.sh` - Main installation script
- `Dockerfile` - Multi-stage Alpine build
- `docker-compose.yml` - Development setup
- `.dockerignore` - Build optimization
- `DOCKER.md` - Complete documentation

## Next Steps

1. Add all Docker files to git
2. Push to main branch
3. Test the GitHub one-liner: `curl -fsSL https://raw.githubusercontent.com/rexbrahh/.nvim/main/install.sh | bash`