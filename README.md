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

At least **one option** is required

| Name               | Description                                                                                   
| ------             | -----------                                                                                   
| -nv, --new-version | New RC name                                                                                   
| -b, --branches     | Branches to merge on new RC<br />**They must be in double quotes**<br />**Space** delimited 
| -major             | Major version increment on new RC                                                             
| -minor             | Minor version increment on new RC                                                             
| -patch             | Patch version increment on new RC                                                             

Some notes about how `hypa-git` handle these options
* If no new version option is provided, `hypa-git` will increment version based on semver option
* If no semver option is provided, `hypa-git` will consider the new RC as a patch.
* If no branch option is provided, `hypa-git` will only create and push the new RC.
* If RC already exists, `hypa-git` will skip creation step.

### Usage Examples

Let's use a git repository with newest tag named **1.13.1** as an example:

```sh
# This block will create a new branch named '1.13.2-RC'
# And merge 'branch-one' and 'branch-two' 
hypa-git -b "branch-one branch-two"

# This block will create a new branch named '1.14.0-RC' 
# And merge 'branch-one'
# In case there's a conflict, hypa-git you warn you and open vscode (if installed)
hypa-git -b "branch-one" -minor

# This block will create a new branch named '2.0.0-RC'
hypa-git -nv 2.0.0-RC

# This block will create a new branch named '1.13.2-RC'
hypa-git -patch 
```

## Contributors

| Thanks for the idea!<br />[![Renan Marangon](https://github.com/maracunha.png?size=100)](https://github.com/maracunha) |
| :--:                                                                                           |
| [Renan Marangon](https://github.com/maracunha)                                                 |
