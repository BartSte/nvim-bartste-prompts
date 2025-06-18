# Changelog - nvim-bartste-prompts

This document describes the changes that were made to the software for each
version. The changes are described concisely, to make it comprehensible for the
user. A change is always categorized based on the following types:

- Bug: a fault in the software is fixed.
- Feature: a functionality is added to the program.
- Improvement: a functionality in the software is improved.
- Breaking Change: a change that breaks backward compatibility.

## 1.0.0 - 2025-06-18

### Breaking Change

- made compatible with bartste-prompts 1.0

### Features

- Write output to markdown temp file and open it correctly in new tabs

### Improvements

- Made prompt more generic

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
