---
name: nido
description: Run code, commands, services and training jobs in isolated Pirol sandboxes (nido) instead of on this computer — small virtual machines in the EU, CPU or with a whole GPU. Use when the person asks for a sandbox, wants something run in isolation (untrusted code, a dependency install, a risky script, a long job, a server or database to try out), needs a GPU to train or fine-tune a model, or mentions nido or Pirol sandboxes.
---

# Pirol sandboxes with nido

A sandbox is a small virtual machine of its own, in the EU, run by [Pirol](https://pirol.ai). You
drive it with the `nido` command line on this computer. nido acts **as the person**, with their
account and their budget. Every sandbox they keep running costs money, and a GPU costs much more.

Work with the least access that does the job. Open only the hosts a task needs, pass only the
secrets it needs, and use `--root` only when a system package really has to be installed.

## 1. Check that nido is ready

```bash
nido --version
nido whoami
```

- **`nido` not found:** it needs Node 20 or newer. Ask the person before you install anything,
  then run `npm install -g @pirol/nido`.
- **Older than 0.7.4:** this skill needs nido 0.7.4 or newer (`--root`, `--expose` and `--connect`
  came with it). Ask the person, then run `nido update`.
- **`Not logged in`:** the person logs in themselves. Ask them to run `nido login` in their own
  terminal. It opens their browser, and nido stores its key in `~/.nido/config.json`. On a machine
  without a browser it is `nido login --manual`. Do not run the login for them, and never ask for,
  read, print or copy a key. In CI, `PIROL_API_KEY` is set instead.
- **Access denied for the account:** sandboxes are in a closed beta for invited accounts. Access
  is requested at hello@pirol.ai.

## 2. Create a sandbox

```bash
nido create <name>
```

Ready in about 20 seconds. Pick a short name for the task, such as `scratch` or `api-test`. Run
`nido ls` first and reuse a sandbox that is already there for the same work.

Everything is closed by default. Add only what the task needs, at creation time — none of these can
be changed later; to change them, remove the sandbox and create it again:

| Option | Use it when |
| --- | --- |
| `--network <host>` | The task downloads from a host. One flag per host, e.g. `--network pypi.org --network files.pythonhosted.org`. `*.example.com` opens one more label, `**.example.com` any number. |
| `--secret <name>` | A program in the sandbox calls `anthropic`, `openai` or `github`. It sees only a placeholder; the real key is added on the way out. The person stores a secret once with `nido secret set <name>` — in their own terminal, because it asks for the key. |
| `--image <ref>` | The task needs its own container image. Commands then run with the image's `ENV`, without a login shell. |
| `--storage <name>` | A storage volume should be at `/data/<name>` (CPU sandboxes only). |
| `--from <template>` | Start from a saved template (`nido save <sandbox> <template>`). |
| `--expose <port>` / `--connect <sandbox>:<port>` | Sandboxes should talk to each other, see section 5. |
| `--root` | Only when a system package must be installed with `apt`. The program then runs as root inside the sandbox's own VM. Not for GPU sandboxes. Say why you add it. |

Python packages need no root: `pip install` or `uv pip install` with `--network pypi.org
--network files.pythonhosted.org`.

### GPU sandboxes

```bash
nido create train --gpu l4 --network huggingface.co --network '**.hf.co'
```

- A GPU is billed by the second, on top of CPU and memory, for as long as the sandbox runs. **Ask
  the person before you create one**, say which GPU, and point to the prices at
  [pirol.ai/pricing](https://pirol.ai/pricing#sandboxes). Never guess a price.
- `l4` is one NVIDIA L4 with 24 GB. If no GPU is free, nido waits and shows how long.
- A GPU sandbox comes with Python 3.12 in `/sandbox/.venv`, PyTorch with CUDA, and the Hugging Face
  libraries. Storage volumes cannot be attached yet: copy data in with `nido cp` or download it.
- Copy the results out and remove the sandbox as soon as the run is done.

## 3. Run commands

```bash
nido exec <name> -- python3 --version
nido exec <name> -- bash -c 'cd /sandbox/app && pip install -r requirements.txt && pytest -q'
```

- Commands start in `/sandbox` and return their exit code. Use `bash -c '…'` for pipes, `&&` and
  `cd`.
- There is no interactive shell. Do not start anything that waits for input.
- Long jobs: `nido exec <name> --detach -- python3 train.py`. nido answers at once and names a log
  file. Read it with `nido exec <name> -- tail -n 50 <log>`.
- A download fails with "Couldn't connect"? The host is not open. `nido logs <name>` names it
  (`is not allowed by any policy`). Tell the person which host is missing, and recreate the
  sandbox with that `--network` once they agree.

## 4. Copy files in and out

```bash
nido cp ./src <name>:/sandbox/src
nido cp <name>:/sandbox/results ./results
nido cp <name>:/sandbox/report.md ./report.md
```

- The sandbox side is written `<name>:<path>` and must be below `/sandbox`.
- It works like `cp`: a file lands under the name you give, or inside the target when that is an
  existing folder or ends in `/`. A folder's contents land in the target folder.
- Do not copy secrets, `.env` files or SSH keys into a sandbox. Use `--secret` instead.

## 5. Ports and connected sandboxes

A sandbox has no public address. A port can be opened only to other sandboxes of the same person,
and both sides must agree:

```bash
nido create db  --expose 5432
nido create app --connect db:5432
nido exec app -- psql -h db.sandbox.internal -p 5432
```

- `--expose <port>`: the program must listen on that port (`127.0.0.1` is enough).
- `--connect <sandbox>:<port>`: the other sandbox is reached as `<sandbox>.sandbox.internal`.
- Only TCP, only one way. GPU and CPU sandboxes cannot connect to each other.

To try a web server, run it in the sandbox and test it from inside, e.g. `nido exec app -- curl -s
localhost:8000/health`.

## 6. Clean up

```bash
nido ls
nido rm <name>
```

- When the work is done and the results are copied out, remove the sandboxes **you** created for
  it, and say so. Ask first before you remove a sandbox you did not create.
- Remove it also when a command failed. Run `nido rm` as its own step, not chained after `&&`.
- `nido stop <name>` pauses a sandbox and backs `/sandbox` up first; a stopped sandbox costs
  nothing but its storage. `nido start <name>` brings it back. Use this when the person wants to
  continue later.
- `nido rm` keeps the last backup. Add `--backup` only when the person asks to delete it too.
- Before you end, list what is still running with `nido ls`, especially GPU sandboxes.

## More

- Storage volumes: `nido storage put ./data my-data`, then `--storage my-data`.
- Templates: `nido save <sandbox> <template>`, `nido fork <from> <new>`.
- A whole folder as a task: `nido init` and `nido run` (see the docs).
- `nido --help` lists every command. Docs: [pirol.ai/docs/sandboxes](https://pirol.ai/docs/sandboxes).

Report what you did in a few lines: which sandbox, which hosts and secrets you opened, what ran,
where the results are now, and what is still running.
