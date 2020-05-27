<h1 align="center">
  <a href="https://github.com/luizeboli/hypa-git">
    <img alt="Hypa Git" src="https://i.imgur.com/3bswOSQ.png">
  </a>
  <br>Hypa Git<br>
</h1>

Hypa-Git is a <a href="http://zsh.org" target="_blank"><code>zsh</code></a> script to help us with the robotic task of create RC's and merge all branches at the sprint ending.

Briefly what `hypa-git` does is create a new RC branch from last tag and name it based on provided semantic version option.

> Note¹: This is an alpha version, which means that you might find some bugs.
> Please open an issue if so 😁.

> Note²: I'm not a zsh expert. Perhaps some code on this script can be done better or are wrong.
> I would be happy if you open an issue to talk about it 🤝

## Requirements

You **must** have <a href="http://zsh.org" target="_blank"><code>zsh</code></a> installed in order to use `hypa-git`.

## Installing

### [npm](https://npmjs.com)

```
npm install -g hypa-git
```

Easy peasy. This command should copy `hypa-git` to `$HOME/.hypa-git` and link it on your `/usr/local/bin` folder to make it executable.

### Manual

1) Clone this repository:
`git clone https://github.com/luizeboli/hypa-git`;

2) Copy `hypa-git` folder to `$HOME/.hypa-git`:
`cp -R /path/where/you/cloned/hypa-git $HOME/.hypa-git`;

3) Create a symbolic link on your `/usr/local/bin`folder:
`ln -s path/where/you/cloned/hypa-git/index.zsh /usr/local/bin/hypa-git`;

## Usage

You can exec `hypa-git` from your terminal for a usage guide or look at below options.

### Options

| Name           | Description | Required |
| ------         | ----------- | -------- |
| -major         | Major version increment on new RC | No
| -minor         | Minor version increment on new RC | No
| -patch         | Patch version increment on new RC | No
| -b, --branches | Branches to merge on new RC       | Yes

> Note: If no semantic version option is provided, hypa-git will consider the new RC as a patch.