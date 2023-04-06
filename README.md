I2PControl for Lua and Conky-Lua
================================

Make sure to check out all the submodules, see: lua/README.md

![screenshot.png](screenshot.png)

```sh
# from this directory(a checkout)
conky -c _dot_conkyrc
```

```sh
# installation to $HOME/.conkyrc
mkdir -p $HOME/lua
cp -rv lua/* $HOME/lua/
cp -v _dot_conkyrc $HOME/.conkyrc
conky -c _dot_conkyrc
```