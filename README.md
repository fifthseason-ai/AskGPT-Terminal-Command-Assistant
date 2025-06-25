# AskGPT Terminal Command Assistant

**AskGPT** is a lightweight Bash script that turns your terminal into an AI-powered command-line assistant. Type natural language like:

```bash
ask "show all listening ports"
```

…and get the exact shell command back—copied straight to your clipboard.

---

## ✨ Features

* **🗣 Natural Language Queries**
  Ask for a terminal command in plain English. No syntax memorization required.

* **📋 Clipboard Copy**
  The result is automatically copied to your clipboard via `xclip`.

* **🧠 Context-Aware Memory**
  Remembers the last 10 questions and responses and includes them in the prompt for improved relevance.

* **🛠 Automatic Setup**
  Installs `xclip` if missing. Just drop in and go.

* **⚡ Fast & Local**
  Just Bash + `curl` + `jq`. No extra dependencies or daemons.

---

## 🚀 Installation

1. **Save the Script**
   Run this one-liner in your terminal:

   ```bash
    mkdir -p ~/.local/bin && curl -o ~/.local/bin/askgpt.sh https://raw.githubusercontent.com/fifthseason-ai/AskGPT-Terminal-Command-Assistant/main/askgpt.sh && chmod +x ~/.local/bin/askgpt.sh
   ```

2. **Create an Alias**
   Add this to your `~/.bashrc` or `~/.zshrc`:

   ```bash
   alias ask='~/.local/bin/askgpt.sh'
   ```

   Then reload your shell:

   ```bash
   source ~/.bashrc   # or source ~/.zshrc
   ```

---

## 🧪 Usage

Just type:

```bash
ask "find large files in this directory"
```

And you’ll get:

```bash
find . -type f -exec du -h {} + | sort -rh | head -n 10
```

The command is printed to the terminal and automatically copied to your clipboard.

---

## 📁 Memory File

AskGPT creates and maintains a memory file at:

```bash
~/.local/bin/askgpt.memory
```

It stores the last 10 question-response pairs and reuses them as context for better continuity.

---

## 🔐 API Key

This script uses the OpenAI API. You’ll need a valid `sk-` or `gpt-4o` project key. Add it inside the script like this:

```bash
API_KEY="your_openai_key_here"
```

---

## 💡 Tip

The more you use it, the smarter your session becomes—without ever storing data online. It's just shell + memory.

---

## 📜 License

MIT License. Use it, modify it, share it. Just don’t paste your API key in a public repo.
