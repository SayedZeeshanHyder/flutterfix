# FlutterFix 🚀

**AI-Powered Flutter Command Wrapper with Intelligent Error Resolution**

FlutterFix is a powerful PowerShell tool that wraps Flutter commands and provides AI-driven error analysis and automated solutions. When your Flutter commands fail, FlutterFix analyzes the errors using Google's Gemini AI and offers interactive, actionable solutions to fix the issues automatically.

## ✨ Features

- **🔧 Seamless Flutter Command Wrapping**: Replace `flutter` with `flutterfix` in any command
- **🤖 AI-Powered Error Analysis**: Leverages Google Gemini AI to understand and analyze Flutter errors
- **🎯 Interactive Solution Menu**: Navigate through AI-generated solutions with an intuitive interface
- **⚡ Automated Fixes**: Apply solutions automatically with confirmation prompts
- **📝 Change Tracking**: Keep track of all modifications made during error resolution
- **🎨 Colored Output**: Enhanced readability with color-coded messages
- **🔒 Secure API Key Management**: Safely store and manage your Gemini API key

## 🎬 Demo

```powershell
# Instead of running:
flutter build apk

# Run this instead:
flutterfix build apk
```

If the command fails, FlutterFix will:
1. Analyze the error with AI
2. Present 5 ranked solutions
3. Let you choose and apply fixes interactively
4. Track all changes made

## 📋 Prerequisites

- **Windows PowerShell 5.1+** or **PowerShell Core 7+**
- **Flutter SDK** installed and available in PATH
- **Google Gemini API Key** ([Get one here](https://makersuite.google.com/app/apikey))
- **Internet connection** for AI analysis

## 🚀 Installation

### Method 1: Quick Setup (Recommended)

1. **Download the script**:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SayedZeeshanHyder/flutterfix/main/flutterfix.ps1" -OutFile "$env:USERPROFILE\flutterfix.ps1"
   ```

2. **Create a global alias**:
   ```powershell
   # Add this line to your PowerShell profile
   Set-Alias -Name flutterfix -Value "$env:USERPROFILE\flutterfix.ps1"
   ```

3. **Edit your PowerShell profile**:
   ```powershell
   notepad $PROFILE
   ```
   Add the alias line from step 2 and save.

### Method 2: Manual Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SayedZeeshanHyder/flutterfix.git
   cd flutterfix
   ```

2. **Copy to a permanent location**:
   ```powershell
   Copy-Item "flutterfix.ps1" "$env:USERPROFILE\flutterfix.ps1"
   ```

3. **Add to PATH or create alias** (same as Method 1, step 2-3)

### Method 3: Development Setup

1. **Fork and clone**:
   ```bash
   git clone https://github.com/SayedZeeshanHyder/flutterfix.git
   cd flutterfix
   ```

2. **Run directly**:
   ```powershell
   .\flutterfix.ps1 --help
   ```

## 🔑 API Key Setup

On first use, FlutterFix will prompt you to enter your Gemini API key. The key is securely stored in `%USERPROFILE%\.zeeshan_gemini_key`.

### Getting a Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated key
5. Enter it when prompted by FlutterFix

### Manual API Key Setup

```powershell
# Store your API key manually
"your-gemini-api-key-here" | Out-File -FilePath "$env:USERPROFILE\.zeeshan_gemini_key" -Encoding UTF8 -NoNewline
```

## 🎯 Usage

### Basic Commands

Replace any `flutter` command with `flutterfix`:

```powershell
# Build commands
flutterfix build apk
flutterfix build appbundle
flutterfix build ios
flutterfix build web

# Development commands
flutterfix run
flutterfix run --debug
flutterfix run --release

# Package management
flutterfix pub get
flutterfix pub upgrade
flutterfix pub deps

# Testing
flutterfix test
flutterfix test --coverage

# Analysis
flutterfix analyze
flutterfix doctor
```

### When Commands Succeed

FlutterFix acts as a transparent wrapper - you'll see the normal Flutter output with a success message.

### When Commands Fail

If a Flutter command fails, FlutterFix automatically:

1. **Analyzes the error** using Gemini AI
2. **Generates 5 ranked solutions** (60-95% success probability)
3. **Shows an interactive menu**:
   ```
   [HELP] Available Solutions (Use Up/Down arrows to navigate, Enter to select):

     > [1] Fix dependency version conflicts (85% success rate)
         Update pubspec.yaml to resolve version conflicts

       [2] Clean and rebuild project (78% success rate)
         Remove build artifacts and rebuild from scratch

       [3] Update Flutter SDK (72% success rate)
         Upgrade to the latest stable Flutter version

       [4] Fix Android build configuration (69% success rate)
         Update Android-specific build settings

       [5] Reset pub cache (65% success rate)
         Clear and refresh package cache

       [6] I will handle it myself
           Skip automatic fixes and resolve manually
   ```

4. **Applies your chosen solution** with confirmation prompts
5. **Tracks all changes** made during the process

### Interactive Menu Navigation

- **Arrow Keys**: Navigate up/down through solutions
- **Enter**: Select the highlighted solution
- **Escape**: Cancel and exit
- **Number Keys (1-6)**: Quick selection
- **Confirmation Prompts**: Each file modification requires Y/N confirmation

## 🛠️ How It Works

### 1. Command Execution
FlutterFix wraps the original Flutter command and captures both output and errors.

### 2. Error Detection
If the command fails (non-zero exit code or error output), the error analysis begins.

### 3. AI Analysis
The error details are sent to Google Gemini AI with a specialized prompt that requests:
- 5 specific solutions ranked by success probability
- Detailed steps for each solution
- File modifications, commands, or deletions needed

### 4. Solution Application
Each solution can include:
- **File modifications**: Update existing files
- **File creation**: Create new configuration files
- **Command execution**: Run additional Flutter/system commands
- **File deletion**: Remove problematic files

### 5. Change Tracking
All modifications are logged and displayed at the end:
```
[LOG] Summary of changes made:

  Modified: pubspec.yaml
    Updated dependency versions to resolve conflicts

  Executed: flutter pub get
    Refreshed dependencies after pubspec changes

  Created: android/local.properties
    Added missing Android SDK configuration
```

## 🎨 Output Examples

### Successful Command
```powershell
PS C:\MyFlutterApp> flutterfix pub get

[RUN] Executing: flutter pub get

Running "flutter pub get" in MyFlutterApp...
Resolving dependencies...
Got dependencies!

[+] Command completed successfully!
```

### Failed Command with AI Resolution
```powershell
PS C:\MyFlutterApp> flutterfix build apk

[RUN] Executing: flutter build apk

Building with sound null safety

FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:checkDebugDuplicateClasses'.

[X] Command failed with exit code: 1

[AI] Analyzing error with Gemini AI...

[HELP] Available Solutions (Use Up/Down arrows to navigate, Enter to select):

  > [1] Fix duplicate class conflicts (87% success rate)
        Remove conflicting dependencies and update build configuration

    [2] Clean build and rebuild (82% success rate)
        Clear build cache and rebuild the entire project

    [3] Update Gradle and build tools (75% success rate)
        Upgrade Android build system components

    [4] Fix ProGuard configuration (70% success rate)
        Update code obfuscation settings

    [5] Reset Android project structure (65% success rate)
        Recreate Android-specific configuration files

    [6] I will handle it myself
        Skip automatic fixes and resolve manually
```

## 📁 Project Structure

```
flutterfix/
├── flutterfix.ps1          # Main PowerShell script
├── README.md               # This documentation
├── LICENSE                 # MIT License
└── examples/               # Usage examples
    ├── basic-usage.md
    ├── error-scenarios.md
    └── api-setup.md
```

### Core Components

#### 🔧 **Command Execution Engine**
- Robust Flutter command wrapping
- Output and error capture
- Exit code handling

#### 🤖 **AI Integration Module**
- Gemini API communication
- Structured prompt engineering
- JSON response parsing

#### 🎮 **Interactive Interface**
- Arrow key navigation
- Real-time menu updates
- Confirmation dialogs

#### 🔒 **Security & Storage**
- Encrypted API key storage
- Safe file operations
- Change rollback capability

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `FLUTTERFIX_API_KEY` | Gemini API key (overrides file) | None |
| `FLUTTERFIX_DEBUG` | Enable debug logging | `false` |
| `FLUTTERFIX_TIMEOUT` | API request timeout (seconds) | `30` |

### Configuration File

FlutterFix stores configuration in `%USERPROFILE%\.flutterfix\config.json`:

```json
{
  "api_timeout": 30,
  "max_solutions": 5,
  "auto_confirm": false,
  "debug_mode": false,
  "theme": "default"
}
```

## 🔍 Troubleshooting

### Common Issues

#### "Flutter command not found"
```powershell
# Verify Flutter installation
flutter --version

# Add Flutter to PATH if needed
$env:PATH += ";C:\flutter\bin"
```

#### "Gemini API call failed"
- Verify your API key is correct
- Check internet connection
- Ensure API quotas aren't exceeded
- API key will be cleared on authentication failure

#### "PowerShell execution policy"
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### "Access denied" errors
```powershell
# Run as administrator if needed
Start-Process PowerShell -Verb RunAs
```

### Debug Mode

Enable detailed logging:

```powershell
$env:FLUTTERFIX_DEBUG = "true"
flutterfix your-command
```

### Reset Configuration

```powershell
# Clear API key
Remove-Item "$env:USERPROFILE\.zeeshan_gemini_key" -Force

# Clear all config
Remove-Item "$env:USERPROFILE\.flutterfix" -Recurse -Force
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google Gemini AI** for intelligent error analysis
- **Flutter Team** for the amazing framework
- **PowerShell Community** for scripting inspiration
- **Open Source Contributors** who make projects like this possible
---

**Made with ❤️ for the Flutter community**

*Happy coding! 🚀*
