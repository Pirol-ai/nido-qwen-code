# nido for Qwen Code

**nido** runs code in isolated sandboxes: each one is a small virtual machine of its own, in the EU,
run by [Pirol](https://pirol.ai). This extension teaches Qwen Code when and how to use them — so you can
say *"try this in a sandbox"* or *"fine-tune this on a GPU"*, and Qwen Code creates the sandbox, runs
the work there, copies the results back and cleans up.

Qwen Code drives nido the way you would: with the `nido` command line on your computer, as you, with
your account and your budget. Nothing new runs in the background.

## What you need

The **nido command line**, version 0.7.4 or newer (Node 20 or newer), installed and logged in once:

```bash
npm install -g @pirol/nido
nido login
```

`nido login` opens your browser and you confirm with your Pirol account. Qwen Code never sees a key.

> **Closed beta.** Sandboxes are open to invited accounts. Ask for access at
> [hello@pirol.ai](mailto:hello@pirol.ai).

## Install

```bash
qwen extensions install Pirol-ai/nido-qwen-code
```

Qwen Code installs an extension straight from a Git repository, so there is no marketplace to add
first. Start a new session afterwards. The skill is called `nido`; Qwen Code uses it on its own
when a task fits, and `/extensions` shows the extension.

## Use it

Ask in plain words. A few prompts to start with:

- *"Run the test suite in a nido sandbox, not on my machine."*
- *"Clone this repo into a sandbox and check whether `npm install` runs any install scripts."*
- *"Start Postgres in one sandbox and our API in another, connected, and run the integration tests."*
- *"Fine-tune Qwen2.5-0.5B with LoRA on `data/tickets.jsonl` on an L4 GPU, then bring the adapter back."*
- *"Which sandboxes are still running? Remove the ones from today."*

Qwen Code checks that nido is installed and logged in, asks before it installs nido or starts a GPU,
opens only the network hosts and secrets the task needs, and removes the sandboxes it created when
the work is done.

## Let it run nido without asking

Qwen Code asks before every shell command. When it asks to run `nido`, you can allow it for good.
That includes creating and removing sandboxes; approve each one instead if you prefer.

## What it runs, sends and stores

- **Runs:** only the `nido` command on your computer, when Qwen Code decides to call it. This
  extension adds instructions, no server and no background process.
- **Sends:** what you copy into a sandbox with `nido cp` goes to that sandbox, in the EU. What a
  command in the sandbox prints goes back to Qwen Code and from there to its model, as with any
  command it runs.
- **Stores:** nothing of its own. nido keeps its login key in `~/.nido/config.json`.
- **Costs:** sandboxes are billed from your Pirol budget while they run; GPUs cost more. Prices:
  [pirol.ai/pricing](https://pirol.ai/pricing#sandboxes).

## The same skill for every agent

The skill in `skills/nido` is the same in all five nido integrations:
[Claude Code](https://github.com/Pirol-ai/nido-claude-code),
[Codex](https://github.com/Pirol-ai/nido-codex),
[GitHub Copilot](https://github.com/Pirol-ai/nido-copilot),
[OpenCode](https://github.com/Pirol-ai/nido-opencode) and
[Qwen Code](https://github.com/Pirol-ai/nido-qwen-code).
Any other agent that runs shell commands can use it too: copy the folder to wherever it reads
skills.

## Checking it

`sh check.sh` installs the extension into a throwaway `HOME`, so your own Qwen Code is not
touched, and checks what Qwen Code made of it. It needs `qwen` and `node`.
`node --test tests/*.test.mjs` checks the manifest alone and runs on every pull request.

## Support

Questions and problems: [github.com/Pirol-ai/nido-qwen-code/issues](https://github.com/Pirol-ai/nido-qwen-code/issues).
Documentation: [pirol.ai/docs/sandboxes](https://pirol.ai/docs/sandboxes) ·
Privacy: [pirol.ai/privacy](https://pirol.ai/privacy) · Terms: [pirol.ai/terms](https://pirol.ai/terms)

## License

MIT — see [LICENSE](LICENSE). The licence covers this extension; the nido command line is licensed
separately.
