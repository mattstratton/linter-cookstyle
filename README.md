# linter-cookstyle

This is a [cookstyle](https://github.com/chef/cookstyle) provider for
[linter][linter]. It will be used with files
that have the [Chef syntax](https://atom.io/packages/language-chef).

## Installation

The `linter` package must be installed in order to use this plugin. If it
is not installed, please follow the instructions [here][linter].

### `cookstyle` Installation

Before using this plugin, you must ensure that `cookstyle` is installed on
your system. To install `cookstyle`, do the following:

1.  Install [ruby](https://www.ruby-lang.org/).

2.  Install `cookstyle` by typing the following in a terminal:

    ```ShellSession
    gem install cookstyle
    ```

3.  Alternatively install ChefDK which already includes `cookstyle`:
    <https://downloads.chef.io/chef-dk/>

Now you can proceed to install the `linter-cookstyle` plugin.

### Plugin installation

```ShellSession
$ apm install linter-cookstyle
```

[linter]: https://github.com/atom-community/linter "Linter"
