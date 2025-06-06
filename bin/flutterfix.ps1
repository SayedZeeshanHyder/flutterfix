# Zeeshan - AI-Powered Flutter Command Wrapper
# Save this as zeeshantesting.ps1 and add to your PATH or create an alias

param(
    [Parameter(Position=0)]
    [string]$Command,
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Global variables
$script:ApiKeyFile = "$env:USERPROFILE\.zeeshan_gemini_key"
$script:GeminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
$script:ProjectRoot = Get-Location
$script:ChangesLog = @()

# Color functions for better output
function Write-ColoredText {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Write-Success { param([string]$Text) Write-ColoredText $Text "Green" }
function Write-Error { param([string]$Text) Write-ColoredText $Text "Red" }
function Write-Warning { param([string]$Text) Write-ColoredText $Text "Yellow" }
function Write-Info { param([string]$Text) Write-ColoredText $Text "Cyan" }

# API Key Management
function Get-GeminiApiKey {
    if (Test-Path $script:ApiKeyFile) {
        return Get-Content $script:ApiKeyFile -Raw
    }
    return $null
}

function Set-GeminiApiKey {
    param([string]$ApiKey)
    $ApiKey | Out-File -FilePath $script:ApiKeyFile -Encoding UTF8 -NoNewline
    Write-Success "[+] Gemini API key saved successfully"
}

function Remove-GeminiApiKey {
    if (Test-Path $script:ApiKeyFile) {
        Remove-Item $script:ApiKeyFile -Force
        Write-Warning "[!] Gemini API key cleared due to authentication failure"
    }
}

function Request-GeminiApiKey {
    Write-Info "[API] Gemini API key is required for error resolution"
    Write-Host "Please enter your Gemini API key: " -NoNewline
    $apiKey = Read-Host
    if ($apiKey -and $apiKey.Trim() -ne "") {
        Set-GeminiApiKey $apiKey.Trim()
        return $apiKey.Trim()
    }
    Write-Error "[X] No API key provided. Error resolution will be disabled."
    return $null
}

# Gemini API Integration
function Invoke-GeminiApi {
    param(
        [string]$Prompt,
        [string]$ApiKey
    )
    
    try {
        $requestBody = @{
            contents = @(
                @{
                    parts = @(
                        @{
                            text = $Prompt
                        }
                    )
                }
            )
            generationConfig = @{
                temperature = 0.3
                topK = 40
                topP = 0.95
                maxOutputTokens = 8192
            }
        } | ConvertTo-Json -Depth 10
        
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $uri = "$script:GeminiApiUrl" + "?key=$ApiKey"
        
        Write-Info "[AI] Analyzing error with Gemini AI..."
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body $requestBody -Headers $headers -TimeoutSec 30
        
        if ($response.candidates -and $response.candidates[0].content.parts[0].text) {
            return $response.candidates[0].content.parts[0].text
        } else {
            throw "Invalid response format from Gemini API"
        }
    }
    catch {
        Write-Error "[X] Gemini API call failed: $($_.Exception.Message)"
        Remove-GeminiApiKey
        return $null
    }
}

function Invoke-FlutterCommand {
    param(
        [string]$Command,
        [string[]]$Arguments
    )
    
    # Build the complete argument string properly
    $allArgs = @()
    if ($Command) {
        $allArgs += $Command
    }
    if ($Arguments -and $Arguments.Count -gt 0) {
        $allArgs += $Arguments
    }
    
    $argumentString = $allArgs -join " "
    $fullCommand = "flutter $argumentString"
    
    Write-Info "[RUN] Executing: $fullCommand"
    Write-Host ""
    
    try {
        # Check if flutter command exists
        $flutterCmd = Get-Command "flutter" -ErrorAction SilentlyContinue
        if (-not $flutterCmd) {
            throw "Flutter command not found. Please ensure Flutter is installed and in your PATH."
        }
        
        # Use Invoke-Expression for the most reliable execution
        $originalErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        
        # Capture both output and errors
        $output = ""
        $errorOutput = ""
        $exitCode = 0
        
        try {
            # Execute the command and capture all output
            $result = & flutter @allArgs 2>&1
            
            # Process the result
            $outputLines = @()
            $errorLines = @()
            
            foreach ($line in $result) {
                $lineStr = $line.ToString()
                Write-Host $lineStr
                
                if ($line -is [System.Management.Automation.ErrorRecord]) {
                    $errorLines += $lineStr
                } else {
                    $outputLines += $lineStr
                }
            }
            
            $output = $outputLines -join "`n"
            $errorOutput = $errorLines -join "`n"
            
            # Check if the command succeeded by looking for typical error indicators
            if ($errorOutput -or ($LASTEXITCODE -and $LASTEXITCODE -ne 0)) {
                $exitCode = if ($LASTEXITCODE) { $LASTEXITCODE } else { 1 }
            } else {
                $exitCode = 0
            }
        }
        catch {
            $errorOutput = $_.Exception.Message
            $exitCode = 1
            Write-Host $errorOutput -ForegroundColor Red
        }
        finally {
            $ErrorActionPreference = $originalErrorActionPreference
        }
        
        return @{
            ExitCode = $exitCode
            Output = $output
            Error = $errorOutput
            Success = ($exitCode -eq 0)
        }
    }
    catch {
        Write-Error "[X] Failed to execute Flutter command: $($_.Exception.Message)"
        return @{
            ExitCode = -1
            Output = ""
            Error = $_.Exception.Message
            Success = $false
        }
    }
}

# Error Analysis and Solution Generation
function Get-ErrorSolutions {
    param(
        [string]$Command,
        [string]$Error,
        [string]$Output
    )
    
    $apiKey = Get-GeminiApiKey
    if (-not $apiKey) {
        $apiKey = Request-GeminiApiKey
        if (-not $apiKey) {
            return $null
        }
    }
    
    $contextPrompt = @"
You are an expert Flutter developer assistant. A Flutter command has failed and you need to provide specific, actionable solutions.

COMMAND EXECUTED: flutter $Command
ERROR OUTPUT: 
$Error

FULL OUTPUT:
$Output

PROJECT CONTEXT: This is a Flutter project and the user needs specific solutions to fix this error.

Please provide EXACTLY 5 solutions in the following JSON format:
{
  "solutions": [
    {
      "title": "Solution Title",
      "description": "Detailed description of what this solution does",
      "probability": 85,
      "steps": [
        {
          "action": "modify_file|run_command|create_file|delete_file",
          "target": "file_path_or_command",
          "content": "new_content_or_command_args",
          "description": "What this step does"
        }
      ]
    }
  ]
}

Requirements:
1. Provide exactly 5 solutions, ordered by probability of success (highest first)
2. Each solution must have a probability between 60-95%
3. Include specific file paths and exact content changes
4. Focus on Flutter-specific issues (dependencies, build configs, etc.)
5. Make solutions actionable and specific to the error shown
6. Ensure JSON is valid and properly formatted
"@

    $response = Invoke-GeminiApi -Prompt $contextPrompt -ApiKey $apiKey
    if (-not $response) {
        return $null
    }
    
    try {
        # Extract JSON from response (in case there's extra text)
        $jsonMatch = [regex]::Match($response, '\{[\s\S]*\}')
        if ($jsonMatch.Success) {
            $jsonContent = $jsonMatch.Value
            $solutions = ConvertFrom-Json $jsonContent
            return $solutions.solutions
        } else {
            Write-Error "[X] Could not extract valid JSON from Gemini response"
            return $null
        }
    }
    catch {
        Write-Error "[X] Failed to parse solutions from Gemini response: $($_.Exception.Message)"
        return $null
    }
}

function Show-InteractiveMenu {
    param(
        [array]$Solutions
    )
    $menuItems = @()
    # Add solutions to menu items
    for ($i = 0; $i -lt $Solutions.Count; $i++) {
        $solution = $Solutions[$i]
        $percentage = $solution.probability.ToString() + "% success rate"
        $menuItems += @{
            Title = $solution.title
            Description = $solution.description
            Percentage = $percentage
            Index = $i + 1
        }
    }
    # Add manual option
    $menuItems += @{
        Title = "I will handle it myself"
        Description = "Skip automatic fixes and resolve manually"
        Percentage = ""
        Index = 6
    }
    $selectedIndex = 0
    $maxIndex = $menuItems.Count - 1
    # Hide cursor
    [Console]::CursorVisible = $false

    try {
        while ($true) {
            Clear-Host
            Write-Warning "[HELP] Available Solutions (Use Up/Down arrows to navigate, Enter to select):"
            Write-Host ""

            for ($i = 0; $i -lt $menuItems.Count; $i++) {
                $item = $menuItems[$i]
                $isSelected = ($i -eq $selectedIndex)
                if ($isSelected) {
                    Write-Host "  > " -NoNewline -ForegroundColor Green
                    Write-Host "[$($item.Index)] " -NoNewline -ForegroundColor Yellow -BackgroundColor DarkBlue
                    Write-Host "$($item.Title) " -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
                    if ($item.Percentage) {
                        Write-Host "($($item.Percentage))" -ForegroundColor Green -BackgroundColor DarkBlue
                    } else {
                        Write-Host "" -BackgroundColor DarkBlue
                    }
                    Write-Host "    " -NoNewline
                    Write-Host $item.Description -ForegroundColor Gray -BackgroundColor DarkBlue
                } else {
                    Write-Host "    " -NoNewline
                    Write-Host "[$($item.Index)] " -NoNewline -ForegroundColor Yellow
                    Write-Host "$($item.Title) " -NoNewline -ForegroundColor White
                    if ($item.Percentage) {
                        Write-Host "($($item.Percentage))" -ForegroundColor Green
                    } else {
                        Write-Host ""
                    }
                    Write-Host "      " -NoNewline
                    Write-Host $item.Description -ForegroundColor Gray
                }
                Write-Host ""
            }

            Write-Host ""
            Write-Host "Use Up/Down arrows to navigate, Enter to select, Esc to cancel" -ForegroundColor DarkGray

            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                'UpArrow' {
                    $selectedIndex = if ($selectedIndex -eq 0) { $maxIndex } else { $selectedIndex - 1 }
                }
                'DownArrow' {
                    $selectedIndex = if ($selectedIndex -eq $maxIndex) { 0 } else { $selectedIndex + 1 }
                }
                'Enter' {
                    [Console]::CursorVisible = $true
                    return $menuItems[$selectedIndex].Index
                }
                'Escape' {
                    [Console]::CursorVisible = $true
                    return -1
                }
                '1' { if ($menuItems.Count -ge 1) { [Console]::CursorVisible = $true; return 1 } }
                '2' { if ($menuItems.Count -ge 2) { [Console]::CursorVisible = $true; return 2 } }
                '3' { if ($menuItems.Count -ge 3) { [Console]::CursorVisible = $true; return 3 } }
                '4' { if ($menuItems.Count -ge 4) { [Console]::CursorVisible = $true; return 4 } }
                '5' { if ($menuItems.Count -ge 5) { [Console]::CursorVisible = $true; return 5 } }
                '6' { if ($menuItems.Count -ge 6) { [Console]::CursorVisible = $true; return 6 } }
            }
        }
    }
    catch {
        Write-Error "[X] Error in menu navigation: $($_.Exception.Message)"
    }
    finally {
        [Console]::CursorVisible = $true
        Clear-Host
    }
}

# Solution Selection and Application
function Show-SolutionMenu {
    param([array]$Solutions)
    
    return Show-InteractiveMenu -Solutions $Solutions
}

function Apply-Solution {
    param(
        [object]$Solution
    )
    
    Write-Info "[FIX] Applying solution: $($Solution.title)"
    Write-Host ""
    
    foreach ($step in $Solution.steps) {
        Write-Host "Step: $($step.description)" -ForegroundColor Cyan
        
        switch ($step.action) {
            "modify_file" {
                if (Test-Path $step.target) {
                    Write-Host "File to modify: $($step.target)" -ForegroundColor Yellow
                    Write-Host "Should I modify this file? [Y/N]: " -NoNewline
                    $confirm = Read-Host
                    
                    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                        try {
                            $originalContent = Get-Content $step.target -Raw -ErrorAction Stop
                            $step.content | Out-File -FilePath $step.target -Encoding UTF8 -NoNewline
                            
                            $script:ChangesLog += @{
                                Action = "Modified"
                                File = $step.target
                                Description = $step.description
                            }
                            
                            Write-Success "[+] Modified $($step.target)"
                        }
                        catch {
                            Write-Error "[X] Failed to modify $($step.target): $($_.Exception.Message)"
                        }
                    } else {
                        Write-Warning "[!] Skipped modifying $($step.target)"
                    }
                } else {
                    Write-Error "[X] File not found: $($step.target)"
                }
            }
            
            "create_file" {
                Write-Host "File to create: $($step.target)" -ForegroundColor Yellow
                Write-Host "Should I create this file? [Y/N]: " -NoNewline
                $confirm = Read-Host
                
                if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                    try {
                        $directory = Split-Path $step.target -Parent
                        if ($directory -and -not (Test-Path $directory)) {
                            New-Item -ItemType Directory -Path $directory -Force | Out-Null
                        }
                        
                        $step.content | Out-File -FilePath $step.target -Encoding UTF8 -NoNewline
                        
                        $script:ChangesLog += @{
                            Action = "Created"
                            File = $step.target
                            Description = $step.description
                        }
                        
                        Write-Success "[+] Created $($step.target)"
                    }
                    catch {
                        Write-Error "[X] Failed to create $($step.target): $($_.Exception.Message)"
                    }
                } else {
                    Write-Warning "[!] Skipped creating $($step.target)"
                }
            }
            
            "run_command" {
                Write-Host "Command to run: $($step.target) $($step.content)" -ForegroundColor Yellow
                Write-Host "Should I run this command? [Y/N]: " -NoNewline
                $confirm = Read-Host
                
                if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                    try {
                        Write-Info "Running: $($step.target) $($step.content)"
                        $result = Invoke-Expression "$($step.target) $($step.content)"
                        
                        $script:ChangesLog += @{
                            Action = "Executed"
                            File = "$($step.target) $($step.content)"
                            Description = $step.description
                        }
                        
                        Write-Success "[+] Command executed successfully"
                    }
                    catch {
                        Write-Error "[X] Command failed: $($_.Exception.Message)"
                    }
                } else {
                    Write-Warning "[!] Skipped running command"
                }
            }
            
            "delete_file" {
                if (Test-Path $step.target) {
                    Write-Host "File to delete: $($step.target)" -ForegroundColor Yellow
                    Write-Host "Should I delete this file? [Y/N]: " -NoNewline
                    $confirm = Read-Host
                    
                    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                        try {
                            Remove-Item $step.target -Force
                            
                            $script:ChangesLog += @{
                                Action = "Deleted"
                                File = $step.target
                                Description = $step.description
                            }
                            
                            Write-Success "[+] Deleted $($step.target)"
                        }
                        catch {
                            Write-Error "[X] Failed to delete $($step.target): $($_.Exception.Message)"
                        }
                    } else {
                        Write-Warning "[!] Skipped deleting $($step.target)"
                    }
                } else {
                    Write-Warning "[!] File not found: $($step.target)"
                }
            }
        }
        
        Write-Host ""
    }
}

function Show-ChangesLog {
    if ($script:ChangesLog.Count -eq 0) {
        Write-Info "[LOG] No changes were made."
        return
    }
    
    Write-Success "[LOG] Summary of changes made:"
    Write-Host ""
    
    foreach ($change in $script:ChangesLog) {
        Write-Host "  $($change.Action): " -NoNewline -ForegroundColor Yellow
        Write-Host "$($change.File)" -ForegroundColor White
        Write-Host "    $($change.Description)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Info "[DIR] Returned to project directory: $script:ProjectRoot"
}

# Main execution logic
function Main {
    # Check if this is a Flutter project
    if (-not (Test-Path "pubspec.yaml")) {
        Write-Error "This does not appear to be a Flutter project (no pubspec.yaml found)"
        exit 1
    }
    
    # Show help if no command provided
    if (-not $Command) {
        Write-Info "[*] Zeeshan - AI-Powered Flutter Command Wrapper"
        Write-Host ""
        Write-Host "Usage: zeeshantesting " -NoNewline -ForegroundColor Yellow
        Write-Host "command [arguments]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  zeeshantesting build apk"
        Write-Host "  zeeshantesting build appbundle"
        Write-Host "  zeeshantesting pub get"
        Write-Host "  zeeshantesting run"
        Write-Host "  zeeshantesting test"
        Write-Host ""
        Write-Host "This tool wraps Flutter commands and provides AI-powered error resolution."
        exit 0
    }
    
    # Execute the Flutter command
    $result = Invoke-FlutterCommand -Command $Command -Arguments $Arguments
    
    Write-Host ""
    
    if ($result.Success) {
        Write-Success "[+] Command completed successfully!"
    } else {
        Write-Error "[X] Command failed with exit code: $($result.ExitCode)"
        
        # Only proceed with AI analysis if there's actual error content
        if ($result.Error -or ($result.Output -and $result.Output.Contains("error"))) {
            Write-Host ""
            Write-Info "[AI] Analyzing error for potential solutions..."
            
            $solutions = Get-ErrorSolutions -Command "$Command $($Arguments -join ' ')" -Error $result.Error -Output $result.Output
            
            if ($solutions -and $solutions.Count -gt 0) {
                $choice = Show-SolutionMenu -Solutions $solutions
                
                if ($choice -eq -1) {
                    Write-Info "[CANCELLED] Operation cancelled by user."
                } elseif ($choice -eq 6) {
                    Write-Info "[OK] No problem! You have got this."
                } else {
                    $selectedSolution = $solutions[$choice - 1]
                    Apply-Solution -Solution $selectedSolution
                    Show-ChangesLog
                }
            } else {
                Write-Warning "[!] Could not generate solutions. Please check the error manually."
            }
        }
    }
    
    # Return to original directory
    Set-Location $script:ProjectRoot
}

# Execute main function
Main