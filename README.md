# Personal Assistant iOS App

This repository contains a SwiftUI iOS app that acts as a personal AI assistant. It uses OpenAI's chat completions API by default and can be pointed at another OpenAI-compatible provider.

## Features

- Chat-style personal assistant interface
- Configurable AI model and API base URL
- API key stored locally in the iOS Keychain
- No API secrets committed to source control

## Run locally

1. Open `PersonalAssistant.xcodeproj` in Xcode.
2. Select an iPhone simulator or a signed iOS device target.
3. Build and run the `PersonalAssistant` scheme.
4. In the app, open Settings and add your AI provider API key.

Defaults:

- Base URL: `https://api.openai.com/v1`
- Model: `gpt-4o-mini`

For another provider, enter that provider's OpenAI-compatible base URL and model name in Settings.
