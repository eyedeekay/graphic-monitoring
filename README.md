I2PControl for Lua and Conky-Lua
================================

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