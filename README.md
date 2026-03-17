# tmux-net-speed

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2018)

A tmux plugin for displaying network upload and download speed in the status bar.

### 📥 Installation

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

Add this line to your tmux config file, then hit `prefix + I`:

```tmux
set -g @plugin 'wfxr/tmux-net-speed'
```

**Install manually**

```bash
git clone https://github.com/wfxr/tmux-net-speed ~/.tmux/plugins/tmux-net-speed
```

Then add the following line to your `~/.tmux.conf`:

```tmux
run-shell ~/.tmux/plugins/tmux-net-speed/net-speed.tmux
```

### 📝 Usage

Use `#{upload_speed}` and `#{download_speed}` in your `status-right` or `status-left` options:

```tmux
set -g status-right '#{upload_speed} #{download_speed}'
```

This works great with [tmux-power](https://github.com/wfxr/tmux-power):

```tmux
set -g @tmux_power_show_upload_speed   true
set -g @tmux_power_show_download_speed true
```

### ⚙ Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `@net_speed_interfaces` | *(empty)* | Space-separated list of interfaces to monitor. If empty, all non-virtual interfaces are used. |
| `@upload_speed_format` | `%7s` | printf format string for upload speed |
| `@download_speed_format` | `%7s` | printf format string for download speed |

Example:

```tmux
set -g @upload_speed_format   '%s'
set -g @download_speed_format '%s'
```

### 💻 Supported Platforms

- Linux
- macOS
- FreeBSD
- NetBSD
- OpenBSD

### 🔗 Other plugins

- [tmux-power](https://github.com/wfxr/tmux-power)
- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url)
- [tmux-web-reachable](https://github.com/wfxr/tmux-web-reachable)

### 📃 License

[MIT](https://wfxr.mit-license.org/2018) (c) Wenxuan Zhang
