# Troubleshooting Guide Template

Use this template to document common issues and their solutions in a consistent format.

## Template Structure

```markdown
## Issue: [Brief Description]

### Symptoms
- What the user sees/experiences
- Error messages (exact text)
- When it occurs (specific conditions)

### Root Cause
Brief explanation of why this happens

### Solution
Step-by-step fix:
1. First step
2. Second step
3. Verification step

### Prevention
How to avoid this issue in the future

### Related Issues
- Links to similar problems
- GitHub issues
- Documentation references
```

## Example Entries

---

## Issue: Command Not Found After Installation

### Symptoms
- Running `projectcmd` returns "command not found"
- Installation completed successfully
- Command doesn't appear in PATH

### Root Cause
The installation script doesn't automatically add the binary to PATH, or the shell hasn't been reloaded after installation.

### Solution
1. Verify installation location:
   ```bash
   which projectcmd || find /usr/local -name projectcmd
   ```

2. Add to PATH (choose one):
   ```bash
   # Temporary (current session only)
   export PATH="$PATH:/usr/local/bin"

   # Permanent (add to ~/.zshrc or ~/.bashrc)
   echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.zshrc
   ```

3. Reload shell configuration:
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

4. Verify it works:
   ```bash
   projectcmd --version
   ```

### Prevention
- Always reload shell after installation
- Check PATH before reporting issues
- Use package managers when available (brew, apt, etc.)

### Related Issues
- [Installation Guide](../README.md#installation)
- GitHub Issue [#123](https://github.com/user/repo/issues/123)

---

## Issue: Permission Denied When Running Scripts

### Symptoms
- `Permission denied` error when executing scripts
- Script exists but won't run
- Works with `sudo` but shouldn't require it

### Root Cause
File lacks execute permissions or ownership issues.

### Solution
1. Check current permissions:
   ```bash
   ls -la script.sh
   ```

2. Add execute permission:
   ```bash
   chmod +x script.sh
   ```

3. Fix ownership if needed:
   ```bash
   # Check current user
   whoami

   # Change ownership
   chown $(whoami) script.sh
   ```

4. Run the script:
   ```bash
   ./script.sh
   ```

### Prevention
- Always set correct permissions after creating scripts
- Use version control to preserve permissions
- Document required permissions in README

### Related Issues
- [Unix Permissions Guide](https://en.wikipedia.org/wiki/File-system_permissions)
- [Script Setup Documentation](docs/setup.md)

---

## Issue: Git Push Fails With Authentication Error

### Symptoms
- `fatal: Authentication failed` when pushing
- Previously working git commands now fail
- Password prompt doesn't accept GitHub password

### Root Cause
GitHub deprecated password authentication in favor of personal access tokens (PAT) or SSH keys.

### Solution

**Option A: Use SSH (Recommended)**
1. Generate SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```

2. Add to SSH agent:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

3. Add to GitHub:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   # Copy output and add to GitHub Settings > SSH Keys
   ```

4. Update remote URL:
   ```bash
   git remote set-url origin git@github.com:username/repo.git
   ```

**Option B: Use Personal Access Token**
1. Generate PAT on GitHub (Settings > Developer settings > Personal access tokens)
2. Use PAT as password when prompted
3. Save in credential manager:
   ```bash
   git config --global credential.helper store
   ```

### Prevention
- Use SSH keys from the start
- Keep PAT secure and rotated
- Enable 2FA on GitHub account

### Related Issues
- [GitHub SSH Documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Creating a Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

---

## Issue: Docker Container Fails to Start

### Symptoms
- `docker-compose up` fails immediately
- Container exits with code 1
- Logs show "address already in use" or similar

### Root Cause
Port conflict with another service or stale container.

### Solution
1. Check what's using the port:
   ```bash
   lsof -i :3000  # Replace 3000 with your port
   ```

2. Stop conflicting service or change port:
   ```bash
   # Kill process using port
   kill -9 $(lsof -t -i:3000)

   # OR change port in docker-compose.yml
   # ports:
   #   - "3001:3000"
   ```

3. Clean up Docker:
   ```bash
   docker-compose down
   docker system prune -f
   docker-compose up --build
   ```

### Prevention
- Use unique ports for each service
- Document port requirements
- Include port checks in startup scripts

### Related Issues
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Port Management Best Practices](docs/ports.md)

---

## Troubleshooting Categories

### Installation Issues
- Missing dependencies
- Permission problems
- PATH configuration
- Version conflicts

### Runtime Errors
- Memory leaks
- Performance degradation
- Crashes and hangs
- Data corruption

### Configuration Problems
- Invalid settings
- Missing environment variables
- Incorrect file paths
- Permission mismatches

### Network Issues
- Connection timeouts
- SSL/TLS errors
- Proxy configuration
- Firewall blocks

### Development Environment
- Build failures
- Test failures
- Hot reload not working
- Debugger not attaching

### Data and Storage
- Database connection issues
- File system errors
- Cache problems
- Backup/restore failures

## Best Practices for Troubleshooting Documentation

1. **Be Specific**: Include exact error messages and version numbers
2. **Show Commands**: Provide copy-paste ready commands
3. **Multiple Solutions**: Offer alternatives when possible
4. **Explain Why**: Help users understand the root cause
5. **Test Solutions**: Verify fixes before documenting
6. **Cross-Reference**: Link to related issues and documentation
7. **Keep Updated**: Review and update as new issues arise
8. **Include Diagnostics**: Show how to gather debugging information
9. **Progressive Disclosure**: Start with simple solutions, escalate to complex
10. **Platform Awareness**: Note platform-specific differences (Mac/Linux/Windows)

## Diagnostic Commands Toolbox

```bash
# System Information
uname -a                    # OS and kernel version
echo $SHELL                 # Current shell
echo $PATH                  # PATH variable
env | grep RELEVANT        # Environment variables

# Process Investigation
ps aux | grep process      # Find running processes
lsof -i :PORT              # What's using a port
top -o cpu                 # CPU usage
htop                       # Interactive process viewer

# Network Diagnostics
ping -c 4 hostname         # Test connectivity
curl -I https://url        # Test HTTP/HTTPS
netstat -an | grep LISTEN  # Listening ports
nslookup domain.com        # DNS resolution

# File System
df -h                      # Disk usage
du -sh *                   # Directory sizes
find . -name "*.log"       # Find files
tail -f logfile.log        # Watch log file

# Git Diagnostics
git status                 # Repository state
git remote -v              # Remote URLs
git log --oneline -10      # Recent commits
git config --list          # Git configuration

# Docker Diagnostics
docker ps -a               # All containers
docker logs container_name # Container logs
docker system df           # Docker disk usage
docker version             # Docker version info
```