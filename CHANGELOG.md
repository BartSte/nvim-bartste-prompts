# Changelog - bartste-prompts

This document describes the changes that were made to the software for each
version. The changes are described concisely, to make it comprehensible for the
user. A change is always categorized based on the following types:

- Bug: a fault in the software is fixed.
- Feature: a functionality is added to the program.
- Improvement: a functionality in the software is improved.
- Breaking Change: a change that breaks backward compatibility.

## 1.0.0

### Breaking Change

- made compatible with bartste-prompts 1.0

### Features

- Write output to markdown temp file and open it correctly in new tabs
- Add `:AiExplain` command to explain selected code
- Add `:AiShowOutput` command to view command output buffer
- Add `:AiUndo` command to restore previous file version

### Improvements

- Refactor core job management and output handling
- Use temporary files in dedicated backup directory
- Improve user prompt template for better code focus

### Bug Fixes

- Fix spinner notification hiding on command exit

## 0.3.3 - 2025-06-11

### Bug Fixes

- Implement persistent backup files and restore command with configurable backup directory

## 0.3.2 - 2025-05-25

### Bug Fixes

- Fix AiUndo command
- Do not show diff when nothing changed

## 0.3.1 - 2025-05-25

### Bug Fixes

- Fix commands accepting user command arguments

## 0.3.0 - 2025-05-24

### Features

- Support multiple aider processes in parallel
- Replace AiStdout and AiStdErr with log file

## 0.2.0 - 2025-05-20

### Features

- Add visual selection range support for prompt commands
- Implement --loglevel option for command execution
- Add AiStdOut/AiStdErr commands to show command output
- Create spinner notifications with configurable options
- Implement command abort functionality
- Add spinning status icon animation during commands
- Introduce lualine running indicator component

## 0.1.0 - 2025-04-12

### Features

- Initial plugin setup with AI command integration
- Non-blocking async command execution
- Automatic diff view after changes
- Executable validation before setup
