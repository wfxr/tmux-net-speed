# tmux-net-speed

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![Awesome](https://img.shields.io/badge/Awesome-tmux-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Uas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/rothgar/awesome-tmux)
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
